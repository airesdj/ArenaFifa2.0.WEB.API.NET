USE `arenafifadb`;

DROP TABLE IF EXISTS `TB_PARAM_QUALIFY_FROM_STAGE0`;

CREATE TABLE `arenafifadb`.`TB_PARAM_QUALIFY_FROM_STAGE0` (
  `IN_QT_TIMES_QUALIFY` INTEGER NOT NULL DEFAULT 0, 
  `ID_JOGO_MATAXMATA` INTEGER NOT NULL DEFAULT 0, 
  `ID_GRUPO_CASA` INTEGER NOT NULL DEFAULT 0, 
  `ID_POSICAO_CASA` INTEGER NOT NULL DEFAULT 0, 
  `ID_POSICAO_VISITANTE` INTEGER NOT NULL DEFAULT 0, 
  `ID_GRUPO_VISITANTE` INTEGER NOT NULL DEFAULT 0, 
  INDEX (`IN_QT_TIMES_QUALIFY`, `ID_GRUPO_CASA`), 
  INDEX (`IN_QT_TIMES_QUALIFY`, `ID_GRUPO_CASA`, `ID_POSICAO_CASA`), 
  INDEX (`IN_QT_TIMES_QUALIFY`, `ID_GRUPO_VISITANTE`, `ID_POSICAO_VISITANTE`), 
  PRIMARY KEY (`IN_QT_TIMES_QUALIFY`, `ID_JOGO_MATAXMATA`, `ID_GRUPO_CASA`, `ID_POSICAO_CASA`, `ID_POSICAO_VISITANTE`, `ID_GRUPO_VISITANTE`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (4, 1, 0, 1, 4, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (4, 2, 0, 2, 3, 0);

INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (8, 1, 0, 1, 8, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (8, 2, 0, 4, 5, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (8, 3, 0, 2, 7, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (8, 4, 0, 3, 6, 0);

INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 1, 0, 1, 16, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 2, 0, 8, 9, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 3, 0, 3, 14, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 4, 0, 7, 10, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 5, 0, 2, 15, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 6, 0, 6, 11, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 7, 0, 4, 13, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 8, 0, 5, 12, 0);

INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 1, 0, 1, 32, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 2, 0, 3, 30, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 3, 0, 5, 28, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 4, 0, 7, 26, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 5, 0, 9, 24, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 6, 0, 11, 22, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 7, 0, 13, 20, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 8, 0, 15, 18, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 9, 0, 2, 31, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 10, 0, 4, 29, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 11, 0, 6, 27, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 12, 0, 8, 25, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 13, 0, 10, 23, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 14, 0, 12, 21, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 15, 0, 14, 19, 0);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (32, 16, 0, 16, 17, 0);

INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 1, 1, 1, 2, 2);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 2, 3, 1, 2, 4);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 3, 5, 1, 2, 6);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 4, 7, 1, 2, 8);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 5, 2, 1, 2, 1);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 6, 4, 1, 2, 3);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 7, 6, 1, 2, 5);
INSERT INTO TB_PARAM_QUALIFY_FROM_STAGE0 VALUES (16, 8, 8, 1, 2, 7);


DROP TABLE IF EXISTS `TB_TEMP_GENERATE_STAGE`;

CREATE TABLE `arenafifadb`.`TB_TEMP_GENERATE_STAGE` (
  `ID_CAMPEONATO` INTEGER NOT NULL DEFAULT 0, 
  `ID_POSICAO` INTEGER NOT NULL DEFAULT 0, 
  `ID_TIME` INTEGER NOT NULL DEFAULT 0, 
  `ID_GRUPO` INTEGER NULL DEFAULT NULL, 
  INDEX (`ID_CAMPEONATO`, `ID_TIME`), 
  INDEX (`ID_CAMPEONATO`, `ID_GRUPO`, `ID_POSICAO`), 
  INDEX (`ID_CAMPEONATO`, `ID_POSICAO`), 
  PRIMARY KEY (`ID_CAMPEONATO`, `ID_POSICAO`, `ID_TIME`)
) ENGINE=myisam DEFAULT CHARSET=utf8;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcValidadeIdDrawTimeExistTabTempQualify1` $$
CREATE FUNCTION `fcValidadeIdDrawTimeExistTabTempQualify1`(pIdCamp INTEGER, pIdDraw INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin
	DECLARE _inRetorno INTEGER DEFAULT 0;
	DECLARE _count INTEGER DEFAULT 0;
	
	SELECT count(1) into _count FROM TB_TEMP_GENERATE_STAGE WHERE ID_CAMPEONATO = pIdCamp AND ID_POSICAO = pIdDraw;
	IF _count > 0 THEN
		SET _inRetorno = 1;
	END IF;

	RETURN _inRetorno;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllTabTempGenerateStageByCampeonato` $$
CREATE PROCEDURE `spDeleteAllTabTempGenerateStageByCampeonato`(
	pIdCamp INTEGER
)
begin 
	DELETE FROM TB_TEMP_GENERATE_STAGE
	WHERE ID_CAMPEONATO = pIdCamp;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTabTempGenerateStage` $$
CREATE PROCEDURE `spAddTabTempGenerateStage`(
	pIdCamp INTEGER,
	pIdPositon INTEGER,
	pIdTime INTEGER,
	pIdGrupo INTEGER
)
begin 
	INSERT INTO TB_TEMP_GENERATE_STAGE VALUES (pIdCamp, pIdPositon,pIdTime, pIdGrupo);
End$$
DELIMITER ;



DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetTimePositionInTabTemp` $$
CREATE FUNCTION `fcGetTimePositionInTabTemp`(pIdCamp INTEGER, pIdPosition INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin
	DECLARE _teamID INTEGER DEFAULT NULL;

	select ID_TIME into _teamID
	from TB_TEMP_GENERATE_STAGE
	where ID_CAMPEONATO = pIdCamp AND ID_POSICAO = pIdPosition;
	
	IF _teamID IS NULL THEN
		SET _teamID = 0;
	END IF;

	RETURN _teamID;
End$$
DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetTimePositionInTabTempByGrupo` $$
CREATE FUNCTION `fcGetTimePositionInTabTempByGrupo`(pIdCamp INTEGER, pIdPosition INTEGER, pIdGrupo INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin
	DECLARE _teamID INTEGER DEFAULT NULL;

	select ID_TIME into _teamID
	from TB_TEMP_GENERATE_STAGE
	where ID_CAMPEONATO = pIdCamp AND ID_GRUPO = pIdGrupo AND ID_POSICAO = pIdPosition;
	
	IF _teamID IS NULL THEN
		SET _teamID = 0;
	END IF;

	RETURN _teamID;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteFasePlayOffByFase` $$
CREATE PROCEDURE `spDeleteFasePlayOffByFase`(
	pIdCamp INTEGER,
	pIdFase INTEGER
)
begin 
	call `arenafifadb`.`spDeleteComentarioUsuarioOfTabelaJogoByFase`(pIdCamp, pIdFase);
     
	DELETE FROM TB_TABELA_JOGO
	WHERE ID_CAMPEONATO = pIdCamp AND ID_FASE = pIdFase;
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdatePositionTimeGenerateStage` $$
CREATE PROCEDURE `spUpdatePositionTimeGenerateStage`(
	pIdCamp INTEGER,
	pPositionStart INTEGER
)
begin 
	DECLARE _position INTEGER DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _teamID INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR 
	select C.ID_TIME
	from TB_CLASSIFICACAO C
	where C.ID_CAMPEONATO = pIdCamp
	and C.ID_TIME IN (SELECT G.ID_TIME FROM TB_TEMP_GENERATE_STAGE G WHERE G.ID_CAMPEONATO = pIdCamp AND ID_POSITION = 0)
	order by C.ID_GRUPO, C.QT_PONTOS_GANHOS desc, C.QT_VITORIAS desc, (C.QT_GOLS_PRO-C.QT_GOLS_CONTRA) desc, C.QT_GOLS_PRO desc, C.QT_GOLS_CONTRA;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	SET _position = pPositionStart;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _teamID;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		UPDATE TB_TEMP_GENERATE_STAGE SET ID_POSICAO = _position
		WHERE ID_CAMPEONATO = pIdCamp AND ID_TIME = _teamID;
		
		SET _position = _position + 1;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTimeFromCampeonatoOrigem` $$
CREATE PROCEDURE `spAddTimeFromCampeonatoOrigem`(
	pIdCamp INTEGER,
	pIdCampOrigem INTEGER,
	pPositionOrigem INTEGER
)
begin 
	DECLARE _position INTEGER DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _teamID INTEGER DEFAULT 0;
	DECLARE _totalGrupos INTEGER DEFAULT 0;
	DECLARE _totalTimes INTEGER DEFAULT 0;
	DECLARE _numGroup INTEGER DEFAULT 1;
	DECLARE _numTeamsPerGurpo INTEGER DEFAULT 0;
	DECLARE _numTeamsQualified INTEGER DEFAULT 1;
	
	SELECT QT_GRUPOS, QT_TIMES into _totalGrupos, _totalTimes FROM TB_CAMPEONATO WHERE ID_CAMPEONATO = pIdCampOrigem;

	SET _numTeamsPerGurpo = (QT_TIMES / _totalGrupos);

	WHILE _numGroup <= _totalGrupos DO

		SET _numTeamsQualified = 1;

		WHILE _numTeamsQualified <= _numTeamsPerGurpo DO

			IF _numTeamsQualified = pPositionOrigem THEN
			
				call `arenafifadb`.`spAddTabTempGenerateStage`(pIdCamp, 0, fcGetTimeIDByPosicaoEGrupo(pIdCampOrigem, pPositionOrigem, _numGroup), NULL);
			
			END IF;

			SET _numTeamsQualified = _numTeamsQualified + 1;

		END WHILE;

		SET _numGroup = _numGroup + 1;

	END WHILE;
	
End$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllFaseByCampeonato` $$
CREATE PROCEDURE `spGetAllFaseByCampeonato`(pIdCamp INTEGER)
begin      
   SELECT X.ID_FASE, X.NM_FASE, X.TOTALMATCHESNORESULT, X.EXISTMATCHES, CASE WHEN X.EXISTMATCHES = 0 THEN 'Fase Não Gerada' WHEN X.TOTALMATCHESNORESULT > 0 THEN 'Fase Em Andamento' ELSE 'Fase Finalizada' END as STATUS
   FROM (select F.ID_FASE, F.NM_FASE, 
               (select count(1) from TB_TABELA_JOGO T where T.ID_CAMPEONATO = C.ID_CAMPEONATO AND T.ID_FASE = C.ID_FASE) as existMatches,
               (select count(1) from TB_TABELA_JOGO T where T.ID_CAMPEONATO = C.ID_CAMPEONATO AND T.ID_FASE = C.ID_FASE AND T.QT_GOLS_TIME_CASA IS NULL) as totalMatchesNoResult
	     from TB_FASE_CAMPEONATO C, TB_FASE F
	     where C.ID_CAMPEONATO = pIdCamp
		   and C.ID_FASE = F.ID_FASE) as X
   order by X.ID_FASE;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateFasePlayOffFromPlayOff` $$
CREATE PROCEDURE `spGenerateFasePlayOffFromPlayOff`(
	pIdCamp INTEGER,
	pIdFase INTEGER,
	pIdPreviousFase INTEGER,
	pDtInicioFase DATE
)
begin      
	DECLARE _IdaVolta TINYINT DEFAULT NULL;
	DECLARE _totalDays INTEGER DEFAULT 0;

	SELECT C.IN_SISTEMA_IDA_VOLTA, C.QT_DIAS_PARTIDA_FASE_MATAxMATA into _IdaVolta, _totalDays
	FROM TB_CAMPEONATO C WHERE C.ID_CAMPEONATO = pIdCamp;
	
	call `arenafifadb`.`spDeleteAllTabTempGenerateStageByCampeonato`(pIdCamp);
	
	IF _IdaVolta = TRUE THEN
	
		call `arenafifadb`.`spGenerateFasePlayOffFromPlayOffTwoLegs`(pIdCamp, pIdFase, pIdPreviousFase, pDtInicioFase, _totalDays);
	
	ELSE
	
		call `arenafifadb`.`spGenerateFasePlayOffFromPlayOffOneLeg`(pIdCamp, pIdFase, pIdPreviousFase, pDtInicioFase, _totalDays);

	END IF;
	
	call `arenafifadb`.`spAddLoadComentarioUsuarioOfCampeonatoByFase`(pIdCamp, pIdFase);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateFasePlayOffFromStage0` $$
CREATE PROCEDURE `spGenerateFasePlayOffFromStage0`(
	pIdCamp INTEGER,
	pIdFase INTEGER,
	pDtInicioFase DATE
)
begin      
	DECLARE _IdaVolta TINYINT DEFAULT NULL;
	DECLARE _totalDays INTEGER DEFAULT 0;
	DECLARE _totalGroups INTEGER DEFAULT 0;
	DECLARE _totalTeamsQualified INTEGER DEFAULT 0;
	DECLARE _totalTeamsForGroup INTEGER DEFAULT 0;
	DECLARE _championshipIDSource INTEGER DEFAULT 0;
	DECLARE _positionSource INTEGER DEFAULT 0;
	DECLARE _type VARCHAR(4) DEFAULT NULL;

	SELECT C.IN_SISTEMA_IDA_VOLTA, C.QT_DIAS_PARTIDA_FASE_MATAxMATA, C.QT_TIMES_CLASSIFICADOS, C.QT_GRUPOS, C.ID_CAMPEONATO_ORIGEM, C.IN_POSICAO_ORIGEM, SG_TIPO_CAMPEONATO
	  into _IdaVolta, _totalDays, _totalTeamsQualified, _totalGroups, _championshipIDSource, _positionSource, _type
	FROM TB_CAMPEONATO C WHERE C.ID_CAMPEONATO = pIdCamp;
	
	IF _totalGroups > 0 THEN
	
		SET _totalTeamsForGroup = _totalTeamsQualified;
		SET _totalTeamsQualified = (_totalTeamsQualified * _totalGroups);
	
	END IF;
	
	call `arenafifadb`.`spDeleteAllTabTempGenerateStageByCampeonato`(pIdCamp);
	
	IF _IdaVolta = TRUE THEN
	
		IF _totalGroups > 0 and _championshipIDSource IS NULL THEN

			call `arenafifadb`.`spGenerateFasePlayOffFromStage0ForGroup`(pIdCamp, pIdFase, pDtInicioFase, _totalDays, _totalTeamsQualified, _totalGroups, _IdaVolta, _totalTeamsForGroup);

		ELSEIF _totalGroups > 0 and _championshipIDSource IS NOT NULL THEN

			SET _totalTeamsQualified = (_totalTeamsQualified * 2);
			
			call `arenafifadb`.`spGenerateFasePlayOffFromStage0ForGroupEuropeLeague`(pIdCamp, pIdFase, pDtInicioFase, _totalDays, _totalTeamsQualified, _totalGroups, _IdaVolta, _championshipIDSource, _positionSource, _totalTeamsForGroup);

		END IF;
	
	ELSE
		IF _totalGroups = 0 THEN

			call `arenafifadb`.`spGenerateFasePlayOffFromStage0ForLeagueOneLeg`(pIdCamp, pIdFase, pDtInicioFase, _totalDays, _totalTeamsQualified);

		ELSEIF _type = "CPDM" THEN

			call `arenafifadb`.`spGenerateFasePlayOffFromStage0CPDM`(pIdCamp, pIdFase, pDtInicioFase, _totalDays, _totalTeamsQualified, _totalGroups, _totalTeamsForGroup);

		ELSE

			call `arenafifadb`.`spGenerateFasePlayOffFromStage0ForGroup`(pIdCamp, pIdFase, pDtInicioFase, _totalDays, _totalTeamsQualified, _totalGroups, _IdaVolta, _totalTeamsForGroup);

		END IF;
	END IF;
	
	call `arenafifadb`.`spAddLoadComentarioUsuarioOfCampeonatoByFase`(pIdCamp, pIdFase);
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateFasePlayOffFromStageQualify1` $$
CREATE PROCEDURE `spGenerateFasePlayOffFromStageQualify1`(
	pIdCamp INTEGER,
	pIdFase INTEGER,
	pDtInicioFase DATE
)
begin      
	DECLARE _finished INTEGER DEFAULT 0;

	DECLARE _teamHomeIDAux INTEGER DEFAULT 0;
	DECLARE _totalGoalsHome INTEGER DEFAULT 0;
	DECLARE _teamAwayIDAux INTEGER DEFAULT 0;
	DECLARE _totalGoalsAway INTEGER DEFAULT 0;
	DECLARE _totalDays INTEGER DEFAULT 0;

	DECLARE _teamID1 INTEGER DEFAULT 0;
	DECLARE _goalsTeam1 INTEGER DEFAULT 0;
	DECLARE _goalsAwayTeam1 INTEGER DEFAULT 0;
	DECLARE _position1 INTEGER DEFAULT 0;
	DECLARE _teamID2 INTEGER DEFAULT 0;
	DECLARE _goalsTeam2 INTEGER DEFAULT 0;
	DECLARE _goalsAwayTeam2 INTEGER DEFAULT 0;
	DECLARE _position2 INTEGER DEFAULT 0;
	DECLARE _teamHomeID INTEGER DEFAULT 0;
	DECLARE _teamAwayID INTEGER DEFAULT 0;
	
	DECLARE _numMatchPlayOff INTEGER DEFAULT 1;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT J.ID_TIME_CASA, J.ID_TIME_VISITANTE, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE
	FROM TB_TABELA_JOGO J WHERE J.ID_CAMPEONATO = pIdCamp AND J.ID_FASE = -1
	ORDER BY J.IN_JOGO_MATAXMATA, J.IN_NUMERO_RODADA, J.ID_TABELA_JOGO;
	
	DECLARE tabela_cursor_v2 CURSOR FOR 
	SELECT ID_TIME_CASA
	FROM TB_CAMPEONATO_TIME 
	WHERE ID_CAMPEONATO = pIdCamp 
	AND ID_TIME NOT IN (SELECT P.ID_TIME FROM TB_TIMES_FASE_PRECOPA P WHERE P.ID_CAMPEONATO = pIdCamp)
	ORDER BY ID_TIME;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	SELECT C.QT_DIAS_PARTIDA_FASE_MATAxMATA into _totalDays
	FROM TB_CAMPEONATO C WHERE C.ID_CAMPEONATO = pIdCamp;
	
	call `arenafifadb`.`spDeleteAllTabTempGenerateStageByCampeonato`(pIdCamp);
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _teamHomeIDAux, _teamAwayIDAux, _totalGoalsHome, _totalGoalsAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _goalsTeam1 = _totalGoalsHome;
		SET _goalsTeam2 = _totalGoalsAway;
		SET _goalsAwayTeam2 = _totalGoalsAway;
		
		FETCH tabela_cursor INTO _teamHomeIDAux, _teamAwayIDAux, _totalGoalsHome, _totalGoalsAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _goalsTeam1 = _goalsTeam1 + _totalGoalsAway;
		SET _goalsTeam2 = _goalsTeam2 + _totalGoalsHome;
		SET _goalsAwayTeam1 = _totalGoalsAway;
		
		IF _goalsTeam1 > _goalsTeam2 THEN
			SET _teamID1 = _teamAwayIDAux;
		ELSEIF _goalsTeam1 < _goalsTeam2 THEN
			SET _teamID1 = _teamHomeIDAux;
		ELSEIF _goalsTeam1 = _goalsTeam2 AND _goalsAwayTeam1 > _goalsAwayTeam2 THEN
			SET _teamID1 = _teamAwayIDAux;
		ELSEIF _goalsTeam1 = _goalsTeam2 AND _goalsAwayTeam1 < _goalsAwayTeam2 THEN
			SET _teamID1 = _teamHomeIDAux;
		END IF;
		
		call `arenafifadb`.`spAddTabTempGenerateStage`(pIdCamp, 0, _teamID1, NULL);

	END LOOP get_tabela;
	
	CLOSE tabela_cursor;


	OPEN tabela_cursor_v2;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor_v2 INTO _teamID1;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		call `arenafifadb`.`spAddTabTempGenerateStage`(pIdCamp, 0, _teamID1, NULL);

	END LOOP get_tabela;
	
	CLOSE tabela_cursor_v2;
	
	call `arenafifadb`.`spGenerateDrawPlayOffFromStageQualify1`(pIdCamp);
	
	call `arenafifadb`.`spGenerateDrawClashesFromQualify1`(pIdCamp, _totalDays, pDtInicioFase, TRUE, pIdFase);
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateDrawPlayOffFromStageQualify1` $$
CREATE PROCEDURE `spGenerateDrawPlayOffFromStageQualify1`(
	pIdCamp INTEGER
)
begin      
	DECLARE _finished INTEGER DEFAULT 0;

	DECLARE _teamID1 INTEGER DEFAULT 0;
	DECLARE _draw INTEGER DEFAULT 0;
	DECLARE _total INTEGER DEFAULT 0;
	DECLARE _inIdDrawExist INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_TIME
	FROM TB_TEMP_GENERATE_STAGE WHERE ID_CAMPEONATO = pIdCamp
	ORDER BY ID_TIME;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	SELECT count(1) into _total
	FROM TB_TEMP_GENERATE_STAGE WHERE ID_CAMPEONATO = pIdCamp;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _teamID1;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		get_draw: LOOP

			SET _draw = fcGetIdDrawAutomatic(1, _total);
		
			SET _inIdDrawExist = fcValidadeIdDrawTimeExistTabTempQualify1(pIdCamp, _draw);
			
			IF _inIdDrawExist = 0 THEN
				LEAVE get_draw;
			END IF;
		
		END LOOP get_draw;
		
		UPDATE TB_TEMP_GENERATE_STAGE 
		SET ID_POSITION = _draw
		WHERE ID_CAMPEONATO = pIdCamp AND ID_TIME = _teamID1;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateDrawClashesFromQualify1` $$
CREATE PROCEDURE `spGenerateDrawClashesFromQualify1`(
	pIdCamp INTEGER, pIntervalDias INTEGER, pDtInicio DATE, pInIdaEVolta TINYINT, pFirstFase INTEGER
)
begin      
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idTimeHome INTEGER DEFAULT 0;
	DECLARE _idTimeAway INTEGER DEFAULT 0;
	DECLARE _inIdDrawExist INTEGER DEFAULT 0;
	DECLARE _count INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT ID_TIME FROM TB_TEMP_GENERATE_STAGE WHERE ID_CAMPEONATO = pIdCamp ORDER BY ID_POSITION;
		
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		SET _count = _count + 1;
	
		FETCH tabela_cursor INTO _idTimeAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
	
		FETCH tabela_cursor INTO _idTimeHome;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
	
		call `arenafifadb`.`spAddTabelaJogo`(pIdCamp, pFirstFase, pDtInicio, pIntervalDias, 0, _idTimeHome, _idTimeAway, _count, pInIdaEVolta);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;

End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateFasePlayOffFromStage0ForLeagueOneLeg` $$
CREATE PROCEDURE `spGenerateFasePlayOffFromStage0ForLeagueOneLeg`(
	pIdCamp INTEGER,
	pIdFase INTEGER,
	pDtInicioFase DATE,
	pInterval INTEGER,
	pTotalTeamsQualified INTEGER
)
begin      
	DECLARE _finished INTEGER DEFAULT 0;
	
	DECLARE _position1 INTEGER DEFAULT 0;
	DECLARE _position2 INTEGER DEFAULT 0;
	DECLARE _teamHomeID INTEGER DEFAULT 0;
	DECLARE _teamAwayID INTEGER DEFAULT 0;
	
	DECLARE _numMatchPlayOff INTEGER DEFAULT 1;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_JOGO_MATAXMATA, ID_POSICAO_CASA, ID_POSICAO_VISITANTE
	FROM TB_PARAM_QUALIFY_FROM_STAGE0 WHERE IN_QT_TIMES_QUALIFY = pTotalTeamsQualified AND ID_GRUPO_CASA = 0
	ORDER BY ID_JOGO_MATAXMATA;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	WHILE _numMatchPlayOff <= pTotalTeamsQualified DO

		call `arenafifadb`.`spAddTabTempGenerateStage`(pIdCamp, _numMatchPlayOff, fcGetTimeIDByPosicao(pIdCamp, _numMatchPlayOff), NULL);

		SET _numMatchPlayOff = _numMatchPlayOff + 1;

	END WHILE;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _numMatchPlayOff, _position1, _position2;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _teamHomeID = fcGetTimePositionInTabTemp(pIdCamp, _position1);
		SET _teamAwayID = fcGetTimePositionInTabTemp(pIdCamp, _position2);
		
		call `arenafifadb`.`spAddTabelaJogo`(pIdCamp, pIdFase, pDtInicioFase, pInterval, 1, _teamHomeID, _teamAwayID, _numMatchPlayOff, FALSE, TRUE);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateFasePlayOffFromStage0CPDM` $$
CREATE PROCEDURE `spGenerateFasePlayOffFromStage0CPDM`(
	pIdCamp INTEGER,
	pIdFase INTEGER,
	pDtInicioFase DATE,
	pInterval INTEGER,
	pTotalTeamsQualified INTEGER,
	pTotalGroups INTEGER,
	pTotalTeamsQualifiedForGroup INTEGER
)
begin      
	DECLARE _finished INTEGER DEFAULT 0;
	
	DECLARE _position1 INTEGER DEFAULT 0;
	DECLARE _position2 INTEGER DEFAULT 0;
	DECLARE _numGroup1 INTEGER DEFAULT 0;
	DECLARE _numGroup2 INTEGER DEFAULT 0;
	DECLARE _teamHomeID INTEGER DEFAULT 0;
	DECLARE _teamAwayID INTEGER DEFAULT 0;
	
	DECLARE _numMatchPlayOff INTEGER DEFAULT 1;
	DECLARE _numGroup INTEGER DEFAULT 1;
	DECLARE _numTeamsQualified INTEGER DEFAULT 1;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_JOGO_MATAXMATA, ID_POSICAO_CASA, ID_POSICAO_VISITANTE, ID_GRUPO_CASA, ID_GRUPO_VISITANTE
	FROM TB_PARAM_QUALIFY_FROM_STAGE0 WHERE IN_QT_TIMES_QUALIFY = pTotalTeamsQualified AND ID_GRUPO_CASA > 0
	ORDER BY ID_JOGO_MATAXMATA;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	WHILE _numGroup <= pTotalGroups DO

		SET _numTeamsQualified = 1;

		WHILE _numTeamsQualified <= pTotalTeamsQualifiedForGroup DO

			call `arenafifadb`.`spAddTabTempGenerateStage`(pIdCamp, _numTeamsQualified, fcGetTimeIDByPosicaoEGrupo(pIdCamp, _numTeamsQualified, _numGroup), _numGroup);

			SET _numTeamsQualified = _numTeamsQualified + 1;

		END WHILE;

		SET _numGroup = _numGroup + 1;

	END WHILE;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _numMatchPlayOff, _position1, _position2, _numGroup1, _numGroup2;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _teamHomeID = fcGetTimePositionInTabTempByGrupo(pIdCamp, _position1, _numGroup1);
		SET _teamAwayID = fcGetTimePositionInTabTempByGrupo(pIdCamp, _position2, _numGroup2);
		
		call `arenafifadb`.`spAddTabelaJogo`(pIdCamp, pIdFase, pDtInicioFase, pInterval, 1, _teamHomeID, _teamAwayID, _numMatchPlayOff, FALSE, TRUE);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateFasePlayOffFromStage0ForGroup` $$
CREATE PROCEDURE `spGenerateFasePlayOffFromStage0ForGroup`(
	pIdCamp INTEGER,
	pIdFase INTEGER,
	pDtInicioFase DATE,
	pInterval INTEGER,
	pTotalTeamsQualified INTEGER,
	pTotalGroups INTEGER,
	pIdaVolta TINYINT,
	pTotalTeamsQualifiedForGroup INTEGER
)
begin      
	DECLARE _finished INTEGER DEFAULT 0;
	
	DECLARE _position1 INTEGER DEFAULT 0;
	DECLARE _position2 INTEGER DEFAULT 0;
	DECLARE _teamHomeID INTEGER DEFAULT 0;
	DECLARE _teamAwayID INTEGER DEFAULT 0;
	
	DECLARE _numMatchPlayOff INTEGER DEFAULT 1;
	DECLARE _numGroup INTEGER DEFAULT 1;
	DECLARE _numTeamsQualified INTEGER DEFAULT 1;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_JOGO_MATAXMATA, ID_POSICAO_CASA, ID_POSICAO_VISITANTE
	FROM TB_PARAM_QUALIFY_FROM_STAGE0 WHERE IN_QT_TIMES_QUALIFY = pTotalTeamsQualified AND ID_GRUPO_CASA = 0
	ORDER BY ID_JOGO_MATAXMATA;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	WHILE _numGroup <= pTotalGroups DO
	
		SET _numTeamsQualified = 1;

		WHILE _numTeamsQualified <= pTotalTeamsQualifiedForGroup DO

			call `arenafifadb`.`spAddTabTempGenerateStage`(pIdCamp, 0, fcGetTimeIDByPosicaoEGrupo(pIdCamp, _numTeamsQualified, _numGroup), NULL);

			SET _numTeamsQualified = _numTeamsQualified + 1;

		END WHILE;

		SET _numGroup = _numGroup + 1;

	END WHILE;
	
	call `arenafifadb`.`spUpdatePositionTimeGenerateStage`(pIdCamp, 1);

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _numMatchPlayOff, _position1, _position2;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _teamHomeID = fcGetTimePositionInTabTemp(pIdCamp, _position1);
		SET _teamAwayID = fcGetTimePositionInTabTemp(pIdCamp, _position2);
		
		call `arenafifadb`.`spAddTabelaJogo`(pIdCamp, pIdFase, pDtInicioFase, pInterval, 1, _teamHomeID, _teamAwayID, _numMatchPlayOff, pIdaVolta, TRUE);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;

End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateFasePlayOffFromStage0ForGroupEuropeLeague` $$
CREATE PROCEDURE `spGenerateFasePlayOffFromStage0ForGroupEuropeLeague`(
	pIdCamp INTEGER,
	pIdFase INTEGER,
	pDtInicioFase DATE,
	pInterval INTEGER,
	pTotalTeamsQualified INTEGER,
	pTotalGroups INTEGER,
	pIdaVolta TINYINT,
	pCampeonatoOrigem INTEGER,
	pPosicaoOrigem INTEGER,
	pTotalTeamsQualifiedForGroup INTEGER
)
begin      
	DECLARE _finished INTEGER DEFAULT 0;
	
	DECLARE _position1 INTEGER DEFAULT 0;
	DECLARE _position2 INTEGER DEFAULT 0;
	DECLARE _teamHomeID INTEGER DEFAULT 0;
	DECLARE _teamAwayID INTEGER DEFAULT 0;
	
	DECLARE _numMatchPlayOff INTEGER DEFAULT 1;
	DECLARE _numGroup INTEGER DEFAULT 1;
	DECLARE _numTeamsQualified INTEGER DEFAULT 1;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_JOGO_MATAXMATA, ID_POSICAO_CASA, ID_POSICAO_VISITANTE
	FROM TB_PARAM_QUALIFY_FROM_STAGE0 WHERE IN_QT_TIMES_QUALIFY = pTotalTeamsQualified AND ID_GRUPO_CASA = 0
	ORDER BY ID_JOGO_MATAXMATA;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	WHILE _numGroup <= pTotalGroups DO

		SET _numTeamsQualified = 1;

		WHILE _numTeamsQualified <= pTotalTeamsQualifiedForGroup DO

			call `arenafifadb`.`spAddTabTempGenerateStage`(pIdCamp, 0, fcGetTimeIDByPosicaoEGrupo(pIdCamp, _numTeamsQualified, _numGroup), NULL);

			SET _numTeamsQualified = _numTeamsQualified + 1;

		END WHILE;

		SET _numGroup = _numGroup + 1;

	END WHILE;
	
	call `arenafifadb`.`spUpdatePositionTimeGenerateStage`(pIdCamp, 1);
	
	call `arenafifadb`.`spAddTimeFromCampeonatoOrigem`(pIdCamp, pCampeonatoOrigem, pPosicaoOrigem);

	call `arenafifadb`.`spUpdatePositionTimeGenerateStage`(pIdCamp, 9);
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _numMatchPlayOff, _position1, _position2;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _teamHomeID = fcGetTimePositionInTabTemp(pIdCamp, _position1);
		SET _teamAwayID = fcGetTimePositionInTabTemp(pIdCamp, _position2);
		
		call `arenafifadb`.`spAddTabelaJogo`(pIdCamp, pIdFase, pDtInicioFase, pInterval, 1, _teamHomeID, _teamAwayID, _numMatchPlayOff, pIdaVolta, TRUE);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateFasePlayOffFromPlayOffOneLeg` $$
CREATE PROCEDURE `spGenerateFasePlayOffFromPlayOffOneLeg`(
	pIdCamp INTEGER,
	pIdFase INTEGER,
	pIdPreviousFase INTEGER,
	pDtInicioFase DATE,
	pInterval INTEGER
)
begin      
	DECLARE _finished INTEGER DEFAULT 0;

	DECLARE _teamHomeIDAux INTEGER DEFAULT 0;
	DECLARE _totalGoalsHome INTEGER DEFAULT 0;
	DECLARE _teamAwayIDAux INTEGER DEFAULT 0;
	DECLARE _totalGoalsAway INTEGER DEFAULT 0;

	DECLARE _teamID1 INTEGER DEFAULT 0;
	DECLARE _teamID2 INTEGER DEFAULT 0;
	DECLARE _position1 INTEGER DEFAULT 0;
	DECLARE _position2 INTEGER DEFAULT 0;
	DECLARE _teamHomeID INTEGER DEFAULT 0;
	DECLARE _teamAwayID INTEGER DEFAULT 0;
	
	DECLARE _numMatchPlayOff INTEGER DEFAULT 1;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT J.ID_TIME_CASA, J.ID_TIME_VISITANTE, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE
	FROM TB_TABELA_JOGO J WHERE J.ID_CAMPEONATO = pIdCamp AND J.ID_FASE = pIdPreviousFase
	ORDER BY J.IN_JOGO_MATAXMATA, J.IN_NUMERO_RODADA, J.ID_TABELA_JOGO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _teamHomeIDAux, _teamAwayIDAux, _totalGoalsHome, _totalGoalsAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _totalGoalsHome > _totalGoalsAway OR _totalGoalsHome = _totalGoalsAway THEN
			SET _teamID1 = _teamHomeIDAux;
		ELSE
			SET _teamID1 = _teamAwayIDAux;
		END IF;
		
		FETCH tabela_cursor INTO _teamHomeIDAux, _teamAwayIDAux, _totalGoalsHome, _totalGoalsAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _totalGoalsHome > _totalGoalsAway OR _totalGoalsHome = _totalGoalsAway THEN
			SET _teamID2 = _teamHomeIDAux;
		ELSE
			SET _teamID2 = _teamAwayIDAux;
		END IF;
		
		SET _position1 = fcGetPositionByTime(pIdCamp, _teamID1);
		SET _position2 = fcGetPositionByTime(pIdCamp, _teamID2);

		IF _position1 < _position2 THEN
			SET _teamHomeID = _teamID1;
			SET _teamAwayID = _teamID2;
		ELSE
			SET _teamHomeID = _teamID2;
			SET _teamAwayID = _teamID1;
		END IF;
		
		call `arenafifadb`.`spAddTabelaJogo`(pIdCamp, pIdFase, pDtInicioFase, pInterval, 1, _teamHomeID, _teamAwayID, _numMatchPlayOff, FALSE, TRUE);
		
		SET _numMatchPlayOff = _numMatchPlayOff + 1;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateFasePlayOffFromPlayOffTwoLegs` $$
CREATE PROCEDURE `spGenerateFasePlayOffFromPlayOffTwoLegs`(
	pIdCamp INTEGER,
	pIdFase INTEGER,
	pIdPreviousFase INTEGER,
	pDtInicioFase DATE,
	pInterval INTEGER
)
begin      
	DECLARE _finished INTEGER DEFAULT 0;

	DECLARE _teamHomeIDAux INTEGER DEFAULT 0;
	DECLARE _totalGoalsHome INTEGER DEFAULT 0;
	DECLARE _teamAwayIDAux INTEGER DEFAULT 0;
	DECLARE _totalGoalsAway INTEGER DEFAULT 0;

	DECLARE _teamID1 INTEGER DEFAULT 0;
	DECLARE _goalsTeam1 INTEGER DEFAULT 0;
	DECLARE _goalsAwayTeam1 INTEGER DEFAULT 0;
	DECLARE _position1 INTEGER DEFAULT 0;
	DECLARE _teamID2 INTEGER DEFAULT 0;
	DECLARE _goalsTeam2 INTEGER DEFAULT 0;
	DECLARE _goalsAwayTeam2 INTEGER DEFAULT 0;
	DECLARE _position2 INTEGER DEFAULT 0;
	DECLARE _teamHomeID INTEGER DEFAULT 0;
	DECLARE _teamAwayID INTEGER DEFAULT 0;
	
	DECLARE _numMatchPlayOff INTEGER DEFAULT 1;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT J.ID_TIME_CASA, J.ID_TIME_VISITANTE, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE
	FROM TB_TABELA_JOGO J WHERE J.ID_CAMPEONATO = pIdCamp AND J.ID_FASE = pIdPreviousFase
	ORDER BY J.IN_JOGO_MATAXMATA, J.IN_NUMERO_RODADA, J.ID_TABELA_JOGO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _teamHomeIDAux, _teamAwayIDAux, _totalGoalsHome, _totalGoalsAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _goalsTeam1 = _totalGoalsHome;
		SET _goalsTeam2 = _totalGoalsAway;
		SET _goalsAwayTeam2 = _totalGoalsAway;
		
		FETCH tabela_cursor INTO _teamHomeIDAux, _teamAwayIDAux, _totalGoalsHome, _totalGoalsAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _goalsTeam1 = _goalsTeam1 + _totalGoalsAway;
		SET _goalsTeam2 = _goalsTeam2 + _totalGoalsHome;
		SET _goalsAwayTeam1 = _totalGoalsAway;
		
		IF _goalsTeam1 > _goalsTeam2 THEN
			SET _teamID1 = _teamAwayIDAux;
		ELSEIF _goalsTeam1 < _goalsTeam2 THEN
			SET _teamID1 = _teamHomeIDAux;
		ELSEIF _goalsTeam1 = _goalsTeam2 AND _goalsAwayTeam1 > _goalsAwayTeam2 THEN
			SET _teamID1 = _teamAwayIDAux;
		ELSEIF _goalsTeam1 = _goalsTeam2 AND _goalsAwayTeam1 < _goalsAwayTeam2 THEN
			SET _teamID1 = _teamHomeIDAux;
		END IF;
		
		FETCH tabela_cursor INTO _teamHomeIDAux, _teamAwayIDAux, _totalGoalsHome, _totalGoalsAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _goalsTeam1 = _totalGoalsHome;
		SET _goalsTeam2 = _totalGoalsAway;
		SET _goalsAwayTeam2 = _totalGoalsAway;
		
		FETCH tabela_cursor INTO _teamHomeIDAux, _teamAwayIDAux, _totalGoalsHome, _totalGoalsAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _goalsTeam1 = _goalsTeam1 + _totalGoalsAway;
		SET _goalsTeam2 = _goalsTeam2 + _totalGoalsHome;
		SET _goalsAwayTeam1 = _totalGoalsAway;
		
		IF _goalsTeam1 > _goalsTeam2 THEN
			SET _teamID2 = _teamAwayIDAux;
		ELSEIF _goalsTeam1 < _goalsTeam2 THEN
			SET _teamID2 = _teamHomeIDAux;
		ELSEIF _goalsTeam1 = _goalsTeam2 AND _goalsAwayTeam1 > _goalsAwayTeam2 THEN
			SET _teamID2 = _teamAwayIDAux;
		ELSEIF _goalsTeam1 = _goalsTeam2 AND _goalsAwayTeam1 < _goalsAwayTeam2 THEN
			SET _teamID2 = _teamHomeIDAux;
		END IF;
		
		SET _position1 = fcGetPositionByTime(pIdCamp, _teamID1);
		SET _position2 = fcGetPositionByTime(pIdCamp, _teamID2);

		IF _position1 < _position2 THEN
			SET _teamHomeID = _teamID1;
			SET _teamAwayID = _teamID2;
		ELSE
			SET _teamHomeID = _teamID2;
			SET _teamAwayID = _teamID1;
		END IF;
		
		call `arenafifadb`.`spAddTabelaJogo`(pIdCamp, pIdFase, pDtInicioFase, pInterval, 1, _teamHomeID, _teamAwayID, _numMatchPlayOff, TRUE, TRUE);
		
		SET _numMatchPlayOff = _numMatchPlayOff + 1;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
End$$
DELIMITER ;

