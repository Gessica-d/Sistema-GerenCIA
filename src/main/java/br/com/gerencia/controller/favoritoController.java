package br.com.gerencia.controller;

import br.com.gerencia.dao.favoritoDAO;
import br.com.gerencia.model.favoritoModel;
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

@WebServlet("/favoritoController")
public class favoritoController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private favoritoDAO favoritoDAO;

 
    @Override
    public void init() {

        try {

            Connection conexao = Conexao.getConnection();

            favoritoDAO = new favoritoDAO(conexao);

        } catch (Exception e) {

            throw new RuntimeException(
                "Erro ao iniciar favoritoDAO: " + e.getMessage()
            );
        }
    }

    // GET
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        try {

            String action = request.getParameter("action");

            if ("excluir".equals(action)) {

                excluirFavorito(request, response);
                return;
            }

            if ("buscar".equals(action)) {

                buscarFavorito(request, response);
                return;
            }

            listarFavoritos(request, response);

        } catch (Exception e) {

            throw new ServletException(e);
        }
    }

    //  POST 
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
                    cadastrarFavorito(request, response);
                    break;

                case "excluir":
                    excluirFavorito(request, response);
                    break;

                default:
                    listarFavoritos(request, response);
                    break;
            }

        } catch (Exception e) {

            throw new ServletException(e);
        }
    }

    // CADASTRAR 
    private void cadastrarFavorito(HttpServletRequest request,
                                   HttpServletResponse response)
            throws Exception {

        String idUsuarioParametro =
            request.getParameter("id_usuario");

        String idEventoParametro =
            request.getParameter("id_evento");

        String dataFavoritoParametro =
            request.getParameter("data_favorito");

        // ================= VALIDAÇÕES =================

        if (idUsuarioParametro == null
                || idUsuarioParametro.isBlank()) {

            throw new Exception(
                "Usuário não informado"
            );
        }

        if (idEventoParametro == null
                || idEventoParametro.isBlank()) {

            throw new Exception(
                "Evento não informado"
            );
        }

        // ================= CONVERSÕES =================

        int idUsuario =
            Integer.parseInt(idUsuarioParametro);

        int idEvento =
            Integer.parseInt(idEventoParametro);

        LocalDateTime dataFavorito;

        if (dataFavoritoParametro == null
                || dataFavoritoParametro.isBlank()) {

            dataFavorito = LocalDateTime.now();

        } else {

            dataFavorito =
                LocalDateTime.parse(dataFavoritoParametro);
        }

        // ================= VERIFICAR DUPLICIDADE =================

        favoritoModel favoritoExistente =
            favoritoDAO.buscarFavorito(
                idUsuario,
                idEvento
            );

        if (favoritoExistente != null) {

            throw new Exception(
                "Este evento já está nos favoritos"
            );
        }

        // ================= MODEL =================

        favoritoModel favorito =
            new favoritoModel(
                idUsuario,
                idEvento,
                dataFavorito
            );

        // ================= DAO =================

        favoritoDAO.adicionarFavorito(favorito);

        response.sendRedirect(
            request.getContextPath()
            + "/pages/home.jsp?view=favoritos"
        );
    }

    // ================= BUSCAR =================
    private void buscarFavorito(HttpServletRequest request,
                                HttpServletResponse response)
            throws Exception {

        String idUsuarioParametro =
            request.getParameter("id_usuario");

        String idEventoParametro =
            request.getParameter("id_evento");

        if (idUsuarioParametro == null
                || idUsuarioParametro.isBlank()) {

            throw new Exception(
                "Usuário não informado"
            );
        }

        if (idEventoParametro == null
                || idEventoParametro.isBlank()) {

            throw new Exception(
                "Evento não informado"
            );
        }

        int idUsuario =
            Integer.parseInt(idUsuarioParametro);

        int idEvento =
            Integer.parseInt(idEventoParametro);

        favoritoModel favorito =
            favoritoDAO.buscarFavorito(
                idUsuario,
                idEvento
            );

        request.setAttribute(
            "favorito",
            favorito
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/detalhesFavorito.jsp"
            );

        dispatcher.forward(request, response);
    }

    // ================= EXCLUIR =================
    private void excluirFavorito(HttpServletRequest request,
                                 HttpServletResponse response)
            throws Exception {

        String idUsuarioParametro =
            request.getParameter("id_usuario");

        String idEventoParametro =
            request.getParameter("id_evento");

        if (idUsuarioParametro == null
                || idUsuarioParametro.isBlank()) {

            throw new Exception(
                "Usuário não informado"
            );
        }

        if (idEventoParametro == null
                || idEventoParametro.isBlank()) {

            throw new Exception(
                "Evento não informado"
            );
        }

        int idUsuario =
            Integer.parseInt(idUsuarioParametro);

        int idEvento =
            Integer.parseInt(idEventoParametro);

        favoritoDAO.excluirFavorito(
            idUsuario,
            idEvento
        );

        response.sendRedirect(
            request.getContextPath()
            + "/pages/home.jsp?view=favoritos"
        );
    }

    // ================= LISTAR =================
    private void listarFavoritos(HttpServletRequest request,
                                 HttpServletResponse response)
            throws Exception {

        List<favoritoModel> lista =
            favoritoDAO.listarFavoritos();

        request.setAttribute(
            "listaFavoritos",
            lista
        );

        RequestDispatcher dispatcher =
            request.getRequestDispatcher(
                "/pages/listaFavoritos.jsp"
            );

        dispatcher.forward(request, response);
    }
}