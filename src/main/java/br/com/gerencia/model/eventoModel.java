package br.com.gerencia.model;

import java.time.LocalDateTime;

// representa uma linha da tabela evento
public class eventoModel {

    private int id_evento;
    private String nome_evento;
    private String tipo_evento;
    private LocalDateTime inicio_evento;
    private LocalDateTime fim_evento;
    private String local_evento;
    private int capacidade_evento;
    private String codigo_evento;
    private String descricao_evento;
    private String status_evento;
    private String categoria_evento;
    private int id_organizador;

    // Construtor vazio
    public eventoModel() {
    }

    // Construtor sem ID
    public eventoModel(String nome_evento, String tipo_evento,
                       LocalDateTime inicio_evento, LocalDateTime fim_evento,
                       String local_evento, int capacidade_evento,
                       String codigo_evento, String descricao_evento,
                       String status_evento, String categoria_evento,
                       int id_organizador) {

        this.nome_evento = nome_evento;
        this.tipo_evento = tipo_evento;
        this.inicio_evento = inicio_evento;
        this.fim_evento = fim_evento;
        this.local_evento = local_evento;
        this.capacidade_evento = capacidade_evento;
        this.codigo_evento = codigo_evento;
        this.descricao_evento = descricao_evento;
        this.status_evento = status_evento;
        this.categoria_evento = categoria_evento;
        this.id_organizador = id_organizador;
    }

    // Construtor completo
    public eventoModel(int id_evento, String nome_evento,
                       String tipo_evento, LocalDateTime inicio_evento,
                       LocalDateTime fim_evento, String local_evento,
                       int capacidade_evento, String codigo_evento,
                       String descricao_evento, String status_evento,
                       String categoria_evento, int id_organizador) {

        this.id_evento = id_evento;
        this.nome_evento = nome_evento;
        this.tipo_evento = tipo_evento;
        this.inicio_evento = inicio_evento;
        this.fim_evento = fim_evento;
        this.local_evento = local_evento;
        this.capacidade_evento = capacidade_evento;
        this.codigo_evento = codigo_evento;
        this.descricao_evento = descricao_evento;
        this.status_evento = status_evento;
        this.categoria_evento = categoria_evento;
        this.id_organizador = id_organizador;
    }

    // Getters e Setters

    public int getId_evento() {
        return id_evento;
    }

    public void setId_evento(int id_evento) {
        this.id_evento = id_evento;
    }

    public String getNome_evento() {
        return nome_evento;
    }

    public void setNome_evento(String nome_evento) {
        this.nome_evento = nome_evento;
    }

    public String getTipo_evento() {
        return tipo_evento;
    }

    public void setTipo_evento(String tipo_evento) {
        this.tipo_evento = tipo_evento;
    }

    public LocalDateTime getInicio_evento() {
        return inicio_evento;
    }

    public void setInicio_evento(LocalDateTime inicio_evento) {
        this.inicio_evento = inicio_evento;
    }

    public LocalDateTime getFim_evento() {
        return fim_evento;
    }

    public void setFim_evento(LocalDateTime fim_evento) {
        this.fim_evento = fim_evento;
    }

    public String getLocal_evento() {
        return local_evento;
    }

    public void setLocal_evento(String local_evento) {
        this.local_evento = local_evento;
    }

    public int getCapacidade_evento() {
        return capacidade_evento;
    }

    public void setCapacidade_evento(int capacidade_evento) {
        this.capacidade_evento = capacidade_evento;
    }

    public String getCodigo_evento() {
        return codigo_evento;
    }

    public void setCodigo_evento(String codigo_evento) {
        this.codigo_evento = codigo_evento;
    }

    public String getDescricao_evento() {
        return descricao_evento;
    }

    public void setDescricao_evento(String descricao_evento) {
        this.descricao_evento = descricao_evento;
    }

    public String getStatus_evento() {
        return status_evento;
    }

    public void setStatus_evento(String status_evento) {
        this.status_evento = status_evento;
    }

    public String getCategoria_evento() {
        return categoria_evento;
    }

    public void setCategoria_evento(String categoria_evento) {
        this.categoria_evento = categoria_evento;
    }

    public int getId_organizador() {
        return id_organizador;
    }

    public void setId_organizador(int id_organizador) {
        this.id_organizador = id_organizador;
    }
}