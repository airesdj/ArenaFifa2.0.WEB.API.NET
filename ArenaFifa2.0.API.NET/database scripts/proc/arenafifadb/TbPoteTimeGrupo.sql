USE `arenafifadb`;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddAllPoteTimeGrupoH2H` $$
CREATE PROCEDURE `spAddAllPoteTimeGrupoH2H`(
	pIdCamp INTEGER,
	pNmTimesPote VARCHAR(500)
)
Begin
	DECLARE _inOrdemPote INTEGER DEFAULT 0;
	DECLARE _next VARCHAR(500) DEFAULT NULL;
	DECLARE _nextlen INTEGER DEFAULT NULL;
	DECLARE _nmTimes VARCHAR(250) DEFAULT "";
	DECLARE strDelimiter CHAR(1) DEFAULT "|";

	DELETE FROM TB_POTE_TIME_GRUPO WHERE ID_CAMPEONATO = pIdCamp;

	iterator:
	LOOP
		IF LENGTH(TRIM(pNmTimesPote)) = 0 OR pNmTimesPote IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _next = SUBSTRING_INDEX(pNmTimesPote,strDelimiter,1);
		
		SET _nextlen = LENGTH(_next);
		
		SET _nmTimes = TRIM(_next);
		
		SET _inOrdemPote = _inOrdemPote + 1;
		
		call `arenafifadb`.`spAddLoadPoteTimeGrupoH2H`(pIdCamp, _nmTimes, _inOrdemPote);

		SET pNmTimesPote = INSERT(pNmTimesPote,1,_nextlen + 1,'');
	END LOOP;

End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddLoadPoteTimeGrupoH2H` $$
CREATE PROCEDURE `spAddLoadPoteTimeGrupoH2H`(
	pIdCamp INTEGER,
	pNmTimesPote VARCHAR(250),
	pInOrdem INTEGER
)
Begin
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR 
		SELECT ID_TIME FROM TB_TIME WHERE NM_TIME in (pNmTimesPote) 
		AND DS_TIPO NOT IN ("'FUT', 'PRO'") 
		ORDER BY NM_TIME;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idTime;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;

		INSERT INTO TB_POTE_TIME_GRUPO  (ID_CAMPEONATO, ID_TIME, IN_ORDEM_GRUPO)
		VALUES (pIdCamp, _idTime, pInOrdem);
	
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
End$$
DELIMITER ;



