USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddClassificacao` $$
CREATE PROCEDURE `spAddClassificacao`(    
    pIdCamp INTEGER,     
    pIdTime INTEGER
)
Begin
	insert into `TB_CLASSIFICACAO` (`ID_CAMPEONATO`, `ID_TIME`, `DT_ENTRADA`) 
	values (pIdCamp, pIdTime, now());
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllClassificacaoOfCampeonato` $$
CREATE PROCEDURE `spGetAllClassificacaoOfCampeonato`(pIdCamp INTEGER)
begin      
   select * from TB_CLASSIFICACAO where ID_CAMPEONATO = pIdCamp order by ID_TIME;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddLoadClassificacaoInitialOfCampeonato` $$
CREATE PROCEDURE `spAddLoadClassificacaoInitialOfCampeonato`(    
    pIdCamp INTEGER,     
    pIdsTime VARCHAR(250)
)
Begin
	DECLARE _next VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlen INTEGER DEFAULT NULL;
	DECLARE _idUsu VARCHAR(5) DEFAULT NULL;
	DECLARE strDelimiter CHAR(1) DEFAULT ',';
	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsTime)) = 0 OR pIdsTime IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _next = SUBSTRING_INDEX(pIdsTime,strDelimiter,1);
		
		SET _nextlen = LENGTH(_next);
		
		SET _idUsu = TRIM(_next);
		
		insert into `TB_CLASSIFICACAO` (ID_CAMPEONATO, ID_TIME, ID_GRUPO, QT_PONTOS_GANHOS, QT_VITORIAS, QT_JOGOS, QT_EMPATES, QT_DERROTAS, QT_GOLS_PRO, QT_GOLS_CONTRA) 
		values (pIdCamp, CAST(_idUsu AS SIGNED), 0, 0, 0, 0, 0, 0, 0, 0);
		
		SET pIdsTime = INSERT(pIdsTime,1,_nextlen + 1,'');
	END LOOP;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddLoadClassificacaoInitialOfCampeonatov2` $$
CREATE PROCEDURE `spAddLoadClassificacaoInitialOfCampeonatov2`(    
    pIdCamp INTEGER)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idTime INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_TIME FROM TB_CAMPEONATO_TIME WHERE ID_CAMPEONATO = pIdCamp;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idTime;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;

		insert into `TB_CLASSIFICACAO` (ID_CAMPEONATO, ID_TIME, ID_GRUPO, QT_PONTOS_GANHOS, QT_VITORIAS, QT_JOGOS, QT_EMPATES, QT_DERROTAS, QT_GOLS_PRO, QT_GOLS_CONTRA) 
		values (pIdCamp, _idTime, 0, 0, 0, 0, 0, 0, 0, 0);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteClassificacaoOfCampeonato` $$
CREATE PROCEDURE `spDeleteClassificacaoOfCampeonato`(pIdCamp INTEGER)
Begin
	delete from `TB_CLASSIFICACAO` where ID_CAMPEONATO = pIdCamp;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spRemoveClassificacaoGrupoOfTime` $$
CREATE PROCEDURE `spRemoveClassificacaoGrupoOfTime`(    
    pIdCamp INTEGER,     
    pIdTime INTEGER
)
Begin
	update `TB_CLASSIFICACAO` 
	set ID_GRUPO = 0, IN_ORDENACAO_GRUPO = 0
	where ID_CAMPEONATO = pIdCamp and ID_TIME = pIdTime;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spRemoveClassificacaoGrupoOfAllTimes` $$
CREATE PROCEDURE `spRemoveClassificacaoGrupoOfAllTimes`(pIdCamp INTEGER)
Begin
	update `TB_CLASSIFICACAO` 
	set ID_GRUPO = 0, IN_ORDENACAO_GRUPO = 0
	where ID_CAMPEONATO = pIdCamp;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddClassificacaoGrupoOfTime` $$
CREATE PROCEDURE `spAddClassificacaoGrupoOfTime`(    
    pIdCamp INTEGER,     
    pIdTime INTEGER,
    pIdGrupo INTEGER,
    pOrdem INTEGER
)
Begin
	update `TB_CLASSIFICACAO` 
	set ID_GRUPO = pIdGrupo, IN_ORDENACAO_GRUPO = pOrdem
	where ID_CAMPEONATO = pIdCamp and ID_TIME = pIdTime;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllClassificacaoTimeOfGrupo` $$
CREATE PROCEDURE `spGetAllClassificacaoTimeOfGrupo`(    
    pIdCamp INTEGER,     
    pIdGrupo INTEGER,
	pNumRodada INTEGER
)
begin      
   select C.*, T.NM_TIME, T.DS_TIPO, T.DS_URL_TIME, U.PSN_ID as PSN1, T.IN_TIME_EXCLUIDO_TEMP_ATUAL,
   (select IN_POSICAO from TB_HISTORICO_CLASSIFICACAO HC where HC.ID_CAMPEONATO = C.ID_CAMPEONATO and HC.ID_TIME = C.ID_TIME and HC.IN_NUMERO_RODADA = pNumRodada limit 1) as PosicaoAnterior
   from TB_CLASSIFICACAO C, TB_TIME T, TB_USUARIO_TIME UT, TB_USUARIO U 
   where C.ID_TIME = T.ID_TIME 
   and C.ID_CAMPEONATO = UT.ID_CAMPEONATO
   and T.ID_TIME = UT.ID_TIME
   and UT.ID_USUARIO = U.ID_USUARIO
   and UT.DT_VIGENCIA_FIM is null
   and C.ID_CAMPEONATO = pIdCamp
   and C.ID_GRUPO = pIdGrupo
   order by C.QT_PONTOS_GANHOS desc, QT_VITORIAS desc, (QT_GOLS_PRO-QT_GOLS_CONTRA) desc, QT_GOLS_PRO desc, QT_GOLS_CONTRA, T.NM_TIME;      
End$$
DELIMITER ;

