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

    // ================= INIT =================
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

    // ================= GET =================
    @Override
    protected void doGet(HttpServletRequest request,
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

            listarUsuarios(request, response);

        } catch (Exception e) {

            throw new ServletException(e);
        }
    }

    // ================= POST =================
    @Override
    protected void doPost(HttpServletRequest request,
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

                default:
                    listarUsuarios(request, response);
                    break;
            }

        } catch (Exception e) {

            throw new ServletException(e);
        }
    }

    // ================= CADASTRAR =================
    private void cadastrarUsuario(HttpServletRequest request,
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

        // ================= VALIDAÇÕES =================

        if (cpf == null || cpf.isBlank()) {
            throw new Exception("CPF obrigatório");
        }

        if (tipoUsuario == null || tipoUsuario.isBlank()) {
            throw new Exception(
                "Tipo de usuário obrigatório"
            );
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

        tipoUsuario = tipoUsuario.toUpperCase();

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
            + "/pages/login.jsp"
        );
    }

    // ================= LOGIN =================
    private void autenticarUsuario(HttpServletRequest request,
                                   HttpServletResponse response)
            throws Exception {

        String email =
            request.getParameter("email_usuario");

        String senha =
            request.getParameter("senha_usuario");

        if (email == null || email.isBlank()
                || senha == null || senha.isBlank()) {

            request.setAttribute(
                "erro",
                "Email e senha são obrigatórios"
            );

            RequestDispatcher dispatcher =
                request.getRequestDispatcher(
                    "/pages/login.jsp"
                );

            dispatcher.forward(request, response);
            return;
        }

        usuarioModel usuario =
            usuarioDAO.buscarPorEmailESenha(
                email,
                senha
            );

        if (usuario != null) {

            HttpSession session =
                request.getSession(true);

            session.setAttribute(
                "usuarioLogado",
                usuario
            );

            response.sendRedirect(
                request.getContextPath()
                + "/pages/home.jsp"
            );

        } else {

            request.setAttribute(
                "erro",
                "Email ou senha inválidos"
            );

            RequestDispatcher dispatcher =
                request.getRequestDispatcher(
                    "/pages/login.jsp"
                );

            dispatcher.forward(request, response);
        }
    }

    // ================= ALTERAR SENHA =================
    private void alterarSenha(HttpServletRequest request,
                              HttpServletResponse response)
            throws Exception {

        HttpSession session =
            request.getSession(false);

        if (session == null) {

            response.sendRedirect(
                request.getContextPath()
                + "/pages/login.jsp"
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
                + "/pages/login.jsp"
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

    // ================= EXCLUIR =================
    private void excluirUsuario(HttpServletRequest request,
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
            + "/usuarioController?action=listar"
        );
    }

    // ================= LOGOUT =================
    private void logoutUsuario(HttpServletRequest request,
                               HttpServletResponse response)
            throws Exception {

        HttpSession session =
            request.getSession(false);

        if (session != null) {
            session.invalidate();
        }

        response.sendRedirect(
            request.getContextPath()
            + "/pages/login.jsp"
        );
    }

    // ================= LISTAR =================
    private void listarUsuarios(HttpServletRequest request,
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