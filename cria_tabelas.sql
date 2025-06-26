-- Sequências para os ID's
CREATE SEQUENCE seq_funcionario START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_campanha  START WITH 1 INCREMENT BY 1 NOCACHE;

-- Tabelas Independentes
CREATE TABLE CLIENTE(
    CPF                  VARCHAR2(11) NOT NULL,
    Nome                 VARCHAR2(100) NOT NULL,
    Endereco_Rua         VARCHAR2(150),
    Endereco_Numero      VARCHAR2(10),
    Endereco_Bairro      VARCHAR2(50),
    Endereco_Complemento VARCHAR2(50),
    Endereco_Cidade      VARCHAR2(50),
    Endereco_Estado      VARCHAR2(2),
    Endereco_Pais        VARCHAR2(30),
    CONSTRAINT pk_cliente PRIMARY KEY (CPF)
);

CREATE TABLE MEIO_DE_COMUNICACAO (
    Nome  VARCHAR2(100) NOT NULL,
    Tipo  VARCHAR2(50),
    CONSTRAINT pk_meio_comunicacao PRIMARY KEY (Nome)
);

CREATE TABLE FUNCIONARIO (
    IDFuncionario NUMBER NOT NULL,
    Nome          VARCHAR2(100) NOT NULL,
    Cargo         VARCHAR2(50),
    Departamento  VARCHAR2(50),
    ID_Supervisor NUMBER,
    CONSTRAINT pk_funcionario PRIMARY KEY (IDFuncionario),
    CONSTRAINT fk_supervisor FOREIGN KEY (ID_Supervisor)
        REFERENCES FUNCIONARIO(IDFuncionario)
);

-- Tabelas Dependentes
CREATE TABLE TELEFONE_CLIENTE (
    CPF_Cliente VARCHAR2(11) NOT NULL,
    Telefone    VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_telefone_cliente PRIMARY KEY (CPF_Cliente, Telefone),
    CONSTRAINT fk_telefone_cliente FOREIGN KEY (CPF_Cliente)
        REFERENCES CLIENTE(CPF)
);

CREATE TABLE CAMPANHA (
    IDCampanha      NUMBER NOT NULL,
    CPF_Pagador     VARCHAR2(11) NOT NULL,
    CPF_Solicitante VARCHAR2(11) NOT NULL,
    Nome            VARCHAR2(100),
    Orcamento       FLOAT,
    DataInicio      DATE,
    DataFim         DATE,
    CONSTRAINT pk_campanha PRIMARY KEY (IDCampanha),
    CONSTRAINT fk_campanha_pagador FOREIGN KEY (CPF_Pagador)
        REFERENCES CLIENTE(CPF),
    CONSTRAINT fk_campanha_solicitante FOREIGN KEY (CPF_Solicitante)
        REFERENCES CLIENTE(CPF),
    CONSTRAINT chk_datas_campanha CHECK (DataFim >= DataInicio)
);

CREATE TABLE GERENTE (
    IDFuncionario  NUMBER NOT NULL,
    BonusGerencial FLOAT,
    CONSTRAINT pk_gerente PRIMARY KEY (IDFuncionario),
    CONSTRAINT fk_gerente_funcionario FOREIGN KEY (IDFuncionario)
        REFERENCES FUNCIONARIO(IDFuncionario)
);

CREATE TABLE DIRETOR_CRIATIVO (
    IDFuncionario NUMBER NOT NULL,
    BonusDirecao  FLOAT,
    CONSTRAINT pk_diretor_criativo PRIMARY KEY (IDFuncionario),
    CONSTRAINT fk_diretor_criativo_func FOREIGN KEY (IDFuncionario)
        REFERENCES FUNCIONARIO(IDFuncionario)
);

CREATE TABLE ANUNCIO (
    IDCampanha NUMBER NOT NULL,
    Sequencia  NUMBER NOT NULL,
    Titulo     VARCHAR2(150),
    Duracao    VARCHAR2(20),
    CONSTRAINT pk_anuncio PRIMARY KEY (IDCampanha, Sequencia),
    CONSTRAINT fk_anuncio_campanha FOREIGN KEY (IDCampanha)
        REFERENCES CAMPANHA(IDCampanha)
);

-- Tabelas de Junção
CREATE TABLE ANUNCIA_EM (
    IDCampanha   NUMBER NOT NULL,
    Sequencia    NUMBER NOT NULL,
    Nome_Meio    VARCHAR2(100) NOT NULL,
    DataInsercao DATE,
    Frequencia   VARCHAR2(50),
    CONSTRAINT pk_anuncia_em PRIMARY KEY (IDCampanha, Sequencia, Nome_Meio),
    CONSTRAINT fk_anuncia_em_anuncio FOREIGN KEY (IDCampanha, Sequencia)
        REFERENCES ANUNCIO(IDCampanha, Sequencia),
    CONSTRAINT fk_anuncia_em_meio FOREIGN KEY (Nome_Meio)
        REFERENCES MEIO_DE_COMUNICACAO(Nome)
);

CREATE TABLE ALOCA (
    IDFuncionario NUMBER NOT NULL,
    IDCampanha    NUMBER NOT NULL,
    Sequencia     NUMBER NOT NULL,
    CONSTRAINT pk_aloca PRIMARY KEY (IDFuncionario, IDCampanha, Sequencia),
    CONSTRAINT fk_aloca_funcionario FOREIGN KEY (IDFuncionario)
        REFERENCES FUNCIONARIO(IDFuncionario),
    CONSTRAINT fk_aloca_anuncio FOREIGN KEY (IDCampanha, Sequencia)
        REFERENCES ANUNCIO(IDCampanha, Sequencia)
);