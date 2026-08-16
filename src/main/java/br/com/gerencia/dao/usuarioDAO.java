package br.com.gerencia.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import br.com.gerencia.model.usuarioModel;

public class usuarioDAO {


	    private Connection conexao;

	    //Construtor da conexao
	    public usuarioDAO(Connection conexao) {
	        this.conexao = conexao;
	    }

    //  BUSCAR USUARIO PARA LOGIN 
    public usuarioModel buscarPorEmailESenha(String email, String senha) throws Exception {

        String sql = "SELECT * FROM usuario WHERE email_usuario = ? AND senha_usuario = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, email);
        stmt.setString(2, senha);

        ResultSet rs = stmt.executeQuery();

        usuarioModel usuario = null;

        if (rs.next()) {
            usuario = new usuarioModel(
                rs.getInt("id_usuario"),
                rs.getString("CPF_usuario"),
                rs.getString("tipo_usuario"),
                rs.getString("nome_usuario"),
                rs.getString("email_usuario"),
                rs.getString("senha_usuario"),
                rs.getString("telefone")
            );
        }

        rs.close();
        stmt.close();

        return usuario;
    }

    // ADICIONAR USUARIO 
    public void adicionarUsuario(usuarioModel usuario) throws Exception {

        String sql = "INSERT INTO usuario "
                   + "(CPF_usuario, tipo_usuario, nome_usuario, email_usuario, senha_usuario, telefone) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, usuario.getCPF_usuario());
        stmt.setString(2, usuario.getTipo_usuario());
        stmt.setString(3, usuario.getNome_usuario());
        stmt.setString(4, usuario.getEmail_usuario());
        stmt.setString(5, usuario.getSenha_usuario());
        stmt.setString(6, usuario.getTelefone());

        stmt.executeUpdate();

        stmt.close();
    }

    //LISTAR USUÁRIOS
    public List<usuarioModel> listarUsuarios() throws Exception {

        List<usuarioModel> usuarios = new ArrayList<>();

        String sql = "SELECT * FROM usuario";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {

            usuarioModel usuario = new usuarioModel(
                rs.getInt("id_usuario"),
                rs.getString("CPF_usuario"),
                rs.getString("tipo_usuario"),
                rs.getString("nome_usuario"),
                rs.getString("email_usuario"),
                rs.getString("senha_usuario"),
                rs.getString("telefone")
            );

            usuarios.add(usuario);
        }

        rs.close();
        stmt.close();

        return usuarios;
    }

    // BUSCAR USUARIO POR ID 
    public usuarioModel buscarPorId(int idUsuario) throws Exception {

        String sql = "SELECT * FROM usuario WHERE id_usuario = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idUsuario);

        ResultSet rs = stmt.executeQuery();

        usuarioModel usuario = null;

        if (rs.next()) {

            usuario = new usuarioModel(
                rs.getInt("id_usuario"),
                rs.getString("CPF_usuario"),
                rs.getString("tipo_usuario"),
                rs.getString("nome_usuario"),
                rs.getString("email_usuario"),
                rs.getString("senha_usuario"),
                rs.getString("telefone")
            );
        }

        rs.close();
        stmt.close();

        return usuario;
    }

    // buscar user por CPF  não deve se repetir
    public usuarioModel buscarPorCPF(String cpf) throws Exception {

        String sql = "SELECT * FROM usuario WHERE CPF_usuario = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, cpf);

        ResultSet rs = stmt.executeQuery();

        usuarioModel usuario = null;

        if (rs.next()) {

            usuario = new usuarioModel(
                rs.getInt("id_usuario"),
                rs.getString("CPF_usuario"),
                rs.getString("tipo_usuario"),
                rs.getString("nome_usuario"),
                rs.getString("email_usuario"),
                rs.getString("senha_usuario"),
                rs.getString("telefone")
            );
        }

        rs.close();
        stmt.close();

        return usuario;
    }

    // buscar user por email  não deve se repetir
    public usuarioModel buscarPorEmail(String email) throws Exception {

        String sql = "SELECT * FROM usuario WHERE email_usuario = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, email);

        ResultSet rs = stmt.executeQuery();

        usuarioModel usuario = null;

        if (rs.next()) {

            usuario = new usuarioModel(
                rs.getInt("id_usuario"),
                rs.getString("CPF_usuario"),
                rs.getString("tipo_usuario"),
                rs.getString("nome_usuario"),
                rs.getString("email_usuario"),
                rs.getString("senha_usuario"),
                rs.getString("telefone")
            );
        }

        rs.close();
        stmt.close();

        return usuario;
    }

    // atualizar user
    public void atualizarUsuario(usuarioModel usuario) throws Exception {

        String sql = "UPDATE usuario SET "
                   + "CPF_usuario = ?, "
                   + "tipo_usuario = ?, "
                   + "nome_usuario = ?, "
                   + "email_usuario = ?, "
                   + "senha_usuario = ?, "
                   + "telefone = ? "
                   + "WHERE id_usuario = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, usuario.getCPF_usuario());
        stmt.setString(2, usuario.getTipo_usuario());
        stmt.setString(3, usuario.getNome_usuario());
        stmt.setString(4, usuario.getEmail_usuario());
        stmt.setString(5, usuario.getSenha_usuario());
        stmt.setString(6, usuario.getTelefone());
        stmt.setInt(7, usuario.getId_usuario());

        stmt.executeUpdate();

        stmt.close();
    }

    // mudar senha
    public void alterarSenha(int idUsuario, String novaSenha) throws Exception {

        String sql = "UPDATE usuario SET senha_usuario = ? WHERE id_usuario = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, novaSenha);
        stmt.setInt(2, idUsuario);

        stmt.executeUpdate();

        stmt.close();
    }

    // excluir user
    public void excluirUsuario(int idUsuario) throws Exception {

        String sql = "DELETE FROM usuario WHERE id_usuario = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idUsuario);

        stmt.executeUpdate();

        stmt.close();
    }
}