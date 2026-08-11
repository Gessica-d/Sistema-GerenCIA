<%@ page contentType="text/html; charset=UTF-8"%>

<!DOCTYPE html>
<html lang="pt-BR">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>GerenCIA - Entrar</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

<style>

    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: 'Inter', Arial, Helvetica, sans-serif;
        color: #0F172A;
    }

    a {
        text-decoration: none;
    }

    /* ================= LAYOUT ================= */

    .auth-split {
        min-height: 100vh;
        display: grid;
        grid-template-columns: 1.05fr 1fr;
    }

    /* ================= LADO ESQUERDO ================= */

    .auth-side {
        position: relative;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        padding: 48px 56px;

        background: linear-gradient(
            160deg,
            #020617 0%,
            #1E3A8A 60%,
            #2563EB 100%
        );

        color: #FFFFFF;
        overflow: hidden;
    }

    .auth-side::after {
        content: "";
        position: absolute;
        inset: 0;

        background: radial-gradient(
            circle at 30% 100%,
            rgba(255,255,255,0.10),
            transparent 55%
        );

        pointer-events: none;
    }

    /* ================= MARCA ================= */

    .auth-brand {
        display: flex;
        align-items: center;
        gap: 10px;
        z-index: 1;
    }

    .auth-brand-icon {
        width: 38px;
        height: 38px;
        border-radius: 10px;

        background: rgba(255,255,255,0.14);

        display: flex;
        align-items: center;
        justify-content: center;

        font-size: 18px;
    }

    .auth-brand span {
        font-size: 18px;
        font-weight: 700;
    }

    /* ================= TEXTO LATERAL ================= */

    .auth-badge {
        z-index: 1;

        display: inline-flex;
        align-items: center;
        gap: 8px;

        width: fit-content;

        padding: 7px 12px;
        border-radius: 20px;

        background: rgba(255,255,255,0.12);

        font-size: 12px;
        font-weight: 600;

        margin-top: 40px;
    }

    .auth-badge-dot {
        width: 7px;
        height: 7px;

        border-radius: 50%;

        background: #4ADE80;
    }

    .auth-side h1 {
        z-index: 1;

        font-size: 36px;
        line-height: 1.2;
        letter-spacing: -0.5px;

        margin-top: 18px;

        max-width: 420px;
    }

    .auth-side h1 span {
        color: #93C5FD;
    }

    .auth-side p {
        z-index: 1;

        max-width: 380px;

        margin-top: 14px;

        color: #CBD5E1;

        font-size: 14px;
        line-height: 1.6;
    }

    /* ================= ESTATÍSTICAS ================= */

    .auth-stats {
        z-index: 1;

        display: flex;
        gap: 36px;

        margin-top: auto;
    }

    .auth-stats strong {
        display: block;
        font-size: 24px;
    }

    .auth-stats span {
        display: block;

        margin-top: 4px;

        font-size: 12px;
        color: #CBD5E1;
    }

    /* ================= FORMULÁRIO ================= */

    .auth-form-wrap {
        display: flex;
        align-items: center;
        justify-content: center;

        padding: 40px 24px;

        background: #FFFFFF;
    }

    .auth-form {
        width: 100%;
        max-width: 380px;
    }

    .auth-form h2 {
        font-size: 26px;
        margin-bottom: 6px;
    }

    .auth-form > p.subtitle {
        color: #64748B;

        font-size: 14px;

        margin-bottom: 28px;
    }

    /* ================= CAMPOS ================= */

    .field {
        margin-bottom: 18px;
    }

    .field label {
        display: block;

        font-size: 13px;
        font-weight: 600;

        color: #334155;

        margin-bottom: 6px;
    }

    .field .input-wrap {
        position: relative;
    }

    .field input {
        width: 100%;
        height: 44px;

        padding: 0 14px 0 40px;

        border: 1px solid #E2E8F0;
        border-radius: 9px;

        font-size: 14px;

        color: #0F172A;
        background: #F8FAFC;

        transition: 0.15s;
    }

    .field input:focus {
        outline: none;

        border-color: #2563EB;

        background: #FFFFFF;

        box-shadow: 0 0 0 3px rgba(37,99,235,0.12);
    }

    .field .icon {
        position: absolute;

        left: 13px;
        top: 50%;

        transform: translateY(-50%);

        font-size: 15px;

        color: #94A3B8;
    }

    /* ================= ERRO ================= */

    .field-error {
        margin-top: 6px;

        font-size: 12px;

        color: #DC2626;
    }

    .alert-error {
        display: flex;
        align-items: center;
        gap: 8px;

        padding: 12px 14px;

        border-radius: 9px;

        background: #FEF2F2;

        border: 1px solid #FECACA;

        color: #B91C1C;

        font-size: 13px;

        margin-bottom: 20px;
    }

    /* ================= OPÇÕES ================= */

    .form-options {
        display: flex;

        align-items: center;
        justify-content: space-between;

        margin-bottom: 22px;

        font-size: 13px;
    }

    .form-options label {
        display: flex;
        align-items: center;

        gap: 6px;

        color: #475569;

        cursor: pointer;
    }

    .form-options a {
        color: #2563EB;

        font-weight: 600;
    }

    .form-options a:hover {
        text-decoration: underline;
    }

    /* ================= BOTÃO ================= */

    .btn-block {
        width: 100%;
        height: 46px;

        border: none;
        border-radius: 9px;

        background: #2563EB;

        color: #FFFFFF;

        font-size: 14px;
        font-weight: 600;

        cursor: pointer;

        transition: 0.15s;
    }

    .btn-block:hover {
        background: #1D4ED8;
    }

    /* ================= DIVISOR ================= */

    .divider {
        display: flex;

        align-items: center;

        gap: 12px;

        margin: 22px 0;

        color: #94A3B8;

        font-size: 12px;
    }

    .divider::before,
    .divider::after {
        content: "";

        flex: 1;

        height: 1px;

        background: #E2E8F0;
    }

    /* ================= RODAPÉ ================= */

    .auth-footer-link {
        text-align: center;

        font-size: 14px;

        color: #64748B;
    }

    .auth-footer-link a {
        color: #2563EB;

        font-weight: 600;
    }

    .auth-footer-link a:hover {
        text-decoration: underline;
    }

    /* ================= RESPONSIVO ================= */

    @media (max-width: 850px) {

        .auth-split {
            grid-template-columns: 1fr;
        }

        .auth-side {
            display: none;
        }

    }

</style>

</head>

<body>

<div class="auth-split">

    <!-- ================================================= -->
    <!-- LADO ESQUERDO -->
    <!-- ================================================= -->

    <div class="auth-side">

        <a href="${pageContext.request.contextPath}/index.html"
           class="auth-brand">

            <div class="auth-brand-icon">
                📅
            </div>

            <span>GerenCIA</span>

        </a>


        <div>

            <div class="auth-badge">

                <span class="auth-badge-dot"></span>

                Plataforma líder em gestão de eventos

            </div>


            <h1>
                Organize eventos
                <span>com inteligência</span>
            </h1>


            <p>
                Gerencie inscrições, fornecedores, check-in
                e muito mais em uma única plataforma.
            </p>

        </div>


        <div class="auth-stats">

            <div>

                <strong>12.400+</strong>

                <span>
                    Eventos realizados
                </span>

            </div>


            <div>

                <strong>840K+</strong>

                <span>
                    Participantes
                </span>

            </div>


            <div>

                <strong>98%</strong>

                <span>
                    Satisfação
                </span>

            </div>

        </div>

    </div>


    <!-- ================================================= -->
    <!-- LADO DIREITO - FORMULÁRIO -->
    <!-- ================================================= -->

    <div class="auth-form-wrap">

        <div class="auth-form">

            <h2>
                Bem-vindo de volta
            </h2>

            <p class="subtitle">
                Gerencie eventos de forma simples e inteligente.
            </p>


            <!-- Mensagem de erro enviada pelo Controller -->

            <% if (request.getAttribute("erro") != null) { %>

                <div class="alert-error">

                    ⚠️

                    <%= request.getAttribute("erro") %>

                </div>

            <% } %>


            <!-- ================================================= -->
            <!-- FORMULÁRIO DE LOGIN -->
            <!-- ================================================= -->

            <form
                action="${pageContext.request.contextPath}/usuarioController"
                method="post">


                <!-- Informa ao UsuarioController qual ação executar -->

                <input
                    type="hidden"
                    name="action"
                    value="login">


                <!-- E-MAIL -->

                <div class="field">

                    <label for="email_usuario">
                        E-mail
                    </label>


                    <div class="input-wrap">

                        <span class="icon">
                            ✉️
                        </span>


                        <input
                            type="email"
                            id="email_usuario"
                            name="email_usuario"
                            placeholder="seu@email.com"
                            required>

                    </div>

                </div>


                <!-- SENHA -->

                <div class="field">

                    <label for="senha_usuario">
                        Senha
                    </label>


                    <div class="input-wrap">

                        <span class="icon">
                            🔒
                        </span>


                        <input
                            type="password"
                            id="senha_usuario"
                            name="senha_usuario"
                            placeholder="••••••••"
                            required>

                    </div>

                </div>


                <!-- OPÇÕES -->

                <div class="form-options">

                    <label>

                        <input
                            type="checkbox"
                            name="lembrar">

                        Lembrar-me

                    </label>


                    <a href="${pageContext.request.contextPath}/pages/esqueciSenha.jsp">

                        Esqueci minha senha

                    </a>

                </div>


                <!-- BOTÃO ENTRAR -->

                <button
                    type="submit"
                    class="btn-block">

                    Entrar

                </button>

            </form>


            <!-- DIVISOR -->

            <div class="divider">
                ou
            </div>


            <!-- CADASTRO -->

            <p class="auth-footer-link">

                Não possui conta?

                <a href="${pageContext.request.contextPath}/pages/cadastroUsuario.jsp">

                    Criar conta

                </a>

            </p>

        </div>

    </div>

</div>

</body>
</html>