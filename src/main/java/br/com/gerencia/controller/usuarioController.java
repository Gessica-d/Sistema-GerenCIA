package br.com.gerencia.controller;

import br.com.gerencia.dao.usuarioDAO;
import br.com.gerencia.model.usuarioModel;
import br.com.gerencia.utils.Conexao;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

@WebServlet("/usuarioController")
public class usuarioController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private usuarioDAO usuarioDAO;

    @Override
    public void init() {

        try {

            Connection conexao = Conexao.getConnection();

            usuarioDAO = new usuarioDAO(conexao);

        } catch (Exception e) {

            throw new RuntimeException(
                "Erro ao iniciar usuarioDAO: " + e.getMessage()
            );
        }
    }

   
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {

            String action = request.getParameter("action");

            if ("logout".equals(action)) {

                logoutUsuario(request, response);
                return;
            }

            if ("excluir".equals(action)) {

                excluirUsuario(request, response);
                return;
            }

            if ("redefinirSenha".equals(action)) {

                redefinirSenhaAdmin(request, response);
                return;
            }

            listarUsuarios(request, response);

        } catch (Exception e) {

            throw new ServletException(e);
        }
    }


    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if (action == null) {
            action = "listar";
        }

        try {

            switch (action) {

                case "novo":
                    cadastrarUsuario(request, response);
                    break;

                case "novoAdmin":
                    cadastrarUsuarioAdmin(request, response);
                    break;

                case "login":
                    autenticarUsuario(request, response);
                    break;

                case "logout":
                    logoutUsuario(request, response);
                    break;

                case "alterarSenha":
                    alterarSenha(request, response);
                    break;

                case "excluir":
                    excluirUsuario(request, response);
                    break;

                case "atualizar":
                    atualizarUsuario(request, response);
                    break;

                case "recuperarSenha":
                    recuperarSenha(request, response);
                    break;

                default:
                    listarUsuarios(request, response);
                    break;
            }

        } catch (Exception e) {

            throw new ServletException(e);
        }
    }


    // Cadastrar user

    private void cadastrarUsuario(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        String cpf =
            request.getParameter("CPF_usuario");

        String tipoUsuario =
            request.getParameter("tipo_usuario");

        String nome =
            request.getParameter("nome_usuario");

        String email =
            request.getParameter("email_usuario");

        String senha =
            request.getParameter("senha_usuario");

        String telefone =
            request.getParameter("telefone");

        // =================================================
        // VALIDAÇÕES
        // =================================================

        if (cpf == null || cpf.isBlank()) {
            throw new Exception("CPF obrigatório");
        }

        if (tipoUsuario == null || tipoUsuario.isBlank()) {
            throw new Exception("Tipo de usuário obrigatório");
        }

        if (nome == null || nome.isBlank()) {
            throw new Exception("Nome obrigatório");
        }

        if (email == null || !email.contains("@")) {
            throw new Exception("Email inválido");
        }

        if (senha == null || senha.isBlank()) {
            throw new Exception("Senha obrigatória");
        }

        if (telefone == null || telefone.isBlank()) {
            throw new Exception("Telefone obrigatório");
        }

        if (usuarioDAO.buscarPorCPF(cpf) != null) {

            request.setAttribute("erro", "Já existe uma conta cadastrada com esse CPF");

            request.getRequestDispatcher("/pages/cadastroUsuario.jsp")
                .forward(request, response);

            return;
        }

        if (usuarioDAO.buscarPorEmail(email) != null) {

            request.setAttribute("erro", "Já existe uma conta cadastrada com esse e-mail");

            request.getRequestDispatcher("/pages/cadastroUsuario.jsp")
                .forward(request, response);

            return;
        }

        usuarioModel usuario =
            new usuarioModel(
                cpf,
                tipoUsuario,
                nome,
                email,
                senha,
                telefone
            );

        usuarioDAO.adicionarUsuario(usuario);

       
        // APÓS CADASTRAR
        
        response.sendRedirect(
            request.getContextPath()
            + "/pages/loginUsuario.jsp"
        );
    }

    // cadastro admin
    
    private void cadastrarUsuarioAdmin(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        HttpSession session = request.getSession(false);

        usuarioModel admLogado = session != null
            ? (usuarioModel) session.getAttribute("usuarioLogado")
            : null;

        if (admLogado == null || !"admin".equals(admLogado.getTipo_usuario())) {

            response.sendRedirect(
                request.getContextPath()
                + "/pages/loginUsuario.jsp"
            );

            return;
        }

        String cpf =
            request.getParameter("CPF_usuario");

        String tipoUsuario =
            request.getParameter("tipo_usuario");

        String nome =
            request.getParameter("nome_usuario");

        String email =
            request.getParameter("email_usuario");

        String senha =
            request.getParameter("senha_usuario");

        String telefone =
            request.getParameter("telefone");

        if (cpf == null || cpf.isBlank()
                || tipoUsuario == null || tipoUsuario.isBlank()
                || nome == null || nome.isBlank()
                || email == null || !email.contains("@")
                || senha == null || senha.isBlank()
                || telefone == null || telefone.isBlank()) {

            throw new Exception(
                "Todos os campos são obrigatórios para cadastrar um usuário"
            );
        }

        if (usuarioDAO.buscarPorCPF(cpf) != null) {

            session.setAttribute("flashMsg", "Já existe uma conta cadastrada com esse CPF.");

            response.sendRedirect(request.getContextPath() + "/pages/homeAdmin.jsp?view=usuarios");

            return;
        }

        if (usuarioDAO.buscarPorEmail(email) != null) {

            session.setAttribute("flashMsg", "Já existe uma conta cadastrada com esse e-mail.");

            response.sendRedirect(request.getContextPath() + "/pages/homeAdmin.jsp?view=usuarios");

            return;
        }

        usuarioModel usuario =
            new usuarioModel(
                cpf,
                tipoUsuario,
                nome,
                email,
                senha,
                telefone
            );

        usuarioDAO.adicionarUsuario(usuario);

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeAdmin.jsp"
        );
    }

    // login

    private void autenticarUsuario(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        String email =
            request.getParameter("email_usuario");

        String senha =
            request.getParameter("senha_usuario");

        // validar login

        if (email == null || email.isBlank()
                || senha == null || senha.isBlank()) {

            request.setAttribute(
                "erro",
                "Email e senha são obrigatórios"
            );

            RequestDispatcher dispatcher =
                request.getRequestDispatcher(
                    "/pages/loginUsuario.jsp"
                );

            dispatcher.forward(request, response);

            return;
        }

        // buscar user

        usuarioModel usuario =
            usuarioDAO.buscarPorEmailESenha(
                email,
                senha
            );

        //login correto
        if (usuario != null) {

            HttpSession session =
                request.getSession(true);

            session.setAttribute(
                "usuarioLogado",
                usuario
            );

            String destino = "/pages/home.jsp";

            if ("organizador".equals(usuario.getTipo_usuario())) {
                destino = "/pages/homeOrganizador.jsp";
            } else if ("admin".equals(usuario.getTipo_usuario())) {
                destino = "/pages/homeAdmin.jsp";
            }

            response.sendRedirect(
                request.getContextPath()
                + destino
            );

        }

        // login errado 

        else {

            request.setAttribute(
                "erro",
                "Email ou senha inválidos"
            );

            RequestDispatcher dispatcher =
                request.getRequestDispatcher(
                    "/pages/loginUsuario.jsp"
                );

            dispatcher.forward(request, response);
        }
    }

    // mudar senha

    private void alterarSenha(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        HttpSession session =
            request.getSession(false);

        if (session == null) {

            response.sendRedirect(
                request.getContextPath()
                + "/pages/loginUsuario.jsp"
            );

            return;
        }

        usuarioModel usuarioLogado =
            (usuarioModel) session.getAttribute(
                "usuarioLogado"
            );

        if (usuarioLogado == null) {

            response.sendRedirect(
                request.getContextPath()
                + "/pages/loginUsuario.jsp"
            );

            return;
        }

        String senhaAtual =
            request.getParameter("senhaAtual");

        String novaSenha =
            request.getParameter("novaSenha");

        String confirmarSenha =
            request.getParameter("confirmarSenha");

        if (novaSenha == null
                || !novaSenha.equals(confirmarSenha)) {

            request.setAttribute(
                "erro",
                "A nova senha e a confirmação não são iguais"
            );

            response.sendRedirect(
                request.getContextPath()
                + "/pages/perfil.jsp"
            );

            return;
        }

        usuarioModel usuarioBanco =
            usuarioDAO.buscarPorEmailESenha(
                usuarioLogado.getEmail_usuario(),
                senhaAtual
            );

        if (usuarioBanco == null) {

            response.sendRedirect(
                request.getContextPath()
                + "/pages/perfil.jsp"
            );

            return;
        }

        usuarioDAO.alterarSenha(
            usuarioLogado.getId_usuario(),
            novaSenha
        );

        usuarioLogado.setSenha_usuario(novaSenha);

        session.setAttribute(
            "usuarioLogado",
            usuarioLogado
        );

        response.sendRedirect(
            request.getContextPath()
            + "/pages/perfil.jsp"
        );
    }

    // admin redefine senha

    private void redefinirSenhaAdmin(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        HttpSession session = request.getSession(false);

        usuarioModel admLogado = session != null
            ? (usuarioModel) session.getAttribute("usuarioLogado")
            : null;

        if (admLogado == null || !"admin".equals(admLogado.getTipo_usuario())) {

            response.sendRedirect(
                request.getContextPath()
                + "/pages/loginUsuario.jsp"
            );

            return;
        }

        String idParametro = request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {
            throw new Exception("ID do usuário não informado");
        }

        int idUsuario = Integer.parseInt(idParametro);

        String senhaTemporaria = "Gerencia@123";

        usuarioDAO.alterarSenha(idUsuario, senhaTemporaria);

        session.setAttribute(
            "flashMsg",
            "Senha redefinida com sucesso. Nova senha temporária: " + senhaTemporaria
        );

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeAdmin.jsp"
        );
    }

    // excluir usuario
    private void excluirUsuario(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {

            throw new Exception(
                "ID do usuário não informado"
            );
        }

        int idUsuario =
            Integer.parseInt(idParametro);

        usuarioDAO.excluirUsuario(idUsuario);

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeAdmin.jsp"
        );
    }

    // atualizar info cadastro em "meu perfil"
    private void atualizarUsuario(HttpServletRequest request,
                                  HttpServletResponse response)
            throws Exception {

        String idParametro = request.getParameter("id_usuario");

        if (idParametro == null || idParametro.isBlank()) {
            throw new Exception("ID do usuário não informado");
        }

        int idUsuario = Integer.parseInt(idParametro);

        usuarioModel usuarioAtual = usuarioDAO.buscarPorId(idUsuario);

        if (usuarioAtual == null) {
            throw new Exception("Usuário não encontrado");
        }

        String nome = request.getParameter("nome_usuario");
        String email = request.getParameter("email_usuario");
        String telefone = request.getParameter("telefone");

        if (nome != null && !nome.isBlank()) {
            usuarioAtual.setNome_usuario(nome);
        }

        if (email != null && !email.isBlank()) {

            if (!email.contains("@")) {
                throw new Exception("Email inválido");
            }

            usuarioAtual.setEmail_usuario(email);
        }

        if (telefone != null && !telefone.isBlank()) {
            usuarioAtual.setTelefone(telefone);
        }

        usuarioDAO.atualizarUsuario(usuarioAtual);

        // Mantém a sessão sincronizada com o que acabou de ser salvo.
        HttpSession session = request.getSession(false);

        if (session != null) {

            usuarioModel logado =
                (usuarioModel) session.getAttribute("usuarioLogado");

            if (logado != null && logado.getId_usuario() == idUsuario) {
                session.setAttribute("usuarioLogado", usuarioAtual);
            }
        }

        String destino = "/pages/home.jsp";

        if ("organizador".equals(usuarioAtual.getTipo_usuario())) {
            destino = "/pages/homeOrganizador.jsp?view=perfil";
        } else if ("admin".equals(usuarioAtual.getTipo_usuario())) {
            destino = "/pages/homeAdmin.jsp";
        }

        response.sendRedirect(request.getContextPath() + destino);
    }

   
    // esqueci minha senha 
    // senha temporária é exibida na própria tela de confirmação

    private void recuperarSenha(HttpServletRequest request,
                                HttpServletResponse response)
            throws Exception {

        String email = request.getParameter("email_usuario");

        if (email == null || email.isBlank()) {

            request.setAttribute("erro", "Informe um e-mail");

            request.getRequestDispatcher("/pages/esqueciSenha.jsp")
                .forward(request, response);

            return;
        }

        usuarioModel usuario = usuarioDAO.buscarPorEmail(email);

        if (usuario == null) {

            // Por segurança, não revela se o e-mail existe ou não no banco.
            request.setAttribute(
                "mensagem",
                "Se esse e-mail estiver cadastrado, as instruções de recuperação foram geradas."
            );

            request.getRequestDispatcher("/pages/esqueciSenha.jsp")
                .forward(request, response);

            return;
        }

        String senhaTemporaria = "Gerencia@" + (100 + new java.util.Random().nextInt(900));

        usuarioDAO.alterarSenha(usuario.getId_usuario(), senhaTemporaria);

        request.setAttribute(
            "mensagem",
            "Sua senha foi redefinida. Use a senha temporária abaixo para entrar e depois altere-a em \"Meu Perfil\"."
        );

        request.setAttribute("senhaGerada", senhaTemporaria);

        request.getRequestDispatcher("/pages/esqueciSenha.jsp")
            .forward(request, response);
    }

    private void logoutUsuario(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        HttpSession session =
            request.getSession(false);

        if (session != null) {
            session.invalidate();
        }

        response.sendRedirect(
            request.getContextPath()
            + "/pages/loginUsuario.jsp"
        );
    }

    // listar users

    private void listarUsuarios(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        List<usuarioModel> lista =
            usuarioDAO.listarUsuarios();

        request.setAttribute(
            "listaUsuarios",
            lista
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/listaUsuarios.jsp"
            );

        dispatcher.forward(request, response);
    }
}
