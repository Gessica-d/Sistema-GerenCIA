package br.com.gerencia.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import br.com.gerencia.model.notificacaoModel;

public class notificacaoDAO {

    private Connection conexao;

    // Construtor da conexão com o BD
    public notificacaoDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // ================= ADICIONAR NOTIFICAÇÃO =================
    public void adicionarNotificacao(notificacaoModel notificacao) throws Exception {

        String sql = "INSERT INTO notificacao "
                   + "(status_notificacao, data_envio, id_inscricao, id_usuario) "
                   + "VALUES (?, ?, ?, ?)";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, notificacao.getStatus_notificacao());
        stmt.setObject(2, notificacao.getData_envio());
        stmt.setInt(3, notificacao.getId_inscricao());
        stmt.setInt(4, notificacao.getId_usuario());

        stmt.executeUpdate();

        stmt.close();
    }

    // ================= LISTAR NOTIFICAÇÕES =================
    public List<notificacaoModel> listarNotificacoes() throws Exception {

        List<notificacaoModel> notificacoes = new ArrayList<>();

        String sql = "SELECT * FROM notificacao";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {

            notificacaoModel notificacao = new notificacaoModel(
                rs.getInt("id_notificacao"),
                rs.getString("status_notificacao"),
                rs.getTimestamp("data_envio").toLocalDateTime(),
                rs.getInt("id_inscricao"),
                rs.getInt("id_usuario")
            );

            notificacoes.add(notificacao);
        }

        rs.close();
        stmt.close();

        return notificacoes;
    }

    // ================= BUSCAR NOTIFICAÇÃO POR ID =================
    public notificacaoModel buscarPorId(int idNotificacao) throws Exception {

        String sql = "SELECT * FROM notificacao WHERE id_notificacao = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idNotificacao);

        ResultSet rs = stmt.executeQuery();

        notificacaoModel notificacao = null;

        if (rs.next()) {

            notificacao = new notificacaoModel(
                rs.getInt("id_notificacao"),
                rs.getString("status_notificacao"),
                rs.getTimestamp("data_envio").toLocalDateTime(),
                rs.getInt("id_inscricao"),
                rs.getInt("id_usuario")
            );
        }

        rs.close();
        stmt.close();

        return notificacao;
    }

    // ================= ATUALIZAR NOTIFICAÇÃO =================
    public void atualizarNotificacao(notificacaoModel notificacao) throws Exception {

        String sql = "UPDATE notificacao SET "
                   + "status_notificacao = ?, "
                   + "data_envio = ?, "
                   + "id_inscricao = ?, "
                   + "id_usuario = ? "
                   + "WHERE id_notificacao = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, notificacao.getStatus_notificacao());
        stmt.setObject(2, notificacao.getData_envio());
        stmt.setInt(3, notificacao.getId_inscricao());
        stmt.setInt(4, notificacao.getId_usuario());
        stmt.setInt(5, notificacao.getId_notificacao());

        stmt.executeUpdate();

        stmt.close();
    }

    // ================= EXCLUIR NOTIFICAÇÃO =================
    public void excluirNotificacao(int idNotificacao) throws Exception {

        String sql = "DELETE FROM notificacao WHERE id_notificacao = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idNotificacao);

        stmt.executeUpdate();

        stmt.close();
    }
}