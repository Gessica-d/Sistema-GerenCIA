<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="br.com.gerencia.model.usuarioModel"%>
<%@ page import="br.com.gerencia.model.eventoModel"%>
<%@ page import="br.com.gerencia.dao.usuarioDAO"%>
<%@ page import="br.com.gerencia.dao.eventoDAO"%>
<%@ page import="br.com.gerencia.dao.inscricaoDAO"%>
<%@ page import="br.com.gerencia.utils.Conexao"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.HashMap"%>
<%
    // ================= GUARDA DE SESSÃO =================
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

    // ================= LISTA REAL DE USUÁRIOS =================
    List<usuarioModel> listaUsuarios;
    try {
        listaUsuarios = new usuarioDAO(Conexao.getConnection()).listarUsuarios();
    } catch (Exception e) {
        listaUsuarios = new java.util.ArrayList<usuarioModel>();
    }

    // ================= LISTA REAL DE EVENTOS (todos, de todos os organizadores) =================
    eventoDAO eventoDAOJsp = new eventoDAO(Conexao.getConnection());
    inscricaoDAO inscricaoDAOAdminJsp = new inscricaoDAO(Conexao.getConnection());

    List<eventoModel> listaEventosAdmin = eventoDAOJsp.listarEventos();

    HashMap<Integer, String> nomeOrganizadorPorId = new HashMap<Integer, String>();
    for (usuarioModel u : listaUsuarios) {
        nomeOrganizadorPorId.put(u.getId_usuario(), u.getNome_usuario());
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

    for (br.com.gerencia.model.inscricaoModel insc : inscricaoDAOAdminJsp.listarInscricoes()) {

        if ("Confirmada".equals(insc.getStatus_inscricao())) {

            totalInscricoesPlataforma++;

            int idEv = insc.getId_evento();
            confirmadosPorEventoAdmin.put(idEv, confirmadosPorEventoAdmin.getOrDefault(idEv, 0) + 1);

            if (insc.getCheckin() != null) {
                checkinsPorEventoAdmin.put(idEv, checkinsPorEventoAdmin.getOrDefault(idEv, 0) + 1);
            }
        }
    }

    int somaTecCientifico = 0, somaSociais = 0, somaCorporativos = 0;

    for (eventoModel ev : listaEventosAdmin) {
        if ("tecCientifico".equals(ev.getCategoria_evento())) somaTecCientifico++;
        else if ("sociais".equals(ev.getCategoria_evento())) somaSociais++;
        else if ("corporativos".equals(ev.getCategoria_evento())) somaCorporativos++;
    }

    int pctTecCientifico = totalEventosPlataforma > 0 ? Math.round(somaTecCientifico * 100f / totalEventosPlataforma) : 0;
    int pctSociais = totalEventosPlataforma > 0 ? Math.round(somaSociais * 100f / totalEventosPlataforma) : 0;
    int pctCorporativos = totalEventosPlataforma > 0 ? Math.round(somaCorporativos * 100f / totalEventosPlataforma) : 0;

    // geometria do donut (raio 70 => circunferência 439.82), calculada a partir dos % reais
    double circDonut = 439.82;
    double lenTec = (pctTecCientifico / 100.0) * circDonut;
    double lenSoc = (pctSociais / 100.0) * circDonut;
    double lenCorp = (pctCorporativos / 100.0) * circDonut;
    double offTec = 0;
    double offSoc = -lenTec;
    double offCorp = -(lenTec + lenSoc);

    // ================= MENSAGEM FLASH (ex: senha redefinida) =================
    String flashMsg = (String) session.getAttribute("flashMsg");
    if (flashMsg != null) {
        session.removeAttribute("flashMsg");
    }

    // ================= HELPER: rótulo de exibição do tipo_usuario =================
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
        if ("tecCientifico".equals(c)) return "TecCientifico";
        if ("sociais".equals(c)) return "Sociais";
        if ("corporativos".equals(c)) return "Corporativos";
        return c;
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

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

<style>

    /* ================= RESET / BASE ================= */

    * { margin: 0; padding: 0; box-sizing: border-box; }

    html {
        overflow-x: hidden;
        width: 100%;
    }

    body {
        font-family: 'Inter', Arial, Helvetica, sans-serif;
        color: #0F172A;
        background: #F8FAFC;
        overflow-x: hidden;
        width: 100%;
    }

    a { text-decoration: none; color: inherit; }
    button { font-family: inherit; cursor: pointer; }

    /* ================= LAYOUT GERAL ================= */

    .app {
        display: grid;
        grid-template-columns: 230px 1fr;
        min-height: 100vh;
        min-width: 0;
    }

    .main-col {
        min-width: 0;
        overflow-x: hidden;
    }

    /* ================= SIDEBAR (ESCURA) ================= */

    .sidebar {
        background: #0B1120;
        color: #CBD5E1;
        display: flex;
        flex-direction: column;
        padding: 20px 14px;
        position: sticky;
        top: 0;
        height: 100vh;
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
        font-size: 16px;
    }

    .sidebar-logo span { font-size: 16px; font-weight: 700; }

    .nav-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 12px;
        border-radius: 9px;
        font-size: 14px;
        font-weight: 500;
        color: #94A3B8;
        margin-bottom: 2px;
        border: none;
        background: none;
        width: 100%;
        text-align: left;
    }

    .nav-item .nav-icon { font-size: 15px; width: 18px; text-align: center; }
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
        font-size: 12px;
        font-weight: 700;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }

    .sidebar-footer strong { display: block; font-size: 13px; color: #F1F5F9; }
    .sidebar-footer small { display: block; font-size: 11px; color: #64748B; }

    .logout-btn {
        margin-left: auto;
        font-size: 15px;
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
        position: sticky;
        top: 0;
        z-index: 5;
    }

    .topbar-title strong { display: block; font-size: 14px; }
    .topbar-title span { display: block; font-size: 11px; color: #94A3B8; }

    .topbar-user {
        margin-left: auto;
        display: flex;
        align-items: center;
        gap: 16px;
        font-size: 13px;
        font-weight: 600;
    }

    .eye-icon { color: #94A3B8; font-size: 15px; }

    /* ================= CONTEÚDO ================= */

    .content { padding: 28px; max-width: 1280px; }

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

    .view-header h1 { font-size: 22px; }
    .view-header p { color: #64748B; font-size: 13px; margin-top: 4px; }

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
        font-size: 13px;
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
        font-size: 13px;
        font-weight: 600;
    }

    .btn-solid:hover { background: #1D4ED8; }

    /* ================= STAT CARDS ================= */

    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 16px;
        margin-bottom: 20px;
    }

    .stat-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 18px;
    }

    .stat-card .row-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 14px;
    }

    .stat-card .row-top span.label { font-size: 13px; color: #64748B; }

    .stat-icon {
        width: 34px;
        height: 34px;
        border-radius: 9px;
        background: #F1F5F9;
        color: #334155;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 15px;
    }

    .stat-card strong { font-size: 26px; display: block; margin-bottom: 4px; }
    .stat-card .delta { font-size: 11px; color: #94A3B8; }

    /* ================= DASHBOARD: DUAS COLUNAS ================= */

    .dash-cols {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
        margin-bottom: 20px;
        align-items: start;
    }

    .panel-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 20px;
    }

    .panel-card h3 { font-size: 14px; margin-bottom: 4px; }
    .panel-card .hint { font-size: 11px; color: #94A3B8; margin-bottom: 16px; }

    .donut-wrap { display: flex; align-items: center; gap: 20px; }

    .legend-item {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 12px;
        margin-bottom: 8px;
    }

    .legend-dot {
        width: 9px;
        height: 9px;
        border-radius: 50%;
        flex-shrink: 0;
    }

    .legend-item .pct { margin-left: auto; font-weight: 700; }

    .chart-legend-line {
        display: flex;
        gap: 16px;
        font-size: 12px;
        margin-bottom: 10px;
    }

    .chart-legend-line span { display: flex; align-items: center; gap: 6px; }

    .legend-line-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
    }

    /* ================= TABELA ================= */

    table.data-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
    }

    table.data-table th {
        text-align: left;
        font-size: 11px;
        text-transform: uppercase;
        letter-spacing: 0.03em;
        color: #94A3B8;
        padding: 10px 8px;
        border-bottom: 1px solid #E2E8F0;
        white-space: nowrap;
    }

    table.data-table td {
        padding: 12px 8px;
        border-bottom: 1px solid #F1F5F9;
        white-space: nowrap;
    }

    .status-pill {
        font-size: 11px;
        font-weight: 600;
        padding: 3px 9px;
        border-radius: 6px;
        background: #DCFCE7;
        color: #166534;
    }

    .status-pill.rascunho { background: #F1F5F9; color: #64748B; }
    .status-pill.inativo { background: #FEE2E2; color: #B91C1C; }

    .type-pill {
        font-size: 11px;
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
        font-size: 13px;
    }

    select.filter-select {
        height: 38px;
        padding: 0 10px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        font-size: 13px;
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
        font-size: 12px;
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
    .categoria-card strong { font-size: 15px; display: block; }
    .categoria-card .count { font-size: 12px; color: #94A3B8; margin-top: 3px; }

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
        font-size: 12px;
        margin-bottom: 20px;
    }

    .menu-toggle-btn {
        display: none;
        width: 34px; height: 34px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        color: #0F172A;
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
    .modal-header h3 { font-size: 15px; }
    .modal-close { border: none; background: none; font-size: 18px; color: #94A3B8; cursor: pointer; }
    .modal-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px; }
    .modal-field label { display: block; font-size: 10px; color: #94A3B8; text-transform: uppercase; margin-bottom: 4px; }
    .modal-field .val { font-size: 13px; font-weight: 600; }

</style>
</head>
<body>

<div class="app">

    <!-- ================= SIDEBAR ================= -->
    <aside class="sidebar" id="sidebarEl">

        <div class="sidebar-logo">
            <div class="sidebar-logo-icon">📊</div>
            <span>Admin</span>
        </div>

        <button class="nav-item active" data-view="dashboard" onclick="mudarView('dashboard', this)">
            <span class="nav-icon">▦</span>
            <span class="nav-label">Dashboard</span>
        </button>

        <button class="nav-item" data-view="eventos" onclick="mudarView('eventos', this)">
            <span class="nav-icon">📅</span>
            <span class="nav-label">Eventos</span>
        </button>

        <button class="nav-item" data-view="usuarios" onclick="mudarView('usuarios', this)">
            <span class="nav-icon">👥</span>
            <span class="nav-label">Usuários</span>
        </button>

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

    <!-- ================= ÁREA PRINCIPAL ================= -->
    <div class="main-col">

        <header class="topbar">
            <button class="menu-toggle-btn" onclick="toggleSidebar()">☰</button>
            <div class="topbar-title">
                <strong>GerenCIA</strong>
                <span>Painel Administrativo</span>
            </div>
            <div class="topbar-user">
                <span class="eye-icon">👁</span>
                <div class="avatar" style="width:30px;height:30px;font-size:11px;"><%= iniciais %></div>
                <%= nomeUsuario %> ⌄
            </div>
        </header>

        <main class="content">

            <!-- ============================================================
                 VIEW: DASHBOARD
            ============================================================ -->
            <section class="view-section active" id="view-dashboard">

                <div class="view-header">
                    <div>
                        <h1>Dashboard Administrativo</h1>
                        <p>Visão geral da plataforma</p>
                    </div>
                </div>

                <div class="stats-grid">

                    <div class="stat-card">
                        <div class="row-top">
                            <span class="label">Total de usuários</span>
                            <div class="stat-icon">👥</div>
                        </div>
                        <strong><%= totalUsuarios %></strong>
                        <span class="delta"><%= totalClientesAdmin %> clientes · <%= totalOrganizadores %> organizadores · <%= totalAdmins %> admin(s)</span>
                    </div>

                    <div class="stat-card">
                        <div class="row-top">
                            <span class="label">Organizadores</span>
                            <div class="stat-icon">🏢</div>
                        </div>
                        <strong><%= totalOrganizadores %></strong>
                        <span class="delta">&nbsp;</span>
                    </div>

                    <div class="stat-card">
                        <div class="row-top">
                            <span class="label">Eventos na plataforma</span>
                            <div class="stat-icon">📅</div>
                        </div>
                        <strong><%= totalEventosPlataforma %></strong>
                        <span class="delta">&nbsp;</span>
                    </div>

                    <div class="stat-card">
                        <div class="row-top">
                            <span class="label">Total de inscrições confirmadas</span>
                            <div class="stat-icon">📈</div>
                        </div>
                        <strong><%= totalInscricoesPlataforma %></strong>
                        <span class="delta">&nbsp;</span>
                    </div>

                </div>

                <div class="dash-cols">

                    <div class="panel-card">
                        <h3>Eventos por categoria</h3>
                        <p class="hint"><%= totalEventosPlataforma %> evento(s) no total</p>

                        <% if (totalEventosPlataforma == 0) { %>
                            <div class="empty-state">Nenhum evento cadastrado ainda.</div>
                        <% } else { %>
                        <div class="donut-wrap">

                            <svg viewBox="0 0 180 180" width="150" height="150">
                                <g transform="rotate(-90 90 90)">
                                    <circle cx="90" cy="90" r="70" fill="none" stroke="#2563EB" stroke-width="24"
                                        stroke-dasharray="<%= lenTec %> <%= circDonut %>" stroke-dashoffset="<%= offTec %>" />
                                    <circle cx="90" cy="90" r="70" fill="none" stroke="#10B981" stroke-width="24"
                                        stroke-dasharray="<%= lenSoc %> <%= circDonut %>" stroke-dashoffset="<%= offSoc %>" />
                                    <circle cx="90" cy="90" r="70" fill="none" stroke="#7C3AED" stroke-width="24"
                                        stroke-dasharray="<%= lenCorp %> <%= circDonut %>" stroke-dashoffset="<%= offCorp %>" />
                                </g>
                            </svg>

                            <div style="flex:1;">
                                <div class="legend-item" style="cursor:pointer;" onclick="mudarView('eventos', document.querySelector('[data-view=eventos]')); filtrarEventosPorCategoria('tecCientifico');">
                                    <span class="legend-dot" style="background:#2563EB;"></span> TecCientifico <span class="pct"><%= pctTecCientifico %>% (<%= somaTecCientifico %>)</span>
                                </div>
                                <div class="legend-item" style="cursor:pointer;" onclick="mudarView('eventos', document.querySelector('[data-view=eventos]')); filtrarEventosPorCategoria('sociais');">
                                    <span class="legend-dot" style="background:#10B981;"></span> Sociais <span class="pct"><%= pctSociais %>% (<%= somaSociais %>)</span>
                                </div>
                                <div class="legend-item" style="cursor:pointer;" onclick="mudarView('eventos', document.querySelector('[data-view=eventos]')); filtrarEventosPorCategoria('corporativos');">
                                    <span class="legend-dot" style="background:#7C3AED;"></span> Corporativos <span class="pct"><%= pctCorporativos %>% (<%= somaCorporativos %>)</span>
                                </div>
                            </div>

                        </div>
                        <% } %>
                    </div>

                    <div class="panel-card">
                        <h3>Usuários por tipo de conta</h3>
                        <p class="hint">Distribuição atual (sem histórico — o banco não guarda data de criação do usuário)</p>

                        <div style="display:flex; flex-direction:column; gap:12px; margin-top:10px;">
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

                <div class="panel-card">
                    <div class="view-header" style="margin-bottom:14px;">
                        <h3 style="font-size:14px;">Eventos recentes</h3>
                        <button class="btn-outline" onclick="mudarView('eventos', document.querySelector('[data-view=eventos]'))">Ver todos</button>
                    </div>

                    <div class="table-wrap">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Evento</th><th>Categoria</th><th>Data</th><th>Capacidade</th>
                                    <th>Inscritos</th><th>Check-in</th><th>Ocupação</th><th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int mostradosRecentes = 0;
                                    for (eventoModel ev : listaEventosAdmin) {
                                        if (mostradosRecentes >= 5) break;
                                        mostradosRecentes++;

                                        int confirmadosEv = confirmadosPorEventoAdmin.getOrDefault(ev.getId_evento(), 0);
                                        int checkinsEv = checkinsPorEventoAdmin.getOrDefault(ev.getId_evento(), 0);
                                        int ocupacaoEv = ev.getCapacidade_evento() > 0 ? (confirmadosEv * 100 / ev.getCapacidade_evento()) : 0;
                                        String nomeOrg = nomeOrganizadorPorId.getOrDefault(ev.getId_organizador(), "—");
                                        String statusClasseEv = "ativo".equals(ev.getStatus_evento()) ? "" : ev.getStatus_evento();
                                %>
                                <tr>
                                    <td><strong><%= ev.getNome_evento() %></strong><br><span style="color:#94A3B8;font-size:11px;"><%= nomeOrg %></span></td>
                                    <td><%= rotuloCategoriaEvento(ev.getCategoria_evento()) %></td>
                                    <td><%= ev.getInicio_evento().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) %></td>
                                    <td><%= ev.getCapacidade_evento() %></td>
                                    <td><%= confirmadosEv %> (<%= ocupacaoEv %>%)</td>
                                    <td><%= checkinsEv %></td>
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

            <!-- ============================================================
                 VIEW: EVENTOS (TODOS)
            ============================================================ -->
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
                        <option value="tecCientifico">TecCientifico</option>
                        <option value="corporativos">Corporativos</option>
                        <option value="sociais">Sociais</option>
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
                                data-busca="<%= js(ev.getNome_evento()).toLowerCase() %> <%= js(nomeOrgT).toLowerCase() %>">
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

            <!-- ============================================================
                 VIEW: USUÁRIOS
            ============================================================ -->
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

        </main>

    </div>


</div>

<script>

    // =========================================================
    // NAVEGAÇÃO ENTRE SUB-VIEWS
    // =========================================================

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

    // =========================================================
    // EVENTOS (ADMIN) — filtro por busca/status/categoria
    // =========================================================

    function filtrarEventosAdmin() {
        const busca = document.getElementById('buscaEventoAdmin').value.toLowerCase();
        const status = document.getElementById('filtroStatusAdmin').value;
        const categoria = document.getElementById('filtroCategoriaAdmin').value;

        document.querySelectorAll('#corpoEventosAdmin tr[data-status]').forEach(function (row) {
            const okBusca = busca === '' || (row.dataset.busca || '').includes(busca);
            const okStatus = status === '' || row.dataset.status === status;
            const okCategoria = categoria === '' || row.dataset.categoria === categoria;
            row.style.display = (okBusca && okStatus && okCategoria) ? '' : 'none';
        });
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

    // =========================================================
    // USUÁRIOS (dados reais, vindos do usuarioDAO)
    // =========================================================

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

    // =========================================================
    // DETALHES DO USUÁRIO (modal)
    // =========================================================

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

<!-- ================= MODAL: DETALHES DO USUÁRIO ================= -->
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
