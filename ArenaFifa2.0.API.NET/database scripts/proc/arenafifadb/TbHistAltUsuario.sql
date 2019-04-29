USE `arenafifadb`;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddHistAltUsuario` $$
CREATE PROCEDURE `spAddHistAltUsuario`(
	pIdUsuarioAlt INTEGER,
	pIdUsuarioOperacao INTEGER,
	pTpOperacao VARCHAR(30),
	pPsnIdAlt VARCHAR(30),
	pPsnIdOperacao VARCHAR(30),
	pDsPagina VARCHAR(30)
)
begin
	insert into TB_HISTORICO_ALT_USUARIO (ID_USUARIO_ALTERADO, DT_OPERACAO, TP_OPERACAO, ID_USUARIO_OPERACAO, DS_PAGINA, PSN_ID_OPERACAO, PSN_ID_ALTERADO)
	values (pIdUsuarioAlt, now(), pTpOperacao, pIdUsuarioOperacao, pDsPagina, pPsnIdOperacao, pPsnIdAlt);
End$$
DELIMITER ;

