USE `arenafifadb_staging`;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateEndOfTemporadaPRO` $$
CREATE PROCEDURE `spCalculateEndOfTemporadaPRO`(pIdTemp INTEGER, pIdNewTemp INTEGER)
Begin
	UPDATE TB_CAMPEONATO SET IN_CAMPEONATO_ATIVO = FALSE 
	WHERE SG_TIPO_CAMPEONATO IN ("PRO1", "PRO2", "CPRO") AND IN_CAMPEONATO_ATIVO = TRUE;
	
	call spCalculateAllFasesEndOfTemporadaPRO(pIdTemp, pIdNewTemp);
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateAllFasesEndOfTemporadaPRO` $$
CREATE PROCEDURE `spCalculateAllFasesEndOfTemporadaPRO`(pIdTemp INTEGER, pIdTempNew INTEGER)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _sgCamps VARCHAR(50) DEFAULT "PRO1,PRO2,CPRO";
	DECLARE _sgLigas VARCHAR(50) DEFAULT "PRO1,PRO2'";
	DECLARE _sgCamp VARCHAR(4) DEFAULT NULL;
	DECLARE _count INTEGER DEFAULT 0;
	DECLARE _idCamp INTEGER DEFAULT 0;
	DECLARE _idCampAux INTEGER DEFAULT 0;
	DECLARE _ptsVitoria INTEGER DEFAULT NULL;
	DECLARE _ptsEmpate INTEGER DEFAULT NULL;
	DECLARE _idUsuHome INTEGER DEFAULT NULL;
	DECLARE _idUsuAway INTEGER DEFAULT NULL;
	DECLARE _idTeamHome INTEGER DEFAULT NULL;
	DECLARE _idTeamAway INTEGER DEFAULT NULL;
	DECLARE _qtGolsHome INTEGER DEFAULT NULL;
	DECLARE _qtGolsAway INTEGER DEFAULT NULL;
	DECLARE _sumPoints INTEGER DEFAULT 0;
	DECLARE _sumEmpate INTEGER DEFAULT 0;
	DECLARE _sumVitoria INTEGER DEFAULT 0;
	DECLARE _sumLiga INTEGER DEFAULT 0;
	DECLARE _sumCopa INTEGER DEFAULT 0;


	#Calculando as Fases de Classificação....
	DECLARE tabela_cursor CURSOR FOR
		SELECT J.ID_CAMPEONATO, J.ID_TIME_CASA, J.ID_USUARIO_TIME_CASA, J.ID_TIME_VISITANTE, J.ID_USUARIO_TIME_VISITANTE, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, C.SG_TIPO_CAMPEONATO 
		FROM TB_TABELA_JOGO J, TB_TIME T1 , TB_TIME T2, TB_USUARIO TU1, TB_USUARIO TU2, TB_CLASSIFICACAO TC1, TB_CLASSIFICACAO TC2, TB_CAMPEONATO C 
		WHERE C.ID_TEMPORADA = pIdTemp
		AND J.ID_FASE = 0
		AND FIND_IN_SET(C.SG_TIPO_CAMPEONATO, _sgCamps) > 0
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
	
	DELETE FROM TB_HISTORICO_ARTILHARIA_PRO WHERE ID_TEMPORADA >= pIdTemp;
	DELETE FROM TB_HISTORICO_CONQUISTA_PRO WHERE ID_TEMPORADA >= pIdTemp;
	DELETE FROM TB_HISTORICO_TEMPORADA_PRO WHERE ID_TEMPORADA >= pIdTemp;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idCamp, _idTeamHome, _idUsuHome, _idTeamAway, _idUsuAway, _qtGolsHome, _qtGolsAway, _sgCamp;
		
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
		
		
		SELECT count(1) into _count FROM TB_HISTORICO_TEMPORADA_PRO WHERE ID_TEMPORADA = pIdTemp AND ID_TIME = _idTeamHome;
		IF _count = 0 THEN
			call spAddHistoricoTemporadaPRO(pIdTemp, _idTeamHome, _idUsuHome, NULL);
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
		
		IF INSTR(_sgLigas,_sgCamp)> 0  THEN
			SET _sumLiga = _sumPoints;
		ELSE
			SET _sumCopa = _sumPoints;
		END IF;
		
		UPDATE TB_HISTORICO_TEMPORADA_PRO
		SET PT_EMPATES_FASE1 = (PT_EMPATES_FASE1+_sumEmpate),
		    PT_VITORIAS_FASE1 = (PT_VITORIAS_FASE1+_sumVitoria),
			PT_COPAS = (PT_COPAS+_sumCopa),
			PT_LIGAS = (PT_LIGAS+_sumLiga)
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsuHome;


		SELECT count(1) into _count FROM TB_HISTORICO_TEMPORADA_PRO WHERE ID_TEMPORADA = pIdTemp AND ID_TIME = _idTeamAway;
		IF _count = 0 THEN
			call spAddHistoricoTemporadaPRO(pIdTemp, _idTeamAway, _idUsuAway, NULL);
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
		
		IF INSTR(_sgLigas,_sgCamp)> 0  THEN
			SET _sumLiga = _sumPoints;
		ELSE
			SET _sumCopa = _sumPoints;
		END IF;
		
		UPDATE TB_HISTORICO_TEMPORADA_PRO
		SET PT_EMPATES_FASE1 = (PT_EMPATES_FASE1+_sumEmpate),
		    PT_VITORIAS_FASE1 = (PT_VITORIAS_FASE1+_sumVitoria),
			PT_COPAS = (PT_COPAS+_sumCopa),
			PT_LIGAS = (PT_LIGAS+_sumLiga)
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _idUsuAway;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	#Calculando fases playoff....
	call spCalculateFasePlayoffFUT_PRO(pIdTemp, _sgCamps, _sgLigas, "PRO");

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
	
		call `arenafifadb_staging`.`spAddElencoPROProxTemp`(pIdTemp, _idUsu, fcGetCurrentIdTimePRO(_idUsu));

	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddElencoPROProxTemp` $$
CREATE PROCEDURE `spAddElencoPROProxTemp`(pIdTemp INTEGER, pIdUsuManager INTEGER, pIdTime INTEGER)
Begin
	insert into TB_CONFIRM_ELENCO_PRO
		SELECT pIdTemp, pIdUsuManager, ID_USUARIO, NOW() FROM TB_GOLEADOR
		WHERE ID_TIME = pIdTime
		ORDER BY ID_USUARIO;
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

		call `arenafifadb_staging`.`spAddLoadClassificacaoInitialOfCampeonatov2`(_idCamp);
		
		call `arenafifadb_staging`.`spAssumeTimes`(_idCamp);
	END IF;

	SELECT _idCamp as idNewCampeonato, _countTecnicos as QtdTimes;
	
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
		
		call `arenafifadb_staging`.`spAddTecnicosFromLigasToCampeonatoTimeUsuario`(_idCamp, pIdsCampLiga);
		call `arenafifadb_staging`.`spAddLoadClassificacaoInitialOfCampeonatov2`(_idCamp);
		
		IF (pListaTimesPreCopa<>"") THEN
			call `arenafifadb_staging`.`spAddListaTimesPreCopa`(_idCamp, pListaTimesPreCopa, _SiglaTimePRO);
		END IF;

		call `arenafifadb_staging`.`spAssumeTimes`(_idCamp);
	END IF;

	SELECT _idCamp as idNewCampeonato;
	
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

	DELETE FROM TB_GOLEADOR WHERE ID_GOLEADOR > 0;

	SET @row_number = _IdPlayerInitial;

	INSERT INTO TB_GOLEADOR
	SELECT (@row_number:=@row_number + 1), fcGetCurrentIdTimePRO(C.ID_USUARIO_MANAGER), U.PSN_ID, U.NM_USUARIO, "...", "PRO CLUB", 0, 0, C.ID_USUARIO, NOW()
	FROM TB_CONFIRM_ELENCO_PRO C, TB_USUARIO U
	WHERE C.ID_TEMPORADA = pIdTemp
	  AND C.ID_USUARIO_MANAGER IN (SELECT CU.ID_USUARIO FROM TB_CAMPEONATO_USUARIO CU WHERE CU.ID_CAMPEONATO = pIdCamp)
	  AND C.ID_USUARIO = U.ID_USUARIO ORDER BY C.ID_USUARIO_MANAGER, C.ID_USUARIO;

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateScorersPRO` $$
CREATE PROCEDURE `spCalculateScorersPRO`(
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
		
		INSERT INTO TB_HISTORICO_ARTILHARIA_PRO (ID_TEMPORADA, ID_CAMPEONATO, ID_GOLEADOR, ID_TIME, ID_TECNICO, QT_GOLS)
		VALUES (pIdTemp, pIdCamp, _idGoleador, _idTime, fcGetIdUsuarioByTime(pIdCamp, _idTime), _qtdGols);

	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spPrepareToCalculatePerformanceTecnicosPRO` $$
CREATE PROCEDURE `spPrepareToCalculatePerformanceTecnicosPRO`(
	pIdTemp INTEGER, 
	pIdPreviousTemp INTEGER, 
	pSgLigas VARCHAR(50)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu INTEGER DEFAULT 0;
	DECLARE _idTime INTEGER DEFAULT 0;
	DECLARE _totPontos INTEGER DEFAULT 0;
	DECLARE _totTemp INTEGER DEFAULT 0;
	DECLARE _totPreviusTemp INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT ID_TIME, ID_USUARIO, PT_TOTAL_TEMPORADA FROM TB_HISTORICO_TEMPORADA_PRO  WHERE ID_TEMPORADA = pIdTemp ORDER BY ID_TIME;
 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idTime, _idUsu, _totTemp;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SELECT PT_TOTAL into _totPreviusTemp FROM TB_HISTORICO_TEMPORADA_PRO WHERE ID_TEMPORADA = pIdPreviousTemp AND ID_TIME = _idTime;
		IF _totPreviusTemp IS NULL THEN
			UPDATE TB_HISTORICO_TEMPORADA_PRO
			SET PT_TOTAL_TEMPORADA_ANTERIOR = PT_TOTAL_TEMPORADA, ID_USUARIO = _idUsu
			WHERE ID_TEMPORADA = pIdTemp AND ID_TIME = _idTime;
		ELSE
			UPDATE TB_HISTORICO_TEMPORADA_PRO
			SET PT_TOTAL_TEMPORADA_ANTERIOR = _totPreviusTemp, PT_TOTAL = (PT_TOTAL+_totPreviusTemp), ID_USUARIO = _idUsu
			WHERE ID_TEMPORADA = pIdTemp AND ID_TIME = _idTime;
		END IF;
		
		call `arenafifadb_staging`.`spCalculatePerformanceTecnicosFUT_PRO`(pIdTemp, _idUsu, pSgLigas, "PRO");
		
		call `arenafifadb_staging`.`spCalculatePerformanceGeralTecnicosFUT_PRO`(pIdTemp, _idUsu, pSgLigas, "PRO");
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddAllTecnicosHistoricoTemporadaPRO` $$
CREATE PROCEDURE `spAddAllTecnicosHistoricoTemporadaPRO`(
	pIdTemp INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu INTEGER DEFAULT 0;
	DECLARE _idTime INTEGER DEFAULT 0;
	DECLARE _idTemp INTEGER DEFAULT 0;
	DECLARE _total INTEGER DEFAULT 0;
	DECLARE _totLstNegra INTEGER DEFAULT 0;
	DECLARE _apGeral DECIMAL(5,2) DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT ID_TIME, max(ID_TEMPORADA) FROM TB_HISTORICO_TEMPORADA_PRO
		WHERE ID_TIME NOT IN (SELECT ID_TIME FROM TB_HISTORICO_TEMPORADA_PRO WHERE ID_Temporada = pIdTemp)
		GROUP BY ID_TIME;
 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idTime, _idTemp;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SELECT ID_USUARIO, PT_TOTAL, PC_APROVEITAMENTO_GERAL, QT_LSTNEGRA into _idUsu, _total, _apGeral, _totLstNegra
		FROM TB_HISTORICO_TEMPORADA_PRO WHERE ID_TEMPORADA = _idTemp AND ID_TIME = _idTime;
		
		IF (_total IS NOT NULL) THEN

			UPDATE TB_HISTORICO_TEMPORADA_PRO
			SET PT_TOTAL = _total, PC_APROVEITAMENTO_GERAL = _apGeral, QT_LSTNEGRA = _totLstNegra, IN_ACESSO_TEMP_ATUAL = 0
			WHERE ID_TEMPORADA = pIdTemp AND ID_TIME = _idTime;
		
		ELSE
		
			INSERT INTO TB_HISTORICO_TEMPORADA_PRO (ID_TEMPORADA, ID_TIME, ID_USUARIO, IN_ACESSO_TEMP_ATUAL, PT_CAMPEAO, PT_VICECAMPEAO, PT_SEMIS, PT_QUARTAS, PT_OITAVAS, PT_CLASSIF_FASE2, 
												PT_VITORIAS_FASE1, PT_EMPATES_FASE1, IN_POSICAO_ATUAL, PT_LIGAS, PT_COPAS, PT_TOTAL_TEMPORADA, QT_JOGOS_TEMPORADA, 
												QT_TOTAL_PONTOS_TEMPORADA, QT_TOTAL_VITORIAS_TEMPORADA, QT_TOTAL_EMPATES_TEMPORADA, PC_APROVEITAMENTO_TEMPORADAS, 
												IN_REBAIXADO_TEMP_ANTERIOR, QT_LSTNEGRA, PT_TOTAL, PT_TOTAL_TEMPORADA_ANTERIOR, IN_POSICAO_ANTERIOR, 
												QT_JOGOS_GERAL, QT_TOTAL_PONTOS_GERAL, QT_TOTAL_VITORIAS_GERAL, QT_TOTAL_EMPATES_GERAL, PC_APROVEITAMENTO_GERAL)
			SELECT pIdTemp, _idTime, _idUsu, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, COALESCE(T.PT_TOTAL,0), COALESCE(T.PT_TOTAL_TEMPORADA_ANTERIOR,0), 
			       COALESCE(T.IN_POSICAO_ANTERIOR,0), COALESCE(T.QT_JOGOS_GERAL,0), COALESCE(T.QT_TOTAL_PONTOS_GERAL,0), COALESCE(T.QT_TOTAL_VITORIAS_GERAL,0), 
				   COALESCE(T.QT_TOTAL_EMPATES_GERAL,0), COALESCE(T.PC_APROVEITAMENTO_GERAL,0)
			FROM TB_HISTORICO_TEMPORADA_PRO T
			WHERE T.ID_TEMPORADA < pIdTemp AND T.ID_TIME = _idTime ORDER BY T.ID_TEMPORADA DESC limit 1;
			
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateHallOfFamePRO` $$
CREATE PROCEDURE `spUpdateHallOfFamePRO`(
	pIdTemp INTEGER
)
Begin
	call `arenafifadb_staging`.`spUpdateHallOfFameLstNegraPRO`(pIdTemp);

	UPDATE TB_HISTORICO_TEMPORADA_PRO
	SET IN_REBAIXADO_TEMP_ANTERIOR = 0 
	WHERE ID_TEMPORADA = pIdTemp AND IN_REBAIXADO_TEMP_ANTERIOR IS NULL;
	
	UPDATE TB_HISTORICO_TEMPORADA_PRO
	SET IN_ACESSO_TEMP_ATUAL = 0
	WHERE ID_TEMPORADA = pIdTemp;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateHallOfFameLstNegraPRO` $$
CREATE PROCEDURE `spUpdateHallOfFameLstNegraPRO`(
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
	SELECT ID_USUARIO, PT_TOTAL FROM TB_HISTORICO_TEMPORADA_PRO WHERE ID_TEMPORADA = pIdTemp
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
		
		UPDATE TB_HISTORICO_TEMPORADA_PRO
		SET IN_POSICAO_ATUAL = _count,
			QT_LSTNEGRA = _qtLstNegra
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = _IdUsu;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;