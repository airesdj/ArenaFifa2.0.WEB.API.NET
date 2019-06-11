USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddCampeonatoTime` $$
CREATE PROCEDURE `spAddCampeonatoTime`(    
    pIdCamp INTEGER,     
    pIdTime INTEGER
)
Begin
	insert into `TB_CAMPEONATO_TIME` (`ID_CAMPEONATO`, `ID_TIME`) 
	values (pIdCamp, pIdTime);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateCampeonatoTimeNewTime` $$
CREATE PROCEDURE `spUpdateCampeonatoTimeNewTime`(    
    pIdCamp INTEGER,     
    pIdTimeOld INTEGER,
    pIdTimeNew INTEGER
)
Begin
    update `TB_CAMPEONATO_TIME` 
	set ID_TIME = pIdTimeNew
	where ID_CAMPEONATO = pIdCamp and ID_TIME = pIdTimeOld;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spTransferCampeonatoTimeNewCampeonato` $$
CREATE PROCEDURE `spTransferCampeonatoTimeNewCampeonato`(    
    pIdCampOld INTEGER,     
    pIdCampNew INTEGER
)
Begin
	insert into `TB_CAMPEONATO_TIME` (`ID_CAMPEONATO`, `ID_TIME`)
	select pIdCampNew, `ID_TIME`
    from `TB_CAMPEONATO_TIME` 
	where ID_CAMPEONATO = pIdCampOld;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTimesOfCampeonatoOrdemSorteio` $$
CREATE PROCEDURE `spGetAllTimesOfCampeonatoOrdemSorteio`(pIdCamp INTEGER)
begin      
   select CT.*, TM.NM_TIME, TM.ID_TIPO_TIME, TM.DS_TIPO, TU.NM_Usuario, TU.psn_id, TU.ID_Usuario 
   from TB_CAMPEONATO_TIME CT, TB_TIME TM, TB_USUARIO_TIME UT, TB_USUARIO TU 
   where CT.ID_CAMPEONATO = pIdCamp
   and UT.ID_USUARIO = TU.ID_USUARIO and UT.ID_CAMPEONATO = CT.ID_CAMPEONATO and UT.ID_TIME=TM.ID_TIME and UT.DT_VIGENCIA_FIM is null
   order by UT.INDICADOR_ORDEM_SORTEIO;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTimesOfCampeonato` $$
CREATE PROCEDURE `spGetAllTimesOfCampeonato`(pIdCamp INTEGER)
begin      
   select ID_TIME, NM_TIME, DS_TIPO from TB_TIME where ID_TIME in (select ID_TIME from TB_CAMPEONATO_TIME where ID_CAMPEONATO = pIdCamp) order by NM_TIME;      
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTimesOfCampeonatoOrdemTime` $$
CREATE PROCEDURE `spGetAllTimesOfCampeonatoOrdemTime`(pIdCamp INTEGER)
begin      
   select CT.*, TM.NM_TIME, TM.ID_TIPO_TIME, TM.DS_TIPO, TU.NM_Usuario, TU.psn_id, TU.ID_Usuario 
   from TB_CAMPEONATO_TIME CT, TB_TIME TM, TB_USUARIO_TIME UT, TB_USUARIO TU 
   where CT.ID_CAMPEONATO = pIdCamp
   and UT.ID_USUARIO = TU.ID_USUARIO and UT.ID_CAMPEONATO = CT.ID_CAMPEONATO and UT.ID_TIME=TM.ID_TIME and UT.DT_VIGENCIA_FIM is null
   order by UT.TM.NM_TIME;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllCampeonatoTimeOfCampeonato` $$
CREATE PROCEDURE `spDeleteAllCampeonatoTimeOfCampeonato`(pIdCamp INTEGER)
Begin
    delete from `TB_CAMPEONATO_TIME` 
	where ID_CAMPEONATO = pIdCamp;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddLoadCampeonatoTimeOfCampeonatoById` $$
CREATE PROCEDURE `spAddLoadCampeonatoTimeOfCampeonatoById`(    
    pIdCamp INTEGER,     
    pIdsTime VARCHAR(250)
)
Begin
	DECLARE _next VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlen INTEGER DEFAULT NULL;
	DECLARE _idTime VARCHAR(5) DEFAULT NULL;
	DECLARE strDelimiter CHAR(1) DEFAULT ',';
	
	call `arenafifadb`.`spDeleteAllCampeonatoTimeOfCampeonato`(pIdCamp);
	
	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsTime)) = 0 OR pIdsTime IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _next = SUBSTRING_INDEX(pIdsTime,strDelimiter,1);
		
		SET _nextlen = LENGTH(_next);
		
		SET _idTime = TRIM(_next);
		
		insert into `TB_CAMPEONATO_TIME` (`ID_CAMPEONATO`, `ID_TIME`) 
		values (pIdCamp, CAST(_idTime AS SIGNED));
		
		SET pIdsTime = INSERT(pIdsTime,1,_nextlen + 1,'');
	END LOOP;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddLoadCampeonatoTimeOfCampeonatoByName` $$
CREATE PROCEDURE `spAddLoadCampeonatoTimeOfCampeonatoByName`(    
    pIdCamp INTEGER,     
    pListaTimes VARCHAR(250),
	pTpTime VARCHAR(10)
)
Begin
	DECLARE _nmTime VARCHAR(5) DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE tabela_cursor CURSOR FOR 
		SELECT ID_TIME FROM TB_TIME WHERE NM_TIME IN (pListaTimes) AND DS_TIPO NOT IN(pTpTime) ORDER BY NM_TIME;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idTime;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;

		INSERT INTO TB_CAMPEONATO_TIME (ID_CAMPEONATO, ID_TIME) VALUES (pIdCamp, _idTime);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
End$$
DELIMITER ;




