SET SERVEROUTPUT ON;


-- 1. CONSULTA COM SELECT REF
-- Consulta: Selecionar a referência para todos os funcionários que são do tipo 'tp_gerente'.
SELECT REF(f) AS Ref_Gerente
FROM tb_funcionarios f
WHERE VALUE(f) IS OF (tp_gerente);


-- 2. CONSULTA COM SELECT DEREF
-- Consulta: Listar o nome de cada campanha e o nome do cliente pagador, acessando os dados do cliente através da referência.
SELECT
    c.Nome AS Nome_Campanha,
    DEREF(c.ClientePagador).Nome AS Nome_Cliente
FROM tb_campanhas c;


-- 3. CONSULTA À VARRAY
-- Consulta: Listar o nome de cada cliente e todos os seus números de telefone.
-- A função TABLE() transforma a coleção em um formato que o FROM consegue ler.
SELECT
    c.Nome AS Nome_Cliente,
    t.Numero AS Telefone
FROM
    tb_clientes c,
    TABLE(c.Telefones) t;


-- 4. CONSULTA À NESTED TABLE
-- Consulta: Listar todos os anúncios (título e duração) da campanha de ID = 1.
SELECT
    DEREF(VALUE(a)).Titulo AS Titulo_Anuncio,
    DEREF(VALUE(a)).Duracao AS Duracao
FROM
    tb_campanhas c,
    TABLE(c.Anuncios) a
WHERE c.IDCampanha = 1;


-- 5. TESTE DA FUNÇÃO: get_info() dos objetos funcionário
-- Consulta: Executar a função get_info() para cada tipo de funcionário.
-- A saída será diferente para Gerente e Diretor Criativo.
SELECT f.Nome, f.get_info() AS Detalhes FROM tb_funcionarios f;


-- 6. TESTE DO PROCEDIMENTO: exibir_endereco() do objeto cliente
-- Objetivo: Executar um MEMBER PROCEDURE de um objeto.
DECLARE
  v_cliente tp_cliente;
BEGIN
  -- Seleciona um objeto cliente inteiro para uma variável
  SELECT VALUE(c) INTO v_cliente FROM tb_clientes c WHERE c.CPF = '11122233344';
  
  -- Chama o procedimento do objeto
  v_cliente.exibir_endereco();
END;
/


-- 7. TESTE DA FUNÇÃO DE PACOTE: pkg_relatorios.get_anuncios_por_campanha
-- Objetivo: Chamar uma função de um pacote que retorna uma coleção.
SELECT * FROM TABLE(pkg_relatorios.get_anuncios_por_campanha(1));


-- 8. TESTE DO PROCEDIMENTO DE PACOTE: pkg_relatorios.get_cliente_campanha
-- Objetivo: Chamar um procedimento com parâmetro de saída (OUT).
DECLARE
    v_nome_cliente_saida VARCHAR2(100);
BEGIN
    pkg_relatorios.get_cliente_campanha(
        p_id_campanha => 1,
        p_nome_cliente => v_nome_cliente_saida -- Variável que receberá o resultado
    );
    DBMS_OUTPUT.PUT_LINE('Cliente da campanha 1 (obtido via procedure): ' || v_nome_cliente_saida);
END;
/


-- 9. TESTE DO TRIGGER: trg_valida_alocacao
-- Objetivo: Provar que o trigger de linha está funcionando.
BEGIN
    INSERT INTO tb_aloca (Funcionario_ref, Anuncio_ref)
    SELECT REF(f), REF(a)
    FROM tb_funcionarios f, tb_anuncios a
    WHERE f.IDFuncionario = 1 AND a.IDCampanha = 1 AND a.Sequencia = 1;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('TESTE BEM-SUCEDIDO: O trigger barrou corretamente a inserção. Erro: ' || SQLERRM);
END;
/


-- 10. CONSULTA COM MÉTODO DE OBJETO NA CLÁUSULA WHERE
-- Consulta: Encontrar todos os funcionários cujo cargo é 'Gerente de Projetos'.
SELECT f.Nome
FROM tb_funcionarios f
WHERE f.get_info() LIKE '%Gerente de Projetos%';


-- 11. CONSULTA UTILIZANDO UMA FUNÇÃO DE ORDENAÇÃO (ORDER MEMBER FUNCTION)
-- Consulta: Listar todos os funcionários ordenados pelo seu ID, usando a função "comparar" que definimos.
SELECT f.Nome, f.IDFuncionario
FROM tb_funcionarios f
ORDER BY VALUE(f); -- O Oracle chama a função ORDER MEMBER automaticamente.


-- 12. CONSULTA HÍBRIDA (TABELA RELACIONAL COM REFs)
-- Consulta: Mostrar o nome do funcionário e o título do anúncio em que ele está alocado.
SELECT
    DEREF(a.Funcionario_ref).Nome AS Nome_Funcionario,
    DEREF(a.Anuncio_ref).Titulo AS Titulo_Anuncio
FROM tb_aloca a;