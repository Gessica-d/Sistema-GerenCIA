package br.com.gerencia.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import br.com.gerencia.model.notificacaoModel;

// acesso à tabela notificacao
public class notificacaoDAO {

    private Connection conexao;

    // Construtor da conexão com o BD
    public notificacaoDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // ADICIONAR NOTIFICAÇÃO
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

    // LISTAR NOTIFICAÇÕES
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

    // LISTAR NOTIFICAÇÕES DE UM USUÁRIO
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

    // CONTAR NÃO LIDAS
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

    // MARCAR TODAS COMO LIDAS (DE UM USUÁRIO)
    public void marcarTodasComoLidas(int idUsuario) throws Exception {

        String sql = "UPDATE notificacao SET status_notificacao = 'lida' "
                   + "WHERE id_usuario = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idUsuario);

        stmt.executeUpdate();

        stmt.close();
    }

    // BUSCAR NOTIFICAÇÃO POR ID
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

    // ATUALIZAR NOTIFICAÇÃO
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

    // EXCLUIR NOTIFICAÇÃO
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
            rs.getObject("data_envio", java.time.LocalDateTime.class),
            rs.getInt("id_inscricao"),
            rs.getInt("id_usuario")
        );
    }
}