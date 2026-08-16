<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="br.com.gerencia.model.usuarioModel"%>
<%@ page import="br.com.gerencia.model.eventoModel"%>
<%@ page import="br.com.gerencia.model.fornecedorModel"%>
<%@ page import="br.com.gerencia.model.contratoModel"%>
<%@ page import="br.com.gerencia.model.inscricaoModel"%>
<%@ page import="br.com.gerencia.model.notificacaoModel"%>
<%@ page import="br.com.gerencia.dao.eventoDAO"%>
<%@ page import="br.com.gerencia.dao.fornecedorDAO"%>
<%@ page import="br.com.gerencia.dao.contratoDAO"%>
<%@ page import="br.com.gerencia.dao.inscricaoDAO"%>
<%@ page import="br.com.gerencia.dao.notificacaoDAO"%>
<%@ page import="br.com.gerencia.dao.usuarioDAO"%>
<%@ page import="br.com.gerencia.utils.Conexao"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.time.format.DateTimeFormatter"%>
<%
    // ================= GUARDA DE SESSÃO =================
    usuarioModel usuarioLogado = (usuarioModel) session.getAttribute("usuarioLogado");

    if (usuarioLogado == null) {
        response.sendRedirect(request.getContextPath() + "/pages/loginUsuario.jsp");
        return;
    }

    if (!"organizador".equals(usuarioLogado.getTipo_usuario())) {
        response.sendRedirect(request.getContextPath() + "/pages/home.jsp");
        return;
    }

    String nomeUsuario = usuarioLogado.getNome_usuario();

    String iniciais = "?";
    if (nomeUsuario != null && !nomeUsuario.isBlank()) {
        String[] partes = nomeUsuario.trim().split("\\s+");
        iniciais = partes.length > 1
            ? ("" + partes[0].charAt(0) + partes[partes.length - 1].charAt(0)).toUpperCase()
            : ("" + partes[0].charAt(0)).toUpperCase();
    }

    // ================= DADOS REAIS DO BANCO =================
    eventoDAO eventoDAOJsp = new eventoDAO(Conexao.getConnection());
    fornecedorDAO fornecedorDAOJsp = new fornecedorDAO(Conexao.getConnection());
    contratoDAO contratoDAOJsp = new contratoDAO(Conexao.getConnection());
    inscricaoDAO inscricaoDAOJsp = new inscricaoDAO(Conexao.getConnection());
    notificacaoDAO notificacaoDAOJsp = new notificacaoDAO(Conexao.getConnection());
    usuarioDAO usuarioDAOJsp = new usuarioDAO(Conexao.getConnection());

    List<eventoModel> meusEventos = new ArrayList<eventoModel>();
    for (eventoModel ev : eventoDAOJsp.listarEventos()) {
        if (ev.getId_organizador() == usuarioLogado.getId_usuario()) {
            meusEventos.add(ev);
        }
    }

    List<fornecedorModel> todosFornecedores = fornecedorDAOJsp.listarFornecedores();
    List<contratoModel> todosContratos = contratoDAOJsp.listarContratos();

    List<notificacaoModel> minhasNotificacoes =
        notificacaoDAOJsp.listarPorUsuario(usuarioLogado.getId_usuario());

    int notifNaoLidas = notificacaoDAOJsp.contarNaoLidas(usuarioLogado.getId_usuario());

    DateTimeFormatter fmtData = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter fmtHora = DateTimeFormatter.ofPattern("HH:mm");
    DateTimeFormatter fmtDataHora = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    // mapas auxiliares nome_fornecedor / nome_evento por id, pra montar os JSONs
    HashMap<Integer, String> nomeFornecedorPorId = new HashMap<Integer, String>();
    for (fornecedorModel f : todosFornecedores) {
        nomeFornecedorPorId.put(f.getId_fornecedor(), f.getNome_fornecedor());
    }

    HashMap<Integer, String> nomeEventoPorId = new HashMap<Integer, String>();
    for (eventoModel ev : meusEventos) {
        nomeEventoPorId.put(ev.getId_evento(), ev.getNome_evento());
    }

    // agregados do dashboard
    int totalEventosAtivos = 0;
    int totalInscritosSoma = 0;
    int totalNaEsperaSoma = 0;

    // ================= MENSAGEM FLASH (ex: erro de CNPJ duplicado) =================
    String flashMsgOrg = (String) session.getAttribute("flashMsg");
    if (flashMsgOrg != null) {
        session.removeAttribute("flashMsg");
    }
    int somaPercentual = 0;
    int qtdEventosComCapacidade = 0;
%>
<%!
    private String js(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("'", "\\'").replace("\r", " ").replace("\n", " ").replace("</", "<\\/");
    }
    private String rotuloTipoConta(String tipo) {
        if ("organizador".equals(tipo)) return "Organizador";
        if ("admin".equals(tipo)) return "Admin";
        return "Cliente";
    }
    private String rotuloStatusEvento(String s) {
        if (s == null) return "";
        if ("ativo".equals(s)) return "Ativo";
        if ("rascunho".equals(s)) return "Rascunho";
        if ("cancelado".equals(s)) return "Cancelado";
        if ("finalizado".equals(s)) return "Finalizado";
        return s;
    }
    private String rotuloCategoria(String c) {
        if (c == null) return "";
        if ("tecCientifico".equals(c)) return "TecCientifico";
        if ("sociais".equals(c)) return "Sociais";
        if ("corporativos".equals(c)) return "Corporativos";
        return c;
    }
    private String rotuloCategoriaFornecedor(String c) {
        if (c == null) return "";
        switch (c) {
            case "audioVisual": return "Audiovisual";
            case "buffet": return "Buffet";
            case "decoracao": return "Decoração";
            case "fotografia": return "Fotografia";
            case "seguranca": return "Segurança";
            case "limpeza": return "Limpeza";
            case "locaoEspaco": return "Locação de Espaço";
            default: return c;
        }
    }
%>
<%
    // ================= AGREGADOS POR EVENTO (inscritos/espera/percentual) =================
    HashMap<Integer, Integer> inscritosPorEvento = new HashMap<Integer, Integer>();
    HashMap<Integer, Integer> esperaPorEvento = new HashMap<Integer, Integer>();
    HashMap<Integer, Integer> percentualPorEvento = new HashMap<Integer, Integer>();

    for (eventoModel ev : meusEventos) {

        int confirmados = inscricaoDAOJsp.contarConfirmados(ev.getId_evento());
        int emEspera = inscricaoDAOJsp.listarPorEventoEStatus(ev.getId_evento(), "Espera").size();
        int pct = ev.getCapacidade_evento() > 0
            ? (int) Math.round((confirmados * 100.0) / ev.getCapacidade_evento())
            : 0;

        inscritosPorEvento.put(ev.getId_evento(), confirmados);
        esperaPorEvento.put(ev.getId_evento(), emEspera);
        percentualPorEvento.put(ev.getId_evento(), pct);

        if ("ativo".equals(ev.getStatus_evento())) {
            totalEventosAtivos++;
        }

        totalInscritosSoma += confirmados;
        totalNaEsperaSoma += emEspera;

        if (ev.getCapacidade_evento() > 0) {
            somaPercentual += pct;
            qtdEventosComCapacidade++;
        }
    }

    int ocupacaoMedia = qtdEventosComCapacidade > 0
        ? (somaPercentual / qtdEventosComCapacidade)
        : 0;

    // eventos ordenados por data de início (mais próximos primeiro), pra "Próximos eventos"
    List<eventoModel> eventosOrdenados = new ArrayList<eventoModel>(meusEventos);
    java.util.Collections.sort(eventosOrdenados, new java.util.Comparator<eventoModel>() {
        public int compare(eventoModel a, eventoModel b) {
            return a.getInicio_evento().compareTo(b.getInicio_evento());
        }
    });
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GerenCIA - Painel do Organizador</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>

<style>

    * { margin: 0; padding: 0; box-sizing: border-box; }

    html, body {
        height: 100%;
        font-family: 'Inter', Arial, Helvetica, sans-serif;
        color: #0F172A;
        background: #F8FAFC;
        overflow: hidden;
    }

    a { text-decoration: none; color: inherit; }
    button { font-family: inherit; cursor: pointer; }

    /* ================= LAYOUT GERAL (sem scroll na página toda) ================= */

    .app {
        display: grid;
        grid-template-columns: 226px 1fr;
        height: 100vh;
        min-width: 0;
    }

    .sidebar {
        background: #FFFFFF;
        border-right: 1px solid #E2E8F0;
        display: flex;
        flex-direction: column;
        padding: 16px 12px;
        height: 100vh;
        overflow-y: auto;
    }

    .sidebar-logo {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 6px 8px 18px;
    }

    .sidebar-logo-icon {
        width: 32px;
        height: 32px;
        border-radius: 9px;
        background: linear-gradient(135deg, #7C3AED, #4C1D95);
        color: #FFFFFF;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 15px;
    }

    .sidebar-logo span { font-size: 15px; font-weight: 700; }

    .nav-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 9px 11px;
        border-radius: 9px;
        font-size: 13px;
        font-weight: 500;
        color: #475569;
        margin-bottom: 2px;
        border: none;
        background: none;
        width: 100%;
        text-align: left;
    }

    .nav-item .nav-icon { font-size: 14px; width: 17px; text-align: center; }
    .nav-item .nav-label { flex: 1; }

    .nav-item .nav-badge {
        min-width: 17px;
        height: 17px;
        padding: 0 5px;
        border-radius: 9px;
        background: #F59E0B;
        color: #FFFFFF;
        font-size: 10px;
        font-weight: 700;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .nav-item:hover { background: #F5F3FF; }
    .nav-item.active { background: #F5F3FF; color: #7C3AED; }

    .sidebar-footer {
        margin-top: auto;
        padding-top: 12px;
        border-top: 1px solid #E2E8F0;
        display: flex;
        align-items: center;
        gap: 9px;
        padding: 12px 7px 4px;
    }

    .avatar {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: linear-gradient(135deg, #7C3AED, #4C1D95);
        color: #FFFFFF;
        font-size: 11px;
        font-weight: 700;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }

    .sidebar-footer strong { display: block; font-size: 12px; }
    .sidebar-footer small { display: block; font-size: 10px; color: #94A3B8; }

    .logout-btn { margin-left: auto; font-size: 14px; color: #94A3B8; background: none; border: none; }

    /* ================= COLUNA PRINCIPAL (topbar fixa + conteúdo com scroll próprio) ================= */

    .main-col {
        display: flex;
        flex-direction: column;
        height: 100vh;
        overflow: hidden;
        min-width: 0;
    }

    .topbar {
        height: 56px;
        background: #FFFFFF;
        border-bottom: 1px solid #E2E8F0;
        display: flex;
        align-items: center;
        padding: 0 24px;
        flex-shrink: 0;
        position: relative;
        z-index: 20;
    }

    .topbar-title strong { display: block; font-size: 13px; }
    .topbar-title span { display: block; font-size: 10px; color: #94A3B8; }

    .topbar-actions { margin-left: auto; display: flex; align-items: center; gap: 14px; }

    .bell-wrap { position: relative; }

    .bell-btn {
        width: 32px; height: 32px; border-radius: 8px; border: none;
        background: #F1F5F9; font-size: 14px; color: #475569;
        display: flex; align-items: center; justify-content: center; position: relative;
    }

    .bell-btn .dot {
        position: absolute; top: 4px; right: 5px; width: 8px; height: 8px;
        border-radius: 50%; background: #EF4444; border: 2px solid #FFFFFF; display: none;
    }

    .bell-btn.unread .dot { display: block; }

    .notif-dropdown {
        position: absolute; top: 42px; right: 0; width: 320px;
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px;
        box-shadow: 0 20px 45px rgba(2,6,23,0.18); display: none; z-index: 30;
        max-height: 380px; display: none; flex-direction: column;
    }

    .notif-dropdown.open { display: flex; }

    .notif-dropdown-header {
        display: flex; align-items: center; justify-content: space-between;
        padding: 12px 14px; border-bottom: 1px solid #F1F5F9; font-size: 13px; font-weight: 700;
    }

    .notif-dropdown-header a { font-size: 11px; font-weight: 600; color: #2563EB; }

    .notif-list { overflow-y: auto; }

    .notif-item {
        padding: 11px 14px; border-bottom: 1px solid #F8FAFC; font-size: 12px; color: #334155;
        display: flex; gap: 8px; align-items: flex-start;
    }

    .notif-item .notif-dot {
        width: 7px; height: 7px; border-radius: 50%; background: #2563EB; margin-top: 5px; flex-shrink: 0;
    }

    .notif-item.lida .notif-dot { background: #E2E8F0; }
    .notif-item .notif-time { font-size: 10px; color: #94A3B8; margin-top: 3px; }
    .notif-empty { padding: 24px 14px; text-align: center; color: #94A3B8; font-size: 12px; }

    .topbar-user {
        display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 600;
        background: none; border: none; padding: 4px 6px; border-radius: 8px;
    }

    .topbar-user:hover { background: #F1F5F9; }

    /* ================= CONTEÚDO (única área com scroll) ================= */

    .content { flex: 1; overflow-y: auto; padding: 20px 24px; }

    .view-section { display: none; height: 100%; }
    .view-section.active { display: block; }

    .view-header {
        display: flex; align-items: flex-end; justify-content: space-between;
        margin-bottom: 16px; gap: 14px; flex-wrap: wrap;
    }

    .view-header h1 { font-size: 19px; }
    .view-header p { color: #64748B; font-size: 12px; margin-top: 3px; }
    .header-actions { display: flex; gap: 8px; }

    .btn-outline {
        display: inline-flex; align-items: center; gap: 6px; height: 34px; padding: 0 14px;
        border-radius: 8px; border: 1px solid #E2E8F0; background: #FFFFFF;
        font-size: 12px; font-weight: 600; color: #334155;
    }
    .btn-outline:hover { background: #F8FAFC; }

    .btn-solid {
        display: inline-flex; align-items: center; gap: 6px; height: 34px; padding: 0 14px;
        border-radius: 8px; border: none; background: #2563EB; color: #FFFFFF;
        font-size: 12px; font-weight: 600;
    }
    .btn-solid:hover { background: #1D4ED8; }

    .btn-ghost {
        border: none; background: none; color: #64748B; font-size: 13px; padding: 6px;
    }

    .icon-btn {
        width: 30px; height: 30px; border-radius: 7px; border: 1px solid #E2E8F0;
        background: #FFFFFF; display: flex; align-items: center; justify-content: center;
        font-size: 12px; color: #64748B;
    }
    .icon-btn:hover { background: #FEF2F2; color: #DC2626; border-color: #FECACA; }

    /* ================= DASHBOARD ================= */

    .dash-grid {
        display: grid;
        grid-template-rows: auto 1fr auto;
        gap: 14px;
        height: calc(100% - 6px);
    }

    .stats-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 12px;
    }

    .stat-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px;
        padding: 13px 14px; cursor: pointer; transition: 0.15s;
    }
    .stat-card:hover { border-color: #C4B5FD; box-shadow: 0 6px 16px rgba(124,58,237,0.10); transform: translateY(-1px); }

    .stat-card .row-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px; }
    .stat-card .row-top span.label { font-size: 12px; color: #64748B; }

    .stat-icon {
        width: 28px; height: 28px; border-radius: 8px; background: #F5F3FF; color: #7C3AED;
        display: flex; align-items: center; justify-content: center; font-size: 13px;
    }

    .stat-card strong { font-size: 21px; display: block; }
    .stat-card .delta { font-size: 10px; color: #94A3B8; }

    .dash-cols { display: grid; grid-template-columns: 1.5fr 1fr; gap: 14px; min-height: 0; }

    .panel-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px;
        padding: 14px 16px; display: flex; flex-direction: column; min-height: 0;
    }

    .panel-card h3 { font-size: 13px; margin-bottom: 10px; flex-shrink: 0; }

    .chart-wrap { position: relative; flex: 1; min-height: 0; }

    #chartTooltip {
        position: absolute; background: #0F172A; color: #FFFFFF; font-size: 11px;
        padding: 5px 9px; border-radius: 6px; pointer-events: none; display: none;
        transform: translate(-50%, -120%); white-space: nowrap; z-index: 5;
    }

    .upcoming-item { display: flex; align-items: center; gap: 10px; padding: 8px 0; border-bottom: 1px solid #F1F5F9; cursor: pointer; border-radius: 8px; }
    .upcoming-item:hover { background: #F8FAFC; }
    .upcoming-item:last-child { border-bottom: none; }

    .upcoming-item .date-box {
        width: 34px; height: 34px; border-radius: 8px; background: #F5F3FF; color: #7C3AED;
        display: flex; flex-direction: column; align-items: center; justify-content: center;
        font-size: 9px; font-weight: 700; flex-shrink: 0; line-height: 1.1;
    }

    .upcoming-item .info { flex: 1; min-width: 0; }
    .upcoming-item .info strong { display: block; font-size: 12px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

    .mini-bar { height: 5px; border-radius: 3px; background: #E2E8F0; margin-top: 5px; overflow: hidden; }
    .mini-bar span { display: block; height: 100%; }

    .upcoming-item .pct { font-size: 11px; font-weight: 700; color: #64748B; flex-shrink: 0; }

    .bar-green { background: #22C55E; }
    .bar-yellow { background: #F59E0B; }
    .bar-red { background: #EF4444; }

    table.data-table { width: 100%; border-collapse: collapse; font-size: 12px; }
    table.data-table th {
        text-align: left; font-size: 10px; text-transform: uppercase; letter-spacing: 0.03em;
        color: #94A3B8; padding: 8px 6px; border-bottom: 1px solid #E2E8F0; white-space: nowrap;
    }
    table.data-table td { padding: 9px 6px; border-bottom: 1px solid #F1F5F9; white-space: nowrap; }
    table.data-table tbody tr { cursor: pointer; }
    table.data-table tbody tr:hover { background: #F8FAFC; }

    .status-pill { font-size: 10px; font-weight: 600; padding: 3px 8px; border-radius: 6px; background: #DCFCE7; color: #166534; }
    .status-pill.rascunho { background: #F1F5F9; color: #64748B; }
    .status-pill.cancelado { background: #FEE2E2; color: #B91C1C; }
    .status-pill.finalizado { background: #DBEAFE; color: #1D4ED8; }
    .status-pill.pendente { background: #FEF3C7; color: #92400E; }

    .table-wrap { flex: 1; overflow-y: auto; min-height: 0; }

    /* ================= TABS ================= */

    .tabs { display: flex; gap: 6px; margin-bottom: 14px; flex-wrap: wrap; flex-shrink: 0; }
    .tab-btn {
        height: 32px; padding: 0 14px; border-radius: 8px; border: 1px solid #E2E8F0;
        background: #FFFFFF; font-size: 12px; font-weight: 600; color: #475569;
    }
    .tab-btn.active { background: #7C3AED; border-color: #7C3AED; color: #FFFFFF; }

    /* ================= CARDS DE LISTA (evento / fornecedor) ================= */

    .list-scroll { height: calc(100% - 46px); overflow-y: auto; }

    .org-event-card, .fornecedor-card {
        background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px;
        padding: 14px 16px; display: flex; align-items: center; gap: 12px;
        margin-bottom: 10px; cursor: pointer; transition: 0.12s;
    }
    .org-event-card:hover, .fornecedor-card:hover { border-color: #C4B5FD; box-shadow: 0 4px 12px rgba(124,58,237,0.08); }

    .org-event-card .icon-box, .fornecedor-card .icon-box {
        width: 38px; height: 38px; border-radius: 9px; background: #F5F3FF; color: #7C3AED;
        display: flex; align-items: center; justify-content: center; font-size: 15px; flex-shrink: 0;
    }

    .org-event-card .info, .fornecedor-card .info { flex: 1; min-width: 0; }
    .org-event-card .info strong, .fornecedor-card .info strong { font-size: 13px; margin-right: 6px; }
    .org-event-card .info .meta, .fornecedor-card .info .meta { font-size: 11px; color: #94A3B8; margin-top: 2px; }

    .org-event-card .capacity { width: 130px; text-align: right; flex-shrink: 0; }
    .org-event-card .capacity strong { display: block; font-size: 12px; margin-bottom: 3px; }

    .org-event-card .actions, .fornecedor-card .actions { display: flex; gap: 5px; flex-shrink: 0; }

    .cat-tag { font-size: 10px; font-weight: 600; color: #7C3AED; background: #F5F3FF; padding: 3px 9px; border-radius: 6px; flex-shrink: 0; }

    .search-row { display: flex; gap: 8px; margin-bottom: 14px; flex-wrap: wrap; align-items: center; flex-shrink: 0; }
    .search-input {
        flex: 1; min-width: 200px; height: 34px; padding: 0 12px; border-radius: 8px;
        border: 1px solid #E2E8F0; font-size: 12px;
    }
    select.filter-select {
        height: 34px; padding: 0 8px; border-radius: 8px; border: 1px solid #E2E8F0;
        font-size: 12px; background: #FFFFFF; color: #334155;
    }

    /* ================= FORM (Criar Evento / campos padrão) ================= */

    .form-card { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; padding: 22px; max-width: 760px; }
    .back-link { display: flex; align-items: center; gap: 8px; font-size: 12px; color: #64748B; margin-bottom: 4px; cursor: pointer; }

    .field { margin-bottom: 15px; }
    .field label { display: block; font-size: 12px; font-weight: 600; color: #334155; margin-bottom: 5px; }
    .field .req { color: #DC2626; }
    .field input, .field select, .field textarea {
        width: 100%; padding: 9px 11px; border: 1px solid #E2E8F0; border-radius: 8px;
        font-size: 13px; font-family: inherit; background: #F8FAFC;
    }
    .field input:focus, .field select:focus, .field textarea:focus { outline: none; border-color: #7C3AED; background: #FFFFFF; }
    .field .hint { font-size: 10px; color: #94A3B8; margin-left: 6px; font-weight: 500; }

    .fields-row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }

    .toggle-group { display: flex; gap: 8px; }
    .toggle-btn {
        flex: 1; padding: 9px; border-radius: 8px; border: 1.5px solid #E2E8F0; background: #FFFFFF;
        font-size: 12px; font-weight: 600; color: #64748B; text-align: center;
    }
    .toggle-btn.active { border-color: #7C3AED; color: #7C3AED; background: #F5F3FF; }

    .inline-fornecedor-box {
        margin-top: 12px; padding: 14px; border-radius: 10px; background: #FAF5FF;
        border: 1px dashed #C4B5FD; display: none;
    }
    .inline-fornecedor-box.open { display: block; }
    .inline-fornecedor-box h4 { font-size: 12px; color: #7C3AED; margin-bottom: 10px; }

    .form-footer { display: flex; align-items: center; justify-content: flex-end; gap: 10px; margin-bottom: 18px; }

    /* ================= DETALHE EVENTO / FORNECEDOR ================= */

    .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 16px; }
    .detail-box { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 10px; padding: 12px 14px; }
    .detail-box label { display: block; font-size: 10px; color: #94A3B8; text-transform: uppercase; margin-bottom: 4px; }
    .detail-box .val { font-size: 13px; font-weight: 600; }

    .vinculado-card {
        display: flex; align-items: center; gap: 12px; padding: 12px 14px; border: 1px solid #E2E8F0;
        border-radius: 10px; margin-bottom: 8px; background: #FFFFFF;
    }
    .vinculado-card .info { flex: 1; }
    .vinculado-card .info strong { font-size: 13px; display: block; }
    .vinculado-card .info span { font-size: 11px; color: #94A3B8; }

    .chip { font-size: 11px; font-weight: 600; padding: 4px 11px; border-radius: 20px; background: #ECFDF5; color: #059669; }

    /* ================= MODAL ================= */

    .modal-overlay {
        display: none; position: fixed; inset: 0; background: rgba(2,6,23,0.55);
        align-items: center; justify-content: center; z-index: 100; padding: 20px;
    }
    .modal-overlay.open { display: flex; }

    .modal-box {
        background: #FFFFFF; border-radius: 14px; width: 100%; max-width: 480px;
        max-height: 90vh; overflow-y: auto; padding: 22px;
    }
    .modal-box.wide { max-width: 620px; }

    .modal-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 16px; }
    .modal-header h3 { font-size: 15px; }
    .modal-header span { font-size: 11px; color: #94A3B8; }
    .modal-close { border: none; background: none; font-size: 18px; color: #94A3B8; cursor: pointer; }

    .modal-footer { display: flex; align-items: center; justify-content: space-between; margin-top: 16px; }

    .upload-box {
        border: 1.5px dashed #E2E8F0; border-radius: 10px; padding: 20px; text-align: center;
        color: #94A3B8; font-size: 11px;
    }
    .upload-box a { color: #7C3AED; font-weight: 600; cursor: pointer; }

    .empty-state { text-align: center; padding: 40px 20px; color: #94A3B8; font-size: 12px; }
    .menu-toggle-btn {
        display: none;
        width: 34px; height: 34px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        font-size: 16px;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        flex-shrink: 0;
    }

    .sidebar-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(2,6,23,0.5);
        z-index: 40;
    }

    .sidebar-overlay.open { display: block; }

    @media (max-width: 900px) {
        .app { grid-template-columns: 1fr; }

        .sidebar {
            position: fixed;
            top: 0; left: 0;
            height: 100vh;
            width: 226px;
            z-index: 50;
            transform: translateX(-100%);
            transition: transform 0.25s ease;
            box-shadow: 0 0 30px rgba(2,6,23,0.25);
        }

        .sidebar.open { transform: translateX(0); }

        .menu-toggle-btn { display: flex; }

        .dash-cols { grid-template-columns: 1fr; }
        .stats-grid { grid-template-columns: repeat(2, 1fr); }
        .fields-row-2 { grid-template-columns: 1fr; }
        .detail-grid { grid-template-columns: 1fr; }
        .content { padding: 14px; }
    }

    @media (max-width: 480px) {
        .stats-grid { grid-template-columns: 1fr; }
    }

</style>
</head>
<body>

<div class="app">

    <!-- ================= SIDEBAR ================= -->
    <aside class="sidebar" id="sidebarEl">

        <div class="sidebar-logo">
            <div class="sidebar-logo-icon">📊</div>
            <span>Organizador</span>
        </div>

        <button class="nav-item active" data-view="dashboard" onclick="mudarView('dashboard', this)">
            <span class="nav-icon">▦</span>
            <span class="nav-label">Dashboard</span>
        </button>

        <button class="nav-item" data-view="eventos" onclick="mudarView('eventos', this)">
            <span class="nav-icon">📅</span>
            <span class="nav-label">Eventos</span>
        </button>

        <button class="nav-item" data-view="fornecedores" onclick="mudarView('fornecedores', this)">
            <span class="nav-icon">🚚</span>
            <span class="nav-label">Fornecedores</span>
        </button>

        <button class="nav-item" data-view="espera" onclick="mudarView('espera', this)">
            <span class="nav-icon">👥</span>
            <span class="nav-label">Lista de Espera</span>
            <% if (totalNaEsperaSoma > 0) { %>
            <span class="nav-badge"><%= totalNaEsperaSoma %></span>
            <% } %>
        </button>

        <button class="nav-item" data-view="perfil" onclick="mudarView('perfil', this)">
            <span class="nav-icon">👤</span>
            <span class="nav-label">Meu Perfil</span>
        </button>

        <div class="sidebar-footer">
            <div class="avatar"><%= iniciais %></div>
            <div>
                <strong><%= nomeUsuario %></strong>
                <small>Organizador</small>
            </div>
            <a class="logout-btn" title="Sair"
               href="${pageContext.request.contextPath}/usuarioController?action=logout">↪</a>
        </div>

    </aside>

    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

    <!-- ================= COLUNA PRINCIPAL ================= -->
    <div class="main-col">

        <header class="topbar">
            <button class="menu-toggle-btn" onclick="toggleSidebar()">☰</button>
            <div class="topbar-title">
                <strong>GerenCIA</strong>
                <span>Painel do Organizador</span>
            </div>

            <div class="topbar-actions">

                <div class="bell-wrap">
                    <button class="bell-btn <%= notifNaoLidas > 0 ? "unread" : "" %>" id="bellBtn" onclick="toggleNotificacoes(event)">
                        🔔<span class="dot"></span>
                    </button>

                    <div class="notif-dropdown" id="notifDropdown">
                        <div class="notif-dropdown-header">
                            Notificações
                            <a href="${pageContext.request.contextPath}/notificacaoController?action=marcarLidas&voltarPara=/pages/homeOrganizador.jsp">Marcar todas como lidas</a>
                        </div>
                        <div class="notif-list">
                            <%
                                if (minhasNotificacoes.isEmpty()) {
                            %>
                            <div class="notif-empty">Nenhuma notificação por enquanto.</div>
                            <%
                                } else {
                                    for (notificacaoModel n : minhasNotificacoes) {
                                        boolean lida = "lida".equals(n.getStatus_notificacao());
                            %>
                            <div class="notif-item <%= lida ? "lida" : "" %>">
                                <span class="notif-dot"></span>
                                <div>
                                    <div><%= n.getMensagem() %></div>
                                    <div class="notif-time"><%= n.getData_envio().format(fmtDataHora) %></div>
                                </div>
                            </div>
                            <%
                                    }
                                }
                            %>
                        </div>
                    </div>
                </div>

                <button class="topbar-user" onclick="mudarView('perfil', document.querySelector('[data-view=perfil]'))">
                    <div class="avatar" style="width:28px;height:28px;font-size:10px;"><%= iniciais %></div>
                    <%= nomeUsuario %> ⌄
                </button>

            </div>
        </header>

        <div class="content">

            <% if (flashMsgOrg != null) { %>
            <div style="background:#FEF2F2; border:1px solid #FECACA; color:#B91C1C; border-radius:10px; padding:12px 16px; font-size:13px; margin-bottom:16px;">
                ⚠️ <%= flashMsgOrg %>
            </div>
            <% } %>
            <!-- ============================================================
                 VIEW: DASHBOARD
            ============================================================ -->
            <section class="view-section active" id="view-dashboard">

                <div class="dash-grid">

                    <div class="stats-grid">

                        <div class="stat-card" onclick="mudarViewById('eventos')">
                            <div class="row-top">
                                <span class="label">Eventos ativos</span>
                                <div class="stat-icon">📅</div>
                            </div>
                            <strong><%= totalEventosAtivos %></strong>
                            <span class="delta"><%= meusEventos.size() %> no total</span>
                        </div>

                        <div class="stat-card" onclick="mudarViewById('eventos')">
                            <div class="row-top">
                                <span class="label">Total de inscritos</span>
                                <div class="stat-icon">👥</div>
                            </div>
                            <strong><%= totalInscritosSoma %></strong>
                            <span class="delta">confirmados em todos os eventos</span>
                        </div>

                        <div class="stat-card" onclick="mudarViewById('espera')">
                            <div class="row-top">
                                <span class="label">Na lista de espera</span>
                                <div class="stat-icon">⏳</div>
                            </div>
                            <strong><%= totalNaEsperaSoma %></strong>
                            <span class="delta">clique para ver a fila</span>
                        </div>

                        <div class="stat-card" onclick="mudarViewById('eventos')">
                            <div class="row-top">
                                <span class="label">Ocupação média</span>
                                <div class="stat-icon">📈</div>
                            </div>
                            <strong><%= ocupacaoMedia %>%</strong>
                            <span class="delta">&nbsp;</span>
                        </div>

                    </div>

                    <div class="dash-cols">

                        <div class="panel-card">
                            <h3>Inscrições ao longo do tempo <span style="font-weight:400;color:#94A3B8;">(clique para ver Eventos)</span></h3>
                            <div class="chart-wrap" onclick="mudarViewById('eventos')" style="cursor:pointer;">
                                <svg id="lineChart" viewBox="0 0 580 190" style="width:100%; height:100%;" preserveAspectRatio="none">
                                    <!-- eixo Y e linha desenhados via JS (renderLineChart) -->
                                </svg>
                                <div id="chartTooltip"></div>
                            </div>
                        </div>

                        <div class="panel-card">
                            <h3>Próximos eventos</h3>
                            <div style="overflow-y:auto; flex:1;">
                            <%
                                int mostrados = 0;
                                for (eventoModel ev : eventosOrdenados) {
                                    if (mostrados >= 5) break;
                                    mostrados++;
                                    int pct = percentualPorEvento.get(ev.getId_evento());
                                    String corClasse = pct <= 60 ? "bar-green" : (pct <= 75 ? "bar-yellow" : "bar-red");
                            %>
                                <div class="upcoming-item" onclick="abrirDetalheEvento(<%= ev.getId_evento() %>)">
                                    <div class="date-box">
                                        <span><%= ev.getInicio_evento().format(DateTimeFormatter.ofPattern("dd")) %></span>
                                        <span><%= ev.getInicio_evento().format(DateTimeFormatter.ofPattern("MMM")) %></span>
                                    </div>
                                    <div class="info">
                                        <strong><%= ev.getNome_evento() %></strong>
                                        <div class="mini-bar"><span class="<%= corClasse %>" style="width:<%= pct %>%"></span></div>
                                    </div>
                                    <span class="pct"><%= pct %>%</span>
                                </div>
                            <%
                                }
                                if (mostrados == 0) {
                            %>
                                <div class="empty-state">Nenhum evento cadastrado ainda.</div>
                            <%
                                }
                            %>
                            </div>
                        </div>

                    </div>

                    <div class="panel-card">
                        <div class="view-header" style="margin-bottom:10px;">
                            <h3 style="font-size:13px;">Últimos Eventos</h3>
                            <button class="btn-outline" onclick="exportarPDF('dashboard')">⬇ Exportar</button>
                        </div>

                        <div class="table-wrap">
                            <table class="data-table">
                                <thead>
                                    <tr><th>Evento</th><th>Data</th><th>Inscritos / Capacidade</th><th>Ocupação</th><th>Status</th></tr>
                                </thead>
                                <tbody>
                                <%
                                    for (eventoModel ev : meusEventos) {
                                        int inscritos = inscritosPorEvento.get(ev.getId_evento());
                                        int pct = percentualPorEvento.get(ev.getId_evento());
                                        String statusClasse = "ativo".equals(ev.getStatus_evento()) ? "" : ev.getStatus_evento();
                                %>
                                    <tr onclick="abrirDetalheEvento(<%= ev.getId_evento() %>)">
                                        <td><strong><%= ev.getNome_evento() %></strong><br><span style="color:#94A3B8;font-size:10px;"><%= ev.getLocal_evento() %></span></td>
                                        <td><%= ev.getInicio_evento().format(fmtData) %></td>
                                        <td><%= inscritos %> / <%= ev.getCapacidade_evento() %></td>
                                        <td><%= pct %>%</td>
                                        <td><span class="status-pill <%= statusClasse %>"><%= rotuloStatusEvento(ev.getStatus_evento()) %></span></td>
                                    </tr>
                                <%
                                    }
                                    if (meusEventos.isEmpty()) {
                                %>
                                    <tr><td colspan="5" style="text-align:center; color:#94A3B8;">Nenhum evento cadastrado ainda.</td></tr>
                                <%
                                    }
                                %>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </div>

            </section>
            <!-- ============================================================
                 VIEW: EVENTOS
            ============================================================ -->
            <section class="view-section" id="view-eventos">

                <div class="view-header">
                    <div>
                        <h1>Meus Eventos</h1>
                        <p><%= meusEventos.size() %> evento(s)</p>
                    </div>
                    <div class="header-actions">
                        <button class="btn-outline" onclick="exportarPDF('eventos')">⬇ Exportar</button>
                        <button class="btn-solid" onclick="mudarViewById('criarEvento')">+ Criar evento</button>
                    </div>
                </div>

                <div class="tabs" id="tabs-eventos">
                    <button class="tab-btn active" data-status="todos">Todos</button>
                    <button class="tab-btn" data-status="rascunho">Rascunho</button>
                    <button class="tab-btn" data-status="ativo">Ativo</button>
                    <button class="tab-btn" data-status="cancelado">Cancelado</button>
                    <button class="tab-btn" data-status="finalizado">Finalizado</button>
                </div>

                <div class="list-scroll" id="lista-eventos-organizador"></div>

            </section>

            <!-- ============================================================
                 VIEW: CRIAR EVENTO
            ============================================================ -->
            <section class="view-section" id="view-criarEvento">

                <div class="back-link" onclick="mudarViewById('eventos')">← Voltar</div>

                <div class="view-header">
                    <div><h1>Criar evento</h1></div>
                </div>

                <div class="form-card">

                    <div class="form-footer" style="margin-bottom:18px;">
                        <div style="font-weight:700; font-size:14px;">Criar novo evento</div>
                        <div style="display:flex; gap:8px;">
                            <button type="button" class="btn-outline" onclick="mudarViewById('eventos')">Cancelar</button>
                            <button type="submit" form="formCriarEvento" class="btn-solid">💾 Salvar como rascunho</button>
                        </div>
                    </div>

                    <form id="formCriarEvento" action="${pageContext.request.contextPath}/eventoController" method="post" onsubmit="return prepararSubmitEvento();">

                        <input type="hidden" name="action" value="novo">
                        <input type="hidden" name="id_organizador" value="<%= usuarioLogado.getId_usuario() %>">
                        <input type="hidden" name="status_evento" value="rascunho">
                        <input type="hidden" name="inicio_evento" id="inicio_evento_hidden">
                        <input type="hidden" name="fim_evento" id="fim_evento_hidden">

                        <div class="field">
                            <label>Nome do evento <span class="req">*</span></label>
                            <input type="text" name="nome_evento" placeholder="Ex: Summit de Tecnologia 2025" required>
                        </div>

                        <div class="fields-row-2">
                            <div class="field">
                                <label>Tipo de evento</label>
                                <div class="toggle-group">
                                    <label class="toggle-btn active" id="lbl_tipo_publico">
                                        <input type="radio" name="tipo_evento" value="publico" checked style="display:none" onclick="selecionarToggle('lbl_tipo_publico','lbl_tipo_privado')"> 🌐 Público
                                    </label>
                                    <label class="toggle-btn" id="lbl_tipo_privado">
                                        <input type="radio" name="tipo_evento" value="privado" style="display:none" onclick="selecionarToggle('lbl_tipo_privado','lbl_tipo_publico')"> 🔒 Privado
                                    </label>
                                </div>
                            </div>
                            <div class="field">
                                <label>Categoria</label>
                                <select name="categoria_evento">
                                    <option value="tecCientifico">TecCientifico</option>
                                    <option value="corporativos">Corporativos</option>
                                    <option value="sociais">Sociais</option>
                                </select>
                            </div>
                        </div>

                        <div class="fields-row-2">
                            <div class="field">
                                <label>Data de início <span class="req">*</span></label>
                                <input type="date" id="data_inicio_input" required>
                            </div>
                            <div class="field">
                                <label>Data de término</label>
                                <input type="date" id="data_fim_input">
                            </div>
                        </div>

                        <div class="fields-row-2">
                            <div class="field">
                                <label>Horário de início</label>
                                <input type="time" id="hora_inicio_input" value="09:00">
                            </div>
                            <div class="field">
                                <label>Horário de término</label>
                                <input type="time" id="hora_fim_input" value="18:00">
                            </div>
                        </div>

                        <div class="field">
                            <label>Local <span class="req">*</span></label>
                            <input type="text" name="local_evento" placeholder="Ex: Expo Center Norte, São Paulo" required>
                        </div>

                        <div class="fields-row-2">
                            <div class="field">
                                <label>Capacidade máxima <span class="req">*</span></label>
                                <input type="number" name="capacidade_evento" min="1" placeholder="200" required>
                            </div>
                            <div class="field">
                                <label>Código do evento</label>
                                <div style="display:flex; gap:8px;">
                                    <input type="text" name="codigo_evento" id="codigo_evento_input" readonly>
                                    <button type="button" class="icon-btn" onclick="gerarCodigoEvento()" style="width:38px;height:38px;">🔄</button>
                                </div>
                            </div>
                        </div>

                        <div class="field">
                            <label>Descrição</label>
                            <textarea name="descricao_evento" rows="3" placeholder="Descreva o evento..."></textarea>
                        </div>

                    </form>

                    <div style="background:#EFF6FF; border:1px solid #BFDBFE; border-radius:10px; padding:12px 14px; font-size:12px; color:#1D4ED8;">
                        ℹ️ Depois de salvar, você será levado direto pros detalhes do evento — é lá que você vincula fornecedores
                        (com contrato e anexo de documento) e publica o evento.
                    </div>

                </div>

            </section>

            <!-- ============================================================
                 VIEW: DETALHES DO EVENTO
            ============================================================ -->
            <section class="view-section" id="view-detalheEvento">

                <div class="back-link" onclick="mudarViewById('eventos')">← Voltar</div>

                <div class="view-header">
                    <div><h1 id="det_ev_nome">—</h1></div>
                    <div class="header-actions">
                        <span class="status-pill" id="det_ev_status">Ativo</span>
                        <a class="btn-solid" id="det_ev_publicar_btn" style="display:none;" href="#"
                           onclick="return confirm('Publicar este evento? Ele ficará visível/ativo pros participantes.');">🚀 Publicar evento</a>
                        <button class="btn-outline" onclick="exportarPDF('detalheEvento')">⬇ Exportar</button>
                    </div>
                </div>

                <div class="detail-grid">
                    <div class="detail-box"><label>Tipo</label><div class="val" id="det_ev_tipo">—</div></div>
                    <div class="detail-box"><label>Categoria</label><div class="val" id="det_ev_categoria">—</div></div>
                    <div class="detail-box"><label>Data de início</label><div class="val" id="det_ev_inicio">—</div></div>
                    <div class="detail-box"><label>Data de término</label><div class="val" id="det_ev_fim">—</div></div>
                    <div class="detail-box"><label>Local</label><div class="val" id="det_ev_local">—</div></div>
                    <div class="detail-box"><label>Capacidade</label><div class="val" id="det_ev_capacidade">—</div></div>
                    <div class="detail-box"><label>Inscritos</label><div class="val" id="det_ev_inscritos">—</div></div>
                    <div class="detail-box"><label>Código</label><div class="val" id="det_ev_codigo">—</div></div>
                </div>

                <div class="panel-card" style="margin-bottom:14px;">
                    <label style="font-size:10px; color:#94A3B8; text-transform:uppercase; margin-bottom:6px; display:block;">Descrição</label>
                    <div id="det_ev_descricao" style="font-size:13px;">—</div>
                </div>

                <div class="view-header" style="margin-bottom:10px;">
                    <h3 style="font-size:13px;">🚚 Fornecedores Vinculados</h3>
                    <button class="btn-outline" onclick="abrirModalContrato(null, currentEventoId)">+ Vincular fornecedor</button>
                </div>

                <div id="det_ev_fornecedores"></div>

            </section>
            <!-- ============================================================
                 VIEW: FORNECEDORES
            ============================================================ -->
            <section class="view-section" id="view-fornecedores">

                <div class="view-header">
                    <div>
                        <h1>Fornecedores</h1>
                        <p><%= todosFornecedores.size() %> cadastrado(s)</p>
                    </div>
                    <div class="header-actions">
                        <button class="btn-outline" onclick="exportarPDF('fornecedores')">⬇ Exportar</button>
                        <button class="btn-solid" onclick="abrirModalFornecedor()">+ Cadastrar fornecedor</button>
                    </div>
                </div>

                <div class="search-row">
                    <input class="search-input" type="text" id="busca-fornecedor" placeholder="Buscar fornecedor...">
                </div>

                <div class="tabs" id="tabs-fornecedores">
                    <button class="tab-btn active" data-cat="Todos">Todos</button>
                    <button class="tab-btn" data-cat="Audiovisual">Audiovisual</button>
                    <button class="tab-btn" data-cat="Buffet">Buffet</button>
                    <button class="tab-btn" data-cat="Decoração">Decoração</button>
                    <button class="tab-btn" data-cat="Fotografia">Fotografia</button>
                    <button class="tab-btn" data-cat="Segurança">Segurança</button>
                    <button class="tab-btn" data-cat="Limpeza">Limpeza</button>
                    <button class="tab-btn" data-cat="Locação de Espaço">Locação</button>
                </div>

                <div class="list-scroll" id="lista-fornecedores"></div>

            </section>

            <!-- ============================================================
                 VIEW: DETALHES DO FORNECEDOR
            ============================================================ -->
            <section class="view-section" id="view-detalheFornecedor">

                <div class="back-link" onclick="mudarViewById('fornecedores')">← Voltar</div>

                <div class="view-header">
                    <div><h1 id="det_for_nome">—</h1></div>
                    <button class="btn-outline" onclick="exportarPDF('detalheFornecedor')">⬇ Exportar Dados</button>
                </div>

                <div class="panel-card" style="margin-bottom:14px;">
                    <div style="display:flex; align-items:center; gap:14px;">
                        <div class="icon-box" style="width:44px;height:44px;border-radius:10px;background:#F5F3FF;color:#7C3AED;display:flex;align-items:center;justify-content:center;font-size:18px;">🚚</div>
                        <div style="flex:1;">
                            <div style="font-weight:700; font-size:14px;" id="det_for_nome2">—</div>
                            <div style="font-size:11px; color:#94A3B8;" id="det_for_contato">—</div>
                        </div>
                        <span class="cat-tag" id="det_for_categoria">—</span>
                    </div>
                    <div style="margin-top:14px;">
                        <label style="font-size:10px; color:#94A3B8; text-transform:uppercase; display:block; margin-bottom:8px;">Eventos vinculados</label>
                        <div id="det_for_eventos" style="display:flex; gap:8px; flex-wrap:wrap;"></div>
                    </div>
                </div>

                <div class="view-header" style="margin-bottom:10px;">
                    <h3 style="font-size:13px;">Histórico de Contratos</h3>
                    <button class="btn-outline" onclick="abrirModalContrato(null, null, currentFornecedorId)">+ Novo contrato</button>
                </div>

                <div class="table-wrap">
                    <table class="data-table">
                        <thead>
                            <tr><th>ID Contrato</th><th>Evento</th><th>Data</th><th>Valor Total</th><th>Adiantamento</th><th>Responsável</th><th>Situação</th><th></th></tr>
                        </thead>
                        <tbody id="det_for_contratos"></tbody>
                    </table>
                </div>

            </section>
            <!-- ============================================================
                 VIEW: LISTA DE ESPERA
            ============================================================ -->
            <section class="view-section" id="view-espera">

                <div class="view-header">
                    <div>
                        <h1>Lista de Espera</h1>
                        <p><%= totalNaEsperaSoma %> pessoa(s) aguardando</p>
                    </div>
                    <button class="btn-outline" onclick="exportarPDF('espera')">⬇ Exportar</button>
                </div>

                <div id="espera-container">
                <%
                    boolean temFila = false;

                    for (eventoModel ev : meusEventos) {

                        List<inscricaoModel> fila =
                            inscricaoDAOJsp.listarPorEventoEStatus(ev.getId_evento(), "Espera");

                        if (fila.isEmpty()) continue;

                        temFila = true;
                %>
                    <div class="panel-card" style="margin-bottom:12px;">
                        <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:10px;">
                            <div>
                                <strong style="font-size:13px;">📅 <%= ev.getNome_evento() %></strong>
                                <div style="font-size:11px; color:#94A3B8;"><%= ev.getInicio_evento().format(fmtData) %> · <%= fila.size() %> na fila</div>
                            </div>
                            <span class="status-pill pendente"><%= fila.size() %></span>
                        </div>

                        <table class="data-table">
                            <thead>
                                <tr><th>#</th><th>Nome</th><th>CPF</th><th>E-mail</th><th>Entrou em</th><th>Status</th></tr>
                            </thead>
                            <tbody>
                            <%
                                int pos = 1;
                                for (inscricaoModel insc : fila) {
                                    usuarioModel u = usuarioDAOJsp.buscarPorId(insc.getId_usuario());
                                    String nomeU = u != null ? u.getNome_usuario() : "(usuário removido)";
                                    String cpfU = u != null ? u.getCPF_usuario() : "—";
                                    String emailU = u != null ? u.getEmail_usuario() : "—";
                            %>
                                <tr>
                                    <td><%= pos %>ª</td>
                                    <td><%= nomeU %></td>
                                    <td><%= cpfU %></td>
                                    <td><%= emailU %></td>
                                    <td><%= insc.getData_inscricao().format(fmtDataHora) %></td>
                                    <td><span class="status-pill pendente">Aguardando</span></td>
                                </tr>
                            <%
                                    pos++;
                                }
                            %>
                            </tbody>
                        </table>
                    </div>
                <%
                    }

                    if (!temFila) {
                %>
                    <div class="empty-state">Nenhum evento com lista de espera no momento.</div>
                <%
                    }
                %>
                </div>

            </section>

            <!-- ============================================================
                 VIEW: MEU PERFIL
            ============================================================ -->
            <section class="view-section" id="view-perfil">

                <div class="view-header">
                    <div>
                        <h1>Meu Perfil</h1>
                        <p>Gerencie suas informações pessoais</p>
                    </div>
                </div>

                <div class="panel-card" style="max-width:640px; margin-bottom:16px; flex-direction:row; align-items:center; gap:16px;">
                    <div class="avatar" style="width:56px;height:56px;font-size:17px;"><%= iniciais %></div>
                    <div>
                        <div style="font-weight:700; font-size:15px;"><%= nomeUsuario %></div>
                        <div style="font-size:11px; color:#94A3B8;">CPF: <%= usuarioLogado.getCPF_usuario() %> · <%= rotuloTipoConta(usuarioLogado.getTipo_usuario()) %></div>
                    </div>
                </div>

                <form class="form-card" style="max-width:640px;"
                      action="${pageContext.request.contextPath}/usuarioController" method="post">

                    <input type="hidden" name="action" value="atualizar">
                    <input type="hidden" name="id_usuario" value="<%= usuarioLogado.getId_usuario() %>">

                    <div class="fields-row-2">
                        <div class="field">
                            <label>Nome completo</label>
                            <input type="text" name="nome_usuario" value="<%= nomeUsuario %>">
                        </div>
                        <div class="field">
                            <label>E-mail</label>
                            <input type="email" name="email_usuario" value="<%= usuarioLogado.getEmail_usuario() %>">
                        </div>
                    </div>

                    <div class="fields-row-2">
                        <div class="field">
                            <label>CPF</label>
                            <input type="text" value="<%= usuarioLogado.getCPF_usuario() %>" disabled>
                        </div>
                        <div class="field">
                            <label>Telefone</label>
                            <input type="tel" name="telefone" value="<%= usuarioLogado.getTelefone() %>">
                        </div>
                    </div>

                    <div class="field">
                        <label>Tipo de conta</label>
                        <input type="text" value="<%= rotuloTipoConta(usuarioLogado.getTipo_usuario()) %>" disabled>
                    </div>

                    <button type="submit" class="btn-solid">Salvar alterações</button>

                </form>

            </section>

        </div>

    </div>

</div>

<!-- ================= MODAL: CONTRATO ================= -->
<!-- ================= MODAL: DETALHES DO CONTRATO (somente leitura) ================= -->
<div class="modal-overlay" id="modalDetalhesContrato">
    <div class="modal-box wide">
        <div class="modal-header">
            <div>
                <h3>Detalhes do Contrato</h3>
                <span id="dc_codigo">—</span>
            </div>
            <button class="modal-close" onclick="fecharModal('modalDetalhesContrato')">×</button>
        </div>

        <div class="detail-grid">
            <div class="detail-box"><label>Evento</label><div class="val" id="dc_evento">—</div></div>
            <div class="detail-box"><label>Fornecedor</label><div class="val" id="dc_fornecedor">—</div></div>
            <div class="detail-box"><label>Data do contrato</label><div class="val" id="dc_data">—</div></div>
            <div class="detail-box"><label>Responsável</label><div class="val" id="dc_responsavel">—</div></div>
            <div class="detail-box"><label>Contato</label><div class="val" id="dc_contato">—</div></div>
            <div class="detail-box"><label>Valor adiantamento</label><div class="val" id="dc_valorPago">—</div></div>
            <div class="detail-box"><label>Valor total</label><div class="val" id="dc_valorTotal">—</div></div>
            <div class="detail-box"><label>Status</label><div class="val" id="dc_situacao">—</div></div>
        </div>

        <div class="panel-card" style="margin-bottom:14px;">
            <label style="font-size:10px; color:#94A3B8; text-transform:uppercase; margin-bottom:6px; display:block;">Objetivo / Escopo</label>
            <div id="dc_objeto" style="font-size:13px;">—</div>
        </div>

        <div id="dc_anexo_wrap" style="margin-bottom:16px;"></div>

        <div class="modal-footer">
            <button type="button" class="btn-outline" onclick="editarContratoAPartirDeDetalhes()">✎ Editar contrato</button>
            <div style="display:flex; gap:8px;">
                <button type="button" class="btn-outline" onclick="exportarContratoDetalhesPDF()">⬇ Exportar contrato</button>
                <button type="button" class="btn-outline" onclick="fecharModal('modalDetalhesContrato')">Fechar</button>
            </div>
        </div>
    </div>
</div>

<div class="modal-overlay" id="modalContrato">
    <div class="modal-box wide">
        <div class="modal-header">
            <div>
                <h3>Contrato de Fornecedor</h3>
                <span id="contratoSubtitulo">—</span>
            </div>
            <button class="modal-close" onclick="fecharModal('modalContrato')">×</button>
        </div>

        <form id="formContrato" action="${pageContext.request.contextPath}/contratoController" method="post"
              enctype="multipart/form-data" onsubmit="return prepararSubmitContrato();">

            <input type="hidden" name="action" id="contratoAction" value="novo">
            <input type="hidden" name="id_contrato" id="contratoId">
            <input type="hidden" name="id_fornecedor" id="contratoIdFornecedor">
            <input type="hidden" name="id_evento" id="contratoIdEvento">
            <input type="hidden" name="data_contrato" id="contratoDataHidden">
            <input type="hidden" name="anexo_contrato_atual" id="contratoAnexoAtual" value="">

            <div class="fields-row-2">
                <div class="field">
                    <label>Fornecedor</label>
                    <select id="contratoFornecedorSelect" onchange="document.getElementById('contratoIdFornecedor').value=this.value;">
                        <option value="">Selecione...</option>
                        <%
                            for (fornecedorModel f : todosFornecedores) {
                        %>
                        <option value="<%= f.getId_fornecedor() %>"><%= f.getNome_fornecedor() %></option>
                        <%
                            }
                        %>
                    </select>
                </div>
                <div class="field">
                    <label>Evento</label>
                    <select id="contratoEventoSelect" onchange="document.getElementById('contratoIdEvento').value=this.value;">
                        <option value="">Selecione...</option>
                        <%
                            for (eventoModel ev : meusEventos) {
                        %>
                        <option value="<%= ev.getId_evento() %>"><%= ev.getNome_evento() %></option>
                        <%
                            }
                        %>
                    </select>
                </div>
            </div>

            <div class="field">
                <label>Data do contrato</label>
                <input type="date" id="contratoData" required>
            </div>

            <div class="fields-row-2">
                <div class="field">
                    <label>Valor adiantamento (R$)</label>
                    <input type="number" step="0.01" name="valor_pago" id="contratoValorPago" value="0">
                </div>
                <div class="field">
                    <label>Valor total (R$)</label>
                    <input type="number" step="0.01" name="valor_total" id="contratoValorTotal" value="0" required>
                </div>
            </div>

            <div class="fields-row-2">
                <div class="field">
                    <label>Nome do responsável</label>
                    <input type="text" name="responsavel_contrato" id="contratoResponsavel" required>
                </div>
                <div class="field">
                    <label>Contato do responsável</label>
                    <input type="text" name="contato_responsavel" id="contratoContato">
                </div>
            </div>

            <div class="field">
                <label>Objetivo / Escopo do serviço</label>
                <textarea name="objeto_contrato" id="contratoObjeto" rows="3" required></textarea>
            </div>

            <div class="field">
                <label>Documento do contrato</label>
                <div class="upload-box" style="text-align:left;">
                    <input type="file" name="arquivo_contrato" id="contratoArquivoInput" accept=".pdf,.doc,.docx" style="width:100%;">
                    <div id="contratoAnexoExistenteLabel" style="margin-top:8px; font-size:11px; color:#059669;"></div>
                    <div style="margin-top:6px; font-size:10px; color:#94A3B8;">PDF, DOC, DOCX — até 10MB</div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="submit" class="btn-solid">💾 Salvar contrato</button>
                <div style="display:flex; gap:8px;">
                    <button type="button" class="btn-outline" onclick="exportarContratoPDF()">⬇ Gerar relatório</button>
                    <button type="button" class="btn-outline" onclick="fecharModal('modalContrato')">Cancelar</button>
                </div>
            </div>

        </form>
    </div>
</div>

<!-- ================= MODAL: NOVO FORNECEDOR (standalone) ================= -->
<div class="modal-overlay" id="modalFornecedor">
    <div class="modal-box wide">
        <div class="modal-header">
            <h3>Cadastrar fornecedor</h3>
            <button class="modal-close" onclick="fecharModal('modalFornecedor')">×</button>
        </div>

        <form action="${pageContext.request.contextPath}/fornecedorController" method="post" enctype="multipart/form-data">
            <input type="hidden" name="action" value="novo">

            <div class="field">
                <label>Nome <span class="req">*</span></label>
                <input type="text" name="nome_fornecedor" required>
            </div>

            <div class="fields-row-2">
                <div class="field">
                    <label>CNPJ</label>
                    <input type="text" name="CNPJ_fornecedor" maxlength="14" placeholder="00000000000100">
                </div>
                <div class="field">
                    <label>Telefone</label>
                    <input type="text" name="telefone_fornecedor" maxlength="11" placeholder="11999999999">
                </div>
            </div>

            <div class="fields-row-2">
                <div class="field">
                    <label>Categoria</label>
                    <select name="categoria_fornecedor" id="fornecedorCategoriaSelect">
                        <option value="audioVisual">Audiovisual</option>
                        <option value="buffet">Buffet</option>
                        <option value="decoracao">Decoração</option>
                        <option value="fotografia">Fotografia</option>
                        <option value="seguranca">Segurança</option>
                        <option value="limpeza">Limpeza</option>
                        <option value="locaoEspaco">Locação de Espaço</option>
                    </select>
                </div>
                <div class="field">
                    <label>E-mail <span class="req">*</span></label>
                    <input type="email" name="email" required>
                </div>
            </div>

            <div class="field" style="border-top:1px solid #F1F5F9; padding-top:14px;">
                <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
                    <input type="checkbox" id="chkVincularContrato" onchange="document.getElementById('boxContratoFornecedor').style.display = this.checked ? 'block' : 'none';">
                    Já vincular um contrato a um evento existente
                </label>
            </div>

            <div id="boxContratoFornecedor" style="display:none; padding:14px; border-radius:10px; background:#FAF5FF; border:1px dashed #C4B5FD; margin-bottom:14px;">

                <div class="field">
                    <label>Evento <span class="req">*</span></label>
                    <select name="id_evento_vinculo">
                        <option value="">Selecione o evento...</option>
                        <%
                            for (eventoModel evVinc : meusEventos) {
                        %>
                        <option value="<%= evVinc.getId_evento() %>"><%= evVinc.getNome_evento() %></option>
                        <%
                            }
                        %>
                    </select>
                    <% if (meusEventos.isEmpty()) { %>
                    <span class="hint">Você ainda não tem nenhum evento cadastrado.</span>
                    <% } %>
                </div>

                <div class="field">
                    <label>Data do contrato</label>
                    <input type="date" name="data_contrato_vinculo">
                </div>

                <div class="fields-row-2">
                    <div class="field">
                        <label>Valor adiantamento (R$)</label>
                        <input type="number" step="0.01" name="valor_pago_vinculo" value="0">
                    </div>
                    <div class="field">
                        <label>Valor total (R$)</label>
                        <input type="number" step="0.01" name="valor_total_vinculo" value="0">
                    </div>
                </div>

                <div class="fields-row-2">
                    <div class="field">
                        <label>Nome do responsável</label>
                        <input type="text" name="responsavel_contrato_vinculo">
                    </div>
                    <div class="field">
                        <label>Contato do responsável</label>
                        <input type="text" name="contato_responsavel_vinculo">
                    </div>
                </div>

                <div class="field">
                    <label>Objetivo / Escopo do serviço</label>
                    <textarea name="objeto_contrato_vinculo" rows="2"></textarea>
                </div>

                <div class="field">
                    <label>Documento do contrato</label>
                    <div class="upload-box" style="text-align:left;">
                        <input type="file" name="arquivo_contrato_vinculo" accept=".pdf,.doc,.docx" style="width:100%;">
                        <div style="margin-top:6px; font-size:10px; color:#94A3B8;">PDF, DOC, DOCX — até 10MB</div>
                    </div>
                </div>

            </div>

            <div class="modal-footer" style="justify-content:flex-end;">
                <button type="button" class="btn-outline" onclick="fecharModal('modalFornecedor')">Cancelar</button>
                <button type="submit" class="btn-solid">Salvar fornecedor</button>
            </div>
        </form>
    </div>
</div>

<script>

    // =========================================================
    // DADOS REAIS (gerados pelo JSP a partir do banco)
    // =========================================================

    const eventosData = [
        <%
            for (eventoModel ev : meusEventos) {
                int inscritos = inscritosPorEvento.get(ev.getId_evento());
                int espera = esperaPorEvento.get(ev.getId_evento());
                int pct = percentualPorEvento.get(ev.getId_evento());
        %>
        {
            id: <%= ev.getId_evento() %>,
            nome: '<%= js(ev.getNome_evento()) %>',
            status: '<%= ev.getStatus_evento() %>',
            statusLabel: '<%= rotuloStatusEvento(ev.getStatus_evento()) %>',
            tipo: '<%= ev.getTipo_evento() %>',
            categoria: '<%= rotuloCategoria(ev.getCategoria_evento()) %>',
            local: '<%= js(ev.getLocal_evento()) %>',
            inicio: '<%= ev.getInicio_evento().format(fmtData) %> · <%= ev.getInicio_evento().format(fmtHora) %>',
            fim: '<%= ev.getFim_evento().format(fmtData) %>',
            capacidade: <%= ev.getCapacidade_evento() %>,
            inscritos: <%= inscritos %>,
            espera: <%= espera %>,
            pct: <%= pct %>,
            codigo: '<%= js(ev.getCodigo_evento()) %>',
            descricao: '<%= js(ev.getDescricao_evento()) %>'
        },
        <%
            }
        %>
    ];

    const fornecedoresData = [
        <%
            for (fornecedorModel f : todosFornecedores) {
        %>
        {
            id: <%= f.getId_fornecedor() %>,
            nome: '<%= js(f.getNome_fornecedor()) %>',
            cnpj: '<%= js(f.getCNPJ_fornecedor()) %>',
            telefone: '<%= js(f.getTelefone_fornecedor()) %>',
            categoria: '<%= rotuloCategoriaFornecedor(f.getCategoria_fornecedor()) %>',
            categoriaValue: '<%= f.getCategoria_fornecedor() %>',
            email: '<%= js(f.getEmail()) %>'
        },
        <%
            }
        %>
    ];

    const contratosData = [
        <%
            for (contratoModel c : todosContratos) {
                String nomeF = nomeFornecedorPorId.get(c.getId_fornecedor());
                String nomeEv = nomeEventoPorId.get(c.getId_evento());
                if (nomeF == null || nomeEv == null) continue; // contrato de fornecedor/evento de outro organizador
                String situacao = c.getValor_pago() > 0 ? "Ativo" : "Pendente";
                String dataIso = c.getData_contrato().toLocalDate().toString();
        %>
        {
            id: <%= c.getId_contrato() %>,
            idFornecedor: <%= c.getId_fornecedor() %>,
            idEvento: <%= c.getId_evento() %>,
            nomeFornecedor: '<%= js(nomeF) %>',
            nomeEvento: '<%= js(nomeEv) %>',
            dataIso: '<%= dataIso %>',
            dataFormatada: '<%= c.getData_contrato().format(fmtData) %>',
            valorPago: <%= c.getValor_pago() %>,
            valorTotal: <%= c.getValor_total() %>,
            responsavel: '<%= js(c.getResponsavel_contrato()) %>',
            contato: '<%= js(c.getContato_responsavel()) %>',
            objeto: '<%= js(c.getObjeto_contrato()) %>',
            situacao: '<%= situacao %>',
            anexo: '<%= js(c.getAnexo_contrato()) %>'
        },
        <%
            }
        %>
    ];

    const totalInscritosReal = <%= totalInscritosSoma %>;

    // =========================================================
    // NAVEGAÇÃO ENTRE SUB-VIEWS
    // =========================================================

    function mudarView(viewId, botao) {
        document.querySelectorAll('.view-section').forEach(el => el.classList.remove('active'));
        document.getElementById('view-' + viewId).classList.add('active');
        document.querySelectorAll('.sidebar .nav-item').forEach(el => el.classList.remove('active'));
        if (botao) botao.classList.add('active');
        document.querySelector('.content').scrollTop = 0;
        fecharSidebarMobile();
    }

    // Alias usado por cliques em cards/gráficos (sem precisar do elemento <button> da sidebar)
    function mudarViewById(viewId) {
        const nav = document.querySelector('.sidebar .nav-item[data-view="' + viewId + '"]');
        mudarView(viewId, nav);
    }

    function toggleSidebar() {
        document.getElementById('sidebarEl').classList.toggle('open');
        document.getElementById('sidebarOverlay').classList.toggle('open');
    }

    function fecharSidebarMobile() {
        document.getElementById('sidebarEl').classList.remove('open');
        document.getElementById('sidebarOverlay').classList.remove('open');
    }

    (function abrirViewInicial() {
        const params = new URLSearchParams(window.location.search);
        const view = params.get('view');
        const abrirEvento = params.get('abrirEvento');

        if (abrirEvento) {
            abrirDetalheEvento(parseInt(abrirEvento, 10));
        } else if (view) {
            mudarViewById(view);
        }
    })();

    // =========================================================
    // NOTIFICAÇÕES
    // =========================================================

    function toggleNotificacoes(ev) {
        ev.stopPropagation();
        document.getElementById('notifDropdown').classList.toggle('open');
    }

    document.addEventListener('click', function (ev) {
        const dd = document.getElementById('notifDropdown');
        if (dd.classList.contains('open') && !dd.contains(ev.target) && ev.target.id !== 'bellBtn') {
            dd.classList.remove('open');
        }
    });

    // =========================================================
    // BARRA DE OCUPAÇÃO — cor conforme percentual
    // 0-60% verde · 61-75% amarelo · 76-100% vermelho
    // =========================================================

    function corBarra(pct) {
        if (pct <= 60) return 'bar-green';
        if (pct <= 75) return 'bar-yellow';
        return 'bar-red';
    }

    // =========================================================
    // EVENTOS — listagem com abas de status
    // =========================================================

    function renderizarEventosOrganizador(filtro) {
        const lista = filtro === 'todos' ? eventosData : eventosData.filter(e => e.status === filtro);

        document.getElementById('lista-eventos-organizador').innerHTML = lista.map(ev => `
            <div class="org-event-card" onclick="abrirDetalheEvento(\${ev.id})">
                <div class="icon-box">📅</div>
                <div class="info">
                    <strong>\${ev.nome}</strong>
                    <span class="status-pill \${ev.status === 'ativo' ? '' : ev.status}">\${ev.statusLabel}</span>
                    <div class="meta">\${ev.inicio} · \${ev.local}</div>
                    <div class="meta">\${ev.espera > 0 ? '⏳ ' + ev.espera + ' na lista de espera' : ''}</div>
                </div>
                <div class="capacity">
                    <strong>\${ev.inscritos}/\${ev.capacidade}</strong>
                    <div class="mini-bar"><span class="\${corBarra(ev.pct)}" style="width:\${ev.pct}%"></span></div>
                </div>
            </div>
        `).join('') || '<div class="empty-state">Nenhum evento nesse status.</div>';
    }

    renderizarEventosOrganizador('todos');

    document.querySelectorAll('#tabs-eventos .tab-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('#tabs-eventos .tab-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            renderizarEventosOrganizador(btn.dataset.status);
        });
    });

    // =========================================================
    // DETALHES DO EVENTO
    // =========================================================

    let currentEventoId = null;

    function abrirDetalheEvento(id) {
        const ev = eventosData.find(e => e.id === id);
        if (!ev) return;

        currentEventoId = id;

        document.getElementById('det_ev_nome').textContent = ev.nome;
        const statusEl = document.getElementById('det_ev_status');
        statusEl.textContent = ev.statusLabel;
        statusEl.className = 'status-pill ' + (ev.status === 'ativo' ? '' : ev.status);

        document.getElementById('det_ev_tipo').textContent = ev.tipo === 'publico' ? 'Público' : 'Privado';
        document.getElementById('det_ev_categoria').textContent = ev.categoria;
        document.getElementById('det_ev_inicio').textContent = ev.inicio;
        document.getElementById('det_ev_fim').textContent = ev.fim;
        document.getElementById('det_ev_local').textContent = ev.local;
        document.getElementById('det_ev_capacidade').textContent = ev.capacidade + ' pessoas';
        document.getElementById('det_ev_inscritos').textContent = ev.inscritos + ' (' + ev.pct + '%)';
        document.getElementById('det_ev_codigo').textContent = ev.codigo;
        document.getElementById('det_ev_descricao').textContent = ev.descricao || '—';

        const publicarBtn = document.getElementById('det_ev_publicar_btn');
        if (ev.status === 'rascunho') {
            publicarBtn.style.display = 'inline-flex';
            publicarBtn.href = '${pageContext.request.contextPath}/eventoController?action=publicar&id=' + id;
        } else {
            publicarBtn.style.display = 'none';
        }

        const vinculados = contratosData.filter(c => c.idEvento === id);

        document.getElementById('det_ev_fornecedores').innerHTML = vinculados.map(c => `
            <div class="vinculado-card">
                <div class="icon-box" style="width:34px;height:34px;border-radius:8px;background:#F5F3FF;color:#7C3AED;display:flex;align-items:center;justify-content:center;">🚚</div>
                <div class="info">
                    <strong>\${c.nomeFornecedor}</strong>
                    <span>Responsável: \${c.responsavel}</span>
                </div>
                <span class="status-pill \${c.situacao === 'Pendente' ? 'pendente' : ''}">\${c.situacao}</span>
                <button class="btn-outline" onclick="abrirDetalhesContrato(\${c.id})">📄 Ver contrato</button>
            </div>
        `).join('') || '<div class="empty-state">Nenhum fornecedor vinculado ainda.</div>';

        mudarViewById('detalheEvento');
    }

    // =========================================================
    // FORNECEDORES — listagem com abas de categoria
    // =========================================================

    function renderizarFornecedores(categoria, busca) {
        busca = (busca || '').toLowerCase();

        const lista = fornecedoresData.filter(f => {
            const okCat = categoria === 'Todos' || f.categoria === categoria;
            const okBusca = busca === '' || f.nome.toLowerCase().includes(busca);
            return okCat && okBusca;
        });

        document.getElementById('lista-fornecedores').innerHTML = lista.map(f => {
            const qtdContratos = contratosData.filter(c => c.idFornecedor === f.id).length;
            return `
                <div class="fornecedor-card" onclick="abrirDetalheFornecedor(\${f.id})">
                    <div class="icon-box">🚚</div>
                    <div class="info">
                        <strong>\${f.nome}</strong>
                        <div class="meta">\${f.categoria} · \${f.cnpj || 'CNPJ não informado'} · \${f.telefone || '—'}</div>
                        <div class="meta">\${qtdContratos} contrato(s)</div>
                    </div>
                    <span class="cat-tag">\${f.categoria}</span>
                </div>
            `;
        }).join('') || '<div class="empty-state">Nenhum fornecedor encontrado.</div>';
    }

    renderizarFornecedores('Todos', '');

    document.querySelectorAll('#tabs-fornecedores .tab-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('#tabs-fornecedores .tab-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            renderizarFornecedores(btn.dataset.cat, document.getElementById('busca-fornecedor').value);
        });
    });

    document.getElementById('busca-fornecedor').addEventListener('input', (e) => {
        const catAtiva = document.querySelector('#tabs-fornecedores .tab-btn.active').dataset.cat;
        renderizarFornecedores(catAtiva, e.target.value);
    });

    // =========================================================
    // DETALHES DO FORNECEDOR
    // =========================================================

    let currentFornecedorId = null;

    function abrirDetalheFornecedor(id) {
        const f = fornecedoresData.find(x => x.id === id);
        if (!f) return;

        currentFornecedorId = id;

        document.getElementById('det_for_nome').textContent = f.nome;
        document.getElementById('det_for_nome2').textContent = f.nome;
        document.getElementById('det_for_contato').textContent = f.categoria + ' · 📞 ' + (f.telefone || '—') + ' · ✉ ' + f.email;
        document.getElementById('det_for_categoria').textContent = f.categoria;

        const contratosDoFornecedor = contratosData.filter(c => c.idFornecedor === id);
        const eventosVinculados = [...new Set(contratosDoFornecedor.map(c => c.nomeEvento))];

        document.getElementById('det_for_eventos').innerHTML = eventosVinculados.map(nome =>
            `<span class="chip">📅 \${nome}</span>`
        ).join('') || '<span style="font-size:12px;color:#94A3B8;">Nenhum evento vinculado ainda.</span>';

        document.getElementById('det_for_contratos').innerHTML = contratosDoFornecedor.map(c => `
            <tr>
                <td>CTR-\${String(c.id).padStart(3, '0')}</td>
                <td>\${c.nomeEvento}</td>
                <td>\${c.dataFormatada}</td>
                <td>R$ \${c.valorTotal.toFixed(2)}</td>
                <td>R$ \${c.valorPago.toFixed(2)}</td>
                <td>\${c.responsavel}</td>
                <td><span class="status-pill \${c.situacao === 'Pendente' ? 'pendente' : ''}">\${c.situacao}</span></td>
                <td><button class="btn-outline" onclick="abrirDetalhesContrato(\${c.id})">👁 Ver</button></td>
            </tr>
        `).join('') || '<tr><td colspan="8" style="text-align:center;color:#94A3B8;">Nenhum contrato ainda.</td></tr>';

        mudarViewById('detalheFornecedor');
    }

    // =========================================================
    // MODAL: CONTRATO (ver / novo)
    // =========================================================

    function abrirModalContrato(idContrato, idEventoPreset, idFornecedorPreset) {

        const form = document.getElementById('formContrato');
        form.reset();
        document.getElementById('contratoAnexoAtual').value = '';
        document.getElementById('contratoAnexoExistenteLabel').textContent = '';

        if (idContrato) {
            // ---- MODO VISUALIZAR / EDITAR ----
            const c = contratosData.find(x => x.id === idContrato);
            if (!c) return;

            document.getElementById('contratoAction').value = 'editar';
            document.getElementById('contratoId').value = c.id;
            document.getElementById('contratoSubtitulo').textContent = c.nomeFornecedor + ' · ' + c.nomeEvento;

            document.getElementById('contratoFornecedorSelect').value = c.idFornecedor;
            document.getElementById('contratoEventoSelect').value = c.idEvento;
            document.getElementById('contratoIdFornecedor').value = c.idFornecedor;
            document.getElementById('contratoIdEvento').value = c.idEvento;
            document.getElementById('contratoData').value = c.dataIso;
            document.getElementById('contratoValorPago').value = c.valorPago;
            document.getElementById('contratoValorTotal').value = c.valorTotal;
            document.getElementById('contratoResponsavel').value = c.responsavel;
            document.getElementById('contratoContato').value = c.contato;
            document.getElementById('contratoObjeto').value = c.objeto;

            if (c.anexo) {
                document.getElementById('contratoAnexoAtual').value = c.anexo;
                document.getElementById('contratoAnexoExistenteLabel').textContent =
                    '📎 Já existe um arquivo anexado. Envie um novo apenas se quiser substituí-lo.';
            }

        } else {
            // ---- MODO NOVO CONTRATO ----
            document.getElementById('contratoAction').value = 'novo';
            document.getElementById('contratoId').value = '';
            document.getElementById('contratoSubtitulo').textContent = 'Novo contrato';

            if (idEventoPreset) {
                document.getElementById('contratoEventoSelect').value = idEventoPreset;
                document.getElementById('contratoIdEvento').value = idEventoPreset;
            }
            if (idFornecedorPreset) {
                document.getElementById('contratoFornecedorSelect').value = idFornecedorPreset;
                document.getElementById('contratoIdFornecedor').value = idFornecedorPreset;
            }

            const hoje = new Date().toISOString().split('T')[0];
            document.getElementById('contratoData').value = hoje;
        }

        document.getElementById('modalContrato').classList.add('open');
    }

    // =========================================================
    // DETALHES DO CONTRATO (somente leitura — img5)
    // =========================================================

    let currentContratoDetalheId = null;

    function abrirDetalhesContrato(idContrato) {
        const c = contratosData.find(x => x.id === idContrato);
        if (!c) return;

        currentContratoDetalheId = idContrato;

        document.getElementById('dc_codigo').textContent = 'CTR-' + String(c.id).padStart(3, '0');
        document.getElementById('dc_evento').textContent = c.nomeEvento;
        document.getElementById('dc_fornecedor').textContent = c.nomeFornecedor;
        document.getElementById('dc_data').textContent = c.dataFormatada;
        document.getElementById('dc_responsavel').textContent = c.responsavel;
        document.getElementById('dc_contato').textContent = c.contato || '—';
        document.getElementById('dc_valorPago').textContent = 'R$ ' + c.valorPago.toFixed(2);
        document.getElementById('dc_valorTotal').textContent = 'R$ ' + c.valorTotal.toFixed(2);
        document.getElementById('dc_situacao').textContent = c.situacao;
        document.getElementById('dc_objeto').textContent = c.objeto || '—';

        const anexoWrap = document.getElementById('dc_anexo_wrap');
        if (c.anexo) {
            const nomeArquivo = c.anexo.split('/').pop();
            anexoWrap.innerHTML = `
                <a href="${pageContext.request.contextPath}/\\${c.anexo}" target="_blank"
                   style="display:flex; align-items:center; gap:8px; padding:10px 14px; background:#ECFDF5; border:1px solid #A7F3D0; border-radius:9px; color:#065F46; font-size:13px; font-weight:600;">
                   📎 \\${nomeArquivo}
                </a>
            `;
        } else {
            anexoWrap.innerHTML = '<div style="font-size:12px; color:#94A3B8;">Nenhum arquivo anexado a este contrato.</div>';
        }

        document.getElementById('modalDetalhesContrato').classList.add('open');
    }

    function editarContratoAPartirDeDetalhes() {
        fecharModal('modalDetalhesContrato');
        abrirModalContrato(currentContratoDetalheId);
    }

    function exportarContratoDetalhesPDF() {
        const c = contratosData.find(x => x.id === currentContratoDetalheId);
        if (!c) return;

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        doc.setFontSize(14);
        doc.text('Contrato CTR-' + String(c.id).padStart(3, '0'), 14, 18);
        doc.autoTable({
            startY: 26,
            body: [
                ['Evento', c.nomeEvento], ['Fornecedor', c.nomeFornecedor],
                ['Data do contrato', c.dataFormatada], ['Responsável', c.responsavel],
                ['Contato', c.contato || '-'], ['Valor adiantamento', 'R$ ' + c.valorPago.toFixed(2)],
                ['Valor total', 'R$ ' + c.valorTotal.toFixed(2)], ['Status', c.situacao],
                ['Objetivo/Escopo', c.objeto || '-']
            ]
        });
        doc.save('contrato-CTR-' + String(c.id).padStart(3, '0') + '.pdf');
    }

    function prepararSubmitContrato() {
        const dataVal = document.getElementById('contratoData').value;
        document.getElementById('contratoDataHidden').value = dataVal + 'T00:00:00';

        if (!document.getElementById('contratoIdFornecedor').value) {
            alert('Selecione um fornecedor.');
            return false;
        }
        if (!document.getElementById('contratoIdEvento').value) {
            alert('Selecione um evento.');
            return false;
        }
        return true;
    }

    function exportarContratoPDF() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        doc.setFontSize(14);
        doc.text('Contrato de Fornecedor', 14, 18);
        doc.setFontSize(10);

        const linhas = [
            ['Fornecedor', document.getElementById('contratoFornecedorSelect').selectedOptions[0]?.text || '-'],
            ['Evento', document.getElementById('contratoEventoSelect').selectedOptions[0]?.text || '-'],
            ['Data do contrato', document.getElementById('contratoData').value],
            ['Valor adiantamento (R$)', document.getElementById('contratoValorPago').value],
            ['Valor total (R$)', document.getElementById('contratoValorTotal').value],
            ['Responsável', document.getElementById('contratoResponsavel').value],
            ['Contato do responsável', document.getElementById('contratoContato').value],
            ['Objeto do serviço', document.getElementById('contratoObjeto').value]
        ];

        doc.autoTable({ startY: 26, head: [['Campo', 'Valor']], body: linhas });
        doc.save('contrato.pdf');
    }

    // =========================================================
    // MODAL: NOVO FORNECEDOR (padrão)
    // =========================================================

    function abrirModalFornecedor() {
        document.getElementById('modalFornecedor').classList.add('open');
    }

    function fecharModal(id) {
        document.getElementById(id).classList.remove('open');
    }

    // =========================================================
    // FORM: CRIAR EVENTO
    // =========================================================

    function selecionarToggle(idAtivo, idInativo) {
        document.getElementById(idAtivo).classList.add('active');
        document.getElementById(idInativo).classList.remove('active');
    }

    function gerarCodigoEvento() {
        const ano = new Date().getFullYear();
        const sufixo = Math.random().toString(36).substring(2, 6).toUpperCase();
        document.getElementById('codigo_evento_input').value = 'EVT-' + ano + '-' + sufixo;
    }

    gerarCodigoEvento();

    function prepararSubmitEvento() {
        const dataInicio = document.getElementById('data_inicio_input').value;
        const horaInicio = document.getElementById('hora_inicio_input').value || '00:00';
        const dataFim = document.getElementById('data_fim_input').value || dataInicio;
        const horaFim = document.getElementById('hora_fim_input').value || '23:59';

        if (!dataInicio) {
            alert('Informe a data de início.');
            return false;
        }

        document.getElementById('inicio_evento_hidden').value = dataInicio + 'T' + horaInicio + ':00';
        document.getElementById('fim_evento_hidden').value = dataFim + 'T' + horaFim + ':00';
        return true;
    }

    // =========================================================
    // GRÁFICO "Inscrições ao longo do tempo" (eixo Y + tooltip)
    // Observação: a distribuição mensal ainda não vem de uma
    // consulta real por mês — usa o total real de inscritos
    // distribuído numa curva ilustrativa até esse valor.
    // =========================================================

    function renderLineChart() {
        const svg = document.getElementById('lineChart');
        if (!svg) return;

        const meses = [];
        const hoje = new Date();
        for (let i = 5; i >= 0; i--) {
            const d = new Date(hoje.getFullYear(), hoje.getMonth() - i, 1);
            meses.push(d.toLocaleDateString('pt-BR', { month: 'short' }).replace('.', ''));
        }

        const total = Math.max(totalInscritosReal, 1);
        const pesos = [0.45, 0.55, 0.62, 0.7, 0.85, 1];
        const valores = pesos.map(p => Math.round(total * p));

        const maxVal = Math.max(...valores, 5);
        const W = 580, H = 190, padL = 34, padB = 20, padT = 10;
        const chartW = W - padL - 10, chartH = H - padB - padT;

        const pontos = valores.map((v, i) => {
            const x = padL + (i / (valores.length - 1)) * chartW;
            const y = padT + chartH - (v / maxVal) * chartH;
            return { x, y, v, mes: meses[i] };
        });

        const linha = pontos.map(p => `\${p.x},\${p.y}`).join(' ');
        const area = linha + ` \${pontos[pontos.length-1].x},\${padT+chartH} \${pontos[0].x},\${padT+chartH}`;

        let svgHtml = '';

        // eixo Y (referência de valores)
        for (let i = 0; i <= 3; i++) {
            const val = Math.round((maxVal / 3) * i);
            const y = padT + chartH - (val / maxVal) * chartH;
            svgHtml += `<line x1="\${padL}" y1="\${y}" x2="\${W-10}" y2="\${y}" stroke="#F1F5F9" stroke-width="1"/>`;
            svgHtml += `<text x="0" y="\${y+3}" font-size="9" fill="#94A3B8">\${val}</text>`;
        }

        svgHtml += `<polyline fill="rgba(124,58,237,0.10)" stroke="none" points="\${area}"/>`;
        svgHtml += `<polyline fill="none" stroke="#7C3AED" stroke-width="2.5" points="\${linha}"/>`;

        pontos.forEach(p => {
            svgHtml += `<circle cx="\${p.x}" cy="\${p.y}" r="4" fill="#7C3AED" stroke="#FFFFFF" stroke-width="1.5"
                          class="chart-point" data-mes="\${p.mes}" data-valor="\${p.v}"/>`;
            svgHtml += `<text x="\${p.x}" y="\${H-4}" font-size="9" fill="#94A3B8" text-anchor="middle">\${p.mes}</text>`;
        });

        svg.innerHTML = svgHtml;

        const tooltip = document.getElementById('chartTooltip');

        svg.querySelectorAll('.chart-point').forEach(pt => {
            pt.addEventListener('mousemove', (ev) => {
                const rect = svg.parentElement.getBoundingClientRect();
                tooltip.style.display = 'block';
                tooltip.style.left = (ev.clientX - rect.left) + 'px';
                tooltip.style.top = (ev.clientY - rect.top) + 'px';
                tooltip.textContent = pt.dataset.mes + ': ' + pt.dataset.valor + ' inscritos';
            });
            pt.addEventListener('mouseleave', () => { tooltip.style.display = 'none'; });
        });
    }

    renderLineChart();

    // =========================================================
    // EXPORTAR PDF (relatório da tela atual)
    // =========================================================

    function exportarPDF(view) {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        doc.setFontSize(14);

        if (view === 'dashboard') {
            doc.text('Relatório — Dashboard do Organizador', 14, 18);
            doc.autoTable({
                startY: 26,
                head: [['Evento', 'Data', 'Inscritos/Capacidade', 'Ocupação', 'Status']],
                body: eventosData.map(e => [e.nome, e.inicio, e.inscritos + '/' + e.capacidade, e.pct + '%', e.statusLabel])
            });
        }

        if (view === 'eventos') {
            doc.text('Relatório — Meus Eventos', 14, 18);
            doc.autoTable({
                startY: 26,
                head: [['Evento', 'Status', 'Local', 'Início', 'Inscritos/Capacidade', 'Espera']],
                body: eventosData.map(e => [e.nome, e.statusLabel, e.local, e.inicio, e.inscritos + '/' + e.capacidade, e.espera])
            });
        }

        if (view === 'fornecedores') {
            doc.text('Relatório — Fornecedores', 14, 18);
            doc.autoTable({
                startY: 26,
                head: [['Nome', 'Categoria', 'CNPJ', 'Telefone', 'E-mail']],
                body: fornecedoresData.map(f => [f.nome, f.categoria, f.cnpj, f.telefone, f.email])
            });
        }

        if (view === 'espera') {
            doc.text('Relatório — Lista de Espera', 14, 18);
            const linhas = [];
            eventosData.filter(e => e.espera > 0).forEach(e => {
                linhas.push([e.nome, '', '(' + e.espera + ' na fila)']);
            });
            doc.autoTable({ startY: 26, head: [['Evento', '', 'Na fila']], body: linhas });
        }

        if (view === 'detalheEvento') {
            const ev = eventosData.find(e => e.id === currentEventoId);
            if (ev) {
                doc.text('Relatório — ' + ev.nome, 14, 18);
                doc.autoTable({
                    startY: 26,
                    body: [
                        ['Status', ev.statusLabel], ['Categoria', ev.categoria],
                        ['Local', ev.local], ['Início', ev.inicio], ['Término', ev.fim],
                        ['Capacidade', ev.capacidade], ['Inscritos', ev.inscritos + ' (' + ev.pct + '%)'],
                        ['Código', ev.codigo]
                    ]
                });
            }
        }

        if (view === 'detalheFornecedor') {
            const f = fornecedoresData.find(x => x.id === currentFornecedorId);
            if (f) {
                doc.text('Relatório — ' + f.nome, 14, 18);
                doc.autoTable({
                    startY: 26,
                    body: [['Categoria', f.categoria], ['CNPJ', f.cnpj], ['Telefone', f.telefone], ['E-mail', f.email]]
                });
                const contratosF = contratosData.filter(c => c.idFornecedor === currentFornecedorId);
                doc.autoTable({
                    startY: doc.lastAutoTable.finalY + 8,
                    head: [['Evento', 'Data', 'Valor Total', 'Situação']],
                    body: contratosF.map(c => [c.nomeEvento, c.dataFormatada, 'R$ ' + c.valorTotal.toFixed(2), c.situacao])
                });
            }
        }

        doc.save('relatorio-' + view + '.pdf');
    }

</script>

</body>
</html>
