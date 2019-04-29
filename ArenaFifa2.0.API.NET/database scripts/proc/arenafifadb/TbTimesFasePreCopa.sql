USE `arenafifadb`;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTimesFasePreCopaOfCampeonato` $$
CREATE PROCEDURE `spGetAllTimesFasePreCopaOfCampeonato`(pIdCamp INTEGER)
begin      
   select P.*, T.NM_Time, T.DS_Tipo 
   from TB_TIMES_FASE_PRECOPA P, TB_TIME T
   where P.ID_Time = T.ID_Time and P.ID_CAMPEONATO = pIdCamp
   order by T.NM_TIME;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateTimesFasePreCopaNewTime` $$
CREATE PROCEDURE `spUpdateTimesFasePreCopaNewTime`(    
    pIdCamp INTEGER,     
    pIdTimeOld INTEGER,
    pIdTimeNew INTEGER
)
Begin
    update `TB_TIMES_FASE_PRECOPA` 
	set ID_TIME = pIdTimeNew
	where ID_CAMPEONATO = pIdCamp and ID_TIME = pIdTimeOld;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllTimesFasePreCopaOfCampeonato` $$
CREATE PROCEDURE `spDeleteAllTimesFasePreCopaOfCampeonato`(pIdCamp INTEGER)
Begin
    delete from `TB_TIMES_FASE_PRECOPA` 
	where ID_CAMPEONATO = pIdCamp;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddLoadTimesFasePreCopaOfCampeonato` $$
CREATE PROCEDURE `spAddLoadTimesFasePreCopaOfCampeonato`(    
    pIdCamp INTEGER,     
    pIdsTime VARCHAR(250)
)
Begin
	DECLARE _next VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlen INTEGER DEFAULT NULL;
	DECLARE _idTime VARCHAR(5) DEFAULT NULL;
	DECLARE strDelimiter CHAR(1) DEFAULT ',';
	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsTime)) = 0 OR pIdsTime IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _next = SUBSTRING_INDEX(pIdsTime,strDelimiter,1);
		
		SET _nextlen = LENGTH(_next);
		
		SET _idTime = TRIM(_next);
		
		insert into `TB_TIMES_FASE_PRECOPA` (`ID_CAMPEONATO`, `ID_TIME`, `ID_ORDEM_SORTEIO`) 
		values (pIdCamp, pIdTime, Null);
		
		SET pIdsTime = INSERT(pIdsTime,1,_nextlen + 1,'');
	END LOOP;
End$$
DELIMITER ;
