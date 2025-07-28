SET SERVEROUTPUT ON;

-- Usamos um bloco DECLARE para criar variáveis que irão armazenar as referências dos objetos
DECLARE
  -- Variáveis para armazenar referências a objetos específicos
  ref_cliente1 REF tp_cliente;
  ref_cliente2 REF tp_cliente;
  
  ref_func_gerente REF tp_funcionario;
  ref_func_designer REF tp_funcionario;
  ref_func_diretor REF tp_funcionario;

  ref_anuncio1 REF tp_anuncio;
  ref_anuncio2 REF tp_anuncio;

  ref_meio1 REF tp_meio_comunicacao;
  ref_meio2 REF tp_meio_comunicacao;

BEGIN

  -- Inserindo objetos nas tabelas que não dependem de outras
  
  -- Inserindo Clientes
  INSERT INTO tb_clientes VALUES (
    tp_cliente(
      '11122233344',
      'Padaria',
      tp_endereco('Rua da Padaria', '100', 'Pão Doce', 'Recife', 'PE'),
      tp_telefones_varray(tp_telefone('8133224455'))
    )
  );

  INSERT INTO tb_clientes VALUES (
    tp_cliente(
      '55566677788',
      'Academia',
      tp_endereco('Av. do Malhão', '200', 'Fitness', 'Jaboatão dos Guararapes', 'PE'),
      tp_telefones_varray(tp_telefone('81988776655'))
    )
  );

  -- Inserindo Funcionários
  INSERT INTO tb_funcionarios VALUES (
    tp_gerente(1, 'Mariana', 'Gerente de Projetos', 1500.00)
  );
  INSERT INTO tb_funcionarios VALUES (
    tp_funcionario(2, 'Pedro', 'Designer Pleno') -- Este é um executor, usamos o construtor base
  );
  INSERT INTO tb_funcionarios VALUES (
    tp_diretor_criativo(3, 'Lucas', 'Diretor de Criação', 2500.00)
  );
  
  -- Inserindo Meios de Comunicação
  INSERT INTO tb_meios_comunicacao VALUES (
    tp_meio_comunicacao('Rádio Jornal', 'Rádio')
  );
  INSERT INTO tb_meios_comunicacao VALUES (
    tp_meio_comunicacao('Facebook', 'Rede Social')
  );

  -- Capturando as Referências (REFs) dos objetos que acabamos de inserir

  SELECT REF(c) INTO ref_cliente1 FROM tb_clientes c WHERE c.CPF = '11122233344';
  
  SELECT REF(f) INTO ref_func_gerente FROM tb_funcionarios f WHERE f.IDFuncionario = 1;
  SELECT REF(f) INTO ref_func_designer FROM tb_funcionarios f WHERE f.IDFuncionario = 2;
  SELECT REF(f) INTO ref_func_diretor FROM tb_funcionarios f WHERE f.IDFuncionario = 3;
  
  SELECT REF(m) INTO ref_meio1 FROM tb_meios_comunicacao m WHERE m.Nome = 'Rádio Jornal';
  SELECT REF(m) INTO ref_meio2 FROM tb_meios_comunicacao m WHERE m.Nome = 'Facebook';

  -- Inserindo objetos que dependem de outros
  
  -- Inserindo Anúncios 
  INSERT INTO tb_anuncios VALUES (1, 1, 'Spot 30s para rádio', '00:00:30');
  INSERT INTO tb_anuncios VALUES (1, 2, 'Carrossel de fotos para FB', NULL);

  -- Capturando REFs dos anúncios
  SELECT REF(a) INTO ref_anuncio1 FROM tb_anuncios a WHERE a.IDCampanha = 1 AND a.Sequencia = 1;
  SELECT REF(a) INTO ref_anuncio2 FROM tb_anuncios a WHERE a.IDCampanha = 1 AND a.Sequencia = 2;

  -- Inserindo a Campanha
  INSERT INTO tb_campanhas VALUES (
    1,
    'Campanha da Padaria',
    5000.00,
    TO_DATE('2025-07-01','YYYY-MM-DD'),
    TO_DATE('2025-07-31','YYYY-MM-DD'),
    ref_cliente1, -- Usando a referência
    tp_anuncios_nt(ref_anuncio1, ref_anuncio2) -- Populando a NESTED TABLE com as referências
  );

  -- Populando as tabelas relacionais de junção com as REFs

  INSERT INTO tb_anuncia_em (Anuncio_ref, Meio_ref, DataInsercao, Frequencia)
  VALUES (ref_anuncio1, ref_meio1, TO_DATE('2025-07-05','YYYY-MM-DD'), '5 inserções/dia');
  
  INSERT INTO tb_anuncia_em (Anuncio_ref, Meio_ref, DataInsercao, Frequencia)
  VALUES (ref_anuncio2, ref_meio2, TO_DATE('2025-07-02','YYYY-MM-DD'), 'Contínua');

  INSERT INTO tb_aloca (Funcionario_ref, Anuncio_ref)
  VALUES (ref_func_designer, ref_anuncio2); -- Alocando o designer Pedro ao anúncio do Facebook

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Povoamento Objeto-Relacional concluído com sucesso!');

END;
/


--EXEMPLOS DE CONSULTA PARA VERIFICAR OS DADOS 

-- Consultando o nome do cliente e a rua do seu endereço (acessando atributo de objeto aninhado)
SELECT c.Nome, c.Endereco.Rua FROM tb_clientes c;

-- Consultando o nome da campanha e o nome do cliente pagador (usando DEREF para seguir a referência)
SELECT
    c.Nome AS Nome_Campanha,
    DEREF(c.ClientePagador).Nome AS Nome_Cliente
FROM tb_campanhas c;

-- Consultando os títulos dos anúncios dentro da NESTED TABLE de uma campanha específica
SELECT a.Titulo
FROM tb_campanhas camp, TABLE(camp.Anuncios) an_ref
JOIN tb_anuncios a ON REF(a) = VALUE(an_ref)
WHERE camp.IDCampanha = 1;