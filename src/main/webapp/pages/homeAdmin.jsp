<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="br.com.gerencia.model.usuarioModel"%>
<%@ page import="br.com.gerencia.dao.usuarioDAO"%>
<%@ page import="br.com.gerencia.utils.Conexao"%>
<%@ page import="java.util.List"%>
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

    // ================= MENSAGEM FLASH (ex: senha redefinida) =================
    String flashMsg = (String) session.getAttribute("flashMsg");
    if (flashMsg != null) {
        session.removeAttribute("flashMsg");
    }

    // ================= HELPER: rótulo de exibição do tipo_usuario =================
%>
<%!
    private String rotuloTipo(String tipo) {
        if ("organizador".equals(tipo)) return "Organizador";
        if ("admin".equals(tipo)) return "Admin";
        return "Cliente";
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

    body {
        font-family: 'Inter', Arial, Helvetica, sans-serif;
        color: #0F172A;
        background: #F8FAFC;
    }

    a { text-decoration: none; color: inherit; }
    button { font-family: inherit; cursor: pointer; }

    /* ================= LAYOUT GERAL ================= */

    .app {
        display: grid;
        grid-template-columns: 230px 1fr;
        min-height: 100vh;
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

    @media (max-width: 900px) {
        .dash-cols { grid-template-columns: 1fr; }
        .app { grid-template-columns: 1fr; }
        .sidebar { display: none; }
    }

</style>
</head>
<body>

<div class="app">

    <!-- ================= SIDEBAR ================= -->
    <aside class="sidebar">

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

        <button class="nav-item" data-view="categorias" onclick="mudarView('categorias', this)">
            <span class="nav-icon">🏷</span>
            <span class="nav-label">Categorias</span>
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

    <!-- ================= ÁREA PRINCIPAL ================= -->
    <div>

        <header class="topbar">
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
                        <strong>7</strong>
                        <span class="delta">↓ +12 este mês</span>
                    </div>

                    <div class="stat-card">
                        <div class="row-top">
                            <span class="label">Organizadores ativos</span>
                            <div class="stat-icon">🏢</div>
                        </div>
                        <strong>2</strong>
                        <span class="delta">↓ +3 este mês</span>
                    </div>

                    <div class="stat-card">
                        <div class="row-top">
                            <span class="label">Eventos na plataforma</span>
                            <div class="stat-icon">📅</div>
                        </div>
                        <strong>6</strong>
                        <span class="delta">↓ +5 esta semana</span>
                    </div>

                    <div class="stat-card">
                        <div class="row-top">
                            <span class="label">Total de inscrições</span>
                            <div class="stat-icon">📈</div>
                        </div>
                        <strong>1.240</strong>
                        <span class="delta">↓ +148 esta semana</span>
                    </div>

                </div>

                <div class="dash-cols">

                    <div class="panel-card">
                        <h3>Eventos por categoria</h3>
                        <p class="hint">Clique em uma fatia para filtrar eventos</p>

                        <div class="donut-wrap">

                            <svg viewBox="0 0 180 180" width="150" height="150">
                                <g transform="rotate(-90 90 90)">
                                    <circle cx="90" cy="90" r="70" fill="none" stroke="#2563EB" stroke-width="24"
                                        stroke-dasharray="167.13 439.82" stroke-dashoffset="0" />
                                    <circle cx="90" cy="90" r="70" fill="none" stroke="#7C3AED" stroke-width="24"
                                        stroke-dasharray="118.75 439.82" stroke-dashoffset="-167.13" />
                                    <circle cx="90" cy="90" r="70" fill="none" stroke="#10B981" stroke-width="24"
                                        stroke-dasharray="83.57 439.82" stroke-dashoffset="-285.88" />
                                    <circle cx="90" cy="90" r="70" fill="none" stroke="#F59E0B" stroke-width="24"
                                        stroke-dasharray="48.38 439.82" stroke-dashoffset="-369.45" />
                                    <circle cx="90" cy="90" r="70" fill="none" stroke="#94A3B8" stroke-width="24"
                                        stroke-dasharray="21.99 439.82" stroke-dashoffset="-417.83" />
                                </g>
                            </svg>

                            <div style="flex:1;">
                                <div class="legend-item"><span class="legend-dot" style="background:#2563EB;"></span> TecCientifico <span class="pct">38%</span></div>
                                <div class="legend-item"><span class="legend-dot" style="background:#7C3AED;"></span> Corporativas <span class="pct">27%</span></div>
                                <div class="legend-item"><span class="legend-dot" style="background:#10B981;"></span> Sociais <span class="pct">19%</span></div>
                                <div class="legend-item"><span class="legend-dot" style="background:#F59E0B;"></span> Entretenimento <span class="pct">11%</span></div>
                                <div class="legend-item"><span class="legend-dot" style="background:#94A3B8;"></span> Outros <span class="pct">5%</span></div>
                            </div>

                        </div>
                    </div>

                    <div class="panel-card">
                        <h3>Novas contas por período</h3>
                        <div class="chart-legend-line">
                            <span><span class="legend-line-dot" style="background:#2563EB;"></span> Clientes</span>
                            <span><span class="legend-line-dot" style="background:#7C3AED;"></span> Organizadores</span>
                        </div>

                        <svg viewBox="0 0 560 180" style="width:100%; height:180px;">
                            <polyline fill="none" stroke="#2563EB" stroke-width="2.5"
                                points="0,160 90,120 180,100 270,90 360,50 450,45 540,35" />
                            <polyline fill="none" stroke="#7C3AED" stroke-width="2.5"
                                points="0,168 90,165 180,158 270,160 360,150 450,152 540,148" />
                            <text x="0" y="178" font-size="10" fill="#94A3B8">Jan</text>
                            <text x="85" y="178" font-size="10" fill="#94A3B8">Fev</text>
                            <text x="175" y="178" font-size="10" fill="#94A3B8">Mar</text>
                            <text x="265" y="178" font-size="10" fill="#94A3B8">Abr</text>
                            <text x="355" y="178" font-size="10" fill="#94A3B8">Mai</text>
                            <text x="445" y="178" font-size="10" fill="#94A3B8">Jun</text>
                            <text x="525" y="178" font-size="10" fill="#94A3B8">Jul</text>
                        </svg>
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
                                    <th>Inscritos</th><th>Comparecimento</th><th>Ocupação</th><th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><strong>Summit de Tecnologia 2025</strong><br><span style="color:#94A3B8;font-size:11px;">TechCo Eventos</span></td>
                                    <td>TecCientifico</td><td>15 Ago 2025</td><td>200</td>
                                    <td>155 (78%)</td><td>128 (83%)</td><td>78%</td>
                                    <td><span class="status-pill">Ativo</span></td>
                                </tr>
                                <tr>
                                    <td><strong>Workshop de UX Design</strong><br><span style="color:#94A3B8;font-size:11px;">DesignLab BR</span></td>
                                    <td>Corporativas</td><td>22 Ago 2025</td><td>80</td>
                                    <td>80 (100%)</td><td>74 (93%)</td><td>100%</td>
                                    <td><span class="status-pill">Ativo</span></td>
                                </tr>
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
                        <p>6 eventos na plataforma</p>
                    </div>
                    <button class="btn-outline">⬇ Exportar</button>
                </div>

                <div class="filters-row">
                    <input class="search-input" type="text" placeholder="Buscar evento ou organizador...">
                    <select class="filter-select">
                        <option>Todos os status</option>
                        <option>Ativo</option>
                        <option>Rascunho</option>
                        <option>Cancelado</option>
                        <option>Finalizado</option>
                    </select>
                    <select class="filter-select">
                        <option>Todas as categorias</option>
                        <option>TecCientifico</option>
                        <option>Corporativas</option>
                        <option>Sociais</option>
                        <option>Entretenimento</option>
                    </select>
                </div>

                <div class="table-wrap">
                    <table class="data-table">
                        <thead>
                            <tr><th>Evento</th><th>Organizador</th><th>Categoria</th><th>Data</th><th>Status</th><th>Vagas</th></tr>
                        </thead>
                        <tbody>
                            <tr><td>Summit de Tecnologia 2025</td><td>TechCo Eventos</td><td>TecCientifico</td><td>15 Ago 2025</td><td><span class="status-pill">Ativo</span></td><td>155/200</td></tr>
                            <tr><td>Workshop de UX Design</td><td>DesignLab BR</td><td>Corporativas</td><td>22 Ago 2025</td><td><span class="status-pill">Ativo</span></td><td>80/80</td></tr>
                            <tr><td>Happy Hour Corporativo</td><td>Rafael Organizer</td><td>Sociais</td><td>10 Set 2025</td><td><span class="status-pill rascunho">Rascunho</span></td><td>0/50</td></tr>
                            <tr><td>Conferência de Inovação</td><td>TechCo Eventos</td><td>TecCientifico</td><td>01 Out 2025</td><td><span class="status-pill">Ativo</span></td><td>87/300</td></tr>
                            <tr><td>Expo Empreendedorismo</td><td>EventPro</td><td>Corporativas</td><td>12 Set 2025</td><td><span class="status-pill">Ativo</span></td><td>150/500</td></tr>
                            <tr><td>Festival de Música</td><td>VibeEvents</td><td>Entretenimento</td><td>20 Set 2025</td><td><span class="status-pill">Ativo</span></td><td>800/1000</td></tr>
                        </tbody>
                    </table>
                </div>

            </section>

            <!-- ============================================================
                 VIEW: CATEGORIAS
            ============================================================ -->
            <section class="view-section" id="view-categorias">

                <div class="view-header">
                    <div>
                        <h1>Categorias</h1>
                        <p>Distribuição de eventos por categoria</p>
                    </div>
                </div>

                <div class="note-box">
                    ⚠️ No banco atual, categoria é um campo fixo (ENUM) dentro da tabela <code>evento</code>, não uma tabela própria.
                    Esta tela mostra a distribuição para consulta; criar/editar categorias livremente exigiria uma tabela
                    <code>categoria</code> separada — posso montar essa migração se você quiser essa flexibilidade.
                </div>

                <div class="categorias-grid">

                    <div class="categoria-card">
                        <div class="top">
                            <strong>TecCientifico</strong>
                            <span class="dot" style="background:#2563EB;"></span>
                        </div>
                        <span class="count">38% dos eventos · 3 eventos</span>
                        <div class="bar"><span style="width:38%; background:#2563EB;"></span></div>
                    </div>

                    <div class="categoria-card">
                        <div class="top">
                            <strong>Corporativas</strong>
                            <span class="dot" style="background:#7C3AED;"></span>
                        </div>
                        <span class="count">27% dos eventos · 2 eventos</span>
                        <div class="bar"><span style="width:27%; background:#7C3AED;"></span></div>
                    </div>

                    <div class="categoria-card">
                        <div class="top">
                            <strong>Sociais</strong>
                            <span class="dot" style="background:#10B981;"></span>
                        </div>
                        <span class="count">19% dos eventos · 1 evento</span>
                        <div class="bar"><span style="width:19%; background:#10B981;"></span></div>
                    </div>

                    <div class="categoria-card">
                        <div class="top">
                            <strong>Entretenimento</strong>
                            <span class="dot" style="background:#F59E0B;"></span>
                        </div>
                        <span class="count">11% dos eventos · 1 evento</span>
                        <div class="bar"><span style="width:11%; background:#F59E0B;"></span></div>
                    </div>

                    <div class="categoria-card">
                        <div class="top">
                            <strong>Outros</strong>
                            <span class="dot" style="background:#94A3B8;"></span>
                        </div>
                        <span class="count">5% dos eventos</span>
                        <div class="bar"><span style="width:5%; background:#94A3B8;"></span></div>
                    </div>

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
                    ⚠️ O toggle Ativo/Inativo abaixo é apenas visual — a tabela <code>usuario</code> ainda não tem uma coluna de status.
                    "Criado em" e "Eventos" também não existem no schema atual (não há data de criação nem contagem de eventos por usuário).
                    Se quiser essas funcionalidades de verdade, ajustamos o banco.
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
                            <tr><th>Usuário</th><th>Tipo</th><th>Criado em</th><th>Eventos</th><th>Status</th><th>Ações</th></tr>
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
        botao.classList.add('active');
    }

    // =========================================================
    // USUÁRIOS (dados reais, vindos do usuarioDAO)
    // =========================================================

    const usuarios = [
        <%
            for (usuarioModel u : listaUsuarios) {
                String nomeEsc = u.getNome_usuario() == null ? "" : u.getNome_usuario().replace("\\", "\\\\").replace("'", "\\'");
                String emailEsc = u.getEmail_usuario() == null ? "" : u.getEmail_usuario().replace("\\", "\\\\").replace("'", "\\'");
        %>
        {
            id: <%= u.getId_usuario() %>,
            nome: '<%= nomeEsc %>',
            email: '<%= emailEsc %>',
            tipo: '<%= rotuloTipo(u.getTipo_usuario()) %>'
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
            <tr>
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
                <td>—</td>
                <td>—</td>
                <td><span class="status-pill">Ativo</span></td>
                <td>
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

</script>

</body>
</html>
