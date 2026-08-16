package br.com.gerencia.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import br.com.gerencia.model.contratoModel;

public class contratoDAO {

    private Connection conexao;

    // Construtor da conexão 
    public contratoDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // add contrato
    public void adicionarContrato(contratoModel contrato) throws Exception {

        String sql = "INSERT INTO contrato "
                   + "(id_fornecedor, id_evento, data_contrato, valor_pago, "
                   + "valor_total, responsavel_contrato, contato_responsavel, "
                   + "objeto_contrato, anexo_contrato) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, contrato.getId_fornecedor());
        stmt.setInt(2, contrato.getId_evento());
        stmt.setObject(3, contrato.getData_contrato());
        stmt.setDouble(4, contrato.getValor_pago());
        stmt.setDouble(5, contrato.getValor_total());
        stmt.setString(6, contrato.getResponsavel_contrato());
        stmt.setString(7, contrato.getContato_responsavel());
        stmt.setString(8, contrato.getObjeto_contrato());
        stmt.setString(9, contrato.getAnexo_contrato());

        stmt.executeUpdate();

        stmt.close();
    }

    // listar contratos
    public List<contratoModel> listarContratos() throws Exception {

        List<contratoModel> contratos = new ArrayList<>();

        String sql = "SELECT * FROM contrato";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {

            contratoModel contrato = new contratoModel(
                rs.getInt("id_contrato"),
                rs.getInt("id_fornecedor"),
                rs.getInt("id_evento"),
                rs.getTimestamp("data_contrato").toLocalDateTime(),
                rs.getDouble("valor_pago"),
                rs.getDouble("valor_total"),
                rs.getString("responsavel_contrato"),
                rs.getString("contato_responsavel"),
                rs.getString("objeto_contrato"),
                rs.getString("anexo_contrato")
            );

            contratos.add(contrato);
        }

        rs.close();
        stmt.close();

        return contratos;
    }

    // buscar contratos por id
    public contratoModel buscarPorId(int idContrato) throws Exception {

        String sql = "SELECT * FROM contrato WHERE id_contrato = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idContrato);

        ResultSet rs = stmt.executeQuery();

        contratoModel contrato = null;

        if (rs.next()) {

            contrato = new contratoModel(
                rs.getInt("id_contrato"),
                rs.getInt("id_fornecedor"),
                rs.getInt("id_evento"),
                rs.getTimestamp("data_contrato").toLocalDateTime(),
                rs.getDouble("valor_pago"),
                rs.getDouble("valor_total"),
                rs.getString("responsavel_contrato"),
                rs.getString("contato_responsavel"),
                rs.getString("objeto_contrato"),
                rs.getString("anexo_contrato")
            );
        }

        rs.close();
        stmt.close();

        return contrato;
    }

    // atualizar contratos
    public void atualizarContrato(contratoModel contrato) throws Exception {

        String sql = "UPDATE contrato SET "
                   + "id_fornecedor = ?, "
                   + "id_evento = ?, "
                   + "data_contrato = ?, "
                   + "valor_pago = ?, "
                   + "valor_total = ?, "
                   + "responsavel_contrato = ?, "
                   + "contato_responsavel = ?, "
                   + "objeto_contrato = ?, "
                   + "anexo_contrato = ? "
                   + "WHERE id_contrato = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, contrato.getId_fornecedor());
        stmt.setInt(2, contrato.getId_evento());
        stmt.setObject(3, contrato.getData_contrato());
        stmt.setDouble(4, contrato.getValor_pago());
        stmt.setDouble(5, contrato.getValor_total());
        stmt.setString(6, contrato.getResponsavel_contrato());
        stmt.setString(7, contrato.getContato_responsavel());
        stmt.setString(8, contrato.getObjeto_contrato());
        stmt.setString(9, contrato.getAnexo_contrato());
        stmt.setInt(10, contrato.getId_contrato());

        stmt.executeUpdate();

        stmt.close();
    }

    // excluir contratos
    public void excluirContrato(int idContrato) throws Exception {

        String sql = "DELETE FROM contrato WHERE id_contrato = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idContrato);

        stmt.executeUpdate();

        stmt.close();
    }
}