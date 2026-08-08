package br.com.gerencia.controller;

import br.com.gerencia.dao.inscricaoDAO;
import br.com.gerencia.model.inscricaoModel;
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

@WebServlet("/inscricaoController")
public class inscricaoController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private inscricaoDAO inscricaoDAO;

    // ================= INIT =================
    @Override
    public void init() {

        try {

            Connection conexao = Conexao.getConnection();

            inscricaoDAO = new inscricaoDAO(conexao);

        } catch (Exception e) {

            throw new RuntimeException(
                "Erro ao iniciar inscricaoDAO: " + e.getMessage()
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

                excluirInscricao(request, response);
                return;
            }

            if ("buscar".equals(action)) {

                buscarInscricao(request, response);
                return;
            }

            listarInscricoes(request, response);

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
                    cadastrarInscricao(request, response);
                    break;

                case "editar":
                    atualizarInscricao(request, response);
                    break;

                case "excluir":
                    excluirInscricao(request, response);
                    break;

                default:
                    listarInscricoes(request, response);
                    break;
            }

        } catch (Exception e) {

            throw new ServletException(e);
        }
    }

    // ================= CADASTRAR =================
    private void cadastrarInscricao(HttpServletRequest request,
                                    HttpServletResponse response)
            throws Exception {

        String idEventoParametro =
            request.getParameter("id_evento");

        String idUsuarioParametro =
            request.getParameter("id_usuario");

        String dataInscricaoParametro =
            request.getParameter("data_inscricao");

        String statusInscricao =
            request.getParameter("status_inscricao");

        String metodoInscricao =
            request.getParameter("metodo_inscricao");

        String checkinParametro =
            request.getParameter("checkin");

        String posicaoFilaParametro =
            request.getParameter("posicao_fila");

        // ================= VALIDAÇÕES =================

        if (idEventoParametro == null
                || idEventoParametro.isBlank()) {

            throw new Exception("Evento não informado");
        }

        if (idUsuarioParametro == null
                || idUsuarioParametro.isBlank()) {

            throw new Exception("Usuário não informado");
        }

        if (dataInscricaoParametro == null
                || dataInscricaoParametro.isBlank()) {

            throw new Exception(
                "Data da inscrição obrigatória"
            );
        }

        if (statusInscricao == null
                || statusInscricao.isBlank()) {

            statusInscricao = "CONFIRMADO";
        }

        if (metodoInscricao == null
                || metodoInscricao.isBlank()) {

            throw new Exception(
                "Método de inscrição obrigatório"
            );
        }

        if (checkinParametro == null
                || checkinParametro.isBlank()) {

            checkinParametro = "false";
        }

        if (posicaoFilaParametro == null
                || posicaoFilaParametro.isBlank()) {

            posicaoFilaParametro = "0";
        }

        // ================= CONVERSÕES =================

        int idEvento =
            Integer.parseInt(idEventoParametro);

        int idUsuario =
            Integer.parseInt(idUsuarioParametro);

        LocalDateTime dataInscricao =
            LocalDateTime.parse(dataInscricaoParametro);

        boolean checkin =
            Boolean.parseBoolean(checkinParametro);

        int posicaoFila =
            Integer.parseInt(posicaoFilaParametro);

        // ================= MODEL =================

        inscricaoModel inscricao =
            new inscricaoModel(
                idEvento,
                idUsuario,
                dataInscricao,
                statusInscricao,
                metodoInscricao,
                checkin,
                posicaoFila
            );

        // ================= DAO =================

        inscricaoDAO.adicionarInscricao(inscricao);

        response.sendRedirect(
            request.getContextPath()
            + "/inscricaoController?action=listar"
        );
    }

    // ================= ATUALIZAR =================
    private void atualizarInscricao(HttpServletRequest request,
                                    HttpServletResponse response)
            throws Exception {

        String idInscricaoParametro =
            request.getParameter("id_inscricao");

        String idEventoParametro =
            request.getParameter("id_evento");

        String idUsuarioParametro =
            request.getParameter("id_usuario");

        String dataInscricaoParametro =
            request.getParameter("data_inscricao");

        String statusInscricao =
            request.getParameter("status_inscricao");

        String metodoInscricao =
            request.getParameter("metodo_inscricao");

        String checkinParametro =
            request.getParameter("checkin");

        String posicaoFilaParametro =
            request.getParameter("posicao_fila");

        // ================= VALIDAÇÕES =================

        if (idInscricaoParametro == null
                || idInscricaoParametro.isBlank()) {

            throw new Exception(
                "ID da inscrição não informado"
            );
        }

        if (idEventoParametro == null
                || idEventoParametro.isBlank()) {

            throw new Exception("Evento não informado");
        }

        if (idUsuarioParametro == null
                || idUsuarioParametro.isBlank()) {

            throw new Exception("Usuário não informado");
        }

        if (dataInscricaoParametro == null
                || dataInscricaoParametro.isBlank()) {

            throw new Exception(
                "Data da inscrição obrigatória"
            );
        }

        if (statusInscricao == null
                || statusInscricao.isBlank()) {

            throw new Exception(
                "Status da inscrição obrigatório"
            );
        }

        if (metodoInscricao == null
                || metodoInscricao.isBlank()) {

            throw new Exception(
                "Método de inscrição obrigatório"
            );
        }

        if (checkinParametro == null
                || checkinParametro.isBlank()) {

            checkinParametro = "false";
        }

        if (posicaoFilaParametro == null
                || posicaoFilaParametro.isBlank()) {

            posicaoFilaParametro = "0";
        }

        // ================= CONVERSÕES =================

        int idInscricao =
            Integer.parseInt(idInscricaoParametro);

        int idEvento =
            Integer.parseInt(idEventoParametro);

        int idUsuario =
            Integer.parseInt(idUsuarioParametro);

        LocalDateTime dataInscricao =
            LocalDateTime.parse(dataInscricaoParametro);

        boolean checkin =
            Boolean.parseBoolean(checkinParametro);

        int posicaoFila =
            Integer.parseInt(posicaoFilaParametro);

        // ================= MODEL =================

        inscricaoModel inscricao =
            new inscricaoModel(
                idInscricao,
                idEvento,
                idUsuario,
                dataInscricao,
                statusInscricao,
                metodoInscricao,
                checkin,
                posicaoFila
            );

        // ================= DAO =================

        inscricaoDAO.atualizarInscricao(inscricao);

        response.sendRedirect(
            request.getContextPath()
            + "/inscricaoController?action=listar"
        );
    }

    // ================= BUSCAR POR ID =================
    private void buscarInscricao(HttpServletRequest request,
                                 HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {

            throw new Exception(
                "ID da inscrição não informado"
            );
        }

        int idInscricao =
            Integer.parseInt(idParametro);

        inscricaoModel inscricao =
            inscricaoDAO.buscarPorId(idInscricao);

        if (inscricao == null) {

            throw new Exception(
                "Inscrição não encontrada"
            );
        }

        request.setAttribute(
            "inscricao",
            inscricao
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/detalhesInscricao.jsp"
            );

        dispatcher.forward(request, response);
    }

    // ================= EXCLUIR =================
    private void excluirInscricao(HttpServletRequest request,
                                  HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {

            throw new Exception(
                "ID da inscrição não informado"
            );
        }

        int idInscricao =
            Integer.parseInt(idParametro);

        inscricaoDAO.excluirInscricao(idInscricao);

        response.sendRedirect(
            request.getContextPath()
            + "/inscricaoController?action=listar"
        );
    }

    // ================= LISTAR =================
    private void listarInscricoes(HttpServletRequest request,
                                  HttpServletResponse response)
            throws Exception {

        List<inscricaoModel> lista =
            inscricaoDAO.listarInscricoes();

        request.setAttribute(
            "listaInscricoes",
            lista
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/listaInscricoes.jsp"
            );

        dispatcher.forward(request, response);
    }
}