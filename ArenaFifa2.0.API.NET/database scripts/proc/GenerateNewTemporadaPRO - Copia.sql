USE `arenafifadb`;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateEndOfTemporadaH2H` $$
CREATE PROCEDURE `spCalculateEndOfTemporadaH2H`(pIdTemp INTEGER, pDataInicio DATE)
Begin
	DECLARE _idNewTemp INTEGER DEFAULT NULL;

	UPDATE TB_CAMPEONATO SET IN_CAMPEONATO_ATIVO = FALSE WHERE SG_TIPO_CAMPEONATO NOT IN ('CDA');
	
	SET _idNewTemp = spAddNewTemporadaByFimOldOne(CONCAT(pIdTemp, " º Temporada"), pDataInicio);
	
	call `arenafifadb`.`spCalculateEndOfTemporadaH2H`(pIdTemp, _idNewTemp);
	
	SELECT _idNewTemp as NewTemporada;

End$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateEndOfTemporadaH2H` $$
CREATE PROCEDURE `spCalculateEndOfTemporadaH2H`(pIdTemp INTEGER, pIdTempNew INTEGER)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _sgCampLessH2H VARCHAR(50) DEFAULT "'CDA', 'LFUT','FUT1','FUT2','CFUT', 'PRO1','PRO2','CPRO'";
	DECLARE _sgLigasH2H VARCHAR(50) DEFAULT "'DIV1', 'DIV2','DIV3','DIV4'";
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
		AND C.SG_TIPO_CAMPEONATO NOT IN (_sgCampLessH2H)
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
			call `arenafifadb`.`spAddHistoricoTemporada`(pIdTemp, _idUsuHome, NULL);
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
		
		UPDATE TB_HISTORICO_TEMPORADA
		SET PT_EMPATES_FASE1 = (PT_EMPATES_FASE1+_sumEmpate),
		    PT_VITORIAS_FASE1 = (PT_VITORIAS_FASE1+_sumVitoria),
			PT_COPAS = (PT_COPAS+_sumCopa),
			PT_LIGAS = (PT_LIGAS+_sumLiga)
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsuHome;


		SELECT count(1) into _count FROM TB_HISTORICO_TEMPORADA WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsuAway;
		IF _count = 0 THEN
			call `arenafifadb`.`spAddHistoricoTemporada`(pIdTemp, _idUsuAway, NULL);
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
		
		UPDATE TB_HISTORICO_TEMPORADA
		SET PT_EMPATES_FASE1 = (PT_EMPATES_FASE1+_sumEmpate),
		    PT_VITORIAS_FASE1 = (PT_VITORIAS_FASE1+_sumVitoria),
			PT_COPAS = (PT_COPAS+_sumCopa),
			PT_LIGAS = (PT_LIGAS+_sumLiga)
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsuAway;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	#Calculando fases playoff....
	call `arenafifadb`.`spCalculateFasePlayoffH2H`(pIdTemp, _sgCampLessH2H, _sgLigasH2H);

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


	DECLARE tabela_cursor CURSOR FOR
		SELECT C.ID_CAMPEONATO, C.SG_TIPO_CAMPEONATO, C.IN_SISTEMA_IDA_VOLTA FROM TB_CAMPEONATO C 
		WHERE C.ID_TEMPORADA = pIdTemp AND C.SG_TIPO_CAMPEONATO NOT IN (pSgCampLessH2H) ORDER BY C.ID_CAMPEONATO;
	
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
		call `arenafifadb`.`spCalculatePassNextFaseH2H`(_idCamp, _sgCamp, _idNextFase, _ptsCalssifFase2, pSgLigas);

		#Calculando Fases Seguintes de Playoff....
		#2a Fase
		call `arenafifadb`.`spCalculateEachFasePlayoffH2H`(_idCamp, _sgCamp, 1, "FASE2", _ptsFase2, pSgLigas);
		
		#Oitavas
		call `arenafifadb`.`spCalculateEachFasePlayoffH2H`(_idCamp, _sgCamp, 2, "OITAVAS", _ptsRound16, pSgLigas);

		#Quartas
		call `arenafifadb`.`spCalculateEachFasePlayoffH2H`(_idCamp, _sgCamp, 3, "QUARTAS", _ptsQuarter, pSgLigas);

		#Semi
		call `arenafifadb`.`spCalculateEachFasePlayoffH2H`(_idCamp, _sgCamp, 4, "SEMI", _ptsSemi, pSgLigas);

		#Campeao e Vice
		IF _inIdaEVolta = false THEN
			call `arenafifadb`.`spCalculateChampionAndViceH2H`(pIdTemp, _idCamp, _sgCamp, _ptsChampion, _ptsVice, pSgLigas, 0, "1");
		ELSE
			call `arenafifadb`.`spCalculateChampionAndViceH2H`(pIdTemp, _idCamp, _sgCamp, _ptsChampion, _ptsVice, pSgLigas, 1, "1,2");
		END IF;
		
		#Artilharia
		call `arenafifadb`.`spCalculateScorersH2H`(pIdTemp, _idCamp);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	UPDATE TB_HISTORICO_TEMPORADA 
	SET PT_TOTAL = (PT_CAMPEAO+PT_VICECAMPEAO+PT_SEMIS+PT_QUARTAS+PT_OITAVAS+PT_CLASSIF_FASE2+PT_VITORIAS_FASE1+PT_EMPATES_FASE1),
	    PT_TOTAL_TEMPORADA = (PT_LIGAS+PT_COPAS)
	WHERE ID_TEMPORADA = pIdTemp;
	
	SELECT ID_TEMPORADA into _idPreviousTemp FROM FROM TB_HISTORICO_TEMPORADA  WHERE ID_TEMPORADA < pIdTemp ORDER BY ID_TEMPORADA DESC LIMIT 1;
	
	#Atualizando Aproveitamento dos técnicos....
	call `arenafifadb`.`spPrepareToCalculatePerformanceTecnicosH2H`(pIdTemp, _idPreviousTemp, pSgLigas);
	
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
		
		SELECT PT_TOTAL into _totPreviusTemp FROM TB_HISTORICO_TEMPORADA B WHERE ID_TEMPORADA = pIdPreviousTemp AND ID_USUARIO = pIdUsu;
		IF _totPreviusTemp IS NULL THEN
			UPDATE TB_HISTORICO_TEMPORADA
			SET PT_TOTAL_TEMPORADA_ANTERIOR = PT_TOTAL_TEMPORADA
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
		ELSE
			UPDATE TB_HISTORICO_TEMPORADA
			SET PT_TOTAL_TEMPORADA_ANTERIOR = _totPreviusTemp, PT_TOTAL = (PT_TOTAL+_totPreviusTemp)
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
		END IF;
		
		
		call `arenafifadb`.`spCalculatePerformanceTecnicosH2H`(pIdTemp, _idUsu, pSgLigas);
		
		call `arenafifadb`.`spCalculatePerformanceGeralTecnicosH2H`(pIdTemp, _idUsu, pSgLigas);
		
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
	pSgLigas VARCHAR(50)
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
	pIdCamp INTEGER
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
		WHERE X.ID_GOLEADOR = G.ID_GOLEADOR
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
DROP PROCEDURE IF EXISTS `spPrepareComentariosDB` $$
CREATE PROCEDURE `spPrepareComentariosDB`()
Begin
	DECLARE _idTabelaIni INTEGER DEFAULT NULL;
	DECLARE _idTabelaFim INTEGER DEFAULT NULL;
	DECLARE _idTimeFim INTEGER DEFAULT NULL;
	DECLARE _idUsuFim INTEGER DEFAULT NULL;
	DECLARE _idFaseFim INTEGER DEFAULT NULL;
	DECLARE _idGoleadorFim INTEGER DEFAULT NULL;
	
	call `arenafifadb`.`spCreateTablesComentariosDB`();
	
	SELECT max(ID_TIME) into _idTimeFim FROM arena_comments.TB_TIME;
	SELECT max(ID_USUARIO) into _idUsuFim FROM arena_comments.TB_USUARIO;
	SELECT max(ID_GOLEADOR) into _idGoleadorFim FROM arena_comments.TB_GOLEADOR;
	SELECT max(ID_FASE) into _idFaseFim FROM arena_comments.TB_FASE;
	
	
	
	INSERT INTO arena_comments.TB_TEMPORADA SELECT * FROM arenafifadb.TB_TEMPORADA WHERE ID_TEMPORADA = (pIdTemp-1);
	INSERT INTO arena_comments.TB_CAMPEONATO SELECT * FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1);
	
	
	
	INSERT INTO arena_comments.TB_TIME SELECT * FROM arenafifadb.TB_TIME WHERE ID_TIME > _idTimeFim;
	INSERT INTO arena_comments.TB_USUARIO SELECT * FROM arenafifadb.TB_USUARIO WHERE ID_USUARIO > _idUsuFim;
	INSERT INTO arena_comments.TB_GOLEADOR SELECT * FROM arenafifadb.TB_GOLEADOR WHERE ID_GOLEADOR > _idGoleadorFim;
	INSERT INTO arena_comments.TB_FASE SELECT * FROM arenafifadb.TB_FASE WHERE ID_FASE > _idFaseFim;
	
	
	
	INSERT INTO arena_comments.TB_CAMPEONATO_TIME SELECT * FROM arenafifadb.TB_CAMPEONATO_TIME
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));

	INSERT INTO arena_comments.TB_CAMPEONATO_USUARIO SELECT * FROM arenafifadb.TB_CAMPEONATO_USUARIO
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));

	INSERT INTO arena_comments.TB_CLASSIFICACAO SELECT * FROM arenafifadb.TB_CLASSIFICACAO
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));

	INSERT INTO arena_comments.TB_FASE_CAMPEONATO SELECT * FROM arenafifadb.TB_FASE_CAMPEONATO
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));

	INSERT INTO arena_comments.TB_GRUPO SELECT * FROM arenafifadb.TB_GRUPO
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));
	
	INSERT INTO arena_comments.TB_USUARIO_TIME SELECT * FROM arenafifadb.TB_USUARIO_TIME
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));
	
	
	
	SELECT min(ID_TABELA_JOGO), max(ID_TABELA_JOGO) into _idTabelaIni, _idTabelaFim FROM arenafifadb.TB_TABELA_JOGO 
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));
	
	INSERT INTO arena_comments.TB_COMENTARIO_JOGO_20 SELECT *, NULL FROM arenafifadb.TB_COMENTARIO_JOGO 
	WHERE ID_TABELA_JOGO >= _idTabelaIni AND ID_TABELA_JOGO <= _idTabelaFim;
	
	UPDATE arena_comments.TB_COMENTARIO_JOGO_20 C
	INNER JOIN arena_comments.TB_USUARIO U ON C.ID_USUARIO = U.ID_USUARIO 
	SET C.PSN_ID = U.PSN_ID
	WHERE C.PSN_ID IS NULL;

	INSERT INTO arena_comments.TB_GOLEADOR_JOGO_20 SELECT *, NULL FROM arenafifadb.TB_GOLEADOR_JOGO 
	WHERE ID_TABELA_JOGO >= _idTabelaIni AND ID_TABELA_JOGO <= _idTabelaFim;

	INSERT INTO arena_comments.TB_TABELA_JOGO_20 SELECT *, NULL FROM arenafifadb.TB_TABELA_JOGO 
	WHERE ID_TABELA_JOGO >= _idTabelaIni AND ID_TABELA_JOGO <= _idTabelaFim;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spCreateTablesComentariosDB` $$
CREATE PROCEDURE `spCreateTablesComentariosDB`()
Begin
	DROP TABLE IF EXISTS `arena_comments`.`TB_COMENTARIO_JOGO_20`;
	DROP TABLE IF EXISTS `arena_comments`.`TB_GOLEADOR_JOGO_20`;
	DROP TABLE IF EXISTS `arena_comments`.`TB_TABELA_JOGO_20`;
	
	CREATE TABLE `arena_comments`.`TB_COMENTARIO_JOGO_20` (
	  `ID_COMENTARIO` INTEGER NOT NULL AUTO_INCREMENT, 
	  `ID_TABELA_JOGO` INTEGER NOT NULL DEFAULT 0, 
	  `ID_USUARIO` INTEGER NOT NULL DEFAULT 0, 
	  `DT_COMENTARIO` DATETIME NOT NULL, 
	  `HR_COMENTARIO` VARCHAR(8) NOT NULL, 
	  `DS_COMENTARIO` LONGTEXT NOT NULL, 
	  `PSN_ID` VARCHAR(30), 
	  INDEX (`ID_TABELA_JOGO`, `ID_USUARIO`, `DT_COMENTARIO`, `HR_COMENTARIO`, `DS_COMENTARIO`(100)), 
	  PRIMARY KEY (`ID_COMENTARIO`)
	) ENGINE=myisam DEFAULT CHARSET=utf8;
	
	CREATE TABLE `arena_comments`.`TB_GOLEADOR_JOGO_20` (
	  `ID_TABELA_JOGO` INTEGER NOT NULL, 
	  `ID_CAMPEONATO` INTEGER NOT NULL, 
	  `ID_TIME` INTEGER NOT NULL, 
	  `ID_GOLEADOR` INTEGER NOT NULL, 
	  `QT_GOLS` INTEGER, 
	  INDEX (`ID_CAMPEONATO`, `QT_GOLS`, `ID_TIME`), 
	  PRIMARY KEY (`ID_CAMPEONATO`, `ID_TABELA_JOGO`, `ID_TIME`, `ID_GOLEADOR`)
	) ENGINE=myisam DEFAULT CHARSET=utf8;

	CREATE TABLE `arena_comments`.`TB_TABELA_JOGO_20` (
	  `ID_TABELA_JOGO` INTEGER NOT NULL AUTO_INCREMENT, 
	  `ID_CAMPEONATO` INTEGER NOT NULL DEFAULT 0, 
	  `ID_FASE` INTEGER NOT NULL DEFAULT 0, 
	  `DT_TABELA_INICIO_JOGO` DATETIME NOT NULL, 
	  `DT_TABELA_FIM_JOGO` DATETIME NOT NULL, 
	  `ID_TIME_CASA` INTEGER NOT NULL DEFAULT 0, 
	  `QT_GOLS_TIME_CASA` INTEGER, 
	  `ID_TIME_VISITANTE` INTEGER NOT NULL DEFAULT 0, 
	  `QT_GOLS_TIME_VISITANTE` INTEGER, 
	  `DT_EFETIVACAO_JOGO` DATETIME, 
	  `IN_NUMERO_RODADA` INTEGER DEFAULT 0, 
	  `IN_DISPUTA_3o_4o` INTEGER, 
	  `DT_SORTEIO` DATETIME NOT NULL, 
	  `DS_HORA_JOGO` VARCHAR(10), 
	  `ID_USUARIO_TIME_CASA` INTEGER, 
	  `ID_USUARIO_TIME_VISITANTE` INTEGER, 
	  `IN_JOGO_MATAXMATA` INTEGER, 
	  `DT_ULTIMA_EFETIVACAO` DATETIME, 
	  `DS_LOGIN_EFETIVACAO` VARCHAR(30), 
	  INDEX (`IN_JOGO_MATAXMATA`, `IN_NUMERO_RODADA`, `ID_TABELA_JOGO`), 
	  PRIMARY KEY (`ID_TABELA_JOGO`), 
	  INDEX (`ID_CAMPEONATO`, `DT_TABELA_INICIO_JOGO`), 
	  INDEX (`ID_CAMPEONATO`, `ID_TIME_CASA`, `ID_TIME_VISITANTE`), 
	  INDEX (`DT_EFETIVACAO_JOGO`, `ID_TABELA_JOGO`), 
	  INDEX (`DT_TABELA_INICIO_JOGO`, `ID_CAMPEONATO`), 
	  INDEX (`ID_TABELA_JOGO`, `ID_CAMPEONATO`, `ID_FASE`), 
	  INDEX (`ID_CAMPEONATO`, `ID_FASE`), 
	  INDEX (`ID_CAMPEONATO`, `ID_FASE`, `IN_NUMERO_RODADA`, `ID_TIME_CASA`, `ID_TIME_VISITANTE`), 
	  INDEX (`ID_CAMPEONATO`, `DT_EFETIVACAO_JOGO`), 
	  INDEX (`IN_NUMERO_RODADA`), 
	  INDEX (`ID_CAMPEONATO`, `DT_TABELA_INICIO_JOGO`, `DT_TABELA_FIM_JOGO`, `ID_FASE`), 
	  INDEX (`ID_CAMPEONATO`, `ID_FASE`, `IN_NUMERO_RODADA`, `DT_EFETIVACAO_JOGO`)
	) ENGINE=myisam DEFAULT CHARSET=utf8;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spInitializeProxTemporada` $$
CREATE PROCEDURE `spInitializeProxTemporada`()
Begin
	DECLARE _count INTEGER DEFAULT NULL;
	DECLARE _nmTable VARCHAR(100) DEFAULT NULL;

	#DECLARE tabela_cursor CURSOR FOR
	#SELECT TABLE_NAME FROM information_schema.tables WHERE TABLE_SCHEMA = "arenafifadb";
	#SELECT concat('INSERT INTO arenafifadb.', TABLE_NAME, ' SELECT * FROM arenafifadb_bkp.', TABLE_NAME, ';') FROM information_schema.TABLES WHERE TABLE_SCHEMA = "arenafifadb";
	#SELECT ROUTINE_NAME FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA  = "arenafifadb"
	#SELECT concat('DROP PROCEDURE ', ROUTINE_NAME, ';') FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA  = "arenafifadb" AND ROUTINE_TYPE  = "PROCEDURE"
	#SELECT concat('DROP FUNCTION ', ROUTINE_NAME, ';') FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA  = "arenafifadb" AND ROUTINE_TYPE  = "FUNCTION"
	
	SELECT count(1) into _count FROM arenafifadb_bkp.TB_CAMPEONATO;
	
	IF _count = 0 THEN
	
		call `arenafifadb`.`spDeleteAllRecordsFromBKP`();
		call `arenafifadb`.`spTransferDataFromDBToBKP`();
			
	ELSE
	
		call `arenafifadb`.`spDeleteAllRecordsFromDB`();
		call `arenafifadb`.`spTransferDataFromBKPToDB`();
			
	END IF;
	
	SELECT fcGetIdTempCurrent() as CurrentTemporada;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spTransferDataFromDBToBKP` $$
CREATE PROCEDURE `spTransferDataFromDBToBKP`()
Begin
	INSERT INTO arenafifadb_bkp.tb_campeonato SELECT * FROM arenafifadb.tb_campeonato;
	INSERT INTO arenafifadb_bkp.tb_campeonato_time SELECT * FROM arenafifadb.tb_campeonato_time;
	INSERT INTO arenafifadb_bkp.tb_campeonato_usuario SELECT * FROM arenafifadb.tb_campeonato_usuario;
	INSERT INTO arenafifadb_bkp.tb_campeonato_usuario_seg_fase SELECT * FROM arenafifadb.tb_campeonato_usuario_seg_fase;
	INSERT INTO arenafifadb_bkp.tb_classificacao SELECT * FROM arenafifadb.tb_classificacao;
	INSERT INTO arenafifadb_bkp.tb_comentario_jogo SELECT * FROM arenafifadb.tb_comentario_jogo;
	INSERT INTO arenafifadb_bkp.tb_comentario_usuario SELECT * FROM arenafifadb.tb_comentario_usuario;
	INSERT INTO arenafifadb_bkp.tb_confirm_elenco_pro SELECT * FROM arenafifadb.tb_confirm_elenco_pro;
	INSERT INTO arenafifadb_bkp.tb_confirmacao_temporada SELECT * FROM arenafifadb.tb_confirmacao_temporada;
	INSERT INTO arenafifadb_bkp.tb_fase SELECT * FROM arenafifadb.tb_fase;
	INSERT INTO arenafifadb_bkp.tb_fase_campeonato SELECT * FROM arenafifadb.tb_fase_campeonato;
	INSERT INTO arenafifadb_bkp.tb_goleador SELECT * FROM arenafifadb.tb_goleador;
	INSERT INTO arenafifadb_bkp.tb_goleador_jogo SELECT * FROM arenafifadb.tb_goleador_jogo;
	INSERT INTO arenafifadb_bkp.tb_grupo SELECT * FROM arenafifadb.tb_grupo;
	INSERT INTO arenafifadb_bkp.tb_historico_alt_campeonato SELECT * FROM arenafifadb.tb_historico_alt_campeonato;
	INSERT INTO arenafifadb_bkp.tb_historico_alt_usuario SELECT * FROM arenafifadb.tb_historico_alt_usuario;
	INSERT INTO arenafifadb_bkp.tb_historico_artilharia SELECT * FROM arenafifadb.tb_historico_artilharia;
	INSERT INTO arenafifadb_bkp.tb_historico_artilharia_pro SELECT * FROM arenafifadb.tb_historico_artilharia_pro;
	INSERT INTO arenafifadb_bkp.tb_historico_atual SELECT * FROM arenafifadb.tb_historico_atual;
	INSERT INTO arenafifadb_bkp.tb_historico_classificacao SELECT * FROM arenafifadb.tb_historico_classificacao;
	INSERT INTO arenafifadb_bkp.tb_historico_conquista SELECT * FROM arenafifadb.tb_historico_conquista;
	INSERT INTO arenafifadb_bkp.tb_historico_conquista_fut SELECT * FROM arenafifadb.tb_historico_conquista_fut;
	INSERT INTO arenafifadb_bkp.tb_historico_conquista_pro SELECT * FROM arenafifadb.tb_historico_conquista_pro;
	INSERT INTO arenafifadb_bkp.tb_historico_temporada SELECT * FROM arenafifadb.tb_historico_temporada;
	INSERT INTO arenafifadb_bkp.tb_historico_temporada_fut SELECT * FROM arenafifadb.tb_historico_temporada_fut;
	INSERT INTO arenafifadb_bkp.tb_historico_temporada_pro SELECT * FROM arenafifadb.tb_historico_temporada_pro;
	INSERT INTO arenafifadb_bkp.tb_historico_transmissao_aovivo SELECT * FROM arenafifadb.tb_historico_transmissao_aovivo;
	INSERT INTO arenafifadb_bkp.tb_lista_banco_reserva SELECT * FROM arenafifadb.tb_lista_banco_reserva;
	INSERT INTO arenafifadb_bkp.tb_lista_negra SELECT * FROM arenafifadb.tb_lista_negra;
	INSERT INTO arenafifadb_bkp.tb_lista_negra_detalhe SELECT * FROM arenafifadb.tb_lista_negra_detalhe;
	INSERT INTO arenafifadb_bkp.tb_palpite_jogo SELECT * FROM arenafifadb.tb_palpite_jogo;
	INSERT INTO arenafifadb_bkp.tb_pontuacao_campeonato SELECT * FROM arenafifadb.tb_pontuacao_campeonato;
	INSERT INTO arenafifadb_bkp.tb_pote_time_grupo SELECT * FROM arenafifadb.tb_pote_time_grupo;
	INSERT INTO arenafifadb_bkp.tb_resultados_lancados SELECT * FROM arenafifadb.tb_resultados_lancados;
	INSERT INTO arenafifadb_bkp.tb_tabela_jogo SELECT * FROM arenafifadb.tb_tabela_jogo;
	INSERT INTO arenafifadb_bkp.tb_temporada SELECT * FROM arenafifadb.tb_temporada;
	INSERT INTO arenafifadb_bkp.tb_time SELECT * FROM arenafifadb.tb_time;
	INSERT INTO arenafifadb_bkp.tb_times_fase_precopa SELECT * FROM arenafifadb.tb_times_fase_precopa;
	INSERT INTO arenafifadb_bkp.tb_tipo_campeonato SELECT * FROM arenafifadb.tb_tipo_campeonato;
	INSERT INTO arenafifadb_bkp.tb_tipo_time SELECT * FROM arenafifadb.tb_tipo_time;
	INSERT INTO arenafifadb_bkp.tb_ultimos_acontecimentos SELECT * FROM arenafifadb.tb_ultimos_acontecimentos;
	INSERT INTO arenafifadb_bkp.tb_usuario SELECT * FROM arenafifadb.tb_usuario;
	INSERT INTO arenafifadb_bkp.tb_usuario_time SELECT * FROM arenafifadb.tb_usuario_time;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spTransferDataFromBKPToDB` $$
CREATE PROCEDURE `spTransferDataFromBKPToDB`()
Begin
	INSERT INTO arenafifadb.tb_campeonato SELECT * FROM arenafifadb_bkp.tb_campeonato;
	INSERT INTO arenafifadb.tb_campeonato_time SELECT * FROM arenafifadb_bkp.tb_campeonato_time;
	INSERT INTO arenafifadb.tb_campeonato_usuario SELECT * FROM arenafifadb_bkp.tb_campeonato_usuario;
	INSERT INTO arenafifadb.tb_campeonato_usuario_seg_fase SELECT * FROM arenafifadb_bkp.tb_campeonato_usuario_seg_fase;
	INSERT INTO arenafifadb.tb_classificacao SELECT * FROM arenafifadb_bkp.tb_classificacao;
	INSERT INTO arenafifadb.tb_comentario_jogo SELECT * FROM arenafifadb_bkp.tb_comentario_jogo;
	INSERT INTO arenafifadb.tb_comentario_usuario SELECT * FROM arenafifadb_bkp.tb_comentario_usuario;
	INSERT INTO arenafifadb.tb_confirm_elenco_pro SELECT * FROM arenafifadb_bkp.tb_confirm_elenco_pro;
	INSERT INTO arenafifadb.tb_confirmacao_temporada SELECT * FROM arenafifadb_bkp.tb_confirmacao_temporada;
	INSERT INTO arenafifadb.tb_fase SELECT * FROM arenafifadb_bkp.tb_fase;
	INSERT INTO arenafifadb.tb_fase_campeonato SELECT * FROM arenafifadb_bkp.tb_fase_campeonato;
	INSERT INTO arenafifadb.tb_goleador SELECT * FROM arenafifadb_bkp.tb_goleador;
	INSERT INTO arenafifadb.tb_goleador_jogo SELECT * FROM arenafifadb_bkp.tb_goleador_jogo;
	INSERT INTO arenafifadb.tb_grupo SELECT * FROM arenafifadb_bkp.tb_grupo;
	INSERT INTO arenafifadb.tb_historico_alt_campeonato SELECT * FROM arenafifadb_bkp.tb_historico_alt_campeonato;
	INSERT INTO arenafifadb.tb_historico_alt_usuario SELECT * FROM arenafifadb_bkp.tb_historico_alt_usuario;
	INSERT INTO arenafifadb.tb_historico_artilharia SELECT * FROM arenafifadb_bkp.tb_historico_artilharia;
	INSERT INTO arenafifadb.tb_historico_artilharia_pro SELECT * FROM arenafifadb_bkp.tb_historico_artilharia_pro;
	INSERT INTO arenafifadb.tb_historico_atual SELECT * FROM arenafifadb_bkp.tb_historico_atual;
	INSERT INTO arenafifadb.tb_historico_classificacao SELECT * FROM arenafifadb_bkp.tb_historico_classificacao;
	INSERT INTO arenafifadb.tb_historico_conquista SELECT * FROM arenafifadb_bkp.tb_historico_conquista;
	INSERT INTO arenafifadb.tb_historico_conquista_fut SELECT * FROM arenafifadb_bkp.tb_historico_conquista_fut;
	INSERT INTO arenafifadb.tb_historico_conquista_pro SELECT * FROM arenafifadb_bkp.tb_historico_conquista_pro;
	INSERT INTO arenafifadb.tb_historico_temporada SELECT * FROM arenafifadb_bkp.tb_historico_temporada;
	INSERT INTO arenafifadb.tb_historico_temporada_fut SELECT * FROM arenafifadb_bkp.tb_historico_temporada_fut;
	INSERT INTO arenafifadb.tb_historico_temporada_pro SELECT * FROM arenafifadb_bkp.tb_historico_temporada_pro;
	INSERT INTO arenafifadb.tb_historico_transmissao_aovivo SELECT * FROM arenafifadb_bkp.tb_historico_transmissao_aovivo;
	INSERT INTO arenafifadb.tb_lista_banco_reserva SELECT * FROM arenafifadb_bkp.tb_lista_banco_reserva;
	INSERT INTO arenafifadb.tb_lista_negra SELECT * FROM arenafifadb_bkp.tb_lista_negra;
	INSERT INTO arenafifadb.tb_lista_negra_detalhe SELECT * FROM arenafifadb_bkp.tb_lista_negra_detalhe;
	INSERT INTO arenafifadb.tb_palpite_jogo SELECT * FROM arenafifadb_bkp.tb_palpite_jogo;
	INSERT INTO arenafifadb.tb_pontuacao_campeonato SELECT * FROM arenafifadb_bkp.tb_pontuacao_campeonato;
	INSERT INTO arenafifadb.tb_pote_time_grupo SELECT * FROM arenafifadb_bkp.tb_pote_time_grupo;
	INSERT INTO arenafifadb.tb_resultados_lancados SELECT * FROM arenafifadb_bkp.tb_resultados_lancados;
	INSERT INTO arenafifadb.tb_tabela_jogo SELECT * FROM arenafifadb_bkp.tb_tabela_jogo;
	INSERT INTO arenafifadb.tb_temporada SELECT * FROM arenafifadb_bkp.tb_temporada;
	INSERT INTO arenafifadb.tb_time SELECT * FROM arenafifadb_bkp.tb_time;
	INSERT INTO arenafifadb.tb_times_fase_precopa SELECT * FROM arenafifadb_bkp.tb_times_fase_precopa;
	INSERT INTO arenafifadb.tb_tipo_campeonato SELECT * FROM arenafifadb_bkp.tb_tipo_campeonato;
	INSERT INTO arenafifadb.tb_tipo_time SELECT * FROM arenafifadb_bkp.tb_tipo_time;
	INSERT INTO arenafifadb.tb_ultimos_acontecimentos SELECT * FROM arenafifadb_bkp.tb_ultimos_acontecimentos;
	INSERT INTO arenafifadb.tb_usuario SELECT * FROM arenafifadb_bkp.tb_usuario;
	INSERT INTO arenafifadb.tb_usuario_time SELECT * FROM arenafifadb_bkp.tb_usuario_time;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllRecordsFromBKP` $$
CREATE PROCEDURE `spDeleteAllRecordsFromBKP`()
Begin
	DELETE FROM arenafifadb_bkp.tb_campeonato;
	DELETE FROM arenafifadb_bkp.tb_campeonato_time;
	DELETE FROM arenafifadb_bkp.tb_campeonato_usuario;
	DELETE FROM arenafifadb_bkp.tb_campeonato_usuario_seg_fase;
	DELETE FROM arenafifadb_bkp.tb_classificacao;
	DELETE FROM arenafifadb_bkp.tb_comentario_jogo;
	DELETE FROM arenafifadb_bkp.tb_comentario_usuario;
	DELETE FROM arenafifadb_bkp.tb_confirm_elenco_pro;
	DELETE FROM arenafifadb_bkp.tb_confirmacao_temporada;
	DELETE FROM arenafifadb_bkp.tb_fase;
	DELETE FROM arenafifadb_bkp.tb_fase_campeonato;
	DELETE FROM arenafifadb_bkp.tb_goleador;
	DELETE FROM arenafifadb_bkp.tb_goleador_jogo;
	DELETE FROM arenafifadb_bkp.tb_grupo;
	DELETE FROM arenafifadb_bkp.tb_historico_alt_campeonato;
	DELETE FROM arenafifadb_bkp.tb_historico_alt_usuario;
	DELETE FROM arenafifadb_bkp.tb_historico_artilharia;
	DELETE FROM arenafifadb_bkp.tb_historico_artilharia_pro;
	DELETE FROM arenafifadb_bkp.tb_historico_atual;
	DELETE FROM arenafifadb_bkp.tb_historico_classificacao;
	DELETE FROM arenafifadb_bkp.tb_historico_conquista;
	DELETE FROM arenafifadb_bkp.tb_historico_conquista_fut;
	DELETE FROM arenafifadb_bkp.tb_historico_conquista_pro;
	DELETE FROM arenafifadb_bkp.tb_historico_temporada;
	DELETE FROM arenafifadb_bkp.tb_historico_temporada_fut;
	DELETE FROM arenafifadb_bkp.tb_historico_temporada_pro;
	DELETE FROM arenafifadb_bkp.tb_historico_transmissao_aovivo;
	DELETE FROM arenafifadb_bkp.tb_lista_banco_reserva;
	DELETE FROM arenafifadb_bkp.tb_lista_negra;
	DELETE FROM arenafifadb_bkp.tb_lista_negra_detalhe;
	DELETE FROM arenafifadb_bkp.tb_palpite_jogo;
	DELETE FROM arenafifadb_bkp.tb_pontuacao_campeonato;
	DELETE FROM arenafifadb_bkp.tb_pote_time_grupo;
	DELETE FROM arenafifadb_bkp.tb_resultados_lancados;
	DELETE FROM arenafifadb_bkp.tb_tabela_jogo;
	DELETE FROM arenafifadb_bkp.tb_temporada;
	DELETE FROM arenafifadb_bkp.tb_time;
	DELETE FROM arenafifadb_bkp.tb_times_fase_precopa;
	DELETE FROM arenafifadb_bkp.tb_tipo_campeonato;
	DELETE FROM arenafifadb_bkp.tb_tipo_time;
	DELETE FROM arenafifadb_bkp.tb_ultimos_acontecimentos;
	DELETE FROM arenafifadb_bkp.tb_usuario;
	DELETE FROM arenafifadb_bkp.tb_usuario_time;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllRecordsFromDB` $$
CREATE PROCEDURE `spDeleteAllRecordsFromDB`(pIdTemp INTEGER)
Begin
	DELETE FROM arenafifadb.tb_campeonato;
	DELETE FROM arenafifadb.tb_campeonato_time;
	DELETE FROM arenafifadb.tb_campeonato_usuario;
	DELETE FROM arenafifadb.tb_campeonato_usuario_seg_fase;
	DELETE FROM arenafifadb.tb_classificacao;
	DELETE FROM arenafifadb.tb_comentario_jogo;
	DELETE FROM arenafifadb.tb_comentario_usuario;
	DELETE FROM arenafifadb.tb_confirm_elenco_pro;
	DELETE FROM arenafifadb.tb_confirmacao_temporada;
	DELETE FROM arenafifadb.tb_fase;
	DELETE FROM arenafifadb.tb_fase_campeonato;
	DELETE FROM arenafifadb.tb_goleador;
	DELETE FROM arenafifadb.tb_goleador_jogo;
	DELETE FROM arenafifadb.tb_grupo;
	DELETE FROM arenafifadb.tb_historico_alt_campeonato;
	DELETE FROM arenafifadb.tb_historico_alt_usuario;
	DELETE FROM arenafifadb.tb_historico_artilharia;
	DELETE FROM arenafifadb.tb_historico_artilharia_pro;
	DELETE FROM arenafifadb.tb_historico_atual;
	DELETE FROM arenafifadb.tb_historico_classificacao;
	DELETE FROM arenafifadb.tb_historico_conquista;
	DELETE FROM arenafifadb.tb_historico_conquista_fut;
	DELETE FROM arenafifadb.tb_historico_conquista_pro;
	DELETE FROM arenafifadb.tb_historico_temporada;
	DELETE FROM arenafifadb.tb_historico_temporada_fut;
	DELETE FROM arenafifadb.tb_historico_temporada_pro;
	DELETE FROM arenafifadb.tb_historico_transmissao_aovivo;
	DELETE FROM arenafifadb.tb_lista_banco_reserva;
	DELETE FROM arenafifadb.tb_lista_negra;
	DELETE FROM arenafifadb.tb_lista_negra_detalhe;
	DELETE FROM arenafifadb.tb_palpite_jogo;
	DELETE FROM arenafifadb.tb_pontuacao_campeonato;
	DELETE FROM arenafifadb.tb_pote_time_grupo;
	DELETE FROM arenafifadb.tb_resultados_lancados;
	DELETE FROM arenafifadb.tb_tabela_jogo;
	DELETE FROM arenafifadb.tb_temporada;
	DELETE FROM arenafifadb.tb_time;
	DELETE FROM arenafifadb.tb_times_fase_precopa;
	DELETE FROM arenafifadb.tb_tipo_campeonato;
	DELETE FROM arenafifadb.tb_tipo_time;
	DELETE FROM arenafifadb.tb_ultimos_acontecimentos;
	DELETE FROM arenafifadb.tb_usuario;
	DELETE FROM arenafifadb.tb_usuario_time;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spCreateNewFieldsAndProcess` $$
CREATE PROCEDURE `spCreateNewFieldsAndProcess`(pIdTemp INTEGER)
Begin
	UPDATE TB_TIME SET IN_TIME_EXCLUIDO_TEMP_ATUAL = NULL;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spTransferSquadPROProxTemp` $$
CREATE PROCEDURE `spTransferSquadPROProxTemp`(pIdTemp INTEGER, pIdCamp INTEGER)
Begin
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT C.ID_USUARIO FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U 
		WHERE C.ID_TEMPORADA = pIdTemp AND C.ID_CAMPEONATO = pIdCamp AND C.IN_CONFIRMACAO = 1 AND C.ID_USUARIO = U.ID_USUARIO
		ORDER BY C.ID_USUARIO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
	
		call `arenafifadb`.`spAddElencoPROProxTemp`(pIdTemp, _idUsu, fcGetCurrentIdTimePRO(_idUsu));

	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddElencoPROProxTemp` $$
CREATE PROCEDURE `spAddElencoPROProxTemp`(pIdTemp INTEGER, pIdUsuManager INTEGER, pIdTime INTEGER)
Begin
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT ID_USUARIO FROM TB_GOLEADOR
		WHERE ID_TIME = pIdTime
		ORDER BY ID_USUARIO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;

		insert into TB_CONFIRM_ELENCO_PRO (ID_TEMPORADA, ID_USUARIO_MANAGER, ID_USUARIO, DT_CONFIRMACAO)
		values (pIdTemp, pIdUsuManager, _idUsu, NOW());

	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;



DELIMITER $$
DROP FUNCTION IF EXISTS `fcAddNovoCampeonato` $$
CREATE FUNCTION `fcAddNovoCampeonato`(pIdTemp INTEGER, pTpCamp VARCHAR(4), pInGrupo TINYINT) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idCampOld INTEGER DEFAULT NULL;
	DECLARE _idCampNew INTEGER DEFAULT NULL;
	
	SELECT ID_CAMPEONATO into _idCampOld FROM TB_CAMPEONATO 
	WHERE ID_TEMPORADA <= pIdTemp AND SG_TIPO_CAMPEONATO = pTpCamp AND IN_CAMPEONATO_GRUPO = pInGrupo
	ORDER BY ID_CAMPEONATO DESC
	limit 1;
	
	IF (_idCampOld IS NULL) THEN
	
		SET _idCampNew = 0;
	
	ELSE
	
		INSERT INTO TB_CAMPEONATO SELECT * FROM TB_CAMPEONATO WHERE ID_CAMPEONATO = _idCampOld;
	
		SELECT ID_CAMPEONATO into _idCampNew FROM TB_CAMPEONATO 
		ORDER BY ID_CAMPEONATO DESC
		limit 1;
		
		UPDATE TB_CAMPEONATO
		SET ID_TEMPORADA = pIdTemp, IN_CAMPEONATO_ATIVO = TRUE
		WHERE ID_CAMPEONATO = _idCampNew;
		
		INSERT INTO TB_FASE_CAMPEONATO (ID_CAMPEONATO, ID_FASE, IN_ORDENACAO) 
		SELECT _idCampNew, ID_FASE, IN_ORDENACAO FROM TB_FASE_CAMPEONATO WHERE ID_Campeonato = _idCampOld;
		
		INSERT INTO TB_CAMPEONATO_USUARIO (ID_CAMPEONATO, ID_USUARIO, DT_ENTRADA) 
		SELECT _idCampNew, ID_USUARIO, DT_ENTRADA FROM TB_CAMPEONATO_USUARIO WHERE ID_Campeonato = _idCampOld;
		
		INSERT INTO TB_GRUPO (ID_CAMPEONATO, ID_GRUPO, NM_GRUPO) 
		SELECT _idCampNew, ID_GRUPO, NM_GRUPO FROM TB_GRUPO WHERE ID_Campeonato = _idCampOld;

	END IF;
	
	RETURN _idCampNew;
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
	SELECT ID_TIME FROM TB_TIME WHERE NM_TIME IN (pListaTimes) AND DS_TIPO NOT IN('FUT','PRO') ORDER BY NM_TIME;
	
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
		
		
		call `arenafifadb`.`spAddLoadClassificacaoInitialOfCampeonatov2`(_idCamp);

	END IF;

	SELECT _idCamp as idNewCampeonato;
	
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
DROP PROCEDURE IF EXISTS `spGenerateCampeonatoLigaPRO` $$
CREATE PROCEDURE `spGenerateCampeonatoLigaPRO`(
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
	DECLARE _TipoTimePRO INTEGER DEFAULT 42;
	DECLARE _SiglaTimePRO VARCHAR(3) DEFAULT "PRO";
	DECLARE _IdCampLigas VARCHAR(5) DEFAULT "14,15";
	DECLARE _IdCampBco INTEGER DEFAULT 13;
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
	
		SET _countTecnicos = fcAddTecnicos(pIdTemp, _idCamp, _IdCampLigas, _IdCampBco, pQtTimes, pInLimiteLstNegra, _SiglaTimePRO, _TipoTimePRO);
		SET _countTecnicos = fcAddTecnicosBco(pIdTemp, _idCamp, _IdCampBco, pQtTimes, pInLimiteLstNegra, _countTecnicos, _SiglaTimePRO, _TipoTimePRO);

		call `arenafifadb`.`spAddLoadClassificacaoInitialOfCampeonatov2`(_idCamp);
		
		call `arenafifadb`.`spAssumeTimes`(_idCamp);
	END IF;

	SELECT _idCamp as idNewCampeonato, _countTecnicos as QtdTimes;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAssumeTimes` $$
CREATE PROCEDURE `spAssumeTimes`(
	pIdCamp INTEGER
)
Begin
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _inOrdem INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT C.ID_Time, T.ID_TECNICO_FUT  FROM TB_CAMPEONATO_TIME C, TB_TIME T WHERE C.ID_TIME = T.ID_TIME AND C.ID_CAMPEONATO = pIdCamp;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idTime, _idUsu;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _inOrdem = _inOrdem + 1;
		
		call `arenafifadb`.`spAddUsuarioTimev2`(_idCamp, _idUsu, _idTime, _inOrdem);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;

End$$
DELIMITER ;



DELIMITER $$
DROP FUNCTION IF EXISTS `fcAddTecnicos` $$
CREATE FUNCTION `fcAddTecnicos`(
	pIdTemp INTEGER, pIdNewCamp INTEGER, pIdCampConfirmTemp VARCHAR(10), pIdCampConfirmTempBco INTEGER, 
	pQtdTimes INTEGER, pInLimiteLstNegra INTEGER, pSiglaTime VARCHAR(3), 
	pIdTipoTime INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _inPtosNegativos INTEGER DEFAULT 0;
	DECLARE _countTecnicos INTEGER DEFAULT 0;
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _NmTime VARCHAR(50) DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT X.ID_USUARIO, X.NM_TIME, X.PT_LSTNEGRA FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR, 
	(SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA,
	(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA_FUT H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
	FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
	WHERE C.ID_TEMPORADA = pIdTemp
	AND C.ID_CAMPEONATO in (pIdCampConfirmTemp)
	AND U.IN_USUARIO_ATIVO = TRUE 
	AND U.IN_DESEJA_PARTICIPAR = 1 
	AND C.IN_CONFIRMACAO in (1,9) 
	AND C.ID_USUARIO = U.ID_USUARIO) X
	ORDER BY X.DS_Status, X.IN_USUARIO_MODERADOR, X.IN_CONFIRMACAO DESC, X.PT_TOTAL DESC, X.IN_ORDENACAO, X.DT_CONFIRMACAO, X.ID_Usuario;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _NmTime, _inPtosNegativos;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _countTecnicos = _countTecnicos + 1;
		
		SELECT ID_TIME into _idTime FROM TB_TIME WHERE ID_TECNICO_FUT = pIdUsu AND NM_TIME = _NmTime AND DS_TIPO = pSiglaTime;
		
		IF (_idTime IS NULL) THEN
		
			insert into `TB_TIME` (`NM_TIME`, `ID_TIPO_TIME`, `DS_TIPO`, `ID_TECNICO_FUT`, `IN_TIME_COM_IMAGEM`) 
			values (_NmTime, _TipoTimeFUT, pSiglaTime, _idUsu, 0);
			
			select ID_TIME into _idTime
			from TB_TIME
			order by ID_TIME desc
			limit 1;
		
		END IF;
		
		IF (_countTecnicos <= pQtdTimes AND _inPtosNegativos <= pInLimiteLstNegra) THEN
		
			call `arenafifadb`.`spAddCampeonatoTime`(pIdNewCamp, _idTime);
			
			call `arenafifadb`.`spAddCampeonatoUsuario`(pIdNewCamp, _idUsu);
			
		END IF;
		
		call `arenafifadb`.`spUpdateToEndBancoReserva`(_idUsu, pSiglaTime);
		
		IF (_inPtosNegativos <= pInLimiteLstNegra) THEN
		
			UPDATE TB_CONFIRMACAO_TEMPORADA
			SET ID_CAMPEONATO = pIdCampConfirmTempBco
			WHERE ID_TEMPORADA = pItemp
			AND ID_CAMPEONATO in (pIdCampConfirmTemp) AND ID_USUARIO = _idUsu;
			
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	RETURN _countTecnicos;
End$$
DELIMITER ;






DELIMITER $$
DROP FUNCTION IF EXISTS `fcAddTecnicosBco` $$
CREATE FUNCTION `fcAddTecnicosFUTBco`(
	pIdTemp INTEGER, pIdNewCamp INTEGER, pIdCampConfirmTempBco INTEGER, 
	pQtdTimes INTEGER, pInLimiteLstNegra INTEGER, pCountTecnicos INTEGER, 
	pSiglaTime VARCHAR(3), pIdTipoTime INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _inPtosNegativos INTEGER DEFAULT 0;
	DECLARE _countTecnicos INTEGER DEFAULT 0;
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _NmTime VARCHAR(50) DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT X.ID_USUARIO, X.NM_TIME, X.PT_LSTNEGRA FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR, 
	(SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA,
	(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA_FUT H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
	FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
	WHERE C.ID_TEMPORADA = pIdTemp
	AND C.ID_CAMPEONATO = pIdCampConfirmTempBco
	AND U.IN_USUARIO_ATIVO = TRUE 
	AND U.IN_DESEJA_PARTICIPAR = 1 
	AND C.IN_CONFIRMACAO IN (1,9)
	AND C.NM_TIME IS NOT NULL
	AND C.ID_USUARIO = U.ID_USUARIO) X
	ORDER BY X.DS_Status, X.IN_USUARIO_MODERADOR, X.IN_CONFIRMACAO DESC, X.PT_TOTAL DESC, X.IN_ORDENACAO, X.DT_CONFIRMACAO, X.ID_Usuario;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	SET _countTecnicos = pCountTecnicos;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _NmTime, _inPtosNegativos;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF (_inPtosNegativos <= pInLimiteLstNegra) THEN
		
			SET _countTecnicos = _countTecnicos + 1;
			
			IF (_countTecnicos <= pQtdTimes) THEN
			
				SELECT ID_TIME into _idTime FROM TB_TIME WHERE ID_TECNICO_FUT = pIdUsu AND NM_TIME = _NmTime AND DS_TIPO = pSiglaTime;
				
				IF (_idTime IS NULL) THEN
				
					insert into `TB_TIME` (`NM_TIME`, `ID_TIPO_TIME`, `DS_TIPO`, `ID_TECNICO_FUT`, `IN_TIME_COM_IMAGEM`) 
					values (_NmTime, pIdTipoTime, pSiglaTime, _idUsu, 0);
					
					select ID_TIME into _idTime
					from TB_TIME
					order by ID_TIME desc
					limit 1;
				
					call `arenafifadb`.`spAddCampeonatoTime`(_idCamp, _idTime);
					
					call `arenafifadb`.`spAddCampeonatoUsuario`(_idCamp, _idUsu);
					
					call `arenafifadb`.`spUpdateToEndBancoReserva`(_idUsu, pSiglaTime);
		
				END IF;
				
			END IF;
		
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	RETURN _countTecnicos;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateCampeonatoCopaPRO` $$
CREATE PROCEDURE `spGenerateCampeonatoCopaPRO`(
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
	DECLARE _SiglaTimePRO VARCHAR(3) DEFAULT "PRO";
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
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, -1, 1);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 2, 2);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 3, 3);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 4, 4);
		INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCamp, 5, 5);
		
		DELETE FROM TB_GRUPO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_POTE_TIME_GRUPO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = _idCamp;
		DELETE FROM TB_CAMPEONATO_TIME WHERE ID_CAMPEONATO = _idCamp;
		
		call `arenafifadb`.`spAddTecnicosFromLigasToCampeonatoTimeUsuario`(_idCamp, pIdsCampLiga);
		call `arenafifadb`.`spAddLoadClassificacaoInitialOfCampeonatov2`(_idCamp);
		
		IF (pListaTimesPreCopa<>"") THEN
			call `arenafifadb`.`spAddListaTimesPreCopa`(_idCamp, pListaTimesPreCopa, _SiglaTimePRO);
		END IF;

		call `arenafifadb`.`spAssumeTimes`(_idCamp);
	END IF;

	SELECT _idCamp as idNewCampeonato;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTecnicosFromLigasToCampeonatoTimeUsuario` $$
CREATE PROCEDURE `spAddTecnicosFromLigasToCampeonatoTimeUsuario`(
	pIdCampCopa INTEGER,
	pIdsCampLiga VARCHAR(10)
)
Begin
	call `arenafifadb`.`spAddTecnicosFromLigasToCampeonatoTime`(pIdCampCopa, pIdsCampLiga);
	call `arenafifadb`.`spAddTecnicosFromLigasToCampeonatoUsuario`(pIdCampCopa, pIdsCampLiga);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTecnicosFromLigasToCampeonatoTime` $$
CREATE PROCEDURE `spAddTecnicosFromLigasToCampeonatoTime`(
	pIdCampCopa INTEGER,
	pIdsCampLiga VARCHAR(10)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _id INTEGER DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_TIME FROM TB_CAMPEONATO_TIME WHERE ID_CAMPEONATO IN (pIdsCampLiga) ORDER BY ID_TIME;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _id;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;

		INSERT INTO TB_CAMPEONATO_TIME (ID_CAMPEONATO, ID_TIME) VALUES (pIdCampCopa, _id);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTecnicosFromLigasToCampeonatoUsuario` $$
CREATE PROCEDURE `spAddTecnicosFromLigasToCampeonatoUsuario`(
	pIdCampCopa INTEGER,
	pIdsCampLiga VARCHAR(10)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _id INTEGER DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_USUARIO FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO IN (pIdsCampLiga) ORDER BY ID_USUARIO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _id;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;

		INSERT INTO TB_CAMPEONATO_USUARIO (ID_CAMPEONATO, ID_USUARIO) VALUES (pIdCampCopa, _id);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddListaTimesPreCopa` $$
CREATE PROCEDURE `spAddListaTimesPreCopa`(
	pIdCampCopa INTEGER,
	pListaTimesPreCopa VARCHAR(500),
	pTpCamp VARCHAR(3)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _id INTEGER DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_TIME FROM TB_TIME WHERE NM_TIME IN (pListaTimesPreCopa) AND ID_TIME IN (SELECT ID_TIME FROM TB_CAMPEONATO_TIME 
	WHERE ID_CAMPEONATO = pIdCampCopa AND DS_TIPO = pTpCamp ORDER BY NM_TIME;
	
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
	WHERE ID_CAMPEONATO = pIdCampCopa AND DS_TIPO NO IN ("'FUT', 'PRO'") ORDER BY NM_TIME;
	
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
DROP PROCEDURE IF EXISTS `spSubscriptionPlayersForPROCLUB` $$
CREATE PROCEDURE `spSubscriptionPlayersForPROCLUB`(
	pIdTemp INTEGER,
	pIdCamp INTEGER
)
Begin
	DECLARE _IdPlayerInitial INTEGER DEFAULT 999000;
	DECLARE _idUsuManager INTEGER DEFAULT NULL;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _NmUsu VARCHAR(50) DEFAULT NULL;
	DECLARE _IdPsn VARCHAR(30) DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _countTecnicos INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT C.ID_USUARIO_MANAGER, C.ID_USUARIO, U.NM_USUARIO, U.PSN_ID FROM TB_CONFIRM_ELENCO_PRO C, TB_USUARIO U WHERE C.ID_TEMPORADA = pIdTemp
	AND C.ID_USUARIO_MANAGER IN (SELECT CU.ID_USUARIO FROM TB_CAMPEONATO_USUARIO CU WHERE CU.ID_CAMPEONATO = pIdCamp)
	AND C.ID_USUARIO = U.ID_USUARIO ORDER BY C.ID_USUARIO_MANAGER, C.ID_USUARIO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsuManager, _idUsu, _NmUsu, _IdPsn;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		call `arenafifadb`.`spAddGoleador`(_IdPlayerInitial, fcGetCurrentIdTimePRO(_idUsuManager), _IdPsn, _NmUsu, "...", "PRO CLUB", 0, _idUsu);
		
		SET _IdPlayerInitial = _IdPlayerInitial + 1;

	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
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
		
			call `arenafifadb`.`spAddGrupo`(_idCamp, _count, CONCAT("Grupo ", _count));
		
			SET _count = _count + 1;
		
		END WHILE;
		
		call `arenafifadb`.`spAddTecnicosFromLigasToCampeonatoTimeUsuario`(_idCamp, pIdsCampLiga);
		call `arenafifadb`.`spAddLoadClassificacaoInitialOfCampeonatov2`(_idCamp);
		
		IF (pListaTimesPote <> "") THEN
		
			call `arenafifadb`.`spAddAllPoteTimeGrupoH2H`(_idCamp, pListaTimesPote);
		
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
		
		call `arenafifadb`.`spAddTecnicosFromLigasToCampeonatoTimeUsuario`(_idCamp, pIdsCampLiga);
		call `arenafifadb`.`spAddLoadClassificacaoInitialOfCampeonatov2`(_idCamp);
		
		IF (pListaTimesPreCopa<>"") THEN
			call `arenafifadb`.`spAddListaTimesPreCopaH2H`(_idCamp, pListaTimesPreCopa);
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
DROP PROCEDURE IF EXISTS `spRelocationLigasH2H` $$
CREATE PROCEDURE `spRelocationLigasH2H`(
	pIdTemp INTEGER,
	pIdSerieA INTEGER,
	pIdSerieB INTEGER,
	pIdSerieC INTEGER,
	pQtLimitMaxLstNegra INTEGER,
	pCodAcessoTapetao INTEGER,
	pCodAcesso INTEGER,
	pCodAcessoRelegated INTEGER,
)
Begin
	call `arenafifadb`.`spMoveUpDivisionAboveAcesso`(pIdTemp, pIdSerieA, pIdSerieB, "DIV2", pCodAcesso);
	call `arenafifadb`.`spMoveUpDivisionAboveAcesso`(pIdTemp, pIdSerieB, pIdSerieC, "DIV3", pCodAcesso);
	
	call `arenafifadb`.`spMoveDownDivisionBelowRelegated`(pIdTemp, pIdSerieA, pIdSerieB, "DIV1", pCodAcessoRelegated);
	call `arenafifadb`.`spMoveDownDivisionBelowRelegated`(pIdTemp, pIdSerieB, pIdSerieC, "DIV2", pCodAcessoRelegated);

	#Retirando técnicos que não renovaram nas Séries
	DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO IN (pIdSerieA, pIdSerieB, pIdSerieC)
	AND ID_USUARIO = (SELECT X.ID_USUARIO FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, 
	(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
	FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
	WHERE C.ID_TEMPORADA = pIdTemp AND C.ID_CAMPEONATO in (1,2,3,4) AND U.IN_USUARIO_ATIVO = TRUE
	AND (C.IN_CONFIRMACAO IS NULL OR C.IN_CONFIRMACAO = 0 OR C.IN_CONFIRMACAO = 9 OR C.DS_STATUS = 'NA')
	AND C.ID_USUARIO = U.ID_USUARIO) X ORDER BY X.DS_STATUS, X.IN_CONFIRMACAO DESC, X.PT_TOTAL DESC, X.IN_ORDENACAO);
	
	
	#Retirando técnicos que não renovaram na Série C
	DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdSerieC
	AND ID_USUARIO = (SELECT U.ID_USUARIO FROM TB_CAMPEONATO_USUARIO C, TB_USUARIO U
	WHERE C.ID_CAMPEONATO = pIdSerieC AND (U.IN_USUARIO_ATIVO <> True Or U.IN_DESEJA_PARTICIPAR <> 1)
	AND C.ID_USUARIO = U.ID_USUARIO ORDER BY U.ID_USUARIO);

	
	#Retirando SEM Técnicos das Séries
	DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO IN (pIdSerieA, pIdSerieB, pIdSerieC)
	AND ID_USUARIO = (SELECT U.ID_USUARIO FROM TB_USUARIO U
	WHERE U.ID_USUARIO IN (fcGetIdUsuariosVazio()) ORDER BY U.ID_USUARIO);
	

	#Retirando técnicos que ultrapassaram o limite de pontos negativos nas Séries
	DELETE FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO IN (pIdSerieA, pIdSerieB, pIdSerieC)
	AND ID_USUARIO = (SELECT X.ID_USUARIO FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, 
	(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
	FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U, (SELECT ID_USUARIO, PT_TOTAL FROM TB_LISTA_NEGRA WHERE ID_Temporada = (pIdTemp-1) AND PT_TOTAL > 0) as L
	WHERE C.ID_TEMPORADA = pIdTemp AND C.ID_CAMPEONATO in (1,2,3,4) AND U.IN_USUARIO_ATIVO = TRUE
	AND C.IN_CONFIRMACAO = 1 AND L.PT_TOTAL > pQtLimitMaxLstNegra
	AND C.ID_USUARIO = U.ID_USUARIO AND C.ID_USUARIO = L.ID_USUARIO AND U.ID_USUARIO = L.ID_USUARIO) X 
	ORDER BY X.DS_STATUS, X.IN_CONFIRMACAO DESC, X.PT_TOTAL DESC, X.IN_ORDENACAO);
	
	call `arenafifadb`.`spMoveUpDivisionAboveTapetao`(pIdTemp, pIdSerieA, pIdSerieB, pQtLimitMaxLstNegra, pCodAcessoTapetao);
	call `arenafifadb`.`spMoveUpDivisionAboveTapetao`(pIdTemp, pIdSerieB, pIdSerieC, pQtLimitMaxLstNegra, pCodAcessoTapetao);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spMoveUpDivisionAboveTapetao` $$
CREATE PROCEDURE `spMoveUpDivisionAboveTapetao`(
	pIdTemp INTEGER,
	pIdSerieAbove INTEGER,
	pIdSerieBelow INTEGER,
	pQtLimitMaxLstNegra INTEGER,
	pCodAcessoTapetao INTEGER
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
		SELECT U.ID_USUARIO,
		(SELECT L.PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemp AND L.ID_USUARIO = H.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
		FROM TB_HISTORICO_TEMPORADA H, TB_CAMPEONATO C, TB_CAMPEONATO_USUARIO X, TB_USUARIO U
		WHERE H.ID_TEMPORADA = pIdTemp
		AND C.ID_CAMPEONATO =  pIdSerieBelow
		AND U.ID_USUARIO NOT IN (fcGetIdUsuariosVazio())
		AND H.ID_USUARIO = U.ID_USUARIO
		AND H.ID_USUARIO = X.ID_USUARIO
		AND C.ID_CAMPEONATO = X.ID_CAMPEONATO
		AND X.ID_USUARIO = U.ID_USUARIO
		AND U.IN_DESEJA_PARTICIPAR = 1
		ORDER BY H.IN_ACESSO_TEMP_ATUAL, H.IN_REBAIXADO_TEMP_ANTERIOR, H.PT_TOTAL DESC, NM_USUARIO;
		
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	SELECT count(1) into _countCurrent FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdSerieAbove;
	
	SELECT QT_TIMES into _QtTotalTimes FROM  TB_CAMPEONATO WHERE ID_CAMPEONATO = pIdSerieAbove;
		
	SET _countRest = (_QtTotalTimes-_countCurrent);
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _TotLstNegra;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _count > _countRest THEN
		
			LEAVE get_tabela;
		
		ELSEIF _TotLstNegra <= pQtLimitMaxLstNegra THEN
		
			call `arenafifadb`.`spDeleteCampeonatoUsuario`(pIdSerieBelow, _idUsu);
			call `arenafifadb`.`spAddCampeonatoUsuario`(pIdSerieAbove, _idUsu);
			
			call `arenafifadb`.`spAddHistoricoTemporada`(pIdTemp, _idUsu, pCodAcessoTapetao);
		
			SET _count = _count + 1;

		END IF;
	
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spMoveUpDivisionAboveAcesso` $$
CREATE PROCEDURE `spMoveUpDivisionAboveAcesso`(
	pIdTemp INTEGER,
	pIdSerieAbove INTEGER,
	pIdSerieBelow INTEGER,
	pSgSerieBelowOld VARCHAR(5),
	pCodAcesso INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _IdUsu1 INTEGER DEFAULT 0;
	DECLARE _IdUsu2 INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT TU1.id_usuario, TU2.id_usuario 
		FROM TB_TABELA_JOGO J, TB_TIME T1 , TB_TIME T2, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2, TB_USUARIO TU1, TB_USUARIO TU2, TB_CLASSIFICACAO TC1, TB_CLASSIFICACAO TC2 
		WHERE J.ID_CAMPEONATO = (SELECT ID_CAMPEONATO FROM  TB_CAMPEONATO WHERE ID_TEMPORADA < pIdTemp AND SG_TIPO_CAMPEONATO = pSgSerieBelowOld ORDER BY ID_CAMPEONATO DESC LIMIT 1)
		AND J.ID_FASE = (SELECT ID_FASE FROM TB_FASE WHERE NM_FASE = 'Semi-Final')
		AND J.IN_NUMERO_RODADA = 1
		AND J.ID_TIME_CASA = T1.ID_TIME 
		AND J.ID_TIME_VISITANTE = T2.ID_TIME 
		AND T1.ID_TIME = UT1.ID_TIME 
		AND T2.ID_TIME = UT2.ID_TIME 
		AND UT1.ID_USUARIO = TU1.ID_USUARIO 
		AND UT2.ID_USUARIO = TU2.ID_USUARIO 
		AND UT1.ID_CAMPEONATO = J.ID_CAMPEONATO 
		AND UT2.ID_CAMPEONATO = J.ID_CAMPEONATO 
		AND J.ID_TIME_CASA = TC1.ID_TIME 
		AND J.ID_TIME_VISITANTE = TC2.ID_TIME 
		AND J.ID_CAMPEONATO = TC1.ID_CAMPEONATO 
		AND J.ID_CAMPEONATO = TC2.ID_CAMPEONATO 
		AND UT1.DT_VIGENCIA_FIM is null 
		AND UT2.DT_VIGENCIA_FIM is null 
		ORDER BY J.DT_TABELA_INICIO_JOGO, J.DS_HORA_JOGO, J.ID_TABELA_JOGO LIMIT 2;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _IdUsu1, _IdUsu2;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		call `arenafifadb`.`spDeleteCampeonatoUsuario`(pIdSerieBelow, _IdUsu1);
		call `arenafifadb`.`spAddCampeonatoUsuario`(pIdSerieAbove, _IdUsu1);
		call `arenafifadb`.`spAddHistoricoTemporada`(pIdTemp, _IdUsu1, pCodAcesso);
		
		call `arenafifadb`.`spDeleteCampeonatoUsuario`(pIdSerieBelow, _IdUsu2);
		call `arenafifadb`.`spAddCampeonatoUsuario`(pIdSerieAbove, _IdUsu2);
		call `arenafifadb`.`spAddHistoricoTemporada`(pIdTemp, _IdUsu2, pCodAcesso);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spMoveDownDivisionBelowRelegated` $$
CREATE PROCEDURE `spMoveDownDivisionBelowRelegated`(
	pIdTemp INTEGER,
	pIdSerieAbove INTEGER,
	pIdSerieBelow INTEGER,
	pSgSerieAboveOld VARCHAR(5),
	pCodAcessoRelegated INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _count INTEGER DEFAULT 0;
	DECLARE _IdUsu INTEGER DEFAULT 0;
	DECLARE _QtTimes INTEGER DEFAULT 0;
	DECLARE _QtTimesRelegated INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT U.ID_USUARIO
		FROM TB_CLASSIFICACAO C, TB_TIME T, TB_USUARIO_TIME UT, TB_USUARIO U
		WHERE C.ID_CAMPEONATO = (SELECT ID_CAMPEONATO FROM  TB_CAMPEONATO WHERE ID_TEMPORADA < pIdTemp AND SG_TIPO_CAMPEONATO = pSgSerieAboveOld ORDER BY ID_CAMPEONATO DESC LIMIT 1)
		AND UT.DT_VIGENCIA_FIM IS NULL AND C.ID_TIME = T.ID_TIME AND C.ID_CAMPEONATO = UT.ID_CAMPEONATO AND T.ID_TIME = UT.ID_TIME
		AND UT.ID_USUARIO = U.ID_USUARIO
		ORDER BY C.QT_PONTOS_GANHOS DESC, QT_VITORIAS DESC, (QT_GOLS_PRO-QT_GOLS_CONTRA) DESC, QT_GOLS_PRO DESC, QT_GOLS_CONTRA, T.NM_TIME;
		
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	SELECT QT_TIMES, QT_TIMES_REBAIXADOS into _QtTimes, _QtTimesRelegated FROM  TB_CAMPEONATO 
	WHERE ID_TEMPORADA < pIdTemp AND SG_TIPO_CAMPEONATO = pSgSerieAboveOld ORDER BY ID_CAMPEONATO DESC LIMIT 1;
		
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _IdUsu;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _count = _count + 1;
		
		IF (_QtTimes - _count) < _QtTimesRelegated THEN
		
			call `arenafifadb`.`spDeleteCampeonatoUsuario`(pIdSerieAbove, _IdUsu);
			call `arenafifadb`.`spAddCampeonatoUsuario`(pIdSerieBelow, _IdUsu);
			call `arenafifadb`.`spUpdateHistoricoTempTecnicoRelegated`(pIdTemp, _IdUsu, pCodAcessoRelegated);
			
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spMoveOnDivisionInitialize` $$
CREATE PROCEDURE `spMoveOnDivisionInitialize`(
	pIdTemp INTEGER,
	pIdSerieB INTEGER,
	pIdSerieC INTEGER,
	pQtLimitMaxLstNegra INTEGER,
	pCodAcessoConvite INTEGER
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
		SELECT X.ID_USUARIO, X.PT_LSTNEGRA FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR, 
		(SELECT L.PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) & AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA, 
		(SELECT top 1 H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc) as PT_TOTAL 
		FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U  
		WHERE C.ID_TEMPORADA = pIdTemp
		AND C.ID_CAMPEONATO = 0
		AND C.IN_CONFIRMACAO = 1
		AND C.ID_USUARIO NOT IN (SELECT CU.ID_USUARIO FROM TB_CAMPEONATO_USUARIO CU WHERE CU.ID_CAMPEONATO IN (pIdSerieB,pIdSerieC))
		AND U.IN_USUARIO_ATIVO = TRUE 
		AND U.IN_DESEJA_PARTICIPAR = 1 
		AND C.ID_USUARIO = U.ID_USUARIO) X
		ORDER BY X.DS_Status, X.IN_USUARIO_MODERADOR, X.IN_CONFIRMACAO DESC, X.IN_ORDENACAO, X.DT_CONFIRMACAO, X.PT_LSTNEGRA, X.PT_TOTAL DESC, X.ID_USUARIO;
		
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	SELECT count(1) into _countCurrent FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdSerieC;
	
	SELECT QT_TIMES into _QtTotalTimes FROM  TB_CAMPEONATO WHERE ID_CAMPEONATO = pIdSerieC;
		
	SET _countRest = (_QtTotalTimes-_countCurrent);
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _TotLstNegra;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _count > _countRest THEN
		
			LEAVE get_tabela;
		
		ELSEIF _TotLstNegra <= pQtLimitMaxLstNegra THEN
		
			call `arenafifadb`.`spAddCampeonatoUsuario`(pIdSerieC, _idUsu);
			call `arenafifadb`.`spAddHistoricoTemporada`(pIdTemp, _idUsu, pCodAcessoConvite);
		
			call `arenafifadb`.`spUpdateToEndBancoReserva`(_idUsu, "H2H");

			SET _count = _count + 1;

		END IF;
	
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllTablesForNewTemporada` $$
CREATE PROCEDURE `spDeleteAllTablesForNewTemporada`(pIdTemp INTEGER, pIdSerieA INTEGER)
Begin
	DELETE FROM TB_COMENTARIO_JOGO;

	DELETE FROM TB_COMENTARIO_USUARIO
		  WHERE ID_TABELA_JOGO IN (SELECT J.ID_TABELA_JOGO FROM TB_TABELA_JOGO J WHERE J.DT_EFETIVACAO_JOGO IS NOT NULL);

	DELETE FROM TB_COMENTARIO_USUARIO
		  WHERE ID_TABELA_JOGO IN (SELECT J.ID_TABELA_JOGO FROM TB_TABELA_JOGO J WHERE J.DT_EFETIVACAO_JOGO IS NOT NULL);

	DELETE FROM TB_COMENTARIO_USUARIO
		  WHERE ID_TABELA_JOGO IN (SELECT J.ID_TABELA_JOGO FROM TB_TABELA_JOGO J WHERE J.DT_EFETIVACAO_JOGO IS NOT NULL);

	DELETE FROM TB_COMENTARIO_USUARIO
		  WHERE ID_TABELA_JOGO IN (SELECT J.ID_TABELA_JOGO FROM TB_TABELA_JOGO J WHERE J.DT_EFETIVACAO_JOGO IS NOT NULL);

	DELETE FROM TB_CONFIRMACAO_TEMPORADA WHERE ID_TEMPORADA <= pIdTemp;

	DELETE FROM TB_HISTORICO_CLASSIFICACAO;

	DELETE FROM TB_HISTORICO_CONQUISTA WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM TB_CAMPEONATO WHERE SG_TIPO_CAMPEONATO IN ('CFUT','LFUT','FUT1','FUT2''CPRO','PRO1'));

	DELETE FROM TB_HISTORICO_TRANSMISSAO_AOVIVO;

	DELETE FROM TB_LISTA_BANCO_RESERVA WHERE DT_FIM IS NOT NULL;

	DELETE FROM TB_USUARIO_TIME WHERE DT_VIGENCIA_FIM IS NOT NULL;

	DELETE FROM TB_POTE_TIME_GRUPO WHERE ID_CAMPEONATO < pIdSerieA;

	DELETE FROM TB_TIMES_FASE_PRECOPA WHERE ID_CAMPEONATO < pIdSerieA;

	DELETE FROM TB_CLASSIFICACAO WHERE ID_CAMPEONATO < pIdSerieA;

	DELETE FROM TB_TABELA_JOGO WHERE ID_CAMPEONATO < pIdSerieA;

	DELETE FROM TB_HISTORICO_ALT_CAMPEONATO;

	DELETE FROM TB_HISTORICO_ALT_USUARIO;

	DELETE FROM TB_HISTORICO_ATUAL;

	DELETE FROM TB_USUARIO_TIME WHERE DT_VIGENCIA_FIM IS NOT NULL ;

	DELETE FROM TB_TABELA_JOGO WHERE DT_EFETIVACAO_JOGO IS NULL;

	DELETE FROM TB_CLASSIFICACAO WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM TB_CAMPEONATO WHERE IN_CAMPEONATO_GRUPO = False AND IN_CAMPEONATO_TURNO_UNICO = False AND IN_CAMPEONATO_TURNO_RETURNO = False AND IN_SISTEMA_MATA = True AND IN_SISTEMA_IDA_VOLTA = True);

	DELETE FROM TB_GRUPO WHERE ID_CAMPEONATO < pIdSerieA;

	DELETE FROM TB_USUARIO_TIME WHERE ID_CAMPEONATO < pIdSerieA;

	DELETE FROM TB_FASE_CAMPEONATO WHERE ID_CAMPEONATO < pIdSerieA;

	DELETE FROM TB_CONFIRM_ELENCO_PRO WHERE ID_Temporada <= pIdTemp;

	DELETE FROM TB_CAMPEONATO_USUARIO_SEG_FASE;

	DELETE FROM TB_PALPITE_JOGO;

	DELETE FROM TB_RESULTADOS_LANCADOS;

	DELETE FROM TB_ULTIMOS_ACONTECIMENTOS;

	DELETE FROM TB_GOLEADOR_JOGO;

	DELETE FROM TB_GOLEADOR WHERE ID_GOLEADOR > 0 AND ID_USUARIO IS NULL;

	DELETE FROM arena_spooler.TB_HISTORICO_SPOOLER;

	DELETE FROM arena_spooler.TB_PROCESSOS_EMAIL_DETALHE;

	DELETE FROM arena_spooler.TB_SPOOLER_PROCESSOS_EMAIL;

End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spMaintenanceBancoAndManagers` $$
CREATE PROCEDURE `spMaintenanceBancoAndManagers`(
	pIdTemp INTEGER,
	pIdSerieA INTEGER,
	pIdSerieB INTEGER,
	pIdSerieC INTEGER,
	pIdFutA INTEGER,
	pIdProA INTEGER
)
Begin

	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _tpUsu VARCHAR(3) DEFAULT NULL;
	DECLARE _NmTime VARCHAR(50) DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR
		SELECT X.ID_USUARIO, "H2H" as TP_USUARIO, NULL as NM_TIME, X.DS_Status, X.IN_USUARIO_MODERADOR, X.IN_CONFIRMACAO, X.IN_ORDENACAO, X.DT_CONFIRMACAO, X.PT_LSTNEGRA, X.PT_TOTAL, X.ID_USUARIO FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR, 
		(SELECT L.PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA, 
		(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
		FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U  
		WHERE C.ID_TEMPORADA = pIdTemp
		AND C.ID_CAMPEONATO = 0
		AND U.IN_USUARIO_ATIVO = TRUE 
		AND U.IN_DESEJA_PARTICIPAR = 1 
		AND C.IN_CONFIRMACAO = 1
		AND C.ID_USUARIO NOT IN (SELECT ID_USUARIO FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO in (pIdSerieA,pIdSerieB,pIdSerieC))
		AND C.ID_USUARIO = U.ID_USUARIO) X
		UNION ALL
		SELECT X.ID_USUARIO, "FUT" as TP_USUARIO, X.NM_TIME, X.DS_Status, X.IN_USUARIO_MODERADOR, X.IN_CONFIRMACAO, X.IN_ORDENACAO, X.DT_CONFIRMACAO, X.PT_LSTNEGRA, X.PT_TOTAL, X.ID_USUARIO FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR, 
		(SELECT L.PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA, 
		(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
		FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U  
		WHERE C.ID_TEMPORADA = pIdTemp
		AND C.ID_CAMPEONATO = 7
		AND U.IN_USUARIO_ATIVO = TRUE 
		AND U.IN_DESEJA_PARTICIPAR = 1 
		AND C.IN_CONFIRMACAO = 1
		AND C.ID_USUARIO NOT IN (SELECT ID_USUARIO FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdFutA)
		AND C.ID_USUARIO = U.ID_USUARIO) X
		UNION ALL
		SELECT X.ID_USUARIO, "PRO" as TP_USUARIO, X.NM_TIME, X.DS_Status, X.IN_USUARIO_MODERADOR, X.IN_CONFIRMACAO, X.IN_ORDENACAO, X.DT_CONFIRMACAO, X.PT_LSTNEGRA, X.PT_TOTAL, X.ID_USUARIO FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR, 
		(SELECT L.PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA, 
		(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
		FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U  
		WHERE C.ID_TEMPORADA = pIdTemp
		AND C.ID_CAMPEONATO = 13
		AND U.IN_USUARIO_ATIVO = TRUE 
		AND U.IN_DESEJA_PARTICIPAR = 1 
		AND C.IN_CONFIRMACAO = 1
		AND C.ID_USUARIO NOT IN (SELECT ID_USUARIO FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdProA)
		AND C.ID_USUARIO = U.ID_USUARIO) X
		ORDER BY TP_USUARIO, DS_Status, IN_USUARIO_MODERADOR, IN_CONFIRMACAO DESC, IN_ORDENACAO, DT_CONFIRMACAO, PT_LSTNEGRA, PT_TOTAL DESC, ID_USUARIO;
		
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	call `arenafifadb`.`spUpdateToEndBancoReservaByTipo`("H2H");
	call `arenafifadb`.`spUpdateToEndBancoReservaByTipo`("FUT");
	call `arenafifadb`.`spUpdateToEndBancoReservaByTipo`("PRO");

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _tpUsu, _NmTime;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		call `arenafifadb`.`spAddBancoReserva`(pIdSerieC, _NmTime, _tpUsu);
	
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	
	#UPDATE TB_CAMPEONATO 
	#SET ID_USUARIO_MODERADOR = , ID_USUARIO_2oMODERADOR = ,
	#ID_USUARIO_1oAUXILIAR = Null, ID_USUARIO_2oAUXILIAR = Null, ID_USUARIO_3oAUXILIAR = Null
	#WHERE ID_CAMPEONATO = pIdSerieA;

End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateClashesNewTemporada` $$
CREATE PROCEDURE `spGenerateClashesNewTemporada`(
	pIdTemp INTEGER
)
Begin

	DECLARE _idTimeFim INTEGER DEFAULT NULL;
	DECLARE _idUsuFim INTEGER DEFAULT NULL;
	DECLARE _idCampIni INTEGER DEFAULT NULL;
	DECLARE _idCampFim INTEGER DEFAULT NULL;
	
	SELECT max(ID_TIME) into _idTimeFim FROM arena_clashes.TB_TIME;
	SELECT max(ID_USUARIO) into _idUsuFim FROM arena_clashes.TB_USUARIO;
	SELECT min(ID_CAMPEONATO), max(ID_CAMPEONATO) into _idCampIni, _idCampFim FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1) AND SG_TIPO_CAMPEONATO NOT IN ('CDA');
	
	INSERT INTO arena_clashes.TB_TEMPORADA SELECT * FROM arenafifadb.TB_TEMPORADA WHERE ID_TEMPORADA = (pIdTemp-1);
	INSERT INTO arena_clashes.TB_CAMPEONATO SELECT * FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1);
	INSERT INTO arena_clashes.TB_TIME SELECT * FROM arenafifadb.TB_TIME WHERE ID_TIME > _idTimeFim;
	INSERT INTO arena_clashes.TB_USUARIO SELECT * FROM arenafifadb.TB_USUARIO WHERE ID_USUARIO > _idUsuFim;
	INSERT INTO arena_clashes.TB_TABELA_JOGO SELECT * FROM arenafifadb.TB_TABELA_JOGO WHERE ID_CAMPEONATO >= _idCampIni AND ID_CAMPEONATO <= _idCampFim;

End$$
DELIMITER ;