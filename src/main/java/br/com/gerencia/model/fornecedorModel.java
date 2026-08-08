package br.com.gerencia.model;

public class fornecedorModel {

    private int id_fornecedor;
    private String nome_fornecedor;
    private String CNPJ_fornecedor;
    private String telefone_fornecedor;
    private String categoria_fornecedor;
    private String email;

    // Construtor vazio
    public fornecedorModel() {
    }

    // Construtor sem ID
    public fornecedorModel(String nome_fornecedor, String CNPJ_fornecedor,
                           String telefone_fornecedor, String categoria_fornecedor,
                           String email) {
        this.nome_fornecedor = nome_fornecedor;
        this.CNPJ_fornecedor = CNPJ_fornecedor;
        this.telefone_fornecedor = telefone_fornecedor;
        this.categoria_fornecedor = categoria_fornecedor;
        this.email = email;
    }

    // Construtor completo
    public fornecedorModel(int id_fornecedor, String nome_fornecedor,
                           String CNPJ_fornecedor, String telefone_fornecedor,
                           String categoria_fornecedor, String email) {
        this.id_fornecedor = id_fornecedor;
        this.nome_fornecedor = nome_fornecedor;
        this.CNPJ_fornecedor = CNPJ_fornecedor;
        this.telefone_fornecedor = telefone_fornecedor;
        this.categoria_fornecedor = categoria_fornecedor;
        this.email = email;
    }

    // Getters e Setters

    public int getId_fornecedor() {
        return id_fornecedor;
    }

    public void setId_fornecedor(int id_fornecedor) {
        this.id_fornecedor = id_fornecedor;
    }

    public String getNome_fornecedor() {
        return nome_fornecedor;
    }

    public void setNome_fornecedor(String nome_fornecedor) {
        this.nome_fornecedor = nome_fornecedor;
    }

    public String getCNPJ_fornecedor() {
        return CNPJ_fornecedor;
    }

    public void setCNPJ_fornecedor(String CNPJ_fornecedor) {
        this.CNPJ_fornecedor = CNPJ_fornecedor;
    }

    public String getTelefone_fornecedor() {
        return telefone_fornecedor;
    }

    public void setTelefone_fornecedor(String telefone_fornecedor) {
        this.telefone_fornecedor = telefone_fornecedor;
    }

    public String getCategoria_fornecedor() {
        return categoria_fornecedor;
    }

    public void setCategoria_fornecedor(String categoria_fornecedor) {
        this.categoria_fornecedor = categoria_fornecedor;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}