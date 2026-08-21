<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="br.com.gerencia.model.usuarioModel"%>
<%@ page import="br.com.gerencia.model.eventoModel"%>
<%@ page import="br.com.gerencia.controller.usuarioController"%>
<%@ page import="br.com.gerencia.controller.eventoController"%>
<%@ page import="br.com.gerencia.controller.inscricaoController"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.HashMap"%>
<%
    // GUARDA DE SESSÃO
    usuarioModel usuarioLogado = (usuarioModel) session.getAttribute("usuarioLogado");

    if (usuarioLogado == null) {
        response.sendRedirect(request.getContextPath() + "/pages/loginUsuario.jsp");
        return;
    }

    if (!"admin".equals(usuarioLogado.getTipo_usuario())) {
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

    // ================= LISTA REAL DE USUÁRIOS (via método estático
    // do usuarioController, nunca instanciando DAO diretamente aqui) =================
    List<usuarioModel> listaUsuarios;
    try {
        listaUsuarios = usuarioController.listarTodos();
    } catch (Exception e) {
        listaUsuarios = new java.util.ArrayList<usuarioModel>();
    }

    // ================= CATEGORIAS DE EVENTO (via método estático do
    // eventoController, que lê o ENUM da coluna no banco) =================
    List<String> categoriasEvento = eventoController.listarCategoriasDisponiveis();

    // LISTA REAL DE EVENTOS (todos, de todos os organizadores)
    List<eventoModel> listaEventosAdmin = eventoController.listarTodos();

    HashMap<Integer, String> nomeOrganizadorPorId = new HashMap<Integer, String>();
    for (usuarioModel u : listaUsuarios) {
        nomeOrganizadorPorId.put(u.getId_usuario(), u.getNome_usuario());
    }

    // organizadores distintos que têm ao menos 1 evento (para o filtro da subtela Eventos)
    java.util.TreeSet<String> organizadoresComEvento = new java.util.TreeSet<String>();
    for (eventoModel evOrg : listaEventosAdmin) {
        organizadoresComEvento.add(nomeOrganizadorPorId.getOrDefault(evOrg.getId_organizador(), "—"));
    }

    // agregados do dashboard (tudo calculado a partir dos dados acima, nada fixo)
    int totalUsuarios = listaUsuarios.size();

    int totalOrganizadores = 0;
    int totalClientesAdmin = 0;
    int totalAdmins = 0;
    for (usuarioModel u : listaUsuarios) {
        if ("organizador".equals(u.getTipo_usuario())) totalOrganizadores++;
        else if ("admin".equals(u.getTipo_usuario())) totalAdmins++;
        else totalClientesAdmin++;
    }

    int totalEventosPlataforma = listaEventosAdmin.size();

    // uma única busca de todas as inscrições, agregada em memória
    // (evita 1 consulta ao banco por evento)
    HashMap<Integer, Integer> confirmadosPorEventoAdmin = new HashMap<Integer, Integer>();
    HashMap<Integer, Integer> checkinsPorEventoAdmin = new HashMap<Integer, Integer>();
    int totalInscricoesPlataforma = 0;

    for (br.com.gerencia.model.inscricaoModel insc : inscricaoController.listarTodos()) {

        if ("Confirmada".equals(insc.getStatus_inscricao())) {

            totalInscricoesPlataforma++;

            int idEv = insc.getId_evento();
            confirmadosPorEventoAdmin.put(idEv, confirmadosPorEventoAdmin.getOrDefault(idEv, 0) + 1);

            if (insc.getCheckin() != null) {
                checkinsPorEventoAdmin.put(idEv, checkinsPorEventoAdmin.getOrDefault(idEv, 0) + 1);
            }
        }
    }

    // contagem dinâmica de eventos por categoria — cobre qualquer categoria do
    // ENUM (atual ou futura), em vez de somar só tecCientifico/sociais/corporativos
    java.util.Map<String, Integer> contagemPorCategoria = new java.util.LinkedHashMap<String, Integer>();
    for (String cat : categoriasEvento) {
        contagemPorCategoria.put(cat, 0);
    }
    for (eventoModel ev : listaEventosAdmin) {
        String cat = ev.getCategoria_evento();
        contagemPorCategoria.put(cat, contagemPorCategoria.getOrDefault(cat, 0) + 1);
    }

    // paleta cíclica: cada categoria (na ordem do ENUM) recebe uma cor fixa
    String[] paletaCoresCategoria = {"#2563EB", "#10B981", "#7C3AED", "#F59E0B", "#EF4444", "#0EA5E9", "#EC4899", "#84CC16"};

    // MENSAGEM FLASH (ex: senha redefinida)
    String flashMsg = (String) session.getAttribute("flashMsg");
    if (flashMsg != null) {
        session.removeAttribute("flashMsg");
    }

    // HELPER: rótulo de exibição do tipo_usuario
%>
<%!
    private String js(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "&quot;").replace("\r", " ").replace("\n", " ").replace("</", "<\\/");
    }
    private String rotuloTipo(String tipo) {
        if ("organizador".equals(tipo)) return "Organizador";
        if ("admin".equals(tipo)) return "Admin";
        return "Cliente";
    }
    private String rotuloCategoriaEvento(String c) {
        if (c == null) return "";
        if ("tecCientifico".equals(c)) return "TecCientifico";
        if ("sociais".equals(c)) return "Sociais";
        if ("corporativos".equals(c)) return "Corporativos";
        // categoria nova (ainda sem rótulo customizado acima): capitaliza a primeira letra
        if (c.isEmpty()) return c;
        return Character.toUpperCase(c.charAt(0)) + c.substring(1);
    }
    private String rotuloStatusEvento(String s) {
        if ("ativo".equals(s)) return "Ativo";
        if ("rascunho".equals(s)) return "Rascunho";
        if ("cancelado".equals(s)) return "Cancelado";
        if ("finalizado".equals(s)) return "Finalizado";
        return s;
    }
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GerenCIA - Painel Administrativo</title>

<script>
    if (localStorage.getItem('gerencia-tema') === 'escuro') {
        document.documentElement.classList.add('dark-mode');
    }
</script>

<!-- Ajuste automático de proporções para qualquer tamanho de tela -->
<script src="${pageContext.request.contextPath}/js/responsivo.js"></script>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

<style>

    /* ================= RESET / BASE ================= */

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

    /* ================= LAYOUT GERAL ================= */

    .app {
        display: grid;
        grid-template-columns: 230px 1fr;
        height: calc(var(--vh, 1vh) * 100);
        min-width: 0;
    }

    .main-col {
        min-width: 0;
        overflow: hidden;
        display: flex;
        flex-direction: column;
        height: calc(var(--vh, 1vh) * 100);
    }

    /* ================= SIDEBAR (ESCURA) ================= */

    .sidebar {
        background: #0B1120;
        color: #CBD5E1;
        display: flex;
        flex-direction: column;
        padding: 20px 14px;
        height: calc(var(--vh, 1vh) * 100);
        overflow-y: auto;
    }

    .sidebar-logo {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 6px 8px 22px;
        color: #FFFFFF;
    }

    .sidebar-logo-icon {
        width: 34px;
        height: 34px;
        border-radius: 9px;
        background: linear-gradient(135deg, #64748B, #1E293B);
        color: #FFFFFF;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
    }

    .sidebar-logo span { font-size: 18px; font-weight: 700; }

    .nav-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 12px;
        border-radius: 9px;
        font-size: 16px;
        font-weight: 500;
        color: #94A3B8;
        margin-bottom: 2px;
        border: none;
        background: none;
        width: 100%;
        text-align: left;
    }

    .nav-item .nav-icon { font-size: 17px; width: 18px; text-align: center; }
    .nav-item .nav-label { flex: 1; }

    .nav-item:hover { background: #1E293B; color: #E2E8F0; }

    .nav-item.active {
        background: #1E293B;
        color: #FFFFFF;
    }

    .sidebar-footer {
        margin-top: auto;
        padding-top: 14px;
        border-top: 1px solid #1E293B;
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 14px 8px 6px;
    }

    .avatar {
        width: 34px;
        height: 34px;
        border-radius: 50%;
        background: linear-gradient(135deg, #64748B, #1E293B);
        color: #FFFFFF;
        font-size: 14px;
        font-weight: 700;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }

    .sidebar-footer strong { display: block; font-size: 15px; color: #F1F5F9; }
    .sidebar-footer small { display: block; font-size: 13px; color: #64748B; }

    .logout-btn {
        margin-left: auto;
        font-size: 17px;
        color: #64748B;
        background: none;
        border: none;
    }

    /* ================= TOPBAR ================= */

    .topbar {
        height: 64px;
        background: #FFFFFF;
        border-bottom: 1px solid #E2E8F0;
        display: flex;
        align-items: center;
        padding: 0 28px;
        flex-shrink: 0;
        position: relative;
        z-index: 10;
    }

    .topbar-title strong { display: block; font-size: 16px; }
    .topbar-title span { display: block; font-size: 13px; color: #94A3B8; }

    .topbar-user {
        margin-left: auto;
        display: flex;
        align-items: center;
        gap: 16px;
        font-size: 15px;
        font-weight: 600;
    }

    .eye-icon { color: #94A3B8; font-size: 17px; }

    /* ================= CONTEÚDO ================= */

    .content { flex: 1; overflow-y: auto; padding: 28px; max-width: 1760px; width: 100%; }

    .view-section { display: none; }
    .view-section.active { display: block; }

    .view-header {
        display: flex;
        align-items: flex-end;
        justify-content: space-between;
        margin-bottom: 20px;
        gap: 16px;
        flex-wrap: wrap;
    }

    .view-header h1 { font-size: 24px; font-weight: 700; letter-spacing: -0.3px; }
    .view-header p { color: #64748B; font-size: 15px; margin-top: 4px; }

    .header-actions { display: flex; gap: 10px; }

    .btn-outline {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        height: 38px;
        padding: 0 16px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        font-size: 15px;
        font-weight: 600;
        color: #334155;
    }

    .btn-outline:hover { background: #F8FAFC; }

    .btn-solid {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        height: 38px;
        padding: 0 16px;
        border-radius: 8px;
        border: none;
        background: #2563EB;
        color: #FFFFFF;
        font-size: 15px;
        font-weight: 600;
    }

    .btn-solid:hover { background: #1D4ED8; }

    /* ================= STAT CARDS ================= */

    .stats-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 8px;
        min-width: 0;
        width: 100%;
    }

    .stat-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-left: 3px solid #7C3AED;
        border-radius: 8px;
        padding: 8px 9px;
        transition: 0.15s;
    }
    .stat-card:hover { box-shadow: 0 6px 16px rgba(124,58,237,0.14); transform: translateY(-1px); }

    .stat-card .row-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 3px;
        gap: 4px;
    }

    .stat-card .row-top span.label {
        font-size: 9.5px; font-weight: 700; color: #64748B;
        text-transform: uppercase; letter-spacing: 0.03em; line-height: 1.25;
    }

    .stat-icon {
        width: 16px;
        height: 16px;
        border-radius: 5px;
        background: #F5F3FF;
        color: #7C3AED;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 9px;
        flex-shrink: 0;
    }

    .stat-card strong { font-size: 19px; font-weight: 900; display: block; margin-bottom: 0; color: #0F172A; line-height: 1.15; letter-spacing: -0.01em; }
    .stat-card .delta { font-size: 9px; color: #94A3B8; display: block; margin-top: 2px; }

    /* Destaque por cor — cada indicador com sua própria identidade visual */
    .stats-grid .stat-card:nth-child(1) { border-left-color: #7C3AED; background: linear-gradient(180deg, rgba(124,58,237,0.06), #FFFFFF 65%); }
    .stats-grid .stat-card:nth-child(1) strong { color: #7C3AED; }
    .stats-grid .stat-card:nth-child(1) .stat-icon { background: rgba(124,58,237,0.14); color: #7C3AED; }

    .stats-grid .stat-card:nth-child(2) { border-left-color: #16A34A; background: linear-gradient(180deg, rgba(22,163,74,0.06), #FFFFFF 65%); }
    .stats-grid .stat-card:nth-child(2) strong { color: #16A34A; }
    .stats-grid .stat-card:nth-child(2) .stat-icon { background: rgba(22,163,74,0.14); color: #16A34A; }

    .stats-grid .stat-card:nth-child(3) { border-left-color: #F59E0B; background: linear-gradient(180deg, rgba(245,158,11,0.08), #FFFFFF 65%); }
    .stats-grid .stat-card:nth-child(3) strong { color: #F59E0B; }
    .stats-grid .stat-card:nth-child(3) .stat-icon { background: rgba(245,158,11,0.16); color: #F59E0B; }

    .stats-grid .stat-card:nth-child(4) { border-left-color: #2563EB; background: linear-gradient(180deg, rgba(37,99,235,0.06), #FFFFFF 65%); }
    .stats-grid .stat-card:nth-child(4) strong { color: #2563EB; }
    .stats-grid .stat-card:nth-child(4) .stat-icon { background: rgba(37,99,235,0.14); color: #2563EB; }

    /* ================= DASHBOARD: DUAS COLUNAS ================= */

    .dash-cols {
        display: grid;
        grid-template-columns: 5fr 2fr;
        gap: 16px;
        margin-bottom: 20px;
        height: 300px;
    }

    /* Coluna direita: cards (2x2) empilhados sobre "Usuários por tipo de conta",
       alinhada ao painel da esquerda que agora ocupa toda a altura */
    .dash-right-col {
        display: flex;
        flex-direction: column;
        gap: 10px;
        min-width: 0;
        min-height: 0;
        width: 100%;
    }

    .panel-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 16px 20px;
        display: flex;
        flex-direction: column;
        min-height: 0;
        min-width: 0;
        overflow-y: auto;
    }

    .panel-card h3 { font-size: 16px; margin-bottom: 4px; }
    .panel-card .hint { font-size: 13px; color: #94A3B8; margin-bottom: 12px; }

    .vbar-wrap {
        display: flex;
        align-items: flex-end;
        justify-content: space-evenly;
        gap: 10px;
        flex: 1;
        min-height: 120px;
        padding: 0 8px;
    }

    .vbar-col {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: flex-end;
        height: 100%;
        flex: 1;
        max-width: 90px;
        min-width: 0;
        cursor: pointer;
    }

    .vbar-value { font-size: 12px; font-weight: 700; color: #0F172A; margin-bottom: 6px; }

    .vbar {
        width: 32px;
        border-radius: 12px;
        transition: 0.15s;
    }
    .vbar-col:hover .vbar { transform: scaleX(1.08); }

    .vbar-label { font-size: 11px; color: #64748B; margin-top: 10px; text-align: center; line-height: 1.3; }
    .vbar-count { font-size: 10px; color: #94A3B8; }

    .chart-legend-line {
        display: flex;
        gap: 16px;
        font-size: 14px;
        margin-bottom: 10px;
    }

    .chart-legend-line span { display: flex; align-items: center; gap: 6px; }

    .legend-line-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
    }

    /* ================= FORM (Meu Perfil) ================= */

    .form-card { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 12px; padding: 22px; max-width: 1200px; min-width: 0; width: 100%; }

    .field { margin-bottom: 15px; }
    .field label { display: block; font-size: 14px; font-weight: 600; color: #334155; margin-bottom: 5px; }
    .field input, .field select, .field textarea {
        width: 100%; padding: 9px 11px; border: 1px solid #E2E8F0; border-radius: 8px;
        font-size: 15px; font-family: inherit; background: #F8FAFC;
    }
    .field input:focus, .field select:focus, .field textarea:focus { outline: none; border-color: #7C3AED; background: #FFFFFF; }

    .fields-row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }

    @media (max-width: 700px) {
        .fields-row-2 { grid-template-columns: 1fr; }
    }

    /* ================= TABELA ================= */

    table.data-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 15px;
    }

    table.data-table th {
        text-align: left;
        font-size: 13px;
        text-transform: uppercase;
        letter-spacing: 0.03em;
        color: #94A3B8;
        padding: 10px 8px;
        border-bottom: 1px solid #E2E8F0;
        white-space: nowrap;
        position: sticky;
        top: 0;
        background: #FFFFFF;
        z-index: 1;
    }

    table.data-table td {
        padding: 12px 8px;
        border-bottom: 1px solid #F1F5F9;
        white-space: nowrap;
    }

    .status-pill {
        font-size: 13px;
        font-weight: 600;
        padding: 3px 9px;
        border-radius: 6px;
        background: #DCFCE7;
        color: #166534;
    }

    .status-pill.rascunho { background: #F1F5F9; color: #64748B; }
    .status-pill.inativo { background: #FEE2E2; color: #B91C1C; }

    .type-pill {
        font-size: 13px;
        font-weight: 600;
        padding: 3px 9px;
        border-radius: 6px;
    }

    .type-pill.cliente { background: #EFF6FF; color: #1D4ED8; }
    .type-pill.organizador { background: #F5F3FF; color: #7C3AED; }
    .type-pill.admin { background: #FEF2F2; color: #B91C1C; }

    .table-wrap { overflow-x: auto; }

    /* ================= FILTROS ================= */

    .filters-row {
        display: flex;
        gap: 10px;
        margin-bottom: 18px;
        flex-wrap: wrap;
        align-items: center;
    }

    .search-input {
        flex: 1;
        min-width: 220px;
        height: 38px;
        padding: 0 14px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        font-size: 15px;
    }

    select.filter-select {
        height: 38px;
        padding: 0 10px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        font-size: 15px;
        background: #FFFFFF;
        color: #334155;
    }

    .pill-group { display: flex; gap: 6px; flex-wrap: wrap; }

    .pill-btn {
        height: 34px;
        padding: 0 14px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        font-size: 14px;
        font-weight: 600;
        color: #475569;
    }

    .pill-btn.active {
        background: #0F172A;
        border-color: #0F172A;
        color: #FFFFFF;
    }

    /* ================= CATEGORIAS ================= */

    .categorias-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 16px;
    }

    .back-link { display: flex; align-items: center; gap: 8px; font-size: 12px; color: #64748B; margin-bottom: 10px; cursor: pointer; }
    .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 16px; }
    .detail-box { background: #FFFFFF; border: 1px solid #E2E8F0; border-radius: 10px; padding: 12px 14px; }
    .detail-box label { display: block; font-size: 10px; color: #94A3B8; text-transform: uppercase; margin-bottom: 4px; }
    .detail-box .val { font-size: 15px; font-weight: 600; }

    .categoria-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 18px;
    }

    .categoria-card .top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 10px;
    }

    .categoria-card .dot { width: 12px; height: 12px; border-radius: 50%; }
    .categoria-card strong { font-size: 17px; display: block; }
    .categoria-card .count { font-size: 14px; color: #94A3B8; margin-top: 3px; }

    .categoria-card .bar {
        height: 6px;
        border-radius: 3px;
        background: #F1F5F9;
        margin-top: 12px;
        overflow: hidden;
    }

    .categoria-card .bar span { display: block; height: 100%; }

    .note-box {
        background: #FFFBEB;
        border: 1px solid #FDE68A;
        color: #92400E;
        border-radius: 10px;
        padding: 12px 16px;
        font-size: 14px;
        margin-bottom: 20px;
    }

    .menu-toggle-btn {
        display: none;
        width: 34px; height: 34px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        color: #0F172A;
        font-size: 18px;
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
        }

        .sidebar.open { transform: translateX(0); }

        .menu-toggle-btn { display: flex; }

        .dash-cols { grid-template-columns: 1fr; }
        .stats-grid { grid-template-columns: repeat(2, 1fr); }
        .content { padding: 14px; }
    }

    @media (max-width: 480px) {
        .stats-grid { grid-template-columns: 1fr; }
    }
    .modal-overlay {
        display: none; position: fixed; inset: 0; background: rgba(2,6,23,0.55);
        align-items: center; justify-content: center; z-index: 100; padding: 20px;
    }
    .modal-overlay.open { display: flex; }
    .modal-box {
        background: #FFFFFF; border-radius: 14px; width: 100%; max-width: 440px;
        max-height: 90vh; overflow-y: auto; padding: 22px;
    }
    .modal-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 16px; }
    .modal-header h3 { font-size: 17px; }
    .modal-close { border: none; background: none; font-size: 20px; color: #94A3B8; cursor: pointer; }
    .modal-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px; }
    .modal-field label { display: block; font-size: 12px; color: #94A3B8; text-transform: uppercase; margin-bottom: 4px; }
    .modal-field .val { font-size: 15px; font-weight: 600; }

    /* =========================================================
       MODO ESCURO
       (a sidebar já é escura por padrão — o toggle escurece
       principalmente a área de conteúdo, que hoje é clara)
       ========================================================= */

    .theme-row {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 12px;
        margin-bottom: 2px;
    }

    .theme-row .nav-label { flex: 1; font-size: 13px; font-weight: 500; color: #94A3B8; }

    .theme-switch { position: relative; width: 36px; height: 20px; flex-shrink: 0; }
    .theme-switch input { opacity: 0; width: 0; height: 0; }
    .theme-switch-slider {
        position: absolute; inset: 0; background: #334155; border-radius: 20px;
        cursor: pointer; transition: 0.2s;
    }
    .theme-switch-slider::before {
        content: ""; position: absolute; width: 14px; height: 14px; left: 3px; top: 3px;
        background: #FFFFFF; border-radius: 50%; transition: 0.2s;
        box-shadow: 0 1px 3px rgba(0,0,0,0.3);
    }
    .theme-switch input:checked + .theme-switch-slider { background: #64748B; }
    .theme-switch input:checked + .theme-switch-slider::before { transform: translateX(16px); }

    html.dark-mode body { background: #0F172A; color: #E2E8F0; }

    html.dark-mode .topbar { background: #0F172A; border-bottom-color: #1E293B; }
    html.dark-mode .topbar-title strong { color: #E2E8F0; }
    html.dark-mode .eye-icon { color: #64748B; }

    html.dark-mode .stat-card,
    html.dark-mode .panel-card,
    html.dark-mode .categoria-card,
    html.dark-mode .form-card,
    html.dark-mode .modal-box {
        background: #1E293B;
        border-color: #334155;
    }

    html.dark-mode .stat-card strong,
    html.dark-mode .view-header h1,
    html.dark-mode .modal-header h3,
    html.dark-mode h3 {
        color: #F1F5F9;
    }

    html.dark-mode .vbar-value { color: #F1F5F9; }

    /* Destaque por cor dos cards — variantes para o modo escuro */
    html.dark-mode .stats-grid .stat-card:nth-child(1) { background: linear-gradient(180deg, rgba(124,58,237,0.20), #1E293B 65%); }
    html.dark-mode .stats-grid .stat-card:nth-child(1) strong { color: #A78BFA; }
    html.dark-mode .stats-grid .stat-card:nth-child(2) { background: linear-gradient(180deg, rgba(22,163,74,0.20), #1E293B 65%); }
    html.dark-mode .stats-grid .stat-card:nth-child(2) strong { color: #4ADE80; }
    html.dark-mode .stats-grid .stat-card:nth-child(3) { background: linear-gradient(180deg, rgba(245,158,11,0.20), #1E293B 65%); }
    html.dark-mode .stats-grid .stat-card:nth-child(3) strong { color: #FBBF24; }
    html.dark-mode .stats-grid .stat-card:nth-child(4) { background: linear-gradient(180deg, rgba(37,99,235,0.20), #1E293B 65%); }
    html.dark-mode .stats-grid .stat-card:nth-child(4) strong { color: #60A5FA; }

    html.dark-mode table.data-table th { color: #94A3B8; border-bottom-color: #334155; background: #1E293B; }
    html.dark-mode table.data-table td { border-bottom-color: #334155; color: #E2E8F0; }
    html.dark-mode table.data-table tbody tr:hover { background: #263449; }

    html.dark-mode input,
    html.dark-mode select,
    html.dark-mode textarea {
        background: #0F172A;
        border-color: #334155;
        color: #E2E8F0;
    }

    html.dark-mode .btn-outline {
        background: #1E293B;
        border-color: #334155;
        color: #E2E8F0;
    }

    html.dark-mode .btn-outline:hover { background: #334155; }

    html.dark-mode .pill-btn { background: #1E293B; border-color: #334155; color: #94A3B8; }

    html.dark-mode .note-box { background: #2A2410; border-color: #4B3E14; color: #FDE68A; }

    html.dark-mode .empty-state { color: #64748B; }

</style>
</head>
<body>

<div class="app">

    <!-- SIDEBAR -->
    <aside class="sidebar" id="sidebarEl">

        <div class="sidebar-logo">
            <div class="sidebar-logo-icon">📊</div>
            <span>Admin</span>
        </div>

        <button class="nav-item active" data-view="dashboard" onclick="mudarView('dashboard', this)">
            <span class="nav-label">Dashboard</span>
        </button>

        <button class="nav-item" data-view="eventos" onclick="mudarView('eventos', this)">
            <span class="nav-label">Eventos</span>
        </button>

        <button class="nav-item" data-view="usuarios" onclick="mudarView('usuarios', this)">
            <span class="nav-label">Usuários</span>
        </button>

        <div class="theme-row">
            <span class="nav-label">Modo escuro</span>
            <label class="theme-switch">
                <input type="checkbox" id="themeToggle" onchange="alternarTema()">
                <span class="theme-switch-slider"></span>
            </label>
        </div>

        <div class="sidebar-footer">
            <div class="avatar"><%= iniciais %></div>
            <div>
                <strong><%= nomeUsuario %></strong>
                <small>Administrador</small>
            </div>
            <a class="logout-btn" title="Sair"
               href="${pageContext.request.contextPath}/usuarioController?action=logout">↪</a>
        </div>

    </aside>

    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

    <!-- ÁREA PRINCIPAL -->
    <div class="main-col">

        <header class="topbar">
            <button class="menu-toggle-btn" onclick="toggleSidebar()">☰</button>
            <div class="topbar-title">
                <strong>GerenCIA</strong>
                <span>Painel Administrativo</span>
            </div>
            <div class="topbar-user" style="cursor:pointer;" onclick="mudarViewById('perfil')" title="Meu Perfil">
                <span class="eye-icon">👁</span>
                <div class="avatar" style="width:30px;height:30px;font-size:11px;"><%= iniciais %></div>
                <%= nomeUsuario %> ⌄
            </div>
        </header>

        <main class="content">

            <!-- VIEW: DASHBOARD -->
            <section class="view-section active" id="view-dashboard">

                <div class="view-header">
                    <div>
                        <h1>Dashboard Administrativo</h1>
                        <p>Visão geral da plataforma</p>
                    </div>
                </div>

                <div class="dash-cols">

                    <div class="panel-card">
                        <h3>Eventos por categoria</h3>
                        <p class="hint"><%= totalEventosPlataforma %> evento(s) no total</p>

                        <% if (totalEventosPlataforma == 0) { %>
                            <div class="empty-state">Nenhum evento cadastrado ainda.</div>
                        <% } else { %>
                        <div class="vbar-wrap">
                            <%
                                int idxCategoria = 0;
                                for (String cat : categoriasEvento) {
                                    int qtdCat = contagemPorCategoria.getOrDefault(cat, 0);
                                    int pctCat = totalEventosPlataforma > 0 ? Math.round(qtdCat * 100f / totalEventosPlataforma) : 0;
                                    String corCat = paletaCoresCategoria[idxCategoria % paletaCoresCategoria.length];
                                    idxCategoria++;
                            %>
                            <div class="vbar-col" onclick="mudarView('eventos', document.querySelector('[data-view=eventos]')); filtrarEventosPorCategoria('<%= cat %>');">
                                <span class="vbar-value"><%= pctCat %>%</span>
                                <div class="vbar" style="height:<%= pctCat > 0 ? pctCat + "%" : "4px" %>; background:<%= corCat %>;"></div>
                                <span class="vbar-label"><%= rotuloCategoriaEvento(cat) %><br><span class="vbar-count"><%= qtdCat %> evento(s)</span></span>
                            </div>
                            <%
                                }
                            %>
                        </div>
                        <% } %>
                    </div>

                    <div class="dash-right-col">

                        <div class="stats-grid">

                            <div class="stat-card">
                                <div class="row-top">
                                    <span class="label">Total de usuários</span>
                                    <div class="stat-icon"></div>
                                </div>
                                <strong><%= totalUsuarios %></strong>
                                <span class="delta"><%= totalClientesAdmin %> clientes · <%= totalOrganizadores %> organizadores · <%= totalAdmins %> admin(s)</span>
                            </div>

                            <div class="stat-card">
                                <div class="row-top">
                                    <span class="label">Organizadores</span>
                                    <div class="stat-icon"></div>
                                </div>
                                <strong><%= totalOrganizadores %></strong>
                                <span class="delta">&nbsp;</span>
                            </div>

                            <div class="stat-card">
                                <div class="row-top">
                                    <span class="label">Eventos na plataforma</span>
                                    <div class="stat-icon"></div>
                                </div>
                                <strong><%= totalEventosPlataforma %></strong>
                                <span class="delta">&nbsp;</span>
                            </div>

                            <div class="stat-card">
                                <div class="row-top">
                                    <span class="label">Total de inscrições confirmadas</span>
                                    <div class="stat-icon"></div>
                                </div>
                                <strong><%= totalInscricoesPlataforma %></strong>
                                <span class="delta">&nbsp;</span>
                            </div>

                        </div>

                        <div class="panel-card" style="flex:1;">
                            <h3>Usuários por tipo de conta</h3>
                            <p class="hint">Distribuição atual dos usuários cadastrados</p>

                            <div style="display:flex; flex-direction:column; gap:8px; margin-top:6px;">
                                <div>
                                    <div style="display:flex; justify-content:space-between; font-size:12px; margin-bottom:4px;">
                                        <span>Clientes</span><strong><%= totalClientesAdmin %></strong>
                                    </div>
                                    <div class="mini-bar" style="height:8px;"><span style="width:<%= totalUsuarios > 0 ? (totalClientesAdmin*100/totalUsuarios) : 0 %>%; background:#2563EB; display:block; height:100%; border-radius:4px;"></span></div>
                                </div>
                                <div>
                                    <div style="display:flex; justify-content:space-between; font-size:12px; margin-bottom:4px;">
                                        <span>Organizadores</span><strong><%= totalOrganizadores %></strong>
                                    </div>
                                    <div class="mini-bar" style="height:8px;"><span style="width:<%= totalUsuarios > 0 ? (totalOrganizadores*100/totalUsuarios) : 0 %>%; background:#7C3AED; display:block; height:100%; border-radius:4px;"></span></div>
                                </div>
                                <div>
                                    <div style="display:flex; justify-content:space-between; font-size:12px; margin-bottom:4px;">
                                        <span>Admins</span><strong><%= totalAdmins %></strong>
                                    </div>
                                    <div class="mini-bar" style="height:8px;"><span style="width:<%= totalUsuarios > 0 ? (totalAdmins*100/totalUsuarios) : 0 %>%; background:#0F172A; display:block; height:100%; border-radius:4px;"></span></div>
                                </div>
                            </div>
                        </div>

                    </div>

                </div>

                <div class="panel-card">
                    <div class="view-header" style="margin-bottom:14px;">
                        <h3 style="font-size:14px;">Eventos recentes</h3>
                        <button class="btn-outline" onclick="mudarView('eventos', document.querySelector('[data-view=eventos]'))">Ver todos</button>
                    </div>

                    <div class="table-wrap" style="max-height:300px; overflow-y:auto;">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Evento</th><th>Categoria</th><th>Data</th><th>Capacidade</th>
                                    <th>Inscritos</th><th>Comparecimento</th><th>Ocupação</th><th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int mostradosRecentes = 0;
                                    for (eventoModel ev : listaEventosAdmin) {
                                        if (mostradosRecentes >= 15) break;
                                        mostradosRecentes++;

                                        int confirmadosEv = confirmadosPorEventoAdmin.getOrDefault(ev.getId_evento(), 0);
                                        int checkinsEv = checkinsPorEventoAdmin.getOrDefault(ev.getId_evento(), 0);
                                        int ocupacaoEv = ev.getCapacidade_evento() > 0 ? (confirmadosEv * 100 / ev.getCapacidade_evento()) : 0;
                                        int pctComparecimentoEv = confirmadosEv > 0 ? (checkinsEv * 100 / confirmadosEv) : 0;
                                        String nomeOrg = nomeOrganizadorPorId.getOrDefault(ev.getId_organizador(), "—");
                                        String statusClasseEv = "ativo".equals(ev.getStatus_evento()) ? "" : ev.getStatus_evento();
                                %>
                                <tr>
                                    <td><strong><%= ev.getNome_evento() %></strong><br><span style="color:#94A3B8;font-size:11px;"><%= nomeOrg %></span></td>
                                    <td><%= rotuloCategoriaEvento(ev.getCategoria_evento()) %></td>
                                    <td><%= ev.getInicio_evento().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) %></td>
                                    <td><%= ev.getCapacidade_evento() %></td>
                                    <td><%= confirmadosEv %> (<%= ocupacaoEv %>%)</td>
                                    <td><%= checkinsEv %> de <%= confirmadosEv %> (<%= pctComparecimentoEv %>%)</td>
                                    <td><%= ocupacaoEv %>%</td>
                                    <td><span class="status-pill <%= statusClasseEv %>"><%= rotuloStatusEvento(ev.getStatus_evento()) %></span></td>
                                </tr>
                                <%
                                    }
                                    if (listaEventosAdmin.isEmpty()) {
                                %>
                                <tr><td colspan="8" style="text-align:center; color:#94A3B8;">Nenhum evento cadastrado ainda.</td></tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>

            </section>

            <!-- VIEW: EVENTOS (TODOS) -->
            <section class="view-section" id="view-eventos">

                <div class="view-header">
                    <div>
                        <h1>Todos os Eventos</h1>
                        <p><%= listaEventosAdmin.size() %> evento(s) na plataforma</p>
                    </div>
                    <button class="btn-outline" onclick="exportarEventosAdminPDF()">⬇ Exportar</button>
                </div>

                <div class="filters-row">
                    <input class="search-input" type="text" id="buscaEventoAdmin" placeholder="Buscar evento ou organizador..." oninput="filtrarEventosAdmin()">
                    <select class="filter-select" id="filtroStatusAdmin" onchange="filtrarEventosAdmin()">
                        <option value="">Todos os status</option>
                        <option value="ativo">Ativo</option>
                        <option value="rascunho">Rascunho</option>
                        <option value="cancelado">Cancelado</option>
                        <option value="finalizado">Finalizado</option>
                    </select>
                    <select class="filter-select" id="filtroCategoriaAdmin" onchange="filtrarEventosAdmin()">
                        <option value="">Todas as categorias</option>
                        <%
                            for (String cat : categoriasEvento) {
                        %>
                        <option value="<%= cat %>"><%= rotuloCategoriaEvento(cat) %></option>
                        <%
                            }
                        %>
                    </select>
                    <select class="filter-select" id="filtroOrganizadorAdmin" onchange="filtrarEventosAdmin()">
                        <option value="">Todos os organizadores</option>
                        <%
                            for (String nomeOrg : organizadoresComEvento) {
                        %>
                        <option value="<%= js(nomeOrg) %>"><%= nomeOrg %></option>
                        <%
                            }
                        %>
                    </select>
                </div>

                <div class="table-wrap">
                    <table class="data-table">
                        <thead>
                            <tr><th>Evento</th><th>Organizador</th><th>Categoria</th><th>Data</th><th>Status</th><th>Vagas</th></tr>
                        </thead>
                        <tbody id="corpoEventosAdmin">
                            <%
                                for (eventoModel ev : listaEventosAdmin) {
                                    int confirmadosEvT = confirmadosPorEventoAdmin.getOrDefault(ev.getId_evento(), 0);
                                    String nomeOrgT = nomeOrganizadorPorId.getOrDefault(ev.getId_organizador(), "—");
                                    String statusClasseT = "ativo".equals(ev.getStatus_evento()) ? "" : ev.getStatus_evento();
                            %>
                            <tr data-status="<%= ev.getStatus_evento() %>" data-categoria="<%= ev.getCategoria_evento() %>"
                                data-organizador="<%= js(nomeOrgT) %>"
                                data-busca="<%= js(ev.getNome_evento()).toLowerCase() %> <%= js(nomeOrgT).toLowerCase() %>"
                                style="cursor:pointer;" onclick="abrirDetalheEventoAdmin(<%= ev.getId_evento() %>)">
                                <td><%= ev.getNome_evento() %></td>
                                <td><%= nomeOrgT %></td>
                                <td><%= rotuloCategoriaEvento(ev.getCategoria_evento()) %></td>
                                <td><%= ev.getInicio_evento().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) %></td>
                                <td><span class="status-pill <%= statusClasseT %>"><%= rotuloStatusEvento(ev.getStatus_evento()) %></span></td>
                                <td><%= confirmadosEvT %>/<%= ev.getCapacidade_evento() %></td>
                            </tr>
                            <%
                                }
                                if (listaEventosAdmin.isEmpty()) {
                            %>
                            <tr><td colspan="6" style="text-align:center; color:#94A3B8;">Nenhum evento cadastrado ainda.</td></tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>

            </section>

            <!-- VIEW: DETALHES DO EVENTO (ADMIN) -->
            <section class="view-section" id="view-detalheEventoAdmin">

                <div class="back-link" onclick="mudarViewById('eventos')">← Voltar</div>

                <div class="view-header">
                    <div><h1 id="dea_nome">—</h1></div>
                    <div class="header-actions">
                        <span class="status-pill" id="dea_status">Ativo</span>
                        <button class="btn-outline" style="color:#DC2626; border-color:#FECACA;" onclick="excluirEventoAdmin()">🗑 Excluir evento</button>
                    </div>
                </div>

                <div class="detail-grid">
                    <div class="detail-box"><label>Organizador</label><div class="val" id="dea_organizador">—</div></div>
                    <div class="detail-box"><label>Categoria</label><div class="val" id="dea_categoria">—</div></div>
                    <div class="detail-box"><label>Início</label><div class="val" id="dea_inicio">—</div></div>
                    <div class="detail-box"><label>Término</label><div class="val" id="dea_fim">—</div></div>
                    <div class="detail-box"><label>Local</label><div class="val" id="dea_local">—</div></div>
                    <div class="detail-box"><label>Código</label><div class="val" id="dea_codigo">—</div></div>
                    <div class="detail-box"><label>Capacidade</label><div class="val" id="dea_capacidade">—</div></div>
                    <div class="detail-box"><label>Inscritos / Comparecimento</label><div class="val" id="dea_inscritos">—</div></div>
                </div>

                <div class="panel-card">
                    <label style="font-size:10px; color:#94A3B8; text-transform:uppercase; margin-bottom:6px; display:block;">Descrição</label>
                    <div id="dea_descricao" style="font-size:13px;">—</div>
                </div>

            </section>

            <!-- VIEW: USUÁRIOS -->
            <section class="view-section" id="view-usuarios">

                <div class="view-header">
                    <div>
                        <h1>Usuários</h1>
                        <p id="contador-usuarios"><%= listaUsuarios.size() %> usuários</p>
                    </div>
                    <div class="header-actions">
                        <button class="btn-outline">⬇ Exportar</button>
                        <button class="btn-solid" onclick="var f=document.getElementById('form-novo-usuario'); f.style.display = f.style.display === 'none' ? 'block' : 'none';">+ Novo usuário</button>
                    </div>
                </div>

                <% if (flashMsg != null) { %>
                    <div class="note-box" style="background:#ECFDF5; border-color:#A7F3D0; color:#065F46;">
                        ✅ <%= flashMsg %>
                    </div>
                <% } %>

                <div class="note-box">
                    ⚠️ O status "Ativo" abaixo é apenas visual — a tabela <code>usuario</code> ainda não tem uma coluna de status real.
                    Se quiser essa funcionalidade de verdade, ajustamos o banco.
                </div>

                <div id="form-novo-usuario" class="panel-card" style="display:none; margin-bottom:20px;">
                    <h3 style="margin-bottom:16px;">Novo usuário</h3>

                    <form action="${pageContext.request.contextPath}/usuarioController" method="post">
                        <input type="hidden" name="action" value="novoAdmin">

                        <div class="filters-row" style="margin-bottom:12px;">
                            <input class="search-input" type="text" name="nome_usuario" placeholder="Nome completo" required>
                            <input class="search-input" type="text" name="CPF_usuario" placeholder="CPF (somente números)" maxlength="11" required>
                        </div>

                        <div class="filters-row" style="margin-bottom:12px;">
                            <input class="search-input" type="email" name="email_usuario" placeholder="E-mail" required>
                            <input class="search-input" type="password" name="senha_usuario" placeholder="Senha inicial" required>
                        </div>

                        <div class="filters-row" style="margin-bottom:16px;">
                            <input class="search-input" type="tel" name="telefone" placeholder="Telefone" required>
                            <select class="filter-select" name="tipo_usuario" required>
                                <option value="usuarioFinal">Cliente</option>
                                <option value="organizador">Organizador</option>
                                <option value="admin">Admin</option>
                            </select>
                        </div>

                        <button type="submit" class="btn-solid">Salvar usuário</button>
                    </form>
                </div>

                <div class="filters-row">
                    <input class="search-input" type="text" placeholder="Buscar usuário..." id="busca-usuario">

                    <div class="pill-group" id="tipo-filtro">
                        <button class="pill-btn active" data-tipo="Todos">Todos</button>
                        <button class="pill-btn" data-tipo="Cliente">Cliente</button>
                        <button class="pill-btn" data-tipo="Organizador">Organizador</button>
                        <button class="pill-btn" data-tipo="Admin">Admin</button>
                    </div>
                </div>

                <div class="table-wrap">
                    <table class="data-table">
                        <thead>
                            <tr><th>Usuário</th><th>Tipo</th><th>Ações</th></tr>
                        </thead>
                        <tbody id="corpo-usuarios"></tbody>
                    </table>
                </div>

            </section>

            <!-- VIEW: MEU PERFIL -->
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
                        <div style="font-size:11px; color:#94A3B8;">CPF: <%= usuarioLogado.getCPF_usuario() %> · Administrador</div>
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
                        <input type="text" value="Administrador" disabled>
                    </div>

                    <button type="submit" class="btn-solid">Salvar alterações</button>

                </form>

            </section>

        </main>

    </div>


</div>

<script>

    // MODO ESCURO

    function alternarTema() {
        const escuro = document.getElementById('themeToggle').checked;
        document.documentElement.classList.toggle('dark-mode', escuro);
        localStorage.setItem('gerencia-tema', escuro ? 'escuro' : 'claro');
    }

    document.getElementById('themeToggle').checked =
        document.documentElement.classList.contains('dark-mode');

    // NAVEGAÇÃO ENTRE SUB-VIEWS

    function mudarView(viewId, botao) {
        document.querySelectorAll('.view-section').forEach(el => el.classList.remove('active'));
        document.getElementById('view-' + viewId).classList.add('active');
        document.querySelectorAll('.sidebar .nav-item').forEach(el => el.classList.remove('active'));
        if (botao) botao.classList.add('active');
        fecharSidebarMobile();
    }

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
        if (view) mudarViewById(view);
    })();

    // EVENTOS (ADMIN) — filtro por busca/status/categoria

    function filtrarEventosAdmin() {
        const busca = document.getElementById('buscaEventoAdmin').value.toLowerCase();
        const status = document.getElementById('filtroStatusAdmin').value;
        const categoria = document.getElementById('filtroCategoriaAdmin').value;
        const organizador = document.getElementById('filtroOrganizadorAdmin').value;

        document.querySelectorAll('#corpoEventosAdmin tr[data-status]').forEach(function (row) {
            const okBusca = busca === '' || (row.dataset.busca || '').includes(busca);
            const okStatus = status === '' || row.dataset.status === status;
            const okCategoria = categoria === '' || row.dataset.categoria === categoria;
            const okOrganizador = organizador === '' || row.dataset.organizador === organizador;
            row.style.display = (okBusca && okStatus && okCategoria && okOrganizador) ? '' : 'none';
        });
    }

    // DETALHES DO EVENTO (ADMIN) — dados reais + exclusão

    const eventosAdminData = [
        <%
            for (eventoModel evAd : listaEventosAdmin) {
                int confirmadosAd = confirmadosPorEventoAdmin.getOrDefault(evAd.getId_evento(), 0);
                int checkinsAd = checkinsPorEventoAdmin.getOrDefault(evAd.getId_evento(), 0);
                String nomeOrgAd = nomeOrganizadorPorId.getOrDefault(evAd.getId_organizador(), "—");
        %>
        {
            id: <%= evAd.getId_evento() %>,
            nome: '<%= js(evAd.getNome_evento()) %>',
            organizador: '<%= js(nomeOrgAd) %>',
            statusLabel: '<%= rotuloStatusEvento(evAd.getStatus_evento()) %>',
            statusClasse: '<%= "ativo".equals(evAd.getStatus_evento()) ? "" : evAd.getStatus_evento() %>',
            categoria: '<%= rotuloCategoriaEvento(evAd.getCategoria_evento()) %>',
            inicio: '<%= evAd.getInicio_evento().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) %>',
            fim: '<%= evAd.getFim_evento().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) %>',
            local: '<%= js(evAd.getLocal_evento()) %>',
            codigo: '<%= js(evAd.getCodigo_evento()) %>',
            capacidade: <%= evAd.getCapacidade_evento() %>,
            inscritos: <%= confirmadosAd %>,
            checkins: <%= checkinsAd %>,
            descricao: '<%= js(evAd.getDescricao_evento()) %>'
        },
        <%
            }
        %>
    ];

    let currentEventoAdminId = null;

    function abrirDetalheEventoAdmin(id) {
        const ev = eventosAdminData.find(e => e.id === id);
        if (!ev) return;

        currentEventoAdminId = id;

        document.getElementById('dea_nome').textContent = ev.nome;
        const statusEl = document.getElementById('dea_status');
        statusEl.textContent = ev.statusLabel;
        statusEl.className = 'status-pill ' + ev.statusClasse;

        document.getElementById('dea_organizador').textContent = ev.organizador;
        document.getElementById('dea_categoria').textContent = ev.categoria;
        document.getElementById('dea_inicio').textContent = ev.inicio;
        document.getElementById('dea_fim').textContent = ev.fim;
        document.getElementById('dea_local').textContent = ev.local;
        document.getElementById('dea_codigo').textContent = ev.codigo;
        document.getElementById('dea_capacidade').textContent = ev.capacidade + ' pessoas';
        document.getElementById('dea_inscritos').textContent =
            ev.inscritos + ' inscrito(s) / ' + ev.checkins + ' check-in(s)';
        document.getElementById('dea_descricao').textContent = ev.descricao || '—';

        mudarViewById('detalheEventoAdmin');
    }

    function excluirEventoAdmin() {
        const ev = eventosAdminData.find(e => e.id === currentEventoAdminId);
        if (!ev) return;

        if (!confirm('Excluir "' + ev.nome + '"? Isso remove também inscrições, contratos e favoritos ligados a esse evento. Essa ação não pode ser desfeita.')) {
            return;
        }

        window.location.href = '${pageContext.request.contextPath}/eventoController?action=excluir&id=' + ev.id;
    }

    function filtrarEventosPorCategoria(categoria) {
        document.getElementById('filtroCategoriaAdmin').value = categoria;
        filtrarEventosAdmin();
    }

    function exportarEventosAdminPDF() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        doc.setFontSize(14);
        doc.text('Todos os Eventos - GerenCIA', 14, 18);

        const linhas = [];
        document.querySelectorAll('#corpoEventosAdmin tr[data-status]').forEach(function (row) {
            if (row.style.display === 'none') return;
            const tds = row.querySelectorAll('td');
            linhas.push(Array.from(tds).map(td => td.textContent.trim()));
        });

        doc.autoTable({
            startY: 26,
            head: [['Evento', 'Organizador', 'Categoria', 'Data', 'Status', 'Vagas']],
            body: linhas
        });

        doc.save('eventos-plataforma.pdf');
    }

    // USUÁRIOS (dados reais, vindos do usuarioDAO)

    const usuarios = [
        <%
            for (usuarioModel u : listaUsuarios) {
                String nomeEsc = js(u.getNome_usuario());
                String emailEsc = js(u.getEmail_usuario());
        %>
        {
            id: <%= u.getId_usuario() %>,
            nome: '<%= nomeEsc %>',
            email: '<%= emailEsc %>',
            tipo: '<%= rotuloTipo(u.getTipo_usuario()) %>',
            cpf: '<%= u.getCPF_usuario() == null ? "" : u.getCPF_usuario() %>',
            telefone: '<%= js(u.getTelefone()) %>'
        },
        <%
            }
        %>
    ];

    let filtroTipo = 'Todos';
    let filtroBusca = '';

    function iniciaisDe(nome) {
        const partes = nome.trim().split(/\s+/);
        return partes.length > 1
            ? (partes[0][0] + partes[partes.length - 1][0]).toUpperCase()
            : partes[0][0].toUpperCase();
    }

    function renderizarUsuarios() {
        const filtrados = usuarios.filter(u => {
            const okTipo = filtroTipo === 'Todos' || u.tipo === filtroTipo;
            const okBusca = filtroBusca === '' ||
                u.nome.toLowerCase().includes(filtroBusca) ||
                u.email.toLowerCase().includes(filtroBusca);
            return okTipo && okBusca;
        });

        const tipoClasse = { Cliente: 'cliente', Organizador: 'organizador', Admin: 'admin' };
        const base = '${pageContext.request.contextPath}/usuarioController';

        document.getElementById('corpo-usuarios').innerHTML = filtrados.map(u => `
            <tr style="cursor:pointer;" onclick="abrirDetalheUsuario(\${u.id})">
                <td>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <div class="avatar" style="width:30px;height:30px;font-size:11px;background:linear-gradient(135deg,#64748B,#1E293B);">\${iniciaisDe(u.nome)}</div>
                        <div>
                            <div style="font-weight:600;">\${u.nome}</div>
                            <div style="font-size:11px; color:#94A3B8;">\${u.email}</div>
                        </div>
                    </div>
                </td>
                <td><span class="type-pill \${tipoClasse[u.tipo]}">\${u.tipo}</span></td>
                <td onclick="event.stopPropagation();">
                    <a href="\${base}?action=redefinirSenha&id=\${u.id}"
                       style="color:#2563EB; font-weight:600;"
                       onclick="return confirm('Redefinir a senha deste usuário para a senha temporária padrão?');">Redefinir senha</a>
                    &nbsp;·&nbsp;
                    <a href="\${base}?action=excluir&id=\${u.id}"
                       style="color:#DC2626; font-weight:600;"
                       onclick="return confirm('Excluir este usuário? Essa ação não pode ser desfeita.');">Excluir</a>
                </td>
            </tr>
        `).join('') || '<tr><td colspan="6" style="text-align:center; color:#94A3B8;">Nenhum usuário encontrado.</td></tr>';

        document.getElementById('contador-usuarios').textContent =
            filtrados.length + ' de ' + usuarios.length + ' usuários';
    }

    renderizarUsuarios();

    document.querySelectorAll('#tipo-filtro .pill-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('#tipo-filtro .pill-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            filtroTipo = btn.dataset.tipo;
            renderizarUsuarios();
        });
    });

    document.getElementById('busca-usuario').addEventListener('input', (e) => {
        filtroBusca = e.target.value.toLowerCase();
        renderizarUsuarios();
    });

    // DETALHES DO USUÁRIO (modal)

    function abrirDetalheUsuario(id) {
        const u = usuarios.find(x => x.id === id);
        if (!u) return;

        document.getElementById('du_nome').textContent = u.nome;
        document.getElementById('du_avatar').textContent = iniciaisDe(u.nome);
        document.getElementById('du_email').textContent = u.email;
        document.getElementById('du_tipo').textContent = u.tipo;
        document.getElementById('du_cpf').textContent = u.cpf || '—';
        document.getElementById('du_telefone').textContent = u.telefone || '—';

        const base = '${pageContext.request.contextPath}/usuarioController';
        document.getElementById('du_redefinir').href = base + '?action=redefinirSenha&id=' + u.id;
        document.getElementById('du_excluir').href = base + '?action=excluir&id=' + u.id;

        document.getElementById('modalDetalheUsuario').classList.add('open');
    }

    function fecharModal(id) {
        document.getElementById(id).classList.remove('open');
    }

</script>

<!-- MODAL: DETALHES DO USUÁRIO -->
<div class="modal-overlay" id="modalDetalheUsuario">
    <div class="modal-box">
        <div class="modal-header">
            <div style="display:flex; align-items:center; gap:12px;">
                <div class="avatar" id="du_avatar" style="width:44px;height:44px;font-size:15px;background:linear-gradient(135deg,#64748B,#1E293B);">—</div>
                <div>
                    <h3 id="du_nome">—</h3>
                    <span style="font-size:11px; color:#94A3B8;" id="du_email">—</span>
                </div>
            </div>
            <button class="modal-close" onclick="fecharModal('modalDetalheUsuario')">×</button>
        </div>

        <div class="modal-row">
            <div class="modal-field"><label>Tipo de conta</label><div class="val" id="du_tipo">—</div></div>
            <div class="modal-field"><label>CPF</label><div class="val" id="du_cpf">—</div></div>
        </div>
        <div class="modal-row">
            <div class="modal-field" style="grid-column:1/-1;"><label>Telefone</label><div class="val" id="du_telefone">—</div></div>
        </div>

        <div class="modal-footer" style="display:flex; justify-content:space-between; margin-top:16px;">
            <a id="du_redefinir" href="#" style="color:#2563EB; font-weight:600; font-size:13px;"
               onclick="return confirm('Redefinir a senha deste usuário para a senha temporária padrão?');">Redefinir senha</a>
            <a id="du_excluir" href="#" style="color:#DC2626; font-weight:600; font-size:13px;"
               onclick="return confirm('Excluir este usuário? Essa ação não pode ser desfeita.');">Excluir usuário</a>
        </div>
    </div>
</div>

</body>
</html>
