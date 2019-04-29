USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmElencoProOfUsuario` $$
CREATE PROCEDURE `spGetAllConfirmElencoProOfUsuario`(
	pIdTemporada INTEGER,
	pIdManager INTEGER
)
begin      
   select C.*, DATE_FORMAT(C.DT_CONFIRMACAO,'%d/%m/%Y') as DT_CONFIRM_FORMATADA, U.NM_USUARIO, U.PSN_ID
   from TB_CONFIRM_ELENCO_PRO C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and C.ID_USUARIO_MANAGER = pIdManager
   and C.ID_USUARIO = U.ID_USUARIO
   order by C.DT_CONFIRMACAO, C.ID_USUARIO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteConfirmElencoPro` $$
CREATE PROCEDURE `spDeleteConfirmElencoPro`(
	pIdTemporada INTEGER,
	pIdManager INTEGER,
	pIdJogador INTEGER
)
begin      
   delete from TB_CONFIRM_ELENCO_PRO
   where ID_TEMPORADA = pIdTemporada
   and ID_USUARIO_MANAGER = pIdManager
   and ID_USUARIO = pIdJogador;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteConfirmElencoProOfManager` $$
CREATE PROCEDURE `spDeleteConfirmElencoProOfManager`(
	pIdManager INTEGER
)
begin      
   delete from TB_CONFIRM_ELENCO_PRO
   where ID_USUARIO_MANAGER = pIdManager;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteConfirmElencoProOfManagerTemporada` $$
CREATE PROCEDURE `spDeleteConfirmElencoProOfManager`(
	pIdTemporada INTEGER,
	pIdManager INTEGER
)
begin      
   delete from TB_CONFIRM_ELENCO_PRO
   where ID_TEMPORADA = pIdTemporada,
   and ID_USUARIO_MANAGER = pIdManager;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddConfirmElencoPro` $$
CREATE PROCEDURE `spAddConfirmElencoPro`(
	pIdTemporada INTEGER,
	pIdManager INTEGER,
	pPsnJogador VARCHAR(30)
	
)
begin
	DECLARE _total INTEGER DEFAULT 0;
	DECLARE _idJogador INTEGER DEFAULT NULL;
	
	select ID_USUARIO into _idJogador
	from TB_USUARIO
	where PSN_ID = pPsnJogador;
	
	IF (_idJogador IS NULL) THEN
	
		select '1' as COD_VALIDATION, 'Incorrect validation - PSN not found.' as DSC_VALIDATION;
	
	ELSE
	
		select count(1) into _total
		from TB_CONFIRM_ELENCO_PRO
		where ID_TEMPORADA = pIdTemporada
		and ID_USUARIO_MANAGER = pIdManager
		and ID_USUARIO = _idJogador;
		
		IF _total > 0 THEN
		
			select '2' as COD_VALIDATION, 'Incorrect validation - Player was found on your squad.' as DSC_VALIDATION;
	
		ELSE
		
			SET _total = 0;
		
			select count(1) into _total
			from TB_GOLEADOR
			where ID_TEMPORADA = pIdTemporada
			and ID_USUARIO_MANAGER <> pIdManager
			and ID_USUARIO = _idJogador;
			
			IF _total > 0 THEN

				select '3' as COD_VALIDATION, 'Incorrect validation - Player was found on another squad.' as DSC_VALIDATION;
	
			ELSE
			
				SET _total = 0;
		
				select count(1) into _total
				from TB_GOLEADOR
				where ID_USUARIO = _idJogador;
				
				IF _total > 0 THEN
				
					select '4' as COD_VALIDATION, 'Incorrect validation - Player was found and he is playing for another team in this season.' as DSC_VALIDATION;
	
				ELSE
				
					insert into TB_CONFIRM_ELENCO_PRO (ID_TEMPORADA, ID_USUARIO_MANAGER, ID_USUARIO, DT_CONFIRMACAO)
					values (pIdTemporada, pIdManager, _idJogador, NOW());
					
					select '0' as COD_VALIDATION, 'Validation done successfully.' as DSC_VALIDATION;
				
				END IF;
			
			END IF;

		END IF;

	END IF;
End$$
DELIMITER ;


