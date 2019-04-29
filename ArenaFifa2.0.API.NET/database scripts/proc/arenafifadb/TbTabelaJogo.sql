USE `arenafifadb`;

ALTER TABLE TB_TABELA_JOGO MODIFY DT_TABELA_INICIO_JOGO DATE;
ALTER TABLE TB_TABELA_JOGO MODIFY DT_TABELA_FIM_JOGO DATE;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllTabelaJogoOfCampeonato` $$
CREATE PROCEDURE `spDeleteAllTabelaJogoOfCampeonato`(pIdCamp INTEGER)
Begin
    delete from `TB_TABELA_JOGO` 
	where ID_CAMPEONATO = pIdCamp;
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
	pIdaVolta TINYINT
)
Begin
	DECLARE _inNumRodIda INTEGER DEFAULT 1;
	DECLARE _inNumRodVolta INTEGER DEFAULT 2;
	DECLARE _count INTEGER DEFAULT NULL;
	DECLARE _dtFim DATE DEFAULT NULL;
	DECLARE _dtInicioVolta DATE DEFAULT NULL;
	DECLARE _dtFimVolta DATE DEFAULT NULL;
	
	IF pIdaVolta = true THEN
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
	
	IF (ISNULL(_idFase,-10) = -10) THEN 

		select ID_FASE into _idFase
		from TB_TABELA_JOGO
		where DT_EFETIVACAO_JOGO is not null order by ID_FASE desc limit 1;
		
		IF (ISNULL(_idFase,-10) = -10) THEN
			_idFase = 0
		END IF;
		
	END IF;

    select _idFase as IdCurrentFase;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllFasesOfTabelaJogo` $$
CREATE PROCEDURE `spGetTabelaJogoAllFases`(pIdCamp INTEGER)
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
DROP PROCEDURE IF EXISTS `spGetTabelaJogoAllDetailsOfCampeonatoFase` $$
CREATE PROCEDURE `spGetTabelaJogoAllDetailsOfCampeonatoFase`(
	pIdCamp INTEGER,
	pIdFase INTEGER,
	pIdGrupo INTEGER,
	pNumRodada INTEGER
)
Begin

	IF (pIdGrupo > 0) THEN 
	
		select IN_NUMERO_RODADA, ID_TABELA_JOGO, T1.DS_URL_TIME as DS_URL1, T2.DS_URL_TIME as DS_URL2, DATE_FORMAT(J.DT_TABELA_INICIO_JOGO,'%d/%m/%Y') as DJ, J.DT_EFETIVACAO_JOGO,
		J.DS_HORA_JOGO as HJ, J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, DATE_FORMAT(J.DT_TABELA_INICIO_JOGO,'%d/%m') as DJ2, 
		T1.IN_TIME_COM_IMAGEM as IMG1, T2.IN_TIME_COM_IMAGEM as IMG2, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, TU1.PSN_ID as PSN1, TU2.PSN_ID as PSN2, 
		T1.DS_Tipo as DT1, T2.DS_Tipo as DT2, DATE_FORMAT(J.DT_TABELA_FIM_JOGO,'%d/%m/%Y') as DF, J.IN_JOGO_MATAXMATA,
		(select USU.PSN_ID from TB_USUARIO USU where USU.ID_Usuario = J.ID_USUARIO_TIME_CASA) as NM_Tecnico_TimeCasa,
		(SELECT USU.PSN_ID FROM TB_USUARIO USU WHERE USU.ID_Usuario = J.ID_USUARIO_TIME_VISITANTE) as NM_Tecnico_TimeVisitante
		from TB_TABELA_JOGO J, TB_TIME T1 , TB_TIME T2, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2, TB_USUARIO TU1, TB_USUARIO TU2, TB_CLASSIFICACAO TC1, TB_CLASSIFICACAO TC2
		where J.ID_CAMPEONATO = pIdCamp
		and J.ID_FASE = pIdFase
		and J.IN_NUMERO_RODADA = pNumRodada
		and UT1.DT_VIGENCIA_FIM is null  
		and UT2.DT_VIGENCIA_FIM is null  
		and TC1.ID_Grupo =  pIdGrupo 
		and TC2.ID_Grupo =  pIdGrupo
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
		order by J.DT_TABELA_INICIO_JOGO, J.DS_HORA_JOGO, J.ID_TABELA_JOGO;
		
	ELSE
		
		select IN_NUMERO_RODADA, ID_TABELA_JOGO, T1.DS_URL_TIME as DS_URL1, T2.DS_URL_TIME as DS_URL2, DATE_FORMAT(J.DT_TABELA_INICIO_JOGO,'%d/%m/%Y') as DJ, J.DT_EFETIVACAO_JOGO,
		J.DS_HORA_JOGO as HJ, J.ID_TIME_CASA, J.ID_TIME_VISITANTE, T1.NM_TIME as 1T, T2.NM_TIME as 2T, DATE_FORMAT(J.DT_TABELA_INICIO_JOGO,'%d/%m') as DJ2, 
		T1.IN_TIME_COM_IMAGEM as IMG1, T2.IN_TIME_COM_IMAGEM as IMG2, J.QT_GOLS_TIME_CASA, J.QT_GOLS_TIME_VISITANTE, TU1.PSN_ID as PSN1, TU2.PSN_ID as PSN2, 
		T1.DS_Tipo as DT1, T2.DS_Tipo as DT2, DATE_FORMAT(J.DT_TABELA_FIM_JOGO,'%d/%m/%Y') as DF, J.IN_JOGO_MATAXMATA,
		(select USU.PSN_ID from TB_USUARIO USU where USU.ID_Usuario = J.ID_USUARIO_TIME_CASA) as NM_Tecnico_TimeCasa,
		(SELECT USU.PSN_ID FROM TB_USUARIO USU WHERE USU.ID_Usuario = J.ID_USUARIO_TIME_VISITANTE) as NM_Tecnico_TimeVisitante
		from TB_TABELA_JOGO J, TB_TIME T1 , TB_TIME T2, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2, TB_USUARIO TU1, TB_USUARIO TU2
		where J.ID_CAMPEONATO = pIdCamp
		and J.ID_FASE = pIdFase
		and J.IN_NUMERO_RODADA = pNumRodada
		and UT1.DT_VIGENCIA_FIM is null  
		and UT2.DT_VIGENCIA_FIM is null
		and J.ID_TIME_CASA = T1.ID_TIME  
		and J.ID_TIME_VISITANTE = T2.ID_TIME  
		and T1.ID_TIME = UT1.ID_TIME  
		and T2.ID_TIME = UT2.ID_TIME  
		and UT1.ID_USUARIO = TU1.ID_USUARIO  
		and UT2.ID_USUARIO = TU2.ID_USUARIO  
		and UT1.ID_CAMPEONATO = J.ID_CAMPEONATO  
		and UT2.ID_CAMPEONATO = J.ID_CAMPEONATO  
		order by J.DT_TABELA_INICIO_JOGO, J.DS_HORA_JOGO, J.ID_TABELA_JOGO;
	
	END IF;

End$$
DELIMITER ;
