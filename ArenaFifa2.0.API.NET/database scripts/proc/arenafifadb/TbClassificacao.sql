USE `arenafifadb`;

DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetPositionByTime` $$
CREATE FUNCTION `fcGetPositionByTime`(pIdCamp INTEGER, pIdTime INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin
	DECLARE _position INTEGER DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _teamID INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR 
	select C.ID_TIME
	from TB_CLASSIFICACAO C
	where C.ID_CAMPEONATO = pIdCamp
	order by C.ID_GRUPO, C.QT_PONTOS_GANHOS desc, C.QT_VITORIAS desc, (C.QT_GOLS_PRO-C.QT_GOLS_CONTRA) desc, C.QT_GOLS_PRO desc, C.QT_GOLS_CONTRA;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	SET _position = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _teamID;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _teamID = pIdTime THEN
			LEAVE get_tabela;
		END IF;
		
		SET _position = _position + 1;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	RETURN _position;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetTimeIDByPosicao` $$
CREATE FUNCTION `fcGetTimeIDByPosicao`(pIdCamp INTEGER, pIdPosicao INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin
	DECLARE _position INTEGER DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _teamID INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR 
	select C.ID_TIME
	from TB_CLASSIFICACAO C
	where C.ID_CAMPEONATO = pIdCamp
	order by C.ID_GRUPO, C.QT_PONTOS_GANHOS desc, C.QT_VITORIAS desc, (C.QT_GOLS_PRO-C.QT_GOLS_CONTRA) desc, C.QT_GOLS_PRO desc, C.QT_GOLS_CONTRA;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	SET _position = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _teamID;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _position = pIdPosicao THEN
			LEAVE get_tabela;
		END IF;
		
		SET _position = _position + 1;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	RETURN _teamID;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetTimeIDByPosicaoEGrupo` $$
CREATE FUNCTION `fcGetTimeIDByPosicaoEGrupo`(pIdCamp INTEGER, pIdPosicao INTEGER, pIdGrupo INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin
	DECLARE _position INTEGER DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _teamID INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR 
	select C.ID_TIME
	from TB_CLASSIFICACAO C
	where C.ID_CAMPEONATO = pIdCamp
	and C.ID_GRUPO = pIdGrupo
	order by C.ID_GRUPO, C.QT_PONTOS_GANHOS desc, C.QT_VITORIAS desc, (C.QT_GOLS_PRO-C.QT_GOLS_CONTRA) desc, C.QT_GOLS_PRO desc, C.QT_GOLS_CONTRA;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	SET _position = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _teamID;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _position = pIdPosicao THEN
			LEAVE get_tabela;
		END IF;
		
		SET _position = _position + 1;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	RETURN _teamID;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddUpdateClassificacao` $$
CREATE PROCEDURE `spAddUpdateClassificacao`(    
    pIdCamp INTEGER,     
    pIdTime INTEGER,
    pTotalPT INTEGER,
    pTotalMatches INTEGER,
    pTotalWin INTEGER,
    pTotalDraw INTEGER,
    pTotalLost INTEGER,
    pGoalsFor INTEGER,
    pGoalsAgaint INTEGER
)
Begin
	DECLARE _idGrupo INTEGER DEFAULT NULL;

	SELECT ID_GRUPO into _idGrupo FROM TB_CLASSIFICACAO
	WHERE ID_CAMPEONATO = pIdCamp and ID_TIME = pIdTime;

	IF _idGrupo IS NULL THEN
	
		SET _idGrupo = 0;

		insert into `TB_CLASSIFICACAO` (`ID_CAMPEONATO`, `ID_TIME`, `ID_GRUPO`, `QT_PONTOS_GANHOS`, `QT_VITORIAS`, `QT_JOGOS`, `QT_EMPATES`, `QT_DERROTAS`, `QT_GOLS_PRO`, `QT_GOLS_CONTRA`) 
		values (pIdCamp, pIdTime, _idGrupo, pTotalPT, pTotalWin, pTotalMatches, pTotalDraw, pTotalLost, pGoalsFor, pGoalsAgaint);

	ELSE
	
		UPDATE TB_CLASSIFICACAO
		SET QT_PONTOS_GANHOS = pTotalPT,
		    QT_VITORIAS = pTotalWin,
			QT_JOGOS = pTotalMatches,
			QT_EMPATES = pTotalDraw,
			QT_DERROTAS = pTotalLost,
			QT_GOLS_PRO = pGoalsFor,
			QT_GOLS_CONTRA = pGoalsAgaint
		WHERE ID_CAMPEONATO = pIdCamp and ID_TIME = pIdTime;

	END IF;
	
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateClassificacaoNewTime` $$
CREATE PROCEDURE `spUpdateClassificacaoNewTime`(    
    pIdCamp INTEGER,     
    pIdTimeOld INTEGER,
    pIdTimeNew INTEGER
)
Begin
    update `TB_CLASSIFICACAO` 
	set ID_TIME = pIdTimeNew
	where ID_CAMPEONATO = pIdCamp and ID_TIME = pIdTimeOld;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllClassificacaoOfCampeonato` $$
CREATE PROCEDURE `spDeleteAllClassificacaoOfCampeonato`(pIdCamp INTEGER)
begin      
   delete from TB_CLASSIFICACAO where ID_CAMPEONATO = pIdCamp;      
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
	DECLARE _idTime VARCHAR(10) DEFAULT NULL;
	DECLARE strDelimiter CHAR(1) DEFAULT ',';
	
	call `arenafifadb`.`spDeleteAllClassificacaoOfCampeonato`(pIdCamp);
	
	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsTime)) = 0 OR pIdsTime IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _next = SUBSTRING_INDEX(pIdsTime,strDelimiter,1);
		
		SET _nextlen = LENGTH(_next);
		
		SET _idTime = TRIM(_next);
		
		call `arenafifadb`.`spAddUpdateClassificacao`(pIdCamp, CAST(_idTime AS SIGNED), 0, 0, 0, 0, 0, 0, 0);

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
	
	call `arenafifadb`.`spDeleteAllClassificacaoOfCampeonato`(pIdCamp);

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idTime;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		call `arenafifadb`.`spAddUpdateClassificacao`(pIdCamp, _idTime, 0, 0, 0, 0, 0, 0, 0);

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
DROP PROCEDURE IF EXISTS `spGetAllClassificacaoTimeOfCampeonato` $$
CREATE PROCEDURE `spGetAllClassificacaoTimeOfCampeonato`(    
    pIdCamp INTEGER
)
begin  
	DECLARE _numRodada INTEGER DEFAULT 0;

	SET _numRodada = fcGetCurrentRoundByCampeonato(pIdCamp);

	select C.*, T.NM_TIME, T.DS_TIPO, T.DS_URL_TIME, U.PSN_ID, T.IN_TIME_EXCLUIDO_TEMP_ATUAL, C.ID_GRUPO,
	(select HC.IN_POSICAO from TB_HISTORICO_CLASSIFICACAO HC where HC.ID_CAMPEONATO = C.ID_CAMPEONATO and HC.ID_TIME = C.ID_TIME and HC.IN_NUMERO_RODADA = _numRodada limit 1) as PosicaoAnterior
	from TB_CLASSIFICACAO C, TB_TIME T, TB_USUARIO_TIME UT, TB_USUARIO U 
	where C.ID_CAMPEONATO = pIdCamp
	and UT.DT_VIGENCIA_FIM is null
	and C.ID_TIME = T.ID_TIME 
	and C.ID_CAMPEONATO = UT.ID_CAMPEONATO
	and T.ID_TIME = UT.ID_TIME
	and UT.ID_USUARIO = U.ID_USUARIO
	order by C.ID_GRUPO, C.QT_PONTOS_GANHOS desc, QT_VITORIAS desc, (QT_GOLS_PRO-QT_GOLS_CONTRA) desc, QT_GOLS_PRO desc, QT_GOLS_CONTRA, T.NM_TIME;      
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateClassificacaoByTime` $$
CREATE PROCEDURE `spCalculateClassificacaoByTime`(    
    pIdCamp INTEGER, pIdTime INTEGER)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _totalPT INTEGER DEFAULT 0;
	DECLARE _match INTEGER DEFAULT 0;
	DECLARE _win INTEGER DEFAULT 0;
	DECLARE _draw INTEGER DEFAULT 0;
	DECLARE _lost INTEGER DEFAULT 0;
	DECLARE _goalsFor INTEGER DEFAULT 0;
	DECLARE _goalsAgainst INTEGER DEFAULT 0;
	DECLARE _goalsTimeHome INTEGER DEFAULT 0;
	DECLARE _goalsTimeAway INTEGER DEFAULT 0;
	DECLARE _idTimeHome INTEGER DEFAULT 0;
	DECLARE _idTimeAway INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_TIME_CASA, QT_GOLS_TIME_CASA, ID_TIME_VISITANTE, QT_GOLS_TIME_VISITANTE 
	FROM TB_TABELA_JOGO 
	WHERE ID_CAMPEONATO = pIdCamp
	  AND ID_FASE = 0
	  AND (ID_TIME_CASA = pIdTime OR ID_TIME_VISITANTE = pIdTime)
	  AND QT_GOLS_TIME_CASA IS NOT NULL 
    ORDER BY ID_TABELA_JOGO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idTimeHome, _goalsTimeHome, _idTimeAway, _goalsTimeAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _match = _match + 1;
		
		IF _goalsTimeHome = _goalsTimeAway THEN
			SET _draw = _draw + 1;
		END IF;
		
		IF pIdTime = _idTimeHome THEN
			IF _goalsTimeHome > _goalsTimeAway THEN
				SET _win = _win + 1;
			ELSEIF _goalsTimeHome < _goalsTimeAway THEN
				SET _lost = _lost + 1;
			END IF;
			
			SET _goalsFor = _goalsFor + _goalsTimeHome;
			SET _goalsAgainst = _goalsAgainst + _goalsTimeAway;
		ELSE
			IF _goalsTimeHome < _goalsTimeAway THEN
				SET _win = _win + 1;
			ELSEIF _goalsTimeHome > _goalsTimeAway THEN
				SET _lost = _lost + 1;
			END IF;
			
			SET _goalsFor = _goalsFor + _goalsTimeAway;
			SET _goalsAgainst = _goalsAgainst + _goalsTimeHome;
		END IF;
		

	END LOOP get_tabela;
	
	SET _totalPT = (_win * 3) + _draw;
	
	call `arenafifadb`.`spAddUpdateClassificacao`(pIdCamp, pIdTime, _totalPT, _match, _win, _draw, _lost, _goalsFor, _goalsAgainst);

	CLOSE tabela_cursor;
End$$
DELIMITER ;