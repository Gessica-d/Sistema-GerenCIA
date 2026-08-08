package br.com.gerencia.model;

import java.time.LocalDateTime;

public class inscricaoModel {

    private int id_inscricao;
    private int id_evento;
    private int id_usuario;
    private LocalDateTime data_inscricao;
    private String status_inscricao;
    private String metodo_inscricao;
    private boolean checkin;
    private int posicao_fila;

    // Construtor vazio
    public inscricaoModel() {
    }

    // Construtor sem ID
    public inscricaoModel(int id_evento, int id_usuario,
                          LocalDateTime data_inscricao,
                          String status_inscricao,
                          String metodo_inscricao,
                          boolean checkin,
                          int posicao_fila) {

        this.id_evento = id_evento;
        this.id_usuario = id_usuario;
        this.data_inscricao = data_inscricao;
        this.status_inscricao = status_inscricao;
        this.metodo_inscricao = metodo_inscricao;
        this.checkin = checkin;
        this.posicao_fila = posicao_fila;
    }

    // Construtor completo
    public inscricaoModel(int id_inscricao, int id_evento,
                          int id_usuario, LocalDateTime data_inscricao,
                          String status_inscricao,
                          String metodo_inscricao,
                          boolean checkin_inscricao,
                          int posicaoFila_inscricao) {

        this.id_inscricao = id_inscricao;
        this.id_evento = id_evento;
        this.id_usuario = id_usuario;
        this.data_inscricao = data_inscricao;
        this.status_inscricao = status_inscricao;
        this.metodo_inscricao = metodo_inscricao;
        this.checkin = checkin;
        this.posicao_fila = posicao_fila;
    }

    // Getters e Setters

    public int getId_inscricao() {
        return id_inscricao;
    }

    public void setId_inscricao(int id_inscricao) {
        this.id_inscricao = id_inscricao;
    }

    public int getId_evento() {
        return id_evento;
    }

    public void setId_evento(int id_evento) {
        this.id_evento = id_evento;
    }

    public int getId_usuario() {
        return id_usuario;
    }

    public void setId_usuario(int id_usuario) {
        this.id_usuario = id_usuario;
    }

    public LocalDateTime getData_inscricao() {
        return data_inscricao;
    }

    public void setData_inscricao(LocalDateTime data_inscricao) {
        this.data_inscricao = data_inscricao;
    }

    public String getStatus_inscricao() {
        return status_inscricao;
    }

    public void setStatus_inscricao(String status_inscricao) {
        this.status_inscricao = status_inscricao;
    }

    public String getMetodo_inscricao() {
        return metodo_inscricao;
    }

    public void setMetodo_inscricao(String metodo_inscricao) {
        this.metodo_inscricao = metodo_inscricao;
    }

    public boolean isCheckin() {
        return checkin;
    }

    public void setCheckin(boolean checkin) {
        this.checkin = checkin;
    }

    public int getPosicao_fila() {
        return posicao_fila;
    }

    public void setPosicao_fila(int posicao_fila) {
        this.posicao_fila = posicao_fila;
    }
}