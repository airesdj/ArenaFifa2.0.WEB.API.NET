USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spRemoveSorteioTimes` $$
CREATE PROCEDURE `spRemoveSorteioTimes`(pIdCamp INTEGER)
Begin

	call `arenafifadb`.`spDeleteComentarioUsuarioOfCampeonato`(pIdCamp);
	call `arenafifadb`.`spDeleteAllTabelaJogoOfCampeonato`(pIdCamp);
	call `arenafifadb`.`spDeleteUsuarioTimeOfCampeonato`(pIdCamp);
	call `arenafifadb`.`spRemoveClassificacaoGrupoOfAllTimes`(pIdCamp);

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spRemoveSorteioGrupos` $$
CREATE PROCEDURE `spRemoveSorteioGrupos`(pIdCamp INTEGER)
Begin

	call `arenafifadb`.`spDeleteComentarioUsuarioOfCampeonato`(pIdCamp);
	call `arenafifadb`.`spDeleteAllTabelaJogoOfCampeonato`(pIdCamp);
	call `arenafifadb`.`spRemoveClassificacaoGrupoOfAllTimes`(pIdCamp);

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spRemoveSorteioJogos` $$
CREATE PROCEDURE `spRemoveSorteioJogos`(pIdCamp INTEGER)
Begin

	call `arenafifadb`.`spDeleteComentarioUsuarioOfCampeonato`(pIdCamp);
	call `arenafifadb`.`spDeleteAllTabelaJogoOfCampeonato`(pIdCamp);

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spCountRecordSegFase` $$
CREATE PROCEDURE `spRemoveSorteioJogos`(pIdCamp INTEGER)
Begin

	select count(1) as Total, 'TotalTimesFasePreCopa' as DS_TIPO_COUNT 
	from TB_TIMES_FASE_PRECOPA
	where ID_CAMPEONATO = pIdCamp
	UNION ALL
	select count(1) as Total, 'TotalCampUsuarioSegFase' as DS_TIPO_COUNT 
	from TB_CAMPEONATO_USUARIO_SEG_FASE
	where ID_CAMPEONATO = pIdCamp;

End$$
DELIMITER ;
