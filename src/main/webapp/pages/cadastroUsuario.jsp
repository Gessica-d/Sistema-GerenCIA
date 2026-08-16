<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GerenCIA - Criar conta</title>

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

    .register-page {
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 40px 20px;
        background: linear-gradient(160deg, #020617 0%, #1E3A8A 55%, #2563EB 100%);
    }

    .register-header {
        text-align: center;
        color: #FFFFFF;
        margin-bottom: 26px;
    }

    .register-header .auth-brand-icon {
        margin: 0 auto 14px;
    }

    .register-header h1 {
        font-size: 24px;
        margin-bottom: 6px;
    }

    .register-header p {
        color: #CBD5E1;
        font-size: 14px;
    }

    .register-card {
        width: 100%;
        max-width: 420px;
        background: #FFFFFF;
        border-radius: 16px;
        padding: 32px;
        box-shadow: 0 20px 50px rgba(2, 6, 23, 0.35);
    }

    .fields-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 14px;
    }

    .account-type {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
        margin-bottom: 24px;
    }

    .account-type input[type="radio"] {
        display: none;
    }

    .account-type-card {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 6px;
        text-align: center;
        padding: 16px 10px;
        border: 1.5px solid #E2E8F0;
        border-radius: 10px;
        cursor: pointer;
        transition: 0.15s;
        position: relative;
    }

    .account-type-card .type-icon {
        width: 34px;
        height: 34px;
        border-radius: 9px;
        background: #F1F5F9;
        color: #64748B;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
    }

    .account-type-card strong {
        font-size: 13px;
    }

    .account-type-card small {
        font-size: 11px;
        color: #94A3B8;
    }

    .account-type input[type="radio"]:checked + .account-type-card {
        border-color: #2563EB;
        background: #EFF6FF;
    }

    .account-type input[type="radio"]:checked + .account-type-card .type-icon {
        background: #2563EB;
        color: #FFFFFF;
    }

    .account-type-card .check-dot {
        position: absolute;
        top: 8px;
        right: 8px;
        width: 10px;
        height: 10px;
        border-radius: 50%;
        background: #22C55E;
        display: none;
    }

    .account-type input[type="radio"]:checked + .account-type-card .check-dot {
        display: block;
    }

    @media (max-width: 480px) {
        .fields-row {
            grid-template-columns: 1fr;
        }
    }

</style>

</head>
<body>

<div class="register-page">

    <div class="register-header">
        <a href="${pageContext.request.contextPath}/index.html" style="display:inline-block;">
            <div class="auth-brand-icon">📅</div>
        </a>
        <h1>Criar sua conta</h1>
        <p>Junte-se ao GerenCIA e gerencie eventos</p>
    </div>

    <div class="register-card">

        <% if (request.getAttribute("erro") != null) { %>
            <div class="alert-error">
                ⚠️ <%= request.getAttribute("erro") %>
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/usuarioController" method="post">

            <input type="hidden" name="action" value="novo">

            <div class="field">
                <label for="CPF_usuario">CPF</label>
                <div class="input-wrap">
                    <span class="icon">🪪</span>
                    <input
                        type="text"
                        id="CPF_usuario"
                        name="CPF_usuario"
                        placeholder="000.000.000-00"
                        maxlength="11"
                        required>
                </div>
            </div>

            <div class="field">
                <label for="nome_usuario">Nome completo</label>
                <div class="input-wrap">
                    <span class="icon">👤</span>
                    <input
                        type="text"
                        id="nome_usuario"
                        name="nome_usuario"
                        placeholder="Maria da Silva"
                        required>
                </div>
            </div>

            <div class="field">
                <label for="email_usuario">E-mail</label>
                <div class="input-wrap">
                    <span class="icon">✉️</span>
                    <input
                        type="email"
                        id="email_usuario"
                        name="email_usuario"
                        placeholder="maria@email.com"
                        required>
                </div>
            </div>

            <div class="fields-row">

                <div class="field">
                    <label for="senha_usuario">Senha</label>
                    <div class="input-wrap">
                        <span class="icon">🔒</span>
                        <input
                            type="password"
                            id="senha_usuario"
                            name="senha_usuario"
                            placeholder="••••••••"
                            minlength="6"
                            required>
                    </div>
                </div>

                <div class="field">
                    <label for="telefone">Telefone</label>
                    <div class="input-wrap">
                        <span class="icon">📱</span>
                        <input
                            type="tel"
                            id="telefone"
                            name="telefone"
                            placeholder="(11) 99999-9999"
                            required>
                    </div>
                </div>

            </div>

            <label style="display:block; font-size:13px; font-weight:600; color:#334155; margin-bottom:10px;">
                Tipo de conta
            </label>

            <div class="account-type">

                <label>
                    <input type="radio" name="tipo_usuario" value="usuarioFinal" checked>
                    <div class="account-type-card">
                        <span class="check-dot"></span>
                        <div class="type-icon">👤</div>
                        <strong>Cliente</strong>
                        <small>Descubra e participe de eventos</small>
                    </div>
                </label>

                <label>
                    <input type="radio" name="tipo_usuario" value="organizador">
                    <div class="account-type-card">
                        <span class="check-dot"></span>
                        <div class="type-icon">🏢</div>
                        <strong>Organizador</strong>
                        <small>Crie e gerencie seus eventos</small>
                    </div>
                </label>

            </div>

            <button type="submit" class="btn-block">Criar conta</button>

        </form>

        <div class="divider">ou</div>

        <p class="auth-footer-link">
            Já possui conta?
            <a href="${pageContext.request.contextPath}/pages/loginUsuario.jsp">Entrar</a>
        </p>

    </div>

</div>

</body>
</html>
