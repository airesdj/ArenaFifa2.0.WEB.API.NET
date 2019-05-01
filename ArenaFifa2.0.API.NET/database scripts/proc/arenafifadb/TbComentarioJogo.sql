USE `arenafifadb`;



ALTER TABLE TB_COMENTARIO_JOGO MODIFY DT_COMENTARIO DATE;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddComentarioJogo` $$
CREATE PROCEDURE `spAddCampeonatoUsuario`(    
    pIdJogo INTEGER,     
    pIdUsu INTEGER,
	pDsComentario TEXT
)
Begin
	DECLARE _total INTEGER DEFAULT 0;
	
	select count(1) into _total
	from TB_COMENTARIO_JOGO
	where ID_TABELA_JOGO = pIdJogo
	and ID_USUARIO = pIdUsu
	and DS_COMENTARIO = pDsComentario
	and DT_COMENTARIO = CURDATE();
	
	IF _total = 0 THEN

		insert into `TB_COMENTARIO_JOGO` (`ID_TABELA_JOGO`, `ID_USUARIO`, `DT_COMENTARIO`, `HR_COMENTARIO`, `DS_COMENTARIO`) 
		values (pIdJogo, pIdUsu, CURDATE(), DATE_FORMAT(CURRENT_TIME(), '%H:%i'), pDsComentario);
	
	END IF;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllComentarioJogoByJogo` $$
CREATE PROCEDURE `spGetAllComentarioJogoByJogo`(pIdJogo INTEGER)
begin      
   select CJ.*, TU.NM_Usuario, TU.PSN_ID, TU.IN_USUARIO_MODERADOR, TU.IN_USUARIO_AUXILIAR, DATE_FORMAT(CJ.DT_COMENTARIO,'%d/%m/%Y') as DT_COMENTARIO_FORMATADO
   from TB_COMENTARIO_JOGO CJ, TB_USUARIO TU
   where CJ.ID_TABELA_JOGO = pIdJogo
   and CJ.ID_USUARIO = TU.ID_USUARIO
   order by CJ.ID_COMENTARIO;
End$$
DELIMITER ;


