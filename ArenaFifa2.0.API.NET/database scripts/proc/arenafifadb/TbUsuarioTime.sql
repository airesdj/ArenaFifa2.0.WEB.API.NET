USE `arenafifadb`;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllUsuarioTimeOfCampeonato` $$
CREATE PROCEDURE `spGetAllUsuarioTimeOfCampeonato`(
	pIdCamp INTEGER
)
begin
   select UT.ID_USUARIO, UT.ID_TIME, U.NM_USUARIO, U.PSN_ID, T.NM_TIME, T.DS_TIPO 
   from TB_USUARIO_TIME UT, TB_USUARIO U,  TB_TIME T 
   where UT.ID_CAMPEONATO = pIdCamp
   and UT.DT_VIGENCIA_FIM IS NULL
   and UT.ID_USUARIO = U.ID_USUARIO
   and UT.ID_TIME = T.ID_TIME
   order by UT.INDICADOR_ORDEM_SORTEIO, U.NM_USUARIO;
End$$
DELIMITER ;



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
   
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateUsuarioTimeNewUsuario` $$
CREATE PROCEDURE `spUpdateUsuarioTimeNewUsuario`(    
	pIdCamp INTEGER,
	pIdUsuOld INTEGER,
	pIdUsuNew INTEGER,
	pIdTimeNew INTEGER
)
Begin
    update `TB_USUARIO_TIME` 
	set ID_TIME = pIdTimeNew, ID_USUARIO = pIdUsuNew
	where ID_CAMPEONATO = pIdCamp and ID_USUARIO = pIdUsuOld;
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



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDoUserExchange` $$
CREATE PROCEDURE `spDoUserExchange`(
	pTpCamp VARCHAR(5),
	pIdUsuIN INTEGER,
	pNmUsuIN VARCHAR(50),
	pPsnIDIN VARCHAR(30),
	pIdUsuOUT INTEGER,
	pIdTipoAcesso INTEGER,
	pPsnUsuOperacao VARCHAR(30),
	pIdUsuarioOperacao INTEGER,
	pDsPaginaOperacao VARCHAR(30)
)
begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _IdTimeIN INTEGER;
	DECLARE _IdTimeOUT INTEGER;
	DECLARE _idTemp INTEGER DEFAULT NULL;
	DECLARE _nmTime VARCHAR(80);
	DECLARE _dsTipo VARCHAR(5);
	DECLARE _IdCamp INTEGER;
	DECLARE _NmCamp VARCHAR(50);
	DECLARE _SgCamp VARCHAR(5);
	DECLARE _SgCampAux VARCHAR(50);
	DECLARE _idPreviousTemp INTEGER DEFAULT NULL;
	DECLARE _CommentarioJogo LONGTEXT DEFAULT "";
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	SET _idTemp = fcGetIdTempCurrent();

	IF pTpCamp = 'DIV1' OR pTpCamp = 'DIV2' OR pTpCamp = 'DIV3' OR pTpCamp = 'DIV4' THEN
	
		SET _idPreviousTemp = fcGetIdTempPrevious();

		IF pTpCamp = 'DIV1' OR pTpCamp = 'DIV2' THEN
			SET _SgCampAux = "'CPGL'";
		ELSE
			SET _SgCampAux = "'CPSA'";
		END IF;
	
		begin
			DECLARE tabela_cursor CURSOR FOR
			SELECT ID_CAMPEONATO, NM_CAMPEONATO, SG_TIPO_CAMPEONATO FROM TB_CAMPEONATO WHERE ID_TEMPORADA = _idTemp
			AND SG_TIPO_CAMPEONATO IN (pTpCamp) AND IN_CAMPEONATO_GRUPO = False
			UNION ALL
			SELECT ID_CAMPEONATO, NM_CAMPEONATO, SG_TIPO_CAMPEONATO FROM TB_CAMPEONATO WHERE ID_TEMPORADA = _idTemp
			AND SG_TIPO_CAMPEONATO IN (_SgCampAux) AND IN_CAMPEONATO_GRUPO = True
			UNION ALL
			SELECT ID_CAMPEONATO, NM_CAMPEONATO, SG_TIPO_CAMPEONATO FROM TB_CAMPEONATO WHERE ID_TEMPORADA = _idTemp
			AND SG_TIPO_CAMPEONATO IN ('CPGL') AND IN_CAMPEONATO_GRUPO = False
			ORDER BY ID_CAMPEONATO;

	
			OPEN tabela_cursor;
				
				get_tabela: LOOP
				
					FETCH tabela_cursor INTO _IdCamp, _NmCamp, _SgCamp;
					
					IF _finished = 1 THEN
						LEAVE get_tabela;
					END IF;
					
				SET _IdTimeOUT =	fcGetIdTimeByUsuario(_IdCamp, pIdUsuOUT);
				
				SELECT NM_Time, DS_TIPO into _nmTime, _dsTipo
				FROM TB_TIME WHERE ID_TIME = _IdTimeOUT;
				
				SET _nmTime = CONCAT(_nmTime, " (", _dsTipo, ")");
				
				SET _CommentarioJogo = CONCAT("Seguem os dados do novo técnico do ", _nmTime, ":");
				SET _CommentarioJogo = CONCAT(_CommentarioJogo, "<br><br>");
				SET _CommentarioJogo = CONCAT(_CommentarioJogo, "<b>", pNmUsuIN, " (", pPsnIDIN, ")</b>");
				
				call `arenafifadb`.`spTransferUsuarioTimeToNewUsuario`(_IdCamp, _IdTimeOUT, pIdUsuOUT, pIdUsuIN);
				
				call `arenafifadb`.`spUpdateCampeonatoUsuarioNewUsuario`(_IdCamp, pIdUsuOUT, pIdUsuIN, pPsnUsuOperacao, pIdUsuarioOperacao, pDsPaginaOperacao);
					
				call `arenafifadb`.`spUpdateComentarioUsuarioNewUsuario`(_IdCamp, pIdUsuOUT, pIdUsuIN);
					
				call `arenafifadb`.`spAddHistoricoTemporadaH2H`(_idPreviousTemp, pIdUsuIN, pIdTipoAcesso);

				call `arenafifadb`.`spUpdateOrdenaHistoricoTempH2H`(_idPreviousTemp);
				
				IF pTpCamp = 'DIV3' OR pTpCamp = 'DIV4' THEN
				
					call `arenafifadb`.`spUpdateToEndBancoReserva`(pIdUsuIN, 'H2H');
				
				END IF;
				
				call `arenafifadb`.`spAddAllComentarioJogoByTime`(_IdCamp, _IdTimeOUT, pIdUsuarioOperacao, _CommentarioJogo);

				END LOOP get_tabela;
				
			CLOSE tabela_cursor;
            
            SELECT _nmTime as NM_TIME;

		End;
		
	ELSEIF pTpCamp = 'FUT1' OR pTpCamp = 'FUT2' THEN

		begin
			DECLARE tabela_cursor CURSOR FOR
			SELECT ID_CAMPEONATO, NM_CAMPEONATO, SG_TIPO_CAMPEONATO FROM TB_CAMPEONATO WHERE ID_TEMPORADA = _idTemp
			AND SG_TIPO_CAMPEONATO IN ('FUT1', 'FUT2', 'CFUT')
			ORDER BY ID_CAMPEONATO;

	
			OPEN tabela_cursor;
				
				get_tabela: LOOP
				
					FETCH tabela_cursor INTO _IdCamp, _NmCamp, _SgCamp;
					
					IF _finished = 1 THEN
						LEAVE get_tabela;
					END IF;
					
				SET _IdTimeOUT =	fcGetIdTimeByUsuario(_IdCamp, pIdUsuOUT);
				
				IF pTpCamp = 'FUT1' OR pTpCamp = 'FUT2' THEN
				
					SELECT B.NM_TIME_FUT into _nmTime
					FROM TB_LISTA_BANCO_RESERVA B
					WHERE B.ID_USUARIO = pIdUsuIN AND B.TP_BANCO_RESERVA = 'FUT'
					AND B.IN_CONSOLE = 'PS4' AND B.DT_FIM IS NULL;
				
					SELECT T.ID_TIME into _IdTimeIN
					FROM TB_TIME T WHERE UCASE(T.NM_TIME) IN (UCASE(_nmTime))
					AND T.DS_TIPO = 'FUT' ORDER BY T.ID_TIME DESC LIMIT 1;
					
					IF _IdTimeIN IS NULL THEN
					
						call `arenafifadb`.`spAddTime`(_nmTime, '...', 37, 0, pIdUsuIN);
					
						SELECT T.ID_TIME into _IdTimeIN
						FROM TB_TIME T WHERE ID_TECNICO_FUT = pIdUsuIN
						AND T.DS_TIPO = 'FUT' ORDER BY T.ID_TIME DESC LIMIT 1;
						
					END IF;
					
				END IF;
				
				SET _CommentarioJogo = CONCAT("Seguem os dados do técnico substituto:");
				SET _CommentarioJogo = CONCAT(_CommentarioJogo, "<br><br>");
				SET _CommentarioJogo = CONCAT("<b>Nome do Time: ", _nmTime);
				SET _CommentarioJogo = CONCAT(_CommentarioJogo, "<br><br>");
				SET _CommentarioJogo = CONCAT(_CommentarioJogo, "Novo Técnico: ", pNmUsuIN, " (", pPsnIDIN, ")</b>");
				
				call `arenafifadb`.`spUpdateCampeonatoTimeNewTime`(_IdCamp, _IdTimeOUT, _IdTimeIN);
				
				call `arenafifadb`.`spUpdateClassificacaoNewTime`(_IdCamp, _IdTimeOUT, _IdTimeIN);
				
				call `arenafifadb`.`spUpdateCampeonatoUsuarioNewUsuario`(_IdCamp, pIdUsuOUT, pIdUsuIN, pPsnUsuOperacao, pIdUsuarioOperacao, pDsPaginaOperacao);
					
				call `arenafifadb`.`spUpdateComentarioUsuarioNewUsuario`(_IdCamp, pIdUsuOUT, pIdUsuIN);
					
				call `arenafifadb`.`spUpdateUsuarioTimeNewUsuario`(_IdCamp, pIdUsuOUT, pIdUsuIN, _IdTimeIN);
				
				call `arenafifadb`.`spUpdateTimesFasePreCopaNewTime`(_IdCamp, _IdTimeOUT, _IdTimeIN);

				call `arenafifadb`.`spUpdateTabelaJogoNewTime`(_IdCamp, _IdTimeOUT, _IdTimeIN);

				IF pTpCamp = 'FUT1' OR pTpCamp = 'FUT2' THEN
				
					call `arenafifadb`.`spUpdateToEndBancoReserva`(pIdUsuIN, 'FUT');
				
				END IF;
				
				call `arenafifadb`.`spAddAllComentarioJogoByTime`(_IdCamp, _IdTimeIN, pIdUsuarioOperacao, _CommentarioJogo);

				END LOOP get_tabela;
				
			CLOSE tabela_cursor;
            
            SELECT _nmTime as NM_TIME;

		End;

	ELSEIF pTpCamp = 'PRO1' OR pTpCamp = 'PRO2' THEN
	
		begin
			DECLARE tabela_cursor CURSOR FOR
			SELECT ID_CAMPEONATO, NM_CAMPEONATO, SG_TIPO_CAMPEONATO FROM TB_CAMPEONATO WHERE ID_TEMPORADA = _idTemp
			AND SG_TIPO_CAMPEONATO IN ('PRO1', 'PRO2', 'CPRO')
			ORDER BY ID_CAMPEONATO;

	
			OPEN tabela_cursor;
			
				get_tabela: LOOP
				
					FETCH tabela_cursor INTO _IdCamp, _NmCamp, _SgCamp;
					
					IF _finished = 1 THEN
						LEAVE get_tabela;
					END IF;
					
				SET _IdTimeOUT =	fcGetIdTimeByUsuario(_IdCamp, pIdUsuOUT);
				
				IF pTpCamp = 'PRO1' OR pTpCamp = 'PRO2' THEN
				
					SELECT B.NM_TIME_FUT into _nmTime
					FROM TB_LISTA_BANCO_RESERVA B
					WHERE B.ID_USUARIO = pIdUsuIN AND B.TP_BANCO_RESERVA = 'PRO'
					AND B.IN_CONSOLE = 'PS4' AND B.DT_FIM IS NULL;
				
					SELECT T.ID_TIME into _IdTimeIN
					FROM TB_TIME T WHERE UCASE(T.NM_TIME) IN (UCASE(_nmTime))
					AND T.DS_TIPO = 'PRO' ORDER BY T.ID_TIME DESC LIMIT 1;
					
					IF _IdTimeIN IS NULL THEN
					
						call `arenafifadb`.`spAddTime`(_nmTime, '...', 42, 0, pIdUsuIN);
					
						SELECT T.ID_TIME into _IdTimeIN
						FROM TB_TIME T WHERE ID_TECNICO_FUT = pIdUsuIN
						AND T.DS_TIPO = 'PRO' ORDER BY T.ID_TIME DESC LIMIT 1;
						
					END IF;
					
				END IF;
				
				SET _CommentarioJogo = CONCAT("Seguem os dados do clube substituto:");
				SET _CommentarioJogo = CONCAT(_CommentarioJogo, "<br><br>");
				SET _CommentarioJogo = CONCAT("<b>Nome do Clube: ", _nmTime);
				SET _CommentarioJogo = CONCAT(_CommentarioJogo, "<br><br>");
				SET _CommentarioJogo = CONCAT(_CommentarioJogo, "Manager: ", pNmUsuIN, " (", pPsnIDIN, ")</b>");
				
				call `arenafifadb`.`spUpdateCampeonatoTimeNewTime`(_IdCamp, _IdTimeOUT, _IdTimeIN);
				
				call `arenafifadb`.`spUpdateClassificacaoNewTime`(_IdCamp, _IdTimeOUT, _IdTimeIN);
				
				call `arenafifadb`.`spUpdateCampeonatoUsuarioNewUsuario`(_IdCamp, pIdUsuOUT, pIdUsuIN, pPsnUsuOperacao, pIdUsuarioOperacao, pDsPaginaOperacao);
					
				call `arenafifadb`.`spUpdateComentarioUsuarioNewUsuario`(_IdCamp, pIdUsuOUT, pIdUsuIN);
					
				call `arenafifadb`.`spUpdateUsuarioTimeNewUsuario`(_IdCamp, pIdUsuOUT, pIdUsuIN, _IdTimeIN);
				
				call `arenafifadb`.`spUpdateTimesFasePreCopaNewTime`(_IdCamp, _IdTimeOUT, _IdTimeIN);

				call `arenafifadb`.`spUpdateTabelaJogoNewTime`(_IdCamp, _IdTimeOUT, _IdTimeIN);

				IF pTpCamp = 'PRO1' OR pTpCamp = 'PRO2' THEN
				
					call `arenafifadb`.`spUpdateToEndBancoReserva`(pIdUsuIN, 'PRO');
				
				END IF;
				
				call `arenafifadb`.`spAddAllComentarioJogoByTime`(_IdCamp, _IdTimeIN, pIdUsuarioOperacao, _CommentarioJogo);

				END LOOP get_tabela;
				
			CLOSE tabela_cursor;
            
            SELECT _nmTime as NM_TIME;

		End;

	END IF;
	
	
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spDoMangerExchange` $$
CREATE PROCEDURE `spDoMangerExchange`(
	pTpCamp VARCHAR(5),
	pIdUsuIN INTEGER,
	pNmUsuIN VARCHAR(50),
	pPsnIDIN VARCHAR(30),
	pIdUsuOUT INTEGER,
	pPsnUsuOperacao VARCHAR(30),
	pIdUsuarioOperacao INTEGER,
	pDsPaginaOperacao VARCHAR(30)
)
begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _IdTimeOUT INTEGER;
	DECLARE _idTemp INTEGER DEFAULT NULL;
	DECLARE _nmTime VARCHAR(80);
	DECLARE _dsTipo VARCHAR(5);
	DECLARE _IdCamp INTEGER;
	DECLARE _NmCamp VARCHAR(50);
	DECLARE _SgCamp VARCHAR(5);
	DECLARE _SgCampAux VARCHAR(50);
	DECLARE _CommentarioJogo LONGTEXT DEFAULT "";
	
	DECLARE tabela_cursor CURSOR FOR
	SELECT ID_CAMPEONATO, NM_CAMPEONATO, SG_TIPO_CAMPEONATO FROM TB_CAMPEONATO WHERE ID_TEMPORADA = _idTemp
	AND SG_TIPO_CAMPEONATO IN ('PRO1', 'PRO2', 'CPRO')
	ORDER BY ID_CAMPEONATO;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	SET _idTemp = fcGetIdTempCurrent();

	OPEN tabela_cursor;
	
		get_tabela: LOOP
		
			FETCH tabela_cursor INTO _IdCamp, _NmCamp, _SgCamp;
			
			IF _finished = 1 THEN
				LEAVE get_tabela;
			END IF;
			
			SET _IdTimeOUT =	fcGetIdTimeByUsuario(_IdCamp, pIdUsuOUT);
			
			SELECT NM_Time, DS_TIPO into _nmTime, _dsTipo
			FROM TB_TIME WHERE ID_TIME = _IdTimeOUT;
			
			#SET _nmTime = CONCAT(_nmTime, " (", _dsTipo, ")");
			
			SET _CommentarioJogo = CONCAT("Seguem os dados do novo técnico do ", _nmTime, ":");
			SET _CommentarioJogo = CONCAT(_CommentarioJogo, "<br><br>");
			SET _CommentarioJogo = CONCAT(_CommentarioJogo, "<b>", pNmUsuIN, " (", pPsnIDIN, ")</b>");
			
			call `arenafifadb`.`spUpdateCampeonatoUsuarioNewUsuario`(_IdCamp, pIdUsuOUT, pIdUsuIN, pPsnUsuOperacao, pIdUsuarioOperacao, pDsPaginaOperacao);
				
			call `arenafifadb`.`spUpdateComentarioUsuarioNewUsuario`(_IdCamp, pIdUsuOUT, pIdUsuIN);
				
			call `arenafifadb`.`spTransferUsuarioTimeToNewUsuario`(_IdCamp, _IdTimeOUT, pIdUsuOUT, pIdUsuIN);
			
			call `arenafifadb`.`spTransferTimeNewTecnico`(pIdUsuIN, _IdTimeOUT);
			
			IF pTpCamp = 'PRO1' OR pTpCamp = 'PRO2' THEN
			
				call `arenafifadb`.`spUpdateToEndBancoReserva`(pIdUsuIN, 'PRO');
			
			END IF;
			
			call `arenafifadb`.`spAddGoleador`(0, _IdTimeOUT, pPsnIDIN, pNmUsuIN, '...', 'PRO CLUB', 0, 'PRO', pIdUsuIN);

			call `arenafifadb`.`spAddAllComentarioJogoByTime`(_IdCamp, _IdTimeOUT, pIdUsuarioOperacao, _CommentarioJogo);
			
		END LOOP get_tabela;
		
	CLOSE tabela_cursor;
	
	SELECT _nmTime as NM_TIME;

End$$
DELIMITER ;