package br.com.gerencia.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import br.com.gerencia.model.eventoModel;

// acesso à tabela evento. excluirEventoComDependencias apaga em
// cascata notificação/inscrição/contrato/favorito antes do evento em si
public class eventoDAO {

    // datas gravadas/lidas com setObject/getObject(LocalDateTime.class),
    // sem conversão de fuso — getTimestamp mudava o horário lido
    // dependendo do fuso da conexão x da JVM

    private Connection conexao;

    // Construtor da conexão com o BD
    public eventoDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // ADICIONAR EVENTO
    // Retorna o id_evento gerado pelo banco (necessário para, por
    // exemplo, já vincular um fornecedor/contrato na mesma operação
    // de criação do evento).
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

        ResultSet chaves = stmt.getGeneratedKeys();
        if (chaves.next()) {
            idGerado = chaves.getInt(1);
        }
        chaves.close();

        stmt.close();

        return idGerado;
    }

    // LISTAR EVENTOS
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
                rs.getObject("inicio_evento", java.time.LocalDateTime.class),
                rs.getObject("fim_evento", java.time.LocalDateTime.class),
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

    // BUSCAR EVENTO POR ID
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
                rs.getObject("inicio_evento", java.time.LocalDateTime.class),
                rs.getObject("fim_evento", java.time.LocalDateTime.class),
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

    // ATUALIZAR EVENTO
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

    // EXCLUIR EVENTO
    public void excluirEvento(int idEvento) throws Exception {

        String sql = "DELETE FROM evento WHERE id_evento = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, idEvento);

        stmt.executeUpdate();

        stmt.close();
    }

    // EXCLUIR EVENTO COM TUDO QUE DEPENDE DELE
    // Sem isso, excluir um evento que já tem inscrito/contrato/favorito
    // quebra por causa das chaves estrangeiras (ON DELETE NO ACTION).
    // Usado principalmente pelo admin, ao remover eventos inadequados.
    public void excluirEventoComDependencias(int idEvento) throws Exception {

        // notificações das inscrições desse evento
        PreparedStatement stmtNotif = conexao.prepareStatement(
            "DELETE n FROM notificacao n "
            + "INNER JOIN inscricao i ON n.id_inscricao = i.id_inscricao "
            + "WHERE i.id_evento = ?"
        );
        stmtNotif.setInt(1, idEvento);
        stmtNotif.executeUpdate();
        stmtNotif.close();

        // inscrições
        PreparedStatement stmtInsc = conexao.prepareStatement(
            "DELETE FROM inscricao WHERE id_evento = ?"
        );
        stmtInsc.setInt(1, idEvento);
        stmtInsc.executeUpdate();
        stmtInsc.close();

        // contratos
        PreparedStatement stmtContrato = conexao.prepareStatement(
            "DELETE FROM contrato WHERE id_evento = ?"
        );
        stmtContrato.setInt(1, idEvento);
        stmtContrato.executeUpdate();
        stmtContrato.close();

        // favoritos
        PreparedStatement stmtFav = conexao.prepareStatement(
            "DELETE FROM favorito WHERE id_evento = ?"
        );
        stmtFav.setInt(1, idEvento);
        stmtFav.executeUpdate();
        stmtFav.close();

        // por fim, o evento em si
        excluirEvento(idEvento);
    }
}