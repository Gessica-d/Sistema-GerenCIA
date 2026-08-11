package br.com.gerencia.controller;

import br.com.gerencia.dao.inscricaoDAO;
import br.com.gerencia.dao.eventoDAO;
import br.com.gerencia.dao.notificacaoDAO;
import br.com.gerencia.model.inscricaoModel;
import br.com.gerencia.model.eventoModel;
import br.com.gerencia.model.notificacaoModel;
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
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/inscricaoController")
public class inscricaoController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private inscricaoDAO inscricaoDAO;
    private eventoDAO eventoDAO;
    private notificacaoDAO notificacaoDAO;

    // ================= INIT =================
    @Override
    public void init() {

        try {

            Connection conexao = Conexao.getConnection();

            inscricaoDAO = new inscricaoDAO(conexao);
            eventoDAO = new eventoDAO(conexao);
            notificacaoDAO = new notificacaoDAO(conexao);

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

            if ("cancelar".equals(action)) {

                cancelarInscricao(request, response);
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

                case "cancelar":
                    cancelarInscricao(request, response);
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

    // =====================================================
    // CANCELAR INSCRIÇÃO (com promoção automática da lista
    // de espera + notificações — regra de negócio do escopo)
    // =====================================================
    private void cancelarInscricao(HttpServletRequest request,
                                   HttpServletResponse response)
            throws Exception {

        String idParametro = request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {
            throw new Exception("ID da inscrição não informado");
        }

        int idInscricao = Integer.parseInt(idParametro);

        inscricaoModel inscricaoCancelada =
            inscricaoDAO.buscarPorId(idInscricao);

        if (inscricaoCancelada == null) {
            throw new Exception("Inscrição não encontrada");
        }

        // 1) Marca a inscrição como cancelada (mantém o histórico).
        inscricaoDAO.atualizarStatus(idInscricao, "Cancelada");

        // 2) Só mexe na lista de espera se a inscrição cancelada
        //    estava CONFIRMADA (cancelar quem já estava esperando
        //    não libera vaga nenhuma).
        if ("Confirmada".equals(inscricaoCancelada.getStatus_inscricao())) {

            inscricaoModel promovido =
                inscricaoDAO.buscarProximoNaFila(inscricaoCancelada.getId_evento());

            if (promovido != null) {

                // Promove o primeiro da fila para confirmado.
                inscricaoDAO.atualizarStatus(promovido.getId_inscricao(), "Confirmada");

                eventoModel evento =
                    eventoDAO.buscarPorId(inscricaoCancelada.getId_evento());

                if (evento != null) {

                    String mensagemOrganizador =
                        "Uma vaga foi liberada em \"" + evento.getNome_evento()
                        + "\" e o próximo da lista de espera foi promovido automaticamente.";

                    String mensagemUsuario =
                        "Você foi promovido da lista de espera e agora está CONFIRMADO no evento \""
                        + evento.getNome_evento() + "\"!";

                    // Notifica o organizador do evento.
                    notificacaoDAO.adicionarNotificacao(
                        new notificacaoModel(
                            "enviada",
                            mensagemOrganizador,
                            LocalDateTime.now(),
                            promovido.getId_inscricao(),
                            evento.getId_organizador()
                        )
                    );

                    // Notifica o usuário que foi promovido.
                    notificacaoDAO.adicionarNotificacao(
                        new notificacaoModel(
                            "enviada",
                            mensagemUsuario,
                            LocalDateTime.now(),
                            promovido.getId_inscricao(),
                            promovido.getId_usuario()
                        )
                    );
                }
            }
        }

        // ================= REDIRECT =================

        HttpSession session = request.getSession(false);

        usuarioModel usuarioLogado = session != null
            ? (usuarioModel) session.getAttribute("usuarioLogado")
            : null;

        String destino = "/pages/home.jsp";

        if (usuarioLogado != null && "organizador".equals(usuarioLogado.getTipo_usuario())) {
            destino = "/pages/homeOrganizador.jsp";
        }

        response.sendRedirect(request.getContextPath() + destino);
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