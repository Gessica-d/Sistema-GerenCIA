<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GerenCIA - Recuperar senha</title>

<!-- Ajuste automático de proporções para qualquer tamanho de tela -->
<script src="${pageContext.request.contextPath}/js/responsivo.js"></script>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

<style>

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
        font-family: 'Inter', Arial, Helvetica, sans-serif;
        color: #0F172A;
        background: #F8FAFC;
        min-height: calc(var(--vh, 1vh) * 100);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 24px 16px;
    }

    a { text-decoration: none; }

    .brand {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 24px;
    }

    .brand-icon {
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

    .brand span {
        font-size: 17px;
        font-weight: 700;
        color: #0F172A;
    }

    .card {
        width: 100%;
        max-width: 400px;
        background: #FFFFFF;
        border-radius: 16px;
        box-shadow: 0 12px 32px rgba(2,6,23,0.08);
        padding: 30px 28px;
    }

    .card h1 {
        font-size: 22px;
        margin-bottom: 8px;
    }

    .card p.subtitle {
        font-size: 13px;
        color: #64748B;
        line-height: 1.5;
        margin-bottom: 22px;
    }

    .field { margin-bottom: 18px; }

    .field label {
        display: block;
        font-size: 13px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 6px;
    }

    .field .input-wrap { position: relative; }

    .field input {
        width: 100%;
        height: 44px;
        padding: 0 14px 0 40px;
        border: 1px solid #E2E8F0;
        border-radius: 9px;
        font-size: 14px;
        color: #0F172A;
        background: #F8FAFC;
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
    }

    .btn-block:hover { background: #1D4ED8; }

    .back-link {
        display: block;
        text-align: center;
        margin-top: 18px;
        font-size: 13px;
        color: #64748B;
    }

    .back-link a { color: #2563EB; font-weight: 600; }
    .back-link a:hover { text-decoration: underline; }

    .footer-note {
        text-align: center;
        font-size: 11px;
        color: #94A3B8;
        margin-top: 22px;
        max-width: 380px;
        line-height: 1.6;
    }

    .footer-note a { color: #64748B; text-decoration: underline; }

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
        margin-bottom: 18px;
    }

    .alert-success {
        padding: 14px;
        border-radius: 9px;
        background: #ECFDF5;
        border: 1px solid #A7F3D0;
        color: #065F46;
        font-size: 13px;
        margin-bottom: 18px;
        line-height: 1.5;
    }

    .senha-gerada {
        display: block;
        margin-top: 8px;
        font-size: 16px;
        font-weight: 700;
        letter-spacing: 0.5px;
        color: #0F172A;
        background: #FFFFFF;
        border: 1px dashed #A7F3D0;
        border-radius: 7px;
        padding: 8px 12px;
        text-align: center;
    }

    @media (max-width: 420px) {
        .card { padding: 24px 20px; }
    }

</style>
</head>
<body>

<a href="${pageContext.request.contextPath}/index.html" class="brand">
    <div class="brand-icon">📅</div>
    <span>GerenCIA</span>
</a>

<div class="card">

    <% if (request.getAttribute("senhaGerada") != null) { %>

        <h1>Senha redefinida</h1>
        <p class="subtitle">Use a senha temporária abaixo para entrar. Recomendamos alterá-la assim que possível em "Meu Perfil".</p>

        <div class="alert-success">
            ✅ <%= request.getAttribute("mensagem") %>
            <span class="senha-gerada"><%= request.getAttribute("senhaGerada") %></span>
        </div>

        <a href="${pageContext.request.contextPath}/pages/loginUsuario.jsp" class="btn-block"
           style="display:flex; align-items:center; justify-content:center;">Ir para o login</a>

    <% } else if (request.getAttribute("mensagem") != null) { %>

        <h1>Verifique seu e-mail</h1>

        <div class="alert-success">
            ✅ <%= request.getAttribute("mensagem") %>
        </div>

        <a href="${pageContext.request.contextPath}/pages/loginUsuario.jsp" class="btn-block"
           style="display:flex; align-items:center; justify-content:center;">Voltar ao login</a>

    <% } else { %>

        <h1>Recuperar senha</h1>
        <p class="subtitle">Informe seu e-mail para receber as instruções de redefinição de senha.</p>

        <% if (request.getAttribute("erro") != null) { %>
            <div class="alert-error">⚠️ <%= request.getAttribute("erro") %></div>
        <% } %>

        <form action="${pageContext.request.contextPath}/usuarioController" method="post">

            <input type="hidden" name="action" value="recuperarSenha">

            <div class="field">
                <label for="email_usuario">E-mail</label>
                <div class="input-wrap">
                    <span class="icon">✉️</span>
                    <input type="email" id="email_usuario" name="email_usuario" placeholder="seu@email.com" required>
                </div>
            </div>

            <button type="submit" class="btn-block">Enviar link de recuperação</button>

        </form>

        <div class="back-link">
            <a href="${pageContext.request.contextPath}/pages/loginUsuario.jsp">← Voltar ao login</a>
        </div>

    <% } %>

</div>

<p class="footer-note">
    Ao continuar, você concorda com os <a href="#">Termos de Uso</a> e a <a href="#">Política de Privacidade</a>.
</p>

</body>
</html>
