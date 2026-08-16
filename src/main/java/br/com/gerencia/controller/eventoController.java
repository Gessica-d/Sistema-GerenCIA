package br.com.gerencia.controller;

import br.com.gerencia.dao.eventoDAO;
import br.com.gerencia.model.eventoModel;
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

@WebServlet("/eventoController")
public class eventoController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private eventoDAO eventoDAO;

    // ================= INIT =================
    @Override
    public void init() {

        try {

            Connection conexao = Conexao.getConnection();

            eventoDAO = new eventoDAO(conexao);

        } catch (Exception e) {

            throw new RuntimeException(
                "Erro ao iniciar eventoDAO: " + e.getMessage()
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

                excluirEvento(request, response);
                return;
            }

            if ("buscar".equals(action)) {

                buscarEvento(request, response);
                return;
            }

            if ("publicar".equals(action)) {

                publicarEvento(request, response);
                return;
            }

            listarEventos(request, response);

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
                    cadastrarEvento(request, response);
                    break;

                case "editar":
                    atualizarEvento(request, response);
                    break;

                case "excluir":
                    excluirEvento(request, response);
                    break;

                default:
                    listarEventos(request, response);
                    break;
            }

        } catch (Exception e) {

            throw new ServletException(e);
        }
    }

    // ================= CADASTRAR =================
    private void cadastrarEvento(HttpServletRequest request,
                                 HttpServletResponse response)
            throws Exception {

        String nome =
            request.getParameter("nome_evento");

        String tipo =
            request.getParameter("tipo_evento");

        String inicio =
            request.getParameter("inicio_evento");

        String fim =
            request.getParameter("fim_evento");

        String local =
            request.getParameter("local_evento");

        String capacidade =
            request.getParameter("capacidade_evento");

        String codigo =
            request.getParameter("codigo_evento");

        String descricao =
            request.getParameter("descricao_evento");

        String status =
            request.getParameter("status_evento");

        String categoria =
            request.getParameter("categoria_evento");

        String idOrganizador =
            request.getParameter("id_organizador");

        // ================= VALIDAÇÕES =================

        if (nome == null || nome.isBlank()) {
            throw new Exception("Nome do evento obrigatório");
        }

        if (tipo == null || tipo.isBlank()) {
            throw new Exception("Tipo do evento obrigatório");
        }

        if (inicio == null || inicio.isBlank()) {
            throw new Exception("Data de início obrigatória");
        }

        if (fim == null || fim.isBlank()) {
            throw new Exception("Data de término obrigatória");
        }

        if (local == null || local.isBlank()) {
            throw new Exception("Local do evento obrigatório");
        }

        if (capacidade == null || capacidade.isBlank()) {
            throw new Exception("Capacidade do evento obrigatória");
        }

        if (categoria == null || categoria.isBlank()) {
            throw new Exception("Categoria do evento obrigatória");
        }

        if (idOrganizador == null || idOrganizador.isBlank()) {
            throw new Exception("Organizador obrigatório");
        }

        LocalDateTime dataInicio =
            LocalDateTime.parse(inicio);

        LocalDateTime dataFim =
            LocalDateTime.parse(fim);

        if (!dataFim.isAfter(dataInicio)) {
            throw new Exception(
                "A data de término deve ser posterior à data de início"
            );
        }

        int capacidadeEvento =
            Integer.parseInt(capacidade);

        int idOrganizadorInt =
            Integer.parseInt(idOrganizador);


        eventoModel evento =
            new eventoModel(
                nome,
                tipo,
                dataInicio,
                dataFim,
                local,
                capacidadeEvento,
                codigo,
                descricao,
                status,
                categoria,
                idOrganizadorInt
            );

        int idEventoGerado = eventoDAO.adicionarEvento(evento);

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeOrganizador.jsp?view=eventos&abrirEvento=" + idEventoGerado
        );
    }

    // ================= ATUALIZAR =================
    private void atualizarEvento(HttpServletRequest request,
                                 HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id_evento");

        if (idParametro == null || idParametro.isBlank()) {
            throw new Exception(
                "ID do evento não informado"
            );
        }

        int idEvento =
            Integer.parseInt(idParametro);

        String nome =
            request.getParameter("nome_evento");

        String tipo =
            request.getParameter("tipo_evento");

        String inicio =
            request.getParameter("inicio_evento");

        String fim =
            request.getParameter("fim_evento");

        String local =
            request.getParameter("local_evento");

        String capacidadeParametro =
            request.getParameter("capacidade_evento");

        String codigo =
            request.getParameter("codigo_evento");

        String descricao =
            request.getParameter("descricao_evento");

        String status =
            request.getParameter("status_evento");

        String categoria =
            request.getParameter("categoria_evento");

        String idOrganizadorParametro =
            request.getParameter("id_organizador");

        if (nome == null || nome.isBlank()) {
            throw new Exception("Nome do evento obrigatório");
        }

        if (tipo == null || tipo.isBlank()) {
            throw new Exception("Tipo do evento obrigatório");
        }

        if (inicio == null || inicio.isBlank()) {
            throw new Exception("Data de início obrigatória");
        }

        if (fim == null || fim.isBlank()) {
            throw new Exception("Data de término obrigatória");
        }

        if (capacidadeParametro == null
                || capacidadeParametro.isBlank()) {
            throw new Exception(
                "Capacidade do evento obrigatória"
            );
        }

        if (idOrganizadorParametro == null
                || idOrganizadorParametro.isBlank()) {
            throw new Exception(
                "Organizador obrigatório"
            );
        }

        LocalDateTime dataInicio =
            LocalDateTime.parse(inicio);

        LocalDateTime dataFim =
            LocalDateTime.parse(fim);

        if (!dataFim.isAfter(dataInicio)) {
            throw new Exception(
                "A data de término deve ser posterior à data de início"
            );
        }

        int capacidade =
            Integer.parseInt(capacidadeParametro);

        int idOrganizador =
            Integer.parseInt(idOrganizadorParametro);


        eventoModel evento =
            new eventoModel(
                idEvento,
                nome,
                tipo,
                dataInicio,
                dataFim,
                local,
                capacidade,
                codigo,
                descricao,
                status,
                categoria,
                idOrganizador
            );

        eventoDAO.atualizarEvento(evento);

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeOrganizador.jsp"
        );
    }

    // ================= BUSCAR POR ID =================
    private void buscarEvento(HttpServletRequest request,
                              HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {
            throw new Exception(
                "ID do evento não informado"
            );
        }

        int idEvento =
            Integer.parseInt(idParametro);

        eventoModel evento =
            eventoDAO.buscarPorId(idEvento);

        if (evento == null) {

            throw new Exception(
                "Evento não encontrado"
            );
        }

        request.setAttribute(
            "evento",
            evento
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/detalhesEvento.jsp"
            );

        dispatcher.forward(request, response);
    }

    // ================= EXCLUIR =================
    private void excluirEvento(HttpServletRequest request,
                               HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {
            throw new Exception(
                "ID do evento não informado"
            );
        }

        int idEvento =
            Integer.parseInt(idParametro);

        eventoDAO.excluirEvento(idEvento);

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeOrganizador.jsp"
        );
    }

    // ================= PUBLICAR (rascunho -> ativo) =================
    private void publicarEvento(HttpServletRequest request,
                                HttpServletResponse response)
            throws Exception {

        String idParametro = request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {
            throw new Exception("ID do evento não informado");
        }

        int idEvento = Integer.parseInt(idParametro);

        eventoDAO.atualizarStatus(idEvento, "ativo");

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeOrganizador.jsp?view=eventos&abrirEvento=" + idEvento
        );
    }

    // ================= LISTAR =================
    private void listarEventos(HttpServletRequest request,
                               HttpServletResponse response)
            throws Exception {

        List<eventoModel> lista =
            eventoDAO.listarEventos();

        request.setAttribute(
            "listaEventos",
            lista
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/listaEventos.jsp"
            );

        dispatcher.forward(request, response);
    }
}