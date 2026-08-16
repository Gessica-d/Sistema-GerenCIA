package br.com.gerencia.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import br.com.gerencia.model.favoritoModel;

public class favoritoDAO {

    private Connection conexao;

    // Construtor da conexão com o BD
    public favoritoDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // ================= ADICIONAR FAVORITO =================
    public void adicionarFavorito(favoritoModel favorito) throws Exception {

        String sql = "INSERT INTO favorito "
                   + "(id_usuario, id_evento, data_favorito) "
                   + "VALUES (?, ?, ?)";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, favorito.getId_usuario());
        stmt.setInt(2, favorito.getId_evento());
        stmt.setObject(3, favorito.getData_favorito());

        stmt.executeUpdate();

        stmt.close();
    }

    // ================= LISTAR FAVORITOS =================
    public List<favoritoModel> listarFavoritos() throws Exception {

        List<favoritoModel> favoritos = new ArrayList<>();

        String sql = "SELECT * FROM favorito";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {

            favoritoModel favorito = new favoritoModel(
                rs.getInt("id_usuario"),
                rs.getInt("id_evento"),
                rs.getObject("data_favorito", java.time.LocalDateTime.class)
            );

            favoritos.add(favorito);
        }

        rs.close();
        stmt.close();

        return favoritos;
    }

    // ================= BUSCAR FAVORITO =================
    public favoritoModel buscarFavorito(int idUsuario, int idEvento) throws Exception {

        String sql = "SELECT * FROM favorito "
                   + "WHERE id_usuario = ? AND id_evento = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idUsuario);
        stmt.setInt(2, idEvento);

        ResultSet rs = stmt.executeQuery();

        favoritoModel favorito = null;

        if (rs.next()) {

            favorito = new favoritoModel(
                rs.getInt("id_usuario"),
                rs.getInt("id_evento"),
                rs.getObject("data_favorito", java.time.LocalDateTime.class)
            );
        }

        rs.close();
        stmt.close();

        return favorito;
    }

    // ================= EXCLUIR FAVORITO =================
    public void excluirFavorito(int idUsuario, int idEvento) throws Exception {

        String sql = "DELETE FROM favorito "
                   + "WHERE id_usuario = ? AND id_evento = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idUsuario);
        stmt.setInt(2, idEvento);

        stmt.executeUpdate();

        stmt.close();
    }
}