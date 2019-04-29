USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddGrupo` $$
CREATE PROCEDURE `spAddGrupo`(    
    pIdCamp INTEGER,     
    pIdGrupo INTEGER,
	pNmGrupo VARCHAR(50)
)
Begin
	insert into `TB_GRUPO` (`ID_CAMPEONATO`, `ID_GRUPO`, `NM_GRUPO`) 
	values (pIdCamp, pIdGrupo, pNmGrupo);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spTransferGrupoNewCampeonato` $$
CREATE PROCEDURE `spTransferGrupoNewCampeonato`(    
    pIdCampOld INTEGER,     
    pIdCampNew INTEGER
)
Begin
	insert into `TB_GRUPO` (`ID_CAMPEONATO`, `ID_GRUPO`, `NM_GRUPO`)
	select pIdCampNew, `ID_GRUPO`, `NM_GRUPO`
    from `TB_GRUPO` 
	where ID_CAMPEONATO = pIdCampOld;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllGrupoOfCampeonato` $$
CREATE PROCEDURE `spDeleteAllGrupoOfCampeonato`(pIdCamp INTEGER)
Begin
    delete from `TB_GRUPO` 
	where ID_CAMPEONATO = pIdCamp;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddLoadGrupoOfCampeonato` $$
CREATE PROCEDURE `spAddLoadGrupoOfCampeonato`(    
    pIdCamp INTEGER,     
    pQtdGrupo INTEGER
)
Begin
	
	DECLARE _aux INTEGER DEFAULT 1;
	
	WHILE _aux <= pQtdGrupo DO
	
		insert into `TB_GRUPO` (`ID_CAMPEONATO`, `ID_GRUPO`, `NM_GRUPO`) 
		values (pIdCamp, _aux, 'Grupo '+CAST(_aux AS CHAR));
	
		SET _aux=_aux+1;
		
	END WHILE;
	
End$$
DELIMITER ;
