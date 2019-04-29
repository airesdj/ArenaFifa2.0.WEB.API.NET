USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddCampeonatoUsuario` $$
CREATE PROCEDURE `spAddCampeonatoUsuario`(    
    pIdCamp INTEGER,     
    pIdUsu INTEGER
)
Begin
	insert into `TB_CAMPEONATO_USUARIO` (`ID_CAMPEONATO`, `ID_USUARIO`, `DT_ENTRADA`) 
	values (pIdCamp, pIdUsu, now());
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteCampeonatoUsuario` $$
CREATE PROCEDURE `spDeleteCampeonatoUsuario`(    
    pIdCamp INTEGER,     
    pIdUsu INTEGER
)
Begin
	DELETE FROM TB_CAMPEONATO_USUARIO 
	WHERE ID_CAMPEONATO = pIdCamp AND ID_USUARIO = pIdUsu;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateCampeonatoUsuarioNewUsuario` $$
CREATE PROCEDURE `spUpdateCampeonatoUsuarioNewUsuario`(    
    pIdCamp INTEGER,     
    pIdUsuOld INTEGER,
    pIdUsuNew INTEGER,
	pPsnUsuOperacao VARCHAR(30),
	pIdUsuarioOperacao INTEGER,
	pDsPaginaOperacao VARCHAR(30)
)
Begin
	DECLARE _nmCamp VARCAR(50) DEFAULT NULL;

	select NM_CAMPEONATO into _nmCamp 
	from TB_CAMPEONATO
	where ID_CAMPEONATO = pIdCamp;

    update `TB_CAMPEONATO_USUARIO` 
	set ID_USUARIO = pIdUsuNew, DT_ENTRADA = now()
	where ID_CAMPEONATO = pIdCamp and ID_USUARIO = pIdUsuOld;

    call `arenafifadb`.`spAddHistAltCampeonato`(pIdCamp, pIdUsuarioOperacao, 'TROCANDO TECNICO DO CAMPEONATO', pPsnUsuOperacao, _nmCamp, pDsPaginaOperacao);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spTransferCampeonatoUsuarioNewCampeonato` $$
CREATE PROCEDURE `spTransferCampeonatoUsuarioNewCampeonato`(    
    pIdCampOld INTEGER,     
    pIdCampNew INTEGER
)
Begin
	insert into `TB_CAMPEONATO_USUARIO` (`ID_CAMPEONATO`, `ID_USUARIO`, `DT_ENTRADA`)
	select pIdCampNew, `ID_USUARIO`, `DT_ENTRADA`
    from `TB_CAMPEONATO_USUARIO` 
	where ID_CAMPEONATO = pIdCampOld;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllUsuariosOfCampeonato` $$
CREATE PROCEDURE `spGetAllUsuariosOfCampeonato`(pIdCamp INTEGER)
begin      
   select ID_USUARIO, NM_USUARIO from TB_USUARIO where ID_USUARIO in (select ID_USUARIO from TB_CAMPEONATO_USUARIO where ID_CAMPEONATO = pIdCamp) order by NM_USUARIO;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddLoadCampeonatoUsuarioOfCampeonato` $$
CREATE PROCEDURE `spAddLoadCampeonatoUsuarioOfCampeonato`(    
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
		
		insert into `TB_CAMPEONATO_USUARIO` (`ID_CAMPEONATO`, `ID_USUARIO`) 
		values (pIdCamp, CAST(_idUsu AS SIGNED));
		
		SET pIdsUsu = INSERT(pIdsUsu,1,_nextlen + 1,'');
	END LOOP;
End$$
DELIMITER ;
