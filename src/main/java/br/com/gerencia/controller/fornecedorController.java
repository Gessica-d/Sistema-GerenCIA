package br.com.gerencia.controller;

import br.com.gerencia.dao.contratoDAO;
import br.com.gerencia.dao.fornecedorDAO;
import br.com.gerencia.model.contratoModel;
import br.com.gerencia.model.fornecedorModel;
import br.com.gerencia.utils.Conexao;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/fornecedorController")
@MultipartConfig(
    maxFileSize = 10 * 1024 * 1024,       // 10MB por arquivo
    maxRequestSize = 12 * 1024 * 1024
)
public class fornecedorController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private fornecedorDAO fornecedorDAO;
    private contratoDAO contratoDAO;

    // ================= INIT =================
    @Override
    public void init() {

        try {

            fornecedorDAO = new fornecedorDAO(Conexao.getConnection());
            contratoDAO = new contratoDAO(Conexao.getConnection());

        } catch (Exception e) {

            throw new RuntimeException(
                "Erro ao iniciar fornecedorDAO: " + e.getMessage()
            );
        }
    }

    // =====================================================
    // SALVAR ARQUIVO DO CONTRATO (upload), usado quando o
    // fornecedor já é vinculado a um evento no próprio
    // cadastro do fornecedor.
    // =====================================================
    private String salvarArquivoContrato(HttpServletRequest request, String nomeCampo) throws Exception {

        Part filePart = request.getPart(nomeCampo);

        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        String header = filePart.getHeader("content-disposition");
        String nomeOriginal = null;

        for (String token : header.split(";")) {
            if (token.trim().startsWith("filename")) {
                nomeOriginal = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }

        if (nomeOriginal == null || nomeOriginal.isBlank()) {
            return null;
        }

        String extensao = "";
        int pontoIdx = nomeOriginal.lastIndexOf('.');
        if (pontoIdx >= 0) {
            extensao = nomeOriginal.substring(pontoIdx);
        }

        String nomeArmazenado = "ctr_" + System.currentTimeMillis() + extensao;

        String caminhoReal = getServletContext().getRealPath("/uploads/contratos/");

        File pastaDestino = new File(caminhoReal);

        if (!pastaDestino.exists()) {
            pastaDestino.mkdirs();
        }

        Path destino = Paths.get(caminhoReal, nomeArmazenado);

        try (InputStream in = filePart.getInputStream()) {
            Files.copy(in, destino, StandardCopyOption.REPLACE_EXISTING);
        }

        return "uploads/contratos/" + nomeArmazenado;
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

        if (fornecedorDAO.buscarPorCNPJ(cnpj) != null) {

            HttpSession session = request.getSession(false);

            if (session != null) {
                session.setAttribute("flashMsg", "Já existe um fornecedor cadastrado com esse CNPJ.");
            }

            String voltarPara = request.getParameter("voltarPara");
            String destino = (voltarPara != null && voltarPara.startsWith("/pages/homeOrganizador.jsp"))
                ? voltarPara
                : "/pages/homeOrganizador.jsp?view=fornecedores";

            response.sendRedirect(
                request.getContextPath()
                + destino
            );

            return;
        }

        fornecedorModel fornecedor =
            new fornecedorModel(
                nome,
                cnpj,
                telefone,
                categoria,
                email
            );

        int idFornecedorGerado = fornecedorDAO.adicionarFornecedor(fornecedor);

        // =================================================
        // VÍNCULO OPCIONAL DE CONTRATO A UM EVENTO EXISTENTE
        // Campos "*_vinculo" só chegam preenchidos se o organizador
        // marcou "Já vincular um contrato a um evento existente".
        // =================================================
        String idEventoVinculo = request.getParameter("id_evento_vinculo");

        if (idEventoVinculo != null && !idEventoVinculo.isBlank()) {

            String dataContratoParam = request.getParameter("data_contrato_vinculo");
            String valorPagoParam = request.getParameter("valor_pago_vinculo");
            String valorTotalParam = request.getParameter("valor_total_vinculo");
            String responsavel = request.getParameter("responsavel_contrato_vinculo");
            String contato = request.getParameter("contato_responsavel_vinculo");
            String objeto = request.getParameter("objeto_contrato_vinculo");

            LocalDateTime dataContrato = (dataContratoParam != null && !dataContratoParam.isBlank())
                ? LocalDateTime.parse(dataContratoParam + "T00:00:00")
                : LocalDateTime.now();

            double valorPago = (valorPagoParam != null && !valorPagoParam.isBlank())
                ? Double.parseDouble(valorPagoParam) : 0;

            double valorTotal = (valorTotalParam != null && !valorTotalParam.isBlank())
                ? Double.parseDouble(valorTotalParam) : 0;

            String anexo = salvarArquivoContrato(request, "arquivo_contrato_vinculo");

            contratoModel contrato = new contratoModel(
                idFornecedorGerado,
                Integer.parseInt(idEventoVinculo),
                dataContrato,
                valorPago,
                valorTotal,
                (responsavel != null && !responsavel.isBlank()) ? responsavel : "Não informado",
                contato,
                (objeto != null && !objeto.isBlank()) ? objeto : "Vinculado no cadastro do fornecedor",
                anexo
            );

            contratoDAO.adicionarContrato(contrato);
        }

        response.sendRedirect(
            request.getContextPath()
            + destinoAposCadastro(request)
        );
    }

    // =====================================================
    // Permite que quem chamou este controller (ex.: o formulário
    // inline de "Cadastrar fornecedor" dentro da tela de criar
    // evento) peça para voltar para uma tela específica em vez do
    // dashboard padrão. Só aceitamos caminhos internos conhecidos,
    // para não abrir um redirect arbitrário.
    // =====================================================
    private String destinoAposCadastro(HttpServletRequest request) {

        String voltarPara = request.getParameter("voltarPara");

        if (voltarPara != null && voltarPara.startsWith("/pages/homeOrganizador.jsp")) {
            return voltarPara;
        }

        return "/pages/homeOrganizador.jsp";
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