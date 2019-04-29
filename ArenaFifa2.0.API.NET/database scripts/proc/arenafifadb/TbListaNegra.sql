USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetListaNegraByTipoCampeonato` $$
CREATE PROCEDURE `spGetListaNegraByTipoCampeonato`(    
    pIdTemp INTEGER,     
    pTpCamp VARCHAR(100)
)
Begin
	SELECT L.*, U.PSN_ID, U.NM_USUARIO, DATE_FORMAT(fcGetDtUpdateListaNegraTemporada(pIdTemp),'%d/%m/%Y') as DT_FORMATADA, 
	(SELECT C.NM_Campeonato FROM TB_Campeonato C, TB_CAMPEONATO_USUARIO T WHERE C.Id_Campeonato = T.Id_Campeonato And T.ID_Usuario = U.ID_Usuario
	And C.ID_Temporada = pIdTemp And C.SG_TIPO_CAMPEONATO in (pTpCamp) limit 1) as NM_Divisao
	FROM TB_LISTA_NEGRA L, TB_USUARIO U 
	WHERE L.ID_Temporada = pIdTemp
	AND U.ID_USUARIO NOT IN (fcGetIdUsuariosVazio())
	AND L.PT_TOTAL > 0
	AND L.ID_Usuario = U.ID_Usuario
	ORDER BY L.PT_TOTAL Desc, U.NM_Usuario;
End$$
DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetDtUpdateListaNegraTemporada` $$
CREATE FUNCTION `fcGetDtUpdateListaNegraTemporada`(pIdTemp INTEGER) RETURNS DATETIME
	DETERMINISTIC
begin

	DECLARE _dtUpdate DATETIME DEFAULT NULL;
	
	SELECT DT_ATUALIZACAO into _dtUpdate FROM TB_LISTA_NEGRA_DETALHE
	WHERE ID_Temporada = pIdTemp ORDER BY DT_ATUALIZACAO DESC LIMIT 1;
	
	RETURN _dtUpdate;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetListaNegraSummaryByTemporada` $$
CREATE PROCEDURE `spGetListaNegraSummaryByTemporada`(    
    pIdTemp INTEGER)
Begin
	SELECT L.*, U.PSN_ID, U.NM_USUARIO, DATE_FORMAT(fcGetDtUpdateListaNegraTemporada(pIdTemp),'%d/%m/%Y') as DT_FORMATADA, T.NM_TEMPORADA
	FROM TB_LISTA_NEGRA L, TB_USUARIO U, TB_TEMPORADA T
	WHERE L.ID_Temporada = pIdTemp
	AND U.ID_USUARIO NOT IN (fcGetIdUsuariosVazio())
	AND L.PT_TOTAL > 0
	AND L.ID_Usuario = U.ID_Usuario
	AND L.ID_Temporada = T.ID_Temporada
	ORDER BY L.PT_TOTAL Desc, U.NM_Usuario;
End$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetListaNegraDetalheByTemporadaEUsuario` $$
CREATE PROCEDURE `spGetListaNegraDetalheByTemporadaEUsuario`(    
    pIdTemp INTEGER, pIdUsu INTEGER)
Begin
	SELECT L.*, U.PSN_ID, U.NM_USUARIO, DATE_FORMAT(L.DT_ATUALIZACAO,'%d/%m/%Y') as DT_FORMATADA, 
	T.NM_TEMPORADA, J.IN_NUMERO_RODADA, C.NM_CAMPEONATO, F.NM_FASE, fcGetTypeModelOfCampeonato(C.SG_TIPO_CAMPEONATO) as TYPE_MODE
	FROM TB_LISTA_NEGRA_DETALHE L, TB_USUARIO U, TB_TEMPORADA T, TB_TABELA_JOGO J, TB_CAMPEONATO C, TB_FASE F
	WHERE L.ID_Temporada = pIdTemp
	AND U.ID_USUARIO = pIdUsu
	AND L.PT_NEGATIVO > 0
	AND L.ID_Usuario = U.ID_Usuario
	AND L.ID_Temporada = T.ID_Temporada
	AND L.ID_TABELA_JOGO = J.ID_TABELA_JOGO
	AND L.ID_Campeonato = C.ID_Campeonato
	AND J.ID_Campeonato = C.ID_Campeonato
	AND J.ID_Fase = F.ID_Fase
	ORDER BY L.DT_ATUALIZACAO desc, L.PT_NEGATIVO Desc;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllListaNegra` $$
CREATE PROCEDURE `spGetAllListaNegra`()
Begin
	SELECT * FROM (SELECT SUM(L.PT_TOTAL) as TOTAL_GERAL, U.PSN_ID, U.NM_Usuario, U.ID_USUARIO, 
	(SELECT N.PT_TOTAL FROM TB_LISTA_NEGRA N WHERE N.ID_Temporada = fcGetIdTempCurrent()
	AND N.ID_USUARIO = U.ID_USUARIO) as TOTAL_TEMP
	FROM TB_LISTA_NEGRA L, TB_USUARIO U 
	WHERE U.ID_USUARIO NOT IN (fcGetIdUsuariosVazio())
	AND L.PT_TOTAL > 0
	AND L.ID_Usuario = U.ID_Usuario GROUP BY U.PSN_ID, U.NM_Usuario, U.ID_Usuario) as X
	WHERE X.TOTAL_GERAL > 5
	ORDER BY X.TOTAL_GERAL Desc, X.NM_Usuario
	LIMIT 100;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllListaNegraDetalheByUsuario` $$
CREATE PROCEDURE `spGetAllListaNegraDetalheByUsuario`(pIdUsu INTEGER, pIdJogo INTEGER)
Begin
	SELECT * FROM TB_LISTA_NEGRA_DETALHE WHERE ID_TABELA_JOGO = pIdJogo
	AND ID_USUARIO = pIdUsu;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetListaNegraByTipoCampeonatov2` $$
CREATE PROCEDURE `spGetListaNegraByTipoCampeonatov2`(    
    pIdTemp INTEGER,     
    pTpCamp VARCHAR(100)
)
Begin
	SELECT L.*, U.PSN_ID, U.NM_Usuario, DATE_FORMAT(CURDATE(),'%d/%m/%Y') as DATA_ATUAL_FORMATADA, X.NM_Campeonato
	FROM TB_LISTA_NEGRA L, TB_USUARIO U, (SELECT DISTINCT T.ID_Usuario, C.NM_Campeonato FROM TB_Campeonato C, TB_CAMPEONATO_USUARIO T WHERE C.Id_Campeonato = T.Id_Campeonato
	And C.ID_Temporada = pIdTemp And C.SG_TIPO_CAMPEONATO in (pTpCamp)) X
	WHERE L.ID_Temporada = pIdTemp
	AND U.ID_USUARIO NOT IN (fcGetIdUsuariosVazio())
	AND L.PT_TOTAL > 11
	AND X.NM_Campeonato IS NOT NULL
	AND L.ID_Usuario = U.ID_Usuario
	AND L.ID_Usuario = X.ID_Usuario
	AND X.ID_Usuario = U.ID_Usuario
	ORDER BY L.PT_TOTAL Desc, U.NM_Usuario;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteListaNegraDetalhe` $$
CREATE PROCEDURE `spDeleteListaNegraDetalhe`(    
    pIdTemp INTEGER,     
    pIdCamp INTEGER,     
    pIdUsu INTEGER,     
    pIdJogo INTEGER
)
Begin
	DELETE FROM TB_LISTA_NEGRA_DETALHE
	WHERE Id_Temporada = pIdTemp
	AND ID_Campeonato = pIdCamp
	AND ID_Usuario = pIdUsu
	AND ID_Tabela_Jogo = pIdJogo;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteListaNegraVazio` $$
CREATE PROCEDURE `spDeleteListaNegraVazio`(pIdTemp INTEGER)
Begin
	DELETE FROM TB_LISTA_NEGRA
	WHERE Id_Temporada = pIdTemp
	AND IPT_TOTAL = 0;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spRemoveListaNegraByJogo` $$
CREATE PROCEDURE `spRemoveListaNegraByJogo`(pIdJogo INTEGER)
Begin
	DECLARE _MsgRetorno VARCHAR(100) DEFAULT "";
	DECLARE _PsnID VARCHAR(30) DEFAULT NULL;
	DECLARE _idTempCurrent INTEGER DEFAULT NULL;
	DECLARE _QtdGolsHome INTEGER DEFAULT NULL;
	DECLARE _IdUsuHome INTEGER DEFAULT NULL;
	DECLARE _IdUsuAway INTEGER DEFAULT NULL;
	DECLARE _IdCamp INTEGER DEFAULT NULL;
	DECLARE _CountAux INTEGER DEFAULT NULL;
	
	SELECT ID_CAMPEONATO, ID_USUARIO_TIME_VISITANTE, ID_USUARIO_TIME_CASA, QT_GOLS_TIME_CASA into _IdCamp, _IdUsuAway, _IdUsuHome, _QtdGolsHome 
	FROM TB_TABELA_JOGO WHERE ID_TABELA_JOGO = pIdJogo;
	
	IF (_IdCamp IS NOT NULL) THEN
	
		SET _idTempCurrent = fcGetIdTempCurrent();
		
		SELECT count(1) into _CountAux FROM TB_LISTA_NEGRA_DETALHE 
		WHERE C.ID_CAMPEONATO = _IdCamp AND ID_TABELA_JOGO = pIdJogo;
		
		IF (_CountAux = 2) THEN
		
			SET _MsgRetorno = "Atenção Senhores técnicos, <br><br>          <b>A pontuação negativa de ambos os técnicos, referente a esta partida, foi retirada.</b>";
		
			call `arenafifadb`.`spDeleteListaNegra`(_idTempCurrent, _IdCamp, _IdUsuHome, pIdJogo);
			call `arenafifadb`.`spDeleteListaNegra`(_idTempCurrent, _IdCamp, _IdUsuAway, pIdJogo);
		
		ELSEIF (_CountAux = 1) THEN
		
			SELECT U.psn_id into _PsnID FROM TB_LISTA_NEGRA_DETALHE C, TB_USUARIO U 
			WHERE C.ID_TEMPORADA = _idTempCurrent AND C.ID_CAMPEONATO = _IdCamp AND C.ID_USUARIO = _IdUsuHome AND C.ID_TABELA_JOGO = pIdJogo;
			
			IF (_PsnID IS NOT NULL) THEN 
			
				SET _MsgRetorno = CONCAT("Atenção Técnico ", _PsnID);
				SET _MsgRetorno = CONCAT(_MsgRetorno, ", <br><br>          <b>A sua pontuação negativa, referente a esta partida, foi retirada.</b>");
			
				call `arenafifadb`.`spDeleteListaNegra`(_idTempCurrent, _IdCamp, _IdUsuHome, pIdJogo);
			
			ELSE
			
				SET _PsnID = NULL;

				SELECT U.psn_id into _PsnID FROM TB_LISTA_NEGRA_DETALHE C, TB_USUARIO U 
				WHERE C.ID_TEMPORADA = _idTempCurrent AND C.ID_CAMPEONATO = _IdCamp AND C.ID_USUARIO = _IdUsuAway AND C.ID_TABELA_JOGO = pIdJogo;
				
				IF (_PsnID IS NOT NULL) THEN 
				
					SET _MsgRetorno = CONCAT("Atenção Técnico ", _PsnID);
					SET _MsgRetorno = CONCAT(_MsgRetorno, ", <br><br>          <b>A sua pontuação negativa, referente a esta partida, foi retirada.</b>");
				
					call `arenafifadb`.`spDeleteListaNegra`(_idTempCurrent, _IdCamp, _IdUsuAway, pIdJogo);
				
				END IF;
				
			END IF;
		
		END IF;
	
	END IF;
	
	SELECT _MsgRetorno as DSC_COMENTARIO_RETIRADA_LISTA_NEGRA;

End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddListaNegraDetalhe` $$
CREATE PROCEDURE `spAddListaNegraDetalhe`(
    pIdTemp INTEGER,     
    pIdCamp INTEGER,     
    pIdUsu INTEGER,     
    pIdJogo INTEGER,
	pSgTpListaNegra VARCHAR(10)
)

Begin

	DECLARE _PT_ADVERTENCIA_LN INTEGER DEFAULT 1;
	DECLARE _PT_OMISSAO_PARCIAL_LN INTEGER DEFAULT 2;
	DECLARE _PT_ANTIDESPORTIVA_LN INTEGER DEFAULT 3;
	DECLARE _PT_OMISSAO_TOTAL_LN INTEGER DEFAULT 4;

	IF (pSgTpListaNegra = "LN_ADV") THEN
	
		INSERT INTO TB_LISTA_NEGRA_DETALHE (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO, ID_TABELA_JOGO, 
											IN_ADVERTENCIAS, IN_OMISSAO_PARCIAL, IN_OMISSAO_TOTAL, IN_ANTIDESPORTIVA, PT_NEGATIVO, DT_ATUALIZACAO)
		VALUES (pIdTemp, pIdCamp, pIdUsu, pIdJogo, 
				1, 0, 0, 0, _PT_ADVERTENCIA_LN, NOW());

	ELSEIF (pSgTpListaNegra = "LN_OMP") THEN
	
		INSERT INTO TB_LISTA_NEGRA_DETALHE (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO, ID_TABELA_JOGO, 
											IN_ADVERTENCIAS, IN_OMISSAO_PARCIAL, IN_OMISSAO_TOTAL, IN_ANTIDESPORTIVA, PT_NEGATIVO, DT_ATUALIZACAO)
		VALUES (pIdTemp, pIdCamp, pIdUsu, pIdJogo, 
				0, 1, 0, 0, _PT_OMISSAO_PARCIAL_LN, NOW());

	ELSEIF (pSgTpListaNegra = "LN_ADP") THEN
	
		INSERT INTO TB_LISTA_NEGRA_DETALHE (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO, ID_TABELA_JOGO, 
											IN_ADVERTENCIAS, IN_OMISSAO_PARCIAL, IN_OMISSAO_TOTAL, IN_ANTIDESPORTIVA, PT_NEGATIVO, DT_ATUALIZACAO)
		VALUES (pIdTemp, pIdCamp, pIdUsu, pIdJogo, 
				0, 0, 1, 0, _PT_ANTIDESPORTIVA_LN, NOW());

	ELSEIF (pSgTpListaNegra = "LN_OMT") THEN
	
		INSERT INTO TB_LISTA_NEGRA_DETALHE (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO, ID_TABELA_JOGO, 
											IN_ADVERTENCIAS, IN_OMISSAO_PARCIAL, IN_OMISSAO_TOTAL, IN_ANTIDESPORTIVA, PT_NEGATIVO, DT_ATUALIZACAO)
		VALUES (pIdTemp, pIdCamp, pIdUsu, pIdJogo, 
				0, 0, 0, 1, _PT_OMISSAO_TOTAL_LN, NOW());

	END IF;

End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spCalculateListaNegra` $$
CREATE PROCEDURE `spCalculateListaNegra`(
    pIdTemp INTEGER,     
    pIdUsu INTEGER)

Begin

	DECLARE _QtdADV INTEGER DEFAULT 0;
	DECLARE _QtdOMP INTEGER DEFAULT 0;
	DECLARE _QtdOMT INTEGER DEFAULT 0;
	DECLARE _QtdANT INTEGER DEFAULT 0;
	DECLARE _QtdTotal INTEGER DEFAULT NULL;
	
	SELECT count(1) into _QtdADV
	FROM TB_LISTA_NEGRA_DETALHE
	WHERE Id_Temporada = pIdTemp
	AND ID_Usuario = pIdUsu
	AND IN_ADVERTENCIAS = 1;

	SELECT count(1) into _QtdOMP
	FROM TB_LISTA_NEGRA_DETALHE
	WHERE Id_Temporada = pIdTemp
	AND ID_Usuario = pIdUsu
	AND IN_OMISSAO_PARCIAL = 1;

	SELECT count(1) into _QtdANT
	FROM TB_LISTA_NEGRA_DETALHE
	WHERE Id_Temporada = pIdTemp
	AND ID_Usuario = pIdUsu
	AND IN_ANTIDESPORTIVA = 1;

	SELECT count(1) into _QtdOMT
	FROM TB_LISTA_NEGRA_DETALHE
	WHERE Id_Temporada = pIdTemp
	AND ID_Usuario = pIdUsu
	AND IN_OMISSAO_TOTAL = 1;

	SELECT SUM(PT_NEGATIVO) into _QtdTotal
	FROM TB_LISTA_NEGRA_DETALHE
	WHERE Id_Temporada = pIdTemp
	AND ID_Usuario = pIdUsu;
	
	call `arenafifadb`.`spDeleteListaNegraVazio`(pIdTemp);

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetListaNegraDetalheByJogo` $$
CREATE PROCEDURE `spGetListaNegraDetalheByJogo`(    
    pIdUsu INTEGER,     
    pTpJogo  INTEGER
)
Begin
	DECLARE _idTempCurrent INTEGER DEFAULT NULL;
	
	SET _idTempCurrent = fcGetIdTempCurrent();

	SELECT *
	FROM TB_LISTA_NEGRA_DETALHE
	WHERE Id_Temporada = _idTempCurrent
	AND ID_Usuario = pIdUsu
	AND ID_Tabela_Jogo = pIdJogo
	LIMIT 1;
End$$
DELIMITER ;

