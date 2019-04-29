USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddComentarioUsuario` $$
CREATE PROCEDURE `spAddComentarioUsuario`(    
    pIdTab INTEGER,     
    pIdCamp INTEGER,     
    pIdUsu INTEGER
)
Begin
	insert into TB_COMENTARIO_USUARIO values (pIdTab, pIdCamp, pIdUsu);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateComentarioUsuarioNewUsuario` $$
CREATE PROCEDURE `spUpdateComentarioUsuarioNewUsuario`(    
    pIdCamp INTEGER,     
    pIdUsuOld INTEGER,
    pIdUsuNew INTEGER
)
Begin
    update `TB_COMENTARIO_USUARIO` 
	set ID_USUARIO = pIdUsuNew
	where ID_CAMPEONATO = pIdCamp and ID_USUARIO = pIdUsuOld;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteComentarioUsuarioOfCampeonato` $$
CREATE PROCEDURE `spDeleteComentarioUsuarioOfCampeonato`(pIdCamp INTEGER)
Begin
    delete from `TB_COMENTARIO_USUARIO` 
	where ID_CAMPEONATO = pIdCamp;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteComentarioUsuarioOfTabelaJogoEfetivado` $$
CREATE PROCEDURE `spDeleteComentarioUsuarioOfTabelaJogoEfetivado`()
Begin
    delete from `TB_COMENTARIO_USUARIO` 
	where ID_TABELA_JOGO in (select J.ID_TABELA_JOGO from TB_TABELA_JOGO J where J.DT_EFETIVACAO_JOGO is not null);
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddLoadComentarioUsuarioOfCampeonato` $$
CREATE PROCEDURE `spAddLoadComentarioUsuarioOfCampeonato`(pIdCamp INTEGER)
Begin
	INSERT INTO TB_COMENTARIO_USUARIO
		SELECT J.ID_TABELA_JOGO, J.ID_CAMPEONATO, U1.ID_USUARIO
		from TB_TABELA_JOGO J, TB_TIME T1, TB_USUARIO_TIME X1, TB_USUARIO U1
		where J.ID_CAMPEONATO = pIdCamp
		and J.IN_NUMERO_RODADA > 0
		and J.ID_TIME_CASA = T1.ID_TIME
		and J.ID_CAMPEONATO = X1.ID_CAMPEONATO
		and J.ID_TIME_CASA = X1.ID_TIME
		and X1.ID_USUARIO = U1.ID_USUARIO
		AND X1.DT_VIGENCIA_FIM IS NULL;

	INSERT INTO TB_COMENTARIO_USUARIO
		SELECT J.ID_TABELA_JOGO, J.ID_CAMPEONATO, U1.ID_USUARIO
		from TB_TABELA_JOGO J, TB_TIME T1, TB_USUARIO_TIME X1, TB_USUARIO U1
		where J.ID_CAMPEONATO = pIdCamp
		and J.IN_NUMERO_RODADA > 0
		and J.ID_TIME_VISITANTE = T1.ID_TIME
		and J.ID_CAMPEONATO = X1.ID_CAMPEONATO
		and J.ID_TIME_VISITANTE = X1.ID_TIME
		and X1.ID_USUARIO = U1.ID_USUARIO
		AND X1.DT_VIGENCIA_FIM IS NULL;
End$$
DELIMITER ;


