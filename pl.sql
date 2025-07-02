-- O Cenário:
-- Precisamos de uma funcionalidade para analisar as campanhas ativas e identificar aquelas que estão "em risco". 
-- Uma campanha é considerada em risco se ela já começou, mas ainda não tem nenhum anúncio ou nenhum funcionário alocado a ela. 
-- Ao final, o processo deve nos retornar o total de campanhas problemáticas encontradas. Esta solução combina vários conceitos PL/SQL.

-- Passo 1: A Especificação
CREATE OR REPLACE PACKAGE pkg_auditoria_campanha IS

  PROCEDURE prc_verificar_campanhas_risco (
    p_total_risco OUT NUMBER
  );

END pkg_auditoria_campanha;

-- Passo 2: A Implementação
CREATE OR REPLACE PACKAGE BODY pkg_auditoria_campanha IS

  FUNCTION fnc_is_campanha_em_risco (
    p_id_campanha IN CAMPANHA.IDCampanha%TYPE
  ) RETURN BOOLEAN IS
    v_num_anuncios     NUMBER;
    v_num_funcionarios NUMBER;
  BEGIN
    -- Conta quantos anúncios existem para esta campanha
    SELECT COUNT(*)
    INTO v_num_anuncios
    FROM ANUNCIO
    WHERE IDCampanha = p_id_campanha;

    -- Conta quantos funcionários estão alocados a esta campanha (em qualquer anúncio)
    SELECT COUNT(DISTINCT IDFuncionario)
    INTO v_num_funcionarios
    FROM ALOCA
    WHERE IDCampanha = p_id_campanha;

    -- A regra de negócio: se não tiver anúncios OU não tiver equipe, está em risco.
    IF v_num_anuncios = 0 OR v_num_funcionarios = 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END fnc_is_campanha_em_risco;

  /*******************************************************************/

  PROCEDURE prc_verificar_campanhas_risco (
    p_total_risco OUT NUMBER
  ) IS
    -- Cursor para buscar todas as campanhas que estão teoricamente ativas hoje.
    CURSOR c_campanhas_ativas IS
      SELECT IDCampanha, Nome
      FROM CAMPANHA
      WHERE SYSDATE BETWEEN DataInicio AND NVL(DataFim, SYSDATE + 1);
  
  BEGIN
    -- Inicializa o parâmetro de saída
    p_total_risco := 0;
    
    DBMS_OUTPUT.PUT_LINE('--- INICIANDO AUDITORIA DE CAMPANHAS EM RISCO ---');

    FOR rec IN c_campanhas_ativas LOOP
    
      -- Chama a função privada para aplicar a regra de negócio
      IF fnc_is_campanha_em_risco(p_id_campanha => rec.IDCampanha) THEN
        DBMS_OUTPUT.PUT_LINE(
          'ALERTA: A campanha "' || rec.Nome || '" (ID: ' || rec.IDCampanha || ') está em risco (sem anúncios ou equipe).'
        );
        -- Incrementa o contador de saída
        p_total_risco := p_total_risco + 1;
      END IF;
      
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('--- FIM DA AUDITORIA ---');
    DBMS_OUTPUT.PUT_LINE('Total de campanhas em risco encontradas: ' || p_total_risco);

  EXCEPTION
    -- Tratamento de erro genérico para a procedure
    WHEN OTHERS THEN
      p_total_risco := -1; -- Retorna um valor que indica erro
      DBMS_OUTPUT.PUT_LINE('Ocorreu um erro inesperado durante a auditoria: ' || SQLERRM);
  END prc_verificar_campanhas_risco;

END pkg_auditoria_campanha;

-- Passo 3: A Execução
DECLARE
  v_total_encontrado NUMBER;
BEGIN
  -- Chama a procedure que está dentro do pacote
  pkg_auditoria_campanha.prc_verificar_campanhas_risco(
    p_total_risco => v_total_encontrado -- Associa o parâmetro OUT à nossa variável local
  );

  -- Só executa após a procedure terminar.
  IF v_total_encontrado >= 0 THEN
    DBMS_OUTPUT.PUT_LINE(
      CHR(10) || '-------------------------------------------' || CHR(10) ||
      'Processo finalizado. Resultado recebido pelo bloco de execução: ' || v_total_encontrado
    );
  ELSE
    DBMS_OUTPUT.PUT_LINE('A execução da auditoria falhou.');
  END IF;
END;
