package br.com.gerencia.model;

import java.time.LocalDateTime;

public class notificacaoModel {

    private int id_notificacao;
    private String status_notificacao;
    private String mensagem;
    private LocalDateTime data_envio;
    private int id_inscricao;
    private int id_usuario;

    // =========================================================
    // CONSTRUTOR VAZIO
    // =========================================================

    public notificacaoModel() {
    }

    // =========================================================
    // CONSTRUTOR SEM ID
    // =========================================================

    public notificacaoModel(
            String status_notificacao,
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

    // =========================================================
    // CONSTRUTOR COMPLETO
    // =========================================================

    public notificacaoModel(
            int id_notificacao,
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

    // =========================================================
    // GET ID NOTIFICAÇÃO
    // =========================================================

    public int getId_notificacao() {
        return id_notificacao;
    }

    public void setId_notificacao(int id_notificacao) {
        this.id_notificacao = id_notificacao;
    }

    // =========================================================
    // GET STATUS
    // =========================================================

    public String getStatus_notificacao() {
        return status_notificacao;
    }

    public void setStatus_notificacao(
            String status_notificacao) {

        this.status_notificacao = status_notificacao;
    }

    // =========================================================
    // GET MENSAGEM
    // =========================================================
    // ESTE É O MÉTODO QUE ESTÁ DANDO ERRO NA LINHA 724
    // =========================================================

    public String getMensagem() {
        return mensagem;
    }

    public void setMensagem(String mensagem) {
        this.mensagem = mensagem;
    }

    // =========================================================
    // GET DATA
    // =========================================================

    public LocalDateTime getData_envio() {
        return data_envio;
    }

    public void setData_envio(
            LocalDateTime data_envio) {

        this.data_envio = data_envio;
    }

    // =========================================================
    // GET ID INSCRIÇÃO
    // =========================================================

    public int getId_inscricao() {
        return id_inscricao;
    }

    public void setId_inscricao(int id_inscricao) {
        this.id_inscricao = id_inscricao;
    }

    // =========================================================
    // GET ID USUÁRIO
    // =========================================================

    public int getId_usuario() {
        return id_usuario;
    }

    public void setId_usuario(int id_usuario) {
        this.id_usuario = id_usuario;
    }
}