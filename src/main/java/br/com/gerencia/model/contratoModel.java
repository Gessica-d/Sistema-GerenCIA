package br.com.gerencia.model;

import java.time.LocalDateTime;

public class contratoModel {

    private int id_contrato;
    private int id_fornecedor;
    private int id_evento;
    private LocalDateTime data_contrato;
    private double valor_pago;
    private double valor_total;
    private String responsavel_contrato;
    private String contato_responsavel;
    private String objeto_contrato;
    private String anexo_contrato;

    // Construtor vazio
    public contratoModel() {
    }

    // Construtor sem ID
    public contratoModel(int id_fornecedor, int id_evento,
                         LocalDateTime data_contrato,
                         double valor_pago, double valor_total,
                         String responsavel_contrato,
                         String contato_responsavel,
                         String objeto_contrato,
                         String anexo_contrato) {

        this.id_fornecedor = id_fornecedor;
        this.id_evento = id_evento;
        this.data_contrato = data_contrato;
        this.valor_pago = valor_pago;
        this.valor_total = valor_total;
        this.responsavel_contrato = responsavel_contrato;
        this.contato_responsavel = contato_responsavel;
        this.objeto_contrato = objeto_contrato;
        this.anexo_contrato = anexo_contrato;
    }

    // Construtor completo
    public contratoModel(int id_contrato, int id_fornecedor,
                         int id_evento, LocalDateTime data_contrato,
                         double valor_pago, double valor_total,
                         String responsavel_contrato,
                         String contato_responsavel,
                         String objeto_contrato,
                         String anexo_contrato) {

        this.id_contrato = id_contrato;
        this.id_fornecedor = id_fornecedor;
        this.id_evento = id_evento;
        this.data_contrato = data_contrato;
        this.valor_pago = valor_pago;
        this.valor_total = valor_total;
        this.responsavel_contrato = responsavel_contrato;
        this.contato_responsavel = contato_responsavel;
        this.objeto_contrato = objeto_contrato;
        this.anexo_contrato = anexo_contrato;
    }

    // Getters e Setters

    public int getId_contrato() {
        return id_contrato;
    }

    public void setId_contrato(int id_contrato) {
        this.id_contrato = id_contrato;
    }

    public int getId_fornecedor() {
        return id_fornecedor;
    }

    public void setId_fornecedor(int id_fornecedor) {
        this.id_fornecedor = id_fornecedor;
    }

    public int getId_evento() {
        return id_evento;
    }

    public void setId_evento(int id_evento) {
        this.id_evento = id_evento;
    }

    public LocalDateTime getData_contrato() {
        return data_contrato;
    }

    public void setData_contrato(LocalDateTime data_contrato) {
        this.data_contrato = data_contrato;
    }

    public double getValor_pago() {
        return valor_pago;
    }

    public void setValor_pago(double valor_pago) {
        this.valor_pago = valor_pago;
    }

    public double getValor_total() {
        return valor_total;
    }

    public void setValor_total(double valor_total) {
        this.valor_total = valor_total;
    }

    public String getResponsavel_contrato() {
        return responsavel_contrato;
    }

    public void setResponsavel_contrato(String responsavel_contrato) {
        this.responsavel_contrato = responsavel_contrato;
    }

    public String getContato_responsavel() {
        return contato_responsavel;
    }

    public void setContato_responsavel(String contato_responsavel) {
        this.contato_responsavel = contato_responsavel;
    }

    public String getObjeto_contrato() {
        return objeto_contrato;
    }

    public void setObjeto_contrato(String objeto_contrato) {
        this.objeto_contrato = objeto_contrato;
    }

    public String getAnexo_contrato() {
        return anexo_contrato;
    }

    public void setAnexo_contrato(String anexo_contrato) {
        this.anexo_contrato = anexo_contrato;
    }
}