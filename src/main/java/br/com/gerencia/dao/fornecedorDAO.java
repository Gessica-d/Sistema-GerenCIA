package br.com.gerencia.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import br.com.gerencia.model.fornecedorModel;

public class fornecedorDAO {

    private Connection conexao;

    // Construtor da conexão com o BD
    public fornecedorDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // ================= ADICIONAR FORNECEDOR =================
    public void adicionarFornecedor(fornecedorModel fornecedor) throws Exception {

        String sql = "INSERT INTO fornecedor "
                   + "(nome_fornecedor, CNPJ_fornecedor, telefone_fornecedor, "
                   + "categoria_fornecedor, email) "
                   + "VALUES (?, ?, ?, ?, ?)";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, fornecedor.getNome_fornecedor());
        stmt.setString(2, fornecedor.getCNPJ_fornecedor());
        stmt.setString(3, fornecedor.getTelefone_fornecedor());
        stmt.setString(4, fornecedor.getCategoria_fornecedor());
        stmt.setString(5, fornecedor.getEmail());

        stmt.executeUpdate();

        stmt.close();
    }

    // ================= LISTAR FORNECEDORES =================
    public List<fornecedorModel> listarFornecedores() throws Exception {

        List<fornecedorModel> fornecedores = new ArrayList<>();

        String sql = "SELECT * FROM fornecedor";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {

            fornecedorModel fornecedor = new fornecedorModel(
                rs.getInt("id_fornecedor"),
                rs.getString("nome_fornecedor"),
                rs.getString("CNPJ_fornecedor"),
                rs.getString("telefone_fornecedor"),
                rs.getString("categoria_fornecedor"),
                rs.getString("email")
            );

            fornecedores.add(fornecedor);
        }

        rs.close();
        stmt.close();

        return fornecedores;
    }

    // ================= BUSCAR FORNECEDOR POR ID =================
    public fornecedorModel buscarPorId(int idFornecedor) throws Exception {

        String sql = "SELECT * FROM fornecedor WHERE id_fornecedor = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idFornecedor);

        ResultSet rs = stmt.executeQuery();

        fornecedorModel fornecedor = null;

        if (rs.next()) {

            fornecedor = new fornecedorModel(
                rs.getInt("id_fornecedor"),
                rs.getString("nome_fornecedor"),
                rs.getString("CNPJ_fornecedor"),
                rs.getString("telefone_fornecedor"),
                rs.getString("categoria_fornecedor"),
                rs.getString("email")
            );
        }

        rs.close();
        stmt.close();

        return fornecedor;
    }

    // ================= ATUALIZAR FORNECEDOR =================
    public void atualizarFornecedor(fornecedorModel fornecedor) throws Exception {

        String sql = "UPDATE fornecedor SET "
                   + "nome_fornecedor = ?, "
                   + "CNPJ_fornecedor = ?, "
                   + "telefone_fornecedor = ?, "
                   + "categoria_fornecedor = ?, "
                   + "email = ? "
                   + "WHERE id_fornecedor = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, fornecedor.getNome_fornecedor());
        stmt.setString(2, fornecedor.getCNPJ_fornecedor());
        stmt.setString(3, fornecedor.getTelefone_fornecedor());
        stmt.setString(4, fornecedor.getCategoria_fornecedor());
        stmt.setString(5, fornecedor.getEmail());
        stmt.setInt(6, fornecedor.getId_fornecedor());

        stmt.executeUpdate();

        stmt.close();
    }

    // ================= EXCLUIR FORNECEDOR =================
    public void excluirFornecedor(int idFornecedor) throws Exception {

        String sql = "DELETE FROM fornecedor WHERE id_fornecedor = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idFornecedor);

        stmt.executeUpdate();

        stmt.close();
    }
}