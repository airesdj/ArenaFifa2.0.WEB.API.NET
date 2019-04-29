USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateEndOfTemporadaFUT` $$
CREATE PROCEDURE `spCalculateEndOfTemporadaFUT`(pIdTemp INTEGER, pDataInicio DATE)
Begin
	DECLARE _idNewTemp INTEGER DEFAULT NULL;

	UPDATE TB_CAMPEONATO SET IN_CAMPEONATO_ATIVO = FALSE 
	WHERE SG_TIPO_CAMPEONATO IN ("FUT1", "FUT2", "CFUT", "LFUT") AND IN_CAMPEONATO_ATIVO = TRUE;
	
	SET _idNewTemp = spAddNewTemporadaByFimOldOne(CONCAT(pIdTemp, " º Temporada"), pDataInicio);
	
	call `arenafifadb`.`spCalculateAllFasesEndOfTemporadaFUT`(pIdTemp, _idNewTemp);
	
	SELECT _idNewTemp as NewTemporada;

End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateAllFasesEndOfTemporadaFUT` $$
CREATE PROCEDURE `spCalculateAllFasesEndOfTemporadaFUT`(pIdTemp INTEGER, pIdTempNew INTEGER)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _sgCamps VARCHAR(50) DEFAULT "'LFUT','FUT1','FUT2','CFUT'";
	DECLARE _sgLigas VARCHAR(50) DEFAULT "'FUT1', 'FUT2', 'LFUT'";
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
		AND C.SG_TIPO_CAMPEONATO IN (_sgCamps)
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
	
	#DELETE FROM TB_HISTORICO_ARTILHARIA_FUT WHERE ID_TEMPORADA >= pIdTemp;
	DELETE FROM TB_HISTORICO_CONQUISTA_FUT WHERE ID_TEMPORADA >= pIdTemp;
	DELETE FROM TB_HISTORICO_TEMPORADA_FUT WHERE ID_TEMPORADA >= pIdTemp;
	
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
		
		
		SELECT count(1) into _count FROM TB_HISTORICO_TEMPORADA_FUT WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsuHome;
		IF _count = 0 THEN
			call `arenafifadb`.`spAddHistoricoTemporadaFUT`(pIdTemp, _idUsuHome, NULL);
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
		
		IF _sgCamp IN (_sgLigasH2H) THEN
			SET _sumLiga = _sumPoints;
		ELSE
			SET _sumCopa = _sumPoints;
		END IF;
		
		UPDATE TB_HISTORICO_TEMPORADA_FUT
		SET PT_EMPATES_FASE1 = (PT_EMPATES_FASE1+_sumEmpate),
		    PT_VITORIAS_FASE1 = (PT_VITORIAS_FASE1+_sumVitoria),
			PT_COPAS = (PT_COPAS+_sumCopa),
			PT_LIGAS = (PT_LIGAS+_sumLiga)
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsuHome;


		SELECT count(1) into _count FROM TB_HISTORICO_TEMPORADA_FUT WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsuAway;
		IF _count = 0 THEN
			call `arenafifadb`.`spAddHistoricoTemporadaFUT`(pIdTemp, _idUsuAway, NULL);
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
		
		IF _sgCamp IN (_sgLigasH2H) THEN
			SET _sumLiga = _sumPoints;
		ELSE
			SET _sumCopa = _sumPoints;
		END IF;
		
		UPDATE TB_HISTORICO_TEMPORADA_FUT
		SET PT_EMPATES_FASE1 = (PT_EMPATES_FASE1+_sumEmpate),
		    PT_VITORIAS_FASE1 = (PT_VITORIAS_FASE1+_sumVitoria),
			PT_COPAS = (PT_COPAS+_sumCopa),
			PT_LIGAS = (PT_LIGAS+_sumLiga)
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsuAway;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	#Calculando fases playoff....
	call `arenafifadb`.`spCalculateFasePlayoffFUT_PRO`(pIdTemp, _sgCamps, _sgLigas, "FUT");

End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateFasePlayoffFUT_PRO` $$
CREATE PROCEDURE `spCalculateFasePlayoffFUT_PRO`(pIdTemp INTEGER, pSgCamps VARCHAR(50), pSgLigas VARCHAR(50), pTipo VARCHAR(3))
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


	DECLARE tabela_cursor CURSOR FOR
		SELECT C.ID_CAMPEONATO, C.SG_TIPO_CAMPEONATO, C.IN_SISTEMA_IDA_VOLTA FROM TB_CAMPEONATO C 
		WHERE C.ID_TEMPORADA = pIdTemp AND C.SG_TIPO_CAMPEONATO IN (pSgCamps) ORDER BY C.ID_CAMPEONATO;
	
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
		
		SELECT ID_FASE into _idNextFase FROM TB_FASE_CAMPEONATO WHERE ID_CAMPEONATO = pIdCamp AND AND ID_FASE > 0 ORDER BY IN_ORDENACAO LIMIT 1;
		
		#Calculando passagens para a próxima fase....
		call `arenafifadb`.`spCalculatePassNextFaseFUT_PRO`(_idCamp, _sgCamp, _idNextFase, _ptsCalssifFase2, pSgLigas, pTipo);

		#Calculando Fases Seguintes de Playoff....
		#2a Fase
		call `arenafifadb`.`spCalculateEachFasePlayoffFUT_PRO`(_idCamp, _sgCamp, 1, "FASE2", _ptsFase2, pSgLigas, pTipo);
		
		#Oitavas
		call `arenafifadb`.`spCalculateEachFasePlayoffFUT_PRO`(_idCamp, _sgCamp, 2, "OITAVAS", _ptsRound16, pSgLigas, pTipo);

		#Quartas
		call `arenafifadb`.`spCalculateEachFasePlayoffFUT_PRO`(_idCamp, _sgCamp, 3, "QUARTAS", _ptsQuarter, pSgLigas, pTipo);

		#Semi
		call `arenafifadb`.`spCalculateEachFasePlayoffFUT_PRO`(_idCamp, _sgCamp, 4, "SEMI", _ptsSemi, pSgLigas, pTipo);

		#Campeao e Vice
		IF _inIdaEVolta = false THEN
			call `arenafifadb`.`spCalculateChampionAndViceFUT_PRO`(pIdTemp, _idCamp, _sgCamp, _ptsChampion, _ptsVice, pSgLigas, 0, "1", pTipo);
		ELSE
			call `arenafifadb`.`spCalculateChampionAndViceFUT_PRO`(pIdTemp, _idCamp, _sgCamp, _ptsChampion, _ptsVice, pSgLigas, 1, "1,2", pTipo);
		END IF;
		
		#Artilharia
		IF pTipo = "PRO" THEN
			SELECT X.QT_GOLS_MARCADOS INTO _qtMaxGols
			FROM (SELECT J.ID_GOLEADOR, SUM(J.QT_GOLS) as QT_GOLS_MARCADOS, J.ID_TIME
			FROM TB_GOLEADOR_JOGO J 
			WHERE J.ID_CAMPEONATO = _idCamp
			GROUP BY J.ID_GOLEADOR, J.ID_TIME) X, TB_GOLEADOR G, TB_TIME T
			WHERE X.ID_GOLEADOR = G.ID_GOLEADOR
			AND X.ID_TIME = G.ID_TIME
			AND G.ID_TIME = T.ID_TIME
			ORDER BY X.QT_GOLS_MARCADOS DESC, G.NM_GOLEADOR LIMIT 1;

			call `arenafifadb`.`spCalculateScorersPRO`(pIdTemp, _idCamp, _qtMaxGols);
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	IF pTipo = "FUT" THEN
	
		UPDATE TB_HISTORICO_TEMPORADA_FUT
		SET PT_TOTAL = (PT_CAMPEAO+PT_VICECAMPEAO+PT_SEMIS+PT_QUARTAS+PT_OITAVAS+PT_CLASSIF_FASE2+PT_VITORIAS_FASE1+PT_EMPATES_FASE1),
			PT_TOTAL_TEMPORADA = (PT_LIGAS+PT_COPAS)
		WHERE ID_TEMPORADA = pIdTemp;
	
		SELECT ID_TEMPORADA into _idPreviousTemp FROM FROM TB_HISTORICO_TEMPORADA_FUT  WHERE ID_TEMPORADA < pIdTemp ORDER BY ID_TEMPORADA DESC LIMIT 1;
		
	ELSE

		UPDATE TB_HISTORICO_TEMPORADA_PRO
		SET PT_TOTAL = (PT_CAMPEAO+PT_VICECAMPEAO+PT_SEMIS+PT_QUARTAS+PT_OITAVAS+PT_CLASSIF_FASE2+PT_VITORIAS_FASE1+PT_EMPATES_FASE1),
			PT_TOTAL_TEMPORADA = (PT_LIGAS+PT_COPAS)
		WHERE ID_TEMPORADA = pIdTemp;

		SELECT ID_TEMPORADA into _idPreviousTemp FROM FROM TB_HISTORICO_TEMPORADA_PRO  WHERE ID_TEMPORADA < pIdTemp ORDER BY ID_TEMPORADA DESC LIMIT 1;
		
	END IF;
	
	IF pTipo = "FUT" THEN
		#Atualizando Aproveitamento dos técnicos....
		call `arenafifadb`.`spPrepareToCalculatePerformanceTecnicosFUT`(pIdTemp, _idPreviousTemp, pSgLigas);
		
		#Atualizando Historico todos técnicos....
		call `arenafifadb`.`spAddAllTecnicosHistoricoTemporadaFUT`(pIdTemp);
		
		#Atualizando o Hall da Fama....
		call `arenafifadb`.`spUpdateHallOfFameFUT`(pIdTemp);
	ELSE
		#Atualizando Aproveitamento dos técnicos....
		call `arenafifadb`.`spPrepareToCalculatePerformanceTecnicosPRO`(pIdTemp, _idPreviousTemp, pSgLigas);
		
		#Atualizando Historico todos técnicos....
		call `arenafifadb`.`spAddAllTecnicosHistoricoTemporadaPRO`(pIdTemp);
		
		#Atualizando o Hall da Fama....
		call `arenafifadb`.`spUpdateHallOfFamePRO`(pIdTemp);
	END IF
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateHallOfFameFUT` $$
CREATE PROCEDURE `spUpdateHallOfFameFUT`(
	pIdTemp INTEGER
)
Begin
	call `arenafifadb`.`spUpdateHallOfFameLstNegraFUT`(pIdTemp);

	UPDATE TB_HISTORICO_TEMPORADA_FUT
	SET IN_REBAIXADO_TEMP_ANTERIOR = 0 
	WHERE ID_TEMPORADA = pIdTemp AND IN_REBAIXADO_TEMP_ANTERIOR IS NULL;
	
	UPDATE TB_HISTORICO_TEMPORADA_FUT
	SET IN_ACESSO_TEMP_ATUAL = 0
	WHERE ID_TEMPORADA = pIdTemp;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateHallOfFameLstNegraFUT` $$
CREATE PROCEDURE `spUpdateHallOfFameLstNegraFUT`(
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
	SELECT ID_USUARIO, PT_TOTAL FROM TB_HISTORICO_TEMPORADA_FUT WHERE ID_TEMPORADA = pIdTemp
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
		
		SELECT PT_TOTAL into  FROM TB_LISTA_NEGRA 
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _IdUsu;
		
		IF _qtLstNegra IS NULL THEN
			SET _qtLstNegra = 0;
		END IF;
		
		UPDATE TB_HISTORICO_TEMPORADA_FUT
		SET IN_POSICAO_ATUAL = _count,
			QT_LSTNEGRA = _qtLstNegra
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _IdUsu;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddAllTecnicosHistoricoTemporadaFUT` $$
CREATE PROCEDURE `spAddAllTecnicosHistoricoTemporadaFUT`(
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
		SELECT ID_USUARIO, max(ID_TEMPORADA) FROM TB_HISTORICO_TEMPORADA_FUT
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
		FROM TB_HISTORICO_TEMPORADA_FUT WHERE ID_TEMPORADA = _idTemp AND ID_USUARIO = _idUsu;
		
		call `arenafifadb`.`spAddHistoricoTemporadaFUT`(pIdTemp, _idUsu, 0);
		
		IF (_total IS NOT NULL) THEN
			UPDATE TB_HISTORICO_TEMPORADA_FUT
			SET PT_TOTAL = _total, PC_APROVEITAMENTO_GERAL = _apGeral, QT_LSTNEGRA = _totLstNegra
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu;
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spPrepareToCalculatePerformanceTecnicosFUT` $$
CREATE PROCEDURE `spPrepareToCalculatePerformanceTecnicosFUT`(
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
		SELECT ID_USUARIO, PT_TOTAL_TEMPORADA FROM TB_HISTORICO_TEMPORADA_FUT  WHERE ID_TEMPORADA = pIdTemp ORDER BY ID_USUARIO;
 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _totTemp;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SELECT PT_TOTAL into _totPreviusTemp FROM TB_HISTORICO_TEMPORADA_FUT WHERE ID_TEMPORADA = pIdPreviousTemp AND ID_USUARIO = pIdUsu;
		IF _totPreviusTemp IS NULL THEN
			UPDATE TB_HISTORICO_TEMPORADA_FUT
			SET PT_TOTAL_TEMPORADA_ANTERIOR = PT_TOTAL_TEMPORADA
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
		ELSE
			UPDATE TB_HISTORICO_TEMPORADA_FUT
			SET PT_TOTAL_TEMPORADA_ANTERIOR = _totPreviusTemp, PT_TOTAL = (PT_TOTAL+_totPreviusTemp)
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
		END IF;
		
		call `arenafifadb`.`spCalculatePerformanceTecnicosFUT_PRO`(pIdTemp, _idUsu, pSgLigas, "FUT");
		
		call `arenafifadb`.`spCalculatePerformanceGeralTecnicosFUT_PRO`(pIdTemp, _idUsu, pSgLigas, "FUT");
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculatePerformanceGeralTecnicosFUT_PRO` $$
CREATE PROCEDURE `spCalculatePerformanceGeralTecnicosFUT_PRO`(
	pIdTemp INTEGER, 
	pIdUsu INTEGER, 
	pSgLigas VARCHAR(50), pTipo VARCHAR(3)
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
	 AND J.ID_CAMPEONATO = C.ID_CAMPEONATO AND C.ID_TEMPORADA = T.ID_TEMPORADA AND C.SG_TIPO_CAMPEONATO IN (pSgLigas) 
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
	
	IF pTipo = "FUT" THEN
		UPDATE TB_HISTORICO_TEMPORADA_FUT
		SET QT_JOGOS_GERAL = _qtJogosGeral,
			QT_TOTAL_VITORIAS_GERAL = _qtdVitoriasGeral,
			QT_TOTAL_EMPATES_GERAL = _qtdEmpatesGeral,
			QT_TOTAL_PONTOS_GERAL = _totPontosGeral,
			PC_APROVEITAMENTO_GERAL = ( (_qtdPontosGanhosGeral * 100) /  _totPontosGeral )
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	ELSE
		UPDATE TB_HISTORICO_TEMPORADA_PRO
		SET QT_JOGOS_GERAL = _qtJogosGeral,
			QT_TOTAL_VITORIAS_GERAL = _qtdVitoriasGeral,
			QT_TOTAL_EMPATES_GERAL = _qtdEmpatesGeral,
			QT_TOTAL_PONTOS_GERAL = _totPontosGeral,
			PC_APROVEITAMENTO_GERAL = ( (_qtdPontosGanhosGeral * 100) /  _totPontosGeral )
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	END IF;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculatePerformanceTecnicosFUT_PRO` $$
CREATE PROCEDURE `spCalculatePerformanceTecnicosFUT_PRO`(
	pIdTemp INTEGER, 
	pIdUsu INTEGER, 
	pSgLigas VARCHAR(50), pTipo VARCHAR(3)
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
	 AND J.ID_CAMPEONATO = C.ID_CAMPEONATO AND C.ID_TEMPORADA = T.ID_TEMPORADA AND C.SG_TIPO_CAMPEONATO IN (pSgLigas) 
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
	
	IF pTipo = "FUT" THEN
		UPDATE TB_HISTORICO_TEMPORADA_FUT
		SET QT_JOGOS_TEMPORADA = _qtJogosTemp,
			QT_TOTAL_VITORIAS_TEMPORADA = _qtdVitorias,
			QT_TOTAL_EMPATES_TEMPORADA = _qtdEmpates,
			QT_TOTAL_PONTOS_TEMPORADA = _totPontosTemporada,
			PC_APROVEITAMENTO_TEMPORADAS = ( (_qtdPontosGanhos * 100) /  _totPontosTemporada )
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	ELSE
		UPDATE TB_HISTORICO_TEMPORADA_PRO
		SET QT_JOGOS_TEMPORADA = _qtJogosTemp,
			QT_TOTAL_VITORIAS_TEMPORADA = _qtdVitorias,
			QT_TOTAL_EMPATES_TEMPORADA = _qtdEmpates,
			QT_TOTAL_PONTOS_TEMPORADA = _totPontosTemporada,
			PC_APROVEITAMENTO_TEMPORADAS = ( (_qtdPontosGanhos * 100) /  _totPontosTemporada )
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	END IF;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateChampionAndViceFUT_PRO` $$
CREATE PROCEDURE `spCalculateChampionAndViceFUT_PRO`(
	pIdTemp INTEGER, 
	pIdCamp INTEGER, 
	pSgCamp VARCHAR(4), 
	pPtsChampion INTEGER, 
	pPtsVice INTEGER, 
	pSgLigas VARCHAR(50)
	pInIdaEVolta INTEGER,
	pNumRodadas VARCHAR(5), pTipo VARCHAR(3)
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
		 AND J.ID_FASE = pIdNextFase
		 AND J.IN_NUMERO_RODADA IN (pNumRodadas)
		 AND J.DT_EFETIVACAO_JOGO IS NOT NULL
		 AND J.ID_USUARIO_TIME_CASA = TU1.ID_USUARIO
		 AND J.ID_USUARIO_TIME_VISITANTE = TU2.ID_USUARIO
		 ORDER BY ORDER BY J.IN_JOGO_MATAXMATA, J.IN_NUMERO_RODADA, J.DT_TABELA_INICIO_JOGO, J.DS_HORA_JOGO, J.ID_TABELA_JOGO;
 
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
				
				IF pTipo = "FUT" THEN
					UPDATE TB_HISTORICO_TEMPORADA_FUT
					SET PT_CAMPEAO = (PT_CAMPEAO+pPtsChampion),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu1;
				ELSE
					UPDATE TB_HISTORICO_TEMPORADA_PRO
					SET PT_CAMPEAO = (PT_CAMPEAO+pPtsChampion),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu1;
				END IF;

				
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsVice;
				ELSE
					SET _sumCopa = pPtsVice;
				END IF;
				
				IF pTipo = "FUT" THEN
					UPDATE TB_HISTORICO_TEMPORADA_FUT
					SET PT_VICECAMPEAO = (PT_VICECAMPEAO+pPtsVice),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu2;

					INSERT INTO TB_HISTORICO_CONQUISTA_FUT (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO_CAMPEAO, ID_TIME_CAMPEAO, ID_USUARIO_VICECAMPEAO, ID_TIME_VICECAMPEAO)
					VALUES (pIdTemp, pIdCamp, _idUsu1, _IdTimeHome, _idUsu2, _IdTimeAway);

				ELSE
					UPDATE TB_HISTORICO_TEMPORADA_PRO
					SET PT_VICECAMPEAO = (PT_VICECAMPEAO+pPtsVice),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu2;

					INSERT INTO TB_HISTORICO_CONQUISTA_PRO (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO_CAMPEAO, ID_TIME_CAMPEAO, ID_USUARIO_VICECAMPEAO, ID_TIME_VICECAMPEAO)
					VALUES (pIdTemp, pIdCamp, _idUsu1, _IdTimeHome, _idUsu2, _IdTimeAway);

				END IF;
				
			ELSEIF _QtdGolsHome < _QtdGolsAway THEN
			
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsChampion;
				ELSE
					SET _sumCopa = pPtsChampion;
				END IF;
				
				IF pTipo = "FUT" THEN
					UPDATE TB_HISTORICO_TEMPORADA_FUT
					SET PT_CAMPEAO = (PT_CAMPEAO+pPtsChampion),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu2;
				ELSE
					UPDATE TB_HISTORICO_TEMPORADA_PRO
					SET PT_CAMPEAO = (PT_CAMPEAO+pPtsChampion),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu2;
				END IF;
				
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsVice;
				ELSE
					SET _sumCopa = pPtsVice;
				END IF;
				
				IF pTipo = "FUT" THEN
					UPDATE TB_HISTORICO_TEMPORADA_FUT
					SET PT_VICECAMPEAO = (PT_VICECAMPEAO+pPtsVice),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu1;

					INSERT INTO TB_HISTORICO_CONQUISTA_FUT (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO_CAMPEAO, ID_TIME_CAMPEAO, ID_USUARIO_VICECAMPEAO, ID_TIME_VICECAMPEAO)
					VALUES (pIdTemp, pIdCamp, _idUsu2, _IdTimeAway, _idUsu1, _IdTimeHome);

				ELSE
					UPDATE TB_HISTORICO_TEMPORADA_PRO
					SET PT_VICECAMPEAO = (PT_VICECAMPEAO+pPtsVice),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu1;

					INSERT INTO TB_HISTORICO_CONQUISTA_PRO (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO_CAMPEAO, ID_TIME_CAMPEAO, ID_USUARIO_VICECAMPEAO, ID_TIME_VICECAMPEAO)
					VALUES (pIdTemp, pIdCamp, _idUsu2, _IdTimeAway, _idUsu1, _IdTimeHome);

				END IF;

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
				
				IF pTipo = "FUT" THEN
					UPDATE TB_HISTORICO_TEMPORADA_FUT
					SET PT_CAMPEAO = (PT_CAMPEAO+pPtsChampion),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu2;
				ELSE
					UPDATE TB_HISTORICO_TEMPORADA_PRO
					SET PT_CAMPEAO = (PT_CAMPEAO+pPtsChampion),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu2;
				END IF;
				
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsVice;
				ELSE
					SET _sumCopa = pPtsVice;
				END IF;
				
				IF pTipo = "FUT" THEN
					UPDATE TB_HISTORICO_TEMPORADA_FUT
					SET PT_VICECAMPEAO = (PT_VICECAMPEAO+pPtsVice),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu1;

					INSERT INTO TB_HISTORICO_CONQUISTA_FUT (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO_CAMPEAO, ID_TIME_CAMPEAO, ID_USUARIO_VICECAMPEAO, ID_TIME_VICECAMPEAO)
					VALUES (pIdTemp, pIdCamp, _idUsu2, _IdTimeAway, _idUsu1, _IdTimeHome);

				ELSE
					UPDATE TB_HISTORICO_TEMPORADA_PRO
					SET PT_VICECAMPEAO = (PT_VICECAMPEAO+pPtsVice),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu1;

					INSERT INTO TB_HISTORICO_CONQUISTA_PRO (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO_CAMPEAO, ID_TIME_CAMPEAO, ID_USUARIO_VICECAMPEAO, ID_TIME_VICECAMPEAO)
					VALUES (pIdTemp, pIdCamp, _idUsu2, _IdTimeAway, _idUsu1, _IdTimeHome);

				END IF;

			ELSEIF ((_sumGolsTime1 > _sumGolsTime2) OR (_sumGolsTime1 = _sumGolsTime2 AND _sumGolsAwayTime1 > _sumGolsAwayTime2)) THEN
			
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsChampion;
				ELSE
					SET _sumCopa = pPtsChampion;
				END IF;
				
				IF pTipo = "FUT" THEN
					UPDATE TB_HISTORICO_TEMPORADA_FUT
					SET PT_CAMPEAO = (PT_CAMPEAO+pPtsChampion),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu1;
				ELSE
					UPDATE TB_HISTORICO_TEMPORADA_PRO
					SET PT_CAMPEAO = (PT_CAMPEAO+pPtsChampion),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu1;
				END IF;
				
				IF pSgCamp IN (pSgLigas) THEN
					SET _sumLiga = pPtsVice;
				ELSE
					SET _sumCopa = pPtsVice;
				END IF;
				
				IF pTipo = "FUT" THEN
					UPDATE TB_HISTORICO_TEMPORADA_FUT
					SET PT_VICECAMPEAO = (PT_VICECAMPEAO+pPtsVice),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu2;

					INSERT INTO TB_HISTORICO_CONQUISTA_FUT (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO_CAMPEAO, ID_TIME_CAMPEAO, ID_USUARIO_VICECAMPEAO, ID_TIME_VICECAMPEAO)
					VALUES (pIdTemp, pIdCamp, _idUsu1, _IdTimeHome, _idUsu2, _IdTimeAway);

				ELSE
					UPDATE TB_HISTORICO_TEMPORADA_PRO
					SET PT_VICECAMPEAO = (PT_VICECAMPEAO+pPtsVice),
						PT_COPAS = (PT_COPAS+_sumCopa),
						PT_LIGAS = (PT_LIGAS+_sumLiga)
					WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsu2;

					INSERT INTO TB_HISTORICO_CONQUISTA_PRO (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO_CAMPEAO, ID_TIME_CAMPEAO, ID_USUARIO_VICECAMPEAO, ID_TIME_VICECAMPEAO)
					VALUES (pIdTemp, pIdCamp, _idUsu1, _IdTimeHome, _idUsu2, _IdTimeAway);

				END IF;

			END IF;
			
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateEachFasePlayoffFUT_PRO` $$
CREATE PROCEDURE `spCalculateEachFasePlayoffFUT_PRO`(
	pIdCamp INTEGER, 
	pSgCamp VARCHAR(4), 
	pIdFasePlayoff INTEGER,
	pTipoFasePlayoff VARCHAR(10),
	pPtsFasePlayoff INTEGER, 
	pSgLigas VARCHAR(50), pTipo VARCHAR(3)
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
		WHERE J.ID_CAMPEONATO = pIdCamp
		AND J.ID_FASE = pIdFasePlayoff
		AND J.IN_NUMERO_RODADA = 1  & _
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

			IF pTipo = "FUT" THEN
				UPDATE TB_HISTORICO_TEMPORADA_FUT
				SET PT_CLASSIF_FASE2 = (PT_CLASSIF_FASE2+pPtsFasePlayoff),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);
			ELSE
				UPDATE TB_HISTORICO_TEMPORADA_PRO
				SET PT_CLASSIF_FASE2 = (PT_CLASSIF_FASE2+pPtsFasePlayoff),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);
			END IF;

		ELSEIF pTipoFasePlayoff = "OITAVAS" THEN

			IF pTipo = "FUT" THEN
				UPDATE TB_HISTORICO_TEMPORADA_FUT
				SET PT_OITAVAS = (PT_OITAVAS+pPtsFasePlayoff),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);
			ELSE
				UPDATE TB_HISTORICO_TEMPORADA_PRO
				SET PT_OITAVAS = (PT_OITAVAS+pPtsFasePlayoff),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);
			END IF;

		ELSEIF pTipoFasePlayoff = "QUARTAS" THEN

			IF pTipo = "FUT" THEN
				UPDATE TB_HISTORICO_TEMPORADA_FUT
				SET PT_QUARTAS = (PT_QUARTAS+pPtsFasePlayoff),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);
			ELSE
				UPDATE TB_HISTORICO_TEMPORADA_PRO
				SET PT_QUARTAS = (PT_QUARTAS+pPtsFasePlayoff),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);
			END IF;

		ELSEIF pTipoFasePlayoff = "SEMI" THEN

			IF pTipo = "FUT" THEN
				UPDATE TB_HISTORICO_TEMPORADA_FUT
				SET PT_SEMIS = (PT_SEMIS+pPtsFasePlayoff),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);
			ELSE
				UPDATE TB_HISTORICO_TEMPORADA_PRO
				SET PT_SEMIS = (PT_SEMIS+pPtsFasePlayoff),
					PT_COPAS = (PT_COPAS+_sumCopa),
					PT_LIGAS = (PT_LIGAS+_sumLiga)
				WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);
			END IF;

		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculatePassNextFaseFUT_PRO` $$
CREATE PROCEDURE `spCalculatePassNextFaseFUT_PRO`(
	pIdCamp INTEGER, 
	pSgCamp VARCHAR(4), 
	pIdNextFase INTEGER, 
	pPtsCalssifFase2 INTEGER, 
	pSgLigas VARCHAR(50), pTipo VARCHAR(3)
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
		 ORDER BY ORDER BY J.DT_TABELA_INICIO_JOGO, J.DS_HORA_JOGO, J.ID_TABELA_JOGO;
 
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
		
		IF pTipo = "FUT" THEN
			UPDATE TB_HISTORICO_TEMPORADA_FUT
			SET PT_CLASSIF_FASE2 = (PT_CLASSIF_FASE2+pPtsCalssifFase2),
				PT_COPAS = (PT_COPAS+_sumCopa),
				PT_LIGAS = (PT_LIGAS+_sumLiga)
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);
		ELSE
			UPDATE TB_HISTORICO_TEMPORADA_PRO
			SET PT_CLASSIF_FASE2 = (PT_CLASSIF_FASE2+pPtsCalssifFase2),
				PT_COPAS = (PT_COPAS+_sumCopa),
				PT_LIGAS = (PT_LIGAS+_sumLiga)
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO IN (_idUsu1, _idUsu2);
		END IF;

	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateCampeonatoLigaFUT` $$
CREATE PROCEDURE `spGenerateCampeonatoLigaFUT`(
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
	pListaTimes VARCHAR(500),
	pInLimiteLstNegra INTEGER
)
Begin
	DECLARE _TipoTimeFUT INTEGER DEFAULT 37;
	DECLARE _SiglaTimeFUT VARCHAR(3) DEFAULT "FUT";
	DECLARE _IdCampLigas VARCHAR(5) DEFAULT "8,9";
	DECLARE _IdCampBco INTEGER DEFAULT 7;
	DECLARE _idCamp INTEGER DEFAULT NULL;
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE _countTecnicos INTEGER DEFAULT 0;
	
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
		
		DELETE FROM TB_GRUPO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_POTE_TIME_GRUPO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_CAMPEONATO_TIME WHERE ID_CAMPEONATO = _idCamp;
	
		SET _countTecnicos = fcAddTecnicos(pIdTemp, _idCamp, _IdCampLigas, _IdCampBco, pQtTimes, pInLimiteLstNegra, _SiglaTimeFUT, _TipoTimeFUT);
		SET _countTecnicos = fcAddTecnicosBco(pIdTemp, _idCamp, _IdCampBco, pQtTimes, pInLimiteLstNegra, _countTecnicos, _SiglaTimeFUT, _TipoTimeFUT);


		call `arenafifadb`.`spAddLoadClassificacaoInitialOfCampeonatov2`(_idCamp);
		
		call `arenafifadb`.`spAssumeTimes`(_idCamp);
	END IF;

	SELECT _idCamp as idNewCampeonato, _countTecnicos as QtdTimes;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateCampeonatoCopaFUT` $$
CREATE PROCEDURE `spGenerateCampeonatoCopaFUT`(
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
	DECLARE _SiglaTimeFUT VARCHAR(3) DEFAULT "FUT";
	DECLARE _idCamp INTEGER DEFAULT NULL;
	
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
		DELETE FROM TB_GRUPO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_POTE_TIME_GRUPO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_CAMPEONATO_TIME WHERE ID_CAMPEONATO = _idCamp;
		
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, -1, 1);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 2, 2);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 3, 3);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 4, 4);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 5, 5);
		
		call `arenafifadb`.`spAddTecnicosFromLigasToCampeonatoTimeUsuario`(_idCamp, pIdsCampLiga);
		call `arenafifadb`.`spAddLoadClassificacaoInitialOfCampeonatov2`(_idCamp);
		
		IF (pListaTimesPreCopa<>"") THEN
			call `arenafifadb`.`spAddListaTimesPreCopa`(_idCamp, pListaTimesPreCopa, _SiglaTimeFUT);
		END IF;

		call `arenafifadb`.`spAssumeTimes`(_idCamp);
	END IF;

	SELECT _idCamp as idNewCampeonato;
	
End$$
DELIMITER ;



