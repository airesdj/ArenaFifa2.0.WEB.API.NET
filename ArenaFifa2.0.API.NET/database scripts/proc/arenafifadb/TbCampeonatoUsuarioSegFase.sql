USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddCampeonatoUsuarioSegFase` $$
CREATE PROCEDURE `spAddCampeonatoUsuarioSegFase`(    
    pIdCamp INTEGER,     
    pIdUsu INTEGER,
	pOrdem INTEGER
)
Begin
	insert into `TB_CAMPEONATO_USUARIO_SEG_FASE` (`ID_CAMPEONATO`, `ID_USUARIO`, `IN_ORDENACAO_SORTEIO`) 
	values (pIdCamp, pIdUsu, pOrdem);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateCampeonatoUsuarioSegFaseOrdemSorteio` $$
CREATE PROCEDURE `spUpdateCampeonatoUsuarioSegFaseOrdemSorteio`(    
    pIdCamp INTEGER,     
    pIdsTime VARCHAR(250)
)
Begin
	DECLARE _next VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlen INTEGER DEFAULT NULL;
	DECLARE _idTime VARCHAR(5) DEFAULT NULL;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE strDelimiter CHAR(1) DEFAULT ',';
	DECLARE _count INTEGER DEFAULT 1;
	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsTime)) = 0 OR pIdsTime IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _next = SUBSTRING_INDEX(pIdsTime,',',1);
		
		SET _nextlen = LENGTH(_next);
		
		SET _idTime = TRIM(_next);
		
		select C.ID_USUARIO into _idUsu
		from TB_CAMPEONATO_USUARIO_SEG_FASE C, TB_USUARIO_TIME U, TB_TIME T
		where ID_CAMPEONATO = pIdCamp
		and T.ID_TIME = CAST(_idTime AS SIGNED)
		and U.DT_VIGENCIA_FIM IS NULL
		and C.ID_CAMPEONATO = U.ID_CAMPEONATO
		and C.ID_USUARIO = U.ID_USUARIO
		and U.ID_TIME = T.ID_TIME;
		
		IF (IFNULL(_idUsu,1) > 1) THEN

			update TB_CAMPEONATO_USUARIO_SEG_FASE
			set IN_ORDENACAO_SORTEIO = _count
			where ID_CAMPEONATO = pIdCamp
			and ID_USUARIO = _idUsu;

		END IF;
		
		SET pIdsTime = INSERT(pIdsTime,1,_nextlen + 1,'');
		SET _idUsu = NULL;
		SET _count = _count+1;
	END LOOP;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spTransferCampeonatoUsuarioSegFaseNewCampeonato` $$
CREATE PROCEDURE `spTransferCampeonatoUsuarioSegFaseNewCampeonato`(    
    pIdCampOld INTEGER,     
    pIdCampNew INTEGER
)
Begin
	insert into `TB_CAMPEONATO_USUARIO_SEG_FASE` (`ID_CAMPEONATO`, `ID_USUARIO`)
	select pIdCampNew, `ID_USUARIO`
    from `TB_CAMPEONATO_USUARIO_SEG_FASE` 
	where ID_CAMPEONATO = pIdCampOld;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllUsuariosSegFaseOfCampeonato` $$
CREATE PROCEDURE `spGetAllUsuariosSegFaseOfCampeonato`(pIdCamp INTEGER)
begin      
   select ID_USUARIO, NM_USUARIO from TB_USUARIO where ID_USUARIO in (select ID_USUARIO from TB_CAMPEONATO_USUARIO_SEG_FASE where ID_CAMPEONATO = pIdCamp) order by NM_USUARIO;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTimeOfUsuariosSegFaseOfCampeonato` $$
CREATE PROCEDURE `spGetAllTimeOfUsuariosSegFaseOfCampeonato`(pIdCamp INTEGER)
begin      
   select C.*, T.ID_TIME, T.NM_TIME, T.DS_TIPO, S.NM_USUARIO
   from TB_CAMPEONATO_USUARIO_SEG_FASE C, TB_USUARIO_TIME U, TB_TIME T, TB_USUARIO S
   where ID_CAMPEONATO = pIdCamp
   and U.DT_VIGENCIA_FIM is null
   and C.ID_CAMPEONATO = U.ID_CAMPEONATO 
   and C.ID_USUARIO = U.ID_USUARIO
   and U.ID_TIME = T.ID_TIME
   and S.ID_USUARIO = C.ID_USUARIO
   and S.ID_USUARIO = U.ID_USUARIO
   order by S.NM_USUARIO;    
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllCampeonatoUsuarioSegFaseOfCampeonato` $$
CREATE PROCEDURE `spDeleteAllCampeonatoUsuarioSegFaseOfCampeonato`(pIdCamp INTEGER)
Begin
    delete from `TB_CAMPEONATO_USUARIO_SEG_FASE` 
	where ID_CAMPEONATO = pIdCamp;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllCampeonatoUsuarioSegFaseOfCampeonato` $$
CREATE PROCEDURE `spGetAllCampeonatoUsuarioSegFaseOfCampeonato`(pIdCamp INTEGER)
begin      
   select * from TB_CAMPEONATO_USUARIO_SEG_FASE
   where ID_CAMPEONATO = pIdCamp;      
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddLoadCampeonatoUsuarioSegFaseOfCampeonato` $$
CREATE PROCEDURE `spAddLoadCampeonatoUsuarioSegFaseOfCampeonato`(    
    pIdCamp INTEGER,     
    pIdsUsu VARCHAR(250)
)
Begin
	DECLARE _next VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlen INTEGER DEFAULT NULL;
	DECLARE _idUsu VARCHAR(5) DEFAULT NULL;
	DECLARE strDelimiter CHAR(1) DEFAULT ',';
	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsUsu)) = 0 OR pIdsUsu IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _next = SUBSTRING_INDEX(pIdsUsu,',',1);
		
		SET _nextlen = LENGTH(_next);
		
		SET _idUsu = TRIM(_next);
		
		insert into `TB_CAMPEONATO_USUARIO_SEG_FASE` (`ID_CAMPEONATO`, `ID_USUARIO`) 
		values (pIdCamp, CAST(_idUsu AS SIGNED));
		
		SET pIdsUsu = INSERT(pIdsUsu,1,_nextlen + 1,'');
	END LOOP;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllUsuariosSegFaseOfCampeonato` $$
CREATE PROCEDURE `spGetAllUsuariosSegFaseOfCampeonato`(pIdCamp INTEGER)
begin      
   select C.*, T.ID_Time, T.NM_Time, T.DS_Tipo 
   from TB_CAMPEONATO_USUARIO_SEG_FASE C, TB_USUARIO_TIME U, TB_TIME T 
   where C.ID_CAMPEONATO = pIdCamp
   and U.DT_VIGENCIA_FIM is null
   and C.ID_CAMPEONATO = U.ID_CAMPEONATO
   and C.ID_USUARIO = U.ID_USUARIO
   and U.ID_TIME = T.ID_TIME;
End$$
DELIMITER ;

