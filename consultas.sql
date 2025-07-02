-- ALTER TABLE
-- Adicionando coluna de status na tabela CLIENTE
ALTER TABLE CLIENTE ADD Status VARCHAR2(20) DEFAULT 'ATIVO';

--CREATE INDEX
-- Criando índice para melhorar consultas pelo nome de cliente
CREATE INDEX idx_cliente_nome ON CLIENTE(Nome);

--INSERT INTO
-- Cadastrando novo cliente
INSERT INTO CLIENTE (CPF, Nome, Endereco_Cidade, Endereco_Estado)
VALUES ('33344455566', 'Restaurante Recife', 'Recife', 'PE');

--UPDATE
-- Atualizando orçamento de campanha
UPDATE CAMPANHA SET Orcamento = 5500.00 WHERE IDCampanha = 1;

--DELETE
-- Deletando telefone de cliente
DELETE FROM TELEFONE_CLIENTE WHERE CPF_Cliente = '55566677788' AND Telefone = '81988776655';

--SELECT-FROM-WHERE
-- Selecionando campanhas com orçamento acima de R$100.000,00
SELECT Nome, Orcamento FROM CAMPANHA WHERE Orcamento > 100000;

--BETWEEN
-- Campanhas entre julho e dezembro de 2023
SELECT Nome, DataInicio, DataFim FROM CAMPANHA 
WHERE DataInicio BETWEEN TO_DATE('01/07/2023', 'DD/MM/YYYY') AND TO_DATE('31/12/2023', 'DD/MM/YYYY');

--IN
-- Clientes de Recife ou Olinda
SELECT Nome, Endereco_Cidade FROM CLIENTE 
WHERE Endereco_Cidade IN ('Recife', 'Olinda');

--LIKE
-- Funcionários com nome começando com 'M'
SELECT Nome, Cargo FROM FUNCIONARIO WHERE Nome LIKE 'M%';

--IS NULL ou IS NOT NULL
-- Funcionários sem supervisor
SELECT Nome, Cargo FROM FUNCIONARIO WHERE ID_Supervisor IS NULL;

-- INNER JOIN
-- Ads com seus meios de comunicação
SELECT a.Titulo, m.Nome AS Meio_Comunicacao
FROM ANUNCIO a
INNER JOIN ANUNCIA_EM ae ON a.IDCampanha = ae.IDCampanha AND a.Sequencia = ae.Sequencia
INNER JOIN MEIO_DE_COMUNICACAO m ON ae.Nome_Meio = m.Nome;

--MAX
-- Maior orçamento de campanha
SELECT MAX(Orcamento) AS Maior_Orcamento FROM CAMPANHA;

--MIN
-- Menor bônus gerencial
SELECT MIN(BonusGerencial) AS Menor_Bonus FROM GERENTE;

-- AVG
-- Média de orçamento das campanhas
SELECT AVG(Orcamento) AS Media_Orcamento FROM CAMPANHA;

--COUNT
-- Quantidade de anúncios por campanha
SELECT IDCampanha, COUNT(*) AS Total_Anuncios 
FROM ANUNCIO 
GROUP BY IDCampanha;

--LEFT OUTER JOIN
-- Todos os clientes e seus telefones (incluindo os com NULL pra mostrar que tá vazio)
SELECT c.Nome, t.Telefone
FROM CLIENTE c
LEFT JOIN TELEFONE_CLIENTE t ON c.CPF = t.CPF_Cliente;

--SUBCONSULTA COM OPERADOR RELACIONAL
-- Clientes com orçamento acima da média
SELECT Nome FROM CLIENTE WHERE CPF IN (
  SELECT CPF_Pagador FROM CAMPANHA 
  WHERE Orcamento > (SELECT AVG(Orcamento) FROM CAMPANHA)
);

--SUBCONSULTA COM IN
-- Funcionários em campanhas
SELECT Nome FROM FUNCIONARIO WHERE IDFuncionario IN (
  SELECT DISTINCT IDFuncionario FROM ALOCA
);

--SUBCONSULTA COM ANY
-- Anúncios com duração maior que QUALQUER anúncio da campanha 1
SELECT Titulo FROM ANUNCIO 
WHERE Duracao > ANY (SELECT Duracao FROM ANUNCIO WHERE IDCampanha = 1);

--SUBCONSULTA COM ALL
-- Campanhas com orçamento maior que TODAS as campanhas da Padaria
SELECT Nome FROM CAMPANHA 
WHERE Orcamento > ALL (
  SELECT Orcamento FROM CAMPANHA 
  WHERE CPF_Pagador = '11122233344'
);

--ORDER BY
-- Funcionários ordenados por departamento e nome
SELECT Nome, Cargo, Departamento FROM FUNCIONARIO 
ORDER BY Departamento, Nome;

--GROUP BY
-- Total de anúncios por tipo de meio de comunicação
SELECT m.Tipo, COUNT(*) AS Total_Anuncios
FROM ANUNCIA_EM ae
JOIN MEIO_DE_COMUNICACAO m ON ae.Nome_Meio = m.Nome
GROUP BY m.Tipo;

--HAVING
-- Meios de comunicação com mais de 1 anúncio
SELECT Nome_Meio, COUNT(*) AS Total_Anuncios
FROM ANUNCIA_EM
GROUP BY Nome_Meio
HAVING COUNT(*) > 1;

--UNION
-- Combina clientes e funcionários
SELECT Nome, 'Cliente' AS Tipo FROM CLIENTE
UNION
SELECT Nome, 'Funcionario' AS Tipo FROM FUNCIONARIO;

--CREATE VIEW
-- Vista para campanhas ativas
CREATE VIEW VW_CAMPANHAS_ATIVAS AS
SELECT IDCampanha, Nome, DataInicio, DataFim 
FROM CAMPANHA 
WHERE DataInicio <= SYSDATE AND DataFim >= SYSDATE;


--GRANT / REVOKE (Só para mostrar o conceito)
-- Conceder permissão de leitura na tabela CLIENTE para um usuário(pesquisar)
-- GRANT SELECT ON CLIENTE TO usuario_1;

-- Revogar permissão de atualização na tabela FUNCIONARIO
-- REVOKE UPDATE ON FUNCIONARIO FROM usuario_2;