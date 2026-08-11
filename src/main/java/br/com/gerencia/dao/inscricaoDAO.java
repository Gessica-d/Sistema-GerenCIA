package br.com.gerencia.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import br.com.gerencia.model.inscricaoModel;

public class inscricaoDAO {

    private Connection conexao;

    // =========================================================
    // CONSTRUTOR
    // =========================================================

    public inscricaoDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // =========================================================
    // ADICIONAR INSCRIÇÃO
    // =========================================================

    public void adicionarInscricao(inscricaoModel inscricao) throws Exception {

        String sql =
            "INSERT INTO inscricao "
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

    // =========================================================
    // LISTAR TODAS AS INSCRIÇÕES
    // =========================================================

    public List<inscricaoModel> listarInscricoes() throws Exception {

        List<inscricaoModel> inscricoes =
            new ArrayList<inscricaoModel>();

        String sql =
            "SELECT * FROM inscricao";

        PreparedStatement stmt =
            conexao.prepareStatement(sql);

        ResultSet rs =
            stmt.executeQuery();

        while (rs.next()) {

            inscricoes.add(montarInscricao(rs));
        }

        rs.close();
        stmt.close();

        return inscricoes;
    }

    // =========================================================
    // BUSCAR POR ID
    // =========================================================

    public inscricaoModel buscarPorId(int idInscricao)
            throws Exception {

        String sql =
            "SELECT * FROM inscricao "
          + "WHERE id_inscricao = ?";

        PreparedStatement stmt =
            conexao.prepareStatement(sql);

        stmt.setInt(1, idInscricao);

        ResultSet rs =
            stmt.executeQuery();

        inscricaoModel inscricao = null;

        if (rs.next()) {

            inscricao = montarInscricao(rs);
        }

        rs.close();
        stmt.close();

        return inscricao;
    }

    // =========================================================
    // ATUALIZAR INSCRIÇÃO
    // =========================================================

    public void atualizarInscricao(
            inscricaoModel inscricao)
            throws Exception {

        String sql =
            "UPDATE inscricao SET "
          + "id_evento = ?, "
          + "id_usuario = ?, "
          + "data_inscricao = ?, "
          + "status_inscricao = ?, "
          + "metodo_inscricao = ?, "
          + "checkin = ?, "
          + "posicao_fila = ? "
          + "WHERE id_inscricao = ?";

        PreparedStatement stmt =
            conexao.prepareStatement(sql);

        stmt.setInt(
            1,
            inscricao.getId_evento()
        );

        stmt.setInt(
            2,
            inscricao.getId_usuario()
        );

        stmt.setObject(
            3,
            inscricao.getData_inscricao()
        );

        stmt.setString(
            4,
            inscricao.getStatus_inscricao()
        );

        stmt.setString(
            5,
            inscricao.getMetodo_inscricao()
        );

        stmt.setBoolean(
            6,
            inscricao.isCheckin()
        );

        stmt.setInt(
            7,
            inscricao.getPosicao_fila()
        );

        stmt.setInt(
            8,
            inscricao.getId_inscricao()
        );

        stmt.executeUpdate();

        stmt.close();
    }

    // =========================================================
    // EXCLUIR
    // =========================================================

    public void excluirInscricao(
            int idInscricao)
            throws Exception {

        String sql =
            "DELETE FROM inscricao "
          + "WHERE id_inscricao = ?";

        PreparedStatement stmt =
            conexao.prepareStatement(sql);

        stmt.setInt(1, idInscricao);

        stmt.executeUpdate();

        stmt.close();
    }

    // =========================================================
    // ATUALIZAR SOMENTE O STATUS
    // =========================================================

    public void atualizarStatus(
            int idInscricao,
            String novoStatus)
            throws Exception {

        String sql =
            "UPDATE inscricao "
          + "SET status_inscricao = ? "
          + "WHERE id_inscricao = ?";

        PreparedStatement stmt =
            conexao.prepareStatement(sql);

        stmt.setString(1, novoStatus);
        stmt.setInt(2, idInscricao);

        stmt.executeUpdate();

        stmt.close();
    }

    // =========================================================
    // BUSCAR PRÓXIMO DA FILA DE ESPERA
    // =========================================================

    public inscricaoModel buscarProximoNaFila(
            int idEvento)
            throws Exception {

        String sql =
            "SELECT * FROM inscricao "
          + "WHERE id_evento = ? "
          + "AND status_inscricao = 'Espera' "
          + "ORDER BY data_inscricao ASC "
          + "LIMIT 1";

        PreparedStatement stmt =
            conexao.prepareStatement(sql);

        stmt.setInt(1, idEvento);

        ResultSet rs =
            stmt.executeQuery();

        inscricaoModel inscricao = null;

        if (rs.next()) {

            inscricao = montarInscricao(rs);
        }

        rs.close();
        stmt.close();

        return inscricao;
    }

    // =========================================================
    // CONTAR INSCRIÇÕES CONFIRMADAS
    // =========================================================
    // ESTE É UM DOS MÉTODOS QUE O HOMEORGANIZADOR USA
    // =========================================================

    public int contarConfirmados(
            int idEvento)
            throws Exception {

        String sql =
            "SELECT COUNT(*) AS total "
          + "FROM inscricao "
          + "WHERE id_evento = ? "
          + "AND status_inscricao = 'Confirmada'";

        PreparedStatement stmt =
            conexao.prepareStatement(sql);

        stmt.setInt(1, idEvento);

        ResultSet rs =
            stmt.executeQuery();

        int total = 0;

        if (rs.next()) {

            total = rs.getInt("total");
        }

        rs.close();
        stmt.close();

        return total;
    }

    // =========================================================
    // LISTAR POR EVENTO E STATUS
    // =========================================================
    // ESTE É O MÉTODO QUE ESTÁ DANDO ERRO NAS LINHAS 136 E 1210
    // =========================================================

    public List<inscricaoModel> listarPorEventoEStatus(
            int idEvento,
            String status)
            throws Exception {

        List<inscricaoModel> lista =
            new ArrayList<inscricaoModel>();

        String sql =
            "SELECT * FROM inscricao "
          + "WHERE id_evento = ? "
          + "AND status_inscricao = ? "
          + "ORDER BY data_inscricao ASC";

        PreparedStatement stmt =
            conexao.prepareStatement(sql);

        stmt.setInt(1, idEvento);
        stmt.setString(2, status);

        ResultSet rs =
            stmt.executeQuery();

        while (rs.next()) {

            lista.add(
                montarInscricao(rs)
            );
        }

        rs.close();
        stmt.close();

        return lista;
    }

    // =========================================================
    // MÉTODO AUXILIAR
    // =========================================================

    private inscricaoModel montarInscricao(
            ResultSet rs)
            throws Exception {

        return new inscricaoModel(
            rs.getInt("id_inscricao"),
            rs.getInt("id_evento"),
            rs.getInt("id_usuario"),
            rs.getTimestamp("data_inscricao")
              .toLocalDateTime(),
            rs.getString("status_inscricao"),
            rs.getString("metodo_inscricao"),
            rs.getBoolean("checkin"),
            rs.getInt("posicao_fila")
        );
    }
}