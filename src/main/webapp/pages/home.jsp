<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="br.com.gerencia.model.usuarioModel"%>
<%@ page import="br.com.gerencia.model.eventoModel"%>
<%@ page import="br.com.gerencia.model.inscricaoModel"%>
<%@ page import="br.com.gerencia.model.favoritoModel"%>
<%@ page import="br.com.gerencia.model.notificacaoModel"%>
<%@ page import="br.com.gerencia.dao.eventoDAO"%>
<%@ page import="br.com.gerencia.dao.inscricaoDAO"%>
<%@ page import="br.com.gerencia.dao.favoritoDAO"%>
<%@ page import="br.com.gerencia.dao.notificacaoDAO"%>
<%@ page import="br.com.gerencia.dao.usuarioDAO"%>
<%@ page import="br.com.gerencia.utils.Conexao"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.time.format.DateTimeFormatter"%>
<%
    // ================= SEM CACHE =================
    // Evita que o navegador reaproveite uma cópia antiga desta página
    // (ex.: após favoritar/inscrever-se, ou trocar de usuário no mesmo
    // navegador) — sem isso, contadores como "Favoritos" e "Meus Eventos"
    // podem continuar mostrando valores de uma sessão anterior.
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

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

    // ================= DADOS REAIS DO BANCO =================
    eventoDAO eventoDAOJsp = new eventoDAO(Conexao.getConnection());
    inscricaoDAO inscricaoDAOJsp = new inscricaoDAO(Conexao.getConnection());
    favoritoDAO favoritoDAOJsp = new favoritoDAO(Conexao.getConnection());
    usuarioDAO usuarioDAOJsp = new usuarioDAO(Conexao.getConnection());

    DateTimeFormatter fmtData = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter fmtHora = DateTimeFormatter.ofPattern("HH:mm");

    // eventos públicos e ativos (o que o cliente pode ver/se inscrever)
    List<eventoModel> eventosAtivos = new ArrayList<eventoModel>();
    for (eventoModel ev : eventoDAOJsp.listarEventos()) {
        if ("ativo".equals(ev.getStatus_evento())) {
            eventosAtivos.add(ev);
        }
    }

    // inscrições do usuário logado (em todos os status)
    List<inscricaoModel> minhasInscricoes = new ArrayList<inscricaoModel>();
    for (inscricaoModel insc : inscricaoDAOJsp.listarInscricoes()) {
        if (insc.getId_usuario() == usuarioLogado.getId_usuario()) {
            minhasInscricoes.add(insc);
        }
    }

    // total de "Meus Eventos" ativos (confirmados + em lista de espera), pro badge da sidebar
    int totalMeusEventosAtivos = 0;
    for (inscricaoModel insc : minhasInscricoes) {
        if ("Confirmada".equals(insc.getStatus_inscricao()) || "Espera".equals(insc.getStatus_inscricao())) {
            totalMeusEventosAtivos++;
        }
    }

    // favoritos do usuário logado
    List<favoritoModel> meusFavoritos = new ArrayList<favoritoModel>();
    for (favoritoModel fav : favoritoDAOJsp.listarFavoritos()) {
        if (fav.getId_usuario() == usuarioLogado.getId_usuario()) {
            meusFavoritos.add(fav);
        }
    }

    // notificações do usuário logado
    notificacaoDAO notificacaoDAOJsp = new notificacaoDAO(Conexao.getConnection());
    List<notificacaoModel> minhasNotificacoes = notificacaoDAOJsp.listarPorUsuario(usuarioLogado.getId_usuario());
    int notifNaoLidas = notificacaoDAOJsp.contarNaoLidas(usuarioLogado.getId_usuario());
    DateTimeFormatter fmtDataHora = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<%!
    private String js(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("'", "\\'").replace("\r", " ").replace("\n", " ").replace("</", "<\\/");
    }
    private String rotuloCategoria(String c) {
        if (c == null) return "";
        if ("tecCientifico".equals(c)) return "Tecnologia";
        if ("sociais".equals(c)) return "Sociais";
        if ("corporativos".equals(c)) return "Corporativos";
        // categoria nova (ainda sem rótulo customizado acima): capitaliza a primeira letra
        if (c.isEmpty()) return c;
        return Character.toUpperCase(c.charAt(0)) + c.substring(1);
    }

    // =========================================================
    // FOTOS DE CAPA DOS CARDS DE EVENTO
    // Um pequeno banco de fotos (Unsplash) por categoria, para
    // preencher o espaço em branco no topo dos cards. A escolha
    // dentro do pool usa o ID do evento como "seed", então cada
    // evento sempre mostra a mesma foto (não fica trocando a
    // cada recarregamento da página).
    // =========================================================
    private static final java.util.Map<String, String[]> IMAGENS_POR_CATEGORIA = new java.util.HashMap<String, String[]>();
    static {
        IMAGENS_POR_CATEGORIA.put("tecCientifico", new String[]{"1540575467063-178a50c2df87", "1531058020387-3be344556be6", "1558008258-3256797b43f3"});
        IMAGENS_POR_CATEGORIA.put("sociais", new String[]{"1528605248644-14dd04022da1", "1519671282429-b44660ead0a7", "1511988617509-a57c8a288659"});
        IMAGENS_POR_CATEGORIA.put("corporativos", new String[]{"1542744173-8e7e53415bb0", "1580894732444-8ecded7900cd", "1556761175-5973dc0f32e7"});
        IMAGENS_POR_CATEGORIA.put("cultural", new String[]{"1637578035851-c5b169722de1", "1569783721854-33a99b4c0bae", "1544213456-bc37cb97df74"});
        IMAGENS_POR_CATEGORIA.put("esportivo", new String[]{"1607627000458-210e8d2bdb1d", "1461897104016-0b3b00cc81ee", "1607962837359-5e7e89f86776"});
        IMAGENS_POR_CATEGORIA.put("comunitario", new String[]{"1582213782179-e0d53f98f2ca", "1599059813005-11265ba4b4ce", "1544928147-79a2dbc1f389"});
        IMAGENS_POR_CATEGORIA.put("artistico", new String[]{"1541753866388-0b3c701627d3", "1589996448606-27d38c70f3bc", "1597274303632-880ef8660375"});
        IMAGENS_POR_CATEGORIA.put("educacional", new String[]{"1509062522246-3755977927d7", "1577896851231-70ef18881754", "1588072432836-e10032774350"});
    }

    private String imagemCategoria(String categoria, int seed, int w, int h) {
        String[] ids = IMAGENS_POR_CATEGORIA.get(categoria);
        if (ids == null) ids = IMAGENS_POR_CATEGORIA.get("tecCientifico");
        int idx = Math.abs(seed) % ids.length;
        return "https://images.unsplash.com/photo-" + ids[idx] + "?w=" + w + "&h=" + h + "&fit=crop&auto=format&q=65";
    }
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GerenCIA - Início</title>

<script>
    // Aplica o tema salvo o quanto antes, pra não "piscar" claro antes de escurecer.
    if (localStorage.getItem('gerencia-tema') === 'escuro') {
        document.documentElement.classList.add('dark-mode');
    }
</script>

<!-- Ajuste automático de proporções para qualquer tamanho de tela -->
<script src="${pageContext.request.contextPath}/js/responsivo.js"></script>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>

<style>

    /* ================= RESET / BASE ================= */

    * { margin: 0; padding: 0; box-sizing: border-box; }

    /* ================= LAYOUT GERAL (sem scroll na página toda) ================= */

    html, body {
        height: 100%;
        overflow: hidden;
        width: 100%;
        font-family: 'Inter', Arial, Helvetica, sans-serif;
        color: #0F172A;
        background: #F8FAFC;
    }

    a { text-decoration: none; color: inherit; }
    button { font-family: inherit; cursor: pointer; }

    .app {
        display: grid;
        grid-template-columns: 240px 1fr;
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

    /* ================= SIDEBAR ================= */

    .sidebar {
        background: #FFFFFF;
        border-right: 1px solid #E2E8F0;
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
        font-size: 18px;
    }

    .sidebar-logo span {
        font-size: 18px;
        font-weight: 700;
    }

    .nav-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 12px;
        border-radius: 9px;
        font-size: 16px;
        font-weight: 500;
        color: #475569;
        margin-bottom: 2px;
        border: none;
        background: none;
        width: 100%;
        text-align: left;
    }

    .nav-item .nav-icon { font-size: 17px; width: 18px; text-align: center; }

    .nav-item .nav-label { flex: 1; }

    .nav-item .nav-badge {
        min-width: 18px;
        height: 18px;
        padding: 0 5px;
        border-radius: 9px;
        background: #EF4444;
        color: #FFFFFF;
        font-size: 12px;
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
        font-size: 14px;
        font-weight: 700;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }

    .sidebar-footer strong { display: block; font-size: 15px; }
    .sidebar-footer small { display: block; font-size: 13px; color: #94A3B8; }

    .logout-btn {
        margin-left: auto;
        font-size: 17px;
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
        flex-shrink: 0;
        position: relative;
        z-index: 10;
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
        font-size: 15px;
    }

    .search-box input {
        border: none;
        background: none;
        outline: none;
        font-size: 15px;
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
        font-size: 19px;
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
        font-size: 15px;
        font-weight: 600;
    }

    /* ================= CONTEÚDO ================= */

    .content {
        flex: 1;
        overflow-y: auto;
        padding: 28px;
        max-width: 1760px;
        width: 100%;
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

    .view-header h1 { font-size: 24px; font-weight: 700; letter-spacing: -0.3px; }
    .view-header p { color: #64748B; font-size: 15px; margin-top: 4px; }

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

    .btn-checkin.aguardando {
        background: #CBD5E1;
        color: #64748B;
        cursor: not-allowed;
        pointer-events: none;
    }

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
        font-size: 13px;
        font-weight: 600;
        margin-bottom: 10px;
    }

    .hero-banner h2 { position: relative; z-index: 1; font-size: 24px; margin-bottom: 6px; }
    .hero-banner p { position: relative; z-index: 1; font-size: 15px; color: #DBEAFE; }

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
        font-size: 15px;
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
        min-width: 0;
        width: 100%;
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
        font-size: 12px;
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
        font-size: 15px;
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
        font-size: 13px;
        font-weight: 600;
        color: #2563EB;
        background: #EFF6FF;
        padding: 3px 8px;
        border-radius: 6px;
    }

    .price-tag { font-size: 15px; font-weight: 700; }

    .event-card h3 { font-size: 16px; margin-bottom: 6px; }

    .event-meta {
        font-size: 14px;
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
        font-size: 14px;
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
        font-size: 15px;
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
        font-size: 12px;
        font-weight: 700;
        flex-shrink: 0;
    }

    .side-item .info strong { display: block; font-size: 14px; }
    .side-item .info span { font-size: 13px; color: #94A3B8; }

    .status-chip {
        font-size: 12px;
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
    .list-card .info strong { font-size: 16px; }
    .list-card .info .meta { font-size: 14px; color: #94A3B8; margin-top: 3px; }

    .list-card .actions { display: flex; gap: 8px; align-items: center; }

    .badge-status {
        font-size: 13px;
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
        font-size: 14px;
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

    .profile-card .avatar { width: 60px; height: 60px; font-size: 20px; }
    .profile-card strong { display: block; font-size: 18px; }
    .profile-card span.sub { font-size: 14px; color: #94A3B8; }

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
        font-size: 15px;
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
        font-size: 15px;
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
        font-size: 15px;
    }

    .menu-toggle-btn {
        display: none;
        width: 34px; height: 34px;
        border-radius: 8px;
        border: 1px solid #E2E8F0;
        background: #FFFFFF;
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
            height: calc(var(--vh, 1vh) * 100);
            width: 240px;
            z-index: 50;
            transform: translateX(-100%);
            transition: transform 0.25s ease;
            box-shadow: 0 0 30px rgba(2,6,23,0.25);
        }

        .sidebar.open { transform: translateX(0); }

        .menu-toggle-btn { display: flex; }

        .two-col { grid-template-columns: 1fr; }
        .fields-row-2 { grid-template-columns: 1fr; }
        .content { padding: 16px; }
    }

    @media (max-width: 480px) {
        .events-grid { grid-template-columns: 1fr; }
    }
    .modal-overlay {
        display: none; position: fixed; inset: 0; background: rgba(2,6,23,0.55);
        align-items: center; justify-content: center; z-index: 100; padding: 20px;
    }
    .modal-overlay.open { display: flex; }
    .modal-box {
        background: #FFFFFF; border-radius: 14px; width: 100%; max-width: 460px;
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
       ========================================================= */

    .theme-row {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 12px;
        margin-bottom: 2px;
    }

    .theme-row .nav-label { flex: 1; font-size: 14px; font-weight: 500; color: #475569; }

    .theme-switch { position: relative; width: 38px; height: 21px; flex-shrink: 0; }
    .theme-switch input { opacity: 0; width: 0; height: 0; }
    .theme-switch-slider {
        position: absolute; inset: 0; background: #E2E8F0; border-radius: 20px;
        cursor: pointer; transition: 0.2s;
    }
    .theme-switch-slider::before {
        content: ""; position: absolute; width: 15px; height: 15px; left: 3px; top: 3px;
        background: #FFFFFF; border-radius: 50%; transition: 0.2s;
        box-shadow: 0 1px 3px rgba(0,0,0,0.3);
    }
    .theme-switch input:checked + .theme-switch-slider { background: #2563EB; }
    .theme-switch input:checked + .theme-switch-slider::before { transform: translateX(17px); }

    html.dark-mode body { background: #0F172A; color: #E2E8F0; }

    html.dark-mode .sidebar { background: #0F172A; border-right-color: #1E293B; }
    html.dark-mode .theme-row .nav-label { color: #CBD5E1; }
    html.dark-mode .nav-item { color: #94A3B8; }
    html.dark-mode .nav-item:hover { background: #1E293B; }
    html.dark-mode .nav-item.active { background: rgba(37,99,235,0.18); color: #93C5FD; }
    html.dark-mode .sidebar-footer { border-top-color: #1E293B; }
    html.dark-mode .sidebar-footer strong { color: #E2E8F0; }

    html.dark-mode .topbar { background: #0F172A; border-bottom-color: #1E293B; }
    html.dark-mode .search-box { background: #1E293B; color: #94A3B8; }
    html.dark-mode .search-box input { color: #E2E8F0; }
    html.dark-mode .search-box input::placeholder { color: #64748B; }
    html.dark-mode .topbar-user { color: #E2E8F0; }
    html.dark-mode .topbar-user:hover { background: #1E293B; }

    html.dark-mode .event-card,
    html.dark-mode .side-card,
    html.dark-mode .list-card,
    html.dark-mode .profile-card,
    html.dark-mode .detail-box,
    html.dark-mode .panel-card,
    html.dark-mode .modal-box {
        background: #1E293B;
        border-color: #334155;
    }

    html.dark-mode .event-card h3,
    html.dark-mode .list-card strong,
    html.dark-mode .side-item strong,
    html.dark-mode .modal-header h3,
    html.dark-mode .view-header h1,
    html.dark-mode .card-title,
    html.dark-mode h1, html.dark-mode h4 {
        color: #F1F5F9;
    }

    html.dark-mode .modal-close { color: #94A3B8; }
    html.dark-mode .notif-dropdown { background: #1E293B; border-color: #334155; }
    html.dark-mode .notif-item { border-bottom-color: #334155; color: #E2E8F0; }
    html.dark-mode .notif-dropdown-header { border-bottom-color: #334155; }

    html.dark-mode input,
    html.dark-mode select,
    html.dark-mode textarea {
        background: #0F172A;
        border-color: #334155;
        color: #E2E8F0;
    }

    html.dark-mode input:focus,
    html.dark-mode select:focus,
    html.dark-mode textarea:focus {
        background: #1E293B;
    }

    html.dark-mode .btn-outline {
        background: #1E293B;
        border-color: #334155;
        color: #E2E8F0;
    }

    html.dark-mode .btn-outline:hover { background: #334155; }

    html.dark-mode .empty-state { color: #64748B; }

    html.dark-mode .hero-badge { background: rgba(255,255,255,0.14); }

</style>
</head>
<body>

<div class="app">

    <!-- ================= SIDEBAR ================= -->
    <aside class="sidebar" id="sidebarEl">

        <div class="sidebar-logo">
            <div class="sidebar-logo-icon">📅</div>
            <span>GerenCIA</span>
        </div>

        <button class="nav-item active" data-view="inicio" onclick="mudarView('inicio', this)">
            <span class="nav-label">Início</span>
        </button>

        <button class="nav-item" data-view="eventos" onclick="mudarView('eventos', this)">
            <span class="nav-label">Eventos</span>
        </button>

        <button class="nav-item" data-view="favoritos" onclick="mudarView('favoritos', this)">
            <span class="nav-label">Favoritos</span>
            <span class="nav-badge"><%= meusFavoritos.size() %></span>
        </button>

        <button class="nav-item" data-view="meus-eventos" onclick="mudarView('meus-eventos', this)">
            <span class="nav-label">Meus Eventos</span>
            <span class="nav-badge blue"><%= totalMeusEventosAtivos %></span>
        </button>

        <button class="nav-item" data-view="historico" onclick="mudarView('historico', this)">
            <span class="nav-label">Histórico</span>
        </button>

        <div class="theme-row">
            <span class="nav-label">Modo escuro</span>
            <label class="theme-switch">
                <input type="checkbox" id="themeToggle" onchange="alternarTema()">
                <span class="theme-switch-slider"></span>
            </label>
        </div>

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

    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

    <!-- ================= ÁREA PRINCIPAL ================= -->
    <div class="main-col">

        <header class="topbar">

            <button class="menu-toggle-btn" onclick="toggleSidebar()">☰</button>

            <div class="search-box">
                🔍
                <input type="text" id="searchInput" placeholder="Buscar por nome ou código do evento..."
                       oninput="aplicarBuscaEventos(this.value)"
                       onkeydown="if(event.key==='Enter'){ event.preventDefault(); mudarViewById('eventos'); }">
            </div>

            <div class="topbar-actions">
                <div class="bell-wrap" style="position:relative;">
                    <button class="bell <%= notifNaoLidas > 0 ? "unread" : "" %>" id="bellBtn" onclick="toggleNotificacoes(event)"
                            style="border:none; background:none; cursor:pointer; position:relative; font-size:16px;">
                        🔔<span class="dot" style="<%= notifNaoLidas > 0 ? "" : "display:none;" %>"></span>
                    </button>

                    <div class="notif-dropdown" id="notifDropdown" style="display:none; position:absolute; top:36px; right:0; width:300px; background:#FFFFFF; border:1px solid #E2E8F0; border-radius:12px; box-shadow:0 20px 45px rgba(2,6,23,0.18); z-index:25; max-height:360px; overflow-y:auto;">
                        <div style="display:flex; align-items:center; justify-content:space-between; padding:12px 14px; border-bottom:1px solid #F1F5F9; font-size:13px; font-weight:700;">
                            Notificações
                            <a href="${pageContext.request.contextPath}/notificacaoController?action=marcarLidas&voltarPara=/pages/home.jsp" style="font-size:11px; font-weight:600; color:#2563EB;">Marcar todas como lidas</a>
                        </div>
                        <%
                            if (minhasNotificacoes.isEmpty()) {
                        %>
                        <div style="padding:24px 14px; text-align:center; color:#94A3B8; font-size:12px;">Nenhuma notificação por enquanto.</div>
                        <%
                            } else {
                                for (notificacaoModel n : minhasNotificacoes) {
                        %>
                        <div style="padding:11px 14px; border-bottom:1px solid #F8FAFC; font-size:12px; color:#334155;">
                            <div><%= n.getMensagem() %></div>
                            <div style="font-size:10px; color:#94A3B8; margin-top:3px;"><%= n.getData_envio().format(fmtDataHora) %></div>
                        </div>
                        <%
                                }
                            }
                        %>
                    </div>
                </div>

                <button class="topbar-user" onclick="mudarViewById('perfil')" style="border:none; background:none; cursor:pointer; display:flex; align-items:center; gap:8px; font-size:13px; font-weight:600; color:#0F172A; padding:4px 6px; border-radius:8px;">
                    <div class="avatar" style="width:30px;height:30px;font-size:11px;"><%= iniciais %></div>
                    <%= nomeUsuario %>
                </button>
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
                    <p><%= eventosAtivos.size() %> evento(s) disponível(is) para você</p>
                </div>

                <div class="category-pills">
                    <button class="pill active">Todos</button>
                    <button class="pill">Tecnologia</button>
                    <button class="pill">Sociais</button>
                    <button class="pill">Corporativos</button>
                </div>

                <div class="two-col">

                    <div class="events-grid" id="grid-inicio">
                        <!-- cards inseridos via JS a partir do mock de eventos -->
                    </div>

                    <div>

                        <div class="side-card">
                            <h4>Meus Próximos Eventos</h4>
                            <%
                                int mostradosProximos = 0;
                                for (inscricaoModel insc : minhasInscricoes) {
                                    if (!"Confirmada".equals(insc.getStatus_inscricao())) continue;
                                    eventoModel evProx = eventoDAOJsp.buscarPorId(insc.getId_evento());
                                    if (evProx == null) continue;
                                    if (mostradosProximos >= 3) break;
                                    mostradosProximos++;
                            %>
                            <div class="side-item">
                                <div class="date-box">
                                    <span><%= evProx.getInicio_evento().format(DateTimeFormatter.ofPattern("dd")) %></span>
                                    <span><%= evProx.getInicio_evento().format(DateTimeFormatter.ofPattern("MMM")) %></span>
                                </div>
                                <div class="info">
                                    <strong><%= evProx.getNome_evento() %></strong>
                                    <span><%= evProx.getInicio_evento().format(fmtHora) %> · <%= evProx.getLocal_evento() %></span>
                                    <div class="status-chip">Confirmada</div>
                                </div>
                            </div>
                            <%
                                }
                                if (mostradosProximos == 0) {
                            %>
                            <div style="font-size:12px; color:#94A3B8;">Você ainda não tem inscrições confirmadas.</div>
                            <%
                                }
                            %>
                        </div>

                        <div class="side-card">
                            <h4>Favoritos</h4>
                            <%
                                int mostradosFav = 0;
                                for (favoritoModel fav : meusFavoritos) {
                                    eventoModel evFav = eventoDAOJsp.buscarPorId(fav.getId_evento());
                                    if (evFav == null) continue;
                                    if (mostradosFav >= 3) break;
                                    mostradosFav++;
                            %>
                            <div class="side-item">
                                <div class="info">
                                    <strong><%= evFav.getNome_evento() %></strong>
                                    <span><%= evFav.getInicio_evento().format(fmtData) %></span>
                                </div>
                            </div>
                            <%
                                }
                                if (mostradosFav == 0) {
                            %>
                            <div style="font-size:12px; color:#94A3B8;">Nenhum favorito ainda.</div>
                            <%
                                }
                            %>
                        </div>

                        <div class="side-card">
                            <h4>Histórico recente</h4>
                            <%
                                int mostradosHist = 0;
                                for (int i = minhasInscricoes.size() - 1; i >= 0 && mostradosHist < 3; i--) {
                                    inscricaoModel insc = minhasInscricoes.get(i);
                                    eventoModel evHist = eventoDAOJsp.buscarPorId(insc.getId_evento());
                                    if (evHist == null) continue;
                                    mostradosHist++;
                            %>
                            <div class="side-item">
                                <div class="info">
                                    <strong><%= evHist.getNome_evento() %></strong>
                                    <span><%= insc.getData_inscricao().format(fmtData) %></span>
                                </div>
                            </div>
                            <%
                                }
                                if (mostradosHist == 0) {
                            %>
                            <div style="font-size:12px; color:#94A3B8;">Nenhuma atividade ainda.</div>
                            <%
                                }
                            %>
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
                    <button class="btn-outline" onclick="exportarPDF('eventos')">⬇ Exportar Dados</button>
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
                    <button class="btn-outline" onclick="exportarPDF('favoritos')">⬇ Exportar Dados</button>
                </div>

                <div class="events-grid" id="grid-favoritos"></div>

            </section>

            <!-- ============================================================
                 VIEW: DETALHES DO EVENTO
            ============================================================ -->
            <section class="view-section" id="view-detalheEvento">

                <div class="back-link" onclick="mudarViewById('eventos')" style="display:flex; align-items:center; gap:8px; font-size:12px; color:#64748B; margin-bottom:10px; cursor:pointer;">← Voltar</div>

                <div class="view-header">
                    <div><h1 id="det_ev_nome">—</h1></div>
                    <button class="btn-outline" onclick="exportarEventoPDF()">⬇ Exportar</button>
                </div>

                <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:16px;">
                    <div class="detail-box" style="background:#FFF;border:1px solid #E2E8F0;border-radius:10px;padding:12px 14px;">
                        <label style="display:block;font-size:10px;color:#94A3B8;text-transform:uppercase;margin-bottom:4px;">Tipo</label>
                        <div id="det_ev_tipo" style="font-size:13px;font-weight:600;">—</div>
                    </div>
                    <div class="detail-box" style="background:#FFF;border:1px solid #E2E8F0;border-radius:10px;padding:12px 14px;">
                        <label style="display:block;font-size:10px;color:#94A3B8;text-transform:uppercase;margin-bottom:4px;">Categoria</label>
                        <div id="det_ev_categoria" style="font-size:13px;font-weight:600;">—</div>
                    </div>
                    <div class="detail-box" style="background:#FFF;border:1px solid #E2E8F0;border-radius:10px;padding:12px 14px;">
                        <label style="display:block;font-size:10px;color:#94A3B8;text-transform:uppercase;margin-bottom:4px;">Início</label>
                        <div id="det_ev_inicio" style="font-size:13px;font-weight:600;">—</div>
                    </div>
                    <div class="detail-box" style="background:#FFF;border:1px solid #E2E8F0;border-radius:10px;padding:12px 14px;">
                        <label style="display:block;font-size:10px;color:#94A3B8;text-transform:uppercase;margin-bottom:4px;">Término</label>
                        <div id="det_ev_fim" style="font-size:13px;font-weight:600;">—</div>
                    </div>
                    <div class="detail-box" style="background:#FFF;border:1px solid #E2E8F0;border-radius:10px;padding:12px 14px;">
                        <label style="display:block;font-size:10px;color:#94A3B8;text-transform:uppercase;margin-bottom:4px;">Local</label>
                        <div id="det_ev_local" style="font-size:13px;font-weight:600;">—</div>
                    </div>
                    <div class="detail-box" style="background:#FFF;border:1px solid #E2E8F0;border-radius:10px;padding:12px 14px;">
                        <label style="display:block;font-size:10px;color:#94A3B8;text-transform:uppercase;margin-bottom:4px;">Código</label>
                        <div id="det_ev_codigo" style="font-size:13px;font-weight:600;">—</div>
                    </div>
                    <div class="detail-box" style="background:#FFF;border:1px solid #E2E8F0;border-radius:10px;padding:12px 14px;">
                        <label style="display:block;font-size:10px;color:#94A3B8;text-transform:uppercase;margin-bottom:4px;">Capacidade</label>
                        <div id="det_ev_capacidade" style="font-size:13px;font-weight:600;">—</div>
                    </div>
                    <div class="detail-box" style="background:#FFF;border:1px solid #E2E8F0;border-radius:10px;padding:12px 14px;">
                        <label style="display:block;font-size:10px;color:#94A3B8;text-transform:uppercase;margin-bottom:4px;">Inscritos</label>
                        <div id="det_ev_inscritos" style="font-size:13px;font-weight:600;">—</div>
                    </div>
                </div>

                <div style="background:#FFF;border:1px solid #E2E8F0;border-radius:10px;padding:14px 16px;margin-bottom:16px;">
                    <label style="display:block;font-size:10px;color:#94A3B8;text-transform:uppercase;margin-bottom:6px;">Descrição</label>
                    <div id="det_ev_descricao" style="font-size:13px;">—</div>
                </div>

                <div style="display:flex; gap:10px;">
                    <button class="btn-outline" id="det_ev_fav_btn" onclick="alternarFavoritoDetalhe()">♡ Favoritar</button>
                    <button class="btn-solid" id="det_ev_inscrever_btn" onclick="inscreverDetalhe()">Inscrever-se</button>
                </div>

            </section>
            <section class="view-section" id="view-meus-eventos">

                <div class="view-header">
                    <div>
                        <h1>Meus Eventos</h1>
                        <p>Eventos em que você está inscrito ou na fila</p>
                    </div>
                    <button class="btn-outline" onclick="exportarPDF('meus-eventos')">⬇ Exportar Dados</button>
                </div>

                <%
                    int mostradosMeusEv = 0;
                    for (inscricaoModel insc : minhasInscricoes) {

                        if (!"Confirmada".equals(insc.getStatus_inscricao())
                                && !"Espera".equals(insc.getStatus_inscricao())) continue;

                        eventoModel evM = eventoDAOJsp.buscarPorId(insc.getId_evento());
                        if (evM == null) continue;

                        mostradosMeusEv++;

                        String badgeClasse = "Espera".equals(insc.getStatus_inscricao()) ? "" : "confirmada";
                        String badgeLabel = "Espera".equals(insc.getStatus_inscricao()) ? "Na lista de espera" : "Confirmada";
                %>
                <div class="list-card">
                    <div class="thumb-sm" style="background-color:#EFF6FF; background-image:url('<%= imagemCategoria(evM.getCategoria_evento(), evM.getId_evento(), 140, 140) %>');"></div>
                    <div class="info">
                        <strong><%= evM.getNome_evento() %></strong>
                        <span class="badge-status <%= badgeClasse %>"><%= badgeLabel %></span>
                        <div class="meta"><%= evM.getInicio_evento().format(fmtData) %> · <%= evM.getInicio_evento().format(fmtHora) %> · <%= evM.getLocal_evento() %></div>
                        <div class="meta">Inscrito em <%= insc.getData_inscricao().format(fmtData) %></div>
                    </div>
                    <div class="actions">
                        <% if ("Confirmada".equals(insc.getStatus_inscricao())) { %>
                        <button class="btn-outline" onclick="gerarComprovante(<%= insc.getId_inscricao() %>)">📄 Comprovante</button>

                        <% if (insc.getCheckin() != null) { %>
                        <button class="btn-outline" disabled>✓ Check-in realizado</button>
                        <% } else { %>
                        <button class="btn-solid btn-checkin"
                                id="checkinBtn_<%= insc.getId_inscricao() %>"
                                data-inicio="<%= evM.getInicio_evento().toString() %>"
                                data-fim="<%= evM.getFim_evento().toString() %>"
                                data-inscricao="<%= insc.getId_inscricao() %>"
                                onclick="realizarCheckin(<%= insc.getId_inscricao() %>, '<%= js(evM.getNome_evento()) %>')">✅ Fazer Check-in</button>
                        <% } %>
                        <% } %>
                        <a class="btn-outline"
                           href="${pageContext.request.contextPath}/inscricaoController?action=cancelar&id=<%= insc.getId_inscricao() %>"
                           onclick="return confirm('Cancelar sua inscrição em \'<%= js(evM.getNome_evento()) %>\'?');">Cancelar</a>
                    </div>
                </div>
                <%
                    }
                    if (mostradosMeusEv == 0) {
                %>
                <div class="empty-state" style="text-align:center; padding:40px; color:#94A3B8;">Você ainda não está inscrito em nenhum evento.</div>
                <%
                    }
                %>

            </section>

            <!-- ============================================================
                 VIEW: HISTÓRICO
            ============================================================ -->
            <section class="view-section" id="view-historico">

                <div class="view-header">
                    <div>
                        <h1>Histórico de Participação</h1>
                        <p><%= minhasInscricoes.size() %> registro(s)</p>
                    </div>
                    <button class="btn-outline" onclick="exportarPDF('historico')">⬇ Exportar Dados</button>
                </div>

                <%
                    List<inscricaoModel> historicoOrdenado = new ArrayList<inscricaoModel>(minhasInscricoes);
                    java.util.Collections.sort(historicoOrdenado, new java.util.Comparator<inscricaoModel>() {
                        public int compare(inscricaoModel a, inscricaoModel b) {
                            return b.getData_inscricao().compareTo(a.getData_inscricao());
                        }
                    });

                    for (inscricaoModel insc : historicoOrdenado) {

                        eventoModel evH = eventoDAOJsp.buscarPorId(insc.getId_evento());
                        if (evH == null) continue;

                        String badgeClasse;
                        String badgeLabel;

                        if (insc.getCheckin() != null) {
                            badgeClasse = "checkin";
                            badgeLabel = "✓ Check-in realizado";
                        } else if ("Cancelada".equals(insc.getStatus_inscricao())) {
                            badgeClasse = "cancelada";
                            badgeLabel = "✕ Cancelado";
                        } else if ("Espera".equals(insc.getStatus_inscricao())) {
                            badgeClasse = "";
                            badgeLabel = "Na lista de espera";
                        } else {
                            badgeClasse = "confirmada";
                            badgeLabel = "Confirmado";
                        }
                %>
                <div class="list-card" style="cursor:pointer;" onclick="abrirDetalheInscricao(<%= insc.getId_inscricao() %>)">
                    <div class="thumb-sm" style="background-color:#EFF6FF; background-image:url('<%= imagemCategoria(evH.getCategoria_evento(), evH.getId_evento(), 140, 140) %>');"></div>
                    <div class="info">
                        <strong><%= evH.getNome_evento() %></strong>
                        <div class="meta"><%= rotuloCategoria(evH.getCategoria_evento()) %> · <%= evH.getInicio_evento().format(fmtData) %> · <%= evH.getLocal_evento() %></div>
                    </div>
                    <span class="badge-status <%= badgeClasse %>"><%= badgeLabel %></span>
                </div>
                <%
                    }
                    if (historicoOrdenado.isEmpty()) {
                %>
                <div class="empty-state" style="text-align:center; padding:40px; color:#94A3B8;">Nenhum histórico ainda.</div>
                <%
                    }
                %>

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
    // MODO ESCURO
    // =========================================================

    function alternarTema() {
        const escuro = document.getElementById('themeToggle').checked;
        document.documentElement.classList.toggle('dark-mode', escuro);
        localStorage.setItem('gerencia-tema', escuro ? 'escuro' : 'claro');
    }

    document.getElementById('themeToggle').checked =
        document.documentElement.classList.contains('dark-mode');

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

    function toggleNotificacoes(ev) {
        ev.stopPropagation();
        const dd = document.getElementById('notifDropdown');
        dd.style.display = dd.style.display === 'block' ? 'none' : 'block';
    }

    document.addEventListener('click', function (ev) {
        const dd = document.getElementById('notifDropdown');
        if (dd && dd.style.display === 'block' && !dd.contains(ev.target) && ev.target.id !== 'bellBtn') {
            dd.style.display = 'none';
        }
    });

    // =========================================================
    // EVENTOS (dados reais, vindos do eventoDAO)
    // =========================================================

    const eventosReais = [
        <%
            for (eventoModel ev : eventosAtivos) {

                int inscritosEv = inscricaoDAOJsp.contarConfirmados(ev.getId_evento());
                int filaEv = inscricaoDAOJsp.contarEspera(ev.getId_evento());
                boolean lotadoEv = inscritosEv >= ev.getCapacidade_evento();
                int pctEv = ev.getCapacidade_evento() > 0
                    ? (int) Math.round((inscritosEv * 100.0) / ev.getCapacidade_evento())
                    : 0;

                boolean favoritoEv = false;
                for (favoritoModel fav : meusFavoritos) {
                    if (fav.getId_evento() == ev.getId_evento()) { favoritoEv = true; break; }
                }

                String meuStatusEv = "";
                for (inscricaoModel insc : minhasInscricoes) {
                    if (insc.getId_evento() == ev.getId_evento()
                            && !"Cancelada".equals(insc.getStatus_inscricao())) {
                        meuStatusEv = insc.getStatus_inscricao();
                        break;
                    }
                }
        %>
        {
            id: <%= ev.getId_evento() %>,
            nome: '<%= js(ev.getNome_evento()) %>',
            tipo: '<%= ev.getTipo_evento() %>',
            categoria: '<%= rotuloCategoria(ev.getCategoria_evento()) %>',
            categoriaValue: '<%= js(ev.getCategoria_evento()) %>',
            local: '<%= js(ev.getLocal_evento()) %>',
            data: '<%= ev.getInicio_evento().format(fmtData) %> · <%= ev.getInicio_evento().format(fmtHora) %>',
            dataFim: '<%= ev.getFim_evento().format(fmtData) %> · <%= ev.getFim_evento().format(fmtHora) %>',
            dataIso: '<%= ev.getInicio_evento().toString() %>',
            codigo: '<%= js(ev.getCodigo_evento()) %>',
            capacidade: <%= ev.getCapacidade_evento() %>,
            inscritos: <%= inscritosEv %>,
            ocupacao: <%= pctEv %>,
            lotado: <%= lotadoEv %>,
            filaAtual: <%= filaEv %>,
            favorito: <%= favoritoEv %>,
            meuStatus: '<%= meuStatusEv %>',
            descricao: '<%= js(ev.getDescricao_evento()) %>'
        },
        <%
            }
        %>
    ];

    // =========================================================
    // FOTOS DE CAPA DOS CARDS DE EVENTO (mesmo banco usado no
    // lado servidor, para os cards montados aqui via JS)
    // =========================================================
    const imagensPorCategoria = {
        tecCientifico: ['1540575467063-178a50c2df87', '1531058020387-3be344556be6', '1558008258-3256797b43f3'],
        sociais: ['1528605248644-14dd04022da1', '1519671282429-b44660ead0a7', '1511988617509-a57c8a288659'],
        corporativos: ['1542744173-8e7e53415bb0', '1580894732444-8ecded7900cd', '1556761175-5973dc0f32e7'],
        cultural: ['1637578035851-c5b169722de1', '1569783721854-33a99b4c0bae', '1544213456-bc37cb97df74'],
        esportivo: ['1607627000458-210e8d2bdb1d', '1461897104016-0b3b00cc81ee', '1607962837359-5e7e89f86776'],
        comunitario: ['1582213782179-e0d53f98f2ca', '1599059813005-11265ba4b4ce', '1544928147-79a2dbc1f389'],
        artistico: ['1541753866388-0b3c701627d3', '1589996448606-27d38c70f3bc', '1597274303632-880ef8660375'],
        educacional: ['1509062522246-3755977927d7', '1577896851231-70ef18881754', '1588072432836-e10032774350']
    };

    function imagemEvento(categoriaValue, seed, w, h) {
        const pool = imagensPorCategoria[categoriaValue] || imagensPorCategoria.tecCientifico;
        const idx = Math.abs(seed) % pool.length;
        return 'https://images.unsplash.com/photo-' + pool[idx] + '?w=' + w + '&h=' + h + '&fit=crop&auto=format&q=65';
    }

    function criarCardEvento(ev) {

        const barraClasse = ev.lotado ? 'capacity-bar full' : 'capacity-bar';
        const favClasse = ev.favorito ? 'fav-btn active' : 'fav-btn';
        const coracao = ev.favorito ? '♥' : '♡';
        const capaUrl = imagemEvento(ev.categoriaValue, ev.id, 500, 280);

        let botaoAcao;
        if (ev.meuStatus === 'Confirmada') {
            botaoAcao = '<button class="btn-outline" disabled>Já inscrito</button>';
        } else if (ev.meuStatus === 'Espera') {
            botaoAcao = '<button class="btn-outline" disabled>Na lista de espera</button>';
        } else if (ev.lotado) {
            botaoAcao = `<button class="btn-outline" onclick="inscrever(\${ev.id}, true)">Entrar na fila</button>`;
        } else {
            botaoAcao = `<button class="btn-solid" onclick="inscrever(\${ev.id}, false)">Inscrever-se</button>`;
        }

        return `
            <div class="event-card" data-categoria="\${ev.categoria}" data-id="\${ev.id}">
                <div class="thumb" style="background-color:#EFF6FF; background-image:url('\${capaUrl}');">
                    \${ev.lotado ? '<span class="tag-lotado">Lotado</span>' : ''}
                    <button class="\${favClasse}" onclick="alternarFavorito(\${ev.id})">\${coracao}</button>
                </div>
                <div class="body">
                    <div class="row-top">
                        <span class="cat-tag">\${ev.categoria}</span>
                    </div>
                    <h3>\${ev.nome}</h3>
                    <div class="event-meta">\${ev.local}</div>
                    <div class="event-meta">\${ev.data}</div>
                    <div class="\${barraClasse}"><span style="width:\${ev.ocupacao}%"></span></div>
                    <div class="actions">
                        <button class="btn-outline" onclick="verDetalhes(\${ev.id})">Ver Detalhes</button>
                        \${botaoAcao}
                    </div>
                </div>
            </div>
        `;
    }

    let currentDetalheEventoId = null;

    function verDetalhes(id) {
        const ev = eventosReais.find(e => e.id === id);
        if (!ev) return;

        currentDetalheEventoId = id;

        document.getElementById('det_ev_nome').textContent = ev.nome;
        document.getElementById('det_ev_tipo').textContent = ev.tipo === 'publico' ? 'Público' : 'Privado';
        document.getElementById('det_ev_categoria').textContent = ev.categoria;
        document.getElementById('det_ev_inicio').textContent = ev.data;
        document.getElementById('det_ev_fim').textContent = ev.dataFim;
        document.getElementById('det_ev_local').textContent = ev.local;
        document.getElementById('det_ev_codigo').textContent = ev.codigo;
        document.getElementById('det_ev_capacidade').textContent = ev.capacidade + ' pessoas';
        document.getElementById('det_ev_inscritos').textContent = ev.inscritos + ' (' + ev.ocupacao + '%)';
        document.getElementById('det_ev_descricao').textContent = ev.descricao || 'Sem descrição.';

        const favBtn = document.getElementById('det_ev_fav_btn');
        favBtn.textContent = ev.favorito ? '♥ Favoritado' : '♡ Favoritar';
        favBtn.classList.toggle('active', ev.favorito);

        const inscBtn = document.getElementById('det_ev_inscrever_btn');
        if (ev.meuStatus === 'Confirmada') {
            inscBtn.textContent = 'Já inscrito';
            inscBtn.disabled = true;
        } else if (ev.meuStatus === 'Espera') {
            inscBtn.textContent = 'Na lista de espera';
            inscBtn.disabled = true;
        } else if (ev.lotado) {
            inscBtn.textContent = 'Entrar na fila (evento lotado)';
            inscBtn.disabled = false;
        } else {
            inscBtn.textContent = 'Inscrever-se';
            inscBtn.disabled = false;
        }

        mudarViewById('detalheEvento');
    }

    function alternarFavoritoDetalhe() {
        if (currentDetalheEventoId != null) alternarFavorito(currentDetalheEventoId);
    }

    function inscreverDetalhe() {
        const ev = eventosReais.find(e => e.id === currentDetalheEventoId);
        if (!ev) return;
        inscrever(ev.id, ev.lotado && ev.meuStatus === '');
    }

    function exportarEventoPDF() {
        const ev = eventosReais.find(e => e.id === currentDetalheEventoId);
        if (!ev) return;
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        doc.setFontSize(14);
        doc.text(ev.nome, 14, 18);
        doc.autoTable({
            startY: 26,
            body: [
                ['Tipo', ev.tipo === 'publico' ? 'Público' : 'Privado'],
                ['Categoria', ev.categoria],
                ['Início', ev.data], ['Término', ev.dataFim],
                ['Local', ev.local], ['Código', ev.codigo],
                ['Capacidade', ev.capacidade], ['Inscritos', ev.inscritos + ' (' + ev.ocupacao + '%)'],
                ['Descrição', ev.descricao || '-']
            ]
        });
        doc.save('evento-' + ev.codigo + '.pdf');
    }

    function alternarFavorito(id) {
        const ev = eventosReais.find(e => e.id === id);
        if (!ev) return;

        const form = document.createElement('form');
        form.method = 'post';
        form.action = '${pageContext.request.contextPath}/favoritoController';

        const campos = {
            action: ev.favorito ? 'excluir' : 'novo',
            id_usuario: '<%= usuarioLogado.getId_usuario() %>',
            id_evento: id,
            data_favorito: new Date().toISOString().split('.')[0]
        };

        for (const chave in campos) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = chave;
            input.value = campos[chave];
            form.appendChild(input);
        }

        document.body.appendChild(form);
        form.submit();
    }

    // id do evento aguardando confirmação de entrada na lista de espera
    let filaEventoIdPendente = null;

    function inscrever(id, entrarNaFila) {

        if (entrarNaFila) {
            abrirModalFila(id);
            return;
        }

        if (!confirm('Confirmar inscrição neste evento?')) {
            return;
        }

        enviarInscricao(id, false, 0);
    }

    function abrirModalFila(id) {
        const ev = eventosReais.find(e => e.id === id);
        if (!ev) return;

        filaEventoIdPendente = id;

        const posicao = (ev.filaAtual || 0) + 1;

        document.getElementById('fila_nome_evento').textContent = ev.nome;
        document.getElementById('fila_posicao').textContent = posicao + 'º da fila';
        document.getElementById('modalFilaEspera').classList.add('open');
    }

    function fecharModalFila() {
        document.getElementById('modalFilaEspera').classList.remove('open');
        filaEventoIdPendente = null;
    }

    function confirmarEntradaFila() {
        if (filaEventoIdPendente == null) return;

        const ev = eventosReais.find(e => e.id === filaEventoIdPendente);
        const posicao = ev ? (ev.filaAtual || 0) + 1 : 0;

        enviarInscricao(filaEventoIdPendente, true, posicao);
        fecharModalFila();
    }

    function enviarInscricao(id, entrarNaFila, posicaoFila) {

        const form = document.createElement('form');
        form.method = 'post';
        form.action = '${pageContext.request.contextPath}/inscricaoController';

        const campos = {
            action: 'novo',
            id_evento: id,
            id_usuario: '<%= usuarioLogado.getId_usuario() %>',
            data_inscricao: new Date().toISOString().split('.')[0],
            status_inscricao: entrarNaFila ? 'Espera' : 'Confirmada',
            metodo_inscricao: 'ingresso',
            posicao_fila: posicaoFila || 0
        };

        for (const chave in campos) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = chave;
            input.value = campos[chave];
            form.appendChild(input);
        }

        document.body.appendChild(form);
        form.submit();
    }

    // =========================================================
    // CHECK-IN
    // O botão fica sempre visível a partir do momento em que o
    // usuário está com inscrição Confirmada, mas só é clicável
    // quando o horário atual está dentro do período do evento.
    // =========================================================

    function estaDentroDoPeriodoEvento(inicioIso, fimIso) {
        const agora = new Date();
        const inicio = new Date(inicioIso);
        const fim = new Date(fimIso);
        return agora >= inicio && agora <= fim;
    }

    function atualizarBotoesCheckin() {
        document.querySelectorAll('.btn-checkin').forEach(function (btn) {
            const inicio = btn.getAttribute('data-inicio');
            const fim = btn.getAttribute('data-fim');
            const dentroDoPeriodo = estaDentroDoPeriodoEvento(inicio, fim);

            btn.classList.toggle('aguardando', !dentroDoPeriodo);

            if (dentroDoPeriodo) {
                btn.textContent = '✅ Fazer Check-in';
                btn.title = 'Confirme sua presença no evento';
            } else {
                const inicioData = new Date(inicio);
                const agora = new Date();
                btn.textContent = agora < inicioData ? '⏳ Check-in indisponível' : '⏳ Check-in encerrado';
                btn.title = agora < inicioData
                    ? 'O check-in só é liberado durante o período do evento'
                    : 'O período do evento já foi encerrado';
            }
        });
    }

    function realizarCheckin(idInscricao, nomeEvento) {
        const btn = document.getElementById('checkinBtn_' + idInscricao);

        if (btn && btn.classList.contains('aguardando')) {
            alert('O check-in só pode ser feito durante o período de acontecimento do evento.');
            return;
        }

        if (!confirm('Confirmar check-in em "' + nomeEvento + '"?')) {
            return;
        }

        window.location.href =
            '${pageContext.request.contextPath}/inscricaoController?action=checkin&id=' + idInscricao;
    }

    atualizarBotoesCheckin();
    setInterval(atualizarBotoesCheckin, 30000);

    // Feedback do check-in após o redirect do controller
    (function feedbackCheckin() {
        const params = new URLSearchParams(window.location.search);
        const status = params.get('checkin');

        if (!status) return;

        if (status === 'ok') {
            alert('Check-in realizado com sucesso!');
        } else {
            const msg = params.get('checkinMsg') || 'Não foi possível realizar o check-in.';
            alert(msg);
        }
    })();

    function renderizarGrid(containerId, lista) {
        document.getElementById(containerId).innerHTML =
            lista.map(criarCardEvento).join('') || '<div class="empty-state" style="grid-column:1/-1;text-align:center;color:#94A3B8;padding:30px;">Nenhum evento encontrado.</div>';
    }

    // =========================================================
    // VISIBILIDADE PÚBLICO x PRIVADO
    // Eventos privados só aparecem na listagem geral quando o
    // usuário digita exatamente o código do evento na busca.
    // Eventos já vinculados ao usuário (inscrito/fila/favorito)
    // continuam visíveis normalmente nas telas específicas deles.
    // =========================================================
    function eventosPublicos() {
        return eventosReais.filter(e => e.tipo === 'publico');
    }

    let categoriaAtivaInicio = 'Todos';

    function aplicarBuscaEventos(termoOriginal) {
        const termo = (termoOriginal || '').trim().toLowerCase();

        let resultado;

        if (!termo) {
            resultado = categoriaAtivaInicio === 'Todos'
                ? eventosPublicos()
                : eventosPublicos().filter(e => e.categoria === categoriaAtivaInicio);
        } else {
            resultado = eventosReais.filter(function (ev) {
                const codigo = (ev.codigo || '').toLowerCase();

                // Evento privado: só entra no resultado com o código EXATO.
                if (ev.tipo === 'privado') {
                    return codigo === termo;
                }

                // Evento público: busca por nome, local ou código (parcial).
                return ev.nome.toLowerCase().includes(termo)
                    || ev.local.toLowerCase().includes(termo)
                    || codigo.includes(termo);
            });
        }

        renderizarGrid('grid-inicio', resultado);
        renderizarGrid('grid-eventos', resultado);
        document.getElementById('contador-eventos').textContent =
            resultado.length + ' evento(s) encontrado(s)';

        return resultado;
    }

    // Início: mostra todos os eventos públicos
    renderizarGrid('grid-inicio', eventosPublicos());

    // Eventos: mostra todos os eventos públicos por padrão
    renderizarGrid('grid-eventos', eventosPublicos());
    document.getElementById('contador-eventos').textContent =
        eventosPublicos().length + ' evento(s) encontrado(s)';

    // Favoritos: só os favoritados (o usuário já conhece o evento,
    // então mostramos mesmo que seja privado)
    const favoritados = eventosReais.filter(e => e.favorito);
    renderizarGrid('grid-favoritos', favoritados);
    document.getElementById('contador-favoritos').textContent =
        favoritados.length + ' evento(s) salvo(s)';

    // Filtro por categoria (pills) na view Início
    document.querySelectorAll('.category-pills .pill').forEach(function (pill) {
        pill.addEventListener('click', function () {
            document.querySelectorAll('.category-pills .pill').forEach(p => p.classList.remove('active'));
            pill.classList.add('active');

            categoriaAtivaInicio = pill.textContent.trim();

            const searchInput = document.getElementById('searchInput');
            aplicarBuscaEventos(searchInput ? searchInput.value : '');
        });
    });

    // =========================================================
    // EXPORTAR PDF (dados reais da tela atual)
    // =========================================================

    // =========================================================
    // HISTÓRICO / INSCRIÇÕES (dados reais, pra modal de detalhes e comprovante)
    // =========================================================

    const historicoData = [
        <%
            for (inscricaoModel insc : minhasInscricoes) {
                eventoModel evI = eventoDAOJsp.buscarPorId(insc.getId_evento());
                if (evI == null) continue;

                String statusLabelJs;
                if ("Cancelada".equals(insc.getStatus_inscricao())) statusLabelJs = "Cancelada";
                else if ("Espera".equals(insc.getStatus_inscricao())) statusLabelJs = "Na lista de espera";
                else statusLabelJs = "Confirmada";

                String checkinJs = insc.getCheckin() != null
                    ? insc.getCheckin().format(fmtDataHora)
                    : "Check-in não realizado";
        %>
        {
            idInscricao: <%= insc.getId_inscricao() %>,
            nome: '<%= js(evI.getNome_evento()) %>',
            categoria: '<%= rotuloCategoria(evI.getCategoria_evento()) %>',
            local: '<%= js(evI.getLocal_evento()) %>',
            codigo: '<%= js(evI.getCodigo_evento()) %>',
            dataEvento: '<%= evI.getInicio_evento().format(fmtDataHora) %>',
            dataInscricao: '<%= insc.getData_inscricao().format(fmtDataHora) %>',
            metodo: '<%= insc.getMetodo_inscricao() %>',
            status: '<%= statusLabelJs %>',
            checkin: '<%= checkinJs %>'
        },
        <%
            }
        %>
    ];

    function abrirDetalheInscricao(idInscricao) {
        const d = historicoData.find(h => h.idInscricao === idInscricao);
        if (!d) return;

        document.getElementById('mi_nome').textContent = d.nome;
        document.getElementById('mi_categoria').textContent = d.categoria;
        document.getElementById('mi_local').textContent = d.local;
        document.getElementById('mi_dataEvento').textContent = d.dataEvento;
        document.getElementById('mi_dataInscricao').textContent = d.dataInscricao;
        document.getElementById('mi_metodo').textContent = d.metodo === 'ingresso' ? 'Ingresso' : 'Código';
        document.getElementById('mi_status').textContent = d.status;
        document.getElementById('mi_checkin').textContent = d.checkin;

        document.getElementById('modalInscricao').classList.add('open');
    }

    function gerarComprovante(idInscricao) {
        const d = historicoData.find(h => h.idInscricao === idInscricao);
        if (!d) return;

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        doc.setFontSize(16);
        doc.text('Comprovante de Inscrição', 14, 20);
        doc.setFontSize(10);
        doc.text('GerenCIA - Sistema de Gestão de Eventos', 14, 27);

        doc.autoTable({
            startY: 36,
            head: [['Campo', 'Valor']],
            body: [
                ['Participante', '<%= js(nomeUsuario) %>'],
                ['CPF', '<%= js(usuarioLogado.getCPF_usuario()) %>'],
                ['Evento', d.nome],
                ['Código do evento', d.codigo],
                ['Categoria', d.categoria],
                ['Local', d.local],
                ['Data do evento', d.dataEvento],
                ['Inscrito em', d.dataInscricao],
                ['Status', d.status]
            ]
        });

        doc.save('comprovante-' + d.codigo + '.pdf');
    }

    function exportarPDF(view) {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        doc.setFontSize(14);

        if (view === 'eventos') {
            doc.text('Explorar Eventos', 14, 18);
            doc.autoTable({
                startY: 26,
                head: [['Evento', 'Categoria', 'Local', 'Data', 'Ocupação']],
                body: eventosReais.map(e => [e.nome, e.categoria, e.local, e.data, e.ocupacao + '%'])
            });
        }

        if (view === 'favoritos') {
            doc.text('Meus Favoritos', 14, 18);
            doc.autoTable({
                startY: 26,
                head: [['Evento', 'Categoria', 'Local', 'Data']],
                body: eventosReais.filter(e => e.favorito).map(e => [e.nome, e.categoria, e.local, e.data])
            });
        }

        if (view === 'meus-eventos') {
            doc.text('Meus Eventos', 14, 18);
            doc.autoTable({
                startY: 26,
                head: [['Evento', 'Status', 'Local', 'Data']],
                body: eventosReais.filter(e => e.meuStatus).map(e => [e.nome, e.meuStatus, e.local, e.data])
            });
        }

        if (view === 'historico') {
            doc.text('Histórico de Participação', 14, 18);
            doc.autoTable({
                startY: 26,
                head: [['Evento', 'Categoria', 'Local', 'Data']],
                body: eventosReais.map(e => [e.nome, e.categoria, e.local, e.data])
            });
        }

        doc.save('relatorio-' + view + '.pdf');
    }

</script>

<!-- ================= MODAL: LISTA DE ESPERA (EVENTO LOTADO) ================= -->
<div class="modal-overlay" id="modalFilaEspera">
    <div class="modal-box" style="max-width:420px;">
        <div class="modal-header">
            <h3>Evento lotado</h3>
            <button class="modal-close" onclick="fecharModalFila()">×</button>
        </div>

        <p style="font-size:13px; color:#475569; margin-bottom:10px;">
            O evento <strong id="fila_nome_evento">—</strong> atingiu a capacidade máxima de participantes confirmados.
        </p>

        <p style="font-size:13px; color:#475569; margin-bottom:6px;">
            Você tem interesse em entrar na lista de espera? 
        </p>

        <div style="background:#F8FAFC; border:1px solid #E2E8F0; border-radius:10px; padding:10px 14px; margin-bottom:18px;">
            <label style="display:block; font-size:10px; color:#94A3B8; text-transform:uppercase; margin-bottom:4px;">Sua posição na fila, caso confirme</label>
            <div id="fila_posicao" style="font-size:16px; font-weight:700; color:#2563EB;">—</div>
        </div>

        <div style="display:flex; gap:10px; justify-content:flex-end;">
            <button class="btn-outline" onclick="fecharModalFila()">Cancelar</button>
            <button class="btn-solid" onclick="confirmarEntradaFila()">Entrar na lista de espera</button>
        </div>
    </div>
</div>

<!-- ================= MODAL: DETALHES DA INSCRIÇÃO ================= -->
<div class="modal-overlay" id="modalInscricao">
    <div class="modal-box">
        <div class="modal-header">
            <h3 id="mi_nome">—</h3>
            <button class="modal-close" onclick="document.getElementById('modalInscricao').classList.remove('open')">×</button>
        </div>

        <div class="modal-row">
            <div class="modal-field"><label>Categoria</label><div class="val" id="mi_categoria">—</div></div>
            <div class="modal-field"><label>Local</label><div class="val" id="mi_local">—</div></div>
        </div>
        <div class="modal-row">
            <div class="modal-field"><label>Data do evento</label><div class="val" id="mi_dataEvento">—</div></div>
            <div class="modal-field"><label>Data da inscrição</label><div class="val" id="mi_dataInscricao">—</div></div>
        </div>
        <div class="modal-row">
            <div class="modal-field"><label>Método</label><div class="val" id="mi_metodo">—</div></div>
            <div class="modal-field"><label>Status</label><div class="val" id="mi_status">—</div></div>
        </div>
        <div class="modal-row">
            <div class="modal-field" style="grid-column:1/-1;"><label>Check-in</label><div class="val" id="mi_checkin">—</div></div>
        </div>
    </div>
</div>

</body>
</html>
