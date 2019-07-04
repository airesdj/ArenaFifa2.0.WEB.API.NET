USE `arenafifadb`;

ALTER TABLE TB_TABELA_JOGO MODIFY DT_TABELA_INICIO_JOGO DATE;
ALTER TABLE TB_TABELA_JOGO MODIFY DT_TABELA_FIM_JOGO DATE;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetCurrentRoundByCampeonato` $$
CREATE FUNCTION `fcGetCurrentRoundByCampeonato`(pIdCamp INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _round INTEGER DEFAULT NULL;
	
	SELECT IN_NUMERO_RODADA into _round
	FROM TB_TABELA_JOGO
	WHERE ID_CAMPEONATO = pIdCamp AND ID_FASE = 0 AND QT_GOLS_TIME_CASA IS NULL
	ORDER BY IN_NUMERO_RODADA LIMIT 1;

	IF _round IS NULL THEN
		SET _round = 0;
	END IF;
	
	RETURN _round;
End$$
DELIMITER ;



DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetCurrentStageRoundByCampeonato` $$
CREATE FUNCTION `fcGetCurrentStageRoundByCampeonato`(pIdCamp INTEGER) RETURNS VARCHAR(20)
	DETERMINISTIC
begin

	DECLARE _stageIDClassificacao INTEGER DEFAULT 0;
	DECLARE _round INTEGER DEFAULT NULL;
	DECLARE _stage INTEGER DEFAULT NULL;
	DECLARE _doubleRound INTEGER DEFAULT NULL;
	
	SELECT ID_FASE into _stage
	FROM TB_TABELA_JOGO
	WHERE ID_CAMPEONATO = pIdCamp AND QT_GOLS_TIME_CASA IS NULL
	ORDER BY ID_FASE, IN_NUMERO_RODADA LIMIT 1;
	
	SELECT IN_DOUBLE_ROUND into _doubleRound FROM TB_CAMPEONATO WHERE ID_CAMPEONATO = pIdCamp;

	IF _stage IS NULL THEN
	
		SELECT ID_FASE into _stage
		FROM TB_TABELA_JOGO
		WHERE ID_CAMPEONATO = pIdCamp AND QT_GOLS_TIME_CASA IS NOT NULL
		ORDER BY ID_FASE DESC, IN_NUMERO_RODADA DESC LIMIT 1;
	
	END IF;
	
	IF _stage = _stageIDClassificacao THEN
	
		SELECT IN_NUMERO_RODADA into _round
		FROM TB_TABELA_JOGO
		WHERE ID_CAMPEONATO = pIdCamp AND ID_FASE = _stage 
		AND ((CURRENT_DATE() BETWEEN DT_TABELA_INICIO_JOGO AND DT_TABELA_FIM_JOGO) OR CURRENT_DATE() > DT_TABELA_FIM_JOGO)
		GROUP BY IN_NUMERO_RODADA ORDER BY IN_NUMERO_RODADA DESC LIMIT 1;

		IF _round IS NOT NULL THEN

			IF _round > 0 THEN
			
				IF (_round % 2) = 0 AND _doubleRound = 1 THEN
				
					SELECT IN_NUMERO_RODADA into _round
					FROM TB_TABELA_JOGO
					WHERE ID_CAMPEONATO = pIdCamp AND ID_FASE = _stage 
					AND IN_NUMERO_RODADA = _round
					AND DT_EFETIVACAO_JOGO is not null LIMIT 1;
					
					IF _round IS NOT NULL THEN
					
						SET _round = _round - 1;
					
					END IF;

				END IF;
				
				IF _round IS NOT NULL THEN
				
					SELECT IN_NUMERO_RODADA into _round
					FROM TB_TABELA_JOGO
					WHERE ID_CAMPEONATO = pIdCamp AND ID_FASE = _stage 
					AND IN_NUMERO_RODADA = _round
					AND DT_EFETIVACAO_JOGO is null LIMIT 1;

					#IF _round IS NOT NULL THEN
					
					#	SET _round = _round + 1;
					
					#END IF;

				END IF;
			
			END IF;

		END IF;
	
		IF _round IS NULL THEN
	
			SELECT IN_NUMERO_RODADA into _round
			FROM TB_TABELA_JOGO
			WHERE ID_CAMPEONATO = pIdCamp AND ID_FASE = _stage AND QT_GOLS_TIME_CASA IS NOT NULL
			ORDER BY IN_NUMERO_RODADA DESC LIMIT 1;
		
		END IF;
		
	ELSE
	
		SELECT IN_NUMERO_RODADA into _round
		FROM TB_TABELA_JOGO
		WHERE ID_CAMPEONATO = pIdCamp AND ID_FASE = _stage AND QT_GOLS_TIME_CASA IS NULL
		ORDER BY IN_NUMERO_RODADA LIMIT 1;

		IF _round IS NULL THEN
			SET _round = 1;
		END IF;

	END IF;
	
	RETURN CONCAT("stage=",_stage, ";round=", _round);
End$$
DELIMITER ;






DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllTabelaJogoOfCampeonato` $$
CREATE PROCEDURE `spDeleteAllTabelaJogoOfCampeonato`(pIdCamp INTEGER)
Begin
    delete from `TB_TABELA_JOGO` 
	where ID_CAMPEONATO = pIdCamp;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateTabelaJogoNewTime` $$
CREATE PROCEDURE `spUpdateTabelaJogoNewTime`(    
    pIdCamp INTEGER,     
    pIdTimeOld INTEGER,
    pIdTimeNew INTEGER
)
Begin
    update `TB_TABELA_JOGO` 
	set ID_TIME_CASA = pIdTimeNew
	where ID_CAMPEONATO = pIdCamp and ID_TIME_CASA = pIdTimeOld;

    update `TB_TABELA_JOGO` 
	set ID_TIME_VISITANTE = pIdTimeNew
	where ID_CAMPEONATO = pIdCamp and ID_TIME_VISITANTE = pIdTimeOld;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTabelaJogo` $$
CREATE PROCEDURE `spAddTabelaJogo`(    
    pIdCamp INTEGER,     
    pIdFase INTEGER,
    pDtInicio DATE,
    pInInterval INTEGER,
    pInNumRodada INTEGER,
    pIdTimeCasa INTEGER,
    pIdTimeVisit INTEGER,
	pNumJogoPlayoff INTEGER,
	pIdaVolta TINYINT,
	pInPlayoffMatch TINYINT
)
Begin
	DECLARE _inNumRodIda INTEGER DEFAULT 1;
	DECLARE _inNumRodVolta INTEGER DEFAULT 2;
	DECLARE _count INTEGER DEFAULT NULL;
	DECLARE _dtFim DATE DEFAULT NULL;
	DECLARE _dtInicioVolta DATE DEFAULT NULL;
	DECLARE _dtFimVolta DATE DEFAULT NULL;
	
	IF pInPlayoffMatch = true THEN
		SET _count = pNumJogoPlayoff;
	ELSE
		SET _inNumRodIda = pInNumRodada;
	END IF;

	SET _dtFim = date_add(pDtInicio, INTERVAL (pInInterval-1) DAY);
	SET _dtInicioVolta = date_add(_dtFim, INTERVAL 1 DAY);
	SET _dtFimVolta = date_add(_dtInicioVolta, INTERVAL (pInInterval-1) DAY);
		
	insert into TB_TABELA_JOGO (ID_CAMPEONATO, ID_FASE, DT_TABELA_INICIO_JOGO, DT_TABELA_FIM_JOGO, ID_TIME_CASA, ID_TIME_VISITANTE, IN_NUMERO_RODADA, DT_SORTEIO, DS_HORA_JOGO, IN_JOGO_MATAXMATA)
	values (pIdCamp, pIdFase, pDtInicio, _dtFim, pIdTimeCasa, pIdTimeVisit, _inNumRodIda, now(), '20:00', _count);
	
	IF (pIdaVolta = true) THEN
	
		insert into TB_TABELA_JOGO (ID_CAMPEONATO, ID_FASE, DT_TABELA_INICIO_JOGO, DT_TABELA_FIM_JOGO, ID_TIME_CASA, ID_TIME_VISITANTE, IN_NUMERO_RODADA, DT_SORTEIO, DS_HORA_JOGO, IN_JOGO_MATAXMATA)
		values (pIdCamp, pIdFase, _dtInicioVolta, _dtFimVolta, pIdTimeVisit, pIdTimeCasa, _inNumRodVolta, now(), '16:00', _count);
		
	END IF;
		
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTabelaJogoPlayoffSorteioDone` $$
CREATE PROCEDURE `spAddTabelaJogoPlayoffSorteioDone`(    
    pIdCamp INTEGER,     
    pIdFase INTEGER,
    pDtInicio DATE,
    pInInterval INTEGER,
    pIdsTimeCasa VARCHAR(250),
    pIdsTimeVisit VARCHAR(250),
	pIdaVolta TINYINT
)
Begin
	DECLARE _nextTimeC VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlenTimeC INTEGER DEFAULT NULL;
	DECLARE _nextTimeV VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlenTimeV INTEGER DEFAULT NULL;
	DECLARE _idTimeCasa VARCHAR(5) DEFAULT NULL;
	DECLARE _idTimeVisit VARCHAR(5) DEFAULT NULL;
	DECLARE _dtFim DATE DEFAULT NULL;
	DECLARE _dtInicioVolta DATE DEFAULT NULL;
	DECLARE _dtFimVolta DATE DEFAULT NULL;
	DECLARE strDelimiter CHAR(1) DEFAULT ',';
	DECLARE _inNumRodIda INTEGER DEFAULT 1;
	DECLARE _inNumRodVolta INTEGER DEFAULT 2;
	DECLARE _count INTEGER DEFAULT 1;

	SET _dtFim = date_add(pDtInicio, INTERVAL pInInterval DAY);
	SET _dtInicioVolta = date_add(_dtFim, INTERVAL 1 DAY);
	SET _dtFimVolta = date_add(_dtInicioVolta, INTERVAL pInInterval DAY);
		
	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsTimeCasa)) = 0 OR pIdsTimeCasa IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _nextTimeC = SUBSTRING_INDEX(pIdsTimeCasa,strDelimiter,1);
		SET _nextTimeV = SUBSTRING_INDEX(pIdsTimeVisit,strDelimiter,1);
		
		SET _nextlenTimeC = LENGTH(_nextTimeC);
		SET _nextlenTimeV = LENGTH(_nextTimeV);
		
		SET _idTimeCasa = TRIM(_nextTimeC);
		SET _idTimeVisit = TRIM(_nextTimeV);
		
		insert into TB_TABELA_JOGO (ID_CAMPEONATO, ID_FASE, DT_TABELA_INICIO_JOGO, DT_TABELA_FIM_JOGO, ID_TIME_CASA, ID_TIME_VISITANTE, IN_NUMERO_RODADA, DT_SORTEIO, DS_HORA_JOGO, IN_JOGO_MATAXMATA)
		values (pIdCamp, pIdFase, pDtInicio, _dtFim, CAST(_idTimeCasa AS SIGNED), CAST(_idTimeVisit AS SIGNED), _inNumRodIda, now(), '16:00', _count);
		
		IF (pIdaVolta = true) THEN
		
			insert into TB_TABELA_JOGO (ID_CAMPEONATO, ID_FASE, DT_TABELA_INICIO_JOGO, DT_TABELA_FIM_JOGO, ID_TIME_CASA, ID_TIME_VISITANTE, IN_NUMERO_RODADA, DT_SORTEIO, DS_HORA_JOGO, IN_JOGO_MATAXMATA)
			values (pIdCamp, pIdFase, _dtInicioVolta, _dtFimVolta, CAST(_idTimeVisit AS SIGNED), CAST(_idTimeCasa AS SIGNED), _inNumRodVolta, now(), '16:00', _count);
			
		END IF;
		
		SET pIdsTimeCasa = INSERT(pIdsTimeCasa,1,_nextlenTimeC + 1,'');
		SET pIdsTimeVisit = INSERT(pIdsTimeVisit,1,_nextlenTimeV + 1,'');
		SET _count = _count+1;
	END LOOP;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTabelaJogoSorteioDone` $$
CREATE PROCEDURE `spAddTabelaJogoSorteioDone`(    
    pIdCamp INTEGER,     
    pIdFase INTEGER,
    pDtInicio DATE,
    pInInterval INTEGER,
    pIdsTimeCasa VARCHAR(250),
    pIdsTimeVisit VARCHAR(250),
	pQtTimesCamp INTEGER,
	pTurnoReturno TINYINT
)
Begin
	DECLARE _nextTimeC VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlenTimeC INTEGER DEFAULT NULL;
	DECLARE _nextTimeV VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlenTimeV INTEGER DEFAULT NULL;
	DECLARE _idTimeCasa VARCHAR(5) DEFAULT NULL;
	DECLARE _idTimeVisit VARCHAR(5) DEFAULT NULL;
	DECLARE _dtInicio DATE DEFAULT NULL;
	DECLARE _dtFim DATE DEFAULT NULL;
	DECLARE strDelimiter CHAR(1) DEFAULT ',';
	DECLARE _numRodada INTEGER DEFAULT 1;
	DECLARE _count INTEGER DEFAULT 1;
	DECLARE _pIdsTimeCasaBkp VARCHAR(250) DEFAULT NULL;
	DECLARE _pIdsTimeVisitBkp VARCHAR(250) DEFAULT NULL;

	SET _dtInicio = pDtInicio;
	SET _dtFim = date_add(_dtInicio, INTERVAL pInInterval DAY);
	
	SET _pIdsTimeCasaBkp = pIdsTimeCasa;
	SET _pIdsTimeVisitBkp = pIdsTimeVisit;
		
	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsTimeCasa)) = 0 OR pIdsTimeCasa IS NULL THEN
			LEAVE iterator;
		END IF;
		
		IF _count > (pQtTimesCamp/2) THEN
			SET _count = 1;
			SET _numRodada = _numRodada+1;
			SET _dtInicio = date_add(_dtFim, INTERVAL 1 DAY);
			SET _dtFim = date_add(_dtInicio, INTERVAL pInInterval DAY);
		END IF;
		
		SET _nextTimeC = SUBSTRING_INDEX(pIdsTimeCasa,strDelimiter,1);
		SET _nextTimeV = SUBSTRING_INDEX(pIdsTimeVisit,strDelimiter,1);
		
		SET _nextlenTimeC = LENGTH(_nextTimeC);
		SET _nextlenTimeV = LENGTH(_nextTimeV);
		
		SET _idTimeCasa = TRIM(_nextTimeC);
		SET _idTimeVisit = TRIM(_nextTimeV);
		
		insert into TB_TABELA_JOGO (ID_CAMPEONATO, ID_FASE, DT_TABELA_INICIO_JOGO, DT_TABELA_FIM_JOGO, ID_TIME_CASA, ID_TIME_VISITANTE, IN_NUMERO_RODADA, DT_SORTEIO, DS_HORA_JOGO)
		values (pIdCamp, pIdFase, _dtInicio, _dtFim, CAST(_idTimeCasa AS SIGNED), CAST(_idTimeVisit AS SIGNED), _inNumRodIda, now(), '20:00');
		
		SET pIdsTimeCasa = INSERT(pIdsTimeCasa,1,_nextlenTimeC + 1,'');
		SET pIdsTimeVisit = INSERT(pIdsTimeVisit,1,_nextlenTimeV + 1,'');
		SET _count = _count+1;
	END LOOP;
	
	IF (pTurnoReturno = true) THEN
	
		SET _nextTimeC = NULL;
		SET _nextTimeV = NULL;
		SET _nextlenTimeC = NULL;
		SET _nextlenTimeV = NULL;
		SET _nextTimeC = NULL;
	
		SET pIdsTimeCasa = _pIdsTimeCasaBkp;
		SET pIdsTimeVisit = _pIdsTimeVisitBkp;
		
		SET _count = 1;
		SET _numRodada = _numRodada+1;
		SET _dtInicio = date_add(_dtFim, INTERVAL 1 DAY);
		SET _dtFim = date_add(_dtInicio, INTERVAL pInInterval DAY);
		
		iterator:
		LOOP
			IF LENGTH(TRIM(pIdsTimeCasa)) = 0 OR pIdsTimeCasa IS NULL THEN
				LEAVE iterator;
			END IF;
			
			IF _count > (pQtTimesCamp/2) THEN
				SET _count = 1;
				SET _numRodada = _numRodada+1;
				SET _dtInicio = date_add(_dtFim, INTERVAL 1 DAY);
				SET _dtFim = date_add(_dtInicio, INTERVAL pInInterval DAY);
			END IF;
			
			SET _nextTimeC = SUBSTRING_INDEX(pIdsTimeCasa,strDelimiter,1);
			SET _nextTimeV = SUBSTRING_INDEX(pIdsTimeVisit,strDelimiter,1);
			
			SET _nextlenTimeC = LENGTH(_nextTimeC);
			SET _nextlenTimeV = LENGTH(_nextTimeV);
			
			SET _idTimeCasa = TRIM(_nextTimeC);
			SET _idTimeVisit = TRIM(_nextTimeV);
			
			insert into TB_TABELA_JOGO (ID_CAMPEONATO, ID_FASE, DT_TABELA_INICIO_JOGO, DT_TABELA_FIM_JOGO, ID_TIME_CASA, ID_TIME_VISITANTE, IN_NUMERO_RODADA, DT_SORTEIO, DS_HORA_JOGO)
			values (pIdCamp, pIdFase, _dtInicio, _dtFim, CAST(_idTimeVisit AS SIGNED), CAST(_idTimeCasa AS SIGNED), _inNumRodIda, now(), '20:00');
			
			SET pIdsTimeCasa = INSERT(pIdsTimeCasa,1,_nextlenTimeC + 1,'');
			SET pIdsTimeVisit = INSERT(pIdsTimeVisit,1,_nextlenTimeV + 1,'');
			SET _count = _count+1;
		END LOOP;	

	END IF;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spValidadeTabelaJogoHasJogo` $$
CREATE PROCEDURE `spValidadeTabelaJogoHasJogo`(pIdCamp INTEGER)
Begin
    select count(1) as total_jogos from `TB_TABELA_JOGO` 
	where ID_CAMPEONATO = pIdCamp
	and DT_EFETIVACAO_JOGO is not null;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTabelaJogoOfCampeonatoFase` $$
CREATE PROCEDURE `spGetAllTabelaJogoOfCampeonatoFase`(pIdCamp INTEGER, pIdFase INTEGER)
Begin
    select IN_NUMERO_RODADA, ID_TABELA_JOGO, T1.DS_URL_TIME as DS_URL1, T2.DS_URL_TIME as DS_URL2, DATE_FORMAT(J.DT_TABELA_INICIO_JOGO,'%d/%m/%Y') as DJ, J.DT_EFETIVACAO_JOGO,
	J.DS_HORA_JOGO as HJ, J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, DATE_FORMAT(J.DT_TABELA_INICIO_JOGO,'%d/%m') as DJ2,
	J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, TU1.PSN_ID as 1P, TU2.PSN_ID as 2P, T1.DS_Tipo as DT1, T2.DS_Tipo as DT2
	from TB_TABELA_JOGO J, TB_TIME T1 , TB_TIME T2, TB_USUARIO_TIME U1, TB_USUARIO_TIME U2, TB_USUARIO TU1, TB_USUARIO TU2
	where ID_CAMPEONATO = pIdCamp
	and J.ID_FASE = pIdFase
	and J.IN_NUMERO_RODADA > 0
	and J.ID_TIME_CASA = T1.ID_TIME
	and J.ID_TIME_VISITANTE = T2.ID_TIME
	and J.ID_CAMPEONATO = U1.ID_CAMPEONATO
	and J.ID_CAMPEONATO = U2.ID_CAMPEONATO
	and J.ID_TIME_CASA = U1.ID_TIME
	and J.ID_TIME_VISITANTE = U2.ID_TIME
	and U1.ID_USUARIO = TU1.ID_USUARIO
	and U2.ID_USUARIO = TU2.ID_USUARIO
	order by J.DT_TABELA_INICIO_JOGO, J.DS_HORA_JOGO, J.ID_TABELA_JOGO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetTabelaJogoCurrentFase` $$
CREATE PROCEDURE `spGetTabelaJogoCurrentFase`(pIdCamp INTEGER)
Begin

	DECLARE _idFase INTEGER DEFAULT NULL;
	
	select ID_FASE into _idFase
	from TB_TABELA_JOGO
	where ID_CAMPEONATO = pIdCamp and DT_EFETIVACAO_JOGO is null;
	
	IF _idFase IS NULL THEN 

		select ID_FASE into _idFase
		from TB_TABELA_JOGO
		where DT_EFETIVACAO_JOGO is not null order by ID_FASE desc limit 1;
		
		IF _idFase IS NULL THEN 
			SET _idFase = 0;
		END IF;
		
	END IF;

    select _idFase as IdCurrentFase;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllFasesOfTabelaJogo` $$
CREATE PROCEDURE `spGetAllFasesOfTabelaJogo`(pIdCamp INTEGER)
Begin
	select F.*
	from TB_FASE F, TB_FASE_CAMPEONATO C
	where F.ID_FASE IN (select ID_FASE from TB_TABELA_JOGO where ID_CAMPEONATO = pIdCamp group by ID_FASE)
	and C.ID_CAMPEONATO = pIdCamp
	and F.ID_FASE = C.ID_FASE
	order by C.IN_ORDENACAO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetTabelaJogoAllDetailsOfCampeonato` $$
CREATE PROCEDURE `spGetTabelaJogoAllDetailsOfCampeonato`(
	pIdCamp INTEGER)
Begin
	IF fcValidCampeonatoIsOnlyPlayoff(pIdCamp) = 0 THEN
	
		select J.ID_CAMPEONATO, C.NM_CAMPEONATO, CASE WHEN TC1.ID_GRUPO > 0 THEN 'Grupo ' + TC1.ID_GRUPO ELSE NULL END as NM_GRUPO, 
		F.NM_FASE, T.NM_TEMPORADA, J.IN_NUMERO_RODADA, J.ID_TABELA_JOGO, T1.DS_URL_TIME as DS_URL1, T2.DS_URL_TIME as DS_URL2, J.DT_TABELA_INICIO_JOGO, J.DT_EFETIVACAO_JOGO,
		J.DS_HORA_JOGO as HJ, J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, J.ID_USUARIO_TIME_CASA, J.ID_USUARIO_TIME_VISITANTE, 
		T1.IN_TIME_COM_IMAGEM as IMG1, T2.IN_TIME_COM_IMAGEM as IMG2, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, TU1.PSN_ID as PSN1, TU2.PSN_ID as PSN2, TU1.ID_USUARIO as IDUSU1, TU2.ID_USUARIO as IDUSU2,
		T1.DS_Tipo as DT1, T2.DS_Tipo as DT2, J.DT_TABELA_FIM_JOGO, J.IN_JOGO_MATAXMATA, fcGetListaNegraByJogo(J.ID_TABELA_JOGO, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE) as IN_BLACK_LIST,
		(select USU.PSN_ID from TB_USUARIO USU where USU.ID_Usuario = J.ID_USUARIO_TIME_CASA) as NM_Tecnico_TimeCasa,
		(SELECT USU.PSN_ID FROM TB_USUARIO USU WHERE USU.ID_Usuario = J.ID_USUARIO_TIME_VISITANTE) as NM_Tecnico_TimeVisitante, TC1.ID_Grupo, J.ID_FASE
		from TB_TABELA_JOGO J, TB_CAMPEONATO C, TB_FASE F, TB_TEMPORADA T, TB_TIME T1 , TB_TIME T2, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2, TB_USUARIO TU1, TB_USUARIO TU2, TB_CLASSIFICACAO TC1, TB_CLASSIFICACAO TC2
		where J.ID_CAMPEONATO = pIdCamp
		and UT1.DT_VIGENCIA_FIM is null  
		and UT2.DT_VIGENCIA_FIM is null  
		and C.ID_TEMPORADA = T.ID_TEMPORADA
		and J.ID_CAMPEONATO = C.ID_CAMPEONATO
		and J.ID_FASE = F.ID_FASE
		and J.ID_TIME_CASA = T1.ID_TIME
		and J.ID_TIME_VISITANTE = T2.ID_TIME
		and T1.ID_TIME = UT1.ID_TIME  
		and T2.ID_TIME = UT2.ID_TIME  
		and UT1.ID_USUARIO = TU1.ID_USUARIO  
		and UT2.ID_USUARIO = TU2.ID_USUARIO  
		and UT1.ID_CAMPEONATO = J.ID_CAMPEONATO  
		and UT2.ID_CAMPEONATO = J.ID_CAMPEONATO  
		and J.ID_TIME_CASA = TC1.ID_TIME  
		and J.ID_TIME_VISITANTE = TC2.ID_TIME  
		and J.ID_CAMPEONATO = TC1.ID_CAMPEONATO  
		and J.ID_CAMPEONATO = TC2.ID_CAMPEONATO  
		order by J.ID_FASE, J.IN_NUMERO_RODADA, J.IN_JOGO_MATAXMATA, TC1.ID_Grupo, J.ID_TABELA_JOGO;
	
	ELSE
	
		select J.ID_CAMPEONATO, C.NM_CAMPEONATO, NULL as NM_GRUPO, F.NM_FASE, T.NM_TEMPORADA, J.IN_NUMERO_RODADA, J.ID_TABELA_JOGO, T1.DS_URL_TIME as DS_URL1, T2.DS_URL_TIME as DS_URL2, J.DT_TABELA_INICIO_JOGO, J.DT_EFETIVACAO_JOGO,
		J.DS_HORA_JOGO as HJ, J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, J.ID_USUARIO_TIME_CASA, J.ID_USUARIO_TIME_VISITANTE, 
		T1.IN_TIME_COM_IMAGEM as IMG1, T2.IN_TIME_COM_IMAGEM as IMG2, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, TU1.PSN_ID as PSN1, TU2.PSN_ID as PSN2, TU1.ID_USUARIO as IDUSU1, TU2.ID_USUARIO as IDUSU2,
		T1.DS_Tipo as DT1, T2.DS_Tipo as DT2, J.DT_TABELA_FIM_JOGO, J.IN_JOGO_MATAXMATA, fcGetListaNegraByJogo(J.ID_TABELA_JOGO, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE) as IN_BLACK_LIST,
		(select USU.PSN_ID from TB_USUARIO USU where USU.ID_Usuario = J.ID_USUARIO_TIME_CASA) as NM_Tecnico_TimeCasa,
		(SELECT USU.PSN_ID FROM TB_USUARIO USU WHERE USU.ID_Usuario = J.ID_USUARIO_TIME_VISITANTE) as NM_Tecnico_TimeVisitante, 0 as ID_Grupo, J.ID_FASE
		from TB_TABELA_JOGO J, TB_CAMPEONATO C, TB_FASE F, TB_TEMPORADA T, TB_TIME T1, TB_TIME T2, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2, TB_USUARIO TU1, TB_USUARIO TU2
		where J.ID_CAMPEONATO = pIdCamp
		and UT1.DT_VIGENCIA_FIM is null  
		and UT2.DT_VIGENCIA_FIM is null  
		and C.ID_TEMPORADA = T.ID_TEMPORADA
		and J.ID_CAMPEONATO = C.ID_CAMPEONATO
		and J.ID_FASE = F.ID_FASE
		and J.ID_TIME_CASA = T1.ID_TIME
		and J.ID_TIME_VISITANTE = T2.ID_TIME
		and T1.ID_TIME = UT1.ID_TIME  
		and T2.ID_TIME = UT2.ID_TIME  
		and UT1.ID_USUARIO = TU1.ID_USUARIO  
		and UT2.ID_USUARIO = TU2.ID_USUARIO  
		and UT1.ID_CAMPEONATO = J.ID_CAMPEONATO  
		and UT2.ID_CAMPEONATO = J.ID_CAMPEONATO  
		order by J.ID_FASE, J.DT_TABELA_INICIO_JOGO, J.DS_HORA_JOGO, J.ID_TABELA_JOGO;
	
	END IF;
		
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetTabelaJogoDetailsOfCampeonato` $$
CREATE PROCEDURE `spGetTabelaJogoDetailsOfCampeonato`(
	pIdCamp INTEGER, pIdJogo INTEGER)
Begin
	IF fcValidCampeonatoIsOnlyPlayoff(pIdCamp) = 0 THEN
	
		select J.ID_CAMPEONATO, C.NM_CAMPEONATO, fcGetTypeModelOfCampeonato(C.SG_TIPO_CAMPEONATO) as TP_CAMPEONATO, CASE WHEN TC1.ID_GRUPO > 0 THEN 'Grupo ' + TC1.ID_GRUPO ELSE NULL END as NM_GRUPO, 
		F.NM_FASE, T.NM_TEMPORADA, J.IN_NUMERO_RODADA, J.ID_TABELA_JOGO, T1.DS_URL_TIME as DS_URL1, T2.DS_URL_TIME as DS_URL2, J.DT_TABELA_INICIO_JOGO, J.DT_EFETIVACAO_JOGO,
		J.DS_HORA_JOGO as HJ, J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, 
		T1.IN_TIME_COM_IMAGEM as IMG1, T2.IN_TIME_COM_IMAGEM as IMG2, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, TU1.PSN_ID as PSN1, TU2.PSN_ID as PSN2, TU1.ID_USUARIO as ID1, TU2.ID_USUARIO as ID2, 
		T1.DS_Tipo as DT1, T2.DS_Tipo as DT2, J.DT_TABELA_FIM_JOGO, J.IN_JOGO_MATAXMATA,
		(select USU.NM_USUARIO from TB_USUARIO USU where USU.ID_Usuario = UT1.ID_USUARIO) as NM_Tecnico_TimeCasa,
		(SELECT USU.NM_USUARIO FROM TB_USUARIO USU WHERE USU.ID_Usuario = UT2.ID_USUARIO) as NM_Tecnico_TimeVisitante, TC1.ID_Grupo, J.ID_FASE
		from TB_TABELA_JOGO J, TB_CAMPEONATO C, TB_FASE F, TB_TEMPORADA T, TB_TIME T1 , TB_TIME T2, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2, TB_USUARIO TU1, TB_USUARIO TU2, TB_CLASSIFICACAO TC1, TB_CLASSIFICACAO TC2
		where J.ID_TABELA_JOGO = pIdJogo
		and J.ID_CAMPEONATO = pIdCamp
		and UT1.DT_VIGENCIA_FIM is null  
		and UT2.DT_VIGENCIA_FIM is null  
		and C.ID_TEMPORADA = T.ID_TEMPORADA
		and J.ID_CAMPEONATO = C.ID_CAMPEONATO
		and J.ID_FASE = F.ID_FASE
		and J.ID_TIME_CASA = T1.ID_TIME
		and J.ID_TIME_VISITANTE = T2.ID_TIME
		and T1.ID_TIME = UT1.ID_TIME  
		and T2.ID_TIME = UT2.ID_TIME  
		and UT1.ID_USUARIO = TU1.ID_USUARIO  
		and UT2.ID_USUARIO = TU2.ID_USUARIO  
		and UT1.ID_CAMPEONATO = J.ID_CAMPEONATO  
		and UT2.ID_CAMPEONATO = J.ID_CAMPEONATO  
		and J.ID_TIME_CASA = TC1.ID_TIME  
		and J.ID_TIME_VISITANTE = TC2.ID_TIME  
		and J.ID_CAMPEONATO = TC1.ID_CAMPEONATO  
		and J.ID_CAMPEONATO = TC2.ID_CAMPEONATO  
		order by J.ID_FASE, TC1.ID_Grupo, J.DT_TABELA_INICIO_JOGO, J.DS_HORA_JOGO, J.ID_TABELA_JOGO;
	
	ELSE
	
		select J.ID_CAMPEONATO, C.NM_CAMPEONATO, NULL as NM_GRUPO, F.NM_FASE, T.NM_TEMPORADA, J.IN_NUMERO_RODADA, J.ID_TABELA_JOGO, T1.DS_URL_TIME as DS_URL1, T2.DS_URL_TIME as DS_URL2, J.DT_TABELA_INICIO_JOGO, J.DT_EFETIVACAO_JOGO,
		fcGetTypeModelOfCampeonato(C.SG_TIPO_CAMPEONATO) as TP_CAMPEONATO, J.DS_HORA_JOGO as HJ, J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, 
		T1.IN_TIME_COM_IMAGEM as IMG1, T2.IN_TIME_COM_IMAGEM as IMG2, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, TU1.PSN_ID as PSN1, TU2.PSN_ID as PSN2, TU1.ID_USUARIO as ID1, TU2.ID_USUARIO as ID2, 
		T1.DS_Tipo as DT1, T2.DS_Tipo as DT2, J.DT_TABELA_FIM_JOGO, J.IN_JOGO_MATAXMATA,
		(select USU.NM_USUARIO from TB_USUARIO USU where USU.ID_Usuario = UT1.ID_USUARIO) as NM_Tecnico_TimeCasa,
		(SELECT USU.NM_USUARIO FROM TB_USUARIO USU WHERE USU.ID_Usuario = UT2.ID_USUARIO) as NM_Tecnico_TimeVisitante, 0 as ID_Grupo, J.ID_FASE
		from TB_TABELA_JOGO J, TB_CAMPEONATO C, TB_FASE F, TB_TEMPORADA T, TB_TIME T1, TB_TIME T2, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2, TB_USUARIO TU1, TB_USUARIO TU2
		where J.ID_TABELA_JOGO = pIdJogo
		and J.ID_CAMPEONATO = pIdCamp
		and UT1.DT_VIGENCIA_FIM is null  
		and UT2.DT_VIGENCIA_FIM is null  
		and C.ID_TEMPORADA = T.ID_TEMPORADA
		and J.ID_CAMPEONATO = C.ID_CAMPEONATO
		and J.ID_FASE = F.ID_FASE
		and J.ID_TIME_CASA = T1.ID_TIME
		and J.ID_TIME_VISITANTE = T2.ID_TIME
		and T1.ID_TIME = UT1.ID_TIME  
		and T2.ID_TIME = UT2.ID_TIME  
		and UT1.ID_USUARIO = TU1.ID_USUARIO  
		and UT2.ID_USUARIO = TU2.ID_USUARIO  
		and UT1.ID_CAMPEONATO = J.ID_CAMPEONATO  
		and UT2.ID_CAMPEONATO = J.ID_CAMPEONATO  
		order by J.ID_FASE, J.DT_TABELA_INICIO_JOGO, J.DS_HORA_JOGO, J.ID_TABELA_JOGO;
	
	END IF;
		
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spSaveSimpleResultTabelaJogo` $$
CREATE PROCEDURE `spSaveSimpleResultTabelaJogo`(    
    pIdJogo INTEGER,     
    pIdCamp INTEGER,     
    pGoalsTimeHome INTEGER,
    pGoalsTimeAway INTEGER,
    pIdUsuAcao INTEGER,
    pPsnIdUsuAcao VARCHAR(30)
)
Begin
	DECLARE _message VARCHAR(100) DEFAULT "";
	DECLARE _typeModel VARCHAR(3) DEFAULT "";
	DECLARE _descriptionDate VARCHAR(50) DEFAULT "";
	DECLARE _descriptionChampionship VARCHAR(80) DEFAULT "";
	DECLARE _descriptionMatch VARCHAR(100) DEFAULT "";
	DECLARE _descriptionCoaches VARCHAR(100) DEFAULT "";
	DECLARE _nmFase VARCHAR(50) DEFAULT "";
	DECLARE _nmCamp VARCHAR(50) DEFAULT "";
	DECLARE _campType VARCHAR(4) DEFAULT "";
	DECLARE _inIdaEVolta BOOLEAN DEFAULT FALSE;
	DECLARE _numRodada INTEGER DEFAULT NULL;
	DECLARE _idFase INTEGER DEFAULT NULL;
	DECLARE _idGrupo INTEGER DEFAULT NULL;
	DECLARE _nmTecnico1 VARCHAR(80) DEFAULT "";
	DECLARE _nmTecnico2 VARCHAR(80) DEFAULT "";
	DECLARE _idTime1 INTEGER DEFAULT NULL;
	DECLARE _nmTime1 VARCHAR(80) DEFAULT "";
	DECLARE _sgTime1 VARCHAR(10) DEFAULT "";
	DECLARE _idTime2 INTEGER DEFAULT NULL;
	DECLARE _nmTime2 VARCHAR(80) DEFAULT "";
	DECLARE _sgTime2 VARCHAR(10) DEFAULT "";
	DECLARE _isOnlyPlayOff INTEGER DEFAULT 0;

	#get variables
	SELECT NM_CAMPEONATO, SG_TIPO_CAMPEONATO, IN_SISTEMA_IDA_VOLTA
	into _nmCamp, _campType, _inIdaEVolta
	FROM TB_CAMPEONATO WHERE ID_CAMPEONATO = pIdCamp;
	
	SELECT CONCAT(U1.NM_Usuario, ' (', U1.psn_id, ')') as nm_tecnico1, CONCAT(U2.NM_Usuario, ' (', U2.psn_id, ')') as nm_tecnico2,
	       T1.NM_TIME as NM_TIME1, T1.DS_TIPO as DS_TIPO1, T2.NM_TIME as NM_TIME2, T2.DS_TIPO as DS_TIPO2, F.NM_Fase, J.IN_NUMERO_RODADA,
		   J.ID_TIME_CASA, J.ID_TIME_VISITANTE, J.ID_FASE
	into   _nmTecnico1, _nmTecnico2, _nmTime1, _sgTime1, _nmTime2, _sgTime2, _nmFase, _numRodada, _idTime1, _idTime2, _idFase
	FROM TB_TABELA_JOGO J, TB_TIME T1, TB_TIME T2, TB_USUARIO U1, TB_USUARIO U2, TB_FASE F, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2
	WHERE J.ID_TABELA_JOGO = pIdJogo
	AND UT1.DT_VIGENCIA_FIM IS NULL
	AND UT2.DT_VIGENCIA_FIM IS NULL
	AND J.ID_CAMPEONATO = UT1.ID_CAMPEONATO
	AND U1.ID_USUARIO = UT1.ID_USUARIO
	AND J.ID_TIME_CASA = UT1.ID_TIME
	AND J.ID_CAMPEONATO = UT2.ID_CAMPEONATO
	AND U2.ID_USUARIO = UT2.ID_USUARIO
	AND J.ID_TIME_VISITANTE = UT2.ID_TIME
	AND J.ID_TIME_CASA = T1.ID_TIME AND J.ID_TIME_VISITANTE = T2.ID_TIME
	AND J.ID_FASE = F.ID_FASE;

	SELECT ID_GRUPO into _idGrupo
	FROM TB_CLASSIFICACAO WHERE ID_CAMPEONATO = pIdCamp AND ID_TIME = _idTime1;
	
	IF _idGrupo IS NULL THEN
		SET _idGrupo = 0;
	END IF;
	
	#save result
    update `TB_TABELA_JOGO` 
	set QT_GOLS_TIME_CASA = pGoalsTimeHome, QT_GOLS_TIME_VISITANTE = pGoalsTimeAway, DT_EFETIVACAO_JOGO = CURDATE(),
	    ID_USUARIO_TIME_CASA = fcGetIdUsuarioByTime(pIdCamp,_idTime1), ID_USUARIO_TIME_VISITANTE = fcGetIdUsuarioByTime(pIdCamp,_idTime2),
	    DT_ULTIMA_EFETIVACAO = now(), DS_LOGIN_EFETIVACAO = pPsnIdUsuAcao
	where ID_TABELA_JOGO = pIdJogo;
	
	
	#save comment automatically
	SET _typeModel = fcGetTypeModelOfCampeonato(_campType);
	
	IF (pGoalsTimeHome = 0 AND pGoalsTimeAway = 0) OR _typeModel = "FUT" THEN
	   SET _message = "<b>Placar atualizado.</b>";
	ELSE
	   SET _message = "<b>Placar e artilharia atualizados.</b>";
	END IF;
	
	call `arenafifadb`.`spAddComentarioJogo`(pIdJogo, pIdUsuAcao, _message);


	#save historic result automatically
	SET _descriptionDate = CONCAT(date_format(now(), '%W, %d de %M de %Y'), " às ", DATE_FORMAT(CURRENT_TIME(), '%H:%i'));
	
	IF _idFase = 0 THEN
		SET _descriptionChampionship = CONCAT(_nmCamp, " - ", _nmFase, " - ", _numRodada, "ª rodada");
	ELSEIF _numRodada = 1 AND _inIdaEVolta = FALSE THEN
		SET _descriptionChampionship = CONCAT(_nmCamp, " - ", _nmFase, " - Jogo Único");
	ELSEIF _numRodada = 1 AND _inIdaEVolta = 1 THEN
		SET _descriptionChampionship = CONCAT(_nmCamp, " - ", _nmFase, " - Ida");
	ELSEIF _numRodada = 2 THEN
		SET _descriptionChampionship = CONCAT(_nmCamp, " - ", _nmFase, " - Volta");
	END IF;
	
	IF _idFase = 0 AND _idGrupo > 0 THEN
		SET _descriptionChampionship = CONCAT(_descriptionChampionship, " - Grupo ", _idGrupo);
	END IF;
	
	IF _typeModel = "H2H" THEN
		SET _nmTime1 = CONCAT(_nmTime1, " (", _sgTime1, ")");
		SET _nmTime2 = CONCAT(_nmTime2, " (", _sgTime2, ")");
	END IF;
	
	SET _descriptionMatch = CONCAT(_nmTime1, " ", pGoalsTimeHome, " vs ", pGoalsTimeAway, " ", _nmTime2);
	SET _descriptionCoaches = CONCAT(_nmTecnico1, " vs ", _nmTecnico2);
	
	call `arenafifadb`.`spAddUpdateResultadoLancado`(CURDATE(), pIdJogo, "NORMAL", pIdCamp, _descriptionDate, _descriptionChampionship, _descriptionMatch, _descriptionCoaches, pPsnIdUsuAcao);


	#calculate team table
	SET _isOnlyPlayOff = fcValidCampeonatoIsOnlyPlayoff(pIdCamp);

	IF _idFase = 0 AND _isOnlyPlayOff = 0 THEN
	
		call `arenafifadb`.`spCalculateClassificacaoByTime`(pIdCamp, _idTime1);
		call `arenafifadb`.`spCalculateClassificacaoByTime`(pIdCamp, _idTime2);
	
	END IF;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDecreeSimpleResultTabelaJogo` $$
CREATE PROCEDURE `spDecreeSimpleResultTabelaJogo`(    
    pIdJogo INTEGER,     
    pIdCamp INTEGER,     
    pGoalsTimeHome INTEGER,
    pGoalsTimeAway INTEGER,
    pIdUsuAcao INTEGER,
    pPsnIdUsuAcao VARCHAR(30),
	pMessage VARCHAR(250),
	pSgTpListaNegra VARCHAR(20)
)
Begin
	DECLARE _typeModel VARCHAR(3) DEFAULT "";
	DECLARE _descriptionDate VARCHAR(50) DEFAULT "";
	DECLARE _descriptionChampionship VARCHAR(80) DEFAULT "";
	DECLARE _descriptionMatch VARCHAR(100) DEFAULT "";
	DECLARE _descriptionCoaches VARCHAR(100) DEFAULT "";
	DECLARE _nmFase VARCHAR(50) DEFAULT "";
	DECLARE _nmCamp VARCHAR(50) DEFAULT "";
	DECLARE _campType VARCHAR(4) DEFAULT "";
	DECLARE _inIdaEVolta BOOLEAN DEFAULT FALSE;
	DECLARE _numRodada INTEGER DEFAULT NULL;
	DECLARE _tempID INTEGER DEFAULT NULL;
	DECLARE _idFase INTEGER DEFAULT NULL;
	DECLARE _idGrupo INTEGER DEFAULT NULL;
	DECLARE _idTecnico1 INTEGER DEFAULT NULL;
	DECLARE _nmTecnico1 VARCHAR(80) DEFAULT "";
	DECLARE _idTecnico2 INTEGER DEFAULT NULL;
	DECLARE _nmTecnico2 VARCHAR(80) DEFAULT "";
	DECLARE _idTime1 INTEGER DEFAULT NULL;
	DECLARE _nmTime1 VARCHAR(80) DEFAULT "";
	DECLARE _sgTime1 VARCHAR(10) DEFAULT "";
	DECLARE _idTime2 INTEGER DEFAULT NULL;
	DECLARE _nmTime2 VARCHAR(80) DEFAULT "";
	DECLARE _sgTime2 VARCHAR(10) DEFAULT "";
	DECLARE _isOnlyPlayOff INTEGER DEFAULT 0;

	#get variables
	SELECT NM_CAMPEONATO, SG_TIPO_CAMPEONATO, IN_SISTEMA_IDA_VOLTA
	into _nmCamp, _campType, _inIdaEVolta
	FROM TB_CAMPEONATO WHERE ID_CAMPEONATO = pIdCamp;
	
	
	SELECT U1.ID_Usuario as id_usuario1, CONCAT(U1.NM_Usuario, ' (', U1.psn_id, ')') as nm_tecnico1, U2.ID_Usuario as id_usuario2, CONCAT(U2.NM_Usuario, ' (', U2.psn_id, ')') as nm_tecnico2,
	       T1.NM_TIME as NM_TIME1, T1.DS_TIPO as DS_TIPO1, T2.NM_TIME as NM_TIME2, T2.DS_TIPO as DS_TIPO2, F.NM_Fase, J.IN_NUMERO_RODADA,
		   J.ID_TIME_CASA, J.ID_TIME_VISITANTE, J.ID_FASE
	into   _idTecnico1, _nmTecnico1, _idTecnico2, _nmTecnico2, _nmTime1, _sgTime1, _nmTime2, _sgTime2, _nmFase, _numRodada, _idTime1, _idTime2, _idFase
	FROM TB_TABELA_JOGO J, TB_TIME T1, TB_TIME T2, TB_USUARIO U1, TB_USUARIO U2, TB_FASE F, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2
	WHERE J.ID_TABELA_JOGO = pIdJogo
	AND UT1.DT_VIGENCIA_FIM IS NULL
	AND UT2.DT_VIGENCIA_FIM IS NULL
	AND J.ID_CAMPEONATO = UT1.ID_CAMPEONATO
	AND U1.ID_USUARIO = UT1.ID_USUARIO
	AND J.ID_TIME_CASA = UT1.ID_TIME
	AND J.ID_CAMPEONATO = UT2.ID_CAMPEONATO
	AND U2.ID_USUARIO = UT2.ID_USUARIO
	AND J.ID_TIME_VISITANTE = UT2.ID_TIME
	AND J.ID_TIME_CASA = T1.ID_TIME AND J.ID_TIME_VISITANTE = T2.ID_TIME
	AND J.ID_FASE = F.ID_FASE;
	
	SELECT ID_GRUPO into _idGrupo
	FROM TB_CLASSIFICACAO WHERE ID_CAMPEONATO = pIdCamp AND ID_TIME = _idTime1;
	
	IF _idGrupo IS NULL THEN
		SET _idGrupo = 0;
	END IF;
	
	#save result
    update `TB_TABELA_JOGO` 
	set QT_GOLS_TIME_CASA = pGoalsTimeHome, QT_GOLS_TIME_VISITANTE = pGoalsTimeAway, DT_EFETIVACAO_JOGO = CURDATE(),
	    ID_USUARIO_TIME_CASA = fcGetIdUsuarioByTime(pIdCamp,_idTime1), ID_USUARIO_TIME_VISITANTE = fcGetIdUsuarioByTime(pIdCamp,_idTime2),
	    DT_ULTIMA_EFETIVACAO = now(), DS_LOGIN_EFETIVACAO = pPsnIdUsuAcao
	where ID_TABELA_JOGO = pIdJogo;
	
	
	#save comment automatically
	SET _typeModel = fcGetTypeModelOfCampeonato(_campType);
	
	call `arenafifadb`.`spAddComentarioJogo`(pIdJogo, pIdUsuAcao, pMessage);


	#save historic result automatically
	SET _descriptionDate = CONCAT(date_format(now(), '%W, %d de %M de %Y'), " às ", DATE_FORMAT(CURRENT_TIME(), '%H:%i'));
	
	IF _idFase = 0 THEN
		SET _descriptionChampionship = CONCAT(_nmCamp, " - ", _nmFase, " - ", _numRodada, "ª rodada");
	ELSEIF _numRodada = 1 AND _inIdaEVolta = FALSE THEN
		SET _descriptionChampionship = CONCAT(_nmCamp, " - ", _nmFase, " - Jogo Único");
	ELSEIF _numRodada = 1 AND _inIdaEVolta = 1 THEN
		SET _descriptionChampionship = CONCAT(_nmCamp, " - ", _nmFase, " - Ida");
	ELSEIF _numRodada = 2 THEN
		SET _descriptionChampionship = CONCAT(_nmCamp, " - ", _nmFase, " - Volta");
	END IF;
	
	IF _idFase = 0 AND _idGrupo > 0 THEN
		SET _descriptionChampionship = CONCAT(_descriptionChampionship, " - Grupo ", _idGrupo);
	END IF;
	
	IF _typeModel = "H2H" THEN
		SET _nmTime1 = CONCAT(_nmTime1, " (", _sgTime1, ")");
		SET _nmTime2 = CONCAT(_nmTime2, " (", _sgTime2, ")");
	END IF;
	
	SET _descriptionMatch = CONCAT(_nmTime1, " ", pGoalsTimeHome, " vs ", pGoalsTimeAway, " ", _nmTime2, " (WO)");
	SET _descriptionCoaches = CONCAT(_nmTecnico1, " vs ", _nmTecnico2);

	
	call `arenafifadb`.`spAddUpdateResultadoLancado`(CURDATE(), pIdJogo, "DECRETO", pIdCamp, _descriptionDate, _descriptionChampionship, _descriptionMatch, _descriptionCoaches, pPsnIdUsuAcao);

	SET _tempID = fcGetIdTempCurrent();

	IF pGoalsTimeHome > pGoalsTimeAway AND pSgTpListaNegra <> '' THEN
		call `arenafifadb`.`spAddListaNegra`(_tempID, pIdCamp, _idTecnico2, pIdJogo, pSgTpListaNegra);
	ELSEIF pGoalsTimeHome < pGoalsTimeAway AND pSgTpListaNegra <> '' THEN
		call `arenafifadb`.`spAddListaNegra`(_tempID, pIdCamp, _idTecnico1, pIdJogo, pSgTpListaNegra);
	ELSEIF pGoalsTimeHome = pGoalsTimeAway AND pSgTpListaNegra <> '' THEN
		call `arenafifadb`.`spAddListaNegra`(_tempID, pIdCamp, _idTecnico1, pIdJogo, pSgTpListaNegra);
		call `arenafifadb`.`spAddListaNegra`(_tempID, pIdCamp, _idTecnico2, pIdJogo, pSgTpListaNegra);
	END IF;

	#calculate team table
	SET _isOnlyPlayOff = fcValidCampeonatoIsOnlyPlayoff(pIdCamp);

	IF _idFase = 0 AND _isOnlyPlayOff = 0 THEN
	
		call `arenafifadb`.`spCalculateClassificacaoByTime`(pIdCamp, _idTime1);
		call `arenafifadb`.`spCalculateClassificacaoByTime`(pIdCamp, _idTime2);
	
	END IF;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteResultTabelaJogo` $$
CREATE PROCEDURE `spDeleteResultTabelaJogo`(    
    pIdJogo INTEGER,     
    pIdUsuAcao INTEGER,
    pPsnIdUsuAcao VARCHAR(30)
)
Begin
	DECLARE _IdCamp INTEGER DEFAULT NULL;
	DECLARE _idFase INTEGER DEFAULT NULL;
	DECLARE _idTimeHome INTEGER DEFAULT NULL;
	DECLARE _idTimeAway INTEGER DEFAULT NULL;
	#delete black list
	call `arenafifadb`.`spRemoveListaNegraByJogo`(pIdJogo);

	#delete result launched
	call `arenafifadb`.`spDeleteResultadoLancado`(pIdJogo);

	#delete scorer
	call `arenafifadb`.`spDeleteAllGoleadorJogo`(pIdJogo);

	#save result
    update `TB_TABELA_JOGO` 
	set QT_GOLS_TIME_CASA = Null, QT_GOLS_TIME_VISITANTE = Null, DT_EFETIVACAO_JOGO = Null,
	    ID_USUARIO_TIME_CASA = Null, ID_USUARIO_TIME_VISITANTE = Null,
	    DT_ULTIMA_EFETIVACAO = now(), DS_LOGIN_EFETIVACAO = pPsnIdUsuAcao
	where ID_TABELA_JOGO = pIdJogo;
	
	SELECT ID_CAMPEONATO, ID_FASE, ID_TIME_CASA, ID_TIME_VISITANTE into _IdCamp, _idFase, _idTimeHome, _idTimeAway
	FROM TB_TABELA_JOGO
	where ID_TABELA_JOGO = pIdJogo;
	
	IF _idFase = 0 THEN
		call `arenafifadb`.`spCalculateClassificacaoByTime`(_IdCamp, _idTimeHome);
		call `arenafifadb`.`spCalculateClassificacaoByTime`(_IdCamp, _idTimeAway);
	END IF;
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTabelaJogoAllHistoricoByTimes` $$
CREATE PROCEDURE `spGetAllTabelaJogoAllHistoricoByTimes`(
	pIdCamp INTEGER, pIdTimeCasa INTEGER, pIdVisitante INTEGER, pTotalRegistroCada INTEGER)
Begin
	DECLARE _exist INTEGER DEFAULT NULL;
	
	SELECT DISTINCT * FROM ((select C.NM_CAMPEONATO, J.ID_FASE, J.IN_NUMERO_RODADA, J.DT_TABELA_INICIO_JOGO, J.DT_TABELA_FIM_JOGO, J.ID_TIME_CASA, J.ID_TIME_VISITANTE, J.DT_EFETIVACAO_JOGO, J.ID_TABELA_JOGO, 
	F.NM_FASE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, TU1.PSN_ID as PSN1, TU2.PSN_ID as PSN2, T1.DS_Tipo as DT1, T2.DS_Tipo as DT2
	from TB_TABELA_JOGO J, TB_CAMPEONATO C, TB_FASE F, TB_TIME T1, TB_TIME T2, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2, TB_USUARIO TU1, TB_USUARIO TU2
	where J.ID_CAMPEONATO = pIdCamp
	and J.QT_GOLS_TIME_CASA IS NOT NULL
	and (J.ID_TIME_CASA = pIdTimeCasa OR J.ID_TIME_VISITANTE = pIdTimeCasa)
	and UT1.DT_VIGENCIA_FIM is null  
	and UT2.DT_VIGENCIA_FIM is null  
	and J.ID_CAMPEONATO = C.ID_CAMPEONATO
	and J.ID_FASE = F.ID_FASE
	and J.ID_TIME_CASA = T1.ID_TIME
	and J.ID_TIME_VISITANTE = T2.ID_TIME
	and T1.ID_TIME = UT1.ID_TIME  
	and T2.ID_TIME = UT2.ID_TIME  
	and UT1.ID_USUARIO = TU1.ID_USUARIO  
	and UT2.ID_USUARIO = TU2.ID_USUARIO  
	and UT1.ID_CAMPEONATO = J.ID_CAMPEONATO  
	and UT2.ID_CAMPEONATO = J.ID_CAMPEONATO  
	order by J.DT_EFETIVACAO_JOGO DESC, J.ID_TABELA_JOGO DESC LIMIT pTotalRegistroCada)
	
	UNION ALL
	
	(select C.NM_CAMPEONATO, J.ID_FASE, J.IN_NUMERO_RODADA, J.DT_TABELA_INICIO_JOGO, J.DT_TABELA_FIM_JOGO, J.ID_TIME_CASA, J.ID_TIME_VISITANTE, J.DT_EFETIVACAO_JOGO, J.ID_TABELA_JOGO, 
	F.NM_FASE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, TU1.PSN_ID as PSN1, TU2.PSN_ID as PSN2, T1.DS_Tipo as DT1, T2.DS_Tipo as DT2
	from TB_TABELA_JOGO J, TB_CAMPEONATO C, TB_FASE F, TB_TIME T1, TB_TIME T2, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2, TB_USUARIO TU1, TB_USUARIO TU2
	where J.ID_CAMPEONATO = pIdCamp
	and J.QT_GOLS_TIME_CASA IS NOT NULL
	and (J.ID_TIME_CASA = pIdVisitante OR J.ID_TIME_VISITANTE = pIdVisitante)
	and UT1.DT_VIGENCIA_FIM is null  
	and UT2.DT_VIGENCIA_FIM is null  
	and J.ID_CAMPEONATO = C.ID_CAMPEONATO
	and J.ID_FASE = F.ID_FASE
	and J.ID_TIME_CASA = T1.ID_TIME
	and J.ID_TIME_VISITANTE = T2.ID_TIME
	and T1.ID_TIME = UT1.ID_TIME  
	and T2.ID_TIME = UT2.ID_TIME  
	and UT1.ID_USUARIO = TU1.ID_USUARIO  
	and UT2.ID_USUARIO = TU2.ID_USUARIO  
	and UT1.ID_CAMPEONATO = J.ID_CAMPEONATO  
	and UT2.ID_CAMPEONATO = J.ID_CAMPEONATO  
	order by J.DT_EFETIVACAO_JOGO DESC, J.ID_TABELA_JOGO DESC LIMIT pTotalRegistroCada)) as X
	
	ORDER BY DT_EFETIVACAO_JOGO DESC, ID_TABELA_JOGO DESC;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetTabelaJogoAllDetailsForMyMatches` $$
CREATE PROCEDURE `spGetTabelaJogoAllDetailsForMyMatches`(
	pTypeMyMactches VARCHAR(8), pIdTime INTEGER, pIdSelecao INTEGER )
Begin

	IF pTypeMyMactches = "NEXT" THEN

		select J.ID_CAMPEONATO, C.NM_CAMPEONATO, F.NM_FASE, J.IN_NUMERO_RODADA, J.ID_TABELA_JOGO, J.DT_TABELA_INICIO_JOGO,
		J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, TU1.PSN_ID as PSN1, TU2.PSN_ID as PSN2, 
		T1.DS_Tipo as DT1, T2.DS_Tipo as DT2, J.DT_TABELA_FIM_JOGO, J.ID_FASE, 0 as ID_USUARIO_TIME_CASA, 0 as ID_USUARIO_TIME_VISITANTE
		from TB_TABELA_JOGO J, TB_CAMPEONATO C, TB_FASE F, TB_TIME T1, TB_TIME T2, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2, TB_USUARIO TU1, TB_USUARIO TU2
		where J.QT_GOLS_TIME_CASA is null
		and (J.ID_TIME_CASA in (pIdTime, pIdSelecao) OR J.ID_TIME_VISITANTE in (pIdTime, pIdSelecao))
		and UT1.DT_VIGENCIA_FIM is null  
		and UT2.DT_VIGENCIA_FIM is null  
		and J.ID_CAMPEONATO = C.ID_CAMPEONATO
		and J.ID_FASE = F.ID_FASE
		and J.ID_TIME_CASA = T1.ID_TIME
		and J.ID_TIME_VISITANTE = T2.ID_TIME
		and T1.ID_TIME = UT1.ID_TIME  
		and T2.ID_TIME = UT2.ID_TIME  
		and UT1.ID_USUARIO = TU1.ID_USUARIO  
		and UT2.ID_USUARIO = TU2.ID_USUARIO  
		and UT1.ID_CAMPEONATO = J.ID_CAMPEONATO  
		and UT2.ID_CAMPEONATO = J.ID_CAMPEONATO  
		order by J.DT_TABELA_INICIO_JOGO, J.ID_CAMPEONATO, J.ID_TABELA_JOGO;
	
	ELSEIF pTypeMyMactches = "DONE" THEN
	
		select J.ID_CAMPEONATO, C.NM_CAMPEONATO, F.NM_FASE, J.IN_NUMERO_RODADA, J.ID_TABELA_JOGO, J.DT_TABELA_INICIO_JOGO,
		J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, TU1.PSN_ID as PSN1, TU2.PSN_ID as PSN2, 
		T1.DS_Tipo as DT1, T2.DS_Tipo as DT2, J.DT_TABELA_FIM_JOGO, J.ID_FASE, J.ID_USUARIO_TIME_CASA, J.ID_USUARIO_TIME_VISITANTE
		from TB_TABELA_JOGO J, TB_CAMPEONATO C, TB_FASE F, TB_TIME T1, TB_TIME T2, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2, TB_USUARIO TU1, TB_USUARIO TU2
		where J.QT_GOLS_TIME_CASA is NOT null
		and (J.ID_TIME_CASA in (pIdTime, pIdSelecao) OR J.ID_TIME_VISITANTE in (pIdTime, pIdSelecao))
		and UT1.DT_VIGENCIA_FIM is null  
		and UT2.DT_VIGENCIA_FIM is null  
		and J.ID_CAMPEONATO = C.ID_CAMPEONATO
		and J.ID_FASE = F.ID_FASE
		and J.ID_TIME_CASA = T1.ID_TIME
		and J.ID_TIME_VISITANTE = T2.ID_TIME
		and T1.ID_TIME = UT1.ID_TIME  
		and T2.ID_TIME = UT2.ID_TIME  
		and UT1.ID_USUARIO = TU1.ID_USUARIO  
		and UT2.ID_USUARIO = TU2.ID_USUARIO  
		and UT1.ID_CAMPEONATO = J.ID_CAMPEONATO  
		and UT2.ID_CAMPEONATO = J.ID_CAMPEONATO  
		order by J.DT_TABELA_INICIO_JOGO, J.ID_CAMPEONATO, J.ID_TABELA_JOGO;
	
	END IF;
	
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetTotalsClashesHistory` $$
CREATE PROCEDURE `spGetTotalsClashesHistory`(pType VARCHAR(3), pIdUsuLogged INTEGER, pPsnIDSearch VARCHAR(30))
begin      
	DECLARE _totalWinUsuLogged INTEGER DEFAULT 0;
	DECLARE _totalWinUsuSearch INTEGER DEFAULT 0;
	DECLARE _totalDraw INTEGER DEFAULT 0;
	DECLARE _totalLossUsuLogged INTEGER DEFAULT 0;
	DECLARE _totalLossUsuSearch INTEGER DEFAULT 0;
	DECLARE _totalGoalsUsuLogged INTEGER DEFAULT 0;
	DECLARE _totalGoalsUsuSearch INTEGER DEFAULT 0;
	DECLARE _idUsuSearch INTEGER DEFAULT 0;
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idError INTEGER DEFAULT 0;
	DECLARE _userIDHome INTEGER DEFAULT 0;
	DECLARE _totalGoalsHome INTEGER DEFAULT 0;
	DECLARE _totalGoalsAway INTEGER DEFAULT 0;
	DECLARE _idCamp INTEGER DEFAULT 0;
	DECLARE _dtMatch DATE DEFAULT NULL;
	
    SELECT ID_USUARIO into _idUsuSearch FROM TB_USUARIO WHERE PSN_ID = pPsnIDSearch;
	
	IF _idUsuSearch IS NULL OR _idUsuSearch = 0 THEN
	
		SET _idError = -1;
	
	ELSE
    
		begin
		
			DECLARE tabela_cursor CURSOR FOR
				SELECT J.ID_Campeonato, J.DT_TABELA_INICIO_JOGO, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, J.ID_USUARIO_TIME_CASA
				FROM TB_TABELA_JOGO J, TB_CAMPEONATO C, TB_TIME T1 , TB_TIME T2 
				WHERE (J.ID_USUARIO_TIME_CASA = pIdUsuLogged OR J.ID_USUARIO_TIME_CASA = _idUsuSearch)
				  AND (J.ID_USUARIO_TIME_VISITANTE = pIdUsuLogged OR J.ID_USUARIO_TIME_VISITANTE = _idUsuSearch)
				  AND J.QT_GOLS_TIME_CASA IS NOT NULL
				  AND FIND_IN_SET(C.SG_TIPO_CAMPEONATO,fcGetAllSiglaByMode(pType))
				  AND J.ID_CAMPEONATO = C.ID_CAMPEONATO AND J.ID_TIME_CASA = T1.ID_TIME
				  AND J.ID_TIME_VISITANTE = T2.ID_TIME

				UNION ALL

				SELECT J.ID_Campeonato, J.DT_TABELA_INICIO_JOGO, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, J.ID_USUARIO_TIME_CASA
				FROM arena_clashes.TB_TABELA_JOGO J, arena_clashes.TB_CAMPEONATO C, arena_clashes.TB_TIME T1 , arena_clashes.TB_TIME T2 
				WHERE (J.ID_USUARIO_TIME_CASA = pIdUsuLogged OR J.ID_USUARIO_TIME_CASA = _idUsuSearch)
				  AND (J.ID_USUARIO_TIME_VISITANTE = pIdUsuLogged OR J.ID_USUARIO_TIME_VISITANTE = _idUsuSearch)
				  AND J.QT_GOLS_TIME_CASA IS NOT NULL
				  AND FIND_IN_SET(C.SG_TIPO_CAMPEONATO,fcGetAllSiglaByMode(pType))
				  AND J.ID_CAMPEONATO = C.ID_CAMPEONATO AND J.ID_TIME_CASA = T1.ID_TIME
				  AND J.ID_TIME_VISITANTE = T2.ID_TIME

				  ORDER BY ID_Campeonato, DT_TABELA_INICIO_JOGO;
				
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
			
			OPEN tabela_cursor;
			
			get_tabela: LOOP
			
				FETCH tabela_cursor INTO _idCamp, _dtMatch, _totalGoalsHome, _totalGoalsAway, _userIDHome;
				
				IF _finished = 1 THEN
					LEAVE get_tabela;
				END IF;
				
				IF _totalGoalsHome = _totalGoalsAway THEN
				
					SET _totalDraw = _totalDraw + 1;
					
					SET _totalGoalsUsuLogged = _totalGoalsUsuLogged + _totalGoalsHome;
					SET _totalGoalsUsuSearch = _totalGoalsUsuSearch + _totalGoalsHome;
					
				ELSEIF _userIDHome = pIdUsuLogged THEN
					
					SET _totalGoalsUsuLogged = _totalGoalsUsuLogged + _totalGoalsHome;
					SET _totalGoalsUsuSearch = _totalGoalsUsuSearch + _totalGoalsAway;
					
					IF _totalGoalsHome > _totalGoalsAway THEN
					
						SET _totalWinUsuLogged = _totalWinUsuLogged + 1;
					
					ELSE
					
						SET _totalWinUsuSearch = _totalWinUsuSearch + 1;
					
					END IF;
					

				ELSEIF _userIDHome = _idUsuSearch THEN
					
					SET _totalGoalsUsuLogged = _totalGoalsUsuLogged + _totalGoalsAway;
					SET _totalGoalsUsuSearch = _totalGoalsUsuSearch + _totalGoalsHome;
					
					IF _totalGoalsHome > _totalGoalsAway THEN
					
						SET _totalWinUsuSearch = _totalWinUsuSearch + 1;
					
					ELSE
					
						SET _totalWinUsuLogged = _totalWinUsuLogged + 1;
					
					END IF;
					
				END IF;
				
			END LOOP get_tabela;
			
			CLOSE tabela_cursor;
				
		end;
	END IF;
   
	SELECT _totalWinUsuLogged as totalWinUsuLogged, _totalWinUsuSearch as totalWinUsuSearch, _totalDraw as totalDraw, _totalLossUsuLogged as totalLossUsuLogged, 
	      _totalLossUsuSearch as totalLossUsuSearch, _totalGoalsUsuLogged as totalGoalsUsuLogged, _totalGoalsUsuSearch as totalGoalsUsuSearch, _idUsuSearch as idUsuSearch,
		  _idError as errorID;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetTotalsClashesHistoryByTimes` $$
CREATE PROCEDURE `spGetTotalsClashesHistoryByTimes`(pType VARCHAR(3), pIdTimeHome INTEGER, pIdTimeAway INTEGER)
begin      
	DECLARE _totalWinUsuLogged INTEGER DEFAULT 0;
	DECLARE _totalWinUsuSearch INTEGER DEFAULT 0;
	DECLARE _totalDraw INTEGER DEFAULT 0;
	DECLARE _totalLossUsuLogged INTEGER DEFAULT 0;
	DECLARE _totalLossUsuSearch INTEGER DEFAULT 0;
	DECLARE _totalGoalsUsuLogged INTEGER DEFAULT 0;
	DECLARE _totalGoalsUsuSearch INTEGER DEFAULT 0;
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _IDTimeHome INTEGER DEFAULT 0;
	DECLARE _totalGoalsHome INTEGER DEFAULT 0;
	DECLARE _totalGoalsAway INTEGER DEFAULT 0;
	DECLARE _idCamp INTEGER DEFAULT 0;
	DECLARE _nmTimeHome VARCHAR(50) DEFAULT NULL;
	DECLARE _nmTimeAway VARCHAR(50) DEFAULT NULL;
	DECLARE _dtMatch DATE DEFAULT NULL;
	
	DECLARE tabela_cursor CURSOR FOR
		SELECT J.ID_Campeonato, J.DT_TABELA_INICIO_JOGO, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, J.ID_TIME_CASA, T1.NM_TIME, T2.NM_TIME
		FROM TB_TABELA_JOGO J, TB_CAMPEONATO C, TB_TIME T1 , TB_TIME T2 
		WHERE (J.ID_TIME_CASA = pIdTimeHome OR J.ID_TIME_CASA = pIdTimeAway)
		  AND (J.ID_TIME_VISITANTE = pIdTimeHome OR J.ID_TIME_VISITANTE = pIdTimeAway)
		  AND J.QT_GOLS_TIME_CASA IS NOT NULL
		  AND FIND_IN_SET(C.SG_TIPO_CAMPEONATO,fcGetAllSiglaByMode(pType))
		  AND J.ID_CAMPEONATO = C.ID_CAMPEONATO AND J.ID_TIME_CASA = T1.ID_TIME
		  AND J.ID_TIME_VISITANTE = T2.ID_TIME

		UNION ALL

		SELECT J.ID_Campeonato, J.DT_TABELA_INICIO_JOGO, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, J.ID_TIME_CASA, T1.NM_TIME, T2.NM_TIME
		FROM arena_clashes.TB_TABELA_JOGO J, arena_clashes.TB_CAMPEONATO C, arena_clashes.TB_TIME T1 , arena_clashes.TB_TIME T2 
		WHERE (J.ID_TIME_CASA = pIdTimeHome OR J.ID_TIME_CASA = pIdTimeAway)
		  AND (J.ID_TIME_VISITANTE = pIdTimeHome OR J.ID_TIME_VISITANTE = pIdTimeAway)
		  AND J.QT_GOLS_TIME_CASA IS NOT NULL
		  AND FIND_IN_SET(C.SG_TIPO_CAMPEONATO,fcGetAllSiglaByMode(pType))
		  AND J.ID_CAMPEONATO = C.ID_CAMPEONATO AND J.ID_TIME_CASA = T1.ID_TIME
		  AND J.ID_TIME_VISITANTE = T2.ID_TIME

		  ORDER BY ID_Campeonato, DT_TABELA_INICIO_JOGO;
		
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idCamp, _dtMatch, _totalGoalsHome, _totalGoalsAway, _IDTimeHome, _nmTimeHome, _nmTimeAway;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _totalGoalsHome = _totalGoalsAway THEN
		
			SET _totalDraw = _totalDraw + 1;
			
			SET _totalGoalsUsuLogged = _totalGoalsUsuLogged + _totalGoalsHome;
			SET _totalGoalsUsuSearch = _totalGoalsUsuSearch + _totalGoalsHome;
			
		ELSEIF _IDTimeHome = pIdTimeHome THEN
			
			SET _totalGoalsUsuLogged = _totalGoalsUsuLogged + _totalGoalsHome;
			SET _totalGoalsUsuSearch = _totalGoalsUsuSearch + _totalGoalsAway;
			
			IF _totalGoalsHome > _totalGoalsAway THEN
			
				SET _totalWinUsuLogged = _totalWinUsuLogged + 1;
			
			ELSE
			
				SET _totalWinUsuSearch = _totalWinUsuSearch + 1;
			
			END IF;
			

		ELSEIF _IDTimeHome = pIdTimeAway THEN
			
			SET _totalGoalsUsuLogged = _totalGoalsUsuLogged + _totalGoalsAway;
			SET _totalGoalsUsuSearch = _totalGoalsUsuSearch + _totalGoalsHome;
			
			IF _totalGoalsHome > _totalGoalsAway THEN
			
				SET _totalWinUsuSearch = _totalWinUsuSearch + 1;
			
			ELSE
			
				SET _totalWinUsuLogged = _totalWinUsuLogged + 1;
			
			END IF;
			
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
		
	SELECT _totalWinUsuLogged as totalWinUsuLogged, _totalWinUsuSearch as totalWinUsuSearch, _totalDraw as totalDraw, _totalLossUsuLogged as totalLossUsuLogged, 
	      _totalLossUsuSearch as totalLossUsuSearch, _totalGoalsUsuLogged as totalGoalsUsuLogged, _totalGoalsUsuSearch as totalGoalsUsuSearch, _nmTimeHome as nmTimeHome,
		  _nmTimeAway as nmTimeAway;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllClashesHistoryByTeams` $$
CREATE PROCEDURE `spGetAllClashesHistoryByTeams`(pType VARCHAR(3), pIdTimeHome INTEGER, pIdTimeAway INTEGER)
begin      
	SELECT T.NM_TEMPORADA, C.ID_Campeonato, C.NM_Campeonato, TU1.NM_Usuario as NM1, TU1.PSN_ID as PSN1, TU2.NM_Usuario as NM2, TU2.PSN_ID as PSN2, J.IN_JOGO_MATAXMATA, 
	      J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, J.ID_FASE, J.DT_TABELA_INICIO_JOGO, J.ID_TABELA_JOGO, J.DT_TABELA_FIM_JOGO, J.DT_EFETIVACAO_JOGO,
		  J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, F.NM_Fase, J.ID_USUARIO_TIME_CASA, J.ID_USUARIO_TIME_VISITANTE, J.IN_NUMERO_RODADA, 0 as ID_GRUPO, "" as NM_GRUPO,
		  "" as DS_URL1, "" as DS_URL2, T1.DS_Tipo as DT1, T2.DS_Tipo as DT2, TU1.PSN_ID as NM_Tecnico_TimeCasa, TU2.PSN_ID as NM_Tecnico_TimeVisitante
	FROM TB_TABELA_JOGO J, TB_TIME T1 , TB_TIME T2, TB_USUARIO TU1, TB_USUARIO TU2, TB_Temporada T, TB_Campeonato C, TB_Fase F 
	WHERE (J.ID_TIME_CASA = pIdTimeHome OR J.ID_TIME_CASA = pIdTimeAway)
	  AND (J.ID_TIME_VISITANTE = pIdTimeHome OR J.ID_TIME_VISITANTE = pIdTimeAway)
	  AND J.QT_GOLS_TIME_CASA IS NOT NULL
	  AND FIND_IN_SET(C.SG_TIPO_CAMPEONATO,fcGetAllSiglaByMode(pType))
	  AND J.ID_CAMPEONATO = C.ID_CAMPEONATO AND J.ID_TIME_CASA = T1.ID_TIME
	  AND J.ID_TIME_VISITANTE = T2.ID_TIME
	  AND J.ID_USUARIO_TIME_CASA = TU1.ID_USUARIO
	  AND J.ID_USUARIO_TIME_VISITANTE = TU2.ID_USUARIO
	  AND J.ID_FASE = F.ID_FASE
	  AND C.ID_TEMPORADA = T.ID_TEMPORADA

	UNION ALL

	SELECT T.NM_TEMPORADA, C.ID_Campeonato, C.NM_Campeonato, TU1.NM_Usuario as NM1, TU1.PSN_ID as PSN1, TU2.NM_Usuario as NM2, TU2.PSN_ID as PSN2, J.IN_JOGO_MATAXMATA, 
	      J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, J.ID_FASE, J.DT_TABELA_INICIO_JOGO, J.ID_TABELA_JOGO, J.DT_TABELA_FIM_JOGO, J.DT_EFETIVACAO_JOGO,
		  J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, F.NM_Fase, J.ID_USUARIO_TIME_CASA, J.ID_USUARIO_TIME_VISITANTE, J.IN_NUMERO_RODADA, 0 as ID_GRUPO, "" as NM_GRUPO,
		  "" as DS_URL1, "" as DS_URL2, T1.DS_Tipo as DT1, T2.DS_Tipo as DT2, TU1.PSN_ID as NM_Tecnico_TimeCasa, TU2.PSN_ID as NM_Tecnico_TimeVisitante
	FROM arena_clashes.TB_TABELA_JOGO J, arena_clashes.TB_TIME T1 , arena_clashes.TB_TIME T2, arena_clashes.TB_USUARIO TU1, arena_clashes.TB_USUARIO TU2, 
	     arena_clashes.TB_Temporada T, arena_clashes.TB_Campeonato C, TB_Fase F 
	WHERE (J.ID_TIME_CASA = pIdTimeHome OR J.ID_TIME_CASA = pIdTimeAway)
	  AND (J.ID_TIME_VISITANTE = pIdTimeHome OR J.ID_TIME_VISITANTE = pIdTimeAway)
	  AND J.QT_GOLS_TIME_CASA IS NOT NULL
	  AND FIND_IN_SET(C.SG_TIPO_CAMPEONATO,fcGetAllSiglaByMode(pType))
	  AND J.ID_CAMPEONATO = C.ID_CAMPEONATO AND J.ID_TIME_CASA = T1.ID_TIME
	  AND J.ID_TIME_VISITANTE = T2.ID_TIME
	  AND J.ID_USUARIO_TIME_CASA = TU1.ID_USUARIO
	  AND J.ID_USUARIO_TIME_VISITANTE = TU2.ID_USUARIO
	  AND J.ID_FASE = F.ID_FASE
	  AND C.ID_TEMPORADA = T.ID_TEMPORADA

	  ORDER BY ID_Campeonato, ID_Fase, DT_TABELA_INICIO_JOGO;
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllClashesHistory` $$
CREATE PROCEDURE `spGetAllClashesHistory`(pType VARCHAR(3), pIdUsuLogged INTEGER, pIdUsuSearch INTEGER)
begin      
	SELECT T.NM_TEMPORADA, C.ID_Campeonato, C.NM_Campeonato, TU1.NM_Usuario as NM1, TU1.PSN_ID as PSN1, TU2.NM_Usuario as NM2, TU2.PSN_ID as PSN2, J.IN_JOGO_MATAXMATA, 
	      J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, J.ID_FASE, J.DT_TABELA_INICIO_JOGO, J.ID_TABELA_JOGO, J.DT_TABELA_FIM_JOGO, J.DT_EFETIVACAO_JOGO,
		  J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, F.NM_Fase, J.ID_USUARIO_TIME_CASA, J.ID_USUARIO_TIME_VISITANTE, J.IN_NUMERO_RODADA, 0 as ID_GRUPO, "" as NM_GRUPO,
		  "" as DS_URL1, "" as DS_URL2, T1.DS_Tipo as DT1, T2.DS_Tipo as DT2, TU1.PSN_ID as NM_Tecnico_TimeCasa, TU2.PSN_ID as NM_Tecnico_TimeVisitante
	FROM TB_TABELA_JOGO J, TB_TIME T1 , TB_TIME T2, TB_USUARIO TU1, TB_USUARIO TU2, TB_Temporada T, TB_Campeonato C, TB_Fase F 
	WHERE (J.ID_USUARIO_TIME_CASA = pIdUsuLogged OR J.ID_USUARIO_TIME_CASA = pIdUsuSearch)
	  AND (J.ID_USUARIO_TIME_VISITANTE = pIdUsuLogged OR J.ID_USUARIO_TIME_VISITANTE = pIdUsuSearch)
	  AND J.QT_GOLS_TIME_CASA IS NOT NULL
	  AND FIND_IN_SET(C.SG_TIPO_CAMPEONATO,fcGetAllSiglaByMode(pType))
	  AND J.ID_CAMPEONATO = C.ID_CAMPEONATO AND J.ID_TIME_CASA = T1.ID_TIME
	  AND J.ID_TIME_VISITANTE = T2.ID_TIME
	  AND J.ID_USUARIO_TIME_CASA = TU1.ID_USUARIO
	  AND J.ID_USUARIO_TIME_VISITANTE = TU2.ID_USUARIO
	  AND J.ID_FASE = F.ID_FASE
	  AND C.ID_TEMPORADA = T.ID_TEMPORADA

	UNION ALL

	SELECT T.NM_TEMPORADA, C.ID_Campeonato, C.NM_Campeonato, TU1.NM_Usuario as NM1, TU1.PSN_ID as PSN1, TU2.NM_Usuario as NM2, TU2.PSN_ID as PSN2, J.IN_JOGO_MATAXMATA, 
	      J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, J.ID_FASE, J.DT_TABELA_INICIO_JOGO, J.ID_TABELA_JOGO, J.DT_TABELA_FIM_JOGO, J.DT_EFETIVACAO_JOGO,
		  J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, F.NM_Fase, J.ID_USUARIO_TIME_CASA, J.ID_USUARIO_TIME_VISITANTE, J.IN_NUMERO_RODADA, 0 as ID_GRUPO, "" as NM_GRUPO,
		  "" as DS_URL1, "" as DS_URL2, T1.DS_Tipo as DT1, T2.DS_Tipo as DT2, TU1.PSN_ID as NM_Tecnico_TimeCasa, TU2.PSN_ID as NM_Tecnico_TimeVisitante
	FROM arena_clashes.TB_TABELA_JOGO J, arena_clashes.TB_TIME T1 , arena_clashes.TB_TIME T2, arena_clashes.TB_USUARIO TU1, arena_clashes.TB_USUARIO TU2, 
	     arena_clashes.TB_Temporada T, arena_clashes.TB_Campeonato C, TB_Fase F 
	WHERE (J.ID_USUARIO_TIME_CASA = pIdUsuLogged OR J.ID_USUARIO_TIME_CASA = pIdUsuSearch)
	  AND (J.ID_USUARIO_TIME_VISITANTE = pIdUsuLogged OR J.ID_USUARIO_TIME_VISITANTE = pIdUsuSearch)
	  AND J.QT_GOLS_TIME_CASA IS NOT NULL
	  AND FIND_IN_SET(C.SG_TIPO_CAMPEONATO,fcGetAllSiglaByMode(pType))
	  AND J.ID_CAMPEONATO = C.ID_CAMPEONATO AND J.ID_TIME_CASA = T1.ID_TIME
	  AND J.ID_TIME_VISITANTE = T2.ID_TIME
	  AND J.ID_USUARIO_TIME_CASA = TU1.ID_USUARIO
	  AND J.ID_USUARIO_TIME_VISITANTE = TU2.ID_USUARIO
	  AND J.ID_FASE = F.ID_FASE
	  AND C.ID_TEMPORADA = T.ID_TEMPORADA

	  ORDER BY ID_Campeonato, ID_Fase, DT_TABELA_INICIO_JOGO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetTabelaJogoAllDetailsForLineUp` $$
CREATE PROCEDURE `spGetTabelaJogoAllDetailsForLineUp`(pIdCamp INTEGER, pIdFase INTEGER )
Begin
	SELECT TU1.PSN_ID as PSN1, TU2.PSN_ID as PSN2, J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T
	FROM TB_TABELA_JOGO J, TB_TIME T1, TB_TIME T2
	WHERE J.ID_CAMPEONATO = pIdCamp
	  AND J.ID_FASE = pIdFase
	  AND J.IN_NUMERO_RODADA = 1
	  AND J.ID_TIME_CASA = T1.ID_TIME
	  AND J.ID_TIME_VISITANTE = T2.ID_TIME
	  ORDER BY IN_JOGO_MATAXMATA, J.ID_TABELA_JOGO;
End$$
DELIMITER ;



DROP TABLE IF EXISTS `TB_TEMP_MATCHES_BY_TEAM`;

CREATE TABLE `arenafifadb`.`TB_TEMP_MATCHES_BY_TEAM` (
  `ID_USUARIO` INTEGER NOT NULL DEFAULT 0, 
  `ID_CAMPEONATO` INTEGER NOT NULL DEFAULT 0, 
  `ID_TIME` INTEGER NOT NULL DEFAULT 0, 
  `NM_TIME` VARCHAR(50) NOT NULL DEFAULT "", 
  INDEX (`ID_CAMPEONATO`, `ID_TIME`), 
  PRIMARY KEY (`ID_USUARIO`, `ID_CAMPEONATO`, `ID_TIME`)
);

DROP TABLE IF EXISTS `TB_TEMP_MATCHES_DETAILS_BY_TEAM`;

CREATE TABLE `arenafifadb`.`TB_TEMP_MATCHES_DETAILS_BY_TEAM` (
  `ID_USUARIO` INTEGER NOT NULL DEFAULT 0, 
  `ID_CAMPEONATO` INTEGER NOT NULL DEFAULT 0, 
  `ID_TIME` INTEGER NOT NULL DEFAULT 0, 
  `ID_ROUND` INTEGER NOT NULL DEFAULT 0, 
  `ID_TIME_NEXT_MATCH` INTEGER NULL DEFAULT 0, 
  `NM_TIME_NEXT_MATCH` VARCHAR(50) NULL DEFAULT 0, 
  `DS_MATCTH_1` VARCHAR(50) NULL DEFAULT NULL, 
  `DS_MATCTH_2` VARCHAR(50) NULL DEFAULT NULL, 
  `DS_MATCTH_3` VARCHAR(50) NULL DEFAULT NULL, 
  `DS_MATCTH_4` VARCHAR(50) NULL DEFAULT NULL, 
  `STATUS_MATCTH` CHAR(1) NULL DEFAULT NULL, 
  INDEX (`ID_USUARIO`, `ID_CAMPEONATO`, `ID_TIME`), 
  PRIMARY KEY (`ID_USUARIO`, `ID_CAMPEONATO`, `ID_TIME`, `ID_ROUND`)
);



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetDetailsMatchesByTimeFromCampeonato` $$
CREATE PROCEDURE `spGetDetailsMatchesByTimeFromCampeonato`(pIdCamp INTEGER, pIdUsu INTEGER )
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _finished_2 INTEGER DEFAULT 0;
	DECLARE _count INTEGER DEFAULT 0;
	DECLARE _idTime INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR
		SELECT T.ID_TIME FROM TB_CAMPEONATO_TIME C, TB_TIME T 
		WHERE ID_CAMPEONATO = pIdCamp
		 AND C.ID_TIME = T.ID_TIME ORDER BY C.ID_TIME;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	DELETE FROM TB_TEMP_MATCHES_BY_TEAM WHERE ID_USUARIO = pIdUsu;
	DELETE FROM TB_TEMP_MATCHES_DETAILS_BY_TEAM WHERE ID_USUARIO = pIdUsu;
	
	INSERT INTO TB_TEMP_MATCHES_BY_TEAM (ID_USUARIO, ID_CAMPEONATO, ID_TIME, NM_TIME)
	(SELECT pIdUsu, C.ID_CAMPEONATO, T.ID_TIME, T.NM_TIME FROM TB_CAMPEONATO_TIME C, TB_TIME T 
	 WHERE ID_CAMPEONATO = pIdCamp
	   AND C.ID_TIME = T.ID_TIME);
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idTime;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		INSERT INTO TB_TEMP_MATCHES_DETAILS_BY_TEAM (ID_USUARIO, ID_CAMPEONATO, ID_TIME, ID_ROUND, ID_TIME_NEXT_MATCH, NM_TIME_NEXT_MATCH, DS_MATCTH_1)
		(SELECT pIdUsu, J.ID_CAMPEONATO, _idTime, 0, IF (J.ID_TIME_CASA = _idTime, J.ID_TIME_VISITANTE, J.ID_TIME_CASA), 
				IF (J.ID_TIME_CASA = _idTime, T2.NM_TIME, T1.NM_TIME) as NM_NEXT_TIME,
		        CONCAT("Rodada ",J.IN_NUMERO_RODADA, " - ", DATE_FORMAT(J.DT_TABELA_INICIO_JOGO,'%d/%m'), " à ", DATE_FORMAT(J.DT_TABELA_FIM_JOGO,'%d/%m'))
			FROM TB_TABELA_JOGO J, TB_TIME T1, TB_TIME T2
			WHERE J.ID_CAMPEONATO = pIdCamp
			  AND (J.ID_TIME_CASA = _idTime OR J.ID_TIME_VISITANTE = _idTime)
			  AND J.QT_GOLS_TIME_CASA IS NULL
			  AND J.ID_TIME_CASA = T1.ID_TIME
			  AND J.ID_TIME_VISITANTE = T2.ID_TIME 
			ORDER BY J.IN_NUMERO_RODADA LIMIT 1);
		
		INSERT INTO TB_TEMP_MATCHES_DETAILS_BY_TEAM (ID_USUARIO, ID_CAMPEONATO, ID_TIME, ID_ROUND, DS_MATCTH_1, DS_MATCTH_2, DS_MATCTH_3, DS_MATCTH_4, STATUS_MATCTH)
		(SELECT pIdUsu, J.ID_CAMPEONATO, _idTime, @curRow := @curRow + 1 AS "ID_ROUND", 
				CONCAT("Rodada ", J.IN_NUMERO_RODADA, " - ", DATE_FORMAT(J.DT_TABELA_INICIO_JOGO,'%d/%m'), " à ", DATE_FORMAT(J.DT_TABELA_FIM_JOGO,'%d/%m')) as DS_MATCTH_1,
				T1.NM_TIME as DS_MATCTH_2,
				CONCAT(J.QT_GOLS_TIME_CASA, " - ", J.QT_GOLS_TIME_VISITANTE) as DS_MATCTH_3,
				T2.NM_TIME as DS_MATCTH_4,
				IF (J.QT_GOLS_TIME_CASA=J.QT_GOLS_TIME_VISITANTE, "E", IF (_idTime=J.ID_TIME_CASA AND J.QT_GOLS_TIME_CASA > J.QT_GOLS_TIME_VISITANTE, "V", IF (_idTime=J.ID_TIME_CASA AND J.QT_GOLS_TIME_CASA < J.QT_GOLS_TIME_VISITANTE, "D", IF(_idTime=J.ID_TIME_VISITANTE AND J.QT_GOLS_TIME_CASA < J.QT_GOLS_TIME_VISITANTE, "V", IF(_idTime=J.ID_TIME_VISITANTE AND J.QT_GOLS_TIME_CASA > J.QT_GOLS_TIME_VISITANTE, "D", ""))))) as STATUS_MATCTH
			FROM TB_TABELA_JOGO J, TB_TIME T1, TB_TIME T2, (SELECT @curRow :=0) r
			WHERE J.ID_CAMPEONATO = pIdCamp
			  AND J.ID_FASE = 0
			  AND (J.ID_TIME_CASA = _idTime OR J.ID_TIME_VISITANTE = _idTime)
			  AND J.QT_GOLS_TIME_CASA IS NOT NULL
			  AND J.ID_TIME_CASA = T1.ID_TIME
			  AND J.ID_TIME_VISITANTE = T2.ID_TIME 
			ORDER BY J.IN_NUMERO_RODADA DESC LIMIT 3);

		#call `arenafifadb`.`spUpdatePreviousMatchDetailsByTimeFromCampeonato`(pIdCamp, pIdUsu, _idTime);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	SELECT TD.*, TM.NM_TIME
	FROM TB_TEMP_MATCHES_BY_TEAM TM, TB_TEMP_MATCHES_DETAILS_BY_TEAM TD
	WHERE TM.ID_USUARIO = pIdUsu
	  AND TM.ID_CAMPEONATO = pIdCamp
	  AND TM.ID_USUARIO = TD.ID_USUARIO
	  AND TM.ID_CAMPEONATO = TD.ID_CAMPEONATO
	  AND TM.ID_TIME = TD.ID_TIME
	  ORDER BY TD.ID_USUARIO, TD.ID_CAMPEONATO, TD.ID_TIME, TD.ID_ROUND;

End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdatePreviousMatchDetailsByTimeFromCampeonato` $$
CREATE PROCEDURE `spUpdatePreviousMatchDetailsByTimeFromCampeonato`(pIdCamp INTEGER, pIdUsu INTEGER, pIdTime INTEGER )
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _count INTEGER DEFAULT 0;
	DECLARE _round INTEGER DEFAULT 0;
	DECLARE _startDate DATE DEFAULT NULL;
	DECLARE _endDate DATE DEFAULT NULL;
	DECLARE _idTimeHome INTEGER DEFAULT 0;
	DECLARE _idTimeAway INTEGER DEFAULT 0;
	DECLARE _nmTimeHome VARCHAR(50) DEFAULT "";
	DECLARE _nmTimeAway VARCHAR(50) DEFAULT "";
	DECLARE _description1 VARCHAR(50) DEFAULT "";
	DECLARE _description3 VARCHAR(50) DEFAULT "";
	DECLARE _status CHAR(1) DEFAULT "";
	DECLARE _totalGoalsHome INTEGER DEFAULT 0;
	DECLARE _totalGoalsAway INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT T1.NM_TIME as NM_TIME_CASA, T2.NM_TIME as NM_TIME_VISITANTE,
			  CONCAT("Rodada ", J.IN_NUMERO_RODADA, " - ", DATE_FORMAT(J.DT_TABELA_INICIO_JOGO,'%d/%m'), " à ", DATE_FORMAT(J.DT_TABELA_FIM_JOGO,'%d/%m')) as round_result,
			  CONCAT(J.QT_GOLS_TIME_CASA, " - ", J.QT_GOLS_TIME_VISITANTE) as match_result,
			  IF (J.QT_GOLS_TIME_CASA=J.QT_GOLS_TIME_VISITANTE, "D", IF (pIdTime=J.ID_TIME_CASA AND J.QT_GOLS_TIME_CASA > J.QT_GOLS_TIME_VISITANTE, "V", IF (pIdTime=J.ID_TIME_CASA AND J.QT_GOLS_TIME_CASA < J.QT_GOLS_TIME_VISITANTE, "D", IF(pIdTime=J.ID_TIME_VISITANTE AND J.QT_GOLS_TIME_CASA < J.QT_GOLS_TIME_VISITANTE, "V", IF(pIdTime=J.ID_TIME_VISITANTE AND J.QT_GOLS_TIME_CASA > J.QT_GOLS_TIME_VISITANTE, "D", ""))))) as status_result
		FROM TB_TABELA_JOGO J, TB_TIME T1, TB_TIME T2
		WHERE J.ID_CAMPEONATO = pIdCamp
		  AND J.ID_FASE = 0
		  AND (J.ID_TIME_CASA = pIdTime OR J.ID_TIME_VISITANTE = pIdTime)
		  AND J.QT_GOLS_TIME_CASA IS NOT NULL
		  AND J.ID_TIME_CASA = T1.ID_TIME
		  AND J.ID_TIME_VISITANTE = T2.ID_TIME 
		ORDER BY J.IN_NUMERO_RODADA DESC LIMIT 3;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	SET _count = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO  _nmTimeHome, _nmTimeAway, _description1, _description3, _status;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _count = 1 THEN

			UPDATE TB_TEMP_MATCHES_BY_TEAM
			  SET DS_PREVIOUS_MATCTH_1_1 = _description1, 
				  DS_PREVIOUS_MATCTH_1_2 = _nmTimeHome, 
				  DS_PREVIOUS_MATCTH_1_3 = _description3,
				  DS_PREVIOUS_MATCTH_1_4 = _nmTimeAway,
				  STATUS_PREVIOUS_MATCTH_1 = _status
			WHERE ID_USUARIO = pIdUsu
			  AND ID_CAMPEONATO = pIdCamp
			  AND ID_TIME = pIdTime;

		ELSEIF _count = 2 THEN

			UPDATE TB_TEMP_MATCHES_BY_TEAM
			  SET DS_PREVIOUS_MATCTH_2_1 = _description1, 
				  DS_PREVIOUS_MATCTH_2_2 = _nmTimeHome, 
				  DS_PREVIOUS_MATCTH_2_3 = _description3,
				  DS_PREVIOUS_MATCTH_2_4 = _nmTimeAway,
				  STATUS_PREVIOUS_MATCTH_2 = _status
			WHERE ID_USUARIO = pIdUsu
			  AND ID_CAMPEONATO = pIdCamp
			  AND ID_TIME = pIdTime;

		ELSEIF _count = 3 THEN

			UPDATE TB_TEMP_MATCHES_BY_TEAM
			  SET DS_PREVIOUS_MATCTH_3_1 = _description1, 
				  DS_PREVIOUS_MATCTH_3_2 = _nmTimeHome, 
				  DS_PREVIOUS_MATCTH_3_3 = _description3,
				  DS_PREVIOUS_MATCTH_3_4 = _nmTimeAway,
				  STATUS_PREVIOUS_MATCTH_3 = _status
			WHERE ID_USUARIO = pIdUsu
			  AND ID_CAMPEONATO = pIdCamp
			  AND ID_TIME = pIdTime;

		END IF;
		
		SET _count = _count + 1;

	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;
