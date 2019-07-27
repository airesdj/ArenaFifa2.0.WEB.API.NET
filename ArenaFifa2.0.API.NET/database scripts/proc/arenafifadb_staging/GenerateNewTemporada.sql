USE `arenafifadb_staging`;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spPrepareComentariosDB` $$
CREATE PROCEDURE `spPrepareComentariosDB`()
Begin
	DECLARE _idTabelaIni INTEGER DEFAULT NULL;
	DECLARE _idTabelaFim INTEGER DEFAULT NULL;
	DECLARE _idTimeFim INTEGER DEFAULT NULL;
	DECLARE _idUsuFim INTEGER DEFAULT NULL;
	DECLARE _idFaseFim INTEGER DEFAULT NULL;
	DECLARE _idGoleadorFim INTEGER DEFAULT NULL;
	
	call `arenafifadb_staging`.`spCreateTablesComentariosDB`();
	
	SELECT max(ID_TIME) into _idTimeFim FROM arena_comments.TB_TIME;
	SELECT max(ID_USUARIO) into _idUsuFim FROM arena_comments.TB_USUARIO;
	SELECT max(ID_GOLEADOR) into _idGoleadorFim FROM arena_comments.TB_GOLEADOR;
	SELECT max(ID_FASE) into _idFaseFim FROM arena_comments.TB_FASE;
	
	
	
	INSERT INTO arena_comments.TB_TEMPORADA SELECT * FROM arenafifadb.TB_TEMPORADA WHERE ID_TEMPORADA = (pIdTemp-1);
	INSERT INTO arena_comments.TB_CAMPEONATO SELECT * FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1);
	
	
	
	INSERT INTO arena_comments.TB_TIME SELECT * FROM arenafifadb.TB_TIME WHERE ID_TIME > _idTimeFim;
	INSERT INTO arena_comments.TB_USUARIO SELECT * FROM arenafifadb.TB_USUARIO WHERE ID_USUARIO > _idUsuFim;
	INSERT INTO arena_comments.TB_GOLEADOR SELECT * FROM arenafifadb.TB_GOLEADOR WHERE ID_GOLEADOR > _idGoleadorFim;
	INSERT INTO arena_comments.TB_FASE SELECT * FROM arenafifadb.TB_FASE WHERE ID_FASE > _idFaseFim;
	
	
	
	INSERT INTO arena_comments.TB_CAMPEONATO_TIME SELECT * FROM arenafifadb.TB_CAMPEONATO_TIME
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));

	INSERT INTO arena_comments.TB_CAMPEONATO_USUARIO SELECT * FROM arenafifadb.TB_CAMPEONATO_USUARIO
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));

	INSERT INTO arena_comments.TB_CLASSIFICACAO SELECT * FROM arenafifadb.TB_CLASSIFICACAO
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));

	INSERT INTO arena_comments.TB_FASE_CAMPEONATO SELECT * FROM arenafifadb.TB_FASE_CAMPEONATO
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));

	INSERT INTO arena_comments.TB_GRUPO SELECT * FROM arenafifadb.TB_GRUPO
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));
	
	INSERT INTO arena_comments.TB_USUARIO_TIME SELECT * FROM arenafifadb.TB_USUARIO_TIME
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));
	
	
	
	SELECT min(ID_TABELA_JOGO), max(ID_TABELA_JOGO) into _idTabelaIni, _idTabelaFim FROM arenafifadb.TB_TABELA_JOGO 
	WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1));
	
	INSERT INTO arena_comments.TB_COMENTARIO_JOGO_20 SELECT *, NULL FROM arenafifadb.TB_COMENTARIO_JOGO 
	WHERE ID_TABELA_JOGO >= _idTabelaIni AND ID_TABELA_JOGO <= _idTabelaFim;
	
	UPDATE arena_comments.TB_COMENTARIO_JOGO_20 C
	INNER JOIN arena_comments.TB_USUARIO U ON C.ID_USUARIO = U.ID_USUARIO 
	SET C.PSN_ID = U.PSN_ID
	WHERE C.PSN_ID IS NULL;

	INSERT INTO arena_comments.TB_GOLEADOR_JOGO_20 SELECT *, NULL FROM arenafifadb.TB_GOLEADOR_JOGO 
	WHERE ID_TABELA_JOGO >= _idTabelaIni AND ID_TABELA_JOGO <= _idTabelaFim;

	INSERT INTO arena_comments.TB_TABELA_JOGO_20 SELECT *, NULL FROM arenafifadb.TB_TABELA_JOGO 
	WHERE ID_TABELA_JOGO >= _idTabelaIni AND ID_TABELA_JOGO <= _idTabelaFim;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spCreateTablesComentariosDB` $$
CREATE PROCEDURE `spCreateTablesComentariosDB`()
Begin
	DROP TABLE IF EXISTS `arena_comments`.`TB_COMENTARIO_JOGO_20`;
	DROP TABLE IF EXISTS `arena_comments`.`TB_GOLEADOR_JOGO_20`;
	DROP TABLE IF EXISTS `arena_comments`.`TB_TABELA_JOGO_20`;
	
	CREATE TABLE `arena_comments`.`TB_COMENTARIO_JOGO_20` (
	  `ID_COMENTARIO` INTEGER NOT NULL AUTO_INCREMENT, 
	  `ID_TABELA_JOGO` INTEGER NOT NULL DEFAULT 0, 
	  `ID_USUARIO` INTEGER NOT NULL DEFAULT 0, 
	  `DT_COMENTARIO` DATETIME NOT NULL, 
	  `HR_COMENTARIO` VARCHAR(8) NOT NULL, 
	  `DS_COMENTARIO` LONGTEXT NOT NULL, 
	  `PSN_ID` VARCHAR(30), 
	  INDEX (`ID_TABELA_JOGO`, `ID_USUARIO`, `DT_COMENTARIO`, `HR_COMENTARIO`, `DS_COMENTARIO`(100)), 
	  PRIMARY KEY (`ID_COMENTARIO`)
	) ENGINE=myisam DEFAULT CHARSET=utf8;
	
	CREATE TABLE `arena_comments`.`TB_GOLEADOR_JOGO_20` (
	  `ID_TABELA_JOGO` INTEGER NOT NULL, 
	  `ID_CAMPEONATO` INTEGER NOT NULL, 
	  `ID_TIME` INTEGER NOT NULL, 
	  `ID_GOLEADOR` INTEGER NOT NULL, 
	  `QT_GOLS` INTEGER, 
	  INDEX (`ID_CAMPEONATO`, `QT_GOLS`, `ID_TIME`), 
	  PRIMARY KEY (`ID_CAMPEONATO`, `ID_TABELA_JOGO`, `ID_TIME`, `ID_GOLEADOR`)
	) ENGINE=myisam DEFAULT CHARSET=utf8;

	CREATE TABLE `arena_comments`.`TB_TABELA_JOGO_20` (
	  `ID_TABELA_JOGO` INTEGER NOT NULL AUTO_INCREMENT, 
	  `ID_CAMPEONATO` INTEGER NOT NULL DEFAULT 0, 
	  `ID_FASE` INTEGER NOT NULL DEFAULT 0, 
	  `DT_TABELA_INICIO_JOGO` DATETIME NOT NULL, 
	  `DT_TABELA_FIM_JOGO` DATETIME NOT NULL, 
	  `ID_TIME_CASA` INTEGER NOT NULL DEFAULT 0, 
	  `QT_GOLS_TIME_CASA` INTEGER, 
	  `ID_TIME_VISITANTE` INTEGER NOT NULL DEFAULT 0, 
	  `QT_GOLS_TIME_VISITANTE` INTEGER, 
	  `DT_EFETIVACAO_JOGO` DATETIME, 
	  `IN_NUMERO_RODADA` INTEGER DEFAULT 0, 
	  `IN_DISPUTA_3o_4o` INTEGER, 
	  `DT_SORTEIO` DATETIME NOT NULL, 
	  `DS_HORA_JOGO` VARCHAR(10), 
	  `ID_USUARIO_TIME_CASA` INTEGER, 
	  `ID_USUARIO_TIME_VISITANTE` INTEGER, 
	  `IN_JOGO_MATAXMATA` INTEGER, 
	  `DT_ULTIMA_EFETIVACAO` DATETIME, 
	  `DS_LOGIN_EFETIVACAO` VARCHAR(30), 
	  INDEX (`IN_JOGO_MATAXMATA`, `IN_NUMERO_RODADA`, `ID_TABELA_JOGO`), 
	  PRIMARY KEY (`ID_TABELA_JOGO`), 
	  INDEX (`ID_CAMPEONATO`, `DT_TABELA_INICIO_JOGO`), 
	  INDEX (`ID_CAMPEONATO`, `ID_TIME_CASA`, `ID_TIME_VISITANTE`), 
	  INDEX (`DT_EFETIVACAO_JOGO`, `ID_TABELA_JOGO`), 
	  INDEX (`DT_TABELA_INICIO_JOGO`, `ID_CAMPEONATO`), 
	  INDEX (`ID_TABELA_JOGO`, `ID_CAMPEONATO`, `ID_FASE`), 
	  INDEX (`ID_CAMPEONATO`, `ID_FASE`), 
	  INDEX (`ID_CAMPEONATO`, `ID_FASE`, `IN_NUMERO_RODADA`, `ID_TIME_CASA`, `ID_TIME_VISITANTE`), 
	  INDEX (`ID_CAMPEONATO`, `DT_EFETIVACAO_JOGO`), 
	  INDEX (`IN_NUMERO_RODADA`), 
	  INDEX (`ID_CAMPEONATO`, `DT_TABELA_INICIO_JOGO`, `DT_TABELA_FIM_JOGO`, `ID_FASE`), 
	  INDEX (`ID_CAMPEONATO`, `ID_FASE`, `IN_NUMERO_RODADA`, `DT_EFETIVACAO_JOGO`)
	) ENGINE=myisam DEFAULT CHARSET=utf8;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetIdTempCurrent` $$
CREATE FUNCTION `fcGetIdTempCurrent`() RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idTemp INTEGER DEFAULT NULL;
	
	SELECT H.id_temporada into _idTemp FROM TB_TEMPORADA H 
	WHERE H.DT_FIM IS NULL ORDER BY H.id_temporada DESC LIMIT 1;
	
	IF (_idTemp IS NULL) THEN
		SET _idTemp = 0;
	END IF;
	
	RETURN _idTemp;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spInitializeProxTemporada` $$
CREATE PROCEDURE `spInitializeProxTemporada`()
Begin
	DECLARE _count INTEGER DEFAULT NULL;
	DECLARE _nmTable VARCHAR(100) DEFAULT NULL;

	#DECLARE tabela_cursor CURSOR FOR
	#SELECT TABLE_NAME FROM information_schema.tables WHERE TABLE_SCHEMA = "arenafifadb";
	#SELECT concat('INSERT INTO arenafifadb.', TABLE_NAME, ' SELECT * FROM arenafifadb_bkp.', TABLE_NAME, ';') FROM information_schema.TABLES WHERE TABLE_SCHEMA = "arenafifadb";
	#SELECT ROUTINE_NAME FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA  = "arenafifadb"
	#SELECT concat('DROP PROCEDURE ', ROUTINE_NAME, ';') FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA  = "arenafifadb" AND ROUTINE_TYPE  = "PROCEDURE"
	#SELECT concat('DROP FUNCTION ', ROUTINE_NAME, ';') FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA  = "arenafifadb" AND ROUTINE_TYPE  = "FUNCTION"
	
	call `arenafifadb_staging`.`spDeleteAllRecordsFromDB`();
	call `arenafifadb_staging`.`spTransferDataFromBKPToDB`();
	
	SELECT fcGetIdTempCurrent() as PreviousTemporadaID;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAlterTableAutoIncrement` $$
CREATE PROCEDURE `spAlterTableAutoIncrement`()
Begin
	DECLARE _count INTEGER DEFAULT NULL;
	
	SELECT ID_CAMPEONATO into _count
	FROM arenafifadb_bkp.TB_CAMPEONATO ORDER BY ID_CAMPEONATO DESC LIMIT 1;
	ALTER TABLE TB_CAMPEONATO AUTO_INCREMENT = _count;
	

	SELECT ID_BANCO_RESERVA into _count
	FROM arenafifadb_bkp.TB_LISTA_BANCO_RESERVA ORDER BY ID_BANCO_RESERVA DESC LIMIT 1;
	ALTER TABLE TB_LISTA_BANCO_RESERVA AUTO_INCREMENT = _count;
	
	
	SELECT ID_TABELA_JOGO into _count
	FROM arenafifadb_bkp.TB_TABELA_JOGO ORDER BY ID_TABELA_JOGO DESC LIMIT 1;
	ALTER TABLE TB_TABELA_JOGO AUTO_INCREMENT = _count;
	

	SELECT ID_TEMPORADA into _count
	FROM arenafifadb_bkp.TB_TEMPORADA ORDER BY ID_TEMPORADA DESC LIMIT 1;
	ALTER TABLE TB_TEMPORADA AUTO_INCREMENT = _count;


	SELECT ID_TIME into _count
	FROM arenafifadb_bkp.TB_TIME ORDER BY ID_TIME DESC LIMIT 1;
	ALTER TABLE TB_TIME AUTO_INCREMENT = _count;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spPrepareDatabaseBKPToNegerateNewSeason` $$
CREATE PROCEDURE `spPrepareDatabaseBKPToNegerateNewSeason`()
Begin
	
	call `arenafifadb_staging`.`spDeleteAllRecordsFromBKP`();
	call `arenafifadb_staging`.`spTransferDataFromDBOnLineToBKP`();
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spTransferDataFromDBOnLineToBKP` $$
CREATE PROCEDURE `spTransferDataFromDBOnLineToBKP`()
Begin
	INSERT INTO arenafifadb_bkp.tb_campeonato SELECT * FROM arenafifadb.tb_campeonato;
	INSERT INTO arenafifadb_bkp.tb_campeonato_time SELECT * FROM arenafifadb.tb_campeonato_time;
	INSERT INTO arenafifadb_bkp.tb_campeonato_usuario SELECT * FROM arenafifadb.tb_campeonato_usuario;
	INSERT INTO arenafifadb_bkp.tb_campeonato_usuario_seg_fase SELECT * FROM arenafifadb.tb_campeonato_usuario_seg_fase;
	INSERT INTO arenafifadb_bkp.tb_classificacao SELECT * FROM arenafifadb.tb_classificacao;
	INSERT INTO arenafifadb_bkp.tb_comentario_jogo SELECT * FROM arenafifadb.tb_comentario_jogo;
	INSERT INTO arenafifadb_bkp.tb_comentario_usuario SELECT * FROM arenafifadb.tb_comentario_usuario;
	INSERT INTO arenafifadb_bkp.tb_confirm_elenco_pro SELECT * FROM arenafifadb.tb_confirm_elenco_pro;
	INSERT INTO arenafifadb_bkp.tb_confirmacao_temporada SELECT * FROM arenafifadb.tb_confirmacao_temporada;
	INSERT INTO arenafifadb_bkp.tb_fase SELECT * FROM arenafifadb.tb_fase;
	INSERT INTO arenafifadb_bkp.tb_fase_campeonato SELECT * FROM arenafifadb.tb_fase_campeonato;
	INSERT INTO arenafifadb_bkp.tb_goleador SELECT * FROM arenafifadb.tb_goleador;
	INSERT INTO arenafifadb_bkp.tb_goleador_jogo SELECT * FROM arenafifadb.tb_goleador_jogo;
	INSERT INTO arenafifadb_bkp.tb_grupo SELECT * FROM arenafifadb.tb_grupo;
	INSERT INTO arenafifadb_bkp.tb_historico_alt_campeonato SELECT * FROM arenafifadb.tb_historico_alt_campeonato;
	INSERT INTO arenafifadb_bkp.tb_historico_alt_usuario SELECT * FROM arenafifadb.tb_historico_alt_usuario;
	INSERT INTO arenafifadb_bkp.tb_historico_artilharia SELECT * FROM arenafifadb.tb_historico_artilharia;
	INSERT INTO arenafifadb_bkp.tb_historico_artilharia_pro SELECT * FROM arenafifadb.tb_historico_artilharia_pro;
	INSERT INTO arenafifadb_bkp.tb_historico_atual SELECT * FROM arenafifadb.tb_historico_atual;
	INSERT INTO arenafifadb_bkp.tb_historico_classificacao SELECT * FROM arenafifadb.tb_historico_classificacao;
	INSERT INTO arenafifadb_bkp.tb_historico_conquista SELECT * FROM arenafifadb.tb_historico_conquista;
	INSERT INTO arenafifadb_bkp.tb_historico_conquista_fut SELECT * FROM arenafifadb.tb_historico_conquista_fut;
	INSERT INTO arenafifadb_bkp.tb_historico_conquista_pro SELECT * FROM arenafifadb.tb_historico_conquista_pro;
	INSERT INTO arenafifadb_bkp.tb_historico_temporada SELECT * FROM arenafifadb.tb_historico_temporada;
	INSERT INTO arenafifadb_bkp.tb_historico_temporada_fut SELECT * FROM arenafifadb.tb_historico_temporada_fut;
	INSERT INTO arenafifadb_bkp.tb_historico_temporada_pro SELECT * FROM arenafifadb.tb_historico_temporada_pro;
	INSERT INTO arenafifadb_bkp.tb_historico_transmissao_aovivo SELECT * FROM arenafifadb.tb_historico_transmissao_aovivo;
	INSERT INTO arenafifadb_bkp.tb_lista_banco_reserva SELECT * FROM arenafifadb.tb_lista_banco_reserva;
	INSERT INTO arenafifadb_bkp.tb_lista_negra SELECT * FROM arenafifadb.tb_lista_negra;
	INSERT INTO arenafifadb_bkp.tb_lista_negra_detalhe SELECT * FROM arenafifadb.tb_lista_negra_detalhe;
	INSERT INTO arenafifadb_bkp.tb_palpite_jogo SELECT * FROM arenafifadb.tb_palpite_jogo;
	INSERT INTO arenafifadb_bkp.tb_pontuacao_campeonato SELECT * FROM arenafifadb.tb_pontuacao_campeonato;
	INSERT INTO arenafifadb_bkp.tb_pote_time_grupo SELECT * FROM arenafifadb.tb_pote_time_grupo;
	INSERT INTO arenafifadb_bkp.tb_resultados_lancados SELECT * FROM arenafifadb.tb_resultados_lancados;
	INSERT INTO arenafifadb_bkp.tb_tabela_jogo SELECT * FROM arenafifadb.tb_tabela_jogo;
	INSERT INTO arenafifadb_bkp.tb_temporada SELECT * FROM arenafifadb.tb_temporada;
	INSERT INTO arenafifadb_bkp.tb_time SELECT * FROM arenafifadb.tb_time;
	INSERT INTO arenafifadb_bkp.tb_times_fase_precopa SELECT * FROM arenafifadb.tb_times_fase_precopa;
	INSERT INTO arenafifadb_bkp.tb_tipo_campeonato SELECT * FROM arenafifadb.tb_tipo_campeonato;
	INSERT INTO arenafifadb_bkp.tb_tipo_time SELECT * FROM arenafifadb.tb_tipo_time;
	INSERT INTO arenafifadb_bkp.tb_ultimos_acontecimentos SELECT * FROM arenafifadb.tb_ultimos_acontecimentos;
	INSERT INTO arenafifadb_bkp.tb_usuario SELECT * FROM arenafifadb.tb_usuario;
	INSERT INTO arenafifadb_bkp.tb_usuario_time SELECT * FROM arenafifadb.tb_usuario_time;
	
	UPDATE arenafifadb_bkp.TB_USUARIO SET ID_USUARIO = 0 WHERE PSN_ID = 'ModeradoresAF';
End$$
DELIMITER ;



DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetCurrentIdTimePRO` $$
CREATE FUNCTION `fcGetCurrentIdTimePRO`(pIdUsu INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idTime INTEGER DEFAULT NULL;
	
	select X.ID_TIME into _idTime
	from TB_USUARIO_TIME X, TB_TIME T, TB_CAMPEONATO C
	where X.id_usuario = pIdUsu
	and X.DT_VIGENCIA_FIM is null
	and T.DS_Tipo is not null
	and C.ID_TEMPORADA IN (SELECT E.ID_TEMPORADA FROM TB_TEMPORADA E WHERE E.DT_FIM is null GROUP BY E.ID_TEMPORADA)
	and C.SG_TIPO_CAMPEONATO in ('CPRO','PRO1','PRO2')
	and X.ID_Time = T.ID_Time
	and X.ID_CAMPEONATO = C.ID_CAMPEONATO
	order by C.ID_TEMPORADA desc
	limit 1;
	
	RETURN _idTime;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spImportAllPROCLUBSquaq` $$
CREATE PROCEDURE `spImportAllPROCLUBSquaq`(pIdNewTemp INTEGER, pIdCopaFut INTEGER)
Begin
	DECLARE _count INTEGER DEFAULT NULL;
	DECLARE _INITIAL_ID_PLAYER_PROCLUB INTEGER DEFAULT 999000;

	DELETE FROM TB_GOLEADOR WHERE ID_TIME = (SELECT ID_TIME FROM TB_CAMPEONATO_TIME WHERE ID_CAMPEONATO = pIdCopaFut) AND DS_TIPO = 'PRO';
	
	SET @row_number = (_INITIAL_ID_PLAYER_PROCLUB - 1);
	
	INSERT INTO TB_GOLEADOR
	SELECT (@row_number:=@row_number + 1), fcGetCurrentIdTimePRO(C.ID_USUARIO), U.PSN_ID, U.NM_USUARIO, '...', 'PRO CLUB', 0, 0, C.ID_USUARIO, NOW()
	FROM TB_CONFIRM_ELENCO_PRO C, TB_USUARIO U WHERE ID_TEMPORADA = pIdNewTemp AND C.ID_USUARIO = U.ID_USUARIO;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spTransferDataFromDBToBKP` $$
CREATE PROCEDURE `spTransferDataFromDBToBKP`()
Begin
	INSERT INTO arenafifadb_bkp.tb_campeonato SELECT * FROM arenafifadb_staging.tb_campeonato;
	INSERT INTO arenafifadb_bkp.tb_campeonato_time SELECT * FROM arenafifadb_staging.tb_campeonato_time;
	INSERT INTO arenafifadb_bkp.tb_campeonato_usuario SELECT * FROM arenafifadb_staging.tb_campeonato_usuario;
	INSERT INTO arenafifadb_bkp.tb_campeonato_usuario_seg_fase SELECT * FROM arenafifadb_staging.tb_campeonato_usuario_seg_fase;
	INSERT INTO arenafifadb_bkp.tb_classificacao SELECT * FROM arenafifadb_staging.tb_classificacao;
	#INSERT INTO arenafifadb_bkp.tb_comentario_jogo SELECT * FROM arenafifadb_staging.tb_comentario_jogo;
	INSERT INTO arenafifadb_bkp.tb_comentario_usuario SELECT * FROM arenafifadb_staging.tb_comentario_usuario;
	INSERT INTO arenafifadb_bkp.tb_confirm_elenco_pro SELECT * FROM arenafifadb_staging.tb_confirm_elenco_pro;
	INSERT INTO arenafifadb_bkp.tb_confirmacao_temporada SELECT * FROM arenafifadb_staging.tb_confirmacao_temporada;
	INSERT INTO arenafifadb_bkp.tb_fase SELECT * FROM arenafifadb_staging.tb_fase;
	INSERT INTO arenafifadb_bkp.tb_fase_campeonato SELECT * FROM arenafifadb_staging.tb_fase_campeonato;
	INSERT INTO arenafifadb_bkp.tb_goleador SELECT * FROM arenafifadb_staging.tb_goleador;
	INSERT INTO arenafifadb_bkp.tb_goleador_jogo SELECT * FROM arenafifadb_staging.tb_goleador_jogo;
	INSERT INTO arenafifadb_bkp.tb_grupo SELECT * FROM arenafifadb_staging.tb_grupo;
	#INSERT INTO arenafifadb_bkp.tb_historico_alt_campeonato SELECT * FROM arenafifadb_staging.tb_historico_alt_campeonato;
	#INSERT INTO arenafifadb_bkp.tb_historico_alt_usuario SELECT * FROM arenafifadb_staging.tb_historico_alt_usuario;
	INSERT INTO arenafifadb_bkp.tb_historico_artilharia SELECT * FROM arenafifadb_staging.tb_historico_artilharia;
	INSERT INTO arenafifadb_bkp.tb_historico_artilharia_pro SELECT * FROM arenafifadb_staging.tb_historico_artilharia_pro;
	INSERT INTO arenafifadb_bkp.tb_historico_atual SELECT * FROM arenafifadb_staging.tb_historico_atual;
	#INSERT INTO arenafifadb_bkp.tb_historico_classificacao SELECT * FROM arenafifadb_staging.tb_historico_classificacao;
	INSERT INTO arenafifadb_bkp.tb_historico_conquista SELECT * FROM arenafifadb_staging.tb_historico_conquista;
	INSERT INTO arenafifadb_bkp.tb_historico_conquista_fut SELECT * FROM arenafifadb_staging.tb_historico_conquista_fut;
	INSERT INTO arenafifadb_bkp.tb_historico_conquista_pro SELECT * FROM arenafifadb_staging.tb_historico_conquista_pro;
	INSERT INTO arenafifadb_bkp.tb_historico_temporada SELECT * FROM arenafifadb_staging.tb_historico_temporada;
	INSERT INTO arenafifadb_bkp.tb_historico_temporada_fut SELECT * FROM arenafifadb_staging.tb_historico_temporada_fut;
	INSERT INTO arenafifadb_bkp.tb_historico_temporada_pro SELECT * FROM arenafifadb_staging.tb_historico_temporada_pro;
	#INSERT INTO arenafifadb_bkp.tb_historico_transmissao_aovivo SELECT * FROM arenafifadb_staging.tb_historico_transmissao_aovivo;
	INSERT INTO arenafifadb_bkp.tb_lista_banco_reserva SELECT * FROM arenafifadb_staging.tb_lista_banco_reserva;
	INSERT INTO arenafifadb_bkp.tb_lista_negra SELECT * FROM arenafifadb_staging.tb_lista_negra;
	INSERT INTO arenafifadb_bkp.tb_lista_negra_detalhe SELECT * FROM arenafifadb_staging.tb_lista_negra_detalhe;
	#INSERT INTO arenafifadb_bkp.tb_palpite_jogo SELECT * FROM arenafifadb_staging.tb_palpite_jogo;
	INSERT INTO arenafifadb_bkp.tb_pontuacao_campeonato SELECT * FROM arenafifadb_staging.tb_pontuacao_campeonato;
	INSERT INTO arenafifadb_bkp.tb_pote_time_grupo SELECT * FROM arenafifadb_staging.tb_pote_time_grupo;
	#INSERT INTO arenafifadb_bkp.tb_resultados_lancados SELECT * FROM arenafifadb_staging.tb_resultados_lancados;
	INSERT INTO arenafifadb_bkp.tb_tabela_jogo SELECT * FROM arenafifadb_staging.tb_tabela_jogo;
	INSERT INTO arenafifadb_bkp.tb_temporada SELECT * FROM arenafifadb_staging.tb_temporada;
	INSERT INTO arenafifadb_bkp.tb_time SELECT * FROM arenafifadb_staging.tb_time;
	INSERT INTO arenafifadb_bkp.tb_times_fase_precopa SELECT * FROM arenafifadb_staging.tb_times_fase_precopa;
	INSERT INTO arenafifadb_bkp.tb_tipo_campeonato SELECT * FROM arenafifadb_staging.tb_tipo_campeonato;
	INSERT INTO arenafifadb_bkp.tb_tipo_time SELECT * FROM arenafifadb_staging.tb_tipo_time;
	#INSERT INTO arenafifadb_bkp.tb_ultimos_acontecimentos SELECT * FROM arenafifadb_staging.tb_ultimos_acontecimentos;
	INSERT INTO arenafifadb_bkp.tb_usuario SELECT * FROM arenafifadb_staging.tb_usuario;
	INSERT INTO arenafifadb_bkp.tb_usuario_time SELECT * FROM arenafifadb_staging.tb_usuario_time;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spTransferDataFromBKPToDB` $$
CREATE PROCEDURE `spTransferDataFromBKPToDB`()
Begin
	INSERT INTO arenafifadb_staging.tb_campeonato SELECT * FROM arenafifadb_bkp.tb_campeonato;
	INSERT INTO arenafifadb_staging.tb_campeonato_time SELECT * FROM arenafifadb_bkp.tb_campeonato_time;
	INSERT INTO arenafifadb_staging.tb_campeonato_usuario SELECT * FROM arenafifadb_bkp.tb_campeonato_usuario;
	INSERT INTO arenafifadb_staging.tb_campeonato_usuario_seg_fase SELECT * FROM arenafifadb_bkp.tb_campeonato_usuario_seg_fase;
	INSERT INTO arenafifadb_staging.tb_classificacao SELECT * FROM arenafifadb_bkp.tb_classificacao;
	#INSERT INTO arenafifadb_staging.tb_comentario_jogo SELECT * FROM arenafifadb_bkp.tb_comentario_jogo;
	INSERT INTO arenafifadb_staging.tb_comentario_usuario SELECT * FROM arenafifadb_bkp.tb_comentario_usuario;
	INSERT INTO arenafifadb_staging.tb_confirm_elenco_pro SELECT * FROM arenafifadb_bkp.tb_confirm_elenco_pro;
	INSERT INTO arenafifadb_staging.tb_confirmacao_temporada SELECT * FROM arenafifadb_bkp.tb_confirmacao_temporada;
	INSERT INTO arenafifadb_staging.tb_fase SELECT * FROM arenafifadb_bkp.tb_fase;
	INSERT INTO arenafifadb_staging.tb_fase_campeonato SELECT * FROM arenafifadb_bkp.tb_fase_campeonato;
	INSERT INTO arenafifadb_staging.tb_goleador SELECT * FROM arenafifadb_bkp.tb_goleador;
	INSERT INTO arenafifadb_staging.tb_goleador_jogo SELECT * FROM arenafifadb_bkp.tb_goleador_jogo;
	INSERT INTO arenafifadb_staging.tb_grupo SELECT * FROM arenafifadb_bkp.tb_grupo;
	#INSERT INTO arenafifadb_staging.tb_historico_alt_campeonato SELECT * FROM arenafifadb_bkp.tb_historico_alt_campeonato;
	#INSERT INTO arenafifadb_staging.tb_historico_alt_usuario SELECT * FROM arenafifadb_bkp.tb_historico_alt_usuario;
	INSERT INTO arenafifadb_staging.tb_historico_artilharia SELECT * FROM arenafifadb_bkp.tb_historico_artilharia;
	INSERT INTO arenafifadb_staging.tb_historico_artilharia_pro SELECT * FROM arenafifadb_bkp.tb_historico_artilharia_pro;
	INSERT INTO arenafifadb_staging.tb_historico_atual SELECT * FROM arenafifadb_bkp.tb_historico_atual;
	#INSERT INTO arenafifadb_staging.tb_historico_classificacao SELECT * FROM arenafifadb_bkp.tb_historico_classificacao;
	INSERT INTO arenafifadb_staging.tb_historico_conquista SELECT * FROM arenafifadb_bkp.tb_historico_conquista;
	INSERT INTO arenafifadb_staging.tb_historico_conquista_fut SELECT * FROM arenafifadb_bkp.tb_historico_conquista_fut;
	INSERT INTO arenafifadb_staging.tb_historico_conquista_pro SELECT * FROM arenafifadb_bkp.tb_historico_conquista_pro;
	INSERT INTO arenafifadb_staging.tb_historico_temporada SELECT * FROM arenafifadb_bkp.tb_historico_temporada;
	INSERT INTO arenafifadb_staging.tb_historico_temporada_fut SELECT * FROM arenafifadb_bkp.tb_historico_temporada_fut;
	INSERT INTO arenafifadb_staging.tb_historico_temporada_pro SELECT * FROM arenafifadb_bkp.tb_historico_temporada_pro;
	#INSERT INTO arenafifadb_staging.tb_historico_transmissao_aovivo SELECT * FROM arenafifadb_bkp.tb_historico_transmissao_aovivo;
	INSERT INTO arenafifadb_staging.tb_lista_banco_reserva SELECT * FROM arenafifadb_bkp.tb_lista_banco_reserva;
	INSERT INTO arenafifadb_staging.tb_lista_negra SELECT * FROM arenafifadb_bkp.tb_lista_negra;
	INSERT INTO arenafifadb_staging.tb_lista_negra_detalhe SELECT * FROM arenafifadb_bkp.tb_lista_negra_detalhe;
	#INSERT INTO arenafifadb_staging.tb_palpite_jogo SELECT * FROM arenafifadb_bkp.tb_palpite_jogo;
	INSERT INTO arenafifadb_staging.tb_pontuacao_campeonato SELECT * FROM arenafifadb_bkp.tb_pontuacao_campeonato;
	INSERT INTO arenafifadb_staging.tb_pote_time_grupo SELECT * FROM arenafifadb_bkp.tb_pote_time_grupo;
	#INSERT INTO arenafifadb_staging.tb_resultados_lancados SELECT * FROM arenafifadb_bkp.tb_resultados_lancados;
	INSERT INTO arenafifadb_staging.tb_tabela_jogo SELECT * FROM arenafifadb_bkp.tb_tabela_jogo;
	INSERT INTO arenafifadb_staging.tb_temporada SELECT * FROM arenafifadb_bkp.tb_temporada;
	INSERT INTO arenafifadb_staging.tb_time SELECT * FROM arenafifadb_bkp.tb_time;
	INSERT INTO arenafifadb_staging.tb_times_fase_precopa SELECT * FROM arenafifadb_bkp.tb_times_fase_precopa;
	INSERT INTO arenafifadb_staging.tb_tipo_campeonato SELECT * FROM arenafifadb_bkp.tb_tipo_campeonato;
	INSERT INTO arenafifadb_staging.tb_tipo_time SELECT * FROM arenafifadb_bkp.tb_tipo_time;
	#INSERT INTO arenafifadb_staging.tb_ultimos_acontecimentos SELECT * FROM arenafifadb_bkp.tb_ultimos_acontecimentos;
	INSERT INTO arenafifadb_staging.tb_usuario SELECT * FROM arenafifadb_bkp.tb_usuario;
	INSERT INTO arenafifadb_staging.tb_usuario_time SELECT * FROM arenafifadb_bkp.tb_usuario_time;

	UPDATE arenafifadb_staging.TB_USUARIO SET ID_USUARIO = 0 WHERE PSN_ID = 'ModeradoresAF';
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllRecordsFromBKP` $$
CREATE PROCEDURE `spDeleteAllRecordsFromBKP`()
Begin
	DELETE FROM arenafifadb_bkp.tb_campeonato;
	DELETE FROM arenafifadb_bkp.tb_campeonato_time;
	DELETE FROM arenafifadb_bkp.tb_campeonato_usuario;
	DELETE FROM arenafifadb_bkp.tb_campeonato_usuario_seg_fase;
	DELETE FROM arenafifadb_bkp.tb_classificacao;
	DELETE FROM arenafifadb_bkp.tb_comentario_jogo;
	DELETE FROM arenafifadb_bkp.tb_comentario_usuario;
	DELETE FROM arenafifadb_bkp.tb_confirm_elenco_pro;
	DELETE FROM arenafifadb_bkp.tb_confirmacao_temporada;
	DELETE FROM arenafifadb_bkp.tb_fase;
	DELETE FROM arenafifadb_bkp.tb_fase_campeonato;
	DELETE FROM arenafifadb_bkp.tb_goleador;
	DELETE FROM arenafifadb_bkp.tb_goleador_jogo;
	DELETE FROM arenafifadb_bkp.tb_grupo;
	DELETE FROM arenafifadb_bkp.tb_historico_alt_campeonato;
	DELETE FROM arenafifadb_bkp.tb_historico_alt_usuario;
	DELETE FROM arenafifadb_bkp.tb_historico_artilharia;
	DELETE FROM arenafifadb_bkp.tb_historico_artilharia_pro;
	DELETE FROM arenafifadb_bkp.tb_historico_atual;
	DELETE FROM arenafifadb_bkp.tb_historico_classificacao;
	DELETE FROM arenafifadb_bkp.tb_historico_conquista;
	DELETE FROM arenafifadb_bkp.tb_historico_conquista_fut;
	DELETE FROM arenafifadb_bkp.tb_historico_conquista_pro;
	DELETE FROM arenafifadb_bkp.tb_historico_temporada;
	DELETE FROM arenafifadb_bkp.tb_historico_temporada_fut;
	DELETE FROM arenafifadb_bkp.tb_historico_temporada_pro;
	DELETE FROM arenafifadb_bkp.tb_historico_transmissao_aovivo;
	DELETE FROM arenafifadb_bkp.tb_lista_banco_reserva;
	DELETE FROM arenafifadb_bkp.tb_lista_negra;
	DELETE FROM arenafifadb_bkp.tb_lista_negra_detalhe;
	DELETE FROM arenafifadb_bkp.tb_palpite_jogo;
	DELETE FROM arenafifadb_bkp.tb_pontuacao_campeonato;
	DELETE FROM arenafifadb_bkp.tb_pote_time_grupo;
	DELETE FROM arenafifadb_bkp.tb_resultados_lancados;
	DELETE FROM arenafifadb_bkp.tb_tabela_jogo;
	DELETE FROM arenafifadb_bkp.tb_temporada;
	DELETE FROM arenafifadb_bkp.tb_time;
	DELETE FROM arenafifadb_bkp.tb_times_fase_precopa;
	DELETE FROM arenafifadb_bkp.tb_tipo_campeonato;
	DELETE FROM arenafifadb_bkp.tb_tipo_time;
	DELETE FROM arenafifadb_bkp.tb_ultimos_acontecimentos;
	DELETE FROM arenafifadb_bkp.tb_usuario;
	DELETE FROM arenafifadb_bkp.tb_usuario_time;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllRecordsFromDBOnLine` $$
CREATE PROCEDURE `spDeleteAllRecordsFromDBOnLine`()
Begin
	DELETE FROM arenafifadb.tb_campeonato;
	DELETE FROM arenafifadb.tb_campeonato_time;
	DELETE FROM arenafifadb.tb_campeonato_usuario;
	DELETE FROM arenafifadb.tb_campeonato_usuario_seg_fase;
	DELETE FROM arenafifadb.tb_classificacao;
	DELETE FROM arenafifadb.tb_comentario_jogo;
	DELETE FROM arenafifadb.tb_comentario_usuario;
	DELETE FROM arenafifadb.tb_confirm_elenco_pro;
	DELETE FROM arenafifadb.tb_confirmacao_temporada;
	DELETE FROM arenafifadb.tb_fase;
	DELETE FROM arenafifadb.tb_fase_campeonato;
	DELETE FROM arenafifadb.tb_goleador;
	DELETE FROM arenafifadb.tb_goleador_jogo;
	DELETE FROM arenafifadb.tb_grupo;
	DELETE FROM arenafifadb.tb_historico_alt_campeonato;
	DELETE FROM arenafifadb.tb_historico_alt_usuario;
	DELETE FROM arenafifadb.tb_historico_artilharia;
	DELETE FROM arenafifadb.tb_historico_artilharia_pro;
	DELETE FROM arenafifadb.tb_historico_atual;
	DELETE FROM arenafifadb.tb_historico_classificacao;
	DELETE FROM arenafifadb.tb_historico_conquista;
	DELETE FROM arenafifadb.tb_historico_conquista_fut;
	DELETE FROM arenafifadb.tb_historico_conquista_pro;
	DELETE FROM arenafifadb.tb_historico_temporada;
	DELETE FROM arenafifadb.tb_historico_temporada_fut;
	DELETE FROM arenafifadb.tb_historico_temporada_pro;
	DELETE FROM arenafifadb.tb_historico_transmissao_aovivo;
	DELETE FROM arenafifadb.tb_lista_banco_reserva;
	DELETE FROM arenafifadb.tb_lista_negra;
	DELETE FROM arenafifadb.tb_lista_negra_detalhe;
	DELETE FROM arenafifadb.tb_palpite_jogo;
	DELETE FROM arenafifadb.tb_pontuacao_campeonato;
	DELETE FROM arenafifadb.tb_pote_time_grupo;
	DELETE FROM arenafifadb.tb_resultados_lancados;
	DELETE FROM arenafifadb.tb_tabela_jogo;
	DELETE FROM arenafifadb.tb_temporada;
	DELETE FROM arenafifadb.tb_time;
	DELETE FROM arenafifadb.tb_times_fase_precopa;
	DELETE FROM arenafifadb.tb_tipo_campeonato;
	DELETE FROM arenafifadb.tb_tipo_time;
	DELETE FROM arenafifadb.tb_ultimos_acontecimentos;
	DELETE FROM arenafifadb.tb_usuario;
	DELETE FROM arenafifadb.tb_usuario_time;
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllRecordsFromDB` $$
CREATE PROCEDURE `spDeleteAllRecordsFromDB`()
Begin
	#DELETE FROM arenafifadb_staging.tb_campeonato;
	TRUNCATE TABLE arenafifadb_staging.tb_campeonato;
	DELETE FROM arenafifadb_staging.tb_campeonato_time;
	DELETE FROM arenafifadb_staging.tb_campeonato_usuario;
	DELETE FROM arenafifadb_staging.tb_campeonato_usuario_seg_fase;
	DELETE FROM arenafifadb_staging.tb_classificacao;
	#DELETE FROM arenafifadb_staging.tb_comentario_jogo;
	DELETE FROM arenafifadb_staging.tb_comentario_usuario;
	DELETE FROM arenafifadb_staging.tb_confirm_elenco_pro;
	DELETE FROM arenafifadb_staging.tb_confirmacao_temporada;
	DELETE FROM arenafifadb_staging.tb_fase;
	DELETE FROM arenafifadb_staging.tb_fase_campeonato;
	DELETE FROM arenafifadb_staging.tb_goleador;
	DELETE FROM arenafifadb_staging.tb_goleador_jogo;
	DELETE FROM arenafifadb_staging.tb_grupo;
	#DELETE FROM arenafifadb_staging.tb_historico_alt_campeonato;
	#DELETE FROM arenafifadb_staging.tb_historico_alt_usuario;
	DELETE FROM arenafifadb_staging.tb_historico_artilharia;
	DELETE FROM arenafifadb_staging.tb_historico_artilharia_pro;
	DELETE FROM arenafifadb_staging.tb_historico_atual;
	#DELETE FROM arenafifadb_staging.tb_historico_classificacao;
	DELETE FROM arenafifadb_staging.tb_historico_conquista;
	DELETE FROM arenafifadb_staging.tb_historico_conquista_fut;
	DELETE FROM arenafifadb_staging.tb_historico_conquista_pro;
	DELETE FROM arenafifadb_staging.tb_historico_temporada;
	DELETE FROM arenafifadb_staging.tb_historico_temporada_fut;
	DELETE FROM arenafifadb_staging.tb_historico_temporada_pro;
	#DELETE FROM arenafifadb_staging.tb_historico_transmissao_aovivo;
	#DELETE FROM arenafifadb_staging.tb_lista_banco_reserva;
	TRUNCATE TABLE arenafifadb_staging.tb_lista_banco_reserva;
	DELETE FROM arenafifadb_staging.tb_lista_negra;
	DELETE FROM arenafifadb_staging.tb_lista_negra_detalhe;
	#DELETE FROM arenafifadb_staging.tb_palpite_jogo;
	DELETE FROM arenafifadb_staging.tb_pontuacao_campeonato;
	DELETE FROM arenafifadb_staging.tb_pote_time_grupo;
	#DELETE FROM arenafifadb_staging.tb_resultados_lancados;
	#DELETE FROM arenafifadb_staging.tb_tabela_jogo;
	#DELETE FROM arenafifadb_staging.tb_temporada;
	#DELETE FROM arenafifadb_staging.tb_time;
	TRUNCATE TABLE arenafifadb_staging.tb_tabela_jogo;
	TRUNCATE TABLE arenafifadb_staging.tb_temporada;
	TRUNCATE TABLE arenafifadb_staging.tb_time;
	DELETE FROM arenafifadb_staging.tb_times_fase_precopa;
	DELETE FROM arenafifadb_staging.tb_tipo_campeonato;
	DELETE FROM arenafifadb_staging.tb_tipo_time;
	#DELETE FROM arenafifadb_staging.tb_ultimos_acontecimentos;
	DELETE FROM arenafifadb_staging.tb_usuario;
	#TRUNCATE TABLE arenafifadb_staging.tb_usuario;
	DELETE FROM arenafifadb_staging.tb_usuario_time;
	
	UPDATE TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS SET ID_CAMPEONATO = 0;
	UPDATE TB_GENERATE_NEWSEASON_CHAMPIONSHIPCUP_DETAILS SET ID_CAMPEONATO = 0;
End$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spCreateNewFieldsAndProcess` $$
CREATE PROCEDURE `spCreateNewFieldsAndProcess`()
Begin
	UPDATE TB_TIME SET IN_TIME_EXCLUIDO_TEMP_ATUAL = NULL;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateIDChampionshipGenerateNewSeason` $$
CREATE PROCEDURE `spUpdateIDChampionshipGenerateNewSeason`()
Begin
	UPDATE TB_TIME SET IN_TIME_EXCLUIDO_TEMP_ATUAL = NULL;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddNewChampionship` $$
CREATE PROCEDURE `spAddNewChampionship`(pIdTemp INTEGER, pTpModalidade CHAR(3), pSgCampeonato CHAR(7), pTpCamp VARCHAR(4), pByGroup TINYINT)
Begin
	DECLARE _idCampNew INTEGER DEFAULT NULL;
	
	SET _idCampNew = fcAddNovoCampeonato(pIdTemp, pTpModalidade, pSgCampeonato, pTpCamp, pByGroup);
	
	SELECT _idCampNew as idCampNew;
End$$
DELIMITER ;



DELIMITER $$
DROP FUNCTION IF EXISTS `fcAddNovoCampeonato` $$
CREATE FUNCTION `fcAddNovoCampeonato`(pIdTemp INTEGER, 	pTpModalidade CHAR(3), pSgCampeonato CHAR(7), pTpCamp VARCHAR(4), pByGroup TINYINT) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idCampOld INTEGER DEFAULT NULL;
	DECLARE _idCampNew INTEGER DEFAULT NULL;
	DECLARE _campLeague INTEGER DEFAULT NULL;
	DECLARE _startDate DATE DEFAULT NULL;
	DECLARE _teams INTEGER DEFAULT NULL;
	DECLARE _daysStage0 INTEGER DEFAULT NULL;
	DECLARE _daysPlayoff INTEGER DEFAULT NULL;
	DECLARE _relegate INTEGER DEFAULT NULL;
	DECLARE _destinyID INTEGER DEFAULT NULL;
	DECLARE _sourceID INTEGER DEFAULT NULL;
	DECLARE _byGroup TINYINT DEFAULT NULL;
	DECLARE _groups INTEGER DEFAULT NULL;
	DECLARE _doubleRound INTEGER DEFAULT NULL;
	DECLARE _count INTEGER DEFAULT NULL;
	DECLARE _byPots TINYINT(1) DEFAULT 0;
	DECLARE _hasSerie INTEGER DEFAULT 0;
	DECLARE _idSerieA INTEGER DEFAULT 0;
	DECLARE _idSerieB INTEGER DEFAULT 0;
	DECLARE _idSerieC INTEGER DEFAULT 0;
	DECLARE _idSerieD INTEGER DEFAULT 0;
	DECLARE _hasDestiny TINYINT(1) DEFAULT 0;
	DECLARE _hasSource TINYINT(1) DEFAULT 0;
	DECLARE _hasSerieA TINYINT(1) DEFAULT 0;
	DECLARE _hasSerieB TINYINT(1) DEFAULT 0;
	DECLARE _hasSerieC TINYINT(1) DEFAULT 0;
	DECLARE _hasSerieA_B TINYINT(1) DEFAULT 0;
	DECLARE _hasSerieA_B_C TINYINT(1) DEFAULT 0;
	DECLARE _hasSerieA_B_C_D TINYINT(1) DEFAULT 0;
	DECLARE _sgSerieA CHAR(7) DEFAULT "SERIE_A";
	DECLARE _sgSerieB CHAR(7) DEFAULT "SERIE_B";
	DECLARE _sgSerieC CHAR(7) DEFAULT "SERIE_C";
	DECLARE _sgSerieD CHAR(7) DEFAULT "SERIE_D";
	
	SELECT count(1) into _campLeague FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS
	WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = pSgCampeonato;
	
	IF _campLeague > 0 THEN
	
		SELECT ID_CAMPEONATO into _idCampOld FROM TB_CAMPEONATO 
		WHERE ID_TEMPORADA <= pIdTemp AND SG_TIPO_CAMPEONATO = pTpCamp
		ORDER BY ID_CAMPEONATO DESC
		limit 1;
		
		IF (_idCampOld IS NULL) THEN
		
			SET _idCampNew = 0;
		
		ELSE
		
			INSERT INTO `TB_CAMPEONATO` (`ID_TEMPORADA`, `NM_CAMPEONATO`, `QT_TIMES`, `DT_INICIO`, `DT_SORTEIO`, `IN_CAMPEONATO_ATIVO`, `IN_CAMPEONATO_GRUPO`, `IN_CAMPEONATO_TURNO_UNICO`, 
										 `IN_CAMPEONATO_TURNO_RETURNO`, `QT_GRUPOS`, `IN_SISTEMA_MATA`, `IN_SISTEMA_IDA_VOLTA`, `QT_TIMES_CLASSIFICADOS`, `QT_TIMES_REBAIXADOS`, 
										 `DS_LOGO_PEQ`, `DS_LOGO_MED`, `ID_USUARIO_MODERADOR`, `DS_FRIENDS_LEAGUE`, `QT_DIAS_PARTIDA_CLASSIFICACAO`, `QT_DIAS_PARTIDA_FASE_MATAXMATA`, 
										 `SG_TIPO_CAMPEONATO`, `QT_TIMES_PROX_CLASSIF`, `IN_CONSOLE`, `ID_USUARIO_2OMODERADOR`, `ID_USUARIO_1OAUXILIAR`, `ID_USUARIO_2OAUXILIAR`, 
										 `ID_USUARIO_3OAUXILIAR`, `DT_ULTIMA_ALTERACAO`, `DS_LOGIN_ALTERACAO`, `DS_FASE_MATAXMATA_MONTADA`, `QT_TIMES_ACESSO`, `IN_DISPUTA_3O_4O_LUGAR`, 
										 `ID_CAMPEONATO_DESTINO`, `ID_CAMPEONATO_ORIGEM`, `IN_POSICAO_ORIGEM`, `IN_DOUBLE_ROUND`) 
			SELECT `ID_TEMPORADA`, `NM_CAMPEONATO`, `QT_TIMES`, `DT_INICIO`, `DT_SORTEIO`, `IN_CAMPEONATO_ATIVO`, `IN_CAMPEONATO_GRUPO`, `IN_CAMPEONATO_TURNO_UNICO`, 
				   `IN_CAMPEONATO_TURNO_RETURNO`, `QT_GRUPOS`, `IN_SISTEMA_MATA`, `IN_SISTEMA_IDA_VOLTA`, `QT_TIMES_CLASSIFICADOS`, `QT_TIMES_REBAIXADOS`, 
				   `DS_LOGO_PEQ`, `DS_LOGO_MED`, `ID_USUARIO_MODERADOR`, `DS_FRIENDS_LEAGUE`, `QT_DIAS_PARTIDA_CLASSIFICACAO`, `QT_DIAS_PARTIDA_FASE_MATAXMATA`, 
				   `SG_TIPO_CAMPEONATO`, `QT_TIMES_PROX_CLASSIF`, `IN_CONSOLE`, `ID_USUARIO_2OMODERADOR`, `ID_USUARIO_1OAUXILIAR`, `ID_USUARIO_2OAUXILIAR`, 
				   `ID_USUARIO_3OAUXILIAR`, `DT_ULTIMA_ALTERACAO`, `DS_LOGIN_ALTERACAO`, `DS_FASE_MATAXMATA_MONTADA`, `QT_TIMES_ACESSO`, `IN_DISPUTA_3O_4O_LUGAR`, 
				   `ID_CAMPEONATO_DESTINO`, `ID_CAMPEONATO_ORIGEM`, `IN_POSICAO_ORIGEM`, `IN_DOUBLE_ROUND`
			FROM TB_CAMPEONATO WHERE ID_CAMPEONATO = _idCampOld;
		
			SELECT ID_CAMPEONATO into _idCampNew FROM TB_CAMPEONATO 
			ORDER BY ID_CAMPEONATO DESC
			limit 1;

			SELECT DATA_INICIO, QT_TIMES, DIAS_FASE_CLASSIFICACAO, DIAS_FASE_PLAYOFF, QT_TIMES_REBAIXADOS, IN_CAMPEONATO_GRUPO, QT_GRUPOS, IN_DOUBLE_ROUND, IN_CAMPEONATO_GRUPO_POR_POTES
			  into _startDate, _teams, _daysStage0, _daysPlayoff, _relegate, _byGroup, _groups, _doubleRound, _byPots
			FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS
			WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = pSgCampeonato;

			UPDATE TB_CAMPEONATO
			SET ID_TEMPORADA = pIdTemp, IN_CAMPEONATO_ATIVO = TRUE, QT_TIMES = _teams, DT_INICIO = _startDate, 
				DT_SORTEIO = (SELECT DATA_SORTEIO FROM TB_GENERATE_NEWSEASON_MAINDETAILS WHERE ID_TEMPORADA = pIdTemp),
			    IN_CAMPEONATO_GRUPO = _byGroup, QT_GRUPOS = _groups, QT_TIMES_REBAIXADOS = _relegate, QT_DIAS_PARTIDA_CLASSIFICACAO = _daysStage0,
				QT_DIAS_PARTIDA_FASE_MATAxMATA = _daysPlayoff, IN_DOUBLE_ROUND = _doubleRound
			WHERE ID_CAMPEONATO = _idCampNew;
			
			INSERT INTO TB_FASE_CAMPEONATO (ID_CAMPEONATO, ID_FASE, IN_ORDENACAO) 
			SELECT _idCampNew, ID_FASE, IN_ORDENACAO FROM TB_FASE_CAMPEONATO WHERE ID_Campeonato = _idCampOld;

			SELECT count(1) into _count FROM TB_FASE_CAMPEONATO WHERE ID_Campeonato = _idCampNew;
			IF _count = 0 THEN
				INSERT INTO TB_FASE_CAMPEONATO (ID_CAMPEONATO, ID_FASE, IN_ORDENACAO) 
				SELECT _idCampNew, ID_FASE, IN_ORDENACAO FROM TB_FASE_CAMPEONATO WHERE ID_Campeonato = (_idCampNew-1);
			ELSEIF pTpModalidade = "H2H" THEN
				INSERT INTO TB_CAMPEONATO_USUARIO (ID_CAMPEONATO, ID_USUARIO, DT_ENTRADA) 
				SELECT _idCampNew, ID_USUARIO, DT_ENTRADA FROM TB_CAMPEONATO_USUARIO WHERE ID_Campeonato = _idCampOld;
			END IF;
			
			SET _count = 1;
			WHILE (_count <= _groups) DO
			
				INSERT INTO TB_GRUPO (ID_CAMPEONATO, ID_GRUPO, NM_GRUPO) 
				VALUES (_idCampNew, _count, CONCAT('Grupo ', _count));

				SET _count = _count + 1;

			END WHILE;
			
			IF pTpModalidade = "FUT" THEN
			
				call spValidateIDTimeTableStandard(pIdTemp, _idCampNew, pTpModalidade, pSgCampeonato);
				call spAddUsuTimeFUTFromStandard(pIdTemp, _idCampNew, pTpModalidade, pSgCampeonato);
			
				call spAssumeTimes(_idCampNew, "FUT");
		
			ELSEIF pTpModalidade = "PRO" THEN
			
				call spAddUsuarioPROCLUB(pIdTemp, _idCampNew, 14);
				call spAddUsuarioPROCLUB(pIdTemp, _idCampNew, 15);
				call spAddUsuarioPROCLUB(pIdTemp, _idCampNew, 13);
			
				call spAssumeTimes(_idCampNew, "PRO");

			ELSE
			
				INSERT INTO TB_CAMPEONATO_TIME (ID_CAMPEONATO, ID_TIME) 
				SELECT _idCampNew, ITEM_ID FROM TB_GENERATE_NEWSEASON_ITEM_STANDARD S
				WHERE S.TP_MODALIDADE = pTpModalidade AND S.SG_CAMPEONATO = pSgCampeonato;
				
			END IF;
			
			UPDATE TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS SET ID_CAMPEONATO = _idCampNew
			WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = pSgCampeonato;

		END IF;
	
	ELSE

		SELECT ID_CAMPEONATO into _idCampOld FROM TB_CAMPEONATO 
		WHERE ID_TEMPORADA <= pIdTemp AND SG_TIPO_CAMPEONATO = pTpCamp AND IN_CAMPEONATO_GRUPO = pByGroup
		ORDER BY ID_CAMPEONATO DESC
		limit 1;
		
		IF (_idCampOld IS NULL) THEN
		
			SET _idCampNew = 0;
		
		ELSE
		
			INSERT INTO `TB_CAMPEONATO` (`ID_TEMPORADA`, `NM_CAMPEONATO`, `QT_TIMES`, `DT_INICIO`, `DT_SORTEIO`, `IN_CAMPEONATO_ATIVO`, `IN_CAMPEONATO_GRUPO`, `IN_CAMPEONATO_TURNO_UNICO`, 
										 `IN_CAMPEONATO_TURNO_RETURNO`, `QT_GRUPOS`, `IN_SISTEMA_MATA`, `IN_SISTEMA_IDA_VOLTA`, `QT_TIMES_CLASSIFICADOS`, `QT_TIMES_REBAIXADOS`, 
										 `DS_LOGO_PEQ`, `DS_LOGO_MED`, `ID_USUARIO_MODERADOR`, `DS_FRIENDS_LEAGUE`, `QT_DIAS_PARTIDA_CLASSIFICACAO`, `QT_DIAS_PARTIDA_FASE_MATAXMATA`, 
										 `SG_TIPO_CAMPEONATO`, `QT_TIMES_PROX_CLASSIF`, `IN_CONSOLE`, `ID_USUARIO_2OMODERADOR`, `ID_USUARIO_1OAUXILIAR`, `ID_USUARIO_2OAUXILIAR`, 
										 `ID_USUARIO_3OAUXILIAR`, `DT_ULTIMA_ALTERACAO`, `DS_LOGIN_ALTERACAO`, `DS_FASE_MATAXMATA_MONTADA`, `QT_TIMES_ACESSO`, `IN_DISPUTA_3O_4O_LUGAR`, 
										 `ID_CAMPEONATO_DESTINO`, `ID_CAMPEONATO_ORIGEM`, `IN_POSICAO_ORIGEM`, `IN_DOUBLE_ROUND`) 
			SELECT `ID_TEMPORADA`, `NM_CAMPEONATO`, `QT_TIMES`, `DT_INICIO`, `DT_SORTEIO`, `IN_CAMPEONATO_ATIVO`, `IN_CAMPEONATO_GRUPO`, `IN_CAMPEONATO_TURNO_UNICO`, 
				   `IN_CAMPEONATO_TURNO_RETURNO`, `QT_GRUPOS`, `IN_SISTEMA_MATA`, `IN_SISTEMA_IDA_VOLTA`, `QT_TIMES_CLASSIFICADOS`, `QT_TIMES_REBAIXADOS`, 
				   `DS_LOGO_PEQ`, `DS_LOGO_MED`, `ID_USUARIO_MODERADOR`, `DS_FRIENDS_LEAGUE`, `QT_DIAS_PARTIDA_CLASSIFICACAO`, `QT_DIAS_PARTIDA_FASE_MATAXMATA`, 
				   `SG_TIPO_CAMPEONATO`, `QT_TIMES_PROX_CLASSIF`, `IN_CONSOLE`, `ID_USUARIO_2OMODERADOR`, `ID_USUARIO_1OAUXILIAR`, `ID_USUARIO_2OAUXILIAR`, 
				   `ID_USUARIO_3OAUXILIAR`, `DT_ULTIMA_ALTERACAO`, `DS_LOGIN_ALTERACAO`, `DS_FASE_MATAXMATA_MONTADA`, `QT_TIMES_ACESSO`, `IN_DISPUTA_3O_4O_LUGAR`, 
				   `ID_CAMPEONATO_DESTINO`, `ID_CAMPEONATO_ORIGEM`, `IN_POSICAO_ORIGEM`, `IN_DOUBLE_ROUND`
			FROM TB_CAMPEONATO WHERE ID_CAMPEONATO = _idCampOld;
		
			SELECT ID_CAMPEONATO into _idCampNew FROM TB_CAMPEONATO 
			ORDER BY ID_CAMPEONATO DESC
			limit 1;

			SELECT DATA_INICIO, QT_TIMES, DIAS_FASE_CLASSIFICACAO, DIAS_FASE_PLAYOFF, IN_CAMPEONATO_GRUPO, QT_GRUPOS, IN_CAMPEONATO_GRUPO_POR_POTES, 
				   IN_CAMPEONATO_DESTINO, IN_CAMPEONATO_ORIGEM
			  into _startDate, _teams, _daysStage0, _daysPlayoff, _byGroup, _groups, _byPots, _hasDestiny, _hasSource
			FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPCUP_DETAILS
			WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = pSgCampeonato;

			UPDATE TB_CAMPEONATO
			SET ID_TEMPORADA = pIdTemp, IN_CAMPEONATO_ATIVO = TRUE, QT_TIMES = _teams, DT_INICIO = _startDate, 
				DT_SORTEIO = (SELECT DATA_SORTEIO FROM TB_GENERATE_NEWSEASON_MAINDETAILS WHERE ID_TEMPORADA = pIdTemp),
			    IN_CAMPEONATO_GRUPO = _byGroup, QT_GRUPOS = _groups, QT_DIAS_PARTIDA_CLASSIFICACAO = _daysStage0,
				QT_DIAS_PARTIDA_FASE_MATAxMATA = _daysPlayoff
			WHERE ID_CAMPEONATO = _idCampNew;
			
			IF _hasDestiny = True OR _hasDestiny = 1 THEN
			
				UPDATE TB_CAMPEONATO
				SET ID_CAMPEONATO_DESTINO = (_idCampNew+1), IN_POSICAO_ORIGEM = 3
				WHERE ID_CAMPEONATO = _idCampNew;
				
			END IF;
			
			IF _hasSource = True OR _hasSource = 1 THEN
			
				UPDATE TB_CAMPEONATO
				SET ID_CAMPEONATO_ORIGEM = (_idCampNew-1), IN_POSICAO_ORIGEM = 3
				WHERE ID_CAMPEONATO = _idCampNew;
				
			END IF;
			
			INSERT INTO TB_FASE_CAMPEONATO (ID_CAMPEONATO, ID_FASE, IN_ORDENACAO) 
			SELECT _idCampNew, ID_FASE, IN_ORDENACAO FROM TB_FASE_CAMPEONATO WHERE ID_Campeonato = _idCampOld;

			SELECT count(1) into _count FROM TB_FASE_CAMPEONATO WHERE ID_Campeonato = _idCampNew;
			IF _count = 0 THEN
				IF pSgCampeonato = 'WORLDCP' THEN
					INSERT INTO TB_FASE_CAMPEONATO VALUE (_idCampNew, 0, 1);
					INSERT INTO TB_FASE_CAMPEONATO VALUE (_idCampNew, 2, 2);
					INSERT INTO TB_FASE_CAMPEONATO VALUE (_idCampNew, 3, 3);
					INSERT INTO TB_FASE_CAMPEONATO VALUE (_idCampNew, 4, 4);
					INSERT INTO TB_FASE_CAMPEONATO VALUE (_idCampNew, 5, 5);
				ELSEIF pSgCampeonato = 'EUROPLG' AND pIdTemp = 23 THEN
					INSERT INTO TB_FASE_CAMPEONATO (ID_CAMPEONATO, ID_FASE, IN_ORDENACAO) 
					SELECT _idCampNew, ID_FASE, IN_ORDENACAO FROM TB_FASE_CAMPEONATO WHERE ID_Campeonato = (_idCampNew-1);
				END IF;
			END IF;
			
			IF pTpModalidade = "PRO" AND pSgCampeonato = 'SERIE_A' AND pIdTemp = 23 THEN 
			
				INSERT INTO TB_FASE_CAMPEONATO VALUES (_idCampNew, 2, 2);
			
			END IF;

			SET _count = 1;
			WHILE (_count <= _groups) DO
			
				INSERT INTO TB_GRUPO (ID_CAMPEONATO, ID_GRUPO, NM_GRUPO) 
				VALUES (_idCampNew, _count, CONCAT('Grupo ', _count));
				
				SET _count = _count + 1;

			END WHILE;
			
			UPDATE TB_GENERATE_NEWSEASON_CHAMPIONSHIPCUP_DETAILS SET ID_CAMPEONATO = _idCampNew
			WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = pSgCampeonato;
			
			SELECT ID_CAMPEONATO into _idSerieA
			FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS
			WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = 'SERIE_A' AND IN_CAMPEONATO_ATIVO = TRUE;
		
			SELECT ID_CAMPEONATO into _idSerieB
			FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS
			WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = 'SERIE_B' AND IN_CAMPEONATO_ATIVO = TRUE;
		
			SELECT ID_CAMPEONATO into _idSerieC
			FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS
			WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = 'SERIE_C' AND IN_CAMPEONATO_ATIVO = TRUE;
		
			SELECT ID_CAMPEONATO into _idSerieD
			FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS
			WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = 'SERIE_D' AND IN_CAMPEONATO_ATIVO = TRUE;
			
			SET _idSerieA = COALESCE(_idSerieA, 0);
			SET _idSerieB = COALESCE(_idSerieB, 0);
			SET _idSerieC = COALESCE(_idSerieC, 0);
			SET _idSerieD = COALESCE(_idSerieD, 0);
			
			IF pSgCampeonato = 'WORLDCP' THEN
			
				INSERT INTO TB_CAMPEONATO_TIME (ID_CAMPEONATO, ID_TIME) 
				SELECT _idCampNew, ITEM_ID FROM TB_GENERATE_NEWSEASON_ITEM_STANDARD S
				WHERE S.TP_MODALIDADE = pTpModalidade AND S.SG_CAMPEONATO = pSgCampeonato;
				
				call spAddUsuarioWorldCup(pIdTemp, _idCampNew, _idSerieA, _idSerieB, _idSerieC);
			
			ELSE

				IF (pSgCampeonato = 'CHAMPLG' OR pSgCampeonato = 'EUROPLG') AND pIdTemp = 23 THEN 
				
					DELETE FROM TB_FASE_CAMPEONATO WHERE ID_CAMPEONATO = _idCampNew AND ID_FASE = 1;
				
				END IF;

				SELECT IN_APENAS_SERIEA, IN_APENAS_SERIEB, IN_APENAS_SERIEC, IN_SERIEA_B, IN_SERIEA_B_C, IN_SERIEA_B_C_D
				  into _hasSerieA, _hasSerieB, _hasSerieC, _hasSerieA_B, _hasSerieA_B_C, _hasSerieA_B_C_D
				FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPCUP_DETAILS
				WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = pSgCampeonato;
				
				IF _hasSerieA = True OR _hasSerieA = 1 THEN
					
					SET _idSerieB = 0;
					SET _idSerieC = 0;
					SET _idSerieD = 0;
					SET _sgSerieB = "";
					SET _sgSerieC = "";
					SET _sgSerieD = "";
				
				ELSEIF _hasSerieB = True OR _hasSerieB = 1 THEN

					SET _idSerieA = 0;
					SET _idSerieC = 0;
					SET _idSerieD = 0;
					SET _sgSerieA = "";
					SET _sgSerieC = "";
					SET _sgSerieD = "";
				
				ELSEIF _hasSerieC = True OR _hasSerieC = 1 THEN

					SET _idSerieA = 0;
					SET _idSerieB = 0;
					SET _idSerieD = 0;
					SET _sgSerieA = "";
					SET _sgSerieB = "";
					SET _sgSerieD = "";
				
				ELSEIF _hasSerieA_B = True OR _hasSerieA_B = 1 THEN

					SET _idSerieC = 0;
					SET _idSerieD = 0;
					SET _sgSerieC = "";
					SET _sgSerieD = "";
				
				ELSEIF _hasSerieA_B_C = True OR _hasSerieA_B_C = 1 THEN

					SET _idSerieD = 0;
					SET _sgSerieD = "";
				
				END IF;
				
				INSERT INTO TB_CAMPEONATO_TIME
				SELECT _idCampNew, C.ID_TIME FROM TB_CAMPEONATO_TIME C WHERE C.ID_CAMPEONATO IN (_idSerieA, _idSerieB, _idSerieC, _idSerieD) 
				ORDER BY C.ID_TIME;

				INSERT INTO TB_CAMPEONATO_USUARIO
				SELECT _idCampNew, C.ID_USUARIO, NULL FROM TB_CAMPEONATO_USUARIO C WHERE  C.ID_CAMPEONATO IN (_idSerieA, _idSerieB, _idSerieC, _idSerieD) 
				ORDER BY C.ID_USUARIO;
				
				IF _byPots = True OR _byPots = 1 THEN
			
					INSERT INTO TB_POTE_TIME_GRUPO 
					SELECT _idCampNew, C.ITEM_ID, C.ITEM_POTE_NUMBER
					FROM TB_GENERATE_NEWSEASON_ITEM_STANDARD C
					WHERE C.TP_MODALIDADE = pTpModalidade AND C.SG_CAMPEONATO IN (_sgSerieA, _sgSerieB, _sgSerieC, _sgSerieD);

				END IF;
			
				IF pTpModalidade = "FUT" OR pTpModalidade = "PRO" THEN
				
					SET @row_number = 1;
	
					insert into TB_USUARIO_TIME (ID_CAMPEONATO, ID_USUARIO, ID_TIME, DT_SORTEIO, INDICADOR_ORDEM_SORTEIO)
					SELECT _idCampNew, C.ID_USUARIO, C.ID_TIME, now(), (@row_number:=@row_number + 1) FROM  TB_USUARIO_TIME C
					WHERE C.ID_CAMPEONATO IN (_idSerieA, _idSerieB, _idSerieC, _idSerieD) ;
				
				END IF;
				
			END IF;
			
		END IF;

	END IF;
	
	IF _idCampNew > 0 AND pSgCampeonato <> 'UEFACUP' AND pSgCampeonato <> 'FUT-CUP' AND pSgCampeonato <> 'PRO-CUP' THEN
	
		INSERT INTO TB_CLASSIFICACAO
		SELECT T.ID_CAMPEONATO, T.ID_TIME, 0, 0, 0, 0, 0, 0, 0, 0, NULL FROM TB_CAMPEONATO_TIME T WHERE T.ID_CAMPEONATO = _idCampNew;
	
	END IF;
	
	IF _idCampNew > 0 AND (_byPots = True OR _byPots = 1) THEN
	
		INSERT INTO TB_POTE_TIME_GRUPO 
		SELECT _idCampNew, C.ITEM_ID, C.ITEM_POTE_NUMBER
		FROM TB_GENERATE_NEWSEASON_ITEM_STANDARD C
		WHERE C.TP_MODALIDADE = pTpModalidade AND C.SG_CAMPEONATO = pSgCampeonato;
		
	END IF;
	
	RETURN _idCampNew;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddUsuarioWorldCup` $$
CREATE PROCEDURE `spAddUsuarioWorldCup`(
	pIdTemp INTEGER,
	pIdCamp INTEGER,
	pIdSerieA INTEGER,
	pIdSerieB INTEGER,
	pIdSerieC INTEGER
)
Begin
	DECLARE _LIMIT_BLACK_LIST INTEGER DEFAULT 8;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _blackList INTEGER DEFAULT NULL;
	DECLARE _count INTEGER DEFAULT 1;
	DECLARE _finished INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT X.ID_USUARIO, X.PT_LSTNEGRA FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID,  
		   (SELECT CASE WHEN T.id_usuario > 0 THEN 1 ELSE 0 END FROM TB_CONFIRMACAO_TEMPORADA T WHERE T.ID_Temporada = pIdTemp   AND T.IN_CONFIRMACAO = 1 AND T.ID_CAMPEONATO IN (1,2,3,4) AND T.ID_USUARIO = C.ID_USUARIO) as IN_CONFIRMA_DIVISAO,  
		   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL,  
		   (SELECT COALESCE(SUM(H.PT_TOTAL), 0) FROM TB_HISTORICO_ATUAL H WHERE H.ID_USUARIO = U.ID_USUARIO AND TP_MODALIDADE = 'H2H' LIMIT 1) as PT_TOTAL_ATUAL,  
		   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada =   (pIdTemp-1)   AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA  
		   FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U   
		   WHERE C.ID_TEMPORADA =   pIdTemp 
		   AND C.ID_CAMPEONATO IN (5)  
		   AND U.IN_USUARIO_ATIVO = TRUE  
		   AND U.IN_DESEJA_PARTICIPAR = 1  
		   AND C.IN_CONFIRMACAO = 1  
		   AND C.ID_USUARIO IN (SELECT ID_USUARIO FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO in (pIdSerieA, pIdSerieB, pIdSerieC)) 
		   AND C.ID_USUARIO = U.ID_USUARIO)  as X
		   ORDER BY X.IN_CONFIRMACAO DESC, X.IN_CONFIRMA_DIVISAO DESC, (COALESCE(X.PT_TOTAL,0)+X.PT_TOTAL_ATUAL) DESC, X.DS_STATUS, X.ID_USUARIO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _blackList;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _blackList = COALESCE(_blackList, 0);
		
		IF _count <= 32 AND _blackList <= _LIMIT_BLACK_LIST THEN
		
			INSERT INTO TB_CAMPEONATO_USUARIO VALUES (pIdCamp, _idUsu, NULL);
			
			SET _count = _count + 1;
		
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;

End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddUsuarioPROCLUB` $$
CREATE PROCEDURE `spAddUsuarioPROCLUB`(
	pIdTemp INTEGER,
	pIdCamp INTEGER,
	pIdCampRenewal INTEGER
)
Begin
	DECLARE _LIMIT_BLACK_LIST INTEGER DEFAULT 16;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE _countCurrent INTEGER DEFAULT 0;
	DECLARE _countRest INTEGER DEFAULT 0;
	DECLARE _TotLstNegra INTEGER DEFAULT 0;
	DECLARE _count INTEGER DEFAULT 1;
	DECLARE _QtTotalTimes INTEGER DEFAULT 0;
	DECLARE _teamName VARCHAR(50) DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
		SELECT X.ID_USUARIO, X.PT_LSTNEGRA, X.NM_TIME FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR,  
			   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada =   (pIdTemp-1)   AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA,  
			   0 as PT_TOTAL 
			   FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U   
			   WHERE C.ID_TEMPORADA = pIdTemp 
			   AND C.ID_CAMPEONATO = pIdCampRenewal 
			   AND U.IN_USUARIO_ATIVO = TRUE  
			   AND C.IN_CONFIRMACAO in (1,9)
			   AND (C.NM_TIME is not null AND TRIM(C.NM_TIME) <> '' AND TRIM(C.NM_TIME) <> '.')
			   AND C.DS_STATUS = 'AP'  
			   AND C.ID_USUARIO = U.ID_USUARIO) as X
			   ORDER BY X.DS_STATUS, X.IN_CONFIRMACAO DESC, X.IN_ORDENACAO, X.PT_LSTNEGRA;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	SELECT count(1) into _countCurrent FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdCamp;
	
	SELECT QT_TIMES into _QtTotalTimes FROM  TB_CAMPEONATO WHERE ID_CAMPEONATO = pIdCamp;
		
	SET _countRest = (_QtTotalTimes-_countCurrent);
	
	SET _count = 1;
	
	IF _countRest > 0 THEN

		OPEN tabela_cursor;
		
		get_tabela: LOOP
		
			SET _idUsu = NULL;
			SET _teamName = COALESCE(_teamName, "");		

			FETCH tabela_cursor INTO _idUsu, _TotLstNegra, _teamName;
			
			SET _idUsu = COALESCE(_idUsu, 0);

			IF _idUsu = 0 THEN
				LEAVE get_tabela;
			END IF;
			
			#IF _finished = 1 THEN
			#	LEAVE get_tabela;
			#END IF;
			
			SET _TotLstNegra = COALESCE(_TotLstNegra, 0);
			
			IF _idUsu > 0  THEN
			
				SET _idTime = NULL;
			
				SELECT ID_TIME into _idTime FROM TB_TIME WHERE ID_TECNICO_FUT = _idUsu AND LOWER(TRIM(NM_TIME)) = LOWER(TRIM(_teamName)) AND DS_TIPO = "PRO";
				
				SET _idTime = COALESCE(_idTime, 0);
				
				IF _idTime = 0 THEN
				
					INSERT INTO TB_TIME(NM_TIME, ID_TIPO_TIME, DS_TIPO, ID_TECNICO_FUT, IN_TIME_COM_IMAGEM) 
					VALUES (TRIM(_teamName), 37, "PRO", _idUsu, 0);
					
					SELECT ID_TIME INTO _idTime FROM TB_TIME ORDER BY ID_TIME DESC LIMIT 1;
					
				END IF;
			
				IF _count <= _countRest AND _TotLstNegra <= _LIMIT_BLACK_LIST THEN
				
					INSERT INTO TB_CAMPEONATO_TIME (ID_CAMPEONATO, ID_TIME) VALUES (pIdCamp, _idTime);
					INSERT INTO TB_CAMPEONATO_USUARIO (ID_CAMPEONATO, ID_USUARIO, DT_ENTRADA) VALUES (pIdCamp, _idUsu, NOW());
					call spUpdateToEndBancoReserva(_idUsu, 'PRO');
					
					SET _count = _count + 1;
					
				ELSEIF _TotLstNegra > _LIMIT_BLACK_LIST THEN
				
					call spUpdateToEndBancoReserva(_idUsu, 'PRO');

				END IF;
				
			END IF;
			
		END LOOP get_tabela;
		
		CLOSE tabela_cursor;
	
	END IF;

End$$
DELIMITER ;





DELIMITER $$
DROP PROCEDURE IF EXISTS `spAssumeTimes` $$
CREATE PROCEDURE `spAssumeTimes`(
	pIdCamp INTEGER,
	pTipoCampo VARCHAR(3)
)
Begin
	SET @row_number = 1;

	insert into TB_USUARIO_TIME (ID_CAMPEONATO, ID_USUARIO, ID_TIME, DT_SORTEIO, INDICADOR_ORDEM_SORTEIO)
	SELECT C.ID_CAMPEONATO, T.ID_TECNICO_FUT, C.ID_TIME, now(), (@row_number:=@row_number + 1) 
	FROM TB_CAMPEONATO_TIME C, TB_TIME T 
	WHERE C.ID_CAMPEONATO = pIdCamp AND DS_TIPO = pTipoCampo AND C.ID_TIME = T.ID_TIME;

End$$
DELIMITER ;



DELIMITER $$
DROP FUNCTION IF EXISTS `fcAddTecnicos` $$
CREATE FUNCTION `fcAddTecnicos`(
	pIdTemp INTEGER, pIdNewCamp INTEGER, pIdCampConfirmTemp VARCHAR(10), pIdCampConfirmTempBco INTEGER, 
	pQtdTimes INTEGER, pInLimiteLstNegra INTEGER, pSiglaTime VARCHAR(3), 
	pIdTipoTime INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _inPtosNegativos INTEGER DEFAULT 0;
	DECLARE _countTecnicos INTEGER DEFAULT 0;
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _NmTime VARCHAR(50) DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT X.ID_USUARIO, X.NM_TIME, X.PT_LSTNEGRA FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR, 
	(SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA,
	(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA_FUT H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
	FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
	WHERE C.ID_TEMPORADA = pIdTemp
	AND C.ID_CAMPEONATO in (pIdCampConfirmTemp)
	AND U.IN_USUARIO_ATIVO = TRUE 
	AND U.IN_DESEJA_PARTICIPAR = 1 
	AND C.IN_CONFIRMACAO in (1,9) 
	AND C.ID_USUARIO = U.ID_USUARIO) X
	ORDER BY X.DS_Status, X.IN_USUARIO_MODERADOR, X.IN_CONFIRMACAO DESC, X.PT_TOTAL DESC, X.IN_ORDENACAO, X.DT_CONFIRMACAO, X.ID_Usuario;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _NmTime, _inPtosNegativos;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _countTecnicos = _countTecnicos + 1;
		
		SELECT ID_TIME into _idTime FROM TB_TIME WHERE ID_TECNICO_FUT = pIdUsu AND NM_TIME = _NmTime AND DS_TIPO = pSiglaTime;
		
		IF (_idTime IS NULL) THEN
		
			insert into `TB_TIME` (`NM_TIME`, `ID_TIPO_TIME`, `DS_TIPO`, `ID_TECNICO_FUT`, `IN_TIME_COM_IMAGEM`) 
			values (_NmTime, _TipoTimeFUT, pSiglaTime, _idUsu, 0);
			
			select ID_TIME into _idTime
			from TB_TIME
			order by ID_TIME desc
			limit 1;
		
		END IF;
		
		IF (_countTecnicos <= pQtdTimes AND _inPtosNegativos <= pInLimiteLstNegra) THEN
		
			call `arenafifadb_staging`.`spAddCampeonatoTime`(pIdNewCamp, _idTime);
			
			call `arenafifadb_staging`.`spAddCampeonatoUsuario`(pIdNewCamp, _idUsu);
			
		END IF;
		
		call `arenafifadb_staging`.`spUpdateToEndBancoReserva`(_idUsu, pSiglaTime);
		
		IF (_inPtosNegativos <= pInLimiteLstNegra) THEN
		
			UPDATE TB_CONFIRMACAO_TEMPORADA
			SET ID_CAMPEONATO = pIdCampConfirmTempBco
			WHERE ID_TEMPORADA = pItemp
			AND ID_CAMPEONATO in (pIdCampConfirmTemp) AND ID_USUARIO = _idUsu;
			
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	RETURN _countTecnicos;
End$$
DELIMITER ;






DELIMITER $$
DROP FUNCTION IF EXISTS `fcAddTecnicosBco` $$
CREATE FUNCTION `fcAddTecnicosBco`(
	pIdTemp INTEGER, pIdNewCamp INTEGER, pIdCampConfirmTempBco INTEGER, 
	pQtdTimes INTEGER, pInLimiteLstNegra INTEGER, pCountTecnicos INTEGER, 
	pSiglaTime VARCHAR(3), pIdTipoTime INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _inPtosNegativos INTEGER DEFAULT 0;
	DECLARE _countTecnicos INTEGER DEFAULT 0;
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _NmTime VARCHAR(50) DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
	SELECT X.ID_USUARIO, X.NM_TIME, X.PT_LSTNEGRA FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR, 
	(SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA,
	(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA_FUT H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
	FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
	WHERE C.ID_TEMPORADA = pIdTemp
	AND C.ID_CAMPEONATO = pIdCampConfirmTempBco
	AND U.IN_USUARIO_ATIVO = TRUE 
	AND U.IN_DESEJA_PARTICIPAR = 1 
	AND C.IN_CONFIRMACAO IN (1,9)
	AND C.NM_TIME IS NOT NULL
	AND C.ID_USUARIO = U.ID_USUARIO) X
	ORDER BY X.DS_Status, X.IN_USUARIO_MODERADOR, X.IN_CONFIRMACAO DESC, X.PT_TOTAL DESC, X.IN_ORDENACAO, X.DT_CONFIRMACAO, X.ID_Usuario;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	SET _countTecnicos = pCountTecnicos;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _NmTime, _inPtosNegativos;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF (_inPtosNegativos <= pInLimiteLstNegra) THEN
		
			SET _countTecnicos = _countTecnicos + 1;
			
			IF (_countTecnicos <= pQtdTimes) THEN
			
				SELECT ID_TIME into _idTime FROM TB_TIME WHERE ID_TECNICO_FUT = pIdUsu AND NM_TIME = _NmTime AND DS_TIPO = pSiglaTime;
				
				IF (_idTime IS NULL) THEN
				
					insert into `TB_TIME` (`NM_TIME`, `ID_TIPO_TIME`, `DS_TIPO`, `ID_TECNICO_FUT`, `IN_TIME_COM_IMAGEM`) 
					values (_NmTime, pIdTipoTime, pSiglaTime, _idUsu, 0);
					
					select ID_TIME into _idTime
					from TB_TIME
					order by ID_TIME desc
					limit 1;
				
					call `arenafifadb_staging`.`spAddCampeonatoTime`(_idCamp, _idTime);
					
					call `arenafifadb_staging`.`spAddCampeonatoUsuario`(_idCamp, _idUsu);
					
					call `arenafifadb_staging`.`spUpdateToEndBancoReserva`(_idUsu, pSiglaTime);
		
				END IF;
				
			END IF;
		
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	RETURN _countTecnicos;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTecnicosFromLigasToCampeonatoTimeUsuario` $$
CREATE PROCEDURE `spAddTecnicosFromLigasToCampeonatoTimeUsuario`(
	pIdCampCopa INTEGER,
	pIdsCampLiga VARCHAR(10)
)
Begin
	call `arenafifadb_staging`.`spAddTecnicosFromLigasToCampeonatoTime`(pIdCampCopa, pIdsCampLiga);
	call `arenafifadb_staging`.`spAddTecnicosFromLigasToCampeonatoUsuario`(pIdCampCopa, pIdsCampLiga);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTecnicosFromLigasToCampeonatoTime` $$
CREATE PROCEDURE `spAddTecnicosFromLigasToCampeonatoTime`(
	pIdCampCopa INTEGER,
	pIdsCampLiga VARCHAR(10)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _id INTEGER DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_TIME FROM TB_CAMPEONATO_TIME WHERE ID_CAMPEONATO IN (pIdsCampLiga) ORDER BY ID_TIME;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _id;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;

		INSERT INTO TB_CAMPEONATO_TIME (ID_CAMPEONATO, ID_TIME) VALUES (pIdCampCopa, _id);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTecnicosFromLigasToCampeonatoUsuario` $$
CREATE PROCEDURE `spAddTecnicosFromLigasToCampeonatoUsuario`(
	pIdCampCopa INTEGER,
	pIdsCampLiga VARCHAR(10)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _id INTEGER DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_USUARIO FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO IN (pIdsCampLiga) ORDER BY ID_USUARIO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _id;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;

		INSERT INTO TB_CAMPEONATO_USUARIO (ID_CAMPEONATO, ID_USUARIO) VALUES (pIdCampCopa, _id);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddListaTimesPreCopa` $$
CREATE PROCEDURE `spAddListaTimesPreCopa`(
	pIdCampCopa INTEGER,
	pListaTimesPreCopa VARCHAR(500),
	pTpCamp VARCHAR(3)
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _id INTEGER DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR 
	SELECT ID_TIME FROM TB_TIME WHERE NM_TIME IN (pListaTimesPreCopa) AND ID_TIME IN (SELECT ID_TIME FROM TB_CAMPEONATO_TIME 
	WHERE ID_CAMPEONATO = pIdCampCopa AND DS_TIPO = pTpCamp) ORDER BY NM_TIME;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _id;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;

		INSERT INTO `TB_TIMES_FASE_PRECOPA` (`ID_CAMPEONATO`, `ID_TIME`, `ID_ORDEM_SORTEIO`) 
		VALUES (pIdCampCopa, _id, NULL);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spMoveUpDivisionAboveTapetao` $$
CREATE PROCEDURE `spMoveUpDivisionAboveTapetao`(
	pIdTemp INTEGER,
	pIdSerieAbove INTEGER,
	pIdSerieBelow INTEGER,
	pQtLimitMaxLstNegra INTEGER,
	pCodAcessoTapetao INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _count INTEGER DEFAULT 1;
	DECLARE _countCurrent INTEGER DEFAULT 0;
	DECLARE _countRest INTEGER DEFAULT 0;
	DECLARE _IdUsu INTEGER DEFAULT 0;
	DECLARE _TotLstNegra INTEGER DEFAULT 0;
	DECLARE _QtTotalTimes INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT U.ID_USUARIO,
		(SELECT L.PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) AND L.ID_USUARIO = H.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
		FROM TB_HISTORICO_TEMPORADA H, TB_CAMPEONATO C, TB_CAMPEONATO_USUARIO X, TB_USUARIO U
		WHERE H.ID_TEMPORADA = pIdTemp
		AND C.ID_CAMPEONATO =  pIdSerieBelow
		AND arenafifadb.fcGetIdUsuariosVazio(U.ID_USUARIO,'NOT')
		AND H.ID_USUARIO = U.ID_USUARIO
		AND H.ID_USUARIO = X.ID_USUARIO
		AND C.ID_CAMPEONATO = X.ID_CAMPEONATO
		AND X.ID_USUARIO = U.ID_USUARIO
		AND U.IN_DESEJA_PARTICIPAR = 1
		ORDER BY H.IN_ACESSO_TEMP_ATUAL, H.IN_REBAIXADO_TEMP_ANTERIOR, H.PT_TOTAL DESC, NM_USUARIO;
		
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	SELECT count(1) into _countCurrent FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdSerieAbove;
	
	SELECT QT_TIMES into _QtTotalTimes FROM  TB_CAMPEONATO WHERE ID_CAMPEONATO = pIdSerieAbove;
		
	SET _countRest = (_QtTotalTimes-_countCurrent);
	
	IF _countRest > 0 THEN 
	
		OPEN tabela_cursor;
		
		SET _count = 1;
		
		get_tabela: LOOP
		
			FETCH tabela_cursor INTO _idUsu, _TotLstNegra;
			
			IF _finished = 1 THEN
				LEAVE get_tabela;
			END IF;
			
			SET _TotLstNegra = COALESCE(_TotLstNegra, 0);

			IF _count > _countRest THEN
			
				LEAVE get_tabela;
			
			ELSEIF _count <= _countRest AND _TotLstNegra <= pQtLimitMaxLstNegra THEN
			
				call `arenafifadb_staging`.`spDeleteCampeonatoUsuario`(pIdSerieBelow, _idUsu);
				call `arenafifadb_staging`.`spAddCampeonatoUsuario`(pIdSerieAbove, _idUsu);
				
				call `arenafifadb_staging`.`spAddHistoricoTemporadaH2H`(pIdTemp, _idUsu, pCodAcessoTapetao);
			
				SET _count = _count + 1;

			END IF;
		
		END LOOP get_tabela;
		
		CLOSE tabela_cursor;
	
	END IF;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spMoveUpDivisionAboveAcesso` $$
CREATE PROCEDURE `spMoveUpDivisionAboveAcesso`(
	pIdTemp INTEGER,
	pIdSerieAbove INTEGER,
	pIdSerieBelow INTEGER,
	pSgSerieBelowOld VARCHAR(5),
	pCodAcesso INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _IdUsu1 INTEGER DEFAULT 0;
	DECLARE _IdUsu2 INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT TU1.id_usuario, TU2.id_usuario 
		FROM TB_TABELA_JOGO J, TB_TIME T1 , TB_TIME T2, TB_USUARIO_TIME UT1, TB_USUARIO_TIME UT2, TB_USUARIO TU1, TB_USUARIO TU2, TB_CLASSIFICACAO TC1, TB_CLASSIFICACAO TC2,
		     (SELECT ID_CAMPEONATO FROM  TB_CAMPEONATO WHERE ID_TEMPORADA < pIdTemp AND SG_TIPO_CAMPEONATO = pSgSerieBelowOld ORDER BY ID_CAMPEONATO DESC LIMIT 1) CX,
			 (SELECT ID_FASE FROM TB_FASE WHERE NM_FASE = 'Semi-Final') FX
		WHERE J.ID_CAMPEONATO = CX.ID_CAMPEONATO 
		AND J.ID_FASE = FX.ID_FASE
		AND J.IN_NUMERO_RODADA = 1
		AND J.ID_TIME_CASA = T1.ID_TIME 
		AND J.ID_TIME_VISITANTE = T2.ID_TIME 
		AND T1.ID_TIME = UT1.ID_TIME 
		AND T2.ID_TIME = UT2.ID_TIME 
		AND UT1.ID_USUARIO = TU1.ID_USUARIO 
		AND UT2.ID_USUARIO = TU2.ID_USUARIO 
		AND UT1.ID_CAMPEONATO = J.ID_CAMPEONATO 
		AND UT2.ID_CAMPEONATO = J.ID_CAMPEONATO 
		AND J.ID_TIME_CASA = TC1.ID_TIME 
		AND J.ID_TIME_VISITANTE = TC2.ID_TIME 
		AND J.ID_CAMPEONATO = TC1.ID_CAMPEONATO 
		AND J.ID_CAMPEONATO = TC2.ID_CAMPEONATO 
		AND UT1.DT_VIGENCIA_FIM is null 
		AND UT2.DT_VIGENCIA_FIM is null 
		ORDER BY J.DT_TABELA_INICIO_JOGO, J.DS_HORA_JOGO, J.ID_TABELA_JOGO LIMIT 2;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _IdUsu1, _IdUsu2;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _IdUsu1 = 401 AND pIdTemp = 23 THEN
			#nothing to do
			SET _IdUsu1 = _IdUsu1;
		ELSE
			call `arenafifadb_staging`.`spDeleteCampeonatoUsuario`(pIdSerieBelow, _IdUsu1);
			call `arenafifadb_staging`.`spAddCampeonatoUsuario`(pIdSerieAbove, _IdUsu1);
			call `arenafifadb_staging`.`spAddHistoricoTemporadaH2H`(pIdTemp, _IdUsu1, pCodAcesso);
		END IF;

		IF _IdUsu2 = 401 AND pIdTemp = 23 THEN
			#nothing to do
			SET _IdUsu2 = _IdUsu2;
		ELSE
			call `arenafifadb_staging`.`spDeleteCampeonatoUsuario`(pIdSerieBelow, _IdUsu2);
			call `arenafifadb_staging`.`spAddCampeonatoUsuario`(pIdSerieAbove, _IdUsu2);
			call `arenafifadb_staging`.`spAddHistoricoTemporadaH2H`(pIdTemp, _IdUsu2, pCodAcesso);
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spMoveDownDivisionBelowRelegated` $$
CREATE PROCEDURE `spMoveDownDivisionBelowRelegated`(
	pIdTemp INTEGER,
	pIdSerieAbove INTEGER,
	pIdSerieBelow INTEGER,
	pSgSerieAboveOld VARCHAR(5),
	pCodAcessoRelegated INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _count INTEGER DEFAULT 0;
	DECLARE _IdUsu INTEGER DEFAULT 0;
	DECLARE _QtTimes INTEGER DEFAULT 0;
	DECLARE _QtTimesRelegated INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT U.ID_USUARIO
		FROM TB_CLASSIFICACAO C, TB_TIME T, TB_USUARIO_TIME UT, TB_USUARIO U,
		     (SELECT ID_CAMPEONATO FROM  TB_CAMPEONATO WHERE ID_TEMPORADA < pIdTemp AND SG_TIPO_CAMPEONATO = pSgSerieAboveOld ORDER BY ID_CAMPEONATO DESC LIMIT 1) CX
		WHERE C.ID_CAMPEONATO = CX.ID_CAMPEONATO
		AND UT.DT_VIGENCIA_FIM IS NULL AND C.ID_TIME = T.ID_TIME AND C.ID_CAMPEONATO = UT.ID_CAMPEONATO AND T.ID_TIME = UT.ID_TIME
		AND UT.ID_USUARIO = U.ID_USUARIO
		ORDER BY C.QT_PONTOS_GANHOS DESC, QT_VITORIAS DESC, (QT_GOLS_PRO-QT_GOLS_CONTRA) DESC, QT_GOLS_PRO DESC, QT_GOLS_CONTRA, T.NM_TIME;
		
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	SELECT QT_TIMES, QT_TIMES_REBAIXADOS into _QtTimes, _QtTimesRelegated FROM  TB_CAMPEONATO 
	WHERE ID_TEMPORADA < pIdTemp AND SG_TIPO_CAMPEONATO = pSgSerieAboveOld ORDER BY ID_CAMPEONATO DESC LIMIT 1;
		
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _IdUsu;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _count = _count + 1;
		
		IF (_QtTimes - _count) < _QtTimesRelegated THEN
		
			call `arenafifadb_staging`.`spDeleteCampeonatoUsuario`(pIdSerieAbove, _IdUsu);
			call `arenafifadb_staging`.`spAddCampeonatoUsuario`(pIdSerieBelow, _IdUsu);
			call `arenafifadb_staging`.`spUpdateHistoricoTempTecnicoRelegated`(pIdTemp, _IdUsu, pCodAcessoRelegated);
			
		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spMoveOnDivisionInitialize` $$
CREATE PROCEDURE `spMoveOnDivisionInitialize`(
	pIdTemp INTEGER,
	pIdSerieB INTEGER,
	pIdSerieC INTEGER,
	pQtLimitMaxLstNegra INTEGER,
	pCodAcessoConvite INTEGER
)
Begin
	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _count INTEGER DEFAULT 1;
	DECLARE _countCurrent INTEGER DEFAULT 0;
	DECLARE _countRest INTEGER DEFAULT 0;
	DECLARE _IdUsu INTEGER DEFAULT 0;
	DECLARE _TotLstNegra INTEGER DEFAULT 0;
	DECLARE _QtTotalTimes INTEGER DEFAULT 0;

	DECLARE tabela_cursor CURSOR FOR
		SELECT X.ID_USUARIO, X.PT_LSTNEGRA FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR, 
		(SELECT L.PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA, 
		(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL 
		FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U  
		WHERE C.ID_TEMPORADA = pIdTemp
		AND C.ID_CAMPEONATO = 0
		AND C.IN_CONFIRMACAO = 1
		AND C.ID_USUARIO NOT IN (SELECT CU.ID_USUARIO FROM TB_CAMPEONATO_USUARIO CU WHERE CU.ID_CAMPEONATO IN (pIdSerieB,pIdSerieC))
		AND U.IN_USUARIO_ATIVO = TRUE 
		AND U.IN_DESEJA_PARTICIPAR = 1 
		AND C.ID_USUARIO = U.ID_USUARIO) X
		ORDER BY X.DS_Status, X.IN_USUARIO_MODERADOR, X.IN_CONFIRMACAO DESC, X.IN_ORDENACAO, X.DT_CONFIRMACAO, X.PT_LSTNEGRA, X.PT_TOTAL DESC, X.ID_USUARIO;
		
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	SELECT count(1) into _countCurrent FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO = pIdSerieC;
	
	SELECT QT_TIMES into _QtTotalTimes FROM  TB_CAMPEONATO WHERE ID_CAMPEONATO = pIdSerieC;
		
	SET _countRest = (_QtTotalTimes-_countCurrent);
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _TotLstNegra;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		SET _TotLstNegra = COALESCE(_TotLstNegra, 0);

		IF _count > _countRest THEN
		
			LEAVE get_tabela;
		
		ELSEIF _TotLstNegra <= pQtLimitMaxLstNegra THEN
		
			call `arenafifadb_staging`.`spAddCampeonatoUsuario`(pIdSerieC, _idUsu);
			call `arenafifadb_staging`.`spAddHistoricoTemporadaH2H`(pIdTemp, _idUsu, pCodAcessoConvite);
		
			call `arenafifadb_staging`.`spUpdateToEndBancoReserva`(_idUsu, H2H);

			SET _count = _count + 1;

		END IF;
	
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllTablesForNewTemporada` $$
CREATE PROCEDURE `spDeleteAllTablesForNewTemporada`(pIdTemp INTEGER, pIdSerieA INTEGER)
Begin
	#DELETE FROM TB_COMENTARIO_JOGO;

	DELETE FROM TB_COMENTARIO_USUARIO
		  WHERE ID_TABELA_JOGO IN (SELECT J.ID_TABELA_JOGO FROM TB_TABELA_JOGO J WHERE J.DT_EFETIVACAO_JOGO IS NOT NULL);

	DELETE FROM TB_COMENTARIO_USUARIO
		  WHERE ID_TABELA_JOGO IN (SELECT J.ID_TABELA_JOGO FROM TB_TABELA_JOGO J WHERE J.DT_EFETIVACAO_JOGO IS NOT NULL);

	DELETE FROM TB_COMENTARIO_USUARIO
		  WHERE ID_TABELA_JOGO IN (SELECT J.ID_TABELA_JOGO FROM TB_TABELA_JOGO J WHERE J.DT_EFETIVACAO_JOGO IS NOT NULL);

	DELETE FROM TB_COMENTARIO_USUARIO
		  WHERE ID_TABELA_JOGO IN (SELECT J.ID_TABELA_JOGO FROM TB_TABELA_JOGO J WHERE J.DT_EFETIVACAO_JOGO IS NOT NULL);

	DELETE FROM TB_CONFIRMACAO_TEMPORADA WHERE ID_TEMPORADA <= pIdTemp;

	#DELETE FROM TB_HISTORICO_CLASSIFICACAO;

	DELETE FROM TB_HISTORICO_CONQUISTA WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM TB_CAMPEONATO WHERE SG_TIPO_CAMPEONATO IN ('CFUT','LFUT','FUT1','FUT2''CPRO','PRO1'));

	#DELETE FROM TB_HISTORICO_TRANSMISSAO_AOVIVO;

	DELETE FROM TB_LISTA_BANCO_RESERVA WHERE DT_FIM IS NOT NULL;

	DELETE FROM TB_USUARIO_TIME WHERE DT_VIGENCIA_FIM IS NOT NULL;

	DELETE FROM TB_POTE_TIME_GRUPO WHERE ID_CAMPEONATO < pIdSerieA;

	DELETE FROM TB_TIMES_FASE_PRECOPA WHERE ID_CAMPEONATO < pIdSerieA;

	DELETE FROM TB_CLASSIFICACAO WHERE ID_CAMPEONATO < pIdSerieA;

	DELETE FROM TB_TABELA_JOGO WHERE ID_CAMPEONATO < pIdSerieA;

	#DELETE FROM TB_HISTORICO_ALT_CAMPEONATO;

	#DELETE FROM TB_HISTORICO_ALT_USUARIO;

	DELETE FROM TB_HISTORICO_ATUAL;

	DELETE FROM TB_USUARIO_TIME WHERE DT_VIGENCIA_FIM IS NOT NULL ;

	DELETE FROM TB_TABELA_JOGO WHERE DT_EFETIVACAO_JOGO IS NULL;

	DELETE FROM TB_CLASSIFICACAO WHERE ID_CAMPEONATO IN (SELECT ID_CAMPEONATO FROM TB_CAMPEONATO WHERE IN_CAMPEONATO_GRUPO = False AND IN_CAMPEONATO_TURNO_UNICO = False AND IN_CAMPEONATO_TURNO_RETURNO = False AND IN_SISTEMA_MATA = True AND IN_SISTEMA_IDA_VOLTA = True);

	DELETE FROM TB_GRUPO WHERE ID_CAMPEONATO < pIdSerieA;

	DELETE FROM TB_USUARIO_TIME WHERE ID_CAMPEONATO < pIdSerieA;

	DELETE FROM TB_FASE_CAMPEONATO WHERE ID_CAMPEONATO < pIdSerieA;

	DELETE FROM TB_CONFIRM_ELENCO_PRO WHERE ID_Temporada <= pIdTemp;

	DELETE FROM TB_CAMPEONATO_USUARIO_SEG_FASE;

	#DELETE FROM TB_PALPITE_JOGO;

	#DELETE FROM TB_RESULTADOS_LANCADOS;

	#DELETE FROM TB_ULTIMOS_ACONTECIMENTOS;

	DELETE FROM TB_GOLEADOR_JOGO;

	DELETE FROM TB_GOLEADOR WHERE ID_GOLEADOR > 0 AND ID_USUARIO IS NULL;

	DELETE FROM arena_spooler.TB_HISTORICO_SPOOLER;

	DELETE FROM arena_spooler.TB_PROCESSOS_EMAIL_DETALHE;

	DELETE FROM arena_spooler.TB_SPOOLER_PROCESSOS_EMAIL;
	
	ALTER TABLE TB_TABELA_JOGO AUTO_INCREMENT = 1;

End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spMaintenanceBancoAndManagers` $$
CREATE PROCEDURE `spMaintenanceBancoAndManagers`(
	pIdTemp INTEGER,
	pIdSerieA INTEGER,
	pIdSerieB INTEGER,
	pIdSerieC INTEGER,
	pIdSerieD INTEGER,
	pIdFutA INTEGER,
	pIdFutB INTEGER,
	pIdProA INTEGER,
	pIdProB INTEGER
)
Begin

	DECLARE _finished INTEGER DEFAULT 0;
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _tpUsu VARCHAR(3) DEFAULT NULL;
	DECLARE _dsFake VARCHAR(50) DEFAULT NULL;
	DECLARE _idFake INTEGER DEFAULT NULL;
	DECLARE _dtFake DATETIME DEFAULT NULL;
	DECLARE _NmTime VARCHAR(50) DEFAULT NULL;

	DECLARE tabela_cursor CURSOR FOR
		SELECT X.ID_USUARIO, 'H2H' as TP_USUARIO, NULL as NM_TIME, X.DS_STATUS, X.IN_USUARIO_MODERADOR, X.IN_CONFIRMACAO, X.IN_ORDENACAO, X.DT_CONFIRMACAO, X.PT_LSTNEGRA, X.PT_TOTAL FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR, 
		(SELECT L.PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA, 
		(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
		FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U  
		WHERE C.ID_TEMPORADA = pIdTemp
		AND C.ID_CAMPEONATO = 0
		AND U.IN_USUARIO_ATIVO = TRUE 
		AND U.IN_DESEJA_PARTICIPAR = 1 
		AND C.IN_CONFIRMACAO = 1
		AND C.ID_USUARIO NOT IN (SELECT ID_USUARIO FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO in (pIdSerieA,pIdSerieB,pIdSerieC,pIdSerieD))
		AND C.ID_USUARIO = U.ID_USUARIO) X
		UNION ALL
		SELECT X.ID_USUARIO, 'FUT' as TP_USUARIO, X.NM_TIME, X.DS_STATUS, X.IN_USUARIO_MODERADOR, X.IN_CONFIRMACAO, X.IN_ORDENACAO, X.DT_CONFIRMACAO, X.PT_LSTNEGRA, X.PT_TOTAL FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR, 
		(SELECT L.PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA, 
		(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
		FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U  
		WHERE C.ID_TEMPORADA = pIdTemp
		AND C.ID_CAMPEONATO = 7
		AND U.IN_USUARIO_ATIVO = TRUE 
		AND U.IN_DESEJA_PARTICIPAR = 1 
		AND C.IN_CONFIRMACAO = 1
		AND C.ID_USUARIO NOT IN (SELECT ID_USUARIO FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO IN (pIdFutA, pIdFutB))
		AND C.ID_USUARIO = U.ID_USUARIO) X
		UNION ALL
		SELECT X.ID_USUARIO, 'PRO' as TP_USUARIO, X.NM_TIME, X.DS_STATUS, X.IN_USUARIO_MODERADOR, X.IN_CONFIRMACAO, X.IN_ORDENACAO, X.DT_CONFIRMACAO, X.PT_LSTNEGRA, X.PT_TOTAL FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR, 
		(SELECT L.PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = (pIdTemp-1) AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA, 
		(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc LIMIT 1) as PT_TOTAL
		FROM TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U  
		WHERE C.ID_TEMPORADA = pIdTemp
		AND C.ID_CAMPEONATO = 13
		AND U.IN_USUARIO_ATIVO = TRUE 
		AND U.IN_DESEJA_PARTICIPAR = 1 
		AND C.IN_CONFIRMACAO = 1
		AND C.ID_USUARIO NOT IN (SELECT ID_USUARIO FROM TB_CAMPEONATO_USUARIO WHERE ID_CAMPEONATO IN (pIdProA, pIdProB))
		AND C.ID_USUARIO = U.ID_USUARIO) X
		ORDER BY TP_USUARIO, DS_Status, IN_USUARIO_MODERADOR, IN_CONFIRMACAO DESC, IN_ORDENACAO, DT_CONFIRMACAO, PT_LSTNEGRA, PT_TOTAL DESC;
		
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	call `arenafifadb_staging`.`spUpdateToEndBancoReservaByTipo`('H2H');
	call `arenafifadb_staging`.`spUpdateToEndBancoReservaByTipo`('FUT');
	call `arenafifadb_staging`.`spUpdateToEndBancoReservaByTipo`('PRO');

	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu, _tpUsu, _NmTime, _dsFake, _idFake, _idFake, _idFake, _dtFake, _idFake, _idFake;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;
		
		IF _tpUsu = 'H2H' THEN
		
			IF pIdSerieD > 0 THEN
		
				call `arenafifadb_staging`.`spAddBancoReserva`(pIdSerieD, _NmTime, _tpUsu);

			ELSEIF pIdSerieC > 0 THEN
		
				call `arenafifadb_staging`.`spAddBancoReserva`(pIdSerieC, _NmTime, _tpUsu);

			ELSEIF pIdSerieB > 0 THEN
		
				call `arenafifadb_staging`.`spAddBancoReserva`(pIdSerieB, _NmTime, _tpUsu);

			END IF;
	
		ELSEIF _tpUsu = 'FUT' THEN
		
			call `arenafifadb_staging`.`spAddBancoReserva`(pIdFutB, _NmTime, _tpUsu);

		ELSEIF _tpUsu = 'PRO' THEN
		
			call `arenafifadb_staging`.`spAddBancoReserva`(pIdProA, _NmTime, _tpUsu);

		END IF;
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	
	#UPDATE TB_CAMPEONATO 
	#SET ID_USUARIO_MODERADOR = , ID_USUARIO_2oMODERADOR = ,
	#ID_USUARIO_1oAUXILIAR = Null, ID_USUARIO_2oAUXILIAR = Null, ID_USUARIO_3oAUXILIAR = Null
	#WHERE ID_CAMPEONATO = pIdSerieA;
	
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spGenerateClashesNewTemporada` $$
CREATE PROCEDURE `spGenerateClashesNewTemporada`(
	pIdTemp INTEGER
)
Begin

	DECLARE _idTimeFim INTEGER DEFAULT NULL;
	DECLARE _idUsuFim INTEGER DEFAULT NULL;
	DECLARE _idCampIni INTEGER DEFAULT NULL;
	DECLARE _idCampFim INTEGER DEFAULT NULL;
	DECLARE _count INTEGER DEFAULT NULL;
	
	SELECT max(ID_TIME) into _idTimeFim FROM arena_clashes.TB_TIME;
	SELECT max(ID_USUARIO) into _idUsuFim FROM arena_clashes.TB_USUARIO;
	SELECT min(ID_CAMPEONATO), max(ID_CAMPEONATO) into _idCampIni, _idCampFim FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1) AND SG_TIPO_CAMPEONATO NOT IN ('CDA');
	
	SET _count = 0;
	SELECT count(1) into _count FROM arena_clashes.TB_TEMPORADA WHERE ID_TEMPORADA = (pIdTemp-1);
	IF _count = 0 THEN
		INSERT INTO arena_clashes.TB_TEMPORADA SELECT * FROM arenafifadb.TB_TEMPORADA WHERE ID_TEMPORADA = (pIdTemp-1);
	END IF;
	
	SET _count = 0;
	SELECT count(1) into _count FROM arena_clashes.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1);
	IF _count = 0 THEN
		INSERT INTO arena_clashes.TB_CAMPEONATO SELECT * FROM arenafifadb.TB_CAMPEONATO WHERE ID_TEMPORADA = (pIdTemp-1);
	END IF;
	
	SET _count = 0;
	SELECT count(1) into _count FROM arena_clashes.TB_TIME WHERE ID_TIME > _idTimeFim;
	IF _count = 0 THEN
		INSERT INTO arena_clashes.TB_TIME SELECT * FROM arenafifadb.TB_TIME WHERE ID_TIME > _idTimeFim;
	END IF;
	
	SET _count = 0;
	SELECT count(1) into _count FROM arena_clashes.TB_USUARIO WHERE ID_USUARIO > _idUsuFim;
	IF _count = 0 THEN
		INSERT INTO arena_clashes.TB_USUARIO SELECT * FROM arenafifadb.TB_USUARIO WHERE ID_USUARIO > _idUsuFim;
	END IF;
	
	SET _count = 0;
	SELECT count(1) into _count FROM arena_clashes.TB_TABELA_JOGO WHERE ID_CAMPEONATO >= _idCampIni AND ID_CAMPEONATO <= _idCampFim;
	IF _count = 0 THEN
		SET _count = 0;
		SELECT ID_TABELA_JOGO into _count FROM arena_clashes.TB_TABELA_JOGO ORDER BY ID_TABELA_JOGO DESC LIMIT 1;

		SET @row_number = _count;

		insert into arena_clashes.TB_TABELA_JOGO (ID_TABELA_JOGO, ID_CAMPEONATO, ID_FASE, DT_TABELA_INICIO_JOGO, DT_TABELA_FIM_JOGO, ID_TIME_CASA, QT_GOLS_TIME_CASA, 
												  ID_TIME_VISITANTE, QT_GOLS_TIME_VISITANTE, DT_EFETIVACAO_JOGO, IN_NUMERO_RODADA, IN_DISPUTA_3o_4o, DT_SORTEIO, 
												  DS_HORA_JOGO, ID_USUARIO_TIME_CASA, ID_USUARIO_TIME_VISITANTE, IN_JOGO_MATAXMATA, DT_ULTIMA_EFETIVACAO, DS_LOGIN_EFETIVACAO)
		SELECT  (@row_number:=@row_number + 1), C.ID_CAMPEONATO, C.ID_FASE, C.DT_TABELA_INICIO_JOGO, C.DT_TABELA_FIM_JOGO, C.ID_TIME_CASA, C.QT_GOLS_TIME_CASA, C.ID_TIME_VISITANTE, C.QT_GOLS_TIME_VISITANTE, C.DT_EFETIVACAO_JOGO, C.IN_NUMERO_RODADA, C.IN_DISPUTA_3o_4o, C.DT_SORTEIO, C.
				DS_HORA_JOGO, C.ID_USUARIO_TIME_CASA, C.ID_USUARIO_TIME_VISITANTE, C.IN_JOGO_MATAXMATA, C.DT_ULTIMA_EFETIVACAO, C.DS_LOGIN_EFETIVACAO
		FROM  arenafifadb.TB_TABELA_JOGO C WHERE ID_CAMPEONATO >= _idCampIni AND ID_CAMPEONATO <= _idCampFim;
	END IF;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllSeasonDetailsNewTemporada` $$
CREATE PROCEDURE `spGetAllSeasonDetailsNewTemporada`()
Begin
	SELECT * FROM TB_GENERATE_NEWSEASON_MAINDETAILS WHERE IN_TEMPORADA_ATIVA = TRUE;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllChampionshipTypesNewTemporadaByMode` $$
CREATE PROCEDURE `spGetAllChampionshipTypesNewTemporadaByMode`(
	pTpModalidade CHAR(3)
)
Begin
	SELECT IN_CAMPEONATO_ATIVO, C.SG_CAMPEONATO FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS 
	 WHERE TP_MODALIDADE = pTpModalidade
	 GROUP BY SG_CAMPEONATO
	UNION ALL
    SELECT IN_CAMPEONATO_ATIVO, C.SG_CAMPEONATO FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPCUP_DETAILS 
	 WHERE TP_MODALIDADE = pTpModalidade
	 GROUP BY IN_CAMPEONATO_ATIVO, C.SG_CAMPEONATO
	 ORDER BY IN_CAMPEONATO_ATIVO DESC, C.SG_CAMPEONATO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllChampionshipLeagueDetailsNewTemporada` $$
CREATE PROCEDURE `spGetAllChampionshipLeagueDetailsNewTemporada`(
	pTpModalidade CHAR(3),
	pSgCampeonato CHAR(7)
)
Begin
	SELECT * FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS 
	 WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = pSgCampeonato;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllChampionshipCupDetailsNewTemporada` $$
CREATE PROCEDURE `spGetAllChampionshipCupDetailsNewTemporada`(
	pTpModalidade CHAR(3),
	pSgCampeonato CHAR(7)
)
Begin
	SELECT * FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPCUP_DETAILS 
	 WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = pSgCampeonato;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllChampionshipItensNewTemporadaByTipoCampeonato` $$
CREATE PROCEDURE `spGetAllChampionshipItensNewTemporadaByTipoCampeonato`(
	pTpModalidade CHAR(3),
	pSgCampeonato CHAR(7)
)
Begin
	SELECT * FROM TB_GENERATE_NEWSEASON_ITEM_STANDARD 
	 WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = pSgCampeonato
	 ORDER BY TP_MODALIDADE, C.SG_CAMPEONATO, C.ITEM_POTE_NUMBER, C.ITEM_NAME;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllChampionshipItensNewTemporadaByModalidade` $$
CREATE PROCEDURE `spGetAllChampionshipItensNewTemporadaByModalidade`(
	pTpModalidade CHAR(3)
)
Begin
	SELECT * FROM TB_GENERATE_NEWSEASON_ITEM_STANDARD 
	 WHERE TP_MODALIDADE = pTpModalidade
	 ORDER BY TP_MODALIDADE, C.SG_CAMPEONATO, C.ITEM_POTE_NUMBER, C.ITEM_NAME;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddUpdateSeasonGenerateNewSeason` $$
CREATE PROCEDURE `spAddUpdateSeasonGenerateNewSeason`(
	pIdTemporada INTEGER,
	pNmTemporada VARCHAR(50),
	pIdUsu INTEGER,
	pNmUsu VARCHAR(50),
	pPsnID VARCHAR(30),
	pDtSorteio DATE
)
Begin
	IF pIdTemporada = 0 THEN
	
		SELECT ID_TEMPORADA into pIdTemporada FROM TB_GENERATE_NEWSEASON_MAINDETAILS
		WHERE IN_TEMPORADA_ATIVA IS NULL ORDER BY ID_TEMPORADA DESC LIMIT 1;
		
		UPDATE TB_GENERATE_NEWSEASON_MAINDETAILS SET IN_TEMPORADA_ATIVA = FALSE
		WHERE ID_TEMPORADA = pIdTemporada;
		
		SET pIdTemporada = pIdTemporada + 1;
		
		INSERT INTO TB_GENERATE_NEWSEASON_MAINDETAILS VALUES (pIdTemporada, C.CONCAT((pIdTemporada-1), C.ª Temporada), C.pIdUsu, C.pNmUsu, C.pPsnID, C.pDtSorteio, C.TRUE);
	
	ELSE
	
		UPDATE TB_GENERATE_NEWSEASON_MAINDETAILS
		SET DATA_SORTEIO = pDtSorteio, C.ID_USUARIO = pIdUsu, C.NM_USUARIO = pNmUsu, C.PSN_ID = pPsnID
		WHERE ID_TEMPORADA = pIdTemporada;
	
	END IF;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateChampionshipLeagueGenerateNewSeason` $$
CREATE PROCEDURE `spUpdateChampionshipLeagueGenerateNewSeason`(
	pTpModalidade CHAR(3),
	pSgCampeonato CHAR(7),
	pDtInicio DATE,
	pQtTimes INTEGER,
	pQtDiasFase0 INTEGER,
	pQtDiasPlayoff INTEGER,
	pQtTimesRebaixados INTEGER,
	pInAtivo TINYINT,
	pInPorGrupo TINYINT,
	pQtGrupos INTEGER,
	pInPorPotes TINYINT,
	pInDoubleRound TINYINT
)
Begin
		UPDATE TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS
		SET DATA_INICIO = pDtInicio, C.QT_TIMES = pQtTimes, C.DIAS_FASE_CLASSIFICACAO = pQtDiasFase0, C.DIAS_FASE_PLAYOFF = pQtDiasPlayoff, C.QT_TIMES_REBAIXADOS = pQtTimesRebaixados,
		    IN_CAMPEONATO_ATIVO = pInAtivo, C.IN_CAMPEONATO_GRUPO = pInPorGrupo, C.QT_GRUPOS = pQtGrupos, C.IN_CAMPEONATO_GRUPO_POR_POTES = pInPorPotes, C.IN_DOUBLE_ROUND = pInDoubleRound
		WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = pSgCampeonato;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateChampionshipCupGenerateNewSeason` $$
CREATE PROCEDURE `spUpdateChampionshipCupGenerateNewSeason`(
	pTpModalidade CHAR(3),
	pSgCampeonato CHAR(7),
	pDtInicio DATE,
	pQtTimes INTEGER,
	pQtDiasFase0 INTEGER,
	pQtDiasPlayoff INTEGER,
	pInAtivo TINYINT,
	pInPorGrupo TINYINT,
	pQtGrupos INTEGER,
	pInPorPotes TINYINT,
	pInDestino TINYINT,
	pInOrigem TINYINT,
	pInSerieA TINYINT,
	pInSerieB TINYINT,
	pInSerieC TINYINT,
	pInSerieA_B TINYINT,
	pInSerieA_B_C TINYINT,
	pInSerieA_B_C_D TINYINT,
	pInSelecao TINYINT
)
Begin
		UPDATE TB_GENERATE_NEWSEASON_CHAMPIONSHIPCUP_DETAILS
		SET DATA_INICIO = pDtInicio, C.QT_TIMES = pQtTimes, C.DIAS_FASE_CLASSIFICACAO = pQtDiasFase0, C.DIAS_FASE_PLAYOFF = pQtDiasPlayoff,
		    IN_CAMPEONATO_ATIVO = pInAtivo, C.IN_CAMPEONATO_GRUPO = pInPorGrupo, C.QT_GRUPOS = pQtGrupos, C.IN_CAMPEONATO_GRUPO_POR_POTES = pInPorPotes,
			IN_CAMPEONATO_DESTINO = pInDestino, C.IN_CAMPEONATO_ORIGEM = pInOrigem, C.IN_APENAS_SERIEA = pInSerieA, C.IN_APENAS_SERIEB = pInSerieB, C.
			IN_APENAS_SERIEC = pInSerieC, C.IN_SERIEA_B = pInSerieA_B, C.IN_SERIEA_B_C = pInSerieA_B_C, C.IN_SERIEA_B_C_D = pInSerieA_B_C_D, C.IN_SELECAO = pInSelecao
		WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = pSgCampeonato;
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTeamGenerateNewSeason` $$
CREATE PROCEDURE `spAddTeamGenerateNewSeason`(
	pTpModalidade CHAR(3),
	pSgCampeonato CHAR(7),
	pIdStandard INTEGER,
	pIdItem INTEGER,
	pIdNumPote INTEGER
)
Begin
	DECLARE _nmItem VARCHAR(50) DEFAULT NULL;
	DECLARE _psnID VARCHAR(30) DEFAULT NULL;
	DECLARE _userID INTEGER DEFAULT NULL;
	DECLARE _typeID INTEGER DEFAULT NULL;
	
	IF pIdStandard = 1 THEN
	
		SELECT NM_TIME, C.ID_TECNICO_FUT, C.ID_TIPO_TIME into _nmItem, C._userID, C._typeID FROM TB_TIME WHERE ID_TIME = pIdItem;
		
		IF _typeID = 37 OR _typeID = 42 THEN
		
			IF COALESCE(_userID, C.0) > 0 THEN
			
				SELECT PSN_ID into _psnID FROM TB_USUARIO WHERE ID_USUARIO = _userID;
		
			END IF;

		END IF;
	
	ELSE
	
		SELECT NM_USUARIO, C.PSN_ID into _nmItem, C._psnID FROM TB_USUARIO WHERE ID_USUARIO = pIdItem;
	
	END IF;

	INSERT INTO TB_GENERATE_NEWSEASON_ITEM_STANDARD
	VALUES (pTpModalidade, C.pSgCampeonato, C.pIdStandard, C.pIdItem, C._nmItem, C._psnID, C.pIdNumPote);
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteTeamGenerateNewSeason` $$
CREATE PROCEDURE `spDeleteTeamGenerateNewSeason`(
	pTpModalidade CHAR(3),
	pSgCampeonato CHAR(7),
	pIdStandard INTEGER,
	pIdItem INTEGER,
	pNmItem VARCHAR(50)
)
Begin
	DELETE FROM TB_GENERATE_NEWSEASON_ITEM_STANDARD
	WHERE TP_MODALIDADE = pTpModalidade AND SG_CAMPEONATO = pSgCampeonato 
	  AND ID_STANDARD = pIdStandard AND ITEM_ID = pIdItem AND ITEM_NAME = pNmItem;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTeamGenerateNewSeasonH2H` $$
CREATE PROCEDURE `spGetAllTeamGenerateNewSeasonH2H`()
Begin
	SELECT ID_TIME, C.NM_TIME, C.DS_TIPO
	FROM TB_TIME 
	WHERE ID_TIME NOT IN (SELECT ITEM_ID FROM TB_GENERATE_NEWSEASON_ITEM_STANDARD WHERE TP_MODALIDADE = 'H2H')
	  AND ID_TIPO_TIME NOT IN (37,38,40,41,42)
	ORDER BY NM_TIME;
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spValidGenerationNewSeason` $$
CREATE PROCEDURE `spValidGenerationNewSeason`()
Begin
	DECLARE _totalOnLine INTEGER DEFAULT NULL;
	DECLARE _totalStaging INTEGER DEFAULT NULL;
	DECLARE _totalBKP INTEGER DEFAULT NULL;
	DECLARE _databasesLookTheSame INTEGER DEFAULT 0;
	DECLARE _generateNewSeasonIsDone INTEGER DEFAULT 0;
	DECLARE _hasWorldCup INTEGER DEFAULT 0;
	DECLARE _hasEuroCup INTEGER DEFAULT 0;
	DECLARE _hasEuroLeague INTEGER DEFAULT 0;
	DECLARE _hasSerieD_H2H INTEGER DEFAULT 0;
	DECLARE _hasSerieB_FUT INTEGER DEFAULT 0;
	DECLARE _hasSerieB_PRO INTEGER DEFAULT 0;
	DECLARE _seasonID INTEGER DEFAULT 0;

	SELECT count(1) into _totalOnLine FROM arenafifadb.TB_USUARIO
	WHERE ID_USUARIO > 1 AND IN_USUARIO_ATIVO = true
	AND arenafifadb.fcGetIdUsuariosVazio(ID_USUARIO,'NOT');	

	SELECT count(1) into _totalBKP FROM arenafifadb_bkp.TB_USUARIO
	WHERE ID_USUARIO > 1 AND IN_USUARIO_ATIVO = true
	AND arenafifadb.fcGetIdUsuariosVazio(ID_USUARIO,'NOT');	
	
	IF _totalOnLine = _totalBKP THEN
	
		SELECT count(1) into _totalOnLine FROM arenafifadb.TB_TEMPORADA;
		
		SELECT count(1) into _totalBKP FROM arenafifadb_bkp.TB_TEMPORADA;
		
		IF _totalOnLine = _totalBKP THEN
		
			SELECT count(1) into _totalOnLine FROM arenafifadb.TB_CAMPEONATO;
			
			SELECT count(1) into _totalBKP FROM arenafifadb_bkp.TB_CAMPEONATO;
			
			IF _totalOnLine = _totalBKP THEN
			
				SELECT count(1) into _totalOnLine FROM arenafifadb.TB_TIME;
				
				SELECT count(1) into _totalBKP FROM arenafifadb_bkp.TB_TIME;
				
				IF _totalOnLine = _totalBKP THEN
				
					SELECT count(1) into _totalOnLine FROM arenafifadb.TB_TABELA_JOGO;
					
					SELECT count(1) into _totalBKP FROM arenafifadb_bkp.TB_TABELA_JOGO;
					
					IF _totalOnLine = _totalBKP THEN
					
						SELECT count(1) into _totalOnLine FROM arenafifadb.TB_USUARIO_TIME;
						
						SELECT count(1) into _totalBKP FROM arenafifadb_bkp.TB_USUARIO_TIME;
						
						IF _totalOnLine = _totalBKP THEN
						
							SET _databasesLookTheSame = 1;
						
						END IF;
						
					END IF;

				END IF;
				
			END IF;
			
		END IF;

	END IF;
	
	
	IF _databasesLookTheSame = 0 THEN
	
		SELECT count(1) into _totalOnLine FROM arenafifadb.TB_TEMPORADA;
		
		SELECT count(1) into _totalStaging FROM arenafifadb_staging.TB_TEMPORADA;
		
		IF _totalOnLine > _totalStaging THEN
		
			SELECT ID_TEMPORADA into _seasonID FROM arenafifadb.TB_TEMPORADA WHERE DT_FIM IS NULL ORDER BY ID_TEMPORADA DESC LIMIT 1;
		
			SELECT count(1) into _totalStaging FROM arenafifadb_staging.TB_CAMPEONATO WHERE ID_TEMPORADA = _seasonID;
			
			IF _totalStaging > 0 THEN
			
				SET _generateNewSeasonIsDone = 1;
			
			END IF;
		
		END IF;
		
	END IF;
	
	SELECT count(1) into _hasSerieD_H2H FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS
	WHERE TP_MODALIDADE = 'H2H' AND SG_CAMPEONATO = 'SERIE_D' AND IN_CAMPEONATO_ATIVO = TRUE;
	
	SELECT count(1) into _hasSerieB_FUT FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS
	WHERE TP_MODALIDADE = 'FUT' AND SG_CAMPEONATO = 'SERIE_B' AND IN_CAMPEONATO_ATIVO = TRUE;
	
	SELECT count(1) into _hasSerieB_PRO FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPLEAGUE_DETAILS
	WHERE TP_MODALIDADE = 'PRO' AND SG_CAMPEONATO = 'SERIE_B' AND IN_CAMPEONATO_ATIVO = TRUE;
	
	
	SELECT count(1) into _hasWorldCup FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPCUP_DETAILS
	WHERE TP_MODALIDADE = 'H2H' AND SG_CAMPEONATO = 'WORLDCP' AND IN_CAMPEONATO_ATIVO = TRUE;
	
	SELECT count(1) into _hasEuroCup FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPCUP_DETAILS
	WHERE TP_MODALIDADE = 'H2H' AND SG_CAMPEONATO = 'EUROCUP' AND IN_CAMPEONATO_ATIVO = TRUE;
	
	SELECT count(1) into _hasEuroLeague FROM TB_GENERATE_NEWSEASON_CHAMPIONSHIPCUP_DETAILS
	WHERE TP_MODALIDADE = 'H2H' AND SG_CAMPEONATO = 'EUROPLG' AND IN_CAMPEONATO_ATIVO = TRUE;
	
	SELECT _generateNewSeasonIsDone as generateNewSeasonIsDone, C._databasesLookTheSame as databasesLookTheSame, C._hasWorldCup as hasWorldCup,
	       _hasEuroCup as hasEuroCup, C._hasSerieD_H2H as hasSerieD_H2H, C._hasSerieB_FUT as hasSerieB_FUT, C._hasSerieB_PRO as hasSerieB_PRO,
		   _hasEuroLeague as hasEuroLeague;
End$$
DELIMITER ;



DELIMITER $$
DROP FUNCTION IF EXISTS `fcAddNewTemporadaByFimOldOne` $$
CREATE FUNCTION `fcAddNewTemporadaByFimOldOne`(
	pNmTemp VARCHAR(50),
	pDtInicio DATE
) RETURNS INTEGER
	DETERMINISTIC
begin

	UPDATE TB_TEMPORADA SET DT_FIM = CURDATE() WHERE ID_TEMPORADA = fcGetIdTempCurrent();
	
	call spAddTemporada(NULL, C.pNmTemp, C.pDtInicio, C.NULL, C.1);

	RETURN fcGetIdTempCurrent();
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddNewTemporadaByFimOldOne` $$
CREATE PROCEDURE `spAddNewTemporadaByFimOldOne`(
	pNmTemp VARCHAR(50))
begin

	SELECT fcAddNewTemporadaByFimOldOne(pNmTemp, C.CURDATE()) as id_current_temporada;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateHistoricoTempTecnicoRelegated` $$
CREATE PROCEDURE `spUpdateHistoricoTempTecnicoRelegated`(
	pIdTemp INTEGER,
	pIdUsu INTEGER,
	pIdTipoAcesso INTEGER
)
Begin
	UPDATE TB_HISTORICO_TEMPORADA SET IN_REBAIXADO_TEMP_ANTERIOR = 1, C.IN_ACESSO_TEMP_ATUAL = pIdTipoAcesso
	WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteCampeonatoUsuario` $$
CREATE PROCEDURE `spDeleteCampeonatoUsuario`(    
    pIdCamp INTEGER, C.    
    pIdUsu INTEGER
)
Begin
	DELETE FROM TB_CAMPEONATO_USUARIO 
	WHERE ID_CAMPEONATO = pIdCamp AND ID_USUARIO = pIdUsu;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddCampeonatoUsuario` $$
CREATE PROCEDURE `spAddCampeonatoUsuario`(    
    pIdCamp INTEGER, C.    
    pIdUsu INTEGER
)
Begin
	insert into `TB_CAMPEONATO_USUARIO` (`ID_CAMPEONATO`, C.`ID_USUARIO`, C.`DT_ENTRADA`) 
	values (pIdCamp, C.pIdUsu, C.now());
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddHistoricoTemporadaH2H` $$
CREATE PROCEDURE `spAddHistoricoTemporadaH2H`(
	pIdTemp INTEGER,
	pIdUsu INTEGER,
	pIdTipoAcesso INTEGER
)
Begin
	DECLARE _count INTEGER DEFAULT 0;
	DECLARE _total INTEGER DEFAULT 0;
	DECLARE _totalTempAnt INTEGER DEFAULT 0;
	DECLARE _position INTEGER DEFAULT 0;
	DECLARE _totalJogos INTEGER DEFAULT 0;
	DECLARE _totalPontos INTEGER DEFAULT 0;
	DECLARE _totalVit INTEGER DEFAULT 0;
	DECLARE _totalEmp INTEGER DEFAULT 0;
	DECLARE _totalAprov INTEGER DEFAULT 0;
	
	If pIdTemp = 0 THEN
		SET pIdTemp = fcGetIdTempPrevious();
	END IF;
	
	SELECT count(1) into _count
	FROM TB_HISTORICO_TEMPORADA
	WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	
	IF (_count) > 0 THEN
	
		IF  pIdTipoAcesso IS NOT NULL THEN
	
			UPDATE TB_HISTORICO_TEMPORADA SET IN_ACESSO_TEMP_ATUAL = pIdTipoAcesso
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
		
		END IF;
	
	ELSE
	
		IF  pIdTipoAcesso IS NULL THEN
		
			SET pIdTipoAcesso = 0;
		
		END IF;

		INSERT INTO TB_HISTORICO_TEMPORADA (ID_TEMPORADA, C.ID_USUARIO, C.IN_ACESSO_TEMP_ATUAL, C.PT_CAMPEAO, C.PT_VICECAMPEAO, C.PT_SEMIS, C.PT_QUARTAS, C.PT_OITAVAS, C.PT_CLASSIF_FASE2, C.
										    PT_VITORIAS_FASE1, C.PT_EMPATES_FASE1, C.IN_POSICAO_ATUAL, C.PT_LIGAS, C.PT_COPAS, C.PT_TOTAL_TEMPORADA, C.QT_JOGOS_TEMPORADA, C.
											QT_TOTAL_PONTOS_TEMPORADA, C.QT_TOTAL_VITORIAS_TEMPORADA, C.QT_TOTAL_EMPATES_TEMPORADA, C.PC_APROVEITAMENTO_TEMPORADAS, C.
											IN_REBAIXADO_TEMP_ANTERIOR, C.QT_LSTNEGRA, C.PT_TOTAL, C.PT_TOTAL_TEMPORADA_ANTERIOR, C.IN_POSICAO_ANTERIOR, C.
											QT_JOGOS_GERAL, C.QT_TOTAL_PONTOS_GERAL, C.QT_TOTAL_VITORIAS_GERAL, C.QT_TOTAL_EMPATES_GERAL, C.PC_APROVEITAMENTO_GERAL)
		VALUES (pIdTemp, C.pIdUsu, C.pIdTipoAcesso, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0);

		SELECT PT_TOTAL, C.PT_TOTAL_TEMPORADA_ANTERIOR, C.IN_POSICAO_ANTERIOR, C.QT_JOGOS_GERAL, C.QT_TOTAL_PONTOS_GERAL, C.QT_TOTAL_VITORIAS_GERAL, C.QT_TOTAL_EMPATES_GERAL, C.PC_APROVEITAMENTO_GERAL 
		into _total, C._totalTempAnt, C._position, C._totalJogos, C._totalPontos, C._totalVit, C._totalEmp, C._totalAprov
		FROM TB_HISTORICO_TEMPORADA
		WHERE ID_TEMPORADA < pIdTemp AND ID_USUARIO = pIdUsu ORDER BY ID_TEMPORADA DESC limit 1;
		
		IF _total IS NOT NULL THEN
		
			UPDATE TB_HISTORICO_TEMPORADA
			SET PT_TOTAL = _total,
			PT_TOTAL_TEMPORADA_ANTERIOR = _totalTempAnt,
			IN_POSICAO_ANTERIOR = _position,
			QT_JOGOS_GERAL = _totalJogos,
			QT_TOTAL_PONTOS_GERAL = _totalPontos,
			QT_TOTAL_VITORIAS_GERAL = _totalVit,
			QT_TOTAL_EMPATES_GERAL = _totalEmp,
			PC_APROVEITAMENTO_GERAL = _totalAprov
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
		
		END IF;
	
	END IF;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddHistoricoTemporadaFUT` $$
CREATE PROCEDURE `spAddHistoricoTemporadaFUT`(
	pIdTemp INTEGER,
	pIdUsu INTEGER,
	pIdTipoAcesso INTEGER
)
Begin
	DECLARE _count INTEGER DEFAULT 0;
	DECLARE _total INTEGER DEFAULT 0;
	DECLARE _totalTempAnt INTEGER DEFAULT 0;
	DECLARE _position INTEGER DEFAULT 0;
	DECLARE _totalJogos INTEGER DEFAULT 0;
	DECLARE _totalPontos INTEGER DEFAULT 0;
	DECLARE _totalVit INTEGER DEFAULT 0;
	DECLARE _totalEmp INTEGER DEFAULT 0;
	DECLARE _totalAprov INTEGER DEFAULT 0;
	
	If pIdTemp = 0 THEN
		SET pIdTemp = fcGetIdTempPrevious();
	END IF;
	
	SELECT count(1) into _count
	FROM TB_HISTORICO_TEMPORADA_FUT
	WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	
	IF (_count) > 0 THEN
	
		UPDATE TB_HISTORICO_TEMPORADA_FUT SET IN_ACESSO_TEMP_ATUAL = pIdTipoAcesso
		WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
	
	ELSE
	
		INSERT INTO TB_HISTORICO_TEMPORADA_FUT (ID_TEMPORADA, C.ID_USUARIO, C.IN_ACESSO_TEMP_ATUAL, C.PT_CAMPEAO, C.PT_VICECAMPEAO, C.PT_SEMIS, C.PT_QUARTAS, C.PT_OITAVAS, C.PT_CLASSIF_FASE2, C.
										    PT_VITORIAS_FASE1, C.PT_EMPATES_FASE1, C.IN_POSICAO_ATUAL, C.PT_LIGAS, C.PT_COPAS, C.PT_TOTAL_TEMPORADA, C.QT_JOGOS_TEMPORADA, C.
											QT_TOTAL_PONTOS_TEMPORADA, C.QT_TOTAL_VITORIAS_TEMPORADA, C.QT_TOTAL_EMPATES_TEMPORADA, C.PC_APROVEITAMENTO_TEMPORADAS, C.
											IN_REBAIXADO_TEMP_ANTERIOR, C.QT_LSTNEGRA, C.PT_TOTAL, C.PT_TOTAL_TEMPORADA_ANTERIOR, C.IN_POSICAO_ANTERIOR, C.
											QT_JOGOS_GERAL, C.QT_TOTAL_PONTOS_GERAL, C.QT_TOTAL_VITORIAS_GERAL, C.QT_TOTAL_EMPATES_GERAL, C.PC_APROVEITAMENTO_GERAL)
		VALUES (pIdTemp, C.pIdUsu, C.pIdTipoAcesso, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0);
	
		SELECT PT_TOTAL, C.PT_TOTAL_TEMPORADA_ANTERIOR, C.IN_POSICAO_ANTERIOR, C.QT_JOGOS_GERAL, C.QT_TOTAL_PONTOS_GERAL, C.QT_TOTAL_VITORIAS_GERAL, C.QT_TOTAL_EMPATES_GERAL, C.PC_APROVEITAMENTO_GERAL 
		into _total, C._totalTempAnt, C._position, C._totalJogos, C._totalPontos, C._totalVit, C._totalEmp, C._totalAprov
		FROM TB_HISTORICO_TEMPORADA_FUT
		WHERE ID_TEMPORADA < pIdTemp AND ID_USUARIO = pIdUsu ORDER BY ID_TEMPORADA DESC limit 1;
		
		IF _total IS NOT NULL THEN
		
			UPDATE TB_HISTORICO_TEMPORADA_FUT
			SET PT_TOTAL = _total,
			PT_TOTAL_TEMPORADA_ANTERIOR = _totalTempAnt,
			IN_POSICAO_ANTERIOR = _position,
			QT_JOGOS_GERAL = _totalJogos,
			QT_TOTAL_PONTOS_GERAL = _totalPontos,
			QT_TOTAL_VITORIAS_GERAL = _totalVit,
			QT_TOTAL_EMPATES_GERAL = _totalEmp,
			PC_APROVEITAMENTO_GERAL = _totalAprov
			WHERE ID_TEMPORADA = pIdTemp AND ID_USUARIO = pIdUsu;
		
		END IF;
	
	END IF;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddHistoricoTemporadaPRO` $$
CREATE PROCEDURE `spAddHistoricoTemporadaPRO`(
	pIdTemp INTEGER,
	pIdTime INTEGER,
	pIdUsu INTEGER,
	pIdTipoAcesso INTEGER
)
Begin
	DECLARE _count INTEGER DEFAULT 0;
	DECLARE _total INTEGER DEFAULT 0;
	DECLARE _totalTempAnt INTEGER DEFAULT 0;
	DECLARE _position INTEGER DEFAULT 0;
	DECLARE _totalJogos INTEGER DEFAULT 0;
	DECLARE _totalPontos INTEGER DEFAULT 0;
	DECLARE _totalVit INTEGER DEFAULT 0;
	DECLARE _totalEmp INTEGER DEFAULT 0;
	DECLARE _totalAprov INTEGER DEFAULT 0;
	
	If pIdTemp = 0 THEN
		SET pIdTemp = fcGetIdTempPrevious();
	END IF;
	
	SELECT count(1) into _count
	FROM TB_HISTORICO_TEMPORADA_PRO
	WHERE ID_TEMPORADA = pIdTemp AND ID_TIME = pIdTime;
	
	IF (_count) > 0 THEN
	
		UPDATE TB_HISTORICO_TEMPORADA_PRO SET IN_ACESSO_TEMP_ATUAL = pIdTipoAcesso
		WHERE ID_TEMPORADA = pIdTemp AND ID_TIME = pIdTime;
	
	ELSE
	
		INSERT INTO TB_HISTORICO_TEMPORADA_PRO (ID_TEMPORADA, C.ID_TIME, C.ID_USUARIO, C.IN_ACESSO_TEMP_ATUAL, C.PT_CAMPEAO, C.PT_VICECAMPEAO, C.PT_SEMIS, C.PT_QUARTAS, C.PT_OITAVAS, C.PT_CLASSIF_FASE2, C.
										    PT_VITORIAS_FASE1, C.PT_EMPATES_FASE1, C.IN_POSICAO_ATUAL, C.PT_LIGAS, C.PT_COPAS, C.PT_TOTAL_TEMPORADA, C.QT_JOGOS_TEMPORADA, C.
											QT_TOTAL_PONTOS_TEMPORADA, C.QT_TOTAL_VITORIAS_TEMPORADA, C.QT_TOTAL_EMPATES_TEMPORADA, C.PC_APROVEITAMENTO_TEMPORADAS, C.
											IN_REBAIXADO_TEMP_ANTERIOR, C.QT_LSTNEGRA, C.PT_TOTAL, C.PT_TOTAL_TEMPORADA_ANTERIOR, C.IN_POSICAO_ANTERIOR, C.
											QT_JOGOS_GERAL, C.QT_TOTAL_PONTOS_GERAL, C.QT_TOTAL_VITORIAS_GERAL, C.QT_TOTAL_EMPATES_GERAL, C.PC_APROVEITAMENTO_GERAL)
		VALUES (pIdTemp, C.pIdTime, C.pIdUsu, C.pIdTipoAcesso, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0, C.0);
	
		SELECT PT_TOTAL, C.PT_TOTAL_TEMPORADA_ANTERIOR, C.IN_POSICAO_ANTERIOR, C.QT_JOGOS_GERAL, C.QT_TOTAL_PONTOS_GERAL, C.QT_TOTAL_VITORIAS_GERAL, C.QT_TOTAL_EMPATES_GERAL, C.PC_APROVEITAMENTO_GERAL 
		into _total, C._totalTempAnt, C._position, C._totalJogos, C._totalPontos, C._totalVit, C._totalEmp, C._totalAprov
		FROM TB_HISTORICO_TEMPORADA_PRO
		WHERE ID_TEMPORADA < pIdTemp AND ID_TIME = pIdTime ORDER BY ID_TEMPORADA DESC limit 1;
		
		IF _total IS NOT NULL THEN
		
			UPDATE TB_HISTORICO_TEMPORADA_PRO
			SET PT_TOTAL = _total,
			ID_USUARIO = pIdUsu,
			PT_TOTAL_TEMPORADA_ANTERIOR = _totalTempAnt,
			IN_POSICAO_ANTERIOR = _position,
			QT_JOGOS_GERAL = _totalJogos,
			QT_TOTAL_PONTOS_GERAL = _totalPontos,
			QT_TOTAL_VITORIAS_GERAL = _totalVit,
			QT_TOTAL_EMPATES_GERAL = _totalEmp,
			PC_APROVEITAMENTO_GERAL = _totalAprov
			WHERE ID_TEMPORADA = pIdTemp AND ID_TIME = pIdTime;
		
		END IF;
	
	END IF;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateToEndBancoReservaByTipo` $$
CREATE PROCEDURE `spUpdateToEndBancoReservaByTipo`(pTpBancoReserva VARCHAR(3))
begin      
   update TB_LISTA_BANCO_RESERVA
   set DT_FIM = now()
   where TP_BANCO_RESERVA = pTpBancoReserva
   and DT_FIM IS NULL;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddBancoReserva` $$
CREATE PROCEDURE `spAddBancoReserva`(
	pIdUsu INTEGER,
	pNmTime VARCHAR(50),
	pTpBanco VARCHAR(3)
)
begin      
	DECLARE _Total INTEGER DEFAULT NULL;
	
	select count(1) into _Total
	from TB_LISTA_BANCO_RESERVA
	where ID_USUARIO = pIdUsu AND TP_BANCO_RESERVA = pTpBanco AND DT_FIM IS NULL;
	
	IF _Total = 0 THEN
	   insert into TB_LISTA_BANCO_RESERVA (ID_USUARIO, C.TP_BANCO_RESERVA, C.NM_TIME_FUT, C.IN_CONSOLE, C.DT_INICIO)
	   values (pIdUsu, C.pTpBanco, C.pNmTime, C.'PS4', C.now());
	END IF;

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateToEndBancoReserva` $$
CREATE PROCEDURE `spUpdateToEndBancoReserva`(pIdUser INTEGER, C.PTpBco VARCHAR(5))
begin      
   update TB_LISTA_BANCO_RESERVA
   set DT_FIM = now()
   where id_usuario = pIdUser
   and DT_FIM IS NULL AND TP_BANCO_RESERVA = PTpBco;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddTemporada` $$
CREATE PROCEDURE `spAddTemporada`(
	pIdTemp INTEGER,
	pNmTemp VARCHAR(50),
	pDtInicio DATE,
	pDtFim DATE,
	pInAtiva INTEGER
)
begin
	IF pIdTemp IS NULL THEN
	
		insert into TB_TEMPORADA (NM_TEMPORADA, C.DT_INICIO, C.DT_FIM, C.IN_TEMPORADA_ATIVA)
		values (pNmTemp, C.pDtInicio, C.pDtFim, C.pInAtiva);
	
	ELSE
	
		insert into TB_TEMPORADA (ID_TEMPORADA, C.NM_TEMPORADA, C.DT_INICIO, C.DT_FIM, C.IN_TEMPORADA_ATIVA)
		values (pIdTemp, C.pDtInicio, C.pDtFim, C.pInAtiva);
	
	END IF;
End$$
DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetIdUsuarioByTime` $$
CREATE FUNCTION `fcGetIdUsuarioByTime`(pIdCamp INTEGER, C.pIdTime INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idUsu INTEGER DEFAULT 0;
	
	SELECT UT1.ID_USUARIO into _idUsu
	FROM TB_USUARIO_TIME UT1, C.TB_CLASSIFICACAO TC1
	WHERE UT1.ID_CAMPEONATO = pIdCamp AND UT1.ID_TIME = pIdTime AND UT1.DT_VIGENCIA_FIM IS NULL
	AND UT1.ID_TIME = TC1.ID_TIME ORDER BY UT1.ID_USUARIO LIMIT 1;
	
	IF (_idUsu IS NULL) THEN
	
		SET _idUsu = 0;
	
	END IF;
	
	RETURN _idUsu;
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
	insert into TB_USUARIO_TIME (ID_CAMPEONATO, C.ID_USUARIO, C.ID_TIME, C.DT_SORTEIO, C.INDICADOR_ORDEM_SORTEIO)
	values (pIdCamp, C.pIdUsu, C.pIdTime, C.now(), C.pOrdem);
End$$
DELIMITER ;
