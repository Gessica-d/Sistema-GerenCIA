<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="br.com.gerencia.model.usuarioModel"%>
<%
    // ================= GUARDA DE SESSÃO =================
    usuarioModel usuarioLogado = (usuarioModel) session.getAttribute("usuarioLogado");

    if (usuarioLogado == null) {
        response.sendRedirect(request.getContextPath() + "/pages/loginUsuario.jsp");
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
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GerenCIA - Início</title>

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
        grid-template-columns: 240px 1fr;
        min-height: 100vh;
    }

    /* ================= SIDEBAR ================= */

    .sidebar {
        background: #FFFFFF;
        border-right: 1px solid #E2E8F0;
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
    }

    .sidebar-logo-icon {
        width: 34px;
        height: 34px;
        border-radius: 9px;
        background: linear-gradient(135deg, #2563EB, #7C3AED);
        color: #FFFFFF;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
    }

    .sidebar-logo span {
        font-size: 16px;
        font-weight: 700;
    }

    .nav-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 12px;
        border-radius: 9px;
        font-size: 14px;
        font-weight: 500;
        color: #475569;
        margin-bottom: 2px;
        border: none;
        background: none;
        width: 100%;
        text-align: left;
    }

    .nav-item .nav-icon { font-size: 15px; width: 18px; text-align: center; }

    .nav-item .nav-label { flex: 1; }

    .nav-item .nav-badge {
        min-width: 18px;
        height: 18px;
        padding: 0 5px;
        border-radius: 9px;
        background: #EF4444;
        color: #FFFFFF;
        font-size: 10px;
        font-weight: 700;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .nav-item .nav-badge.blue { background: #2563EB; }

    .nav-item:hover { background: #F1F5F9; }

    .nav-item.active {
        background: #EFF6FF;
        color: #2563EB;
    }

    .sidebar-footer {
        margin-top: auto;
        padding-top: 14px;
        border-top: 1px solid #E2E8F0;
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 14px 8px 6px;
    }

    .avatar {
        width: 34px;
        height: 34px;
        border-radius: 50%;
        background: linear-gradient(135deg, #2563EB, #7C3AED);
        color: #FFFFFF;
        font-size: 12px;
        font-weight: 700;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }

    .sidebar-footer strong { display: block; font-size: 13px; }
    .sidebar-footer small { display: block; font-size: 11px; color: #94A3B8; }

    .logout-btn {
        margin-left: auto;
        font-size: 15px;
        color: #94A3B8;
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
        gap: 18px;
        padding: 0 28px;
        position: sticky;
        top: 0;
        z-index: 5;
    }

    .search-box {
        flex: 1;
        max-width: 420px;
        display: flex;
        align-items: center;
        gap: 8px;
        height: 40px;
        padding: 0 14px;
        border-radius: 9px;
        background: #F1F5F9;
        color: #94A3B8;
        font-size: 13px;
    }

    .search-box input {
        border: none;
        background: none;
        outline: none;
        font-size: 13px;
        flex: 1;
        color: #0F172A;
    }

    .topbar-actions {
        margin-left: auto;
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .bell {
        position: relative;
        font-size: 17px;
        color: #64748B;
    }

    .bell .dot {
        position: absolute;
        top: -2px;
        right: -2px;
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: #EF4444;
        border: 2px solid #FFFFFF;
    }

    .topbar-user {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        font-weight: 600;
    }

    /* ================= CONTEÚDO ================= */

    .content {
        padding: 28px;
        max-width: 1280px;
    }

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

    /* ================= BANNER (Início) ================= */

    .hero-banner {
        border-radius: 16px;
        padding: 30px 32px;
        margin-bottom: 22px;
        background: linear-gradient(120deg, #4C1D95, #2563EB);
        color: #FFFFFF;
        position: relative;
        overflow: hidden;
    }

    .hero-banner::after {
        content: "";
        position: absolute;
        inset: 0;
        background: radial-gradient(circle at 90% 20%, rgba(255,255,255,0.14), transparent 55%);
    }

    .hero-badge {
        z-index: 1;
        position: relative;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 5px 11px;
        border-radius: 20px;
        background: rgba(255,255,255,0.16);
        font-size: 11px;
        font-weight: 600;
        margin-bottom: 10px;
    }

    .hero-banner h2 { position: relative; z-index: 1; font-size: 24px; margin-bottom: 6px; }
    .hero-banner p { position: relative; z-index: 1; font-size: 13px; color: #DBEAFE; }

    /* ================= FILTRO CATEGORIA (pills) ================= */

    .category-pills {
        display: flex;
        gap: 8px;
        margin-bottom: 22px;
        flex-wrap: wrap;
    }

    .pill {
        height: 34px;
        padding: 0 16px;
        border-radius: 20px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
        font-size: 13px;
        font-weight: 500;
        color: #475569;
    }

    .pill.active {
        background: #2563EB;
        border-color: #2563EB;
        color: #FFFFFF;
    }

    /* ================= LAYOUT DUAS COLUNAS (Início) ================= */

    .two-col {
        display: grid;
        grid-template-columns: 1fr 300px;
        gap: 22px;
        align-items: start;
    }

    /* ================= GRID DE EVENTOS ================= */

    .events-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
        gap: 16px;
    }

    .event-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        overflow: hidden;
    }

    .event-card .thumb {
        height: 120px;
        background-size: cover;
        background-position: center;
        position: relative;
    }

    .event-card .thumb .tag-lotado {
        position: absolute;
        top: 10px;
        left: 10px;
        background: #EF4444;
        color: #FFFFFF;
        font-size: 10px;
        font-weight: 700;
        padding: 3px 8px;
        border-radius: 5px;
    }

    .fav-btn {
        position: absolute;
        top: 10px;
        right: 10px;
        width: 28px;
        height: 28px;
        border-radius: 50%;
        border: none;
        background: rgba(255,255,255,0.92);
        font-size: 13px;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .fav-btn.active { color: #EF4444; }

    .event-card .body { padding: 14px; }

    .event-card .row-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 8px;
    }

    .cat-tag {
        font-size: 11px;
        font-weight: 600;
        color: #2563EB;
        background: #EFF6FF;
        padding: 3px 8px;
        border-radius: 6px;
    }

    .price-tag { font-size: 13px; font-weight: 700; }

    .event-card h3 { font-size: 14px; margin-bottom: 6px; }

    .event-meta {
        font-size: 12px;
        color: #94A3B8;
        margin-bottom: 4px;
    }

    .capacity-bar {
        height: 5px;
        border-radius: 3px;
        background: #E2E8F0;
        margin: 10px 0 12px;
        overflow: hidden;
    }

    .capacity-bar span {
        display: block;
        height: 100%;
        background: #2563EB;
    }

    .capacity-bar.full span { background: #EF4444; }

    .event-card .actions {
        display: flex;
        gap: 8px;
    }

    .event-card .actions .btn-outline,
    .event-card .actions .btn-solid {
        flex: 1;
        justify-content: center;
        height: 34px;
        font-size: 12px;
    }

    /* ================= CARDS LATERAIS (Início) ================= */

    .side-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 16px;
        margin-bottom: 16px;
    }

    .side-card h4 {
        font-size: 13px;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .side-item {
        display: flex;
        gap: 10px;
        padding: 8px 0;
        border-bottom: 1px solid #F1F5F9;
    }

    .side-item:last-child { border-bottom: none; }

    .side-item .date-box {
        width: 38px;
        height: 38px;
        border-radius: 8px;
        background: #EFF6FF;
        color: #2563EB;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        font-size: 10px;
        font-weight: 700;
        flex-shrink: 0;
    }

    .side-item .info strong { display: block; font-size: 12px; }
    .side-item .info span { font-size: 11px; color: #94A3B8; }

    .status-chip {
        font-size: 10px;
        font-weight: 600;
        padding: 2px 7px;
        border-radius: 5px;
        background: #DCFCE7;
        color: #166534;
        display: inline-block;
        margin-top: 3px;
    }

    /* ================= LISTAS (Meus Eventos / Histórico) ================= */

    .list-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 16px 18px;
        display: flex;
        align-items: center;
        gap: 14px;
        margin-bottom: 12px;
    }

    .list-card .thumb-sm {
        width: 60px;
        height: 60px;
        border-radius: 9px;
        background-size: cover;
        background-position: center;
        flex-shrink: 0;
    }

    .list-card .info { flex: 1; }
    .list-card .info strong { font-size: 14px; }
    .list-card .info .meta { font-size: 12px; color: #94A3B8; margin-top: 3px; }

    .list-card .actions { display: flex; gap: 8px; align-items: center; }

    .badge-status {
        font-size: 11px;
        font-weight: 600;
        padding: 4px 9px;
        border-radius: 6px;
    }

    .badge-status.confirmada { background: #DCFCE7; color: #166534; }
    .badge-status.cancelada { background: #FEE2E2; color: #B91C1C; }
    .badge-status.participou { background: #DBEAFE; color: #1D4ED8; }
    .badge-status.checkin { background: #DCFCE7; color: #166534; }

    .btn-danger-outline {
        height: 34px;
        padding: 0 14px;
        border-radius: 8px;
        border: 1px solid #FCA5A5;
        background: #FFFFFF;
        color: #DC2626;
        font-size: 12px;
        font-weight: 600;
    }

    /* ================= PERFIL ================= */

    .profile-card {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 20px;
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 20px;
        max-width: 640px;
    }

    .profile-card .avatar { width: 60px; height: 60px; font-size: 18px; }
    .profile-card strong { display: block; font-size: 16px; }
    .profile-card span.sub { font-size: 12px; color: #94A3B8; }

    .profile-form {
        background: #FFFFFF;
        border: 1px solid #E2E8F0;
        border-radius: 12px;
        padding: 22px;
        max-width: 640px;
    }

    .field { margin-bottom: 16px; }

    .field label {
        display: block;
        font-size: 13px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 6px;
    }

    .field input,
    .field textarea {
        width: 100%;
        padding: 10px 12px;
        border: 1px solid #E2E8F0;
        border-radius: 8px;
        font-size: 13px;
        font-family: inherit;
        background: #F8FAFC;
    }

    .field input:focus,
    .field textarea:focus {
        outline: none;
        border-color: #2563EB;
        background: #FFFFFF;
    }

    .fields-row-2 {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 14px;
    }

    .empty-state {
        text-align: center;
        padding: 50px 20px;
        color: #94A3B8;
        font-size: 13px;
    }

    @media (max-width: 900px) {
        .two-col { grid-template-columns: 1fr; }
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
            <div class="sidebar-logo-icon">📅</div>
            <span>GerenCIA</span>
        </div>

        <button class="nav-item active" data-view="inicio" onclick="mudarView('inicio', this)">
            <span class="nav-icon">🏠</span>
            <span class="nav-label">Início</span>
        </button>

        <button class="nav-item" data-view="eventos" onclick="mudarView('eventos', this)">
            <span class="nav-icon">📅</span>
            <span class="nav-label">Eventos</span>
        </button>

        <button class="nav-item" data-view="favoritos" onclick="mudarView('favoritos', this)">
            <span class="nav-icon">♡</span>
            <span class="nav-label">Favoritos</span>
            <span class="nav-badge">3</span>
        </button>

        <button class="nav-item" data-view="meus-eventos" onclick="mudarView('meus-eventos', this)">
            <span class="nav-icon">📋</span>
            <span class="nav-label">Meus Eventos</span>
            <span class="nav-badge blue">2</span>
        </button>

        <button class="nav-item" data-view="historico" onclick="mudarView('historico', this)">
            <span class="nav-icon">🕐</span>
            <span class="nav-label">Histórico</span>
        </button>

        <button class="nav-item" data-view="perfil" onclick="mudarView('perfil', this)">
            <span class="nav-icon">👤</span>
            <span class="nav-label">Meu Perfil</span>
        </button>

        <div class="sidebar-footer">
            <div class="avatar"><%= iniciais %></div>
            <div>
                <strong><%= nomeUsuario %></strong>
                <small><%= usuarioLogado.getEmail_usuario() %></small>
            </div>
            <a class="logout-btn" title="Sair"
               href="${pageContext.request.contextPath}/usuarioController?action=logout">↪</a>
        </div>

    </aside>

    <!-- ================= ÁREA PRINCIPAL ================= -->
    <div>

        <header class="topbar">

            <div class="search-box">
                🔍
                <input type="text" placeholder="Buscar eventos...">
            </div>

            <div class="topbar-actions">
                <div class="bell">🔔<span class="dot"></span></div>
                <div class="topbar-user">
                    <div class="avatar" style="width:30px;height:30px;font-size:11px;"><%= iniciais %></div>
                    <%= nomeUsuario %>
                </div>
            </div>

        </header>

        <main class="content">

            <!-- ============================================================
                 VIEW: INÍCIO
            ============================================================ -->
            <section class="view-section active" id="view-inicio">

                <div class="hero-banner">
                    <div class="hero-badge">⭐ Destaques da semana</div>
                    <h2>Descubra novos eventos</h2>
                    <p>Mais de 1.400 eventos disponíveis para você</p>
                </div>

                <div class="category-pills">
                    <button class="pill active">Todos</button>
                    <button class="pill">Tecnologia</button>
                    <button class="pill">Design</button>
                    <button class="pill">Marketing</button>
                    <button class="pill">Negócios</button>
                    <button class="pill">Entretenimento</button>
                </div>

                <div class="two-col">

                    <div class="events-grid" id="grid-inicio">
                        <!-- cards inseridos via JS a partir do mock de eventos -->
                    </div>

                    <div>

                        <div class="side-card">
                            <h4>📅 Meus Próximos Eventos</h4>

                            <div class="side-item">
                                <div class="date-box"><span>12</span><span>Set</span></div>
                                <div class="info">
                                    <strong>Expo Empreendedorismo</strong>
                                    <span>10:00 · Expoville, Curitiba, PR</span>
                                    <div class="status-chip">Confirmada</div>
                                </div>
                            </div>

                            <div class="side-item">
                                <div class="date-box"><span>23</span><span>Jul</span></div>
                                <div class="info">
                                    <strong>Workshop Ágil na Prática</strong>
                                    <span>09:00 · Hub Inovação, São Paulo, SP</span>
                                    <div class="status-chip">Confirmada</div>
                                </div>
                            </div>
                        </div>

                        <div class="side-card">
                            <h4>♡ Favoritos</h4>

                            <div class="side-item">
                                <div class="info">
                                    <strong>Summit de Tecnologia 2025</strong>
                                    <span>15 Ago 2025</span>
                                </div>
                            </div>

                            <div class="side-item">
                                <div class="info">
                                    <strong>Hackathon de Inovação</strong>
                                    <span>05 Set 2025</span>
                                </div>
                            </div>

                            <div class="side-item">
                                <div class="info">
                                    <strong>DevConf Brasil 2025</strong>
                                    <span>10 Out 2025</span>
                                </div>
                            </div>
                        </div>

                        <div class="side-card">
                            <h4>🕐 Histórico recente</h4>

                            <div class="side-item">
                                <div class="info">
                                    <strong>Tech Summit ...</strong>
                                    <span>Jan 2024</span>
                                </div>
                            </div>
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
                        <h1>Explorar Eventos</h1>
                        <p id="contador-eventos">eventos encontrados</p>
                    </div>
                    <button class="btn-outline">⬇ Exportar Dados</button>
                </div>

                <div class="events-grid" id="grid-eventos"></div>

            </section>

            <!-- ============================================================
                 VIEW: FAVORITOS
            ============================================================ -->
            <section class="view-section" id="view-favoritos">

                <div class="view-header">
                    <div>
                        <h1>Meus Favoritos</h1>
                        <p id="contador-favoritos">eventos salvos</p>
                    </div>
                    <button class="btn-outline">⬇ Exportar Dados</button>
                </div>

                <div class="events-grid" id="grid-favoritos"></div>

            </section>

            <!-- ============================================================
                 VIEW: MEUS EVENTOS
            ============================================================ -->
            <section class="view-section" id="view-meus-eventos">

                <div class="view-header">
                    <div>
                        <h1>Meus Eventos</h1>
                        <p>Eventos em que você está inscrito ou na fila</p>
                    </div>
                    <button class="btn-outline">⬇ Exportar Dados</button>
                </div>

                <div class="list-card">
                    <div class="thumb-sm" style="background-image:url('https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=200&q=60')"></div>
                    <div class="info">
                        <strong>Expo Empreendedorismo</strong>
                        <span class="badge-status confirmada">Confirmada</span>
                        <div class="meta">📅 12 Set 2025 · 10:00 · 📍 Expoville, Curitiba, PR</div>
                        <div class="meta">Inscrito em 10/07/2025 · Pela plataforma</div>
                    </div>
                    <div class="actions">
                        <button class="btn-outline">📄 Comprovante</button>
                        <button class="btn-danger-outline">Cancelar</button>
                    </div>
                </div>

                <div class="list-card">
                    <div class="thumb-sm" style="background-image:url('https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=200&q=60')"></div>
                    <div class="info">
                        <strong>Workshop Ágil na Prática</strong>
                        <span class="badge-status confirmada">Confirmada</span>
                        <div class="meta">📅 23 Jul 2026 · 09:00 · 📍 Hub Inovação, São Paulo, SP</div>
                        <div class="meta">Inscrito em 20/07/2026 · Pela plataforma</div>
                    </div>
                    <div class="actions">
                        <button class="btn-outline">📄 Comprovante</button>
                        <button class="btn-danger-outline">Cancelar</button>
                    </div>
                </div>

            </section>

            <!-- ============================================================
                 VIEW: HISTÓRICO
            ============================================================ -->
            <section class="view-section" id="view-historico">

                <div class="view-header">
                    <div>
                        <h1>Histórico de Participação</h1>
                        <p>6 eventos registrados</p>
                    </div>
                    <button class="btn-outline">⬇ Exportar Dados</button>
                </div>

                <div class="list-card">
                    <div class="thumb-sm" style="background-image:url('https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=200&q=60')"></div>
                    <div class="info">
                        <strong>Tech Summit 2024</strong>
                        <div class="meta">Tecnologia · Jan 2024 · Expo Center Norte, São Paulo, SP</div>
                    </div>
                    <span class="badge-status checkin">✓ Check-in realizado</span>
                </div>

                <div class="list-card">
                    <div class="thumb-sm" style="background-image:url('https://images.unsplash.com/photo-1552664730-d307ca884978?w=200&q=60')"></div>
                    <div class="info">
                        <strong>Workshop React Avançado</strong>
                        <div class="meta">Tecnologia · Mar 2024 · Online</div>
                    </div>
                    <span class="badge-status participou">✓ Participou</span>
                </div>

                <div class="list-card">
                    <div class="thumb-sm" style="background-image:url('https://images.unsplash.com/photo-1531482615713-2afd69097998?w=200&q=60')"></div>
                    <div class="info">
                        <strong>DevConf 2024</strong>
                        <div class="meta">Tecnologia · Jun 2024 · Porto Alegre, RS</div>
                    </div>
                    <span class="badge-status cancelada">✕ Cancelado</span>
                </div>

                <div class="list-card">
                    <div class="thumb-sm" style="background-image:url('https://images.unsplash.com/photo-1591115765373-5207764f72e7?w=200&q=60')"></div>
                    <div class="info">
                        <strong>UX Week SP</strong>
                        <div class="meta">Design · Ago 2024 · São Paulo, SP</div>
                    </div>
                    <span class="badge-status checkin">✓ Check-in realizado</span>
                </div>

                <div class="list-card">
                    <div class="thumb-sm" style="background-image:url('https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=200&q=60')"></div>
                    <div class="info">
                        <strong>Marketing Summit</strong>
                        <div class="meta">Marketing · Out 2024 · Rio de Janeiro, RJ</div>
                    </div>
                    <span class="badge-status participou">✓ Participou</span>
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

                <div class="profile-card">
                    <div class="avatar"><%= iniciais %></div>
                    <div>
                        <strong><%= nomeUsuario %></strong>
                        <span class="sub">CPF: <%= usuarioLogado.getCPF_usuario() %></span>
                    </div>
                </div>

                <form class="profile-form"
                      action="${pageContext.request.contextPath}/usuarioController"
                      method="post">

                    <input type="hidden" name="action" value="atualizar">
                    <input type="hidden" name="id_usuario" value="<%= usuarioLogado.getId_usuario() %>">

                    <div class="fields-row-2">
                        <div class="field">
                            <label for="p_nome">Nome completo</label>
                            <input type="text" id="p_nome" name="nome_usuario" value="<%= nomeUsuario %>">
                        </div>
                        <div class="field">
                            <label for="p_email">E-mail</label>
                            <input type="email" id="p_email" name="email_usuario" value="<%= usuarioLogado.getEmail_usuario() %>">
                        </div>
                    </div>

                    <div class="field">
                        <label for="p_tel">Telefone</label>
                        <input type="tel" id="p_tel" name="telefone" value="<%= usuarioLogado.getTelefone() %>">
                    </div>

                    <button type="submit" class="btn-solid">Salvar alterações</button>

                </form>

            </section>

        </main>

    </div>

</div>

<script>

    // =========================================================
    // NAVEGAÇÃO ENTRE SUB-VIEWS (sem trocar de página)
    // =========================================================

    function mudarView(viewId, botao) {

        document.querySelectorAll('.view-section').forEach(function (el) {
            el.classList.remove('active');
        });

        document.getElementById('view-' + viewId).classList.add('active');

        document.querySelectorAll('.nav-item').forEach(function (el) {
            el.classList.remove('active');
        });

        botao.classList.add('active');
    }

    // =========================================================
    // MOCK DE EVENTOS
    // (substituir por dados vindos do eventoController quando integrar)
    // =========================================================

    const mockEventos = [
        {
            id: 1,
            nome: "Summit de Tecnologia 2025",
            categoria: "Tecnologia",
            preco: "R$ 299",
            imagem: "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400&q=60",
            local: "Expo Center Norte, São Paulo, SP",
            data: "15 Ago 2025 · 09:00",
            ocupacao: 60,
            lotado: false,
            favorito: true
        },
        {
            id: 2,
            nome: "Workshop de UX Design",
            categoria: "Design",
            preco: "R$ 149",
            imagem: "https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&q=60",
            local: "Online (Zoom)",
            data: "22 Ago 2025 · 14:00",
            ocupacao: 100,
            lotado: true,
            favorito: false
        },
        {
            id: 3,
            nome: "Conferência de Marketing Digital",
            categoria: "Marketing",
            preco: "Gratuito",
            imagem: "https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=400&q=60",
            local: "Centro de Convenções, Rio de Janeiro, RJ",
            data: "30 Ago 2025 · 08:30",
            ocupacao: 20,
            lotado: false,
            favorito: false
        },
        {
            id: 4,
            nome: "Hackathon de Inovação",
            categoria: "Tecnologia",
            preco: "R$ 89",
            imagem: "https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=400&q=60",
            local: "HUB BH, Belo Horizonte, MG",
            data: "05 Set 2025 · 18:00",
            ocupacao: 40,
            lotado: false,
            favorito: true
        },
        {
            id: 5,
            nome: "DevConf Brasil 2025",
            categoria: "Tecnologia",
            preco: "R$ 180",
            imagem: "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=400&q=60",
            local: "PUCRS, Porto Alegre, RS",
            data: "10 Out 2025 · 08:00",
            ocupacao: 35,
            lotado: false,
            favorito: true
        },
        {
            id: 6,
            nome: "UX Week SP",
            categoria: "Design",
            preco: "R$ 120",
            imagem: "https://images.unsplash.com/photo-1591115765373-5207764f72e7?w=400&q=60",
            local: "São Paulo, SP",
            data: "18 Nov 2025 · 09:00",
            ocupacao: 55,
            lotado: false,
            favorito: false
        }
    ];

    function criarCardEvento(ev) {

        const barraClasse = ev.lotado ? 'capacity-bar full' : 'capacity-bar';
        const favClasse = ev.favorito ? 'fav-btn active' : 'fav-btn';
        const coracao = ev.favorito ? '♥' : '♡';
        const botaoAcao = ev.lotado
            ? '<button class="btn-outline">Entrar na fila</button>'
            : '<button class="btn-solid">Inscrever-se</button>';

        return `
            <div class="event-card" data-categoria="${ev.categoria}" data-id="${ev.id}">
                <div class="thumb" style="background-image:url('${ev.imagem}')">
                    ${ev.lotado ? '<span class="tag-lotado">Lotado</span>' : ''}
                    <button class="${favClasse}" onclick="alternarFavorito(${ev.id}, this)">${coracao}</button>
                </div>
                <div class="body">
                    <div class="row-top">
                        <span class="cat-tag">${ev.categoria}</span>
                        <span class="price-tag">${ev.preco}</span>
                    </div>
                    <h3>${ev.nome}</h3>
                    <div class="event-meta">📍 ${ev.local}</div>
                    <div class="event-meta">📅 ${ev.data}</div>
                    <div class="${barraClasse}"><span style="width:${ev.ocupacao}%"></span></div>
                    <div class="actions">
                        <button class="btn-outline">Ver Detalhes</button>
                        ${botaoAcao}
                    </div>
                </div>
            </div>
        `;
    }

    function alternarFavorito(id, botao) {
        // Alternância apenas visual por enquanto.
        // Ao integrar, chamar favoritoController (action=adicionar/remover) aqui.
        const ev = mockEventos.find(e => e.id === id);
        ev.favorito = !ev.favorito;
        botao.classList.toggle('active');
        botao.textContent = ev.favorito ? '♥' : '♡';
    }

    function renderizarGrid(containerId, lista) {
        document.getElementById(containerId).innerHTML =
            lista.map(criarCardEvento).join('');
    }

    // Início: mostra os 3 primeiros
    renderizarGrid('grid-inicio', mockEventos.slice(0, 3));

    // Eventos: mostra todos
    renderizarGrid('grid-eventos', mockEventos);
    document.getElementById('contador-eventos').textContent =
        mockEventos.length + ' eventos encontrados';

    // Favoritos: só os favoritados
    const favoritados = mockEventos.filter(e => e.favorito);
    renderizarGrid('grid-favoritos', favoritados);
    document.getElementById('contador-favoritos').textContent =
        favoritados.length + ' eventos salvos';

    // Filtro por categoria (pills) na view Início
    document.querySelectorAll('.category-pills .pill').forEach(function (pill) {
        pill.addEventListener('click', function () {
            document.querySelectorAll('.category-pills .pill').forEach(p => p.classList.remove('active'));
            pill.classList.add('active');

            const categoria = pill.textContent.trim();
            const filtrada = categoria === 'Todos'
                ? mockEventos
                : mockEventos.filter(e => e.categoria === categoria);

            renderizarGrid('grid-inicio', filtrada.slice(0, 6));
        });
    });

</script>

</body>
</html>