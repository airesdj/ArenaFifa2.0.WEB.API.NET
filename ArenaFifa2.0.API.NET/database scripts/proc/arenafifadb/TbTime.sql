USE `arenafifadb`;

DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetIdTimeByUsuario` $$
CREATE FUNCTION `fcGetIdTimeByUsuario`(pIdCamp INTEGER, pIdUsu INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idTime INTEGER DEFAULT 0;
	
	SELECT U.ID_TIME into _idTime
	FROM TB_USUARIO_TIME U, TB_TIME T
	WHERE U.ID_CAMPEONATO = pIdCamp AND U.ID_USUARIO = pIdUsu AND U.DT_VIGENCIA_FIM IS NULL
	AND U.ID_TIME = T.ID_TIME ORDER BY U.ID_TIME LIMIT 1;
	
	IF (_idTime IS NULL) THEN
	
		SET _idTime = 0;
	
	END IF;
	
	RETURN _idTime;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTimesNoFilterCRUD` $$
CREATE PROCEDURE `spGetAllTimesNoFilterCRUD`()
begin      
   select T.*, P.NM_Tipo_Time, U.NM_Usuario, (CONCAT(U.NM_Usuario, ' (', U.PSN_ID, ')')) as NM_Tecnico_FUT
   from (TB_TIME T INNER JOIN TB_TIPO_TIME P ON  T.ID_Tipo_Time = P.ID_Tipo_Time) LEFT JOIN TB_USUARIO U ON T.ID_TECNICO_FUT = U.ID_Usuario
   order by T.NM_TIME;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTimesWithFilterCRUD` $$
CREATE PROCEDURE `spGetAllTimesWithFilterCRUD`(pFilter VARCHAR(20))
begin      
   select T.*, P.NM_Tipo_Time, U.NM_Usuario, (CONCAT(U.NM_Usuario, ' (', U.PSN_ID, ')')) as NM_Tecnico_FUT
   from (TB_TIME T INNER JOIN TB_TIPO_TIME P ON  T.ID_Tipo_Time = P.ID_Tipo_Time) LEFT JOIN TB_USUARIO U ON T.ID_TECNICO_FUT = U.ID_Usuario
   where (T.NM_Time like CONCAT('%',pFilter,'%') or P.NM_Tipo_Time like CONCAT('%',pFilter,'%') or U.NM_Usuario like CONCAT('%',pFilter,'%'))
   order by T.NM_TIME;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetTime` $$
CREATE PROCEDURE `spGetTime`(idTime INTEGER)
begin      
   select T.*, P.NM_Tipo_Time, U.NM_Usuario, U.PSN_ID, (CONCAT(U.NM_Usuario, ' (', U.PSN_ID, ')')) as NM_Tecnico_FUT
   from (TB_TIME T INNER JOIN TB_TIPO_TIME P ON  T.ID_Tipo_Time = P.ID_Tipo_Time) LEFT JOIN TB_USUARIO U ON T.ID_TECNICO_FUT = U.ID_Usuario
   where T.ID_TIME = idTime
   order by T.NM_TIME;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteTime` $$
CREATE PROCEDURE `spDeleteTime`(idTime INTEGER)
begin      
   delete from TB_TIME
   where ID_TIME = idTime;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTime` $$
CREATE PROCEDURE `spAddTime`(    
    pNmTime VARCHAR(50),    
    pdsUrl VARCHAR(200),    
    pIdTipo INTEGER,    
    pIdTimeSofifa INTEGER,    
    pIdTecnico INTEGER 
)
Begin
	DECLARE _idTime INTEGER DEFAULT NULL;
	
	IF pIdTecnico = 0 THEN
		SET pIdTecnico = NULL;
	END IF;
	
	IF pIdTimeSofifa = 0 THEN
		SET pIdTimeSofifa = NULL;
	END IF;
	
	insert into `TB_TIME` (`NM_TIME`, `DS_URL_TIME`, `ID_TIPO_TIME`, `ID_TIME_SOFIFA`, `ID_TECNICO_FUT`) 
	values (pNmTime, pdsUrl, pIdTipo, pIdTimeSofifa, pIdTecnico);
	
	select ID_TIME into _idTime
	from TB_TIME
	order by ID_TIME desc
	limit 1;

	call `arenafifadb`.`spUpdateTipoTipoByTime`(_idTime);
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateTime` $$
CREATE PROCEDURE `spUpdateTime`(    
    pIdTime INTEGER,     
    pNmTime VARCHAR(50),    
    pdsUrl VARCHAR(200),    
    pIdTipo INTEGER,    
    pIdTimeSofifa INTEGER,    
    pIdTecnico INTEGER 
)
Begin
	IF pIdTecnico = 0 THEN
		SET pIdTecnico = NULL;
	END IF;
	
	IF pIdTimeSofifa = 0 THEN
		SET pIdTimeSofifa = NULL;
	END IF;
	
	update `TB_TIME`
	set NM_TIME = pNmTime,
	    DS_URL_TIME = pdsUrl,
		ID_TIPO_TIME = pIdTipo,
		ID_TIME_SOFIFA = pIdTimeSofifa,
		ID_TECNICO_FUT = pIdTecnico
	where ID_TIME = pIdTime;
	
	call `arenafifadb`.`spUpdateTipoTipoByTime`(pIdTime);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateTipoTipoByTime` $$
CREATE PROCEDURE `spUpdateTipoTipoByTime`(pIdTime INTEGER)
Begin
	update TB_TIME T, TB_TIPO_TIME P
	set T.DS_TIPO = Left(P.NM_Tipo_Time,3)
	where T.ID_TIPO_TIME = P.ID_TIPO_TIME and T.ID_TIPO_TIME > 1 and T.ID_TIME = pIdTime;

	update TB_TIME T, TB_TIPO_TIME P
	set T.DS_TIPO = NULL
	where T.ID_TIPO_TIME = P.ID_TIPO_TIME and T.ID_TIPO_TIME = 1 and T.ID_TIME = pIdTime;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spTransferTimeNewTecnico` $$
CREATE PROCEDURE `spTransferTimeNewTecnico`(pIdNewUsu INTEGER, pIdTime INTEGER)
Begin
	update TB_TIME 
	set ID_TECNICO_FUT = pIdNewUsu
	where ID_TIME = pIdTime;
End$$
DELIMITER ;





DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTipoTime` $$
CREATE PROCEDURE `spGetAllTipoTime`()
begin      
   select *
   from TB_TIPO_TIME
   order by NM_TIPO_TIME;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTimesH2H` $$
CREATE PROCEDURE `spGetAllTimesH2H`()
begin      
   select T.*, P.NM_Tipo_Time, U.NM_Usuario, (CONCAT(U.NM_Usuario, ' (', U.PSN_ID, ')')) as NM_Tecnico_FUT
   from (TB_TIME T INNER JOIN TB_TIPO_TIME P ON  T.ID_Tipo_Time = P.ID_Tipo_Time) LEFT JOIN TB_USUARIO U ON T.ID_TECNICO_FUT = U.ID_Usuario
   WHERE T.ID_TIPO_TIME NOT IN (37,39,40,41,42)
   order by T.NM_TIME;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTimesPRO` $$
CREATE PROCEDURE `spGetAllTimesPRO`()
begin      
   select T.*, P.NM_Tipo_Time, U.NM_Usuario, (CONCAT(U.NM_Usuario, ' (', U.PSN_ID, ')')) as NM_Tecnico_FUT
   from (TB_TIME T INNER JOIN TB_TIPO_TIME P ON  T.ID_Tipo_Time = P.ID_Tipo_Time) LEFT JOIN TB_USUARIO U ON T.ID_TECNICO_FUT = U.ID_Usuario
   WHERE T.ID_TIPO_TIME = 42
   order by T.NM_TIME;      
End$$
DELIMITER ;
