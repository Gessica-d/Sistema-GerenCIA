package br.com.gerencia.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
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
        if (inscricao.getCheckin() != null) {
            stmt.setTimestamp(6, Timestamp.valueOf(inscricao.getCheckin()));
        } else {
            stmt.setNull(6, java.sql.Types.TIMESTAMP);
        }
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
                lerCheckin(rs),
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
                lerCheckin(rs),
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
        if (inscricao.getCheckin() != null) {
            stmt.setTimestamp(6, Timestamp.valueOf(inscricao.getCheckin()));
        } else {
            stmt.setNull(6, java.sql.Types.TIMESTAMP);
        }
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

    // ================= ATUALIZAR SOMENTE O STATUS =================
    public void atualizarStatus(int idInscricao, String novoStatus) throws Exception {

        String sql = "UPDATE inscricao SET status_inscricao = ? WHERE id_inscricao = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, novoStatus);
        stmt.setInt(2, idInscricao);

        stmt.executeUpdate();

        stmt.close();
    }

    // ================= PRÓXIMO DA LISTA DE ESPERA DE UM EVENTO =================
    // Retorna a inscrição mais antiga com status 'Espera' para o evento informado
    // (respeita a ordem de inscrição, do primeiro que entrou na fila).
    public inscricaoModel buscarProximoNaFila(int idEvento) throws Exception {

        String sql = "SELECT * FROM inscricao "
                   + "WHERE id_evento = ? AND status_inscricao = 'Espera' "
                   + "ORDER BY data_inscricao ASC LIMIT 1";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idEvento);

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
                lerCheckin(rs),
                rs.getInt("posicao_fila")
            );
        }

        rs.close();
        stmt.close();

        return inscricao;
    }

    // ================= QUANTIDADE CONFIRMADA EM UM EVENTO =================
    public int contarConfirmados(int idEvento) throws Exception {

        String sql = "SELECT COUNT(*) AS total FROM inscricao "
                   + "WHERE id_evento = ? AND status_inscricao = 'Confirmada'";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idEvento);

        ResultSet rs = stmt.executeQuery();

        int total = 0;

        if (rs.next()) {
            total = rs.getInt("total");
        }

        rs.close();
        stmt.close();

        return total;
    }

    // ================= QUANTIDADE NA LISTA DE ESPERA DE UM EVENTO =================
    public int contarEspera(int idEvento) throws Exception {

        String sql = "SELECT COUNT(*) AS total FROM inscricao "
                   + "WHERE id_evento = ? AND status_inscricao = 'Espera'";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idEvento);

        ResultSet rs = stmt.executeQuery();

        int total = 0;

        if (rs.next()) {
            total = rs.getInt("total");
        }

        rs.close();
        stmt.close();

        return total;
    }

    // ================= ATUALIZAR SOMENTE O CHECK-IN =================
    // Usado no momento em que o usuário efetivamente realiza o check-in
    // no evento (deve respeitar a janela de tempo do evento, validada
    // na camada de controller antes de chamar este método).
    public void atualizarCheckin(int idInscricao, java.time.LocalDateTime checkin) throws Exception {

        String sql = "UPDATE inscricao SET checkin = ? WHERE id_inscricao = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        if (checkin != null) {
            stmt.setTimestamp(1, Timestamp.valueOf(checkin));
        } else {
            stmt.setNull(1, java.sql.Types.TIMESTAMP);
        }
        stmt.setInt(2, idInscricao);

        stmt.executeUpdate();

        stmt.close();
    }

    // ================= LISTAR INSCRIÇÕES DE UM EVENTO POR STATUS =================
    public List<inscricaoModel> listarPorEventoEStatus(int idEvento, String status) throws Exception {

        List<inscricaoModel> lista = new ArrayList<>();

        String sql = "SELECT * FROM inscricao "
                   + "WHERE id_evento = ? AND status_inscricao = ? "
                   + "ORDER BY data_inscricao ASC";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idEvento);
        stmt.setString(2, status);

        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {

            lista.add(new inscricaoModel(
                rs.getInt("id_inscricao"),
                rs.getInt("id_evento"),
                rs.getInt("id_usuario"),
                rs.getTimestamp("data_inscricao").toLocalDateTime(),
                rs.getString("status_inscricao"),
                rs.getString("metodo_inscricao"),
                lerCheckin(rs),
                rs.getInt("posicao_fila")
            ));
        }

        rs.close();
        stmt.close();

        return lista;
    }

    // ================= HELPER: leitura null-safe do checkin =================
    private java.time.LocalDateTime lerCheckin(ResultSet rs) throws Exception {
        Timestamp ts = rs.getTimestamp("checkin");
        return ts != null ? ts.toLocalDateTime() : null;
    }
}