USE `arenafifadb`;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTipoCampeonato` $$
CREATE PROCEDURE `spAddTipoCampeonato`(
	pSgTipo VARCHAR(4),
	pNmTipo VARCHAR(200)
)
begin

	insert into TB_TIPO_CAMPEONATO (SG_TIPO_CAMPEONATO, DS_TIPO_CAMPEONATO)
	values (pSgTipo, pNmTipo);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTipoTime` $$
CREATE PROCEDURE `spAddTipoTime`(
	pNmTipo VARCHAR(50)
)
begin

	insert into TB_TIPO_TIME (NM_TIPO_TIME)
	values (pNmTipo);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTiposCampeonato` $$
CREATE PROCEDURE `spGetAllTiposCampeonato`()
begin
	SELECT * FROM TB_TIPO_CAMPEONATO ORDER BY DS_TIPO_CAMPEONATO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTiposTime` $$
CREATE PROCEDURE `spGetAllTiposTime`()
begin
	SELECT * FROM TB_TIPO_TIME ORDER BY NM_TIPO_TIME;
End$$
DELIMITER ;



