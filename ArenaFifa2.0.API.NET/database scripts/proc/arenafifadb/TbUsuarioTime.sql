USE `arenafifadb`;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteUsuarioTimeOfCampeonato` $$
CREATE PROCEDURE `spDeleteUsuarioTimeOfCampeonato`(
	pIdCamp INTEGER
)
begin

	delete from TB_USUARIO_TIME
	where ID_CAMPEONATO = pIdCamp;
 
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetTotalRecordsUsuarioTime` $$
CREATE PROCEDURE `spGetTotalRecordsUsuarioTime`(
	pIdCamp INTEGER
)
begin

	select count(1) as Total_Records from TB_USUARIO_TIME
	where ID_CAMPEONATO = pIdCamp;
 
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spTransferUsuarioTimeToNewUsuario` $$
CREATE PROCEDURE `spTransferUsuarioTimeToNewUsuario`(
	pIdCamp INTEGER,
	pIdTime INTEGER,
	pIdUsuOld INTEGER,
	pIdUsuNew INTEGER
)
begin      

	update TB_USUARIO_TIME set DT_VIGENCIA_FIM = now()
	where ID_CAMPEONATO = pIdCamp and ID_USUARIO = pIdUsuOld;
	
	insert into TB_USUARIO_TIME (ID_CAMPEONATO, ID_USUARIO, ID_TIME, DT_SORTEIO)
	values (pIdCamp, pIdUsuNew, pIdTime, now());

	select U.*, (CONCAT(T.NM_Time, ' (', T.DS_TIPO, ')')) as DSC_TIME
	from TB_USUARIO_TIME U, TB_TIME T
	where U.ID_TIME = T.ID_TIME
	and U.ID_CAMPEONATO = pIdCamp
	and U.ID_USUARIO = pIdUsuNew
	and U.DT_VIGENCIA_FIM is null;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateUsuarioTimeNewUsuario` $$
CREATE PROCEDURE `spUpdateUsuarioTimeNewUsuario`(    
	pIdCamp INTEGER,
	pIdUsu INTEGER,
	pIdTimeOld INTEGER,
	pIdTimeNew INTEGER
)
Begin
    update `TB_USUARIO_TIME` 
	set ID_TIME = pIdTimeNew, ID_USUARIO = pIdUsu
	where ID_CAMPEONATO = pIdCamp and ID_USUARIO = pIdTimeOld;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddUsuarioTimev1` $$
CREATE PROCEDURE `spAddUsuarioTimev1`(
	pIdCamp INTEGER,
	pIdUsu INTEGER,
	pIdTime INTEGER
)
begin

	DECLARE _OrdemSorteio INTEGER;
 
	select INDICADOR_ORDEM_SORTEIO into _OrdemSorteio from TB_USUARIO_TIME
	where ID_CAMPEONATO = pIdCamp
	order by INDICADOR_ORDEM_SORTEIO desc
	limit 1;

	insert into TB_USUARIO_TIME (ID_CAMPEONATO, ID_USUARIO, ID_TIME, DT_SORTEIO, INDICADOR_ORDEM_SORTEIO)
	values (pIdCamp, pIdUsu, pIdTime, now(), _OrdemSorteio);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddUsuarioTimev2` $$
CREATE PROCEDURE `spAddUsuarioTimev2`(
	pIdCamp INTEGER,
	pIdUsu INTEGER,
	pIdTime INTEGER,
	pOrdem INTEGER
)
begin
	insert into TB_USUARIO_TIME (ID_CAMPEONATO, ID_USUARIO, ID_TIME, DT_SORTEIO, INDICADOR_ORDEM_SORTEIO)
	values (pIdCamp, pIdUsu, pIdTime, now(), pOrdem);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spValidadeUsuarioTimeSorteioDone` $$
CREATE PROCEDURE `spValidadeUsuarioTimeSorteioDone`(
	pIdCamp INTEGER
)
begin

	DECLARE _SorteioDone INTEGER DEFAULT 0;
 
	select count(1) into _SorteioDone from TB_USUARIO_TIME
	where ID_CAMPEONATO = pIdCamp;
	
	SELECT _SorteioDone as 'inSorteioRealizado';
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteUsuarioTime` $$
CREATE PROCEDURE `spDeleteUsuarioTime`(
	pIdCamp INTEGER,
	pIdUsu INTEGER,
	pIdTime INTEGER
)
begin
	delete from TB_USUARIO_TIME
	where ID_CAMPEONATO = pIdCamp
	and ID_USUARIO = pIdUsuNew
	and ID_TIME = pIdTime;      
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddUsuarioTimeSorteioDone` $$
CREATE PROCEDURE `spAddUsuarioTimeSorteioDone`(
	pIdTemp INTEGER,
	pIdCamp INTEGER,
	pSgTiposLiga VARCHAR(80)
)
begin

	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _IdTime INTEGER;
	DECLARE _IdUsu INTEGER;
	
	DECLARE tabela_cursor CURSOR FOR 
	select ID_USUARIO from TB_CAMPEONATO_USUARIO where ID_CAMPEONATO = pIdCamp;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _IdUsu;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		select ID_TIME into _IdTime 
		from TB_USUARIO_TIME
		where ID_CAMPEONATO IN (select ID_CAMPEONATO from TB_CAMPEONATO where ID_TEMPORADA = pIdTemp and ID_CAMPEONATO <> pIdCamp and IN_CAMPEONATO_ATIVO = true )
		and ID_USUARIO = _IdUsu
		and DT_VIGENCIA_FIM is null
		and SG_TIPO_CAMPEONATO in (pSgTiposLiga)
		limit 1;
		
		insert into TB_USUARIO_TIME (ID_CAMPEONATO, ID_USUARIO, ID_TIME, DT_SORTEIO)
		values (pIdCamp, _IdUsu, _IdTime, now());
	
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	call `arenafifadb`.`spUpdateUsuarioTimeWithOrdemSorteio`(pIdCamp);
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateUsuarioTimeWithOrdemSorteio` $$
CREATE PROCEDURE `spUpdateUsuarioTimeWithOrdemSorteio`(pIdCamp INTEGER)
begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _IdTime INTEGER;
	DECLARE _IdUsu INTEGER;
	DECLARE _count INTEGER DEFAULT 1;
	
	DECLARE tabela_cursor CURSOR FOR 
	select U.ID_USUARIO, U.ID_TIME from TB_USUARIO_TIME U, TB_TIME T 
	where U.ID_CAMPEONATO = pIdCamp
	and U.ID_Time = T.ID_Time
	order by T.NM_TIME;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _IdUsu, _IdTime;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		update TB_USUARIO_TIME
		set INDICADOR_ORDEM_SORTEIO = _count
		where ID_CAMPEONATO = pIdCamp
		and ID_USUARIO = _IdUsu
		and ID_TIME = _IdTime;

		SET _count = _count+1;
	
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddLoadUsuarioTimeSorteioDone` $$
CREATE PROCEDURE `spAddLoadUsuarioTimeSorteioDone`(
	pIdCamp INTEGER,
	pIdsUsu VARCHAR(250),
	pIdsTime VARCHAR(250)
)
begin
	DECLARE _nextUsu VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlenUsu INTEGER DEFAULT NULL;
	DECLARE _idUsu VARCHAR(5) DEFAULT NULL;
	DECLARE _nextTime VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlenTime INTEGER DEFAULT NULL;
	DECLARE _idTime VARCHAR(5) DEFAULT NULL;
	DECLARE strDelimiter CHAR(1) DEFAULT ',';
	DECLARE _count INTEGER DEFAULT 1;
	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsUsu)) = 0 OR pIdsUsu IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _nextUsu = SUBSTRING_INDEX(pIdsUsu,strDelimiter,1);
		SET _nextTime = SUBSTRING_INDEX(pIdsTime,strDelimiter,1);
		
		SET _nextlenUsu = LENGTH(_nextUsu);
		SET _nextlenTime = LENGTH(_nextTime);
		
		SET _idUsu = TRIM(_nextUsu);
		SET _idTime = TRIM(_nextTime);
		
		insert into TB_USUARIO_TIME (ID_CAMPEONATO, ID_USUARIO, ID_TIME, DT_SORTEIO, INDICADOR_ORDEM_SORTEIO)
		values (pIdCamp, CAST(_idUsu AS SIGNED), CAST(_idTime AS SIGNED), now(), _count);
		
		SET pIdsUsu = INSERT(pIdsUsu,1,_nextlenUsu + 1,'');
		SET pIdsTime = INSERT(pIdsTime,1,_nextTime + 1,'');
		SET _count = _count+1;
	END LOOP;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddUsuarioTimeOfCampeonato` $$
CREATE PROCEDURE `spAddUsuarioTimeOfCampeonato`(pIdCamp INTEGER)
begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _IdTime INTEGER;
	DECLARE _IdUsu INTEGER;
	DECLARE _count INTEGER DEFAULT 1;
	
	DECLARE tabela_cursor CURSOR FOR 
	select T.ID_TECNICO_FUT, C.ID_Time from TB_CAMPEONATO_TIME C, TB_TIME T
	where C.ID_CAMPEONATO = pIdCamp
	and C.ID_TIME = T.ID_TIME;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _IdUsu, _IdTime;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		call `arenafifadb`.`spAddUsuarioTimev2`(pIdCamp, _IdUsu, _IdTime, _count);
		
		SET _count = _count+1;
	
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;