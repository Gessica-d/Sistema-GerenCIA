package br.com.gerencia.controller;

import br.com.gerencia.dao.contratoDAO;
import br.com.gerencia.model.contratoModel;
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

@WebServlet("/contratoController")
public class contratoController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private contratoDAO contratoDAO;

    // ================= INIT =================
    @Override
    public void init() {

        try {

            Connection conexao = Conexao.getConnection();

            contratoDAO = new contratoDAO(conexao);

        } catch (Exception e) {

            throw new RuntimeException(
                "Erro ao iniciar contratoDAO: " + e.getMessage()
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

                excluirContrato(request, response);
                return;
            }

            if ("buscar".equals(action)) {

                buscarContrato(request, response);
                return;
            }

            listarContratos(request, response);

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
                    cadastrarContrato(request, response);
                    break;

                case "editar":
                    atualizarContrato(request, response);
                    break;

                case "excluir":
                    excluirContrato(request, response);
                    break;

                default:
                    listarContratos(request, response);
                    break;
            }

        } catch (Exception e) {

            throw new ServletException(e);
        }
    }

    // ================= CADASTRAR =================
    private void cadastrarContrato(HttpServletRequest request,
                                   HttpServletResponse response)
            throws Exception {

        String idFornecedorParametro =
            request.getParameter("id_fornecedor");

        String idEventoParametro =
            request.getParameter("id_evento");

        String dataContratoParametro =
            request.getParameter("data_contrato");

        String valorPagoParametro =
            request.getParameter("valor_pago");

        String valorTotalParametro =
            request.getParameter("valor_total");

        String responsavelContrato =
            request.getParameter("responsavel_contrato");

        String contatoResponsavel =
            request.getParameter("contato_responsavel");

        String objetoContrato =
            request.getParameter("objeto_contrato");

        String anexoContrato =
            request.getParameter("anexo_contrato");

        // ================= VALIDAÇÕES =================

        if (idFornecedorParametro == null
                || idFornecedorParametro.isBlank()) {

            throw new Exception(
                "Fornecedor não informado"
            );
        }

        if (idEventoParametro == null
                || idEventoParametro.isBlank()) {

            throw new Exception(
                "Evento não informado"
            );
        }

        if (dataContratoParametro == null
                || dataContratoParametro.isBlank()) {

            throw new Exception(
                "Data do contrato obrigatória"
            );
        }

        if (valorPagoParametro == null
                || valorPagoParametro.isBlank()) {

            throw new Exception(
                "Valor pago obrigatório"
            );
        }

        if (valorTotalParametro == null
                || valorTotalParametro.isBlank()) {

            throw new Exception(
                "Valor total obrigatório"
            );
        }

        if (responsavelContrato == null
                || responsavelContrato.isBlank()) {

            throw new Exception(
                "Responsável pelo contrato obrigatório"
            );
        }

        if (objetoContrato == null
                || objetoContrato.isBlank()) {

            throw new Exception(
                "Objeto do contrato obrigatório"
            );
        }

        // ================= CONVERSÕES =================

        int idFornecedor =
            Integer.parseInt(idFornecedorParametro);

        int idEvento =
            Integer.parseInt(idEventoParametro);

        LocalDateTime dataContrato =
            LocalDateTime.parse(dataContratoParametro);

        double valorPago =
            Double.parseDouble(valorPagoParametro);

        double valorTotal =
            Double.parseDouble(valorTotalParametro);

        // ================= MODEL =================

        contratoModel contrato =
            new contratoModel(
                idFornecedor,
                idEvento,
                dataContrato,
                valorPago,
                valorTotal,
                responsavelContrato,
                contatoResponsavel,
                objetoContrato,
                anexoContrato
            );

        // ================= DAO =================

        contratoDAO.adicionarContrato(contrato);

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeOrganizador.jsp"
        );
    }

    // ================= ATUALIZAR =================
    private void atualizarContrato(HttpServletRequest request,
                                   HttpServletResponse response)
            throws Exception {

        String idContratoParametro =
            request.getParameter("id_contrato");

        String idFornecedorParametro =
            request.getParameter("id_fornecedor");

        String idEventoParametro =
            request.getParameter("id_evento");

        String dataContratoParametro =
            request.getParameter("data_contrato");

        String valorPagoParametro =
            request.getParameter("valor_pago");

        String valorTotalParametro =
            request.getParameter("valor_total");

        String responsavelContrato =
            request.getParameter("responsavel_contrato");

        String contatoResponsavel =
            request.getParameter("contato_responsavel");

        String objetoContrato =
            request.getParameter("objeto_contrato");

        String anexoContrato =
            request.getParameter("anexo_contrato");

        // ================= VALIDAÇÕES =================

        if (idContratoParametro == null
                || idContratoParametro.isBlank()) {

            throw new Exception(
                "ID do contrato não informado"
            );
        }

        if (idFornecedorParametro == null
                || idFornecedorParametro.isBlank()) {

            throw new Exception(
                "Fornecedor não informado"
            );
        }

        if (idEventoParametro == null
                || idEventoParametro.isBlank()) {

            throw new Exception(
                "Evento não informado"
            );
        }

        if (dataContratoParametro == null
                || dataContratoParametro.isBlank()) {

            throw new Exception(
                "Data do contrato obrigatória"
            );
        }

        if (valorPagoParametro == null
                || valorPagoParametro.isBlank()) {

            throw new Exception(
                "Valor pago obrigatório"
            );
        }

        if (valorTotalParametro == null
                || valorTotalParametro.isBlank()) {

            throw new Exception(
                "Valor total obrigatório"
            );
        }

        if (responsavelContrato == null
                || responsavelContrato.isBlank()) {

            throw new Exception(
                "Responsável pelo contrato obrigatório"
            );
        }

        if (objetoContrato == null
                || objetoContrato.isBlank()) {

            throw new Exception(
                "Objeto do contrato obrigatório"
            );
        }

        // ================= CONVERSÕES =================

        int idContrato =
            Integer.parseInt(idContratoParametro);

        int idFornecedor =
            Integer.parseInt(idFornecedorParametro);

        int idEvento =
            Integer.parseInt(idEventoParametro);

        LocalDateTime dataContrato =
            LocalDateTime.parse(dataContratoParametro);

        double valorPago =
            Double.parseDouble(valorPagoParametro);

        double valorTotal =
            Double.parseDouble(valorTotalParametro);

        // ================= MODEL =================

        contratoModel contrato =
            new contratoModel(
                idContrato,
                idFornecedor,
                idEvento,
                dataContrato,
                valorPago,
                valorTotal,
                responsavelContrato,
                contatoResponsavel,
                objetoContrato,
                anexoContrato
            );

        // ================= DAO =================

        contratoDAO.atualizarContrato(contrato);

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeOrganizador.jsp"
        );
    }

    // ================= BUSCAR POR ID =================
    private void buscarContrato(HttpServletRequest request,
                                HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {

            throw new Exception(
                "ID do contrato não informado"
            );
        }

        int idContrato =
            Integer.parseInt(idParametro);

        contratoModel contrato =
            contratoDAO.buscarPorId(idContrato);

        if (contrato == null) {

            throw new Exception(
                "Contrato não encontrado"
            );
        }

        request.setAttribute(
            "contrato",
            contrato
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/detalhesContrato.jsp"
            );

        dispatcher.forward(request, response);
    }

    // ================= EXCLUIR =================
    private void excluirContrato(HttpServletRequest request,
                                 HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {

            throw new Exception(
                "ID do contrato não informado"
            );
        }

        int idContrato =
            Integer.parseInt(idParametro);

        contratoDAO.excluirContrato(idContrato);

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeOrganizador.jsp"
        );
    }

    // ================= LISTAR =================
    private void listarContratos(HttpServletRequest request,
                                 HttpServletResponse response)
            throws Exception {

        List<contratoModel> lista =
            contratoDAO.listarContratos();

        request.setAttribute(
            "listaContratos",
            lista
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/listaContratos.jsp"
            );

        dispatcher.forward(request, response);
    }
}