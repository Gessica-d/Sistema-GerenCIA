<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">

<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GerenCIA - Login</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<link rel="stylesheet" href="css/style.css">

</head>

<body>

<div class="container">

    <div class="left">

        <div class="logo">
            <h1>GerenCIA</h1>
            <p>Gerencie eventos de forma simples e inteligente.</p>
        </div>

        <img
        src="https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=900&q=80"
        alt="Eventos">

    </div>

    <div class="right">

        <div class="login-box">

            <h2>Bem-vindo</h2>

            <p>Faça login para acessar sua conta.</p>

            <form action="LoginServlet" method="post">

                <label>Email</label>

                <input
                    type="email"
                    name="email"
                    placeholder="Digite seu e-mail"
                    required>

                <label>Senha</label>

                <input
                    type="password"
                    name="senha"
                    placeholder="Digite sua senha"
                    required>

                <div class="options">

                    <label>

                        <input type="checkbox">

                        Lembrar-me

                    </label>

                    <a href="esqueciSenha.jsp">
                        Esqueci minha senha
                    </a>

                </div>

                <button type="submit">
                    Entrar
                </button>

            </form>

            <div class="divider">
                ou
            </div>

            <a class="cadastro" href="cadastro.jsp">
                Criar nova conta
            </a>

        </div>

    </div>

</div>

</body>

</html>