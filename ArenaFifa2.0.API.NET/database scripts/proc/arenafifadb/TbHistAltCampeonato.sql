USE `arenafifadb`;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddHistAltCampeonato` $$
CREATE PROCEDURE `spAddHistAltCampeonato`(
	pIdCampAlt INTEGER,
	pIdUsuarioOperacao INTEGER,
	pTpOperacao VARCHAR(30),
	pPsnIdOperacao VARCHAR(30),
	pNmCampAlt VARCHAR(100),	
	pDsPagina VARCHAR(30)
)
begin
	insert into TB_HISTORICO_ALT_CAMPEONATO (ID_CAMPEONATO_ALTERADO, DT_OPERACAO, TP_OPERACAO, ID_USUARIO_OPERACAO, DS_PAGINA, PSN_ID_OPERACAO, NM_CAMP_ALTERADO)
	values (pIdCampAlt, now(), pTpOperacao, pIdUsuarioOperacao, pDsPagina, pPsnIdOperacao, pNmCampAlt);
End$$
DELIMITER ;

