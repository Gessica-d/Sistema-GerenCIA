package br.com.gerencia.controller;

import br.com.gerencia.dao.notificacaoDAO;
import br.com.gerencia.model.notificacaoModel;
import br.com.gerencia.utils.Conexao;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/notificacaoController")
public class notificacaoController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private notificacaoDAO notificacaoDAO;

    // ================= INIT =================
    @Override
    public void init() {

        try {

            Connection conexao = Conexao.getConnection();

            notificacaoDAO = new notificacaoDAO(conexao);

        } catch (Exception e) {

            throw new RuntimeException(
                "Erro ao iniciar notificacaoDAO: " + e.getMessage()
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

            if ("excluir".equals(action)) {

                excluirNotificacao(request, response);
                return;
            }

            if ("buscar".equals(action)) {

                buscarNotificacao(request, response);
                return;
            }

            listarNotificacoes(request, response);

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
                    cadastrarNotificacao(request, response);
                    break;

                case "editar":
                    atualizarNotificacao(request, response);
                    break;

                case "excluir":
                    excluirNotificacao(request, response);
                    break;

                default:
                    listarNotificacoes(request, response);
                    break;
            }

        } catch (Exception e) {

            throw new ServletException(e);
        }
    }

    // ================= CADASTRAR =================
    private void cadastrarNotificacao(HttpServletRequest request,
                                      HttpServletResponse response)
            throws Exception {

        String statusNotificacao =
            request.getParameter("status_notificacao");

        String dataEnvioParametro =
            request.getParameter("data_envio");

        String idInscricaoParametro =
            request.getParameter("id_inscricao");

        String idUsuarioParametro =
            request.getParameter("id_usuario");

        // ================= VALIDAÇÕES =================

        if (statusNotificacao == null
                || statusNotificacao.isBlank()) {

            throw new Exception(
                "Status da notificação obrigatório"
            );
        }

        if (idInscricaoParametro == null
                || idInscricaoParametro.isBlank()) {

            throw new Exception(
                "Inscrição não informada"
            );
        }

        if (idUsuarioParametro == null
                || idUsuarioParametro.isBlank()) {

            throw new Exception(
                "Usuário não informado"
            );
        }

        // ================= CONVERSÕES =================

        int idInscricao =
            Integer.parseInt(idInscricaoParametro);

        int idUsuario =
            Integer.parseInt(idUsuarioParametro);

        LocalDateTime dataEnvio;

        if (dataEnvioParametro == null
                || dataEnvioParametro.isBlank()) {

            dataEnvio = LocalDateTime.now();

        } else {

            dataEnvio =
                LocalDateTime.parse(dataEnvioParametro);
        }

        // ================= MODEL =================

        notificacaoModel notificacao =
            new notificacaoModel(
                statusNotificacao,
                dataEnvio,
                idInscricao,
                idUsuario
            );

        // ================= DAO =================

        notificacaoDAO.adicionarNotificacao(notificacao);

        response.sendRedirect(
            request.getContextPath()
            + "/notificacaoController?action=listar"
        );
    }

    // ================= ATUALIZAR =================
    private void atualizarNotificacao(HttpServletRequest request,
                                      HttpServletResponse response)
            throws Exception {

        String idNotificacaoParametro =
            request.getParameter("id_notificacao");

        String statusNotificacao =
            request.getParameter("status_notificacao");

        String dataEnvioParametro =
            request.getParameter("data_envio");

        String idInscricaoParametro =
            request.getParameter("id_inscricao");

        String idUsuarioParametro =
            request.getParameter("id_usuario");

        // ================= VALIDAÇÕES =================

        if (idNotificacaoParametro == null
                || idNotificacaoParametro.isBlank()) {

            throw new Exception(
                "ID da notificação não informado"
            );
        }

        if (statusNotificacao == null
                || statusNotificacao.isBlank()) {

            throw new Exception(
                "Status da notificação obrigatório"
            );
        }

        if (dataEnvioParametro == null
                || dataEnvioParametro.isBlank()) {

            throw new Exception(
                "Data de envio obrigatória"
            );
        }

        if (idInscricaoParametro == null
                || idInscricaoParametro.isBlank()) {

            throw new Exception(
                "Inscrição não informada"
            );
        }

        if (idUsuarioParametro == null
                || idUsuarioParametro.isBlank()) {

            throw new Exception(
                "Usuário não informado"
            );
        }

        // ================= CONVERSÕES =================

        int idNotificacao =
            Integer.parseInt(idNotificacaoParametro);

        int idInscricao =
            Integer.parseInt(idInscricaoParametro);

        int idUsuario =
            Integer.parseInt(idUsuarioParametro);

        LocalDateTime dataEnvio =
            LocalDateTime.parse(dataEnvioParametro);

        // ================= MODEL =================

        notificacaoModel notificacao =
            new notificacaoModel(
                idNotificacao,
                statusNotificacao,
                dataEnvio,
                idInscricao,
                idUsuario
            );

        // ================= DAO =================

        notificacaoDAO.atualizarNotificacao(notificacao);

        response.sendRedirect(
            request.getContextPath()
            + "/notificacaoController?action=listar"
        );
    }

    // ================= BUSCAR POR ID =================
    private void buscarNotificacao(HttpServletRequest request,
                                   HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {

            throw new Exception(
                "ID da notificação não informado"
            );
        }

        int idNotificacao =
            Integer.parseInt(idParametro);

        notificacaoModel notificacao =
            notificacaoDAO.buscarPorId(idNotificacao);

        if (notificacao == null) {

            throw new Exception(
                "Notificação não encontrada"
            );
        }

        request.setAttribute(
            "notificacao",
            notificacao
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/detalhesNotificacao.jsp"
            );

        dispatcher.forward(request, response);
    }

    // ================= EXCLUIR =================
    private void excluirNotificacao(HttpServletRequest request,
                                    HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {

            throw new Exception(
                "ID da notificação não informado"
            );
        }

        int idNotificacao =
            Integer.parseInt(idParametro);

        notificacaoDAO.excluirNotificacao(idNotificacao);

        response.sendRedirect(
            request.getContextPath()
            + "/notificacaoController?action=listar"
        );
    }

    // ================= LISTAR =================
    private void listarNotificacoes(HttpServletRequest request,
                                    HttpServletResponse response)
            throws Exception {

        List<notificacaoModel> lista =
            notificacaoDAO.listarNotificacoes();

        request.setAttribute(
            "listaNotificacoes",
            lista
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/listaNotificacoes.jsp"
            );

        dispatcher.forward(request, response);
    }
}