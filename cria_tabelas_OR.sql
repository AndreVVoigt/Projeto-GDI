-- Tipo para representar um endereço.
CREATE OR REPLACE TYPE tp_endereco AS OBJECT (
    Rua        VARCHAR2(150),
    Numero     VARCHAR2(10),
    Bairro     VARCHAR2(50),
    Cidade     VARCHAR2(50),
    Estado     VARCHAR2(2)
);
/

-- Tipo simples para representar um telefone.
CREATE OR REPLACE TYPE tp_telefone AS OBJECT (
    Numero     VARCHAR2(20)
);
/

-- VARRAY: Coleção de telefones.
CREATE OR REPLACE TYPE tp_telefones_varray AS VARRAY(5) OF tp_telefone;
/

-- Tipo para um anúncio individual.
CREATE OR REPLACE TYPE tp_anuncio AS OBJECT (
    IDCampanha NUMBER,
    Sequencia  NUMBER,
    Titulo     VARCHAR2(150),
    Duracao    VARCHAR2(20)
);
/

-- NESTED TABLE: Tipo para armazenar uma coleção de referências a anúncios.
CREATE OR REPLACE TYPE tp_anuncios_nt AS TABLE OF REF tp_anuncio;
/



-- 1. CREATE OR REPLACE TYPE: Definição do tipo de funcionário.
CREATE OR REPLACE TYPE tp_funcionario AS OBJECT (
    IDFuncionario NUMBER,
    Nome          VARCHAR2(100),
    Cargo         VARCHAR2(50),

    -- MEMBER FUNCTION
    MEMBER FUNCTION get_info RETURN VARCHAR2,
    
    -- ORDER MEMBER FUNCTION: Para comparar funcionários.
    ORDER MEMBER FUNCTION comparar (p_outro_func IN tp_funcionario) RETURN INTEGER

) NOT INSTANTIABLE NOT FINAL;
/

-- 2. CREATE OR REPLACE TYPE BODY: Implementação dos métodos de tp_funcionario.
CREATE OR REPLACE TYPE BODY tp_funcionario AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'ID: ' || SELF.IDFuncionario || ', Nome: ' || SELF.Nome || ', Cargo: ' || SELF.Cargo;
    END;

    ORDER MEMBER FUNCTION comparar (p_outro_func IN tp_funcionario) RETURN INTEGER IS
    BEGIN
        IF SELF.IDFuncionario < p_outro_func.IDFuncionario THEN
            RETURN -1; 
        ELSIF SELF.IDFuncionario > p_outro_func.IDFuncionario THEN
            RETURN 1;  
        ELSE
            RETURN 0;  
        END IF;
    END;
END;
/

-- Tipo GERENTE herda de FUNCIONARIO
CREATE OR REPLACE TYPE tp_gerente UNDER tp_funcionario (
    BonusGerencial      FLOAT,
    
    -- 8. OVERRIDING MEMBER: Sobrescrevendo a função get_info
    OVERRIDING MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY tp_gerente AS
    OVERRIDING MEMBER FUNCTION get_info RETURN VARCHAR2 IS
        info_base VARCHAR2(200);
    BEGIN
        -- Chama a função da superclasse e adiciona novas informações
        info_base := (SELF AS tp_funcionario).get_info();
        RETURN info_base || ', Bônus: ' || SELF.BonusGerencial;
    END;
END;
/

-- Tipo DIRETOR_CRIATIVO herda de FUNCIONARIO
CREATE OR REPLACE TYPE tp_diretor_criativo UNDER tp_funcionario (
    BonusDirecao        FLOAT,
    
    OVERRIDING MEMBER FUNCTION get_info RETURN VARCHAR2,
    
    -- 9. FINAL MEMBER: Esta procedure não poderá ser sobrescrita por futuros subtipos.
    FINAL MEMBER PROCEDURE conceder_ferias
);
/

CREATE OR REPLACE TYPE BODY tp_diretor_criativo AS
    OVERRIDING MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN (SELF AS tp_funcionario).get_info() || ', Bônus de Direção: ' || SELF.BonusDirecao;
    END;
END;
/



-- CREATE OR REPLACE TYPE
CREATE OR REPLACE TYPE tp_cliente AS OBJECT (
    CPF        VARCHAR2(11),
    Nome       VARCHAR2(100),
    Endereco   tp_endereco,       
    Telefones  tp_telefones_varray, 
    
    -- MEMBER PROCEDURE
    MEMBER PROCEDURE exibir_endereco
);
/

CREATE OR REPLACE TYPE BODY tp_cliente AS
    MEMBER PROCEDURE exibir_endereco IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Endereço de ' || SELF.Nome || ':');
        DBMS_OUTPUT.PUT_LINE(SELF.Endereco.Rua || ', ' || SELF.Endereco.Numero || ' - ' || SELF.Endereco.Bairro);
    END;
END;
/

CREATE OR REPLACE TYPE tp_campanha AS OBJECT (
    IDCampanha      NUMBER,
    Nome            VARCHAR2(100),
    Orcamento       FLOAT,
    DataInicio      DATE,
    DataFim         DATE,
    -- REF: Referência a um objeto cliente
    ClientePagador  REF tp_cliente,
    Anuncios        tp_anuncios_nt,
    
    -- CONSTRUCTOR FUNCTION
    CONSTRUCTOR FUNCTION tp_campanha(Nome VARCHAR2, Orcamento FLOAT) RETURN SELF AS RESULT
);
/

CREATE OR REPLACE TYPE BODY tp_campanha AS
    CONSTRUCTOR FUNCTION tp_campanha(Nome VARCHAR2, Orcamento FLOAT) RETURN SELF AS RESULT IS
    BEGIN
        SELF.IDCampanha := 0;
        SELF.Nome := Nome;
        SELF.Orcamento := Orcamento;
        SELF.DataInicio := SYSDATE;
        SELF.DataFim := SYSDATE + 30;
        SELF.Anuncios := tp_anuncios_nt(); -- Inicializa a nested table vazia
        RETURN;
    END;
END;
/


-- Criação do tipo tp_meio_comunicacao
CREATE OR REPLACE TYPE tp_meio_comunicacao AS OBJECT (
    Nome  VARCHAR2(100),
    Tipo  VARCHAR2(50)
);
/

-- Tabela relacional para AnunciaEm
CREATE TABLE tb_anuncia_em (
    -- Armazena uma referência ao objeto Anúncio
    Anuncio_ref REF tp_anuncio SCOPE IS tb_anuncios,
    
    -- Armazena uma referência ao objeto MeioDeComunicacao
    Meio_ref    REF tp_meio_comunicacao SCOPE IS tb_meios_comunicacao,
    
    -- Atributos do próprio relacionamento
    DataInsercao DATE,
    Frequencia   VARCHAR2(50),
    
    CONSTRAINT pk_anuncia_em_or PRIMARY KEY (Anuncio_ref, Meio_ref)
);
/

-- Tabela relacional para Aloca
CREATE TABLE tb_aloca (
    -- Armazena uma referência ao objeto Funcionário
    Funcionario_ref REF tp_funcionario SCOPE IS tb_funcionarios,
    
    -- Armazena uma referência ao objeto Anúncio
    Anuncio_ref     REF tp_anuncio SCOPE IS tb_anuncios,
    
    CONSTRAINT pk_aloca_or PRIMARY KEY (Funcionario_ref, Anuncio_ref)
);
/



-- 13. CREATE TABLE OF
CREATE TABLE tb_clientes OF tp_cliente (
    CPF PRIMARY KEY
);
/

CREATE TABLE tb_funcionarios OF tp_funcionario;
/

CREATE TABLE tb_anuncios OF tp_anuncio (
    PRIMARY KEY (IDCampanha, Sequencia)
);
/

CREATE TABLE tb_meios_comunicacao OF tp_meio_comunicacao (
    Nome PRIMARY KEY
);
/

CREATE TABLE tb_campanhas OF tp_campanha (
    IDCampanha PRIMARY KEY,
    -- 16. SCOPE IS: Garante que a referência a cliente aponte apenas para a tabela tb_clientes
    SCOPE FOR (ClientePagador) IS tb_clientes
)

NESTED TABLE Anuncios STORE AS nt_anuncios;
/

