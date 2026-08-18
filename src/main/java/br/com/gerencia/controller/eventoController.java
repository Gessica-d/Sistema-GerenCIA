package br.com.gerencia.controller;

import br.com.gerencia.dao.contratoDAO;
import br.com.gerencia.dao.eventoDAO;
import br.com.gerencia.dao.inscricaoDAO;
import br.com.gerencia.model.contratoModel;
import br.com.gerencia.model.eventoModel;
import br.com.gerencia.model.usuarioModel;
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

@WebServlet("/eventoController")
@MultipartConfig(
    maxFileSize = 10 * 1024 * 1024,       // 10MB por arquivo
    maxRequestSize = 12 * 1024 * 1024
)
public class eventoController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private eventoDAO eventoDAO;
    private inscricaoDAO inscricaoDAO;
    private contratoDAO contratoDAO;

    // ================= INIT =================
    @Override
    public void init() {

        try {

            eventoDAO = new eventoDAO(Conexao.getConnection());
            inscricaoDAO = new inscricaoDAO(Conexao.getConnection());
            contratoDAO = new contratoDAO(Conexao.getConnection());

        } catch (Exception e) {

            throw new RuntimeException(
                "Erro ao iniciar eventoDAO: " + e.getMessage()
            );
        }
    }

    // =====================================================
    // Quantidade de pessoas já vinculadas ao evento
    // (confirmadas + em lista de espera). Usado para travar a
    // edição de campos sensíveis quando já existe alguém inscrito.
    // =====================================================
    private int contarVinculadosAoEvento(int idEvento) throws Exception {

        int confirmados = inscricaoDAO.contarConfirmados(idEvento);
        int emEspera = inscricaoDAO.listarPorEventoEStatus(idEvento, "Espera").size();

        return confirmados + emEspera;
    }

    // =====================================================
    // SALVAR ARQUIVO DO CONTRATO (upload), usado quando um
    // fornecedor é vinculado já na tela de criação do evento.
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

                excluirEvento(request, response);
                return;
            }

            if ("buscar".equals(action)) {

                buscarEvento(request, response);
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

        if (dataInicio.isBefore(LocalDateTime.now())) {
            throw new Exception(
                "Não é possível criar um evento com data/horário de início já no passado"
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

        // =================================================
        // VÍNCULO OPCIONAL DE FORNECEDOR JÁ NA CRIAÇÃO
        // Campos "vinculo_*" só chegam preenchidos se o organizador
        // abriu o bloco "Vincular fornecedor" no formulário de criar
        // evento. Se não usou, simplesmente não faz nada aqui.
        // =================================================
        String idFornecedorVinculo = request.getParameter("vinculo_id_fornecedor");

        if (idFornecedorVinculo != null && !idFornecedorVinculo.isBlank()) {

            String dataContratoParam = request.getParameter("vinculo_data_contrato");
            String valorPagoParam = request.getParameter("vinculo_valor_pago");
            String valorTotalParam = request.getParameter("vinculo_valor_total");
            String responsavel = request.getParameter("vinculo_responsavel_contrato");
            String contato = request.getParameter("vinculo_contato_responsavel");
            String objeto = request.getParameter("vinculo_objeto_contrato");

            LocalDateTime dataContrato = (dataContratoParam != null && !dataContratoParam.isBlank())
                ? LocalDateTime.parse(dataContratoParam + "T00:00:00")
                : LocalDateTime.now();

            double valorPago = (valorPagoParam != null && !valorPagoParam.isBlank())
                ? Double.parseDouble(valorPagoParam) : 0;

            double valorTotal = (valorTotalParam != null && !valorTotalParam.isBlank())
                ? Double.parseDouble(valorTotalParam) : 0;

            String anexo = salvarArquivoContrato(request, "vinculo_arquivo_contrato");

            contratoModel contrato = new contratoModel(
                Integer.parseInt(idFornecedorVinculo),
                idEventoGerado,
                dataContrato,
                valorPago,
                valorTotal,
                (responsavel != null && !responsavel.isBlank()) ? responsavel : "Não informado",
                contato,
                (objeto != null && !objeto.isBlank()) ? objeto : "Vinculado na criação do evento",
                anexo
            );

            contratoDAO.adicionarContrato(contrato);
        }

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeOrganizador.jsp?view=eventos"
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

        eventoModel existente = eventoDAO.buscarPorId(idEvento);

        if (existente == null) {
            throw new Exception("Evento não encontrado");
        }

        HttpSession session = request.getSession(true);

        int vinculados = contarVinculadosAoEvento(idEvento);

        LocalDateTime dataInicio;
        LocalDateTime dataFim;
        int capacidade;

        // =================================================
        // TRAVA DE CAMPOS SENSÍVEIS
        // Assim que o evento já tem alguém inscrito (confirmado
        // ou em lista de espera), nome/tipo/datas/local/código/
        // categoria não podem mais mudar — o servidor ignora
        // qualquer valor recebido para esses campos e preserva
        // o que já está salvo. Descrição, status e (com ressalva)
        // capacidade continuam editáveis, além dos fornecedores/
        // contratos, que são tratados em outro controller.
        // =================================================
        if (vinculados > 0) {

            nome = existente.getNome_evento();
            tipo = existente.getTipo_evento();
            local = existente.getLocal_evento();
            codigo = existente.getCodigo_evento();
            categoria = existente.getCategoria_evento();
            dataInicio = existente.getInicio_evento();
            dataFim = existente.getFim_evento();

            capacidade = Integer.parseInt(capacidadeParametro);

            if (capacidade < vinculados) {

                session.setAttribute(
                    "flashMsg",
                    "Não é possível reduzir a capacidade para menos que o número de "
                    + "inscritos/na fila já existentes (" + vinculados + ")."
                );

                response.sendRedirect(
                    request.getContextPath()
                    + "/pages/homeOrganizador.jsp?view=eventos&abrirEvento=" + idEvento
                );

                return;
            }

        } else {

            dataInicio = LocalDateTime.parse(inicio);
            dataFim = LocalDateTime.parse(fim);

            if (!dataFim.isAfter(dataInicio)) {

                session.setAttribute("flashMsg", "A data de término deve ser posterior à data de início.");

                response.sendRedirect(
                    request.getContextPath()
                    + "/pages/homeOrganizador.jsp?view=eventos&abrirEvento=" + idEvento
                );

                return;
            }

            if (dataInicio.isBefore(LocalDateTime.now())) {

                session.setAttribute("flashMsg", "Não é possível deixar o evento com data/horário de início já no passado.");

                response.sendRedirect(
                    request.getContextPath()
                    + "/pages/homeOrganizador.jsp?view=eventos&abrirEvento=" + idEvento
                );

                return;
            }

            capacidade = Integer.parseInt(capacidadeParametro);
        }

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

        session.setAttribute("flashMsg", "Evento atualizado com sucesso.");

        response.sendRedirect(
            request.getContextPath()
            + "/pages/homeOrganizador.jsp?view=eventos&abrirEvento=" + idEvento
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

        eventoDAO.excluirEventoComDependencias(idEvento);

        HttpSession sessaoExclusao = request.getSession(false);

        usuarioModel usuarioExclusao = sessaoExclusao != null
            ? (usuarioModel) sessaoExclusao.getAttribute("usuarioLogado")
            : null;

        String destinoExclusao = "/pages/homeOrganizador.jsp?view=eventos";

        if (usuarioExclusao != null && "admin".equals(usuarioExclusao.getTipo_usuario())) {
            destinoExclusao = "/pages/homeAdmin.jsp?view=eventos";
        }

        response.sendRedirect(
            request.getContextPath()
            + destinoExclusao
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