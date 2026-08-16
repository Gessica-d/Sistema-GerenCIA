package br.com.gerencia.controller;

import br.com.gerencia.dao.fornecedorDAO;
import br.com.gerencia.dao.contratoDAO;
import br.com.gerencia.model.fornecedorModel;
import br.com.gerencia.model.contratoModel;
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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/fornecedorController")
@MultipartConfig(
    maxFileSize = 10 * 1024 * 1024,
    maxRequestSize = 12 * 1024 * 1024
)
public class fornecedorController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private fornecedorDAO fornecedorDAO;
    private contratoDAO contratoDAO;

    
    @Override
    public void init() {

        try {

            Connection conexao = Conexao.getConnection();

            fornecedorDAO = new fornecedorDAO(conexao);
            contratoDAO = new contratoDAO(conexao);

        } catch (Exception e) {

            throw new RuntimeException(
                "Erro ao iniciar fornecedorDAO: " + e.getMessage()
            );
        }
    }

    // get
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

    // post
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

    // cadastrar
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

        //validações

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

            response.sendRedirect(
                request.getContextPath()
                + "/pages/homeOrganizador.jsp?view=fornecedores"
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

       
        // CONTRATO OPCIONAL (só se o organizador selecionou
        // um evento existente pra vincular na mesma tela)
   

        String idEventoVinculo = request.getParameter("id_evento_vinculo");

        if (idEventoVinculo != null && !idEventoVinculo.isBlank()) {

            String dataContratoParam = request.getParameter("data_contrato_vinculo");
            String valorPagoParam = request.getParameter("valor_pago_vinculo");
            String valorTotalParam = request.getParameter("valor_total_vinculo");
            String responsavelContrato = request.getParameter("responsavel_contrato_vinculo");
            String contatoResponsavel = request.getParameter("contato_responsavel_vinculo");
            String objetoContrato = request.getParameter("objeto_contrato_vinculo");

            LocalDateTime dataContrato = (dataContratoParam == null || dataContratoParam.isBlank())
                ? LocalDateTime.now()
                : LocalDate.parse(dataContratoParam).atStartOfDay();

            double valorPago = (valorPagoParam == null || valorPagoParam.isBlank())
                ? 0.0 : Double.parseDouble(valorPagoParam);

            double valorTotal = (valorTotalParam == null || valorTotalParam.isBlank())
                ? 0.0 : Double.parseDouble(valorTotalParam);

            String anexoContrato = salvarArquivoContratoVinculo(request);

            contratoModel contrato = new contratoModel(
                idFornecedorGerado,
                Integer.parseInt(idEventoVinculo),
                dataContrato,
                valorPago,
                valorTotal,
                (responsavelContrato == null || responsavelContrato.isBlank()) ? nome : responsavelContrato,
                contatoResponsavel,
                (objetoContrato == null || objetoContrato.isBlank())
                    ? "Serviços de " + categoria : objetoContrato,
                anexoContrato
            );

            contratoDAO.adicionarContrato(contrato);
        }

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeOrganizador.jsp"
        );
    }

  
    // SAalvar contrato (anexar), quando o contrato
    // é criado junto do cadastro de fornecedor.
  
    private String salvarArquivoContratoVinculo(HttpServletRequest request) throws Exception {

        Part filePart = request.getPart("arquivo_contrato_vinculo");

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

    // atualizar
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

        // validações

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

    // buscar por id
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

    // excluir
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

    // listar
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