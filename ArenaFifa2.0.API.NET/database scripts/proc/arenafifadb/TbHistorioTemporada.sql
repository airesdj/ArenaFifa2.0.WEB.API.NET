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
DROP PROCEDURE IF EXISTS `spAddHistoricoTemporadaH2H` $$
CREATE PROCEDURE `spAddHistoricoTemporadaH2H`(
	pIdTemp INTEGER,
	pIdUsu INTEGER,
	pIdTipoAcesso INTEGER
)
Begin
	DECLARE _count INTEGER DEFAULT 0;
	
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
											IN_REBAIXADO_TEMP_ANTERIOR, IN_ACESSO_TEMP_ATUAL, QT_LSTNEGRA, PT_TOTAL, PT_TOTAL_TEMPORADA_ANTERIOR, IN_POSICAO_ANTERIOR, 
											QT_JOGOS_GERAL, QT_TOTAL_PONTOS_GERAL, QT_TOTAL_VITORIAS_GERAL, QT_TOTAL_EMPATES_GERAL, PC_APROVEITAMENTO_GERAL)
		VALUES (pIdTemp, pIdUsu, pIdTipoAcesso, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	
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
											IN_REBAIXADO_TEMP_ANTERIOR, IN_ACESSO_TEMP_ATUAL, QT_LSTNEGRA, PT_TOTAL, PT_TOTAL_TEMPORADA_ANTERIOR, IN_POSICAO_ANTERIOR, 
											QT_JOGOS_GERAL, QT_TOTAL_PONTOS_GERAL, QT_TOTAL_VITORIAS_GERAL, QT_TOTAL_EMPATES_GERAL, PC_APROVEITAMENTO_GERAL)
		VALUES (pIdTemp, pIdUsu, pIdTipoAcesso, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	
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
											IN_REBAIXADO_TEMP_ANTERIOR, IN_ACESSO_TEMP_ATUAL, QT_LSTNEGRA, PT_TOTAL, PT_TOTAL_TEMPORADA_ANTERIOR, IN_POSICAO_ANTERIOR, 
											QT_JOGOS_GERAL, QT_TOTAL_PONTOS_GERAL, QT_TOTAL_VITORIAS_GERAL, QT_TOTAL_EMPATES_GERAL, PC_APROVEITAMENTO_GERAL)
		VALUES (pIdTemp, pIdUsu, pIdTipoAcesso, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	
	END IF;
End$$
DELIMITER ;
