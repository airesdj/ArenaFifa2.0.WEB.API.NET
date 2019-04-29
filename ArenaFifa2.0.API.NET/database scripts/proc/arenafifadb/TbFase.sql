USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllFase` $$
CREATE PROCEDURE `spGetAllFase`()
begin      
   select *
   from TB_FASE
   order by NM_FASE;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetFase` $$
CREATE PROCEDURE `spGetFase`(pIdFase INTEGER)
begin      
   select *
   from TB_FASE
   where ID_FASE = pIdFase;
End$$
DELIMITER ;