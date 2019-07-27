USE `arenafifadb_staging`;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateEndOfTemporadaH2H` $$
CREATE PROCEDURE `spCalculateEndOfTemporadaH2H`(pIdTemp INTEGER)
Begin
	DECLARE _idNewTemp INTEGER DEFAULT NULL;

	UPDATE TB_CAMPEONATO SET IN_CAMPEONATO_ATIVO = FALSE 
	WHERE SG_TIPO_CAMPEONATO IN ("DIV1", "DIV2", "DIV3", "DIV4", "CPGL", "CPSA", "MDCL", "CPDM", "ERCP") AND IN_CAMPEONATO_ATIVO = TRUE;
	
	SET _idNewTemp = fcAddNewTemporadaByFimOldOne(CONCAT(pIdTemp, " ª Temporada"), CURDATE());
	
	call `arenafifadb_staging`.`spCalculateAllFasesEndOfTemporadaH2H`(pIdTemp, _idNewTemp);
	
	SELECT _idNewTemp as NewTemporadaID, NM_TEMPORADA as NewTemporadaName FROM TB_TEMPORADA
	WHERE ID_TEMPORADA = _idNewTemp;

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateAllFasesEndOfTemporadaH2H` $$
CREATE PROCEDURE `spCalculateAllFasesEndOfTemporadaH2H`(pIdTemp INTEGER, pIdTempNew INTEGER)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _sgCampLessH2H VARCHAR(50) DEFAULT "CDA,LFUT,FUT1,FUT2,CFUT,PRO1,PRO2,CPRO";
	DECLARE _sgLigasH2H VARCHAR(50) DEFAULT "DIV1,DIV2,DIV3,DIV4";
	DECLARE _sgCamp VARCHAR(4) DEFAULT NULL;
	DECLARE _count INTEGER DEFAULT 0;
	DECLARE _idCamp INTEGER DEFAULT 0;
	DECLARE _idCampAux INTEGER DEFAULT 0;
	DECLARE _ptsVitoria INTEGER DEFAULT NULL;
	DECLARE _ptsEmpate INTEGER DEFAULT NULL;
	DECLARE _idUsuHome INTEGER DEFAULT NULL;
	DECLARE _idUsuAway INTEGER DEFAULT NULL;
	DECLARE _qtGolsHome INTEGER DEFAULT NULL;
	DECLARE _qtGolsAway INTEGER DEFAULT NULL;
	DECLARE _sumPoints INTEGER DEFAULT 0;
	DECLARE _sumEmpate INTEGER DEFAULT 0;
	DECLARE _sumVitoria INTEGER DEFAULT 0;
	DECLARE _sumLiga INTEGER DEFAULT 0;
	DECLARE _sumCopa INTEGER DEFAULT 0;


	#Calculando as Fases de Classificação....
	DECLARE tabela_cursor CURSOR FOR
		SELECT J.ID_CAMPEONATO, J.ID_USUARIO_TIME_CASA, J.ID_USUARIO_TIME_VISITANTE, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, C.SG_TIPO_CAMPEONATO 
		FROM TB_TABELA_JOGO J, TB_TIME T1 , TB_TIME T2, TB_USUARIO TU1, TB_USUARIO TU2, TB_CLASSIFICACAO TC1, TB_CLASSIFICACAO TC2, TB_CAMPEONATO C 
		WHERE C.ID_TEMPORADA = pIdTemp
		AND J.ID_FASE = 0
		AND FIND_IN_SET(C.SG_TIPO_CAMPEONATO, _sgCampLessH2H) = 0
		AND C.ID_CAMPEONATO = J.ID_CAMPEONATO 
		AND C.ID_CAMPEONATO = TC1.ID_CAMPEONATO 
		AND C.ID_CAMPEONATO = TC2.ID_CAMPEONATO 
		AND J.ID_CAMPEONATO = TC1.ID_CAMPEONATO 
		AND J.ID_CAMPEONATO = TC2.ID_CAMPEONATO 
		AND J.ID_TIME_CASA = T1.ID_TIME 
		AND J.ID_TIME_VISITANTE = T2.ID_TIME 
		AND J.ID_USUARIO_TIME_CASA = TU1.ID_USUARIO 
		AND J.ID_USUARIO_TIME_VISITANTE = TU2.ID_USUARIO 
		AND J.ID_TIME_CASA = TC1.ID_TIME 
		AND J.ID_TIME_VISITANTE = TC2.ID_TIME 
		AND J.DT_EFETIVACAO_JOGO is not null
		ORDER BY J.ID_CAMPEONATO, J.ID_FASE, J.DT_TABELA_INICIO_JOGO, J.DS_HORA_JOGO, J.ID_TABELA_JOGO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	DELETE FROM TB_HISTORICO_ARTILHARIA WHERE ID_TEMPORADA >= pIdTemp;
	DELETE FROM TB_HISTORICO_CONQUISTA WHERE ID_TEMPORADA >= pIdTemp;
	DELETE FROM TB_HISTORICO_TEMPORADA WHERE ID_TEMPORADA >= pIdTemp;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idCamp, _idUsuHome, _idUsuAway, _qtGolsHome, _qtGolsAway, _sgCamp;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _idCamp <> _idCampAux THEN
			SELECT PT_VITORIAS_FASE1, PT_EMPATES_FASE1 into _ptsVitoria, _ptsEmpate
			FROM TB_PONTUACAO_CAMPEONATO WHERE SG_TIPO_CAMPEONATO = _sgCamp;
			
			IF _ptsVitoria IS NULL THEN
				SET _ptsVitoria = 0;
				SET _ptsEmpate = 0;
			END IF;
		
			SET _idCampAux = _idCamp;
		END IF;
		
		
		SELECT count(1) into _count FROM TB_HISTORICO_TEMPORADA WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsuHome;
		IF _count = 0 THEN
			call spAddHistoricoTemporadaH2H(pIdTemp, _idUsuHome, NULL);
		END IF;
	
		SET _sumPoints = 0;
		SET _sumEmpate = 0;
		SET _sumVitoria = 0;
		
		IF _qtGolsHome = _qtGolsAway THEN
			SET _sumPoints = _ptsEmpate;
			SET _sumEmpate = _ptsEmpate;
		ELSEIF _qtGolsHome > _qtGolsAway THEN
			SET _sumPoints = _ptsVitoria;
			SET _sumVitoria = _ptsVitoria;
		END IF;
		
		SET _sumLiga = 0;
		SET _sumCopa = 0;
		
		IF INSTR(_sgLigasH2H,_sgCamp)> 0  THEN
			SET _sumLiga = _sumPoints;
		ELSE
			SET _sumCopa = _sumPoints;
		END IF;
		
		UPDATE TB_HISTORICO_TEMPORADA
		SET PT_EMPATES_FASE1 = (PT_EMPATES_FASE1+_sumEmpate),
		    PT_VITORIAS_FASE1 = (PT_VITORIAS_FASE1+_sumVitoria),
			PT_COPAS = (PT_COPAS+_sumCopa),
			PT_LIGAS = (PT_LIGAS+_sumLiga)
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsuHome;


		SELECT count(1) into _count FROM TB_HISTORICO_TEMPORADA WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsuAway;
		IF _count = 0 THEN
			call spAddHistoricoTemporadaH2H(pIdTemp, _idUsuAway, NULL);
		END IF;
		
		SET _sumPoints = 0;
		SET _sumEmpate = 0;
		SET _sumVitoria = 0;
		
		IF _qtGolsHome = _qtGolsAway THEN
			SET _sumPoints = _ptsEmpate;
			SET _sumEmpate = _ptsEmpate;
		ELSEIF _qtGolsHome < _qtGolsAway THEN
			SET _sumPoints = _ptsVitoria;
			SET _sumVitoria = _ptsVitoria;
		END IF;
		
		SET _sumLiga = 0;
		SET _sumCopa = 0;
		
		IF INSTR(_sgLigasH2H,_sgCamp)> 0  THEN
			SET _sumLiga = _sumPoints;
		ELSE
			SET _sumCopa = _sumPoints;
		END IF;
		
		UPDATE TB_HISTORICO_TEMPORADA
		SET PT_EMPATES_FASE1 = (PT_EMPATES_FASE1+_sumEmpate),
		    PT_VITORIAS_FASE1 = (PT_VITORIAS_FASE1+_sumVitoria),
			PT_COPAS = (PT_COPAS+_sumCopa),
			PT_LIGAS = (PT_LIGAS+_sumLiga)
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsuAway;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	#Calculando fases playoff....
	call spCalculateFasePlayoffH2H(pIdTemp, _sgCampLessH2H, _sgLigasH2H);

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateFasePlayoffH2H` $$
CREATE PROCEDURE `spCalculateFasePlayoffH2H`(pIdTemp INTEGER, pSgCampLessH2H VARCHAR(50), pSgLigas VARCHAR(50))
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _sgCamp VARCHAR(4) DEFAULT NULL;
	DECLARE _idCamp INTEGER DEFAULT 0;
	DECLARE _idCampAux INTEGER DEFAULT 0;
	DECLARE _ptsCalssifFase2 INTEGER DEFAULT NULL;
	DECLARE _idNextFase INTEGER DEFAULT NULL;
	DECLARE _ptsRound16 INTEGER DEFAULT NULL;
	DECLARE _ptsFase2 INTEGER DEFAULT NULL;
	DECLARE _ptsQuarter INTEGER DEFAULT NULL;
	DECLARE _ptsSemi INTEGER DEFAULT NULL;
	DECLARE _ptsChampion INTEGER DEFAULT NULL;
	DECLARE _ptsVice INTEGER DEFAULT NULL;
	DECLARE _inIdaEVolta TINYINT DEFAULT NULL;
	DECLARE _idPreviousTemp TINYINT DEFAULT NULL;
	DECLARE _qtMaxGols INTEGER DEFAULT NULL;


	DECLARE tabela_cursor CURSOR FOR
		SELECT C.ID_CAMPEONATO, C.SG_TIPO_CAMPEONATO, C.IN_SISTEMA_IDA_VOLTA FROM TB_CAMPEONATO C 
		WHERE C.ID_TEMPORADA = pIdTemp AND FIND_IN_SET(C.SG_TIPO_CAMPEONATO, pSgCampLessH2H) = 0 ORDER BY C.ID_CAMPEONATO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idCamp, _sgCamp, _inIdaEVolta;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _idCamp <> _idCampAux THEN
			SELECT PT_CLASSIF_FASE2, PT_FASE2, PT_OITAVAS, PT_QUARTAS, PT_SEMIS, PT_VICECAMPEAO, PT_CAMPEAO 
			  into _ptsCalssifFase2, _ptsFase2, _ptsRound16, _ptsQuarter, _ptsSemi, _ptsVice, _ptsChampion
			FROM TB_PONTUACAO_CAMPEONATO WHERE SG_TIPO_CAMPEONATO = _sgCamp;
			
			IF _ptsCalssifFase2 IS NULL THEN
				SET _ptsCalssifFase2 = 0;
				SET _ptsFase2 = 0;
				SET _ptsRound16 = 0;
				SET _ptsQuarter = 0;
				SET _ptsSemi = 0;
				SET _ptsVice = 0;
				SET _ptsChampion = 0;
			END IF;
		
			SET _idCampAux = _idCamp;
		END IF;
		
		SELECT ID_FASE into _idNextFase FROM TB_FASE_CAMPEONATO WHERE ID_CAMPEONATO = _idCamp AND ID_FASE > 0 ORDER BY IN_ORDENACAO LIMIT 1;
		
		#Calculando passagens para a próxima fase....
		call spCalculatePassNextFaseH2H(pIdTemp, _idCamp, _sgCamp, _idNextFase, _ptsCalssifFase2, pSgLigas);

		#Calculando Fases Seguintes de Playoff....
		#2a Fase
		call spCalculateEachFasePlayoffH2H(pIdTemp, _idCamp, _sgCamp, 1, "FASE2", _ptsFase2, pSgLigas);
		
		#Oitavas
		call spCalculateEachFasePlayoffH2H(pIdTemp, _idCamp, _sgCamp, 2, "OITAVAS", _ptsRound16, pSgLigas);

		#Quartas
		call spCalculateEachFasePlayoffH2H(pIdTemp, _idCamp, _sgCamp, 3, "QUARTAS", _ptsQuarter, pSgLigas);

		#Semi
		call spCalculateEachFasePlayoffH2H(pIdTemp, _idCamp, _sgCamp, 4, "SEMI", _ptsSemi, pSgLigas);

		#Campeao e Vice
		IF _inIdaEVolta = false THEN
			call spCalculateChampionAndViceH2H(pIdTemp, _idCamp, _sgCamp, _ptsChampion, _ptsVice, pSgLigas, 0, "1");
		ELSE
			call spCalculateChampionAndViceH2H(pIdTemp, _idCamp, _sgCamp, _ptsChampion, _ptsVice, pSgLigas, 1, "1,2");
		END IF;
		
		#Artilharia
		SELECT X.QT_GOLS_MARCADOS INTO _qtMaxGols
		FROM (SELECT J.ID_GOLEADOR, SUM(J.QT_GOLS) as QT_GOLS_MARCADOS, J.ID_TIME
		FROM TB_GOLEADOR_JOGO J 
		WHERE J.ID_CAMPEONATO = _idCamp
		GROUP BY J.ID_GOLEADOR, J.ID_TIME) X, TB_GOLEADOR G, TB_TIME T
		WHERE X.ID_GOLEADOR = G.ID_GOLEADOR
		AND X.ID_TIME = G.ID_TIME
		AND G.ID_TIME = T.ID_TIME
		ORDER BY X.QT_GOLS_MARCADOS DESC, G.NM_GOLEADOR LIMIT 1;

		call spCalculateScorersH2H(pIdTemp, _idCamp, _qtMaxGols);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	UPDATE TB_HISTORICO_TEMPORADA 
	SET PT_TOTAL = (PT_CAMPEAO+PT_VICECAMPEAO+PT_SEMIS+PT_QUARTAS+PT_OITAVAS+PT_CLASSIF_FASE2+PT_VITORIAS_FASE1+PT_EMPATES_FASE1),
	    PT_TOTAL_TEMPORADA = (PT_LIGAS+PT_COPAS)
	WHERE ID_TEMPORADA = pIdTemp;
	
	SELECT ID_TEMPORADA into _idPreviousTemp FROM TB_HISTORICO_TEMPORADA  WHERE ID_TEMPORADA < pIdTemp ORDER BY ID_TEMPORADA DESC LIMIT 1;
	
	#Atualizando Aproveitamento dos técnicos....
	call spPrepareToCalculatePerformanceTecnicosH2H(pIdTemp, _idPreviousTemp, pSgLigas);
	
	#Atualizando Historico todos técnicos....
	call spAddAllTecnicosHistoricoTemporadaH2H(pIdTemp);
	
	#Atualizando o Hall da Fama....
	call spUpdateHallOfFameH2H(pIdTemp);
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spPrepareToCalculatePerformanceTecnicosH2H` $$
CREATE PROCEDURE `spPrepareToCalculatePerformanceTecnicosH2H`(
	pIdTemp INTEGER, 
	pIdPreviousTemp INTEGER, 
	pSgLigas VARCHAR(50)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu INTEGER DEFAULT 0;
	DECLARE _totPontos INTEGER DEFAULT 0;
	DECLARE _totTemp INTEGER DEFAULT 0;
	DECLARE _totPreviusTemp INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT ID_USUARIO, PT_TOTAL_TEMPORADA FROM TB_HISTORICO_TEMPORADA  WHERE ID_TEMPORADA = pIdTemp ORDER BY ID_USUARIO;
 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _totTemp;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SELECT PT_TOTAL into _totPreviusTemp FROM TB_HISTORICO_TEMPORADA WHERE ID_TEMPORADA = pIdPreviousTemp AND ID_USUARIO = _idUsu;
		IF _totPreviusTemp IS NULL THEN
			UPDATE TB_HISTORICO_TEMPORADA
			SET PT_TOTAL_TEMPORADA_ANTERIOR = PT_TOTAL_TEMPORADA
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu;
		ELSE
			UPDATE TB_HISTORICO_TEMPORADA
			SET PT_TOTAL_TEMPORADA_ANTERIOR = _totPreviusTemp, PT_TOTAL = (PT_TOTAL+_totPreviusTemp)
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu;
		END IF;
		
		call `arenafifadb_staging`.`spCalculatePerformanceTecnicosH2H`(pIdTemp, _idUsu, pSgLigas);
		
		call `arenafifadb_staging`.`spCalculatePerformanceGeralTecnicosH2H`(pIdTemp, _idUsu, pSgLigas);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddAllTecnicosHistoricoTemporadaH2H` $$
CREATE PROCEDURE `spAddAllTecnicosHistoricoTemporadaH2H`(
	pIdTemp INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu INTEGER DEFAULT 0;
	DECLARE _idTemp INTEGER DEFAULT 0;
	DECLARE _total INTEGER DEFAULT 0;
	DECLARE _totLstNegra INTEGER DEFAULT 0;
	DECLARE _apGeral DECIMAL(5,2) DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT ID_USUARIO, max(ID_TEMPORADA) FROM TB_HISTORICO_TEMPORADA
		WHERE ID_USUARIO NOT IN (SELECT ID_USUARIO FROM TB_HISTORICO_TEMPORADA WHERE ID_Temporada = pIdTemp)
		GROUP BY ID_USUARIO;
 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _idTemp;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SELECT PT_TOTAL, PC_APROVEITAMENTO_GERAL, QT_LSTNEGRA into _total, _apGeral, _totLstNegra
		FROM TB_HISTORICO_TEMPORADA WHERE ID_TEMPORADA = _idTemp AND ID_USUARIO = _idUsu;
		
		IF (_total IS NOT NULL) THEN

			UPDATE TB_HISTORICO_TEMPORADA
			SET PT_TOTAL = _total, PC_APROVEITAMENTO_GERAL = _apGeral, QT_LSTNEGRA = _totLstNegra, IN_ACESSO_TEMP_ATUAL = 0
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu;
		
		ELSE
		
			INSERT INTO TB_HISTORICO_TEMPORADA (ID_TEMPORADA, ID_USUARIO, IN_ACESSO_TEMP_ATUAL, PT_CAMPEAO, PT_VICECAMPEAO, PT_SEMIS, PT_QUARTAS, PT_OITAVAS, PT_CLASSIF_FASE2, 
												PT_VITORIAS_FASE1, PT_EMPATES_FASE1, IN_POSICAO_ATUAL, PT_LIGAS, PT_COPAS, PT_TOTAL_TEMPORADA, QT_JOGOS_TEMPORADA, 
												QT_TOTAL_PONTOS_TEMPORADA, QT_TOTAL_VITORIAS_TEMPORADA, QT_TOTAL_EMPATES_TEMPORADA, PC_APROVEITAMENTO_TEMPORADAS, 
												IN_REBAIXADO_TEMP_ANTERIOR, QT_LSTNEGRA, PT_TOTAL, PT_TOTAL_TEMPORADA_ANTERIOR, IN_POSICAO_ANTERIOR, 
												QT_JOGOS_GERAL, QT_TOTAL_PONTOS_GERAL, QT_TOTAL_VITORIAS_GERAL, QT_TOTAL_EMPATES_GERAL, PC_APROVEITAMENTO_GERAL)
			SELECT pIdTemp, _idUsu, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, COALESCE(T.PT_TOTAL,0), COALESCE(T.PT_TOTAL_TEMPORADA_ANTERIOR,0), 
			       COALESCE(T.IN_POSICAO_ANTERIOR,0), COALESCE(T.QT_JOGOS_GERAL,0), COALESCE(T.QT_TOTAL_PONTOS_GERAL,0), COALESCE(T.QT_TOTAL_VITORIAS_GERAL,0), 
				   COALESCE(T.QT_TOTAL_EMPATES_GERAL,0), COALESCE(T.PC_APROVEITAMENTO_GERAL,0)
			FROM TB_HISTORICO_TEMPORADA T
			WHERE T.ID_TEMPORADA < pIdTemp AND T.ID_USUARIO = _idUsu ORDER BY T.ID_TEMPORADA DESC limit 1;
			
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateHallOfFameH2H` $$
CREATE PROCEDURE `spUpdateHallOfFameH2H`(
	pIdTemp INTEGER
)
Begin
	call spUpdateHallOfFameLstNegraH2H(pIdTemp);
	call spUpdateHallOfFameRelegatedH2H(pIdTemp);

	UPDATE TB_HISTORICO_TEMPORADA
	SET IN_REBAIXADO_TEMP_ANTERIOR = 0 
	WHERE ID_TEMPORADA = pIdTemp AND IN_REBAIXADO_TEMP_ANTERIOR IS NULL;
	
	UPDATE TB_HISTORICO_TEMPORADA
	SET IN_ACESSO_TEMP_ATUAL = 0
	WHERE ID_TEMPORADA = pIdTemp;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateHallOfFameRelegatedH2H` $$
CREATE PROCEDURE `spUpdateHallOfFameRelegatedH2H`(
	pIdTemp INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _IdCamp INTEGER DEFAULT 0;
	DECLARE _qtTimes INTEGER DEFAULT 0;
	DECLARE _qtTimesRelegated INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
	SELECT ID_CAMPEONATO, QT_TIMES, QT_TIMES_REBAIXADOS FROM TB_CAMPEONATO WHERE ID_TEMPORADA = pIdTemp AND SG_TIPO_CAMPEONATO IN ("DIV1", "DIV2")
	ORDER BY ID_CAMPEONATO DESC;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _IdCamp, _qtTimes, _qtTimesRelegated;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _qtTimesRelegated > 0 THEN
		
			call `arenafifadb_staging`.`spUpdateHallOfFameRelegatedByDivisionH2H`(pIdTemp, _IdCamp, _qtTimes, _qtTimesRelegated);
		
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateHallOfFameRelegatedByDivisionH2H` $$
CREATE PROCEDURE `spUpdateHallOfFameRelegatedByDivisionH2H`(
	pIdTemp INTEGER,
	pIdCamp INTEGER,
	pQtTimes INTEGER,
	pQtTimesRelegated INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _IdUsu INTEGER DEFAULT 0;
	DECLARE _count INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT U.ID_USUARIO
		FROM TB_CLASSIFICACAO C, TB_TIME T, TB_USUARIO_TIME UT, TB_USUARIO U 
		WHERE C.ID_CAMPEONATO = pIdCamp
		AND C.ID_TIME = T.ID_TIME
		AND C.ID_CAMPEONATO = UT.ID_CAMPEONATO
		AND T.ID_TIME = UT.ID_TIME 
		AND UT.ID_USUARIO = U.ID_USUARIO 
		AND UT.DT_VIGENCIA_FIM IS NULL
		ORDER BY C.QT_PONTOS_GANHOS DESC, QT_VITORIAS DESC, (QT_GOLS_PRO-QT_GOLS_CONTRA) DESC, QT_GOLS_PRO DESC, QT_GOLS_CONTRA, T.NM_TIME;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _IdUsu;
		
		SET _count = _count + 1;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF (pQtTimes-_count) < pQtTimesRelegated THEN
		
			UPDATE TB_HISTORICO_TEMPORADA
			SET IN_REBAIXADO_TEMP_ANTERIOR = 1
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu;
		
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateHallOfFameLstNegraH2H` $$
CREATE PROCEDURE `spUpdateHallOfFameLstNegraH2H`(
	pIdTemp INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _IdUsu INTEGER DEFAULT 0;
	DECLARE _qtTotalPG INTEGER DEFAULT 0;
	DECLARE _qtTotalPGAux INTEGER DEFAULT -1;
	DECLARE _qtLstNegra INTEGER DEFAULT NULL;
	DECLARE _count INTEGER DEFAULT 0;
	DECLARE _countAux INTEGER DEFAULT 1;

	DECLARE tabela_cursor CURSOR FOR
	SELECT ID_USUARIO, PT_TOTAL FROM TB_HISTORICO_TEMPORADA WHERE ID_TEMPORADA = pIdTemp
	ORDER BY PT_TOTAL DESC;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _IdUsu, _qtTotalPG;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _qtTotalPGAux <> _qtTotalPG THEN
		
			SET _qtTotalPGAux = _qtTotalPG;
			SET _count = _count + _countAux;
			SET _countAux = 1;
		
		ELSE
		
			SET _countAux = _countAux + 1;
		
		END IF;
		
		SELECT PT_TOTAL into _qtLstNegra FROM TB_LISTA_NEGRA 
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _IdUsu;
		
		IF _qtLstNegra IS NULL THEN
			SET _qtLstNegra = 0;
		END IF;
		
		UPDATE TB_HISTORICO_TEMPORADA
		SET IN_POSICAO_ATUAL = _count,
			QT_LSTNEGRA = _qtLstNegra
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _IdUsu;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculatePerformanceTecnicosH2H` $$
CREATE PROCEDURE `spCalculatePerformanceTecnicosH2H`(
	pIdTemp INTEGER, 
	pIdUsu INTEGER, 
	pSgLigas VARCHAR(50)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _IdUsuHome INTEGER DEFAULT 0;
	DECLARE _IdUsuAway INTEGER DEFAULT 0;
	DECLARE _sumGolsHome INTEGER DEFAULT 0;
	DECLARE _sumGolsAway INTEGER DEFAULT 0;
	DECLARE _qtJogosTemp INTEGER DEFAULT 0;
	DECLARE _qtdVitorias INTEGER DEFAULT 0;
	DECLARE _qtdEmpates INTEGER DEFAULT 0;
	DECLARE _qtdPontosGanhos INTEGER DEFAULT 0;
	DECLARE _totPontosTemporada INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
	SELECT J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, J.ID_USUARIO_TIME_CASA, J.ID_USUARIO_TIME_VISITANTE
	 FROM TB_TABELA_JOGO J, TB_CAMPEONATO C, TB_TEMPORADA T WHERE T.ID_TEMPORADA = pIdTemp
	 AND (J.ID_USUARIO_TIME_CASA = pIdUsu OR J.ID_USUARIO_TIME_VISITANTE = pIdUsu)
	 AND J.ID_CAMPEONATO = C.ID_CAMPEONATO AND C.ID_TEMPORADA = T.ID_TEMPORADA AND C.SG_TIPO_CAMPEONATO NOT IN (pSgLigas) 
	 ORDER BY J.ID_TABELA_JOGO;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _sumGolsHome, _sumGolsAway, _IdUsuHome, _IdUsuAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _qtJogosTemp = _qtJogosTemp + 1;
		
		IF _sumGolsHome = _sumGolsAway THEN
		
			SET _qtdEmpates = _qtdEmpates + 1;
		
		ELSEIF (pIdUsu = _IdUsuHome) AND (_sumGolsHome > _sumGolsAway) THEN
		
			SET _qtdVitorias = _qtdVitorias + 1;
		
		ELSEIF (pIdUsu = _IdUsuAway) AND (_sumGolsAway > _sumGolsHome) THEN
		
			SET _qtdVitorias = _qtdVitorias + 1;
		
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	SET _totPontosTemporada = _qtJogosTemp * 3;
	SET _qtdPontosGanhos = (_qtdVitorias * 3) + _qtdEmpates;
	
	UPDATE TB_HISTORICO_TEMPORADA
	SET QT_JOGOS_TEMPORADA = _qtJogosTemp,
	    QT_TOTAL_VITORIAS_TEMPORADA = _qtdVitorias,
		QT_TOTAL_EMPATES_TEMPORADA = _qtdEmpates,
		QT_TOTAL_PONTOS_TEMPORADA = _totPontosTemporada,
		PC_APROVEITAMENTO_TEMPORADAS = ( (_qtdPontosGanhos * 100) /  _totPontosTemporada )
	WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculatePerformanceGeralTecnicosH2H` $$
CREATE PROCEDURE `spCalculatePerformanceGeralTecnicosH2H`(
	pIdTemp INTEGER, 
	pIdUsu INTEGER, 
	pSgLigas VARCHAR(50)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _IdUsuHome INTEGER DEFAULT 0;
	DECLARE _IdUsuAway INTEGER DEFAULT 0;
	DECLARE _sumGolsHome INTEGER DEFAULT 0;
	DECLARE _sumGolsAway INTEGER DEFAULT 0;
	DECLARE _qtJogosGeral INTEGER DEFAULT 0;
	DECLARE _qtdVitoriasGeral INTEGER DEFAULT 0;
	DECLARE _qtdEmpatesGeral INTEGER DEFAULT 0;
	DECLARE _qtdPontosGanhosGeral INTEGER DEFAULT 0;
	DECLARE _totPontosGeral INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
	SELECT J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, J.ID_USUARIO_TIME_CASA, J.ID_USUARIO_TIME_VISITANTE
	 FROM TB_TABELA_JOGO J, TB_CAMPEONATO C, TB_TEMPORADA T WHERE T.ID_TEMPORADA <= pIdTemp
	 AND (J.ID_USUARIO_TIME_CASA = pIdUsu OR J.ID_USUARIO_TIME_VISITANTE = pIdUsu)
	 AND J.ID_CAMPEONATO = C.ID_CAMPEONATO AND C.ID_TEMPORADA = T.ID_TEMPORADA AND C.SG_TIPO_CAMPEONATO NOT IN (pSgLigas) 
	 ORDER BY J.ID_TABELA_JOGO;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _sumGolsHome, _sumGolsAway, _IdUsuHome, _IdUsuAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _qtJogosGeral = _qtJogosGeral + 1;
		
		IF _sumGolsHome = _sumGolsAway THEN
		
			SET _qtdEmpatesGeral = _qtdEmpatesGeral + 1;
		
		ELSEIF (pIdUsu = _IdUsuHome) AND (_sumGolsHome > _sumGolsAway) THEN
		
			SET _qtdVitoriasGeral = _qtdVitoriasGeral + 1;
		
		ELSEIF (pIdUsu = _IdUsuAway) AND (_sumGolsAway > _sumGolsHome) THEN
		
			SET _qtdVitoriasGeral = _qtdVitoriasGeral + 1;
		
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	SET _totPontosGeral = _qtJogosGeral * 3;
	SET _qtdPontosGanhosGeral = (_qtdVitoriasGeral * 3) + _qtdEmpatesGeral;
	
	UPDATE TB_HISTORICO_TEMPORADA
	SET QT_JOGOS_GERAL = _qtJogosGeral,
	    QT_TOTAL_VITORIAS_GERAL = _qtdVitoriasGeral,
		QT_TOTAL_EMPATES_GERAL = _qtdEmpatesGeral,
		QT_TOTAL_PONTOS_GERAL = _totPontosGeral,
		PC_APROVEITAMENTO_GERAL = ( (_qtdPontosGanhosGeral * 100) /  _totPontosGeral )
	WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculatePassNextFaseH2H` $$
CREATE PROCEDURE `spCalculatePassNextFaseH2H`(
	pIdTemp INTEGER, 
	pIdCamp INTEGER, 
	pSgCamp VARCHAR(4), 
	pIdNextFase INTEGER, 
	pPtsCalssifFase2 INTEGER, 
	pSgLigas VARCHAR(50)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu1 INTEGER DEFAULT 0;
	DECLARE _idUsu2 INTEGER DEFAULT 0;
	DECLARE _sumLiga INTEGER DEFAULT 0;
	DECLARE _sumCopa INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT TU1.ID_USUARIO as IDUSU1, TU2.ID_USUARIO as IDUSU2
		 FROM TB_TABELA_JOGO J, TB_USUARIO TU1, TB_USUARIO TU2
		 WHERE J.ID_CAMPEONATO =  pIdCamp
		 AND J.ID_FASE = pIdNextFase
		 AND J.IN_NUMERO_RODADA = 1 
		 AND J.DT_EFETIVACAO_JOGO IS NOT NULL
		 AND J.ID_USUARIO_TIME_CASA = TU1.ID_USUARIO
		 AND J.ID_USUARIO_TIME_VISITANTE = TU2.ID_USUARIO
		 ORDER BY J.DT_TABELA_INICIO_JOGO, J.DS_HORA_JOGO, J.ID_TABELA_JOGO;
 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu1, _idUsu2;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _sumLiga = 0;
		SET _sumCopa = 0;
		
		IF pSgCamp IN (pSgLigas) THEN
			SET _sumLiga = pPtsCalssifFase2;
		ELSE
			SET _sumCopa = pPtsCalssifFase2;
		END IF;
		
		UPDATE TB_HISTORICO_TEMPORADA
		SET PT_CLASSIF_FASE2 = (PT_CLASSIF_FASE2+pPtsCalssifFase2),
			PT_COPAS = (PT_COPAS+_sumCopa),
			PT_LIGAS = (PT_LIGAS+_sumLiga)
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);

	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateChampionAndViceH2H` $$
CREATE PROCEDURE `spCalculateChampionAndViceH2H`(
	pIdTemp INTEGER, 
	pIdCamp INTEGER, 
	pSgCamp VARCHAR(4), 
	pPtsChampion INTEGER, 
	pPtsVice INTEGER, 
	pSgLigas VARCHAR(50),
	pInIdaEVolta INTEGER,
	pNumRodadas VARCHAR(5)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu1 INTEGER DEFAULT 0;
	DECLARE _idUsu2 INTEGER DEFAULT 0;
	DECLARE _sumLiga INTEGER DEFAULT 0;
	DECLARE _sumCopa INTEGER DEFAULT 0;
	DECLARE _QtdGolsHome INTEGER DEFAULT 0;
	DECLARE _QtdGolsAway INTEGER DEFAULT 0;
	DECLARE _IdTimeHome INTEGER DEFAULT 0;
	DECLARE _IdTimeAway INTEGER DEFAULT 0;
	DECLARE _sumGolsTime1 INTEGER DEFAULT 0;
	DECLARE _sumGolsTime2 INTEGER DEFAULT 0;
	DECLARE _sumGolsAwayTime1 INTEGER DEFAULT 0;
	DECLARE _sumGolsAwayTime2 INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT TU1.ID_USUARIO as IDUSU1, TU2.ID_USUARIO as IDUSU2, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, J.ID_TIME_CASA, J.ID_TIME_VISITANTE
		 FROM TB_TABELA_JOGO J, TB_USUARIO TU1, TB_USUARIO TU2
		 WHERE J.ID_CAMPEONATO =  pIdCamp
		 AND J.ID_FASE = 5
		 AND J.IN_NUMERO_RODADA IN (pNumRodadas)
		 AND J.DT_EFETIVACAO_JOGO IS NOT NULL
		 AND J.ID_USUARIO_TIME_CASA = TU1.ID_USUARIO
		 AND J.ID_USUARIO_TIME_VISITANTE = TU2.ID_USUARIO
		 ORDER BY J.IN_JOGO_MATAXMATA, J.IN_NUMERO_RODADA, J.DT_TABELA_INICIO_JOGO, J.DS_HORA_JOGO, J.ID_TABELA_JOGO;
 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu1, _idUsu2, _QtdGolsHome, _QtdGolsAway, _IdTimeHome, _IdTimeAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _sumLiga = 0;
		SET _sumCopa = 0;
		
		IF pInIdaEVolta = 0 THEN
		
			IF _QtdGolsHome > _QtdGolsAway OR _QtdGolsHome = _QtdGolsAway THEN
			
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsChampion;
				ELSE
					SET _sumCopa = pPtsChampion;
				END IF;
				
				UPDATE TB_HISTORICO_TEMPORADA
				SET PT_CAMPEAO = (PT_CAMPEAO+pPtsChampion),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu1;

				
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsVice;
				ELSE
					SET _sumCopa = pPtsVice;
				END IF;
				
				UPDATE TB_HISTORICO_TEMPORADA
				SET PT_VICECAMPEAO = (PT_VICECAMPEAO+pPtsVice),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu2;
				
				INSERT INTO TB_HISTORICO_CONQUISTA (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO_CAMPEAO, ID_TIME_CAMPEAO, ID_USUARIO_VICECAMPEAO, ID_TIME_VICECAMPEAO)
				VALUES (pIdTemp, pIdCamp, _idUsu1, _IdTimeHome, _idUsu2, _IdTimeAway);

			ELSEIF _QtdGolsHome < _QtdGolsAway THEN
			
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsChampion;
				ELSE
					SET _sumCopa = pPtsChampion;
				END IF;
				
				UPDATE TB_HISTORICO_TEMPORADA
				SET PT_CAMPEAO = (PT_CAMPEAO+pPtsChampion),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu2;

				
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsVice;
				ELSE
					SET _sumCopa = pPtsVice;
				END IF;
				
				UPDATE TB_HISTORICO_TEMPORADA
				SET PT_VICECAMPEAO = (PT_VICECAMPEAO+pPtsVice),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu1;

				INSERT INTO TB_HISTORICO_CONQUISTA (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO_CAMPEAO, ID_TIME_CAMPEAO, ID_USUARIO_VICECAMPEAO, ID_TIME_VICECAMPEAO)
				VALUES (pIdTemp, pIdCamp, _idUsu2, _IdTimeAway, _idUsu1, _IdTimeHome);

			END IF;
		
		ELSE
		
			SET _sumGolsTime1 = _QtdGolsHome;
			SET _sumGolsTime2 = _QtdGolsAway;
			SET _sumGolsAwayTime2 = _QtdGolsAway;
			
			FETCH tabela_cursor INTO _idUsu1, _idUsu2, _QtdGolsHome, _QtdGolsAway, _IdTimeHome, _IdTimeAway;
			
			IF _finished = 1 THEN
				LEAVE get_tabela;
			END IF;
			
			SET _sumGolsTime2 = _sumGolsTime2 + _QtdGolsHome;
			SET _sumGolsTime1 = _sumGolsTime1 + _QtdGolsAway;
			SET _sumGolsAwayTime1 = _QtdGolsAway;
			
			IF ((_sumGolsTime2 > _sumGolsTime1) OR (_sumGolsTime1 = _sumGolsTime2 AND _sumGolsAwayTime2 > _sumGolsAwayTime1)) THEN
			
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsChampion;
				ELSE
					SET _sumCopa = pPtsChampion;
				END IF;
				
				UPDATE TB_HISTORICO_TEMPORADA
				SET PT_CAMPEAO = (PT_CAMPEAO+pPtsChampion),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu2;

				
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsVice;
				ELSE
					SET _sumCopa = pPtsVice;
				END IF;
				
				UPDATE TB_HISTORICO_TEMPORADA
				SET PT_VICECAMPEAO = (PT_VICECAMPEAO+pPtsVice),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu1;

				INSERT INTO TB_HISTORICO_CONQUISTA (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO_CAMPEAO, ID_TIME_CAMPEAO, ID_USUARIO_VICECAMPEAO, ID_TIME_VICECAMPEAO)
				VALUES (pIdTemp, pIdCamp, _idUsu2, _IdTimeAway, _idUsu1, _IdTimeHome);

			ELSEIF ((_sumGolsTime1 > _sumGolsTime2) OR (_sumGolsTime1 = _sumGolsTime2 AND _sumGolsAwayTime1 > _sumGolsAwayTime2)) THEN
			
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsChampion;
				ELSE
					SET _sumCopa = pPtsChampion;
				END IF;
				
				UPDATE TB_HISTORICO_TEMPORADA
				SET PT_CAMPEAO = (PT_CAMPEAO+pPtsChampion),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu1;

				
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsVice;
				ELSE
					SET _sumCopa = pPtsVice;
				END IF;
				
				UPDATE TB_HISTORICO_TEMPORADA
				SET PT_VICECAMPEAO = (PT_VICECAMPEAO+pPtsVice),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu2;
				
				INSERT INTO TB_HISTORICO_CONQUISTA (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO_CAMPEAO, ID_TIME_CAMPEAO, ID_USUARIO_VICECAMPEAO, ID_TIME_VICECAMPEAO)
				VALUES (pIdTemp, pIdCamp, _idUsu1, _IdTimeHome, _idUsu2, _IdTimeAway);

			END IF;
			
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateScorersH2H` $$
CREATE PROCEDURE `spCalculateScorersH2H`(
	pIdTemp INTEGER, 
	pIdCamp INTEGER,
	pQtMaxGols INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idGoleador INTEGER DEFAULT 0;
	DECLARE _idTime INTEGER DEFAULT 0;
	DECLARE _qtdGols INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT X.ID_GOLEADOR, X.QT_GOLS_MARCADOS, T.ID_TIME
		FROM (SELECT J.ID_GOLEADOR, SUM(J.QT_GOLS) as QT_GOLS_MARCADOS, J.ID_TIME 
		FROM TB_GOLEADOR_JOGO J 
		WHERE J.ID_CAMPEONATO = pIdCamp
		GROUP BY J.ID_GOLEADOR, J.ID_TIME) X, TB_GOLEADOR G, TB_TIME T
		WHERE X.QT_GOLS_MARCADOS = pQtMaxGols
		AND X.ID_GOLEADOR = G.ID_GOLEADOR
		AND X.ID_TIME = G.ID_TIME
		AND G.ID_TIME = T.ID_TIME
		ORDER BY X.QT_GOLS_MARCADOS DESC, G.NM_GOLEADOR ;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idGoleador, _qtdGols, _idTime;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		INSERT INTO TB_HISTORICO_ARTILHARIA (ID_TEMPORADA, ID_CAMPEONATO, ID_GOLEADOR, ID_TIME, ID_TECNICO, QT_GOLS)
		VALUES (pIdTemp, pIdCamp, _idGoleador, _idTime, fcGetIdUsuarioByTime(pIdCamp, _idTime), _qtdGols);

	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateEachFasePlayoffH2H` $$
CREATE PROCEDURE `spCalculateEachFasePlayoffH2H`(
	pIdTemp INTEGER, 
	pIdCamp INTEGER, 
	pSgCamp VARCHAR(4), 
	pIdFasePlayoff INTEGER,
	pTipoFasePlayoff VARCHAR(10),
	pPtsFasePlayoff INTEGER, 
	pSgLigas VARCHAR(50)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu1 INTEGER DEFAULT 0;
	DECLARE _idUsu2 INTEGER DEFAULT 0;
	DECLARE _sumLiga INTEGER DEFAULT 0;
	DECLARE _sumCopa INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT TU1.ID_USUARIO , TU2.ID_USUARIO
		FROM TB_TABELA_JOGO J, TB_USUARIO TU1, TB_USUARIO TU2 
		WHERE J.ID_CAMPEONATO = pIdCamp
		AND J.ID_FASE = pIdFasePlayoff
		AND J.IN_NUMERO_RODADA = 1
		AND J.ID_USUARIO_TIME_CASA = TU1.ID_USUARIO 
		AND J.ID_USUARIO_TIME_VISITANTE = TU2.ID_USUARIO 
		AND J.DT_EFETIVACAO_JOGO IS NOT NULL;
 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu1, _idUsu2;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _sumLiga = 0;
		SET _sumCopa = 0;
		
		IF pSgCamp IN (pSgLigas) THEN
			SET _sumLiga = pPtsFasePlayoff;
		ELSE
			SET _sumCopa = pPtsFasePlayoff;
		END IF;
		
		IF pTipoFasePlayoff = "FASE2" THEN

			UPDATE TB_HISTORICO_TEMPORADA
			SET PT_CLASSIF_FASE2 = (PT_CLASSIF_FASE2+pPtsFasePlayoff),
				PT_COPAS = (PT_COPAS+_sumCopa),
				PT_LIGAS = (PT_LIGAS+_sumLiga)
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);

		ELSEIF pTipoFasePlayoff = "OITAVAS" THEN

			UPDATE TB_HISTORICO_TEMPORADA
			SET PT_OITAVAS = (PT_OITAVAS+pPtsFasePlayoff),
				PT_COPAS = (PT_COPAS+_sumCopa),
				PT_LIGAS = (PT_LIGAS+_sumLiga)
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);

		ELSEIF pTipoFasePlayoff = "QUARTAS" THEN

			UPDATE TB_HISTORICO_TEMPORADA
			SET PT_QUARTAS = (PT_QUARTAS+pPtsFasePlayoff),
				PT_COPAS = (PT_COPAS+_sumCopa),
				PT_LIGAS = (PT_LIGAS+_sumLiga)
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);

		ELSEIF pTipoFasePlayoff = "SEMI" THEN

			UPDATE TB_HISTORICO_TEMPORADA
			SET PT_SEMIS = (PT_SEMIS+pPtsFasePlayoff),
				PT_COPAS = (PT_COPAS+_sumCopa),
				PT_LIGAS = (PT_LIGAS+_sumLiga)
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);

		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateCampeonatoLigaH2H` $$
CREATE PROCEDURE `spGenerateCampeonatoLigaH2H`(
	pIdTemp INTEGER,
	pTpCamp VARCHAR(4),
	pDtInicio DATE,
	pDtSorteio DATE,
	pNmCamp VARCHAR(50),
	pQtTimesAcesso INTEGER,
	pQtTimesRebaix INTEGER,
	pQtTimes INTEGER,
	pQtDiasClassif INTEGER,
	pQtDiasPlayoff INTEGER,
	pListaTimes VARCHAR(500)
)
Begin
	DECLARE _idCamp INTEGER DEFAULT NULL;
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_TIME FROM TB_TIME WHERE NM_TIME IN (pListaTimes) AND DS_TIPO NOT IN(FUT,PRO) ORDER BY NM_TIME;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	SET _idCamp = fcAddNovoCampeonato(pIdTemp, pTpCamp, FALSE);
	
	IF (_idCamp>0) THEN
	
		UPDATE TB_CAMPEONATO
		SET NM_CAMPEONATO = pNmCamp,
		    DT_INICIO = pDtInicio,
			DT_SORTEIO = pDtSorteio,
			QT_DIAS_PARTIDA_FASE_MATAxMATA = pQtDiasPlayoff,
			QT_TIMES_ACESSO = pQtTimesAcesso,
			QT_DIAS_PARTIDA_CLASSIFICACAO = pQtDiasClassif,
			QT_TIMES = pQtTimes,
			QT_TIMES_REBAIXADOS = pQtTimesRebaix,
			IN_DISPUTA_3o_4o_Lugar = FALSE
		WHERE ID_CAMPEONATO = _idCamp;
		
		DELETE FROM TB_CAMPEONATO_TIME WHERE ID_CAMPEONATO = _idCamp;
	
		OPEN tabela_cursor;
		
		get_tabela: LOOP
		
			FETCH tabela_cursor INTO _idTime;
			
			IF _finished = 1 THEN
				LEAVE get_tabela;
			END IF;

			INSERT INTO TB_CAMPEONATO_TIME (ID_CAMPEONATO, ID_TIME) VALUES (_idCamp, _idTime);
			
		END LOOP get_tabela;
		
		CLOSE tabela_cursor;
		
		
		call `arenafifadb_staging`.`spAddLoadClassificacaoInitialOfCampeonatov2`(_idCamp);

	END IF;

	SELECT _idCamp as idNewCampeonato;
	
End$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddListaTimesPreCopaH2H` $$
CREATE PROCEDURE `spAddListaTimesPreCopaH2H`(
	pIdCampCopa INTEGER,
	pListaTimesPreCopa VARCHAR(500)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _id INTEGER DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_TIME FROM TB_TIME WHERE NM_TIME IN (pListaTimesPreCopa) AND ID_TIME IN (SELECT ID_TIME FROM TB_CAMPEONATO_TIME 
	WHERE ID_CAMPEONATO = pIdCampCopa AND DS_TIPO NOT IN ("FUT, PRO")) ORDER BY NM_TIME;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _id;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;

		INSERT INTO `TB_TIMES_FASE_PRECOPA` (`ID_CAMPEONATO`, `ID_TIME`, `ID_ORDEM_SORTEIO`) 
		VALUES (pIdCampCopa, _id, NULL);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateCampeonatoUCL_UEL` $$
CREATE PROCEDURE `spGenerateCampeonatoUCL_UEL`(
	pIdTemp INTEGER,
	pTpCamp VARCHAR(4),
	pDtInicio DATE,
	pDtSorteio DATE,
	pNmCamp VARCHAR(50),
	pQtTimesAcesso INTEGER,
	pQtTimesRebaix INTEGER,
	pQtTimes INTEGER,
	pQtGrupos INTEGER,
	pQtDiasClassif INTEGER,
	pQtDiasPlayoff INTEGER,
	pIdsCampLiga VARCHAR(10),
	pListaTimesPote VARCHAR(500)
)
Begin
	DECLARE _idCamp INTEGER DEFAULT NULL;
	DECLARE _count INTEGER DEFAULT 1;
	
	SET _idCamp = fcAddNovoCampeonato(pIdTemp, pTpCamp, TRUE);
	
	IF (_idCamp>0) THEN
	
		UPDATE TB_CAMPEONATO
		SET NM_CAMPEONATO = pNmCamp,
		    DT_INICIO = pDtInicio,
			DT_SORTEIO = pDtSorteio,
			QT_DIAS_PARTIDA_FASE_MATAxMATA = pQtDiasPlayoff,
			QT_TIMES_ACESSO = pQtTimesAcesso,
			QT_DIAS_PARTIDA_CLASSIFICACAO = pQtDiasClassif,
			QT_TIMES = pQtTimes,
			QT_TIMES_REBAIXADOS = pQtTimesRebaix,
			IN_DISPUTA_3o_4o_Lugar = FALSE
		WHERE ID_CAMPEONATO = _idCamp;
		
		DELETE FROM TB_FASE_CAMPEONATO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_GRUPO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_POTE_TIME_GRUPO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_CAMPEONATO_TIME WHERE ID_CAMPEONATO = _idCamp;
		
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 0, 1);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 2, 2);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 3, 3);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 4, 4);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 5, 5);
		
		WHILE _count <= pQtGrupos DO
		
			call `arenafifadb_staging`.`spAddGrupo`(_idCamp, _count, CONCAT("Grupo ", _count));
		
			SET _count = _count + 1;
		
		END WHILE;
		
		call `arenafifadb_staging`.`spAddTecnicosFromLigasToCampeonatoTimeUsuario`(_idCamp, pIdsCampLiga);
		call `arenafifadb_staging`.`spAddLoadClassificacaoInitialOfCampeonatov2`(_idCamp);
		
		IF (pListaTimesPote <> "") THEN
		
			call `arenafifadb_staging`.`spAddAllPoteTimeGrupoH2H`(_idCamp, pListaTimesPote);
		
		END IF;
		
	END IF;

	SELECT _idCamp as idNewCampeonato;
	
End$$
DELIMITER ;





DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateCampeonatoCopaClubes` $$
CREATE PROCEDURE `spGenerateCampeonatoCopaClubes`(
	pIdTemp INTEGER,
	pTpCamp VARCHAR(4),
	pDtInicio DATE,
	pDtSorteio DATE,
	pNmCamp VARCHAR(50),
	pQtTimesAcesso INTEGER,
	pQtTimesRebaix INTEGER,
	pQtTimes INTEGER,
	pQtDiasClassif INTEGER,
	pQtDiasPlayoff INTEGER,
	pIdsCampLiga VARCHAR(10),
	pListaTimesPreCopa VARCHAR(500)
)
Begin
	DECLARE _idCamp INTEGER DEFAULT NULL;
	DECLARE _count INTEGER DEFAULT 1;
	
	SET _idCamp = fcAddNovoCampeonato(pIdTemp, pTpCamp, FALSE);
	
	IF (_idCamp>0) THEN
	
		UPDATE TB_CAMPEONATO
		SET NM_CAMPEONATO = pNmCamp,
		    DT_INICIO = pDtInicio,
			DT_SORTEIO = pDtSorteio,
			QT_DIAS_PARTIDA_FASE_MATAxMATA = pQtDiasPlayoff,
			QT_TIMES_ACESSO = pQtTimesAcesso,
			QT_DIAS_PARTIDA_CLASSIFICACAO = pQtDiasClassif,
			QT_TIMES = pQtTimes,
			QT_TIMES_REBAIXADOS = pQtTimesRebaix,
			IN_DISPUTA_3o_4o_Lugar = FALSE
		WHERE ID_CAMPEONATO = _idCamp;
		
		DELETE FROM TB_FASE_CAMPEONATO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_TIMES_FASE_PRECOPA WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_GRUPO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_POTE_TIME_GRUPO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_CAMPEONATO_TIME WHERE ID_CAMPEONATO = _idCamp;
		
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp,-1, 0);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 1, 1);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 2, 2);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 3, 3);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 4, 4);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 5, 5);
		
		call `arenafifadb_staging`.`spAddTecnicosFromLigasToCampeonatoTimeUsuario`(_idCamp, pIdsCampLiga);
		call `arenafifadb_staging`.`spAddLoadClassificacaoInitialOfCampeonatov2`(_idCamp);
		
		IF (pListaTimesPreCopa<>"") THEN
			call `arenafifadb_staging`.`spAddListaTimesPreCopaH2H`(_idCamp, pListaTimesPreCopa);
		END IF;

	END IF;

	SELECT _idCamp as idNewCampeonato;
	
End$$
DELIMITER ;





DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateCampeonatoMDL` $$
CREATE PROCEDURE `spGenerateCampeonatoMDL`(
	pIdTemp INTEGER,
	pTpCamp VARCHAR(4),
	pDtInicio DATE,
	pDtSorteio DATE,
	pNmCamp VARCHAR(50),
	pQtTimesAcesso INTEGER,
	pQtTimesRebaix INTEGER,
	pQtTimes INTEGER,
	pQtDiasClassif INTEGER,
	pQtDiasPlayoff INTEGER
)
Begin
	DECLARE _idCamp INTEGER DEFAULT NULL;
	DECLARE _count INTEGER DEFAULT 1;
	
	SET _idCamp = fcAddNovoCampeonato(pIdTemp, pTpCamp, FALSE);
	
	IF (_idCamp>0) THEN
	
		UPDATE TB_CAMPEONATO
		SET NM_CAMPEONATO = pNmCamp,
		    DT_INICIO = pDtInicio,
			DT_SORTEIO = pDtSorteio,
			QT_DIAS_PARTIDA_FASE_MATAxMATA = pQtDiasPlayoff,
			QT_TIMES_ACESSO = pQtTimesAcesso,
			QT_DIAS_PARTIDA_CLASSIFICACAO = pQtDiasClassif,
			QT_TIMES = pQtTimes,
			QT_TIMES_REBAIXADOS = pQtTimesRebaix,
			IN_DISPUTA_3o_4o_Lugar = FALSE
		WHERE ID_CAMPEONATO = _idCamp;
		
		DELETE FROM TB_TIMES_FASE_PRECOPA WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_GRUPO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_POTE_TIME_GRUPO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_CAMPEONATO_TIME WHERE ID_CAMPEONATO = _idCamp;
		
	END IF;

	SELECT _idCamp as idNewCampeonato;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spRellocationLigasH2H` $$
CREATE PROCEDURE `spRellocationLigasH2H`(
	pIdTemp INTEGER,
	pIdSerieA INTEGER,
	pIdSerieB INTEGER,
	pIdSerieC INTEGER,
	pIdSerieD INTEGER,
	pQtLimitMaxLstNegra INTEGER,
	pCodAcessoTapetao INTEGER,
	pCodAcesso INTEGER,
	pCodAcessoRelegated INTEGER,
	pCodAcessoInvited INTEGER
)
Begin
	call spMoveUpDivisionAboveAcesso(pIdTemp, pIdSerieA, pIdSerieB, "DIV2", pCodAcesso);
	call spMoveUpDivisionAboveAcesso(pIdTemp, pIdSerieB, pIdSerieC, "DIV3", pCodAcesso);
	
	call spMoveDownDivisionBelowRelegated(pIdTemp, pIdSerieA, pIdSerieB, "DIV1", pCodAcessoRelegated);
	call spMoveDownDivisionBelowRelegated(pIdTemp, pIdSerieB, pIdSerieC, "DIV2", pCodAcessoRelegated);

	#Retirando técnicos que não renovaram nas Séries
	call spDeleteNotAcceptRenewalH2H(pIdTemp, pIdSerieA, pIdSerieB, pIdSerieC, pIdSerieD);
	
	#Retirando técnicos inativos
	DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO IN (pIdSerieA, pIdSerieB, pIdSerieC, pIdSerieD)
	AND ID_USUARIO IN (SELECT U.ID_USUARIO FROM TB_USUARIO U WHERE U.ID_USUARIO > 100 AND (U.IN_USUARIO_ATIVO <> True Or U.IN_DESEJA_PARTICIPAR <> 1));
	
	#Retirando SEM Técnicos das Séries
	DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO IN (pIdSerieA, pIdSerieB, pIdSerieC, pIdSerieD)
	AND ID_USUARIO IN (SELECT U.ID_USUARIO FROM TB_USUARIO U WHERE arenafifadb.fcGetIdUsuariosVazio(U.ID_USUARIO,'IN') ORDER BY U.ID_USUARIO);
	
	#Retirando técnicos que ultrapassaram o limite de pontos negativos nas Séries
	call spDeleteBlackListRenewalH2H(pIdTemp, pIdSerieA, pIdSerieB, pIdSerieC, pIdSerieD, pQtLimitMaxLstNegra);
	
	call spValidateHistoricoTemporada(pIdTemp, pIdSerieA, NULL);
	call spValidateHistoricoTemporada(pIdTemp, pIdSerieB, NULL);
	call spValidateHistoricoTemporada(pIdTemp, pIdSerieC, NULL);
	call spValidateHistoricoTemporada(pIdTemp, pIdSerieD, NULL);
	
	call spMoveUpDivisionAboveTapetao(pIdTemp, pIdSerieA, pIdSerieB, pQtLimitMaxLstNegra, pCodAcessoTapetao);
	call spRelocationBenchToSerieH2H(pIdTemp, pIdSerieC, pIdSerieA, pIdSerieB, pIdSerieC, pIdSerieD, pQtLimitMaxLstNegra, pCodAcessoInvited);

	call spMoveUpDivisionAboveTapetao(pIdTemp, pIdSerieB, pIdSerieC, pQtLimitMaxLstNegra, pCodAcessoTapetao);
	call spRelocationBenchToSerieH2H(pIdTemp, pIdSerieC, pIdSerieA, pIdSerieB, pIdSerieC, pIdSerieD, pQtLimitMaxLstNegra, pCodAcessoInvited);
	
	call spMoveUpDivisionAboveTapetao(pIdTemp, pIdSerieB, pIdSerieC, pQtLimitMaxLstNegra, pCodAcessoTapetao);
	call spRelocationBenchToSerieH2H(pIdTemp, pIdSerieC, pIdSerieA, pIdSerieB, pIdSerieC, pIdSerieD, pQtLimitMaxLstNegra, pCodAcessoInvited);
	
	call spRelocationBenchToSerieH2H(pIdTemp, pIdSerieD, pIdSerieA, pIdSerieB, pIdSerieC, pIdSerieD, pQtLimitMaxLstNegra, pCodAcessoInvited);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spRelocationBenchToSerieH2H` $$
CREATE PROCEDURE `spRelocationBenchToSerieH2H`(
	pIdTemp INTEGER,
	pIdCamp INTEGER,
	pIdSerieA INTEGER,
	pIdSerieB INTEGER,
	pIdSerieC INTEGER,
	pIdSerieD INTEGER,
	pQtLimitMaxLstNegra INTEGER,
	pCodAcessoInvited INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _count INTEGER DEFAULT 1;
	DECLARE _countCurrent INTEGER DEFAULT 0;
	DECLARE _countRest INTEGER DEFAULT 0;
	DECLARE _IdUsu INTEGER DEFAULT 0;
	DECLARE _TotLstNegra INTEGER DEFAULT 0;
	DECLARE _QtTotalTimes INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR 
		SELECT X.ID_Usuario, X.PT_LSTNEGRA FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR,  
			   (SELECT L.PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA,  
			   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL  
			   FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U   
			   WHERE C.ID_TEMPORADA = pIdTemp
			   AND C.ID_CAMPEONATO = 0  
			   AND C.IN_CONFIRMACAO = 1 
			   AND C.ID_USUARIO NOT IN (SELECT CU.ID_USUARIO FROM TB_CAMPEONATO_USUARIO CU WHERE CU.ID_CAMPEONATO IN (pIdSerieA, pIdSerieB, pIdSerieC, pIdSerieD)) 
			   AND U.IN_USUARIO_ATIVO = TRUE  
			   AND U.IN_DESEJA_PARTICIPAR = 1  
			   AND C.ID_USUARIO = U.ID_USUARIO) as X
			   ORDER BY X.DS_Status, X.IN_USUARIO_MODERADOR, X.IN_CONFIRMACAO DESC, X.IN_ORDENACAO, X.DT_CONFIRMACAO, X.PT_LSTNEGRA, X.PT_TOTAL DESC, X.ID_Usuario;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	SELECT count(1) into _countCurrent FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdCamp;
	
	SELECT QT_TIMES into _QtTotalTimes FROM  TB_CAMPEONATO WHERE ID_CAMPEONATO = pIdCamp;
		
	SET _countRest = (_QtTotalTimes-_countCurrent);
	
	SET _count = 1;
	
	IF _countRest > 0 THEN

		OPEN tabela_cursor;
		
		get_tabela: LOOP
		
			FETCH tabela_cursor INTO _idUsu, _TotLstNegra;
			
			IF _finished = 1 THEN
				LEAVE get_tabela;
			END IF;
			
			SET _TotLstNegra = COALESCE(_TotLstNegra, 0);
			
			IF _count > _countRest THEN
			
				LEAVE get_tabela;
			
			ELSEIF _count <= _countRest AND _TotLstNegra <= pQtLimitMaxLstNegra THEN
			
				call spAddCampeonatoUsuario(pIdCamp, _idUsu);
				
				call spAddHistoricoTemporadaH2H(pIdTemp, _idUsu, pCodAcessoInvited);
				
				call spUpdateToEndBancoReserva(_idUsu, 'H2H');
			
				SET _count = _count + 1;

			END IF;
		
		END LOOP get_tabela;
		
		CLOSE tabela_cursor;
	
	END IF;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteNotAcceptRenewalH2H` $$
CREATE PROCEDURE `spDeleteNotAcceptRenewalH2H`(
	pIdTemp INTEGER,
	pIdSerieA INTEGER,
	pIdSerieB INTEGER,
	pIdSerieC INTEGER,
	pIdSerieD INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _idCampRenewal INTEGER DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR 
		SELECT X.ID_USUARIO, X.ID_CAMPEONATO FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, 
			(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
			FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
			WHERE C.ID_TEMPORADA = pIdTemp AND C.ID_CAMPEONATO in (1,2,3,4) AND U.IN_USUARIO_ATIVO = TRUE
			AND (C.IN_CONFIRMACAO IS NULL OR C.IN_CONFIRMACAO = 0 OR C.IN_CONFIRMACAO = 9 OR C.DS_STATUS = 'NA')
			AND C.ID_USUARIO = U.ID_USUARIO) as X;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _idCampRenewal;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _idCampRenewal = 1 THEN
			DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdSerieA AND ID_USUARIO = _idUsu;
		ELSEIF _idCampRenewal = 2 THEN
			DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdSerieB AND ID_USUARIO = _idUsu;
		ELSEIF _idCampRenewal = 3 THEN
			DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdSerieC AND ID_USUARIO = _idUsu;
		ELSEIF _idCampRenewal = 4 THEN
			DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdSerieD AND ID_USUARIO = _idUsu;
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteBlackListRenewalH2H` $$
CREATE PROCEDURE `spDeleteBlackListRenewalH2H`(
	pIdTemp INTEGER,
	pIdSerieA INTEGER,
	pIdSerieB INTEGER,
	pIdSerieC INTEGER,
	pIdSerieD INTEGER,
	pQtLimitMaxLstNegra INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _idCampRenewal INTEGER DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR 
		SELECT X.ID_USUARIO, X.ID_CAMPEONATO FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, 
		(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
		FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U, (SELECT ID_USUARIO, PT_TOTAL FROM TB_LISTA_NEGRA WHERE ID_Temporada = (pIdTemp-1) AND PT_TOTAL > 0) as L
		WHERE C.ID_TEMPORADA = pIdTemp AND C.ID_CAMPEONATO in (1,2,3,4) AND U.IN_USUARIO_ATIVO = TRUE
		AND C.IN_CONFIRMACAO = 1 AND L.PT_TOTAL > pQtLimitMaxLstNegra
		AND C.ID_USUARIO = U.ID_USUARIO AND C.ID_USUARIO = L.ID_USUARIO AND U.ID_USUARIO = L.ID_USUARIO) X;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _idCampRenewal;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _idCampRenewal = 1 THEN
			DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdSerieA AND ID_USUARIO = _idUsu;
		ELSEIF _idCampRenewal = 2 THEN
			DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdSerieB AND ID_USUARIO = _idUsu;
		ELSEIF _idCampRenewal = 3 THEN
			DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdSerieC AND ID_USUARIO = _idUsu;
		ELSEIF _idCampRenewal = 4 THEN
			DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdSerieD AND ID_USUARIO = _idUsu;
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spValidateHistoricoTemporada` $$
CREATE PROCEDURE `spValidateHistoricoTemporada`(
	pIdTemp INTEGER,
	pIdCamp INTEGER,
	pCodHist INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu INTEGER DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR 
		SELECT C.ID_USUARIO FROM TB_CAMPEONATO_USUARIO C WHERE C.ID_CAMPEONATO = pIdCamp ORDER BY C.ID_USUARIO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		call spAddHistoricoTemporadaH2H(pIdTemp, _idUsu, pCodHist);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spValidateIDTimeTableStandard` $$
CREATE PROCEDURE `spValidateIDTimeTableStandard`(
	pIdTemp INTEGER,
	pIdCamp INTEGER,
	ptpMode CHAR(3),
	pSgCamp CHAR(7)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE _idTipo INTEGER DEFAULT NULL;
	DECLARE _psnID VARCHAR(30) DEFAULT NULL;
	DECLARE _teamName VARCHAR(50) DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR 
		SELECT ITEM_NAME FROM TB_GENERATE_NEWSEASON_ITEM_STANDARD WHERE TP_MODALIDADE = ptpMode AND SG_CAMPEONATO = pSgCamp AND ITEM_ID = 0;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		SET _teamName = "";
		SET _idUsu = NULL;
		SET _psnID = NULL;
	
		FETCH tabela_cursor INTO _teamName;
		
		SET _teamName = COALESCE(_teamName, "");
		
		IF _teamName = "" THEN
			LEAVE get_tabela;
		END IF;
		
		#IF _finished = 1 THEN
		#	LEAVE get_tabela;
		#END IF;
		
		SELECT C.ID_USUARIO into _idUsu 
		FROM TB_CONFIRMACAO_TEMPORADA C
		WHERE C.ID_TEMPORADA = pIdTemp AND C.ID_CAMPEONATO >= 7 AND LOWER(TRIM(C.NM_TIME)) = LOWER(TRIM(_teamName)) LIMIT 1;

	    SET _idUsu = COALESCE(_idUsu, 0);
		  
		SELECT U.PSN_ID into  _psnID 
		FROM TB_USUARIO U WHERE U.ID_USUARIO = _idUsu;
		  
		IF _idUsu > 0  THEN
		
			SET _idTime = NULL;
		
			SELECT ID_TIME into _idTime FROM TB_TIME WHERE ID_TECNICO_FUT = _idUsu AND LOWER(TRIM(NM_TIME)) = LOWER(TRIM(_teamName)) AND DS_TIPO = ptpMode;
			
			SET _idTime = COALESCE(_idTime, 0);
			
			IF _idTime = 0 THEN
			
				IF ptpMode = 'FUT' THEN
					SET _idTipo = 37;
				ELSEIF ptpMode = 'PRO' THEN
					SET _idTipo = 42;
				END IF;
			
				INSERT INTO TB_TIME(NM_TIME, ID_TIPO_TIME, DS_TIPO, ID_TECNICO_FUT, IN_TIME_COM_IMAGEM) 
				VALUES (TRIM(_teamName), _idTipo, ptpMode, _idUsu, 0);
				
				SELECT ID_TIME INTO _idTime FROM TB_TIME ORDER BY ID_TIME DESC LIMIT 1;
				
			END IF;
		
			UPDATE TB_GENERATE_NEWSEASON_ITEM_STANDARD
			SET ITEM_ID = _idTime, ITEM_PSN = _psnID
			WHERE TP_MODALIDADE = ptpMode AND SG_CAMPEONATO = pSgCamp AND LOWER(TRIM(ITEM_NAME)) = LOWER(TRIM(_teamName)) AND ITEM_ID = 0;
		
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	#SELECT _idTime, _idUsu, _psnID, _teamName, _finished;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddUsuTimeFUTFromStandard` $$
CREATE PROCEDURE `spAddUsuTimeFUTFromStandard`(
	pIdTemp INTEGER,
	pIdCamp INTEGER,
	ptpMode CHAR(3),
	pSgCamp CHAR(7)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE _idTipo INTEGER DEFAULT NULL;
	DECLARE _psnID VARCHAR(30) DEFAULT NULL;
	DECLARE _teamName VARCHAR(50) DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR 
		SELECT ITEM_ID, ITEM_NAME, ITEM_PSN FROM TB_GENERATE_NEWSEASON_ITEM_STANDARD WHERE TP_MODALIDADE = ptpMode AND SG_CAMPEONATO = pSgCamp;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idTime, _teamName, _psnID;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SELECT U.ID_USUARIO into _idUsu
		FROM TB_USUARIO U
		WHERE U.PSN_ID = _psnID;
		  
		IF _idUsu IS NOT NULL THEN
		
			INSERT INTO TB_CAMPEONATO_TIME (ID_CAMPEONATO, ID_TIME) VALUES (pIdCamp, _idTime);
			INSERT INTO TB_CAMPEONATO_USUARIO (ID_CAMPEONATO, ID_USUARIO, DT_ENTRADA) VALUES (pIdCamp, _idUsu, NOW());
		
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;
