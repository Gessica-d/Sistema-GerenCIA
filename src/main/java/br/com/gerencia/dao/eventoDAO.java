package br.com.gerencia.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import br.com.gerencia.model.eventoModel;

public class eventoDAO {

    private Connection conexao;

    // Construtor da conexão 
    public eventoDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // add evento
  
    public int adicionarEvento(eventoModel evento) throws Exception {

        String sql = "INSERT INTO evento "
                   + "(nome_evento, tipo_evento, inicio_evento, fim_evento, "
                   + "local_evento, capacidade_evento, codigo_evento, "
                   + "descricao_evento, status_evento, categoria_evento, id_organizador) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        PreparedStatement stmt = conexao.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);

        stmt.setString(1, evento.getNome_evento());
        stmt.setString(2, evento.getTipo_evento());
        stmt.setObject(3, evento.getInicio_evento());
        stmt.setObject(4, evento.getFim_evento());
        stmt.setString(5, evento.getLocal_evento());
        stmt.setInt(6, evento.getCapacidade_evento());
        stmt.setString(7, evento.getCodigo_evento());
        stmt.setString(8, evento.getDescricao_evento());
        stmt.setString(9, evento.getStatus_evento());
        stmt.setString(10, evento.getCategoria_evento());
        stmt.setInt(11, evento.getId_organizador());

        stmt.executeUpdate();

        int idGerado = 0;
        ResultSet keys = stmt.getGeneratedKeys();
        if (keys.next()) {
            idGerado = keys.getInt(1);
        }
        keys.close();
        stmt.close();

        return idGerado;
    }

    // listar eventos
    public List<eventoModel> listarEventos() throws Exception {

        List<eventoModel> eventos = new ArrayList<>();

        String sql = "SELECT * FROM evento";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {

            eventoModel evento = new eventoModel(
                rs.getInt("id_evento"),
                rs.getString("nome_evento"),
                rs.getString("tipo_evento"),
                rs.getTimestamp("inicio_evento").toLocalDateTime(),
                rs.getTimestamp("fim_evento").toLocalDateTime(),
                rs.getString("local_evento"),
                rs.getInt("capacidade_evento"),
                rs.getString("codigo_evento"),
                rs.getString("descricao_evento"),
                rs.getString("status_evento"),
                rs.getString("categoria_evento"),
                rs.getInt("id_organizador")
            );

            eventos.add(evento);
        }

        rs.close();
        stmt.close();

        return eventos;
    }

    // buscar eventos por id
    public eventoModel buscarPorId(int idEvento) throws Exception {

        String sql = "SELECT * FROM evento WHERE id_evento = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idEvento);

        ResultSet rs = stmt.executeQuery();

        eventoModel evento = null;

        if (rs.next()) {

            evento = new eventoModel(
                rs.getInt("id_evento"),
                rs.getString("nome_evento"),
                rs.getString("tipo_evento"),
                rs.getTimestamp("inicio_evento").toLocalDateTime(),
                rs.getTimestamp("fim_evento").toLocalDateTime(),
                rs.getString("local_evento"),
                rs.getInt("capacidade_evento"),
                rs.getString("codigo_evento"),
                rs.getString("descricao_evento"),
                rs.getString("status_evento"),
                rs.getString("categoria_evento"),
                rs.getInt("id_organizador")
            );
        }

        rs.close();
        stmt.close();

        return evento;
    }

    // atualizar eventos
    public void atualizarEvento(eventoModel evento) throws Exception {

        String sql = "UPDATE evento SET "
                   + "nome_evento = ?, "
                   + "tipo_evento = ?, "
                   + "inicio_evento = ?, "
                   + "fim_evento = ?, "
                   + "local_evento = ?, "
                   + "capacidade_evento = ?, "
                   + "codigo_evento = ?, "
                   + "descricao_evento = ?, "
                   + "status_evento = ?, "
                   + "categoria_evento = ?, "
                   + "id_organizador = ? "
                   + "WHERE id_evento = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, evento.getNome_evento());
        stmt.setString(2, evento.getTipo_evento());
        stmt.setObject(3, evento.getInicio_evento());
        stmt.setObject(4, evento.getFim_evento());
        stmt.setString(5, evento.getLocal_evento());
        stmt.setInt(6, evento.getCapacidade_evento());
        stmt.setString(7, evento.getCodigo_evento());
        stmt.setString(8, evento.getDescricao_evento());
        stmt.setString(9, evento.getStatus_evento());
        stmt.setString(10, evento.getCategoria_evento());
        stmt.setInt(11, evento.getId_organizador());
        stmt.setInt(12, evento.getId_evento());

        stmt.executeUpdate();

        stmt.close();
    }

    // atualizar status
    public void atualizarStatus(int idEvento, String novoStatus) throws Exception {

        String sql = "UPDATE evento SET status_evento = ? WHERE id_evento = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, novoStatus);
        stmt.setInt(2, idEvento);

        stmt.executeUpdate();

        stmt.close();
    }

    // excluir evento
    public void excluirEvento(int idEvento) throws Exception {

        String sql = "DELETE FROM evento WHERE id_evento = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idEvento);

        stmt.executeUpdate();

        stmt.close();
    }
}