package br.com.gerencia.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import br.com.gerencia.model.notificacaoModel;

public class notificacaoDAO {

    private Connection conexao;

    // Construtor da conexão 
    public notificacaoDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // nova notificacao
    public void adicionarNotificacao(notificacaoModel notificacao) throws Exception {

        String sql = "INSERT INTO notificacao "
                   + "(status_notificacao, mensagem, data_envio, id_inscricao, id_usuario) "
                   + "VALUES (?, ?, ?, ?, ?)";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, notificacao.getStatus_notificacao());
        stmt.setString(2, notificacao.getMensagem());
        stmt.setObject(3, notificacao.getData_envio());
        stmt.setInt(4, notificacao.getId_inscricao());
        stmt.setInt(5, notificacao.getId_usuario());

        stmt.executeUpdate();

        stmt.close();
    }

    // listar notificacao
    public List<notificacaoModel> listarNotificacoes() throws Exception {

        List<notificacaoModel> notificacoes = new ArrayList<>();

        String sql = "SELECT * FROM notificacao ORDER BY data_envio DESC";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            notificacoes.add(montar(rs));
        }

        rs.close();
        stmt.close();

        return notificacoes;
    }

    // listar notificacao por user
    public List<notificacaoModel> listarPorUsuario(int idUsuario) throws Exception {

        List<notificacaoModel> notificacoes = new ArrayList<>();

        String sql = "SELECT * FROM notificacao WHERE id_usuario = ? "
                   + "ORDER BY data_envio DESC LIMIT 20";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idUsuario);

        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            notificacoes.add(montar(rs));
        }

        rs.close();
        stmt.close();

        return notificacoes;
    }

    // validar se nao foi lida
    public int contarNaoLidas(int idUsuario) throws Exception {

        String sql = "SELECT COUNT(*) AS total FROM notificacao "
                   + "WHERE id_usuario = ? AND status_notificacao <> 'lida'";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idUsuario);

        ResultSet rs = stmt.executeQuery();

        int total = 0;

        if (rs.next()) {
            total = rs.getInt("total");
        }

        rs.close();
        stmt.close();

        return total;
    }

    // marcar como lida
    public void marcarTodasComoLidas(int idUsuario) throws Exception {

        String sql = "UPDATE notificacao SET status_notificacao = 'lida' "
                   + "WHERE id_usuario = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idUsuario);

        stmt.executeUpdate();

        stmt.close();
    }

    // buscar notificacao por id
    public notificacaoModel buscarPorId(int idNotificacao) throws Exception {

        String sql = "SELECT * FROM notificacao WHERE id_notificacao = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idNotificacao);

        ResultSet rs = stmt.executeQuery();

        notificacaoModel notificacao = null;

        if (rs.next()) {
            notificacao = montar(rs);
        }

        rs.close();
        stmt.close();

        return notificacao;
    }

    // atualizar notificacao
    public void atualizarNotificacao(notificacaoModel notificacao) throws Exception {

        String sql = "UPDATE notificacao SET "
                   + "status_notificacao = ?, "
                   + "mensagem = ?, "
                   + "data_envio = ?, "
                   + "id_inscricao = ?, "
                   + "id_usuario = ? "
                   + "WHERE id_notificacao = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, notificacao.getStatus_notificacao());
        stmt.setString(2, notificacao.getMensagem());
        stmt.setObject(3, notificacao.getData_envio());
        stmt.setInt(4, notificacao.getId_inscricao());
        stmt.setInt(5, notificacao.getId_usuario());
        stmt.setInt(6, notificacao.getId_notificacao());

        stmt.executeUpdate();

        stmt.close();
    }

    // excluir notificao
    public void excluirNotificacao(int idNotificacao) throws Exception {

        String sql = "DELETE FROM notificacao WHERE id_notificacao = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idNotificacao);

        stmt.executeUpdate();

        stmt.close();
    }

    // HELPER
    private notificacaoModel montar(ResultSet rs) throws Exception {

        return new notificacaoModel(
            rs.getInt("id_notificacao"),
            rs.getString("status_notificacao"),
            rs.getString("mensagem"),
            rs.getTimestamp("data_envio").toLocalDateTime(),
            rs.getInt("id_inscricao"),
            rs.getInt("id_usuario")
        );
    }
}
