package br.com.gerencia.model;

import java.time.LocalDateTime;

public class favoritoModel {

    private int id_usuario;
    private int id_evento;
    private LocalDateTime data_favorito;

    // Construtor vazio
    public favoritoModel() {
    }

    // Construtor
    public favoritoModel(int id_usuario, int id_evento,
                         LocalDateTime data_favorito) {
        this.id_usuario = id_usuario;
        this.id_evento = id_evento;
        this.data_favorito = data_favorito;
    }

    // Getters e Setters

    public int getId_usuario() {
        return id_usuario;
    }

    public void setId_usuario(int id_usuario) {
        this.id_usuario = id_usuario;
    }

    public int getId_evento() {
        return id_evento;
    }

    public void setId_evento(int id_evento) {
        this.id_evento = id_evento;
    }

    public LocalDateTime getData_favorito() {
        return data_favorito;
    }

    public void setData_favorito(LocalDateTime data_favorito) {
        this.data_favorito = data_favorito;
    }
}