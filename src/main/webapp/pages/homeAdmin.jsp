<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.time.LocalDateTime"%>
<%@ page import="java.time.format.DateTimeFormatter"%>

<%@ page import="br.com.gerencia.model.usuarioModel"%>
<%@ page import="br.com.gerencia.model.eventoModel"%>

<%
    /* ============================================================
       USUÁRIO LOGADO
       ============================================================ */

    usuarioModel usuarioLogado =
        (usuarioModel) session.getAttribute("usuarioLogado");

    if (usuarioLogado == null) {

        response.sendRedirect(
            request.getContextPath() + "/pages/loginUsuario.jsp"
        );

        return;
    }

    if (!"admin".equalsIgnoreCase(usuarioLogado.getTipo_usuario())) {

        response.sendRedirect(
            request.getContextPath() + "/pages/home.jsp"
        );

        return;
    }


    /* ============================================================
       DADOS REAIS VINDOS DO CONTROLLER
       ============================================================ */

    List<usuarioModel> listaUsuarios =
        (List<usuarioModel>) request.getAttribute("listaUsuarios");

    List<eventoModel> listaEventos =
        (List<eventoModel>) request.getAttribute("listaEventos");


    /*
     * Caso o controller não tenha enviado as listas,
     * usamos listas vazias.
     *
     * NÃO criamos dados fictícios.
     */

    if (listaUsuarios == null) {
        listaUsuarios = new ArrayList<usuarioModel>();
    }

    if (listaEventos == null) {
        listaEventos = new ArrayList<eventoModel>();
    }


    /* ============================================================
       DADOS DO ADMINISTRADOR LOGADO
       ============================================================ */

    String nomeUsuario = usuarioLogado.getNome_usuario();

    if (nomeUsuario == null || nomeUsuario.trim().isEmpty()) {
        nomeUsuario = "Administrador";
    }


    String iniciais = "?";

    String[] partesNome =
        nomeUsuario.trim().split("\\s+");

    if (partesNome.length > 1) {

        iniciais =
            ("" + partesNome[0].charAt(0)
            + partesNome[partesNome.length - 1].charAt(0))
            .toUpperCase();

    } else {

        iniciais =
            ("" + partesNome[0].charAt(0))
            .toUpperCase();
    }


    /* ============================================================
       ESTATÍSTICAS REAIS
       ============================================================ */

    int totalUsuarios =
        listaUsuarios.size();

    int totalEventos =
        listaEventos.size();


    int totalOrganizadores = 0;

    for (usuarioModel usuario : listaUsuarios) {

        if ("organizador".equalsIgnoreCase(
                usuario.getTipo_usuario())) {

            totalOrganizadores++;
        }
    }


    /*
     * Quantidade de eventos por categoria.
     * Os valores são calculados exclusivamente
     * a partir dos eventos encontrados no banco.
     */

    Map<String, Integer> eventosPorCategoria =
        new HashMap<String, Integer>();

    for (eventoModel evento : listaEventos) {

        String categoria =
            evento.getCategoria_evento();

        if (categoria == null ||
            categoria.trim().isEmpty()) {

            categoria = "Sem categoria";
        }

        Integer quantidade =
            eventosPorCategoria.get(categoria);

        if (quantidade == null) {
            quantidade = 0;
        }

        eventosPorCategoria.put(
            categoria,
            quantidade + 1
        );
    }


    /* ============================================================
       FORMATADOR DE DATA
       ============================================================ */

    DateTimeFormatter formatoData =
        DateTimeFormatter.ofPattern("dd/MM/yyyy");

%>


<!DOCTYPE html>

<html lang="pt-BR">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>GerenCIA - Painel Administrativo</title>


<style>

/* ============================================================
   RESET
   ============================================================ */

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}


body {

    font-family:
        Arial,
        Helvetica,
        sans-serif;

    color: #0F172A;

    background: #F8FAFC;
}


a {

    text-decoration: none;

    color: inherit;
}


button {

    font-family: inherit;

    cursor: pointer;
}


/* ============================================================
   LAYOUT
   ============================================================ */

.app {

    display: grid;

    grid-template-columns: 230px 1fr;

    min-height: 100vh;
}


/* ============================================================
   SIDEBAR
   ============================================================ */

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

    padding:
        6px 8px 22px;

    color: #FFFFFF;
}


.sidebar-logo-icon {

    width: 34px;

    height: 34px;

    border-radius: 9px;

    background:
        linear-gradient(
            135deg,
            #64748B,
            #1E293B
        );

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

    color: #94A3B8;

    margin-bottom: 2px;

    border: none;

    background: none;

    width: 100%;

    text-align: left;
}


.nav-item:hover {

    background: #1E293B;

    color: #E2E8F0;
}


.nav-item.active {

    background: #1E293B;

    color: #FFFFFF;
}


.nav-icon {

    width: 18px;

    text-align: center;
}


.nav-label {

    flex: 1;
}


/* ============================================================
   SIDEBAR FOOTER
   ============================================================ */

.sidebar-footer {

    margin-top: auto;

    padding-top: 14px;

    border-top:
        1px solid #1E293B;

    display: flex;

    align-items: center;

    gap: 10px;

    padding:
        14px 8px 6px;
}


.avatar {

    width: 34px;

    height: 34px;

    border-radius: 50%;

    background:
        linear-gradient(
            135deg,
            #64748B,
            #1E293B
        );

    color: #FFFFFF;

    font-size: 12px;

    font-weight: 700;

    display: flex;

    align-items: center;

    justify-content: center;

    flex-shrink: 0;
}


.sidebar-footer strong {

    display: block;

    font-size: 13px;

    color: #F1F5F9;
}


.sidebar-footer small {

    display: block;

    font-size: 11px;

    color: #64748B;
}


.logout-btn {

    margin-left: auto;

    font-size: 15px;

    color: #64748B;

    background: none;

    border: none;
}


/* ============================================================
   TOPBAR
   ============================================================ */

.topbar {

    height: 64px;

    background: #FFFFFF;

    border-bottom:
        1px solid #E2E8F0;

    display: flex;

    align-items: center;

    padding: 0 28px;

    position: sticky;

    top: 0;

    z-index: 5;
}


.topbar-title strong {

    display: block;

    font-size: 14px;
}


.topbar-title span {

    display: block;

    font-size: 11px;

    color: #94A3B8;
}


.topbar-user {

    margin-left: auto;

    display: flex;

    align-items: center;

    gap: 10px;

    font-size: 13px;

    font-weight: 600;
}


/* ============================================================
   CONTEÚDO
   ============================================================ */

.content {

    padding: 28px;

    max-width: 1400px;
}


.view-section {

    display: none;
}


.view-section.active {

    display: block;
}


.view-header {

    display: flex;

    align-items: flex-end;

    justify-content: space-between;

    margin-bottom: 20px;

    gap: 16px;

    flex-wrap: wrap;
}


.view-header h1 {

    font-size: 22px;
}


.view-header p {

    color: #64748B;

    font-size: 13px;

    margin-top: 4px;
}


/* ============================================================
   BOTÕES
   ============================================================ */

.header-actions {

    display: flex;

    gap: 10px;
}


.btn-outline {

    display: inline-flex;

    align-items: center;

    gap: 6px;

    height: 38px;

    padding: 0 16px;

    border-radius: 8px;

    border:
        1px solid #E2E8F0;

    background: #FFFFFF;

    font-size: 13px;

    font-weight: 600;

    color: #334155;
}


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


/* ============================================================
   CARDS DE ESTATÍSTICAS
   ============================================================ */

.stats-grid {

    display: grid;

    grid-template-columns:
        repeat(
            auto-fit,
            minmax(220px, 1fr)
        );

    gap: 16px;

    margin-bottom: 20px;
}


.stat-card {

    background: #FFFFFF;

    border:
        1px solid #E2E8F0;

    border-radius: 12px;

    padding: 18px;
}


.stat-card .row-top {

    display: flex;

    align-items: center;

    justify-content: space-between;

    margin-bottom: 14px;
}


.stat-card .label {

    font-size: 13px;

    color: #64748B;
}


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


.stat-card strong {

    font-size: 26px;

    display: block;

    margin-bottom: 4px;
}


.stat-card .delta {

    font-size: 11px;

    color: #94A3B8;
}


/* ============================================================
   PAINÉIS
   ============================================================ */

.dash-cols {

    display: grid;

    grid-template-columns:
        1fr 1fr;

    gap: 16px;

    margin-bottom: 20px;

    align-items: start;
}


.panel-card {

    background: #FFFFFF;

    border:
        1px solid #E2E8F0;

    border-radius: 12px;

    padding: 20px;

    margin-bottom: 20px;
}


.panel-card h3 {

    font-size: 14px;

    margin-bottom: 4px;
}


.hint {

    font-size: 11px;

    color: #94A3B8;

    margin-bottom: 16px;
}


/* ============================================================
   TABELAS
   ============================================================ */

.table-wrap {

    overflow-x: auto;
}


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

    border-bottom:
        1px solid #E2E8F0;

    white-space: nowrap;
}


table.data-table td {

    padding: 12px 8px;

    border-bottom:
        1px solid #F1F5F9;

    white-space: nowrap;
}


/* ============================================================
   STATUS
   ============================================================ */

.status-pill {

    font-size: 11px;

    font-weight: 600;

    padding: 3px 9px;

    border-radius: 6px;

    background: #DCFCE7;

    color: #166534;
}


.status-pill.rascunho {

    background: #F1F5F9;

    color: #64748B;
}


.status-pill.cancelado {

    background: #FEE2E2;

    color: #B91C1C;
}


.status-pill.finalizado {

    background: #E0E7FF;

    color: #3730A3;
}


/* ============================================================
   TIPO USUÁRIO
   ============================================================ */

.type-pill {

    font-size: 11px;

    font-weight: 600;

    padding: 3px 9px;

    border-radius: 6px;
}


.type-pill.cliente {

    background: #EFF6FF;

    color: #1D4ED8;
}


.type-pill.organizador {

    background: #F5F3FF;

    color: #7C3AED;
}


.type-pill.admin {

    background: #FEF2F2;

    color: #B91C1C;
}


/* ============================================================
   FILTROS
   ============================================================ */

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

    border:
        1px solid #E2E8F0;

    font-size: 13px;
}


.filter-select {

    height: 38px;

    padding: 0 10px;

    border-radius: 8px;

    border:
        1px solid #E2E8F0;

    font-size: 13px;

    background: #FFFFFF;

    color: #334155;
}


/* ============================================================
   CATEGORIAS
   ============================================================ */

.categorias-grid {

    display: grid;

    grid-template-columns:
        repeat(
            auto-fit,
            minmax(220px, 1fr)
        );

    gap: 16px;
}


.categoria-card {

    background: #FFFFFF;

    border:
        1px solid #E2E8F0;

    border-radius: 12px;

    padding: 18px;
}


.categoria-card strong {

    font-size: 15px;

    display: block;
}


.categoria-card .count {

    font-size: 12px;

    color: #94A3B8;

    margin-top: 5px;

    display: block;
}


/* ============================================================
   AVISO
   ============================================================ */

.note-box {

    background: #FFFBEB;

    border:
        1px solid #FDE68A;

    color: #92400E;

    border-radius: 10px;

    padding: 12px 16px;

    font-size: 12px;

    margin-bottom: 20px;
}


/* ============================================================
   RESPONSIVO
   ============================================================ */

@media (max-width: 900px) {

    .dash-cols {

        grid-template-columns: 1fr;
    }

    .app {

        grid-template-columns: 1fr;
    }

    .sidebar {

        display: none;
    }
}

</style>

</head>


<body>


<div class="app">


<!-- ============================================================
     SIDEBAR
     ============================================================ -->

<aside class="sidebar">


    <div class="sidebar-logo">

        <div class="sidebar-logo-icon">
            📊
        </div>

        <span>Admin</span>

    </div>


    <button
        class="nav-item active"
        data-view="dashboard"
        onclick="mudarView('dashboard', this)">

        <span class="nav-icon">▦</span>

        <span class="nav-label">
            Dashboard
        </span>

    </button>


    <button
        class="nav-item"
        data-view="eventos"
        onclick="mudarView('eventos', this)">

        <span class="nav-icon">📅</span>

        <span class="nav-label">
            Eventos
        </span>

    </button>


    <button
        class="nav-item"
        data-view="categorias"
        onclick="mudarView('categorias', this)">

        <span class="nav-icon">🏷</span>

        <span class="nav-label">
            Categorias
        </span>

    </button>


    <button
        class="nav-item"
        data-view="usuarios"
        onclick="mudarView('usuarios', this)">

        <span class="nav-icon">👥</span>

        <span class="nav-label">
            Usuários
        </span>

    </button>


    <div class="sidebar-footer">

        <div class="avatar">
            <%= iniciais %>
        </div>

        <div>

            <strong>
                <%= nomeUsuario %>
            </strong>

            <small>
                Administrador
            </small>

        </div>

        <a
            class="logout-btn"
            title="Sair"
            href="<%= request.getContextPath() %>/usuarioController?action=logout">

            ↪

        </a>

    </div>


</aside>


<!-- ============================================================
     ÁREA PRINCIPAL
     ============================================================ -->

<div>


<header class="topbar">


    <div class="topbar-title">

        <strong>
            GerenCIA
        </strong>

        <span>
            Painel Administrativo
        </span>

    </div>


    <div class="topbar-user">

        <span>
            👁
        </span>

        <div
            class="avatar"
            style="width:30px;height:30px;font-size:11px;">

            <%= iniciais %>

        </div>

        <%= nomeUsuario %>

    </div>


</header>


<main class="content">


<!-- ============================================================
     DASHBOARD
     ============================================================ -->

<section
    class="view-section active"
    id="view-dashboard">


    <div class="view-header">

        <div>

            <h1>
                Dashboard Administrativo
            </h1>

            <p>
                Visão geral da plataforma
            </p>

        </div>

    </div>


    <!-- ========================================================
         ESTATÍSTICAS REAIS
         ======================================================== -->

    <div class="stats-grid">


        <div class="stat-card">

            <div class="row-top">

                <span class="label">
                    Total de usuários
                </span>

                <div class="stat-icon">
                    👥
                </div>

            </div>

            <strong>
                <%= totalUsuarios %>
            </strong>

            <span class="delta">
                Registros existentes no banco
            </span>

        </div>


        <div class="stat-card">

            <div class="row-top">

                <span class="label">
                    Organizadores
                </span>

                <div class="stat-icon">
                    🏢
                </div>

            </div>

            <strong>
                <%= totalOrganizadores %>
            </strong>

            <span class="delta">
                Usuários com tipo organizador
            </span>

        </div>


        <div class="stat-card">

            <div class="row-top">

                <span class="label">
                    Eventos na plataforma
                </span>

                <div class="stat-icon">
                    📅
                </div>

            </div>

            <strong>
                <%= totalEventos %>
            </strong>

            <span class="delta">
                Registros existentes no banco
            </span>

        </div>


        <div class="stat-card">

            <div class="row-top">

                <span class="label">
                    Categorias utilizadas
                </span>

                <div class="stat-icon">
                    🏷
                </div>

            </div>

            <strong>
                <%= eventosPorCategoria.size() %>
            </strong>

            <span class="delta">
                Categorias presentes nos eventos
            </span>

        </div>


    </div>


    <!-- ========================================================
         DUAS COLUNAS
         ======================================================== -->

    <div class="dash-cols">


        <!-- ====================================================
             CATEGORIAS
             ==================================================== -->

        <div class="panel-card">

            <h3>
                Eventos por categoria
            </h3>

            <p class="hint">
                Dados calculados a partir dos eventos cadastrados
            </p>


            <div>

                <%
                    if (eventosPorCategoria.isEmpty()) {
                %>

                    <p style="font-size:13px;color:#94A3B8;">
                        Nenhum evento cadastrado.
                    </p>

                <%
                    } else {

                        for (Map.Entry<String, Integer> entrada :
                             eventosPorCategoria.entrySet()) {

                            String categoria =
                                entrada.getKey();

                            int quantidade =
                                entrada.getValue();

                            int percentual = 0;

                            if (totalEventos > 0) {

                                percentual =
                                    (quantidade * 100)
                                    / totalEventos;
                            }
                %>


                    <div style="margin-bottom:18px;">

                        <div style="
                            display:flex;
                            justify-content:space-between;
                            margin-bottom:6px;
                            font-size:13px;">

                            <strong>
                                <%= categoria %>
                            </strong>

                            <span>
                                <%= quantidade %>
                                evento(s)
                                -
                                <%= percentual %>%
                            </span>

                        </div>


                        <div style="
                            height:7px;
                            background:#F1F5F9;
                            border-radius:5px;
                            overflow:hidden;">

                            <div style="
                                width:<%= percentual %>%;
                                height:100%;
                                background:#2563EB;">

                            </div>

                        </div>

                    </div>


                <%
                        }
                    }
                %>

            </div>

        </div>


        <!-- ====================================================
             INFORMAÇÕES
             ==================================================== -->

        <div class="panel-card">

            <h3>
                Resumo dos dados
            </h3>

            <p class="hint">
                Informações reais carregadas do banco de dados
            </p>


            <div style="display:flex;flex-direction:column;gap:15px;">


                <div style="
                    padding:14px;
                    background:#F8FAFC;
                    border-radius:8px;">

                    <strong>
                        Usuários
                    </strong>

                    <div style="
                        margin-top:5px;
                        color:#64748B;
                        font-size:12px;">

                        <%= totalUsuarios %>
                        usuário(s) cadastrado(s)

                    </div>

                </div>


                <div style="
                    padding:14px;
                    background:#F8FAFC;
                    border-radius:8px;">

                    <strong>
                        Organizadores
                    </strong>

                    <div style="
                        margin-top:5px;
                        color:#64748B;
                        font-size:12px;">

                        <%= totalOrganizadores %>
                        organizador(es) cadastrado(s)

                    </div>

                </div>


                <div style="
                    padding:14px;
                    background:#F8FAFC;
                    border-radius:8px;">

                    <strong>
                        Eventos
                    </strong>

                    <div style="
                        margin-top:5px;
                        color:#64748B;
                        font-size:12px;">

                        <%= totalEventos %>
                        evento(s) cadastrado(s)

                    </div>

                </div>


            </div>

        </div>


    </div>


    <!-- ========================================================
         EVENTOS RECENTES
         ======================================================== -->

    <div class="panel-card">


        <div class="view-header"
             style="margin-bottom:14px;">

            <div>

                <h3 style="font-size:14px;">
                    Eventos cadastrados
                </h3>

                <p>
                    Eventos existentes no banco de dados
                </p>

            </div>


            <button
                class="btn-outline"
                onclick="
                    mudarView(
                        'eventos',
                        document.querySelector('[data-view=eventos]')
                    )
                ">

                Ver todos

            </button>

        </div>


        <div class="table-wrap">


            <table class="data-table">


                <thead>

                    <tr>

                        <th>
                            Evento
                        </th>

                        <th>
                            Organizador
                        </th>

                        <th>
                            Categoria
                        </th>

                        <th>
                            Data
                        </th>

                        <th>
                            Status
                        </th>

                        <th>
                            Capacidade
                        </th>

                    </tr>

                </thead>


                <tbody>


                <%
                    if (listaEventos.isEmpty()) {
                %>

                    <tr>

                        <td
                            colspan="6"
                            style="
                                text-align:center;
                                color:#94A3B8;
                                padding:30px;">

                            Nenhum evento cadastrado.

                        </td>

                    </tr>

                <%
                    } else {

                        int limite =
                            Math.min(5, listaEventos.size());

                        for (int i = 0; i < limite; i++) {

                            eventoModel evento =
                                listaEventos.get(i);


                            String nomeOrganizador =
                                "Não encontrado";


                            /*
                             * Busca o organizador REAL
                             * através do id_organizador.
                             */

                            for (usuarioModel usuario :
                                 listaUsuarios) {

                                if (usuario.getId_usuario()
                                    == evento.getId_organizador()) {

                                    nomeOrganizador =
                                        usuario.getNome_usuario();

                                    break;
                                }
                            }


                            String dataEvento = "-";

                            if (evento.getInicio_evento() != null) {

                                dataEvento =
                                    evento
                                        .getInicio_evento()
                                        .format(formatoData);
                            }


                            String status =
                                evento.getStatus_evento();

                            if (status == null ||
                                status.trim().isEmpty()) {

                                status = "Não informado";
                            }


                            String classeStatus = "";

                            if ("rascunho".equalsIgnoreCase(status)) {

                                classeStatus = "rascunho";

                            } else if ("cancelado".equalsIgnoreCase(status)) {

                                classeStatus = "cancelado";

                            } else if ("finalizado".equalsIgnoreCase(status)) {

                                classeStatus = "finalizado";
                            }

                %>


                    <tr>


                        <td>

                            <strong>
                                <%= evento.getNome_evento() %>
                            </strong>

                        </td>


                        <td>
                            <%= nomeOrganizador %>
                        </td>


                        <td>
                            <%= evento.getCategoria_evento() != null
                                ? evento.getCategoria_evento()
                                : "-" %>
                        </td>


                        <td>
                            <%= dataEvento %>
                        </td>


                        <td>

                            <span class="status-pill <%= classeStatus %>">

                                <%= status %>

                            </span>

                        </td>


                        <td>
                            <%= evento.getCapacidade_evento() %>
                        </td>


                    </tr>


                <%
                        }
                    }
                %>


                </tbody>


            </table>


        </div>


    </div>


</section>


<!-- ============================================================
     EVENTOS
     ============================================================ -->

<section
    class="view-section"
    id="view-eventos">


    <div class="view-header">

        <div>

            <h1>
                Todos os Eventos
            </h1>

            <p>
                <%= totalEventos %>
                evento(s) na plataforma
            </p>

        </div>

    </div>


    <div class="filters-row">

        <input
            class="search-input"
            type="text"
            id="busca-evento"
            placeholder="Buscar evento ou organizador...">

    </div>


    <div class="table-wrap">


        <table class="data-table">


            <thead>

                <tr>

                    <th>
                        Evento
                    </th>

                    <th>
                        Organizador
                    </th>

                    <th>
                        Categoria
                    </th>

                    <th>
                        Data
                    </th>

                    <th>
                        Status
                    </th>

                    <th>
                        Capacidade
                    </th>

                </tr>

            </thead>


            <tbody id="corpo-eventos">


            <%
                if (listaEventos.isEmpty()) {
            %>

                <tr>

                    <td
                        colspan="6"
                        style="
                            text-align:center;
                            color:#94A3B8;
                            padding:30px;">

                        Nenhum evento cadastrado.

                    </td>

                </tr>

            <%
                } else {

                    for (eventoModel evento :
                         listaEventos) {


                        String nomeOrganizador =
                            "Não encontrado";


                        for (usuarioModel usuario :
                             listaUsuarios) {

                            if (usuario.getId_usuario()
                                == evento.getId_organizador()) {

                                nomeOrganizador =
                                    usuario.getNome_usuario();

                                break;
                            }
                        }


                        String dataEvento = "-";

                        if (evento.getInicio_evento() != null) {

                            dataEvento =
                                evento
                                    .getInicio_evento()
                                    .format(formatoData);
                        }


                        String status =
                            evento.getStatus_evento();

                        if (status == null ||
                            status.trim().isEmpty()) {

                            status = "Não informado";
                        }


                        String classeStatus = "";

                        if ("rascunho".equalsIgnoreCase(status)) {

                            classeStatus = "rascunho";

                        } else if ("cancelado".equalsIgnoreCase(status)) {

                            classeStatus = "cancelado";

                        } else if ("finalizado".equalsIgnoreCase(status)) {

                            classeStatus = "finalizado";
                        }

            %>


                <tr
                    data-busca-evento="
                        <%= evento.getNome_evento() %>
                        <%= nomeOrganizador %>
                    ">


                    <td>

                        <strong>
                            <%= evento.getNome_evento() %>
                        </strong>

                    </td>


                    <td>
                        <%= nomeOrganizador %>
                    </td>


                    <td>
                        <%= evento.getCategoria_evento() != null
                            ? evento.getCategoria_evento()
                            : "-" %>
                    </td>


                    <td>
                        <%= dataEvento %>
                    </td>


                    <td>

                        <span class="status-pill <%= classeStatus %>">

                            <%= status %>

                        </span>

                    </td>


                    <td>
                        <%= evento.getCapacidade_evento() %>
                    </td>


                </tr>


            <%
                    }
                }
            %>


            </tbody>


        </table>


    </div>


</section>


<!-- ============================================================
     CATEGORIAS
     ============================================================ -->

<section
    class="view-section"
    id="view-categorias">


    <div class="view-header">

        <div>

            <h1>
                Categorias
            </h1>

            <p>
                Distribuição real dos eventos cadastrados
            </p>

        </div>

    </div>


    <div class="categorias-grid">


    <%
        if (eventosPorCategoria.isEmpty()) {
    %>

        <div class="categoria-card">

            <strong>
                Nenhuma categoria
            </strong>

            <span class="count">
                Não existem eventos cadastrados.
            </span>

        </div>

    <%
        } else {

            for (Map.Entry<String, Integer> entrada :
                 eventosPorCategoria.entrySet()) {

                String categoria =
                    entrada.getKey();

                int quantidade =
                    entrada.getValue();

                int percentual = 0;

                if (totalEventos > 0) {

                    percentual =
                        (quantidade * 100)
                        / totalEventos;
                }
    %>


        <div class="categoria-card">


            <strong>
                <%= categoria %>
            </strong>


            <span class="count">

                <%= quantidade %>
                evento(s)

                -

                <%= percentual %>%

            </span>


            <div style="
                height:6px;
                border-radius:4px;
                background:#F1F5F9;
                margin-top:12px;
                overflow:hidden;">

                <div style="
                    width:<%= percentual %>%;
                    height:100%;
                    background:#2563EB;">

                </div>

            </div>


        </div>


    <%
            }
        }
    %>


    </div>


</section>


<!-- ============================================================
     USUÁRIOS
     ============================================================ -->

<section
    class="view-section"
    id="view-usuarios">


    <div class="view-header">


        <div>

            <h1>
                Usuários
            </h1>

            <p id="contador-usuarios">

                <%= totalUsuarios %>
                usuário(s) cadastrado(s)

            </p>

        </div>


    </div>


    <div class="note-box">

        A tabela de usuários não possui um campo
        <code>status_usuario</code>.
        Por isso, o sistema não inventa "Ativo" ou
        "Inativo".

    </div>


    <div class="filters-row">


        <input
            class="search-input"
            type="text"
            id="busca-usuario"
            placeholder="Buscar usuário...">


        <select
            class="filter-select"
            id="filtro-tipo">

            <option value="Todos">
                Todos os tipos
            </option>

            <option value="cliente">
                Cliente
            </option>

            <option value="organizador">
                Organizador
            </option>

            <option value="admin">
                Admin
            </option>

        </select>


    </div>


    <div class="table-wrap">


        <table class="data-table">


            <thead>

                <tr>

                    <th>
                        Usuário
                    </th>

                    <th>
                        CPF
                    </th>

                    <th>
                        Tipo
                    </th>

                    <th>
                        E-mail
                    </th>

                    <th>
                        Telefone
                    </th>

                    <th>
                        Eventos criados
                    </th>

                </tr>

            </thead>


            <tbody id="corpo-usuarios">


            <%
                if (listaUsuarios.isEmpty()) {
            %>


                <tr>

                    <td
                        colspan="6"
                        style="
                            text-align:center;
                            color:#94A3B8;
                            padding:30px;">

                        Nenhum usuário cadastrado.

                    </td>

                </tr>


            <%
                } else {

                    for (usuarioModel usuario :
                         listaUsuarios) {


                        int eventosCriados = 0;


                        /*
                         * Conta somente eventos reais cujo
                         * id_organizador pertence ao usuário.
                         */

                        for (eventoModel evento :
                             listaEventos) {

                            if (evento.getId_organizador()
                                == usuario.getId_usuario()) {

                                eventosCriados++;
                            }
                        }


                        String tipo =
                            usuario.getTipo_usuario();

                        if (tipo == null) {
                            tipo = "";
                        }


                        String classeTipo =
                            tipo.toLowerCase();

            %>


                <tr
                    data-nome="
                        <%= usuario.getNome_usuario() != null
                            ? usuario.getNome_usuario()
                            : "" %>"

                    data-email="
                        <%= usuario.getEmail_usuario() != null
                            ? usuario.getEmail_usuario()
                            : "" %>"

                    data-tipo="<%= classeTipo %>">


                    <td>

                        <div style="
                            display:flex;
                            align-items:center;
                            gap:10px;">


                            <div
                                class="avatar"
                                style="
                                    width:30px;
                                    height:30px;
                                    font-size:11px;">

                                <%
                                    String nome =
                                        usuario.getNome_usuario();

                                    String iniciaisUsuario = "?";

                                    if (nome != null &&
                                        !nome.trim().isEmpty()) {

                                        String[] partes =
                                            nome.trim()
                                                .split("\\s+");

                                        if (partes.length > 1) {

                                            iniciaisUsuario =
                                                ("" +
                                                partes[0].charAt(0) +
                                                partes[partes.length - 1].charAt(0))
                                                .toUpperCase();

                                        } else {

                                            iniciaisUsuario =
                                                ("" +
                                                partes[0].charAt(0))
                                                .toUpperCase();
                                        }
                                    }
                                %>

                                <%= iniciaisUsuario %>

                            </div>


                            <div>

                                <div style="font-weight:600;">

                                    <%= usuario.getNome_usuario() %>

                                </div>

                            </div>


                        </div>

                    </td>


                    <td>

                        <%= usuario.getCPF_usuario() != null
                            ? usuario.getCPF_usuario()
                            : "-" %>

                    </td>


                    <td>


                        <%
                            String textoTipo =
                                tipo;

                            if ("cliente".equalsIgnoreCase(tipo)) {

                                textoTipo = "Cliente";

                            } else if (
                                "organizador".equalsIgnoreCase(tipo)) {

                                textoTipo = "Organizador";

                            } else if (
                                "admin".equalsIgnoreCase(tipo)) {

                                textoTipo = "Admin";
                            }
                        %>


                        <span class="type-pill <%= classeTipo %>">

                            <%= textoTipo %>

                        </span>


                    </td>


                    <td>

                        <%= usuario.getEmail_usuario() != null
                            ? usuario.getEmail_usuario()
                            : "-" %>

                    </td>


                    <td>

                        <%= usuario.getTelefone() != null
                            ? usuario.getTelefone()
                            : "-" %>

                    </td>


                    <td>

                        <%= eventosCriados %>

                    </td>


                </tr>


            <%
                    }
                }
            %>


            </tbody>


        </table>


    </div>


</section>


</main>


</div>


</div>


<script>

/* ============================================================
   NAVEGAÇÃO ENTRE AS SUBTELAS
   ============================================================ */

function mudarView(viewId, botao) {

    document
        .querySelectorAll('.view-section')
        .forEach(function(elemento) {

            elemento.classList.remove('active');

        });


    var view =
        document.getElementById(
            'view-' + viewId
        );


    if (view) {

        view.classList.add('active');

    }


    document
        .querySelectorAll('.sidebar .nav-item')
        .forEach(function(elemento) {

            elemento.classList.remove('active');

        });


    if (botao) {

        botao.classList.add('active');

    }

}


/* ============================================================
   BUSCA DE USUÁRIOS
   ============================================================ */

var buscaUsuario =
    document.getElementById('busca-usuario');

var filtroTipo =
    document.getElementById('filtro-tipo');


function filtrarUsuarios() {

    var texto =
        buscaUsuario.value
            .toLowerCase()
            .trim();


    var tipoSelecionado =
        filtroTipo.value
            .toLowerCase();


    var linhas =
        document.querySelectorAll(
            '#corpo-usuarios tr[data-nome]'
        );


    var encontrados = 0;


    linhas.forEach(function(linha) {

        var nome =
            (linha.dataset.nome || '')
                .toLowerCase();


        var email =
            (linha.dataset.email || '')
                .toLowerCase();


        var tipo =
            (linha.dataset.tipo || '')
                .toLowerCase();


        var correspondeTexto =
            texto === '' ||
            nome.includes(texto) ||
            email.includes(texto);


        var correspondeTipo =
            tipoSelecionado === 'todos' ||
            tipo === tipoSelecionado;


        if (
            correspondeTexto &&
            correspondeTipo
        ) {

            linha.style.display = '';

            encontrados++;

        } else {

            linha.style.display = 'none';

        }

    });


    var contador =
        document.getElementById(
            'contador-usuarios'
        );


    if (contador) {

        contador.textContent =
            encontrados +
            ' usuário(s) encontrado(s)';

    }

}


if (buscaUsuario) {

    buscaUsuario.addEventListener(
        'input',
        filtrarUsuarios
    );

}


if (filtroTipo) {

    filtroTipo.addEventListener(
        'change',
        filtrarUsuarios
    );

}


/* ============================================================
   BUSCA DE EVENTOS
   ============================================================ */

var buscaEvento =
    document.getElementById('busca-evento');


if (buscaEvento) {

    buscaEvento.addEventListener(
        'input',
        function() {

            var texto =
                buscaEvento.value
                    .toLowerCase()
                    .trim();


            var linhas =
                document.querySelectorAll(
                    '#corpo-eventos tr[data-busca-evento]'
                );


            linhas.forEach(function(linha) {

                var dados =
                    (linha.dataset.buscaEvento || '')
                        .toLowerCase();


                if (
                    texto === '' ||
                    dados.includes(texto)
                ) {

                    linha.style.display = '';

                } else {

                    linha.style.display = 'none';

                }

            });

        }
    );

}

</script>


</body>

</html>