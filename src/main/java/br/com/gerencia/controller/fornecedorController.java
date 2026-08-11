package br.com.gerencia.controller;

import br.com.gerencia.dao.fornecedorDAO;
import br.com.gerencia.model.fornecedorModel;
import br.com.gerencia.utils.Conexao;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

@WebServlet("/fornecedorController")
public class fornecedorController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private fornecedorDAO fornecedorDAO;

    // ================= INIT =================
    @Override
    public void init() {

        try {

            Connection conexao = Conexao.getConnection();

            fornecedorDAO = new fornecedorDAO(conexao);

        } catch (Exception e) {

            throw new RuntimeException(
                "Erro ao iniciar fornecedorDAO: " + e.getMessage()
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

                excluirFornecedor(request, response);
                return;
            }

            if ("buscar".equals(action)) {

                buscarFornecedor(request, response);
                return;
            }

            listarFornecedores(request, response);

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
                    cadastrarFornecedor(request, response);
                    break;

                case "editar":
                    atualizarFornecedor(request, response);
                    break;

                case "excluir":
                    excluirFornecedor(request, response);
                    break;

                default:
                    listarFornecedores(request, response);
                    break;
            }

        } catch (Exception e) {

            throw new ServletException(e);
        }
    }

    // ================= CADASTRAR =================
    private void cadastrarFornecedor(HttpServletRequest request,
                                     HttpServletResponse response)
            throws Exception {

        String nome =
            request.getParameter("nome_fornecedor");

        String cnpj =
            request.getParameter("CNPJ_fornecedor");

        String telefone =
            request.getParameter("telefone_fornecedor");

        String categoria =
            request.getParameter("categoria_fornecedor");

        String email =
            request.getParameter("email");

        // ================= VALIDAÇÕES =================

        if (nome == null || nome.isBlank()) {
            throw new Exception(
                "Nome do fornecedor obrigatório"
            );
        }

        if (cnpj == null || cnpj.isBlank()) {
            throw new Exception(
                "CNPJ obrigatório"
            );
        }

        if (telefone == null || telefone.isBlank()) {
            throw new Exception(
                "Telefone obrigatório"
            );
        }

        if (categoria == null || categoria.isBlank()) {
            throw new Exception(
                "Categoria obrigatória"
            );
        }

        if (email == null || !email.contains("@")) {
            throw new Exception(
                "Email inválido"
            );
        }

        fornecedorModel fornecedor =
            new fornecedorModel(
                nome,
                cnpj,
                telefone,
                categoria,
                email
            );

        fornecedorDAO.adicionarFornecedor(fornecedor);

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeOrganizador.jsp"
        );
    }

    // ================= ATUALIZAR =================
    private void atualizarFornecedor(HttpServletRequest request,
                                     HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id_fornecedor");

        if (idParametro == null || idParametro.isBlank()) {
            throw new Exception(
                "ID do fornecedor não informado"
            );
        }

        int idFornecedor =
            Integer.parseInt(idParametro);

        String nome =
            request.getParameter("nome_fornecedor");

        String cnpj =
            request.getParameter("CNPJ_fornecedor");

        String telefone =
            request.getParameter("telefone_fornecedor");

        String categoria =
            request.getParameter("categoria_fornecedor");

        String email =
            request.getParameter("email");

        // ================= VALIDAÇÕES =================

        if (nome == null || nome.isBlank()) {
            throw new Exception(
                "Nome do fornecedor obrigatório"
            );
        }

        if (cnpj == null || cnpj.isBlank()) {
            throw new Exception(
                "CNPJ obrigatório"
            );
        }

        if (telefone == null || telefone.isBlank()) {
            throw new Exception(
                "Telefone obrigatório"
            );
        }

        if (categoria == null || categoria.isBlank()) {
            throw new Exception(
                "Categoria obrigatória"
            );
        }

        if (email == null || !email.contains("@")) {
            throw new Exception(
                "Email inválido"
            );
        }

        fornecedorModel fornecedor =
            new fornecedorModel(
                idFornecedor,
                nome,
                cnpj,
                telefone,
                categoria,
                email
            );

        fornecedorDAO.atualizarFornecedor(fornecedor);

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeOrganizador.jsp"
        );
    }

    // ================= BUSCAR POR ID =================
    private void buscarFornecedor(HttpServletRequest request,
                                  HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {
            throw new Exception(
                "ID do fornecedor não informado"
            );
        }

        int idFornecedor =
            Integer.parseInt(idParametro);

        fornecedorModel fornecedor =
            fornecedorDAO.buscarPorId(idFornecedor);

        request.setAttribute(
            "fornecedor",
            fornecedor
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/detalhesFornecedor.jsp"
            );

        dispatcher.forward(request, response);
    }

    // ================= EXCLUIR =================
    private void excluirFornecedor(HttpServletRequest request,
                                   HttpServletResponse response)
            throws Exception {

        String idParametro =
            request.getParameter("id");

        if (idParametro == null || idParametro.isBlank()) {
            throw new Exception(
                "ID do fornecedor não informado"
            );
        }

        int idFornecedor =
            Integer.parseInt(idParametro);

        fornecedorDAO.excluirFornecedor(idFornecedor);

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeOrganizador.jsp"
        );
    }

    // ================= LISTAR =================
    private void listarFornecedores(HttpServletRequest request,
                                    HttpServletResponse response)
            throws Exception {

        List<fornecedorModel> lista =
            fornecedorDAO.listarFornecedores();

        request.setAttribute(
            "listaFornecedores",
            lista
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/listaFornecedores.jsp"
            );

        dispatcher.forward(request, response);
    }
}