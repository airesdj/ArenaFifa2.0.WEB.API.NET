USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddGoleadorJogo` $$
CREATE PROCEDURE `spAddGoleadorJogo`(
	pIdCamp INTEGER,
	pIdJogo INTEGER,
	pIdTime INTEGER,
	pIdGoleador INTEGER,
	pQtGols INTEGER
)
begin      
	insert into TB_GOLEADOR_JOGO (ID_CAMPEONATO, ID_TABELA_JOGO, ID_TIME, ID_GOLEADOR, QT_GOLS)
	values (pIdCamp, pIdJogo, pIdTime, pIdGoleador, pQtGols);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddLoadGoleadorJogo` $$
CREATE PROCEDURE `spAddLoadGoleadorJogo`(
	pIdCamp INTEGER,
	pIdJogo INTEGER,
	pIdsGoleadorHome VARCHAR(250),
	pQtGolsGoleadorHome VARCHAR(250),
	pIdsGoleadorAway VARCHAR(250),
	pQtGolsGoleadorAway VARCHAR(250)
)
begin      
	DECLARE _idTimeHome INTEGER DEFAULT NULL;
	DECLARE _idTimeAway INTEGER DEFAULT NULL;
	DECLARE _nextGoleador VARCHAR(250) DEFAULT NULL;
	DECLARE _nextGols VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlenGoleador INTEGER DEFAULT NULL;
	DECLARE _nextlenGols INTEGER DEFAULT NULL;
	DECLARE _idGoleador VARCHAR(10) DEFAULT NULL;
	DECLARE _idGols VARCHAR(3) DEFAULT NULL;
	DECLARE strDelimiter CHAR(1) DEFAULT ',';
	
	select ID_TIME_CASA, ID_TIME_VISITANTE into _idTimeHome, _idTimeAway
	from TB_TABELA_JOGO
	where ID_CAMPEONATO = pIdCamp
	and ID_TABELA_JOGO = pIdJogo;

	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsGoleadorHome)) = 0 OR pIdsGoleadorHome IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _nextGoleador = SUBSTRING_INDEX(pIdsGoleadorHome,strDelimiter,1);
		SET _nextGols = SUBSTRING_INDEX(pQtGolsGoleadorHome,strDelimiter,1);
		
		SET _nextlenGoleador = LENGTH(_nextGoleador);
		SET _nextlenGols = LENGTH(_nextGols);
		
		SET _idGoleador = TRIM(_nextGoleador);
		SET _idGols = TRIM(_nextGols);
		
		call spAddGoleadorJogo (pIdCamp, pIdJogo, _idTimeHome, CAST(_idGoleador AS SIGNED), CAST(_idGols AS SIGNED));
		
		SET pIdsGoleadorHome = INSERT(pIdsGoleadorHome,1,_nextlenGoleador + 1,'');
		SET pQtGolsGoleadorHome = INSERT(pQtGolsGoleadorHome,1,_nextlenGoleador + 1,'');
	END LOOP;

	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsGoleadorAway)) = 0 OR pIdsGoleadorAway IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _nextGoleador = SUBSTRING_INDEX(pIdsGoleadorAway,strDelimiter,1);
		SET _nextGols = SUBSTRING_INDEX(pQtGolsGoleadorAway,strDelimiter,1);
		
		SET _nextlenGoleador = LENGTH(_nextGoleador);
		SET _nextlenGols = LENGTH(_nextGols);
		
		SET _idGoleador = TRIM(_nextGoleador);
		SET _idGols = TRIM(_nextGols);
		
		call spAddGoleadorJogo (pIdCamp, pIdJogo, _idTimeAway, CAST(_idGoleador AS SIGNED), CAST(_idGols AS SIGNED));
		
		SET pIdsGoleadorAway = INSERT(pIdsGoleadorAway,1,_nextlenGoleador + 1,'');
		SET pQtGolsGoleadorAway = INSERT(pQtGolsGoleadorAway,1,_nextlenGoleador + 1,'');
	END LOOP;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllGoleadoresByTimeJogo` $$
CREATE PROCEDURE `spGetAllGoleadoresByTimeJogo`(pIdTime INTEGER, pIdJogo INTEGER)
begin      
   SELECT G.*, GJ.QT_GOLS FROM TB_GOLEADOR G, TB_GOLEADOR_JOGO GJ 
   WHERE GJ.ID_TABELA_JOGO = pIdJogo AND GJ.ID_TIME = pIdTime AND G.ID_GOLEADOR = 0 AND G.ID_GOLEADOR = GJ.ID_GOLEADOR AND G.ID_TIME = GJ.ID_TIME
   UNION ALL
   SELECT G.*, GJ.QT_GOLS FROM TB_GOLEADOR G, TB_GOLEADOR_JOGO GJ 
   WHERE GJ.ID_TABELA_JOGO = pIdJogo AND G.ID_TIME = pIdTime AND G.ID_GOLEADOR > 0 AND G.ID_GOLEADOR = GJ.ID_GOLEADOR AND G.ID_TIME = GJ.ID_TIME
   ORDER BY NM_GOLEADOR;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteLoadGoleadorJogo` $$
CREATE PROCEDURE `spDeleteLoadGoleadorJogo`(
	pIdCamp INTEGER,
	pIdJogo INTEGER,
	pIdsGoleadorHome VARCHAR(250),
	pIdsGoleadorAway VARCHAR(250),
)
begin      
	DECLARE _idTimeHome INTEGER DEFAULT NULL;
	DECLARE _idTimeAway INTEGER DEFAULT NULL;
	DECLARE _nextGoleador VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlenGoleador INTEGER DEFAULT NULL;
	DECLARE _idGoleador VARCHAR(10) DEFAULT NULL;
	DECLARE strDelimiter CHAR(1) DEFAULT ',';
	
	select ID_TIME_CASA, ID_TIME_VISITANTE into _idTimeHome, _idTimeAway
	from TB_TABELA_JOGO
	where ID_CAMPEONATO = pIdCamp
	and ID_TABELA_JOGO = pIdJogo;

	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsGoleadorHome)) = 0 OR pIdsGoleadorHome IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _nextGoleador = SUBSTRING_INDEX(pIdsGoleadorHome,strDelimiter,1);
		
		SET _nextlenGoleador = LENGTH(_nextGoleador);
		
		SET _idGoleador = TRIM(_nextGoleador);
		
		delete from TB_GOLEADOR_JOGO where ID_CAMPEONATO = pIdCamp
		and ID_TABELA_JOGO = pIdJogo and ID_TIME = _idTimeHome and ID_GOLEADOR = _idGoleador;
		
		SET pIdsGoleadorHome = INSERT(pIdsGoleadorHome,1,_nextlenGoleador + 1,'');
	END LOOP;

	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsGoleadorAway)) = 0 OR pIdsGoleadorAway IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _nextGoleador = SUBSTRING_INDEX(pIdsGoleadorAway,strDelimiter,1);
		
		SET _nextlenGoleador = LENGTH(_nextGoleador);
		
		SET _idGoleador = TRIM(_nextGoleador);
		
		delete from TB_GOLEADOR_JOGO where ID_CAMPEONATO = pIdCamp
		and ID_TABELA_JOGO = pIdJogo and ID_TIME = _idTimeAway and ID_GOLEADOR = _idGoleador;
		
		SET pIdsGoleadorAway = INSERT(pIdsGoleadorAway,1,_nextlenGoleador + 1,'');
	END LOOP;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllGoleadoresByCampeonato` $$
CREATE PROCEDURE `spGetAllGoleadoresByCampeonato`(pIdCamp INTEGER)
begin      
	SELECT X.ID_GOLEADOR, G.NM_GOLEADOR, X.QT_GOLS_MARCADOS, T.NM_TIME, T.DS_Tipo, G.NM_GOLEADOR_COMPLETO, G.DS_LINK_IMAGEM
	FROM (SELECT J.ID_GOLEADOR, SUM(J.QT_GOLS) as QT_GOLS_MARCADOS
	FROM TB_GOLEADOR_JOGO J
	WHERE J.ID_CAMPEONATO = pIdCamp
	GROUP BY J.ID_GOLEADOR) X, TB_GOLEADOR G, TB_TIME T
	WHERE G.ID_TIME IN (SELECT CT.ID_TIME FROM TB_CAMPEONATO_TIME CT WHERE CT.ID_CAMPEONATO = pIdCamp)
	AND X.ID_GOLEADOR = G.ID_GOLEADOR
	AND G.ID_TIME = T.ID_TIME
	ORDER BY X.QT_GOLS_MARCADOS DESC, G.NM_GOLEADOR;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllGoleadoresByTime` $$
CREATE PROCEDURE `spGetAllGoleadoresByTime`(pIdCamp INTEGER, pIdTime INTEGER)
begin      
	SELECT X.ID_GOLEADOR, G.NM_GOLEADOR, X.QT_GOLS_MARCADOS, T.NM_TIME, T.DS_Tipo, G.NM_GOLEADOR_COMPLETO, G.DS_LINK_IMAGEM
	FROM (SELECT J.ID_GOLEADOR, SUM(J.QT_GOLS) as QT_GOLS_MARCADOS
	FROM TB_GOLEADOR_JOGO J
	WHERE J.ID_CAMPEONATO = pIdCamp
	AND J.ID_TIME = pIdTime
	GROUP BY J.ID_GOLEADOR) X, TB_GOLEADOR G, TB_TIME T
	WHERE G.ID_TIME = pIdTime
	AND X.ID_GOLEADOR = G.ID_GOLEADOR
	AND G.ID_TIME = T.ID_TIME
	ORDER BY X.QT_GOLS_MARCADOS DESC, G.NM_GOLEADOR;
End$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllGoleadoresByJogo` $$
CREATE PROCEDURE `spGetAllGoleadoresByJogo`(pIdCamp INTEGER, pIdTimeHome INTEGER, pIdTimeAway INTEGER, pIdJogo INTEGER)
begin      
	SELECT G.NM_GOLEADOR, J.QT_GOLS, 'Home' TP_TIME FROM TB_GOLEADOR G, TB_GOLEADOR_JOGO J
	WHERE J.ID_CAMPEONATO = pIdCamp AND J.ID_TABELA_JOGO = pIdJogo AND J.ID_TIME = pIdTimeHome
	AND J.ID_GOLEADOR = G.ID_GOLEADOR AND J.ID_TIME = G.ID_TIME
	UNION ALL
	SELECT G.NM_GOLEADOR, J.QT_GOLS, 'Home' TP_TIME FROM TB_GOLEADOR G, TB_GOLEADOR_JOGO J
	WHERE J.ID_CAMPEONATO = pIdCamp AND J.ID_TABELA_JOGO = pIdJogo AND J.ID_TIME = pIdTimeHome
	AND G.ID_GOLEADOR = 0 AND G.ID_TIME = 0
	AND J.ID_GOLEADOR = G.ID_GOLEADOR
	UNION ALL
	SELECT G.NM_GOLEADOR, J.QT_GOLS, 'Away' TP_TIME FROM TB_GOLEADOR G, TB_GOLEADOR_JOGO J
	WHERE J.ID_CAMPEONATO = pIdCamp AND J.ID_TABELA_JOGO = pIdJogo AND J.ID_TIME = pIdTimeAway
	AND J.ID_GOLEADOR = G.ID_GOLEADOR AND J.ID_TIME = G.ID_TIME
	UNION ALL
	SELECT G.NM_GOLEADOR, J.QT_GOLS, 'Away' TP_TIME FROM TB_GOLEADOR G, TB_GOLEADOR_JOGO J
	WHERE J.ID_CAMPEONATO = pIdCamp AND J.ID_TABELA_JOGO = pIdJogo AND J.ID_TIME = pIdTimeAway
	AND G.ID_GOLEADOR = 0 AND G.ID_TIME = 0
	AND J.ID_GOLEADOR = G.ID_GOLEADOR
	ORDER BY TP_TIME, NM_GOLEADOR;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetLoadAllGoleadores` $$
CREATE PROCEDURE `spGetLoadAllGoleadores`(pIdsTime VARCHAR(250))
begin      
	SELECT X.ID_GOLEADOR, G.NM_GOLEADOR, G.ID_USUARIO, X.QT_GOLS_MARCADOS, G.NM_GOLEADOR_COMPLETO, T.NM_TIME, T.DS_TIPO
	FROM (SELECT J.ID_GOLEADOR, SUM(J.QT_GOLS) as QT_GOLS_MARCADOS
	FROM TB_GOLEADOR_JOGO J
	WHERE J.ID_TIME IN (pIdsTime)
	GROUP BY J.ID_GOLEADOR) X, TB_GOLEADOR G, TB_TIME T
	WHERE X.ID_GOLEADOR = G.ID_GOLEADOR
	AND G.ID_TIME = T.ID_TIME
	AND G.ID_TIME IN (pIdsTime)
	ORDER BY X.QT_GOLS_MARCADOS DESC, G.NM_GOLEADOR;
End$$
DELIMITER ;

