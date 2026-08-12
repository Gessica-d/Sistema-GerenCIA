package br.com.gerencia.model;

import java.time.LocalDateTime;

public class notificacaoModel {

    private int id_notificacao;
    private String status_notificacao;
    private String mensagem;
    private LocalDateTime data_envio;
    private int id_inscricao;
    private int id_usuario;

    // Construtor vazio
    public notificacaoModel() {
    }

    // Construtor sem ID
    public notificacaoModel(String status_notificacao,
                            String mensagem,
                            LocalDateTime data_envio,
                            int id_inscricao,
                            int id_usuario) {
        this.status_notificacao = status_notificacao;
        this.mensagem = mensagem;
        this.data_envio = data_envio;
        this.id_inscricao = id_inscricao;
        this.id_usuario = id_usuario;
    }

    // Construtor completo
    public notificacaoModel(int id_notificacao,
                            String status_notificacao,
                            String mensagem,
                            LocalDateTime data_envio,
                            int id_inscricao,
                            int id_usuario) {
        this.id_notificacao = id_notificacao;
        this.status_notificacao = status_notificacao;
        this.mensagem = mensagem;
        this.data_envio = data_envio;
        this.id_inscricao = id_inscricao;
        this.id_usuario = id_usuario;
    }

    // Getters e Setters

    public int getId_notificacao() {
        return id_notificacao;
    }

    public void setId_notificacao(int id_notificacao) {
        this.id_notificacao = id_notificacao;
    }

    public String getStatus_notificacao() {
        return status_notificacao;
    }

    public void setStatus_notificacao(String status_notificacao) {
        this.status_notificacao = status_notificacao;
    }

    public String getMensagem() {
        return mensagem;
    }

    public void setMensagem(String mensagem) {
        this.mensagem = mensagem;
    }

    public LocalDateTime getData_envio() {
        return data_envio;
    }

    public void setData_envio(LocalDateTime data_envio) {
        this.data_envio = data_envio;
    }

    public int getId_inscricao() {
        return id_inscricao;
    }

    public void setId_inscricao(int id_inscricao) {
        this.id_inscricao = id_inscricao;
    }

    public int getId_usuario() {
        return id_usuario;
    }

    public void setId_usuario(int id_usuario) {
        this.id_usuario = id_usuario;
    }
}
