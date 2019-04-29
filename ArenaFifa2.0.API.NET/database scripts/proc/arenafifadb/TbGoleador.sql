USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllGoleadorOfTime` $$
CREATE PROCEDURE `spGetAllGoleadorOfTime`(pIdTime INTEGER)
begin      
   select *
   from TB_GOLEADOR
   where ID_TIME = pIdTime
   order by NM_GOLEADOR;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetGoleador` $$
CREATE PROCEDURE `spGetGoleador`(pIdTime INTEGER, pIdGoleador INTEGER)
begin      
   select *
   from TB_GOLEADOR
   where ID_TIME = pIdTime
   and ID_GOLEADOR = pIdGoleador;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetGoleadorByGoleador` $$
CREATE PROCEDURE `spGetGoleadorByGoleador`(pIdGoleador INTEGER)
begin      
   select G.*, T.NM_TIME, DATE_FORMAT(G.DT_INSCRICAO,'%d/%m/%Y') as DT_FORMATADA
   from TB_GOLEADOR G, TB_TIME T
   where ID_GOLEADOR = pIdGoleador
   and G.ID_TIME = T.ID_TIME;
End$$
DELIMITER ;



DELIMITER $$
DROP FUNCTION IF EXISTS `spGetMaxIdGoleador` $$
CREATE FUNCTION `spGetMaxIdGoleador`() RETURNS INTEGER
	DETERMINISTIC
begin
	DECLARE _maxID INTEGER DEFAULT NULL;
	
	select ID_GOLEADOR into _maxID
    from TB_GOLEADOR
	order by ID_GOLEADOR desc
	limit 1;
	
	IF (_maxID IS NULL) THEN
	
		SET _maxID = 999000;
	
	ELSE
	
		SET _maxID = _maxID + 1;
	
	END IF;
	
	RETURN _maxID;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetGoleadorGolsOfTime` $$
CREATE PROCEDURE `spGetGoleadorGolsOfTime`(pIdJogo INTEGER, pIdTime INTEGER)
begin      
   select G.*, GJ.QT_GOLS FROM TB_GOLEADOR G, TB_GOLEADOR_JOGO GJ WHERE G.ID_GOLEADOR = GJ.ID_GOLEADOR AND GJ.ID_TABELA_JOGO = pIdJogo AND GJ.ID_TIME = pIdTime AND G.ID_GOLEADOR = 0
   union all
   select G.*, GJ.QT_GOLS FROM TB_GOLEADOR G, TB_GOLEADOR_JOGO GJ WHERE G.ID_GOLEADOR = GJ.ID_GOLEADOR AND G.ID_TIME = GJ.ID_TIME AND GJ.ID_TABELA_JOGO = pIdJogo AND G.ID_TIME = pIdTime AND G.ID_GOLEADOR > 0;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllGoleadoresWithFilterCRUDH2H` $$
CREATE PROCEDURE `spGetAllGoleadoresWithFilterCRUDH2H`(pFilter VARCHAR(20))
begin      
   select G.*, T.NM_TIME, P.NM_TIPO_TIME
   from TB_GOLEADOR G, TB_TIME T, TB_TIPO_TIME P
   where (G.NM_Goleador like CONCAT('%',pFilter,'%') or G.NM_GOLEADOR_COMPLETO like CONCAT('%',pFilter,'%') or T.NM_TIME like CONCAT('%',pFilter,'%') or P.NM_TIPO_TIME like CONCAT('%',pFilter,'%'))
   and T.ID_TIPO_TIME  NOT IN (37,39,40,41,42)
   and G.ID_TIME = T.ID_TIME
   and T.ID_TIPO_TIME = P.ID_TIPO_TIME
   order by G.NM_GOLEADOR, T.NM_TIME;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllGoleadoresNoFilterCRUDH2H` $$
CREATE PROCEDURE `spGetAllGoleadoresNoFilterCRUDH2H`()
begin      
   select G.*, T.NM_TIME, P.NM_TIPO_TIME
   from TB_GOLEADOR G, TB_TIME T, TB_TIPO_TIME P
   where T.ID_TIPO_TIME  NOT IN (37,39,40,41,42)
   and G.ID_TIME = T.ID_TIME
   and T.ID_TIPO_TIME = P.ID_TIPO_TIME
   order by G.NM_GOLEADOR, T.NM_TIME;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllGoleadoresWithFilterCRUDFUT` $$
CREATE PROCEDURE `spGetAllGoleadoresWithFilterCRUDFUT`(pFilter VARCHAR(20))
begin      
   select G.*, T.NM_Time, U.PSN_ID as PSN_MANAGER, U.NM_USUARIO as NM_MANAGER
   from TB_GOLEADOR G, TB_TIME T, TB_USUARIO U
   where (G.NM_Goleador like CONCAT('%',pFilter,'%') or G.NM_GOLEADOR_COMPLETO like CONCAT('%',pFilter,'%') or T.NM_TIME like CONCAT('%',pFilter,'%') or U.NM_USUARIO like CONCAT('%',pFilter,'%') or U.PSN_ID like CONCAT('%',pFilter,'%'))
   and T.ID_TIPO_TIME = 42
   and G.ID_TIME = T.ID_TIME
   and T.ID_TECNICO_FUT = U.ID_USUARIO
   order by G.NM_GOLEADOR, T.NM_TIME;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllGoleadoresNoFilterCRUDFUT` $$
CREATE PROCEDURE `spGetAllGoleadoresNoFilterCRUDFUT`()
begin      
   select G.*, T.NM_Time, U.PSN_ID as PSN_MANAGER, U.NM_USUARIO as NM_MANAGER
   from TB_GOLEADOR G, TB_TIME T, TB_USUARIO U
   where T.ID_TIPO_TIME = 42
   and G.ID_TIME = T.ID_TIME
   and T.ID_TECNICO_FUT = U.ID_USUARIO
   order by G.NM_GOLEADOR, T.NM_TIME;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllUsuariosByDetailsGoleadorCRUD` $$
CREATE PROCEDURE `spGetAllUsuariosByDetailsGoleadorCRUD`(pAcao VARCHAR(15), pIdUsu INTEGER)
begin

	IF (pacao='INCLUDE_RECORD') THEN
	
		SELECT U.ID_USUARIO, U.PSN_ID, U.NM_USUARIO
		FROM TB_USUARIO U 
		WHERE U.IN_USUARIO_ATIVO = True AND U.IN_DESEJA_PARTICIPAR = 1 
		AND NOT EXISTS (SELECT G.ID_USUARIO FROM TB_GOLEADOR G WHERE G.ID_USUARIO IS NOT NULL AND G.ID_USUARIO = U.ID_USUARIO) ORDER BY PSN_ID;
	
	ELSEIF (pacao='RECORD_DETAILS') THEN
	
		SELECT U.ID_USUARIO, U.PSN_ID, U.NM_USUARIO FROM TB_USUARIO U WHERE U.ID_USUARIO = pIdUsu;
	
	ELSE
	
		SELECT U.ID_USUARIO, U.PSN_ID, U.NM_USUARIO 
		FROM TB_USUARIO U 
		WHERE U.IN_USUARIO_ATIVO = True AND U.IN_DESEJA_PARTICIPAR = 1 
		AND (NOT EXISTS (SELECT G.ID_USUARIO FROM TB_GOLEADOR G WHERE G.ID_USUARIO IS NOT NULL AND G.ID_USUARIO = U.ID_USUARIO) OR ID_USUARIO = pIdUsu) ORDER BY PSN_ID;
	
	END IF;

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeteleGoleador` $$
CREATE PROCEDURE `spDeteleGoleador`(pIdGoleador INTEGER)
begin      
   delete from TB_GOLEADOR
   where ID_GOLEADOR = pIdGoleador;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateGoleador` $$
CREATE PROCEDURE `spUpdateGoleador`(
	pIdGoleador INTEGER,
	pIdTime INTEGER,
	pNmGoleador VARCHAR(50),
	pNmCompleto VARCHAR(100),
	pDsLink VARCHAR(200),
	pDsPais VARCHAR(80),
	pIdSofifa INTEGER,
	pIdUsu INTEGER
)
begin      
	update TB_GOLEADOR
	set NM_GOLEADOR = pNmGoleador,
	ID_Time = pIdTime,
	NM_GOLEADOR_COMPLETO = pNmCompleto,
	DS_LINK_IMAGEM = pDsLink,
	ID_TIME_SOFIFA = pIdSofifa,
	DS_PAIS = pDsPais,
	DT_INSCRICAO = NOW(),
	ID_USUARIO = pIdUsu
	where ID_GOLEADOR = pIdGoleador;  
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddGoleador` $$
CREATE PROCEDURE `spAddGoleador`(
	pIdGoleador INTEGER,
	pIdTime INTEGER,
	pNmGoleador VARCHAR(50),
	pNmCompleto VARCHAR(100),
	pDsLink VARCHAR(200),
	pDsPais VARCHAR(80),
	pIdSofifa INTEGER,
	pIdUsu INTEGER
)
begin      
	insert into  TB_GOLEADOR  (ID_GOLEADOR, NM_GOLEADOR, ID_Time, NM_GOLEADOR_COMPLETO, DS_LINK_IMAGEM, ID_TIME_SOFIFA, DS_PAIS, DT_INSCRICAO, ID_USUARIO)
	values (pIdGoleador, pNmGoleador, pIdTime, pNmCompleto, pDsLink, pIdSofifa, pDsPais, NOW(), pIdUsu);
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAddGoleadorByNewUsuPRO` $$
CREATE PROCEDURE `spGetAddGoleadorByNewUsuPRO`(pIdUsu INTEGER, pIdCamp INTEGER)
begin      
	DECLARE _idGoleador INTEGER DEFAULT NULL;
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE _Total INTEGER DEFAULT 0;
	DECLARE _NmUsu VARCHAR(50) DEFAULT NULL;
	DECLARE _PsnId VARCHAR(30) DEFAULT NULL;
	
	SET _idGoleador = spGetMaxIdGoleador();
	SET _idTime = fcGetCurrentIdTime(pIdUsu, pIdCamp);
	
	select NM_USUARIO, PSN_ID into _NmUsu, _PsnId
	from TB_USUARIO 
	where ID_USUARIO = pIdUsu;
	
	select count(1) into _Total
	from TB_GOLEADOR
	where ID_USUARIO = pIdUsu;
	
	IF (_Total > 0) THEN
	
		update TB_GOLEADOR 
		set ID_TIME = _idTime
		where ID_USUARIO = pIdUsu;
	
	ELSE
	
		call spAddGoleador(_idGoleador, _idTime, _PsnId, _NmUsu, '...', 'PRO CLUB', 0, pIdUsu);
	
	END IF;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAddLoadGoleadoresByNewUsuPRO` $$
CREATE PROCEDURE `spGetAddLoadGoleadoresByNewUsuPRO`(pIdUsu INTEGER, pIdTemp INTEGER, pIdNewTime INTEGER)
begin      
	DECLARE _IdUsu INTEGER DEFAULT NULL;
	DECLARE _idGoleador INTEGER DEFAULT NULL;
	DECLARE _Total INTEGER DEFAULT 0;
	DECLARE _NmUsu VARCHAR(50) DEFAULT NULL;
	DECLARE _PsnId VARCHAR(30) DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
	       SELECT C.ID_USUARIO, U.NM_USUARIO, U.PSN_ID 
		   from TB_CONFIRM_ELENCO_PRO C, TB_USUARIO U
		   where C.ID_TEMPORADA = pIdTemp
		     and C.ID_USUARIO_MANAGER = pIdUsu
			 and C.ID_USUARIO = U.ID_USUARIO
		  order by C.DT_CONFIRMACAO, C.ID_USUARIO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _IdUsu, _NmUsu, _PsnId;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;

		SET _idGoleador = spGetMaxIdGoleador();
	
		call spAddGoleador(_idGoleador, pIdNewTime, _PsnId, _NmUsu, '...', 'PRO CLUB', 0, _IdUsu);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;

	
	SET _idGoleador = spGetMaxIdGoleador();
	
	select NM_USUARIO, PSN_ID into _NmUsu, _PsnId
	from TB_USUARIO
	where ID_USUARIO = pIdUsu;	

	call spAddGoleador(_idGoleador, pIdNewTime, _PsnId, _NmUsu, '...', 'PRO CLUB', 0, _IdUsu);

	call spDeleteConfirmElencoProOfManagerTemporada(pIdTemp, pIdUsu);
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllGoleadoresByGame` $$
CREATE PROCEDURE `spGetAllGoleadoresByGame`(pIdCamp INTEGER, pIdJogo INTEGER, pIdTimeHome INTEGER, pIdTimeAway INTEGER)
begin      
   select G.NM_GOLEADOR, J.QT_GOLS, 'Home' as TpJogo
   from B_GOLEADOR G, TB_GOLEADOR_JOGO J
   where J.ID_CAMPEONATO = pIdCamp
   and J.ID_TABELA_JOGO = pIdJogo
   and J.ID_TIME = pIdTimeHome
   and J.ID_GOLEADOR = G.ID_GOLEADOR
   and J.ID_TIME = G.ID_TIME
   UNION ALL
   select G.NM_GOLEADOR, J.QT_GOLS, 'Away' as TpJogo
   from B_GOLEADOR G, TB_GOLEADOR_JOGO J
   where J.ID_CAMPEONATO = pIdCamp
   and J.ID_TABELA_JOGO = pIdJogo
   and J.ID_TIME = pIdTimeAway
   and J.ID_GOLEADOR = G.ID_GOLEADOR
   and J.ID_TIME = G.ID_TIME
   order by TpJogo, NM_GOLEADOR;
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllGoleadoresByGamev2` $$
CREATE PROCEDURE `spGetAllGoleadoresByGamev2`(pIdCamp INTEGER, pIdJogo INTEGER, pIdTimeHome INTEGER, pIdTimeAway INTEGER)
begin      
   select G.NM_GOLEADOR, J.QT_GOLS, 'Home' as TpJogo
   from B_GOLEADOR G, TB_GOLEADOR_JOGO J
   where J.ID_CAMPEONATO = pIdCamp
   and J.ID_TABELA_JOGO = pIdJogo
   and J.ID_TIME = pIdTimeHome
   and J.ID_GOLEADOR = G.ID_GOLEADOR
   and J.ID_TIME = G.ID_TIME
   UNION ALL
   select G.NM_GOLEADOR, J.QT_GOLS, 'Home' as TpJogo
   from B_GOLEADOR G, TB_GOLEADOR_JOGO J
   where J.ID_CAMPEONATO = pIdCamp
   and J.ID_TABELA_JOGO = pIdJogo
   and J.ID_TIME = pIdTimeHome
   and G.ID_GOLEADOR = 0
   and G.ID_TIME = 0
   and J.ID_GOLEADOR = G.ID_GOLEADOR
   and J.ID_TIME = G.ID_TIME
   UNION ALL
   select G.NM_GOLEADOR, J.QT_GOLS, 'Away' as TpJogo
   from B_GOLEADOR G, TB_GOLEADOR_JOGO J
   where J.ID_CAMPEONATO = pIdCamp
   and J.ID_TABELA_JOGO = pIdJogo
   and J.ID_TIME = pIdTimeAway
   and J.ID_GOLEADOR = G.ID_GOLEADOR
   and J.ID_TIME = G.ID_TIME
   UNION ALL
   select G.NM_GOLEADOR, J.QT_GOLS, 'Away' as TpJogo
   from B_GOLEADOR G, TB_GOLEADOR_JOGO J
   where J.ID_CAMPEONATO = pIdCamp
   and J.ID_TABELA_JOGO = pIdJogo
   and J.ID_TIME = pIdTimeAway
   and G.ID_GOLEADOR = 0
   and G.ID_TIME = 0
   and J.ID_GOLEADOR = G.ID_GOLEADOR
   and J.ID_TIME = G.ID_TIME
   order by TpJogo, NM_GOLEADOR;
End$$
DELIMITER ;