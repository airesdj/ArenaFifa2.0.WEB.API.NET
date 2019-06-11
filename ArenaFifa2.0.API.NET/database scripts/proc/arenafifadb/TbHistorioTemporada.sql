USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateHistoricoTempTecnicoRelegated` $$
CREATE PROCEDURE `spUpdateHistoricoTempTecnicoRelegated`(
	pIdTemp INTEGER,
	pIdUsu INTEGER,
	pIdTipoAcesso INTEGER
)
Begin
	UPDATE TB_HISTORICO_TEMPORADA SET IN_REBAIXADO_TEMP_ANTERIOR = 1, IN_ACESSO_TEMP_ATUAL = pIdTipoAcesso
	WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateOrdenaHistoricoTempH2H` $$
CREATE PROCEDURE `spUpdateOrdenaHistoricoTempH2H`(
	pIdTemp INTEGER
)
Begin
	SET @row_number = 0;
	
	UPDATE TB_HISTORICO_TEMPORADA H join
	(SELECT (@row_number:=@row_number + 1) AS POSICAO_ATUAL, T.ID_TEMPORADA, T.ID_USUARIO FROM TB_HISTORICO_TEMPORADA T WHERE T.ID_TEMPORADA = pIdTemp ORDER BY T.PT_TOTAL DESC) X
	on H.ID_TEMPORADA = X.ID_TEMPORADA
	AND H.ID_USUARIO = X.ID_USUARIO
	SET H.IN_POSICAO_ATUAL = X.POSICAO_ATUAL;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateOrdenaHistoricoTempFUT` $$
CREATE PROCEDURE `spUpdateOrdenaHistoricoTempFUT`(
	pIdTemp INTEGER
)
Begin
	SET @row_number = 0;
	
	UPDATE TB_HISTORICO_TEMPORADA H join
	(SELECT (@row_number:=@row_number + 1) AS POSICAO_ATUAL, T.ID_TEMPORADA, T.ID_USUARIO FROM TB_HISTORICO_TEMPORADA T WHERE T.ID_TEMPORADA = 20 ORDER BY T.PT_TOTAL DESC) X
	on H.ID_TEMPORADA = X.ID_TEMPORADA_FUT
	AND H.ID_USUARIO = X.ID_USUARIO
	SET H.IN_POSICAO_ATUAL = X.POSICAO_ATUAL;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateOrdenaHistoricoTempPRO` $$
CREATE PROCEDURE `spUpdateOrdenaHistoricoTempPRO`(
	pIdTemp INTEGER
)
Begin
	SET @row_number = 0;
	
	UPDATE TB_HISTORICO_TEMPORADA H join
	(SELECT (@row_number:=@row_number + 1) AS POSICAO_ATUAL, T.ID_TEMPORADA, T.ID_USUARIO FROM TB_HISTORICO_TEMPORADA T WHERE T.ID_TEMPORADA = 20 ORDER BY T.PT_TOTAL DESC) X
	on H.ID_TEMPORADA = X.ID_TEMPORADA_PRO
	AND H.ID_USUARIO = X.ID_USUARIO
	SET H.IN_POSICAO_ATUAL = X.POSICAO_ATUAL;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddHistoricoTemporadaH2H` $$
CREATE PROCEDURE `spAddHistoricoTemporadaH2H`(
	pIdTemp INTEGER,
	pIdUsu INTEGER,
	pIdTipoAcesso INTEGER
)
Begin
	DECLARE _count INTEGER DEFAULT 0;
	DECLARE _total INTEGER DEFAULT 0;
	DECLARE _totalTempAnt INTEGER DEFAULT 0;
	DECLARE _position INTEGER DEFAULT 0;
	DECLARE _totalJogos INTEGER DEFAULT 0;
	DECLARE _totalPontos INTEGER DEFAULT 0;
	DECLARE _totalVit INTEGER DEFAULT 0;
	DECLARE _totalEmp INTEGER DEFAULT 0;
	DECLARE _totalAprov INTEGER DEFAULT 0;
	
	If pIdTemp = 0 THEN
		SET pIdTemp = fcGetIdTempPrevious();
	END IF;
	
	SELECT count(1) into _count
	FROM TB_HISTORICO_TEMPORADA
	WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	
	IF (_count) > 0 THEN
	
		UPDATE TB_HISTORICO_TEMPORADA SET IN_ACESSO_TEMP_ATUAL = pIdTipoAcesso
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	
	ELSE

		INSERT INTO TB_HISTORICO_TEMPORADA (ID_TEMPORADA, ID_USUARIO, IN_ACESSO_TEMP_ATUAL, PT_CAMPEAO, PT_VICECAMPEAO, PT_SEMIS, PT_QUARTAS, PT_OITAVAS, PT_CLASSIF_FASE2, 
										    PT_VITORIAS_FASE1, PT_EMPATES_FASE1, IN_POSICAO_ATUAL, PT_LIGAS, PT_COPAS, PT_TOTAL_TEMPORADA, QT_JOGOS_TEMPORADA, 
											QT_TOTAL_PONTOS_TEMPORADA, QT_TOTAL_VITORIAS_TEMPORADA, QT_TOTAL_EMPATES_TEMPORADA, PC_APROVEITAMENTO_TEMPORADAS, 
											IN_REBAIXADO_TEMP_ANTERIOR, QT_LSTNEGRA, PT_TOTAL, PT_TOTAL_TEMPORADA_ANTERIOR, IN_POSICAO_ANTERIOR, 
											QT_JOGOS_GERAL, QT_TOTAL_PONTOS_GERAL, QT_TOTAL_VITORIAS_GERAL, QT_TOTAL_EMPATES_GERAL, PC_APROVEITAMENTO_GERAL)
		VALUES (pIdTemp, pIdUsu, pIdTipoAcesso, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

		SELECT PT_TOTAL, PT_TOTAL_TEMPORADA_ANTERIOR, IN_POSICAO_ANTERIOR, QT_JOGOS_GERAL, QT_TOTAL_PONTOS_GERAL, QT_TOTAL_VITORIAS_GERAL, QT_TOTAL_EMPATES_GERAL, PC_APROVEITAMENTO_GERAL 
		into _total, _totalTempAnt, _position, _totalJogos, _totalPontos, _totalVit, _totalEmp, _totalAprov
		FROM TB_HISTORICO_TEMPORADA
		WHERE ID_TEMPORADA < pIdTemp AND ID_USUARIO = pIdUsu ORDER BY ID_TEMPORADA DESC limit 1;
		
		IF _total IS NOT NULL THEN
		
			UPDATE TB_HISTORICO_TEMPORADA
			SET PT_TOTAL = _total,
			PT_TOTAL_TEMPORADA_ANTERIOR = _totalTempAnt,
			IN_POSICAO_ANTERIOR = _position,
			QT_JOGOS_GERAL = _totalJogos,
			QT_TOTAL_PONTOS_GERAL = _totalPontos,
			QT_TOTAL_VITORIAS_GERAL = _totalVit,
			QT_TOTAL_EMPATES_GERAL = _totalEmp,
			PC_APROVEITAMENTO_GERAL = _totalAprov
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
		
		END IF;
	
	END IF;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddHistoricoTemporadaFUT` $$
CREATE PROCEDURE `spAddHistoricoTemporadaFUT`(
	pIdTemp INTEGER,
	pIdUsu INTEGER,
	pIdTipoAcesso INTEGER
)
Begin
	DECLARE _count INTEGER DEFAULT 0;
	DECLARE _total INTEGER DEFAULT 0;
	DECLARE _totalTempAnt INTEGER DEFAULT 0;
	DECLARE _position INTEGER DEFAULT 0;
	DECLARE _totalJogos INTEGER DEFAULT 0;
	DECLARE _totalPontos INTEGER DEFAULT 0;
	DECLARE _totalVit INTEGER DEFAULT 0;
	DECLARE _totalEmp INTEGER DEFAULT 0;
	DECLARE _totalAprov INTEGER DEFAULT 0;
	
	If pIdTemp = 0 THEN
		SET pIdTemp = fcGetIdTempPrevious();
	END IF;
	
	SELECT count(1) into _count
	FROM TB_HISTORICO_TEMPORADA_FUT
	WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	
	IF (_count) > 0 THEN
	
		UPDATE TB_HISTORICO_TEMPORADA_FUT SET IN_ACESSO_TEMP_ATUAL = pIdTipoAcesso
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	
	ELSE
	
		INSERT INTO TB_HISTORICO_TEMPORADA_FUT (ID_TEMPORADA, ID_USUARIO, IN_ACESSO_TEMP_ATUAL, PT_CAMPEAO, PT_VICECAMPEAO, PT_SEMIS, PT_QUARTAS, PT_OITAVAS, PT_CLASSIF_FASE2, 
										    PT_VITORIAS_FASE1, PT_EMPATES_FASE1, IN_POSICAO_ATUAL, PT_LIGAS, PT_COPAS, PT_TOTAL_TEMPORADA, QT_JOGOS_TEMPORADA, 
											QT_TOTAL_PONTOS_TEMPORADA, QT_TOTAL_VITORIAS_TEMPORADA, QT_TOTAL_EMPATES_TEMPORADA, PC_APROVEITAMENTO_TEMPORADAS, 
											IN_REBAIXADO_TEMP_ANTERIOR, QT_LSTNEGRA, PT_TOTAL, PT_TOTAL_TEMPORADA_ANTERIOR, IN_POSICAO_ANTERIOR, 
											QT_JOGOS_GERAL, QT_TOTAL_PONTOS_GERAL, QT_TOTAL_VITORIAS_GERAL, QT_TOTAL_EMPATES_GERAL, PC_APROVEITAMENTO_GERAL)
		VALUES (pIdTemp, pIdUsu, pIdTipoAcesso, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	
		SELECT PT_TOTAL, PT_TOTAL_TEMPORADA_ANTERIOR, IN_POSICAO_ANTERIOR, QT_JOGOS_GERAL, QT_TOTAL_PONTOS_GERAL, QT_TOTAL_VITORIAS_GERAL, QT_TOTAL_EMPATES_GERAL, PC_APROVEITAMENTO_GERAL 
		into _total, _totalTempAnt, _position, _totalJogos, _totalPontos, _totalVit, _totalEmp, _totalAprov
		FROM TB_HISTORICO_TEMPORADA_FUT
		WHERE ID_TEMPORADA < pIdTemp AND ID_USUARIO = pIdUsu ORDER BY ID_TEMPORADA DESC limit 1;
		
		IF _total IS NOT NULL THEN
		
			UPDATE TB_HISTORICO_TEMPORADA_FUT
			SET PT_TOTAL = _total,
			PT_TOTAL_TEMPORADA_ANTERIOR = _totalTempAnt,
			IN_POSICAO_ANTERIOR = _position,
			QT_JOGOS_GERAL = _totalJogos,
			QT_TOTAL_PONTOS_GERAL = _totalPontos,
			QT_TOTAL_VITORIAS_GERAL = _totalVit,
			QT_TOTAL_EMPATES_GERAL = _totalEmp,
			PC_APROVEITAMENTO_GERAL = _totalAprov
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
		
		END IF;
	
	END IF;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddHistoricoTemporadaPRO` $$
CREATE PROCEDURE `spAddHistoricoTemporadaPRO`(
	pIdTemp INTEGER,
	pIdUsu INTEGER,
	pIdTipoAcesso INTEGER
)
Begin
	DECLARE _count INTEGER DEFAULT 0;
	DECLARE _total INTEGER DEFAULT 0;
	DECLARE _totalTempAnt INTEGER DEFAULT 0;
	DECLARE _position INTEGER DEFAULT 0;
	DECLARE _totalJogos INTEGER DEFAULT 0;
	DECLARE _totalPontos INTEGER DEFAULT 0;
	DECLARE _totalVit INTEGER DEFAULT 0;
	DECLARE _totalEmp INTEGER DEFAULT 0;
	DECLARE _totalAprov INTEGER DEFAULT 0;
	
	If pIdTemp = 0 THEN
		SET pIdTemp = fcGetIdTempPrevious();
	END IF;
	
	SELECT count(1) into _count
	FROM TB_HISTORICO_TEMPORADA_PRO
	WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	
	IF (_count) > 0 THEN
	
		UPDATE TB_HISTORICO_TEMPORADA_PRO SET IN_ACESSO_TEMP_ATUAL = pIdTipoAcesso
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	
	ELSE
	
		INSERT INTO TB_HISTORICO_TEMPORADA_PRO (ID_TEMPORADA, ID_USUARIO, IN_ACESSO_TEMP_ATUAL, PT_CAMPEAO, PT_VICECAMPEAO, PT_SEMIS, PT_QUARTAS, PT_OITAVAS, PT_CLASSIF_FASE2, 
										    PT_VITORIAS_FASE1, PT_EMPATES_FASE1, IN_POSICAO_ATUAL, PT_LIGAS, PT_COPAS, PT_TOTAL_TEMPORADA, QT_JOGOS_TEMPORADA, 
											QT_TOTAL_PONTOS_TEMPORADA, QT_TOTAL_VITORIAS_TEMPORADA, QT_TOTAL_EMPATES_TEMPORADA, PC_APROVEITAMENTO_TEMPORADAS, 
											IN_REBAIXADO_TEMP_ANTERIOR, QT_LSTNEGRA, PT_TOTAL, PT_TOTAL_TEMPORADA_ANTERIOR, IN_POSICAO_ANTERIOR, 
											QT_JOGOS_GERAL, QT_TOTAL_PONTOS_GERAL, QT_TOTAL_VITORIAS_GERAL, QT_TOTAL_EMPATES_GERAL, PC_APROVEITAMENTO_GERAL)
		VALUES (pIdTemp, pIdUsu, pIdTipoAcesso, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	
		SELECT PT_TOTAL, PT_TOTAL_TEMPORADA_ANTERIOR, IN_POSICAO_ANTERIOR, QT_JOGOS_GERAL, QT_TOTAL_PONTOS_GERAL, QT_TOTAL_VITORIAS_GERAL, QT_TOTAL_EMPATES_GERAL, PC_APROVEITAMENTO_GERAL 
		into _total, _totalTempAnt, _position, _totalJogos, _totalPontos, _totalVit, _totalEmp, _totalAprov
		FROM TB_HISTORICO_TEMPORADA_PRO
		WHERE ID_TEMPORADA < pIdTemp AND ID_USUARIO = pIdUsu ORDER BY ID_TEMPORADA DESC limit 1;
		
		IF _total IS NOT NULL THEN
		
			UPDATE TB_HISTORICO_TEMPORADA_PRO
			SET PT_TOTAL = _total,
			PT_TOTAL_TEMPORADA_ANTERIOR = _totalTempAnt,
			IN_POSICAO_ANTERIOR = _position,
			QT_JOGOS_GERAL = _totalJogos,
			QT_TOTAL_PONTOS_GERAL = _totalPontos,
			QT_TOTAL_VITORIAS_GERAL = _totalVit,
			QT_TOTAL_EMPATES_GERAL = _totalEmp,
			PC_APROVEITAMENTO_GERAL = _totalAprov
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
		
		END IF;
	
	END IF;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllGeneralRanking` $$
CREATE PROCEDURE `spGetAllGeneralRanking`(
	pTotalRecords INTEGER,
	pTypeMode VARCHAR(3)
)
Begin
	DECLARE _idTemp INTEGER DEFAULT 0;
	
	SET _idTemp = fcGetIdTempPrevious();
	
	IF pTypeMode = "H2H" THEN

		SELECT T.*, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO  
		FROM  TB_HISTORICO_TEMPORADA T, TB_USUARIO U 
		WHERE T.ID_TEMPORADA =  _idTemp
		AND T.PT_TOTAL > 0  
		AND fcGetIdUsuariosVazio(U.ID_USUARIO,'NOT')
		AND T.ID_USUARIO = U.ID_USUARIO  
		AND IN_POSICAO_ATUAL <= pTotalRecords 
		ORDER BY IN_POSICAO_ATUAL;
	
	ELSEIF pTypeMode = "FUT" THEN

		SELECT T.*, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO  
		FROM  TB_HISTORICO_TEMPORADA_FUT T, TB_USUARIO U 
		WHERE T.ID_TEMPORADA =  _idTemp
		AND T.PT_TOTAL > 0  
		AND fcGetIdUsuariosVazio(U.ID_USUARIO,'NOT')
		AND T.ID_USUARIO = U.ID_USUARIO  
		AND IN_POSICAO_ATUAL <= pTotalRecords 
		ORDER BY IN_POSICAO_ATUAL;
	
	ELSE
	
		SELECT T.*, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO  
		FROM  TB_HISTORICO_TEMPORADA_PRO T, TB_USUARIO U 
		WHERE T.ID_TEMPORADA =  _idTemp
		AND T.PT_TOTAL > 0  
		AND fcGetIdUsuariosVazio(U.ID_USUARIO,'NOT')
		AND T.ID_USUARIO = U.ID_USUARIO  
		AND IN_POSICAO_ATUAL <= pTotalRecords 
		ORDER BY IN_POSICAO_ATUAL;
	
	END IF;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllRankingCurrent` $$
CREATE PROCEDURE `spGetAllRankingCurrent`(
	pTypeMode VARCHAR(3)
)
Begin
	DECLARE _idTemp INTEGER DEFAULT 0;
	
	SET _idTemp = fcGetIdTempCurrent();
	
	SELECT U.ID_USUARIO, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO, H.PT_TOTAL, fcGetTimeNameByUserMode(U.ID_USUARIO,pTypeMode) as NM_TIME
	FROM TB_HISTORICO_ATUAL H, TB_USUARIO U 
	WHERE H.ID_TEMPORADA =  _idTemp
	AND fcGetIdUsuariosVazio(U.ID_USUARIO,'NOT')
	AND H.TP_MODALIDADE = pTypeMode
	AND H.ID_USUARIO = U.ID_USUARIO  
	AND U.IN_DESEJA_PARTICIPAR = 1 ORDER BY H.PT_TOTAL DESC;

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetRankingByDivision` $$
CREATE PROCEDURE `spGetRankingByDivision`(
	pSiglaCamp VARCHAR(4),
	pTypeMode VARCHAR(3)
)
Begin
	DECLARE _idTemp INTEGER DEFAULT 0;
	DECLARE _idCamp INTEGER DEFAULT 0;
	
	SET _idTemp = fcGetIdTempPrevious();
	
	SELECT ID_CAMPEONATO into _idCamp
	FROM TB_CAMPEONATO WHERE ID_TEMPORADA = fcGetIdTempCurrent() AND SG_TIPO_CAMPEONATO = pSiglaCamp;
	
	IF pTypeMode = "H2H" THEN

		SELECT U.ID_USUARIO, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO, H.PT_TOTAL, H.IN_REBAIXADO_TEMP_ANTERIOR, H.IN_ACESSO_TEMP_ATUAL, fcGetTimeNameByUserMode(U.ID_USUARIO,pTypeMode) as NM_TIME
		FROM TB_HISTORICO_TEMPORADA H, TB_CAMPEONATO C, TB_CAMPEONATO_USUARIO X, TB_USUARIO U  
		WHERE H.ID_TEMPORADA = _idTemp 
		AND C.ID_CAMPEONATO = _idCamp 
		AND fcGetIdUsuariosVazio(U.ID_USUARIO,'NOT') 
		AND H.ID_USUARIO = U.ID_USUARIO  
		AND H.ID_USUARIO = X.ID_USUARIO  
		AND C.ID_CAMPEONATO = X.ID_CAMPEONATO 
		AND X.ID_USUARIO = U.ID_USUARIO  
		AND U.IN_DESEJA_PARTICIPAR = 1 

		UNION ALL SELECT U.ID_USUARIO, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO, 0 as PT_TOTAL, 0 as IN_REBAIXADO_TEMP_ANTERIOR, 0 as IN_ACESSO_TEMP_ATUAL, fcGetTimeNameByUserMode(U.ID_USUARIO,pTypeMode) as NM_TIME
		FROM TB_CAMPEONATO C, TB_CAMPEONATO_USUARIO X, TB_USUARIO U  
		WHERE C.ID_CAMPEONATO = _idCamp 
		AND fcGetIdUsuariosVazio(U.ID_USUARIO,'NOT')
		AND C.ID_CAMPEONATO = X.ID_CAMPEONATO 
		AND X.ID_USUARIO = U.ID_USUARIO  
		AND U.IN_DESEJA_PARTICIPAR = 1  
		AND U.ID_USUARIO NOT IN (SELECT H.ID_USUARIO FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_TEMPORADA = _idTemp )
		ORDER BY IN_ACESSO_TEMP_ATUAL, IN_REBAIXADO_TEMP_ANTERIOR, PT_TOTAL DESC, NM_Usuario;

	ELSEIF pTypeMode = "FUT" THEN

		SELECT U.ID_USUARIO, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO, H.PT_TOTAL, H.IN_REBAIXADO_TEMP_ANTERIOR, H.IN_ACESSO_TEMP_ATUAL, fcGetTimeNameByUserMode(U.ID_USUARIO,pTypeMode) as NM_TIME
		FROM TB_HISTORICO_TEMPORADA_FUT H, TB_CAMPEONATO C, TB_CAMPEONATO_USUARIO X, TB_USUARIO U  
		WHERE H.ID_TEMPORADA = _idTemp 
		AND C.ID_CAMPEONATO = _idCamp 
		AND fcGetIdUsuariosVazio(U.ID_USUARIO,'NOT')
		AND H.ID_USUARIO = U.ID_USUARIO  
		AND H.ID_USUARIO = X.ID_USUARIO  
		AND C.ID_CAMPEONATO = X.ID_CAMPEONATO 
		AND X.ID_USUARIO = U.ID_USUARIO  
		AND U.IN_DESEJA_PARTICIPAR = 1 

		UNION ALL SELECT U.ID_USUARIO, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO, 0 as PT_TOTAL, 0 as IN_REBAIXADO_TEMP_ANTERIOR, 0 as IN_ACESSO_TEMP_ATUAL, fcGetTimeNameByUserMode(U.ID_USUARIO,pTypeMode) as NM_TIME
		FROM TB_CAMPEONATO C, TB_CAMPEONATO_USUARIO X, TB_USUARIO U  
		WHERE C.ID_CAMPEONATO = _idCamp 
		AND fcGetIdUsuariosVazio(U.ID_USUARIO,'NOT') 
		AND C.ID_CAMPEONATO = X.ID_CAMPEONATO 
		AND X.ID_USUARIO = U.ID_USUARIO  
		AND U.IN_DESEJA_PARTICIPAR = 1  
		AND U.ID_USUARIO NOT IN (SELECT H.ID_USUARIO FROM TB_HISTORICO_TEMPORADA_FUT H WHERE H.ID_TEMPORADA = _idTemp )
		ORDER BY IN_ACESSO_TEMP_ATUAL, IN_REBAIXADO_TEMP_ANTERIOR, PT_TOTAL DESC, NM_Usuario;

	ELSE
	
		SELECT U.ID_USUARIO, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO, H.PT_TOTAL, H.IN_REBAIXADO_TEMP_ANTERIOR, H.IN_ACESSO_TEMP_ATUAL, fcGetTimeNameByUserMode(U.ID_USUARIO,pTypeMode) as NM_TIME
		FROM TB_HISTORICO_TEMPORADA_PRO H, TB_CAMPEONATO C, TB_CAMPEONATO_USUARIO X, TB_USUARIO U  
		WHERE H.ID_TEMPORADA = _idTemp 
		AND C.ID_CAMPEONATO = _idCamp 
		AND fcGetIdUsuariosVazio(U.ID_USUARIO,'NOT')
		AND H.ID_USUARIO = U.ID_USUARIO  
		AND H.ID_USUARIO = X.ID_USUARIO  
		AND C.ID_CAMPEONATO = X.ID_CAMPEONATO 
		AND X.ID_USUARIO = U.ID_USUARIO  
		AND U.IN_DESEJA_PARTICIPAR = 1 

		UNION ALL SELECT U.ID_USUARIO, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO, 0 as PT_TOTAL, 0 as IN_REBAIXADO_TEMP_ANTERIOR, 0 as IN_ACESSO_TEMP_ATUAL, fcGetTimeNameByUserMode(U.ID_USUARIO,pTypeMode) as NM_TIME
		FROM TB_CAMPEONATO C, TB_CAMPEONATO_USUARIO X, TB_USUARIO U  
		WHERE C.ID_CAMPEONATO = _idCamp 
		AND fcGetIdUsuariosVazio(U.ID_USUARIO,'NOT')
		AND C.ID_CAMPEONATO = X.ID_CAMPEONATO 
		AND X.ID_USUARIO = U.ID_USUARIO  
		AND U.IN_DESEJA_PARTICIPAR = 1  
		AND U.ID_USUARIO NOT IN (SELECT H.ID_USUARIO FROM TB_HISTORICO_TEMPORADA_PRO H WHERE H.ID_TEMPORADA = _idTemp )
		ORDER BY IN_ACESSO_TEMP_ATUAL, IN_REBAIXADO_TEMP_ANTERIOR, PT_TOTAL DESC, NM_Usuario;

	END IF;
	
End$$
DELIMITER ;
