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

    // =========================================================
    // INIT
    // =========================================================

    @Override
    public void init() throws ServletException {

        try {

            Connection conexao = Conexao.getConnection();

            usuarioDAO = new usuarioDAO(conexao);

        } catch (Exception e) {

            throw new ServletException(
                "Erro ao iniciar usuarioDAO: " + e.getMessage(),
                e
            );
        }
    }

    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {

            String action = request.getParameter("action");

            // =====================================================
            // LOGOUT
            // =====================================================

            if ("logout".equals(action)) {

                logoutUsuario(request, response);
                return;
            }

            // =====================================================
            // BUSCAR USUÁRIO
            // =====================================================

            if ("buscar".equals(action)) {

                buscarUsuario(request, response);
                return;
            }

            // =====================================================
            // EXCLUIR USUÁRIO
            // =====================================================

            if ("excluir".equals(action)) {

                excluirUsuario(request, response);
                return;
            }

            // =====================================================
            // REDEFINIR SENHA PELO ADMIN
            // =====================================================

            if ("redefinirSenha".equals(action)) {

                redefinirSenhaAdmin(request, response);
                return;
            }

            // =====================================================
            // LISTAR
            // =====================================================
            //
            // Se action=listar ou se não houver action,
            // busca os usuários no banco.
            //

            listarUsuarios(request, response);

        } catch (Exception e) {

            throw new ServletException(
                "Erro no usuarioController: " + e.getMessage(),
                e
            );
        }
    }

    // =========================================================
    // POST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if (action == null || action.isBlank()) {

            action = "listar";
        }

        try {

            switch (action) {

                // =================================================
                // CADASTRO NORMAL
                // =================================================

                case "novo":

                    cadastrarUsuario(request, response);
                    break;

                // =================================================
                // CADASTRO FEITO PELO ADMIN
                // =================================================

                case "novoAdmin":

                    cadastrarUsuarioAdmin(request, response);
                    break;

                // =================================================
                // LOGIN
                // =================================================

                case "login":

                    realizarLogin(request, response);
                    break;

                // =================================================
                // LOGOUT
                // =================================================

                case "logout":

                    logoutUsuario(request, response);
                    break;

                // =================================================
                // ALTERAR SENHA
                // =================================================

                case "alterarSenha":

                    alterarSenha(request, response);
                    break;

                // =================================================
                // REDEFINIR SENHA PELO ADMIN
                // =================================================

                case "redefinirSenha":

                    redefinirSenhaAdmin(request, response);
                    break;

                // =================================================
                // EXCLUIR
                // =================================================

                case "excluir":

                    excluirUsuario(request, response);
                    break;

                // =================================================
                // ATUALIZAR PERFIL
                // =================================================

                case "atualizar":

                    atualizarUsuario(request, response);
                    break;

                // =================================================
                // EDITAR USUÁRIO COMPLETO
                // =================================================

                case "editar":

                    editarUsuario(request, response);
                    break;

                // =================================================
                // LISTAR
                // =================================================

                default:

                    listarUsuarios(request, response);
                    break;
            }

        } catch (Exception e) {

            throw new ServletException(
                "Erro no usuarioController: " + e.getMessage(),
                e
            );
        }
    }

    // =========================================================
    // LOGIN
    // =========================================================

    private void realizarLogin(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        String email =
            request.getParameter("email_usuario");

        String senha =
            request.getParameter("senha_usuario");

        // =====================================================
        // REMOVE ESPAÇOS DO E-MAIL
        // =====================================================

        if (email != null) {

            email = email.trim();
        }

        // =====================================================
        // VERIFICA CAMPOS
        // =====================================================

        if (email == null || email.isEmpty()
                || senha == null || senha.isEmpty()) {

            request.setAttribute(
                "erroLogin",
                "Informe o e-mail e a senha."
            );

            // Mantém também "erro" para compatibilidade
            // com versões mais recentes da tela de login.

            request.setAttribute(
                "erro",
                "Informe o e-mail e a senha."
            );

            RequestDispatcher dispatcher =
                request.getRequestDispatcher(
                    "/pages/loginUsuario.jsp"
                );

            dispatcher.forward(request, response);

            return;
        }

        // =====================================================
        // BUSCA USUÁRIO NO BANCO
        // =====================================================

        usuarioModel usuario =
            usuarioDAO.buscarPorEmailESenha(
                email,
                senha
            );

        // =====================================================
        // USUÁRIO NÃO ENCONTRADO
        // =====================================================

        if (usuario == null) {

            request.setAttribute(
                "erroLogin",
                "E-mail ou senha incorretos."
            );

            request.setAttribute(
                "erro",
                "E-mail ou senha incorretos."
            );

            RequestDispatcher dispatcher =
                request.getRequestDispatcher(
                    "/pages/loginUsuario.jsp"
                );

            dispatcher.forward(request, response);

            return;
        }

        // =====================================================
        // CRIA SESSÃO
        // =====================================================

        HttpSession session =
            request.getSession(true);

        session.setAttribute(
            "usuarioLogado",
            usuario
        );

        // =====================================================
        // IDENTIFICA TIPO DO USUÁRIO
        // =====================================================

        String tipoUsuario =
            usuario.getTipo_usuario();

        if (tipoUsuario != null) {

            tipoUsuario = tipoUsuario.trim();
        }

        // =====================================================
        // ADMINISTRADOR
        // =====================================================
        //
        // IMPORTANTE:
        //
        // O admin NÃO vai diretamente para homeAdmin.jsp.
        //
        // Primeiro passa pelo controller, que busca os
        // usuários no banco e coloca a lista na requisição.
        //

        if ("admin".equalsIgnoreCase(tipoUsuario)) {

            response.sendRedirect(
                request.getContextPath()
                + "/usuarioController?action=listar"
            );

            return;
        }

        // =====================================================
        // ORGANIZADOR
        // =====================================================

        if ("organizador".equalsIgnoreCase(tipoUsuario)) {

            response.sendRedirect(
                request.getContextPath()
                + "/pages/homeOrganizador.jsp"
            );

            return;
        }

        // =====================================================
        // CLIENTE
        // =====================================================

        if ("cliente".equalsIgnoreCase(tipoUsuario)
                || "usuarioFinal".equalsIgnoreCase(tipoUsuario)) {

            response.sendRedirect(
                request.getContextPath()
                + "/pages/home.jsp"
            );

            return;
        }

        // =====================================================
        // TIPO NÃO RECONHECIDO
        // =====================================================

        request.setAttribute(
            "erroLogin",
            "Tipo de usuário não reconhecido."
        );

        request.setAttribute(
            "erro",
            "Tipo de usuário não reconhecido."
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/loginUsuario.jsp"
            );

        dispatcher.forward(request, response);
    }

    // =========================================================
    // CADASTRAR USUÁRIO
    // =========================================================

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

        // =====================================================
        // VALIDAÇÕES
        // =====================================================

        if (cpf == null || cpf.isBlank()) {

            throw new Exception(
                "CPF obrigatório"
            );
        }

        if (tipoUsuario == null || tipoUsuario.isBlank()) {

            throw new Exception(
                "Tipo de usuário obrigatório"
            );
        }

        if (nome == null || nome.isBlank()) {

            throw new Exception(
                "Nome obrigatório"
            );
        }

        if (email == null || !email.contains("@")) {

            throw new Exception(
                "Email inválido"
            );
        }

        if (senha == null || senha.isBlank()) {

            throw new Exception(
                "Senha obrigatória"
            );
        }

        if (telefone == null || telefone.isBlank()) {

            throw new Exception(
                "Telefone obrigatório"
            );
        }

        // =====================================================
        // CRIA OBJETO
        // =====================================================

        usuarioModel usuario =
            new usuarioModel(
                cpf,
                tipoUsuario,
                nome,
                email,
                senha,
                telefone
            );

        // =====================================================
        // SALVA
        // =====================================================

        usuarioDAO.adicionarUsuario(usuario);

        // =====================================================
        // VOLTA PARA LOGIN
        // =====================================================

        response.sendRedirect(
            request.getContextPath()
            + "/pages/loginUsuario.jsp"
        );
    }

    // =========================================================
    // CADASTRAR USUÁRIO PELO ADMIN
    // =========================================================

    private void cadastrarUsuarioAdmin(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        // =====================================================
        // VERIFICA ADMIN LOGADO
        // =====================================================

        HttpSession session =
            request.getSession(false);

        usuarioModel admLogado =
            session != null
                ? (usuarioModel) session.getAttribute("usuarioLogado")
                : null;

        if (admLogado == null
                || !"admin".equalsIgnoreCase(
                    admLogado.getTipo_usuario())) {

            response.sendRedirect(
                request.getContextPath()
                + "/pages/loginUsuario.jsp"
            );

            return;
        }

        // =====================================================
        // RECEBE DADOS
        // =====================================================

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

        // =====================================================
        // VALIDAÇÕES
        // =====================================================

        if (cpf == null || cpf.isBlank()
                || tipoUsuario == null || tipoUsuario.isBlank()
                || nome == null || nome.isBlank()
                || email == null || !email.contains("@")
                || senha == null || senha.isBlank()
                || telefone == null || telefone.isBlank()) {

            throw new Exception(
                "Todos os campos são obrigatórios para cadastrar um usuário."
            );
        }

        // =====================================================
        // CRIA USUÁRIO
        // =====================================================

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

        // =====================================================
        // VOLTA PELO CONTROLLER
        // =====================================================
        //
        // Assim a lista de usuários é atualizada.
        //

        response.sendRedirect(
            request.getContextPath()
            + "/usuarioController?action=listar"
        );
    }

    // =========================================================
    // ALTERAR SENHA DO PRÓPRIO USUÁRIO
    // =========================================================

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

        // =====================================================
        // VERIFICA NOVA SENHA
        // =====================================================

        if (novaSenha == null
                || novaSenha.isBlank()
                || !novaSenha.equals(confirmarSenha)) {

            response.sendRedirect(
                request.getContextPath()
                + "/pages/perfil.jsp"
            );

            return;
        }

        // =====================================================
        // CONFERE SENHA ATUAL
        // =====================================================

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

        // =====================================================
        // ALTERA SENHA
        // =====================================================

        usuarioDAO.alterarSenha(
            usuarioLogado.getId_usuario(),
            novaSenha
        );

        usuarioLogado.setSenha_usuario(
            novaSenha
        );

        session.setAttribute(
            "usuarioLogado",
            usuarioLogado
        );

        response.sendRedirect(
            request.getContextPath()
            + "/pages/perfil.jsp"
        );
    }

    // =========================================================
    // REDEFINIR SENHA PELO ADMIN
    // =========================================================

    private void redefinirSenhaAdmin(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        HttpSession session =
            request.getSession(false);

        usuarioModel admLogado =
            session != null
                ? (usuarioModel) session.getAttribute(
                    "usuarioLogado"
                )
                : null;

        // =====================================================
        // CONFERE ADMIN
        // =====================================================

        if (admLogado == null
                || !"admin".equalsIgnoreCase(
                    admLogado.getTipo_usuario())) {

            response.sendRedirect(
                request.getContextPath()
                + "/pages/loginUsuario.jsp"
            );

            return;
        }

        // =====================================================
        // PEGA ID
        // =====================================================

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {

            throw new Exception(
                "ID do usuário não informado."
            );
        }

        int idUsuario =
            Integer.parseInt(idParametro);

        // =====================================================
        // SENHA TEMPORÁRIA
        // =====================================================

        String senhaTemporaria =
            "Gerencia@123";

        usuarioDAO.alterarSenha(
            idUsuario,
            senhaTemporaria
        );

        // =====================================================
        // MENSAGEM
        // =====================================================

        session.setAttribute(
            "flashMsg",
            "Senha redefinida com sucesso. Nova senha temporária: "
            + senhaTemporaria
        );

        // =====================================================
        // VOLTA PELO CONTROLLER PARA ATUALIZAR HOMEADMIN
        // =====================================================

        response.sendRedirect(
            request.getContextPath()
            + "/usuarioController?action=listar"
        );
    }

    // =========================================================
    // EDITAR USUÁRIO COMPLETO
    // =========================================================
    //
    // Mantém a funcionalidade da versão anterior.
    //

    private void editarUsuario(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id_usuario");

        if (idParametro == null || idParametro.isBlank()) {

            throw new Exception(
                "ID do usuário não informado."
            );
        }

        int idUsuario =
            Integer.parseInt(idParametro);

        String cpf =
            request.getParameter("CPF_usuario");

        String tipo =
            request.getParameter("tipo_usuario");

        String nome =
            request.getParameter("nome_usuario");

        String email =
            request.getParameter("email_usuario");

        String senha =
            request.getParameter("senha_usuario");

        String telefone =
            request.getParameter("telefone");

        usuarioModel usuario =
            new usuarioModel(
                idUsuario,
                cpf,
                tipo,
                nome,
                email,
                senha,
                telefone
            );

        usuarioDAO.atualizarUsuario(
            usuario
        );

        response.sendRedirect(
            request.getContextPath()
            + "/usuarioController?action=listar"
        );
    }

    // =========================================================
    // ATUALIZAR PERFIL
    // =========================================================
    //
    // Usado pelo "Meu Perfil".
    //
    // Não altera:
    // - CPF
    // - tipo de usuário
    // - senha
    //

    private void atualizarUsuario(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id_usuario");

        if (idParametro == null || idParametro.isBlank()) {

            throw new Exception(
                "ID do usuário não informado."
            );
        }

        int idUsuario =
            Integer.parseInt(idParametro);

        // =====================================================
        // BUSCA USUÁRIO ATUAL
        // =====================================================

        usuarioModel usuarioAtual =
            usuarioDAO.buscarPorId(idUsuario);

        if (usuarioAtual == null) {

            throw new Exception(
                "Usuário não encontrado."
            );
        }

        // =====================================================
        // RECEBE DADOS
        // =====================================================

        String nome =
            request.getParameter("nome_usuario");

        String email =
            request.getParameter("email_usuario");

        String telefone =
            request.getParameter("telefone");

        // =====================================================
        // ATUALIZA NOME
        // =====================================================

        if (nome != null && !nome.isBlank()) {

            usuarioAtual.setNome_usuario(
                nome
            );
        }

        // =====================================================
        // ATUALIZA EMAIL
        // =====================================================

        if (email != null && !email.isBlank()) {

            email = email.trim();

            if (!email.contains("@")) {

                throw new Exception(
                    "Email inválido."
                );
            }

            usuarioAtual.setEmail_usuario(
                email
            );
        }

        // =====================================================
        // ATUALIZA TELEFONE
        // =====================================================

        if (telefone != null && !telefone.isBlank()) {

            usuarioAtual.setTelefone(
                telefone
            );
        }

        // =====================================================
        // SALVA
        // =====================================================

        usuarioDAO.atualizarUsuario(
            usuarioAtual
        );

        // =====================================================
        // ATUALIZA SESSÃO
        // =====================================================

        HttpSession session =
            request.getSession(false);

        if (session != null) {

            usuarioModel logado =
                (usuarioModel) session.getAttribute(
                    "usuarioLogado"
                );

            if (logado != null
                    && logado.getId_usuario()
                    == idUsuario) {

                session.setAttribute(
                    "usuarioLogado",
                    usuarioAtual
                );
            }
        }

        // =====================================================
        // DESTINO
        // =====================================================

        String destino =
            "/pages/home.jsp";

        if ("organizador".equalsIgnoreCase(
                usuarioAtual.getTipo_usuario())) {

            destino =
                "/pages/homeOrganizador.jsp?view=perfil";

        } else if ("admin".equalsIgnoreCase(
                usuarioAtual.getTipo_usuario())) {

            destino =
                "/usuarioController?action=listar";
        }

        response.sendRedirect(
            request.getContextPath()
            + destino
        );
    }

    // =========================================================
    // BUSCAR USUÁRIO POR ID
    // =========================================================

    private void buscarUsuario(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {

            throw new Exception(
                "ID do usuário não informado."
            );
        }

        int idUsuario =
            Integer.parseInt(idParametro);

        usuarioModel usuario =
            usuarioDAO.buscarPorId(
                idUsuario
            );

        if (usuario == null) {

            throw new Exception(
                "Usuário não encontrado."
            );
        }

        request.setAttribute(
            "usuario",
            usuario
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/detalhesUsuario.jsp"
            );

        dispatcher.forward(
            request,
            response
        );
    }

    // =========================================================
    // EXCLUIR USUÁRIO
    // =========================================================

    private void excluirUsuario(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {

            throw new Exception(
                "ID do usuário não informado."
            );
        }

        int idUsuario =
            Integer.parseInt(idParametro);

        usuarioDAO.excluirUsuario(
            idUsuario
        );

        // =====================================================
        // VOLTA PELO CONTROLLER
        // =====================================================
        //
        // Isso faz com que a lista seja buscada novamente.
        //

        response.sendRedirect(
            request.getContextPath()
            + "/usuarioController?action=listar"
        );
    }

    // =========================================================
    // LISTAR USUÁRIOS
    // =========================================================

    private void listarUsuarios(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        // =====================================================
        // BUSCA OS USUÁRIOS NO BANCO
        // =====================================================

        List<usuarioModel> lista =
            usuarioDAO.listarUsuarios();

        // =====================================================
        // COLOCA NA REQUEST
        // =====================================================

        request.setAttribute(
            "listaUsuarios",
            lista
        );

        // =====================================================
        // HOME ADMIN
        // =====================================================
        //
        // Usuários é uma SUBTELA do homeAdmin.
        //
        // Por isso não usamos listaUsuarios.jsp aqui.
        //

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/homeAdmin.jsp"
            );

        dispatcher.forward(
            request,
            response
        );
    }

    // =========================================================
    // LOGOUT
    // =========================================================

    private void logoutUsuario(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

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
}