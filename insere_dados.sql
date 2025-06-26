-- 1. Inserindo Clientes
INSERT INTO CLIENTE (CPF, Nome, Endereco_Cidade, Endereco_Estado)
VALUES ('11122233344', 'Padaria',     'Recife',                'PE');
INSERT INTO CLIENTE (CPF, Nome, Endereco_Cidade, Endereco_Estado)
VALUES ('55566677788', 'Academia',    'Jaboatão dos Guararapes','PE');
INSERT INTO CLIENTE (CPF, Nome, Endereco_Cidade, Endereco_Estado)
VALUES ('99988877766', 'Consultoria', 'Recife',                'PE');

-- 2. Inserindo Telefones
INSERT INTO TELEFONE_CLIENTE (CPF_Cliente, Telefone)
VALUES ('11122233344', '8133224455');
INSERT INTO TELEFONE_CLIENTE (CPF_Cliente, Telefone)
VALUES ('55566677788', '81988776655');

-- 3. Inserindo Funcionários
INSERT INTO FUNCIONARIO (IDFuncionario, Nome, Cargo, Departamento, ID_Supervisor)
VALUES (seq_funcionario.NEXTVAL, 'Mariana', 'Gerente de Projetos', 'Projetos', NULL);
INSERT INTO FUNCIONARIO (IDFuncionario, Nome, Cargo, Departamento, ID_Supervisor)
VALUES (seq_funcionario.NEXTVAL, 'Pedro',   'Designer Pleno',      'Criação',  1);
INSERT INTO FUNCIONARIO (IDFuncionario, Nome, Cargo, Departamento, ID_Supervisor)
VALUES (seq_funcionario.NEXTVAL, 'Lucas',   'Diretor de Criação',  'Criação',  1);

-- 4. Inserindo nas tabelas de especialização
INSERT INTO GERENTE      (IDFuncionario, BonusGerencial)
VALUES (1, 3500.00);
INSERT INTO DIRETOR_CRIATIVO (IDFuncionario, BonusDirecao)
VALUES (3, 2500.00);

-- 5. Inserindo Meios de Comunicação
INSERT INTO MEIO_DE_COMUNICACAO (Nome, Tipo)
VALUES ('Rádio Jornal', 'Rádio');
INSERT INTO MEIO_DE_COMUNICACAO (Nome, Tipo)
VALUES ('Facebook',     'Rede Social');

-- 6. Inserindo Campanhas
INSERT INTO CAMPANHA
  (IDCampanha, CPF_Pagador, CPF_Solicitante, Nome, Orcamento, DataInicio, DataFim)
VALUES
  (seq_campanha.NEXTVAL,
   '11122233344', '11122233344', 'Campanha da Padaria', 5000.00,
   TO_DATE('2025-07-01','YYYY-MM-DD'), TO_DATE('2025-07-31','YYYY-MM-DD'));

-- 7. Inserindo Anúncios
INSERT INTO ANUNCIO (IDCampanha, Sequencia, Titulo, Duracao)
VALUES (1, 1, 'Spot 30s para rádio',        '00:00:30');
INSERT INTO ANUNCIO (IDCampanha, Sequencia, Titulo, Duracao)
VALUES (1, 2, 'Carrossel de fotos para FB', NULL);

-- 8. Populando tabelas de junção
INSERT INTO ANUNCIA_EM
  (IDCampanha, Sequencia, Nome_Meio, DataInsercao, Frequencia)
VALUES
  (1, 1, 'Rádio Jornal', TO_DATE('2025-07-05','YYYY-MM-DD'), '5 inserções/dia');
INSERT INTO ANUNCIA_EM
  (IDCampanha, Sequencia, Nome_Meio, DataInsercao, Frequencia)
VALUES
  (1, 2, 'Facebook',     TO_DATE('2025-07-02','YYYY-MM-DD'), 'Contínua');

-- 9. Populando ALOCA
INSERT INTO ALOCA (IDFuncionario, IDCampanha, Sequencia)
VALUES (2, 1, 2);