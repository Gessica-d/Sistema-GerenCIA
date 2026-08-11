package br.com.gerencia.controller;

import br.com.gerencia.dao.notificacaoDAO;
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

            if ("marcarLidas".equals(action)) {

                marcarTodasComoLidas(request, response);
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

                case "excluir":
                    excluirNotificacao(request, response);
                    break;

                case "marcarLidas":
                    marcarTodasComoLidas(request, response);
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

        String statusNotificacao = request.getParameter("status_notificacao");
        String mensagem = request.getParameter("mensagem");
        String dataEnvioParametro = request.getParameter("data_envio");
        String idInscricaoParametro = request.getParameter("id_inscricao");
        String idUsuarioParametro = request.getParameter("id_usuario");

        if (statusNotificacao == null || statusNotificacao.isBlank()) {
            throw new Exception("Status da notificação obrigatório");
        }

        if (mensagem == null || mensagem.isBlank()) {
            throw new Exception("Mensagem da notificação obrigatória");
        }

        if (idInscricaoParametro == null || idInscricaoParametro.isBlank()) {
            throw new Exception("Inscrição não informada");
        }

        if (idUsuarioParametro == null || idUsuarioParametro.isBlank()) {
            throw new Exception("Usuário não informado");
        }

        int idInscricao = Integer.parseInt(idInscricaoParametro);
        int idUsuario = Integer.parseInt(idUsuarioParametro);

        LocalDateTime dataEnvio = (dataEnvioParametro == null || dataEnvioParametro.isBlank())
            ? LocalDateTime.now()
            : LocalDateTime.parse(dataEnvioParametro);

        notificacaoModel notificacao = new notificacaoModel(
            statusNotificacao,
            mensagem,
            dataEnvio,
            idInscricao,
            idUsuario
        );

        notificacaoDAO.adicionarNotificacao(notificacao);

        response.sendRedirect(
            request.getContextPath()
            + "/notificacaoController?action=listar"
        );
    }

    // ================= MARCAR TODAS COMO LIDAS (usuário logado) =================
    private void marcarTodasComoLidas(HttpServletRequest request,
                                      HttpServletResponse response)
            throws Exception {

        HttpSession session = request.getSession(false);

        usuarioModel usuarioLogado = session != null
            ? (usuarioModel) session.getAttribute("usuarioLogado")
            : null;

        if (usuarioLogado == null) {
            response.sendRedirect(request.getContextPath() + "/pages/loginUsuario.jsp");
            return;
        }

        notificacaoDAO.marcarTodasComoLidas(usuarioLogado.getId_usuario());

        String voltarPara = request.getParameter("voltarPara");

        if (voltarPara == null || voltarPara.isBlank()) {
            voltarPara = "organizador".equals(usuarioLogado.getTipo_usuario())
                ? "/pages/homeOrganizador.jsp"
                : "/pages/home.jsp";
        }

        response.sendRedirect(request.getContextPath() + voltarPara);
    }

    // ================= EXCLUIR =================
    private void excluirNotificacao(HttpServletRequest request,
                                    HttpServletResponse response)
            throws Exception {

        String idParametro = request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {
            throw new Exception("ID da notificação não informado");
        }

        int idNotificacao = Integer.parseInt(idParametro);

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

        List<notificacaoModel> lista = notificacaoDAO.listarNotificacoes();

        request.setAttribute("listaNotificacoes", lista);

        RequestDispatcher dispatcher =
            request.getRequestDispatcher("/pages/listaNotificacoes.jsp");

        dispatcher.forward(request, response);
    }
}
