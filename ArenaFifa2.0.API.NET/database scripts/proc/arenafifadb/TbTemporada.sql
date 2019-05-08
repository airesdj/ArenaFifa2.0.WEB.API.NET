USE `arenafifadb`;

ALTER TABLE TB_TEMPORADA MODIFY DT_INICIO DATE;
ALTER TABLE TB_TEMPORADA MODIFY DT_FIM DATE;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetIdTempCurrent` $$
CREATE FUNCTION `fcGetIdTempCurrent`() RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idTemp INTEGER DEFAULT NULL;
	
	SELECT H.id_temporada into _idTemp FROM TB_TEMPORADA H 
	WHERE H.DT_FIM IS NULL ORDER BY H.id_temporada DESC LIMIT 1;
	
	IF (_idTemp IS NULL) THEN
		SET _idTemp = 0;
	END IF;
	
	RETURN _idTemp;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetIdTempPrevious` $$
CREATE FUNCTION `fcGetIdTempPrevious`() RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idTemp INTEGER DEFAULT NULL;
	
	SELECT H.id_temporada into _idTemp FROM TB_TEMPORADA H 
	WHERE H.DT_FIM IS NOT NULL ORDER BY H.id_temporada DESC LIMIT 1;
	
	IF (_idTemp IS NULL) THEN
		SET _idTemp = 0;
	END IF;
	
	RETURN _idTemp;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcAddNewTemporadaByFimOldOne` $$
CREATE FUNCTION `fcAddNewTemporadaByFimOldOne`(
	pNmTemp VARCHAR(50),
	pDtInicio DATE
) RETURNS INTEGER
	DETERMINISTIC
begin

	UPDATE TB_TEMPORADA SET DT_FIM = CURDATE() WHERE ID_TEMPORADA = fcGetIdTempCurrent();
	
	call `arenafifadb`.`spAddTemporada`(NULL, pNmTemp, pDtInicio, NULL, 1);

	RETURN fcGetIdTempCurrent();
End$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddNewTemporadaByFimOldOne` $$
CREATE PROCEDURE `spAddNewTemporadaByFimOldOne`(
	pNmTemp VARCHAR(50),
	pDtInicio DATE)
begin

	SELECT fcAddNewTemporadaByFimOldOne(pNmTemp, pDtInicio) as id_current_temporada;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetIDsTemporadaByMode` $$
CREATE PROCEDURE `spGetIDsTemporadaByMode`(
	pMode VARCHAR(3)
)
begin
	DECLARE _nmTemp VARCHAR(50) DEFAULT NULL;
	DECLARE _idTemp INTEGER DEFAULT NULL;
	DECLARE _nmTempPrevious VARCHAR(50) DEFAULT NULL;
	DECLARE _idTempPrevious INTEGER DEFAULT NULL;
	
	SET _idTemp = fcGetIdTempCurrent();
	SET _idTempPrevious = fcGetIdTempPrevious();
	
	SELECT NM_TEMPORADA into _nmTemp FROM TB_TEMPORADA WHERE ID_TEMPORADA = _idTemp;
	SELECT NM_TEMPORADA into _nmTempPrevious FROM TB_TEMPORADA WHERE ID_TEMPORADA = _idTempPrevious;

	SELECT _idTemp as id_current_temporada, _nmTemp as nm_current_temporada, _idTempPrevious as id_previous_temporada, _nmTempPrevious as nm_previous_temporada;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetIDCurrentTemporada` $$
CREATE PROCEDURE `spGetIDCurrentTemporada`()
begin
	call `arenafifadb`.`spGetTemporada`(fcGetIdTempCurrent());
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetCurrentTemporada` $$
CREATE PROCEDURE `spGetCurrentTemporada`()
begin
	SELECT *, DATE_FORMAT(DT_INICIO,'%d/%m/%Y') as DT_INICIO_FORMATADA, DATE_FORMAT(DT_FIM,'%d/%m/%Y') as DT_FIM_FORMATADA
	FROM TB_TEMPORADA WHERE id_temporada = fcGetIdTempCurrent();
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTemporada` $$
CREATE PROCEDURE `spGetAllTemporada`()
begin      
   select *
   from TB_TEMPORADA
   order by NM_TEMPORADA;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetTemporada` $$
CREATE PROCEDURE `spGetTemporada`(idTemporada INTEGER)
begin      
   select *, DATE_FORMAT(DT_INICIO,'%d/%m/%Y') as DT_INICIO_FORMATADA, DATE_FORMAT(DT_FIM,'%d/%m/%Y') as DT_FIM_FORMATADA
   from TB_TEMPORADA
   where ID_TEMPORADA = idTemporada;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteTemporada` $$
CREATE PROCEDURE `spDeleteTemporada`(idTemporada INTEGER)
begin      
   delete from TB_TEMPORADA
   where ID_TEMPORADA = idTemporada;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTemporada` $$
CREATE PROCEDURE `spAddTemporada`(
	pIdTemp INTEGER,
	pNmTemp VARCHAR(50),
	pDtInicio DATE,
	pDtFim DATE,
	pInAtiva INTEGER
)
begin
	IF pIdTemp IS NULL THEN
	
		insert into TB_TEMPORADA (NM_TEMPORADA, DT_INICIO, DT_FIM, IN_TEMPORADA_ATIVA)
		values (pNmTemp, pDtInicio, pDtFim, pInAtiva);
	
	ELSE
	
		insert into TB_TEMPORADA (ID_TEMPORADA, NM_TEMPORADA, DT_INICIO, DT_FIM, IN_TEMPORADA_ATIVA)
		values (pIdTemp, pDtInicio, pDtFim, pInAtiva);
	
	END IF;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateTemporada` $$
CREATE PROCEDURE `spUpdateTemporada`(
	pIdTemp INTEGER,
	pNmTemp VARCHAR(50),
	pDtInicio DATE,
	pDtFim DATE,
	pInAtiva INTEGER
)
begin
	update TB_TEMPORADA 
	set NM_TEMPORADA = pNmTemp,
	DT_INICIO = pDtInicio,
	DT_FIM = pDtFim,
	IN_TEMPORADA_ATIVA = pInAtiva
	where ID_TEMPORADA = pIdTemp;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTemporadasNoFilterCRUD` $$
CREATE PROCEDURE `spGetAllTemporadasNoFilterCRUD`()
begin      
   select *, DATE_FORMAT(DT_INICIO,'%d/%m/%Y') as DT_INICIO_FORMATADA, DATE_FORMAT(DT_FIM,'%d/%m/%Y') as DT_FIM_FORMATADA
   from TB_TEMPORADA
   order by ID_TEMPORADA DESC;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTemporadasWithFilterCRUD` $$
CREATE PROCEDURE `spGetAllTemporadasWithFilterCRUD`(pFilter VARCHAR(20))
begin      
   select *, DATE_FORMAT(DT_INICIO,'%d/%m/%Y') as DT_INICIO_FORMATADA, DATE_FORMAT(DT_FIM,'%d/%m/%Y') as DT_FIM_FORMATADA
   from TB_TEMPORADA
   where (NM_TEMPORADA like CONCAT('%',pFilter,'%'))
   order by ID_TEMPORADA DESC;      
End$$
DELIMITER ;
