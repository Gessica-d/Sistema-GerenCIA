package br.com.gerencia.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import br.com.gerencia.model.inscricaoModel;

public class inscricaoDAO {

    private Connection conexao;

    // Construtor da conexão com o BD
    public inscricaoDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // ================= ADICIONAR INSCRIÇÃO =================
    public void adicionarInscricao(inscricaoModel inscricao) throws Exception {

        String sql = "INSERT INTO inscricao "
                   + "(id_evento, id_usuario, data_inscricao, status_inscricao, "
                   + "metodo_inscricao, checkin, posicao_fila) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, inscricao.getId_evento());
        stmt.setInt(2, inscricao.getId_usuario());
        stmt.setObject(3, inscricao.getData_inscricao());
        stmt.setString(4, inscricao.getStatus_inscricao());
        stmt.setString(5, inscricao.getMetodo_inscricao());
        stmt.setBoolean(6, inscricao.isCheckin());
        stmt.setInt(7, inscricao.getPosicao_fila());

        stmt.executeUpdate();

        stmt.close();
    }

    // ================= LISTAR INSCRIÇÕES =================
    public List<inscricaoModel> listarInscricoes() throws Exception {

        List<inscricaoModel> inscricoes = new ArrayList<>();

        String sql = "SELECT * FROM inscricao";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {

            inscricaoModel inscricao = new inscricaoModel(
                rs.getInt("id_inscricao"),
                rs.getInt("id_evento"),
                rs.getInt("id_usuario"),
                rs.getTimestamp("data_inscricao").toLocalDateTime(),
                rs.getString("status_inscricao"),
                rs.getString("metodo_inscricao"),
                rs.getBoolean("checkin"),
                rs.getInt("posicao_fila")
            );

            inscricoes.add(inscricao);
        }

        rs.close();
        stmt.close();

        return inscricoes;
    }

    // ================= BUSCAR INSCRIÇÃO POR ID =================
    public inscricaoModel buscarPorId(int idInscricao) throws Exception {

        String sql = "SELECT * FROM inscricao WHERE id_inscricao = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idInscricao);

        ResultSet rs = stmt.executeQuery();

        inscricaoModel inscricao = null;

        if (rs.next()) {

            inscricao = new inscricaoModel(
                rs.getInt("id_inscricao"),
                rs.getInt("id_evento"),
                rs.getInt("id_usuario"),
                rs.getTimestamp("data_inscricao").toLocalDateTime(),
                rs.getString("status_inscricao"),
                rs.getString("metodo_inscricao"),
                rs.getBoolean("checkin"),
                rs.getInt("posicao_fila")
            );
        }

        rs.close();
        stmt.close();

        return inscricao;
    }

    // ================= ATUALIZAR INSCRIÇÃO =================
    public void atualizarInscricao(inscricaoModel inscricao) throws Exception {

        String sql = "UPDATE inscricao SET "
                   + "id_evento = ?, "
                   + "id_usuario = ?, "
                   + "data_inscricao = ?, "
                   + "status_inscricao = ?, "
                   + "metodo_inscricao = ?, "
                   + "checkin = ?, "
                   + "posicao_fila = ? "
                   + "WHERE id_inscricao = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, inscricao.getId_evento());
        stmt.setInt(2, inscricao.getId_usuario());
        stmt.setObject(3, inscricao.getData_inscricao());
        stmt.setString(4, inscricao.getStatus_inscricao());
        stmt.setString(5, inscricao.getMetodo_inscricao());
        stmt.setBoolean(6, inscricao.isCheckin());
        stmt.setInt(7, inscricao.getPosicao_fila());
        stmt.setInt(8, inscricao.getId_inscricao());

        stmt.executeUpdate();

        stmt.close();
    }

    // ================= EXCLUIR INSCRIÇÃO =================
    public void excluirInscricao(int idInscricao) throws Exception {

        String sql = "DELETE FROM inscricao WHERE id_inscricao = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idInscricao);

        stmt.executeUpdate();

        stmt.close();
    }
}