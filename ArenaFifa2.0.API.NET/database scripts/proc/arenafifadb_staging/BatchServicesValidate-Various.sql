USE `arenafifadb_staging`;

ALTER TABLE TB_CONFIRMACAO_TEMPORADA MODIFY DT_CONFIRMACAO DATE;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetIDsTemporadaByMode` $$
CREATE PROCEDURE `spGetIDsTemporadaByMode`(
	pMode VARCHAR(3)
)
begin
	DECLARE _nmTemp VARCHAR(50) DEFAULT NULL;
	DECLARE _idTemp INTEGER DEFAULT NULL;
	DECLARE _nmTempPrevious VARCHAR(50) DEFAULT NULL;
	DECLARE _idTempPrevious INTEGER DEFAULT NULL;
	
	SET _idTempPrevious = fcGetIdTempCurrent();
	SET _idTemp = _idTempPrevious + 1;
	
	SELECT NM_TEMPORADA into _nmTempPrevious FROM TB_TEMPORADA WHERE ID_TEMPORADA = _idTempPrevious;
	SET _nmTemp = CONCAT((_idTemp - 1), "ª Temporada");
	
	SELECT _idTemp as id_current_temporada, _nmTemp as nm_current_temporada, _idTempPrevious as id_previous_temporada, _nmTempPrevious as nm_previous_temporada;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoCDM` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoCDM`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select *, (PT_TOTAL+PT_TOTAL_ATUAL) as PT_TOTAL_GERAL FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID,
   (SELECT count(T.id_usuario) FROM TB_CONFIRMACAO_TEMPORADA T WHERE T.ID_Temporada = pIdTemporada AND T.IN_CONFIRMACAO = 1 AND T.ID_CAMPEONATO IN (1,2,3,4) AND T.ID_USUARIO = C.ID_USUARIO) as IN_CONFIRMA_DIVISAO,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   0 as PT_TOTAL_ATUAL,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_STATUS, IN_CONFIRMACAO DESC, (PT_TOTAL+PT_TOTAL_ATUAL) DESC, IN_ORDENACAO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoH2H` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoH2H`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select *, (PT_TOTAL+PT_TOTAL_ATUAL) as PT_TOTAL_GERAL FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   0 as PT_TOTAL_ATUAL,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_STATUS, IN_CONFIRMACAO DESC, (PT_TOTAL+PT_TOTAL_ATUAL) DESC, IN_ORDENACAO;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoH2HBco` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoH2HBco`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select * FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and (C.IN_CONFIRMACAO IS NULL OR C.IN_CONFIRMACAO = 1)
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_Status, IN_USUARIO_MODERADOR, IN_CONFIRMACAO DESC, IN_ORDENACAO, DT_CONFIRMACAO, PT_LSTNEGRA, PT_TOTAL DESC, ID_Usuario;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoFUT` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoFUT`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select *, (PT_TOTAL+PT_TOTAL_ATUAL) as PT_TOTAL_GERAL FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA_FUT H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   0 as PT_TOTAL_ATUAL,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_STATUS, IN_CONFIRMACAO DESC, (PT_TOTAL+PT_TOTAL_ATUAL) DESC, IN_ORDENACAO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoFUTBco` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoFUTBco`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select * FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA_FUT H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and (C.IN_CONFIRMACAO = 9 OR C.IN_CONFIRMACAO = 1 OR C.IN_CONFIRMACAO IS NULL)
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_Status, IN_USUARIO_MODERADOR, IN_CONFIRMACAO DESC, IN_ORDENACAO, DT_CONFIRMACAO, PT_LSTNEGRA, PT_TOTAL DESC, ID_Usuario;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoPRO` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoPRO`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select * FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA_PRO H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   0 as PT_TOTAL_ATUAL,
   (SELECT count(1) as TOTAL FROM TB_CONFIRM_ELENCO_PRO J WHERE J.ID_TEMPORADA = pIdTemporada AND J.ID_USUARIO_MANAGER = U.ID_USUARIO) as TOTAL_JOGADORES,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_STATUS, IN_CONFIRMACAO DESC, (PT_TOTAL+PT_TOTAL_ATUAL) DESC, IN_ORDENACAO, PT_LSTNEGRA;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoPROBco` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoPROBco`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select * FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA_PRO H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   (SELECT count(1) as TOTAL FROM TB_CONFIRM_ELENCO_PRO J WHERE J.ID_TEMPORADA = pIdTemporada AND J.ID_USUARIO_MANAGER = U.ID_USUARIO) as TOTAL_JOGADORES,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and (C.IN_CONFIRMACAO = 9 OR C.IN_CONFIRMACAO = 1 OR C.IN_CONFIRMACAO IS NULL)
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_STATUS, IN_CONFIRMACAO DESC, IN_ORDENACAO, DT_CONFIRMACAO, PT_LSTNEGRA, PT_TOTAL DESC, ID_Usuario;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaNoFilterCRUD` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaNoFilterCRUD`()
begin
	DECLARE _idTempNova INTEGER DEFAULT NULL;
	DECLARE _idTempAtual INTEGER DEFAULT NULL;
	
	SET _idTempAtual = fcGetIdTempCurrent();
	SET _idTempNova = _idTempAtual + 1;
	
	select * FROM (SELECT C.*, DATE_FORMAT(c.DT_CONFIRMACAO,'%d/%m/%Y') as DT_CONFIRMACAO_FORMATADA, U.NM_Usuario, U.PSN_Id,
	(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
	(SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = _idTempAtual AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
	from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
	where C.ID_TEMPORADA = _idTempNova
	and C.ID_USUARIO = U.ID_USUARIO) as X
	order by ID_CAMPEONATO, IN_ORDENACAO, DS_Status, IN_CONFIRMACAO DESC, DT_CONFIRMACAO, PT_TOTAL DESC, NM_Usuario;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaWithFilterCRUD` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaWithFilterCRUD`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER
)
begin      
   select * FROM (SELECT C.*, DATE_FORMAT(c.DT_CONFIRMACAO,'%d/%m/%Y') as DT_CONFIRMACAO_FORMATADA, U.NM_Usuario, U.PSN_Id,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and (U.NM_USUARIO like CONCAT('%',pFilter,'%') or C.DS_Status like CONCAT('%',pFilter,'%') or U.PSN_Id like CONCAT('%',pFilter,'%'))
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, IN_ORDENACAO, DS_Status, IN_CONFIRMACAO DESC, DT_CONFIRMACAO, PT_TOTAL DESC, NM_Usuario;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetConfirmacaoTemporada` $$
CREATE PROCEDURE `spGetConfirmacaoTemporada`(
	pIdTemporada INTEGER,
	pIdCampeonato INTEGER,
	pIdUsu INTEGER
)
begin      
   select *, DATE_FORMAT(c.DT_CONFIRMACAO,'%d/%m/%Y') as DT_CONFIRMACAO_FORMATADA, U.NM_Usuario, U.PSN_Id
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and C.ID_CAMPEONATO = pIdCampeonato
   and C.ID_USUARIO = pIdUsu
   and C.ID_USUARIO = U.ID_USUARIO;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetLastOrdemConfirmacaoTemporada` $$
CREATE FUNCTION `fcGetLastOrdemConfirmacaoTemporada`(
	pIdTemporada INTEGER,
	pIdsCampeonato VARCHAR(30)
) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _inOrdenacao INTEGER DEFAULT NULL;
	
	select IN_ORDENACAO into _inOrdenacao
	from TB_CONFIRMACAO_TEMPORADA
	where ID_TEMPORADA = pIdTemporada
	and ID_CAMPEONATO IN (pIdsCampeonato)
	order by IN_ORDENACAO desc
	limit 1;
	
	IF (_inOrdenacao IS NULL) THEN
	
		SET _inOrdenacao = 1000;
	
	ELSE
	
		SET _inOrdenacao = _inOrdenacao + 1;

	END IF;
	
	RETURN _inOrdenacao;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetUsuarioById` $$
CREATE PROCEDURE `spGetUsuarioById`(pIdUsuario INTEGER)
begin      
   select *, DATE_FORMAT(DT_ULTIMO_ACESSO,'%d/%m/%Y') as DT_ACESSO_FORMATADA, 
   DATE_FORMAT(DT_CADASTRO,'%d/%m/%Y') as DT_CADASTRO_FORMATADA, DATE_FORMAT(DT_ULTIMA_ALTERACAO,'%d/%m/%Y %H:%i:%s') as DT_ALTERACAO_FORMATADA,
   fcGetCurrentIdTimeH2H(id_usuario) as id_TimeH2H, fcGetCurrentIdTimeFUT(id_usuario) as id_TimeFUT, fcGetCurrentIdTimePRO(id_usuario) as id_TimePRO
   from TB_USUARIO
   where ID_USUARIO = pIdUsuario;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllSquadOfClub` $$
CREATE PROCEDURE `spGetAllSquadOfClub`(
	pIdTemporada INTEGER,
	pIdManager INTEGER
)
begin
	DECLARE _clubID INTEGER DEFAULT 0;
	
	IF pIdTemporada = 0 THEN
		
		SET _clubID = fcGetCurrentIdTimePRO(pIdManager);
	
		select C.ID_GOLEADOR, C.ID_USUARIO, DATE_FORMAT(C.DT_INSCRICAO,'%d/%m/%Y %H:%i') as DT_CONFIRMACAO_FORMATADA, U.NM_Usuario, U.PSN_Id
		from TB_GOLEADOR C, TB_USUARIO U
		where C.ID_TIME = _clubID
		and C.ID_USUARIO = U.ID_USUARIO
		ORDER BY C.DT_INSCRICAO, C.ID_USUARIO;

	ELSE
	
		select C.*, 0 as ID_GOLEADOR, DATE_FORMAT(C.DT_CONFIRMACAO,'%d/%m/%Y %H:%i') as DT_CONFIRMACAO_FORMATADA, U.NM_Usuario, U.PSN_Id
		from TB_CONFIRM_ELENCO_PRO C, TB_USUARIO U
		where C.ID_TEMPORADA = pIdTemporada
		and C.ID_USUARIO_MANAGER = pIdManager
		and C.ID_USUARIO = U.ID_USUARIO
		ORDER BY C.DT_CONFIRMACAO, C.ID_USUARIO;

	END IF;
	
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetCurrentIdTimeH2H` $$
CREATE FUNCTION `fcGetCurrentIdTimeH2H`(pIdUsu INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idTime INTEGER DEFAULT NULL;
	
	select X.ID_TIME into _idTime
	from TB_USUARIO_TIME X, TB_TIME T, TB_CAMPEONATO C
	where X.id_usuario = pIdUsu
	and X.DT_VIGENCIA_FIM is null
	and T.DS_Tipo is not null
	and C.ID_TEMPORADA IN (SELECT T.ID_TEMPORADA FROM TB_TEMPORADA T WHERE T.DT_FIM is null GROUP BY ID_TEMPORADA)
	and C.SG_TIPO_CAMPEONATO in ('DIV1','DIV2','DIV3','DIV4')
	and X.ID_Time = T.ID_Time
	and X.ID_CAMPEONATO = C.ID_CAMPEONATO
	order by C.ID_TEMPORADA desc
	limit 1;
	
	RETURN _idTime;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetCurrentIdTimeFUT` $$
CREATE FUNCTION `fcGetCurrentIdTimeFUT`(pIdUsu INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idTime INTEGER DEFAULT NULL;
	
	select X.ID_TIME into _idTime
	from TB_USUARIO_TIME X, TB_TIME T, TB_CAMPEONATO C
	where X.id_usuario = pIdUsu
	and X.DT_VIGENCIA_FIM is null
	and T.DS_Tipo is not null
	and C.ID_TEMPORADA IN (SELECT T.ID_TEMPORADA FROM TB_TEMPORADA T WHERE T.DT_FIM is null GROUP BY ID_TEMPORADA)
	and C.SG_TIPO_CAMPEONATO in ('LFUT','CFUT','FUT1','FUT2')
	and X.ID_Time = T.ID_Time
	and X.ID_CAMPEONATO = C.ID_CAMPEONATO
	order by C.ID_TEMPORADA desc
	limit 1;
	
	RETURN _idTime;
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
	and C.ID_TEMPORADA IN (SELECT T.ID_TEMPORADA FROM TB_TEMPORADA T WHERE T.DT_FIM is null GROUP BY ID_TEMPORADA)
	and C.SG_TIPO_CAMPEONATO in ('CPRO','PRO1','PRO2')
	and X.ID_Time = T.ID_Time
	and X.ID_CAMPEONATO = C.ID_CAMPEONATO
	order by C.ID_TEMPORADA desc
	limit 1;
	
	RETURN _idTime;
End$$
DELIMITER ;



DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetCurrentIdTimeCDM` $$
CREATE FUNCTION `fcGetCurrentIdTimeCDM`(pIdUsu INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idTime INTEGER DEFAULT NULL;
	
	select X.ID_TIME into _idTime
	from TB_USUARIO_TIME X, TB_TIME T, TB_CAMPEONATO C
	where X.id_usuario = pIdUsu
	and X.DT_VIGENCIA_FIM is null
	and T.DS_Tipo is not null
	and C.ID_TEMPORADA IN (SELECT T.ID_TEMPORADA FROM TB_TEMPORADA T WHERE T.DT_FIM is null GROUP BY ID_TEMPORADA)
	and C.SG_TIPO_CAMPEONATO in ('CPDM','ERCP')
	and X.ID_Time = T.ID_Time
	and X.ID_CAMPEONATO = C.ID_CAMPEONATO
	order by C.ID_TEMPORADA desc
	limit 1;
	
	RETURN _idTime;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddUpdateConfirmacaoTemporada` $$
CREATE PROCEDURE `spAddUpdateConfirmacaoTemporada`(
	pIdTemporada INTEGER,
	pIdCampeonato INTEGER,
	pIdUsu INTEGER,
	pInConfirm INTEGER,
	pInOrdernacao INTEGER,
	pNmTimeFUT VARCHAR(50)
)
begin
	DECLARE _inLastOrdenacao INTEGER DEFAULT NULL;
	DECLARE _inUsuarioFound INTEGER DEFAULT 0;
	DECLARE _inConfirmDate DATETIME DEFAULT NULL;

	IF pIdTemporada = 0 THEN
		SET pIdTemporada = fcGetIdTempCurrent() + 1;
	END IF;
	
	IF pInOrdernacao = 0 THEN
	
		select IN_ORDENACAO into _inLastOrdenacao
		from TB_CONFIRMACAO_TEMPORADA
		where ID_TEMPORADA = pIdTemporada
		and ID_CAMPEONATO = pIdCampeonato
		order by IN_ORDENACAO DESC
		limit 1;
		
		IF (_inLastOrdenacao IS NULL) THEN
		
			SET _inLastOrdenacao = 1000;
		
		ELSE
		
			SET _inLastOrdenacao = _inLastOrdenacao + 1;

		END IF;
	
	ELSE
	
		SET _inLastOrdenacao = pInOrdernacao;
	
	END IF;
	
	select count(1) into _inUsuarioFound
	from TB_CONFIRMACAO_TEMPORADA
	where ID_TEMPORADA = pIdTemporada
	and ID_CAMPEONATO = pIdCampeonato
	and ID_USUARIO = pIdUsu;
	
	
	IF pInConfirm >= 0 THEN
		SET _inConfirmDate = CURRENT_DATE();
    ELSE
		SET _inConfirmDate = NULL;
		SET _inLastOrdenacao = 0;
	END IF;
	
	IF (_inUsuarioFound = 0) THEN
	
		insert into TB_CONFIRMACAO_TEMPORADA (ID_TEMPORADA, ID_CAMPEONATO, ID_USUARIO, NM_TIME, IN_CONFIRMACAO, IN_ORDENACAO, DT_CONFIRMACAO, IN_CONSOLE, DS_STATUS, DS_DESCRICAO_STATUS)
		values (pIdTemporada, pIdCampeonato, pIdUsu, pNmTimeFUT, pInConfirm, _inLastOrdenacao, _inConfirmDate, 'PS4', 'AP', 'Aprovada.');
	
	ELSE
	
		update TB_CONFIRMACAO_TEMPORADA
		set NM_TIME = pNmTimeFUT,
		IN_CONFIRMACAO = pInConfirm,
		DT_CONFIRMACAO = _inConfirmDate,
		IN_ORDENACAO = _inLastOrdenacao
		where ID_TEMPORADA = pIdTemporada
		and ID_USUARIO = pIdUsu
		and ID_CAMPEONATO = pIdCampeonato;
	
	END IF;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddUpdateConfirmacaoTemporadaPRO` $$
CREATE PROCEDURE `spAddUpdateConfirmacaoTemporadaPRO`(
	pIdTemporada INTEGER,
	pIdCampeonato INTEGER,
	pIdUsu INTEGER,
	pInConfirm INTEGER,
	pNmTimeFUT VARCHAR(50)
)
begin
	DECLARE _inLastOrdenacao INTEGER DEFAULT NULL;
	DECLARE _inUsuarioFound INTEGER DEFAULT 0;
	
	select IN_ORDENACAO into _inLastOrdenacao
	from TB_CONFIRMACAO_TEMPORADA
	where ID_TEMPORADA = pIdTemporada
	and ID_CAMPEONATO = pIdCampeonato
	order by IN_ORDENACAO DESC
	limit 1;
	
	IF (_inLastOrdenacao IS NULL) THEN
	
		SET _inLastOrdenacao = 1000;
	
	ELSE
	
		SET _inLastOrdenacao = _inLastOrdenacao + 1;

	END IF;
	
	select count(1) into _inUsuarioFound
	from TB_CONFIRMACAO_TEMPORADA
	where ID_TEMPORADA = pIdTemporada
	and ID_USUARIO = pIdUsu
	and ID_CAMPEONATO = pIdCampeonato;
	
	IF (_inUsuarioFound = 0) THEN
	
		insert into TB_CONFIRMACAO_TEMPORADA (ID_TEMPORADA, ID_USUARIO, ID_CAMPEONATO, NM_TIME, IN_CONFIRMACAO, IN_ORDENACAO, DT_CONFIRMACAO, IN_CONSOLE, DS_STATUS, DS_DESCRICAO_STATUS)
		values (pIdTemporada, pIdCampeonato, pIdUsu, pNmTimeFUT, pInConfirm, _inLastOrdenacao, NOW(), 'PS4', 'AP', 'Aprovada.');
	
	ELSE
	
		update TB_CONFIRMACAO_TEMPORADA
		set NM_TIME = pNmTimeFUT,
		IN_CONFIRMACAO = pInConfirm,
		DT_CONFIRMACAO = NOW()
		where ID_TEMPORADA = pIdTemporada
		and ID_USUARIO = pIdUsu
		and ID_CAMPEONATO = pIdCampeonato;
	
	END IF;
End$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonato` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonato`(
	pIdTemporada INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select *
   from TB_CONFIRMACAO_TEMPORADA
   where ID_TEMPORADA = pIdTemporada
   and ID_CAMPEONATO IN (pIdsCampeonato)
   order by IN_ORDENACAO DESC;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoUsuario` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoUsuario`(
	pIdTemporada INTEGER,
	pIdsCampeonato VARCHAR(30),
	pIdUsu INTEGER
)
begin      
   select *
   from TB_CONFIRMACAO_TEMPORADA
   where ID_TEMPORADA = pIdTemporada
   and ID_USUARIO = pIdUsu
   and ID_CAMPEONATO IN (pIdsCampeonato);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoCDM` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoCDM`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select *, (PT_TOTAL+PT_TOTAL_ATUAL) as PT_TOTAL_GERAL FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID,
   (SELECT count(T.id_usuario) FROM TB_CONFIRMACAO_TEMPORADA T WHERE T.ID_Temporada = pIdTemporada AND T.IN_CONFIRMACAO = 1 AND T.ID_CAMPEONATO IN (1,2,3,4) AND T.ID_USUARIO = C.ID_USUARIO) as IN_CONFIRMA_DIVISAO,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   0 as PT_TOTAL_ATUAL,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and C.IN_CONFIRMACAO = 1
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_STATUS, IN_CONFIRMACAO DESC, (PT_TOTAL+PT_TOTAL_ATUAL) DESC, IN_ORDENACAO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoH2H` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoH2H`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select *, (PT_TOTAL+PT_TOTAL_ATUAL) as PT_TOTAL_GERAL FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   0 as PT_TOTAL_ATUAL,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_STATUS, IN_CONFIRMACAO DESC, (PT_TOTAL+PT_TOTAL_ATUAL) DESC, IN_ORDENACAO;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoH2HBco` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoH2HBco`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select * FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and (C.IN_CONFIRMACAO IS NULL OR C.IN_CONFIRMACAO = 1)
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_Status, IN_USUARIO_MODERADOR, IN_CONFIRMACAO DESC, IN_ORDENACAO, DT_CONFIRMACAO, PT_LSTNEGRA, PT_TOTAL DESC, ID_Usuario;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoFUT` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoFUT`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select *, (PT_TOTAL+PT_TOTAL_ATUAL) as PT_TOTAL_GERAL FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA_FUT H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   0 as PT_TOTAL_ATUAL,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_STATUS, IN_CONFIRMACAO DESC, (PT_TOTAL+PT_TOTAL_ATUAL) DESC, IN_ORDENACAO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoFUTBco` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoFUTBco`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select * FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID, U.IN_USUARIO_MODERADOR,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA_FUT H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and (C.IN_CONFIRMACAO = 9 OR C.IN_CONFIRMACAO = 1 OR C.IN_CONFIRMACAO IS NULL)
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_Status, IN_USUARIO_MODERADOR, IN_CONFIRMACAO DESC, IN_ORDENACAO, DT_CONFIRMACAO, PT_LSTNEGRA, PT_TOTAL DESC, ID_Usuario;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoPRO` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoPRO`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select * FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA_PRO H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   0 as PT_TOTAL_ATUAL,
   (SELECT count(1) as TOTAL FROM TB_CONFIRM_ELENCO_PRO J WHERE J.ID_TEMPORADA = pIdTemporada AND J.ID_USUARIO_MANAGER = U.ID_USUARIO) as TOTAL_JOGADORES,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_STATUS, IN_CONFIRMACAO DESC, (PT_TOTAL+PT_TOTAL_ATUAL) DESC, IN_ORDENACAO, PT_LSTNEGRA;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaOfCampeonatoPROBco` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaOfCampeonatoPROBco`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER,
	pIdsCampeonato VARCHAR(30)
)
begin      
   select * FROM (SELECT C.*, U.NM_Usuario, U.PSN_ID,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA_PRO H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   (SELECT count(1) as TOTAL FROM TB_CONFIRM_ELENCO_PRO J WHERE J.ID_TEMPORADA = pIdTemporada AND J.ID_USUARIO_MANAGER = U.ID_USUARIO) as TOTAL_JOGADORES,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and FIND_IN_SET(C.ID_CAMPEONATO, pIdsCampeonato)
   and (C.IN_CONFIRMACAO = 9 OR C.IN_CONFIRMACAO = 1 OR C.IN_CONFIRMACAO IS NULL)
   and U.IN_USUARIO_ATIVO = TRUE
   and U.IN_DESEJA_PARTICIPAR = 1
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, DS_STATUS, IN_CONFIRMACAO DESC, IN_ORDENACAO, DT_CONFIRMACAO, PT_LSTNEGRA, PT_TOTAL DESC, ID_Usuario;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaNoFilterCRUD` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaNoFilterCRUD`()
begin
	DECLARE _idTempNova INTEGER DEFAULT NULL;
	DECLARE _idTempAtual INTEGER DEFAULT NULL;
	
	SET _idTempAtual = fcGetIdTempCurrent();
	SET _idTempNova = _idTempAtual + 1;
	
	select * FROM (SELECT C.*, DATE_FORMAT(c.DT_CONFIRMACAO,'%d/%m/%Y') as DT_CONFIRMACAO_FORMATADA, U.NM_Usuario, U.PSN_Id,
	(SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
	(SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = _idTempAtual AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
	from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
	where C.ID_TEMPORADA = _idTempNova
	and C.ID_USUARIO = U.ID_USUARIO) as X
	order by ID_CAMPEONATO, IN_ORDENACAO, DS_Status, IN_CONFIRMACAO DESC, DT_CONFIRMACAO, PT_TOTAL DESC, NM_Usuario;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllConfirmacaoTemporadaWithFilterCRUD` $$
CREATE PROCEDURE `spGetAllConfirmacaoTemporadaWithFilterCRUD`(
	pIdTemporada INTEGER,
	pIdTemporadaAnt INTEGER
)
begin      
   select * FROM (SELECT C.*, DATE_FORMAT(c.DT_CONFIRMACAO,'%d/%m/%Y') as DT_CONFIRMACAO_FORMATADA, U.NM_Usuario, U.PSN_Id,
   (SELECT H.PT_TOTAL FROM TB_HISTORICO_TEMPORADA H WHERE H.ID_USUARIO = U.ID_USUARIO ORDER BY H.ID_TEMPORADA desc limit 1) as PT_TOTAL,
   (SELECT PT_TOTAL FROM TB_LISTA_NEGRA L WHERE L.ID_Temporada = pIdTemporadaAnt AND L.ID_USUARIO = C.ID_USUARIO AND L.PT_TOTAL > 0) as PT_LSTNEGRA
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and (U.NM_USUARIO like CONCAT('%',pFilter,'%') or C.DS_Status like CONCAT('%',pFilter,'%') or U.PSN_Id like CONCAT('%',pFilter,'%'))
   and C.ID_USUARIO = U.ID_USUARIO) as X
   order by ID_CAMPEONATO, IN_ORDENACAO, DS_Status, IN_CONFIRMACAO DESC, DT_CONFIRMACAO, PT_TOTAL DESC, NM_Usuario;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetConfirmacaoTemporada` $$
CREATE PROCEDURE `spGetConfirmacaoTemporada`(
	pIdTemporada INTEGER,
	pIdCampeonato INTEGER,
	pIdUsu INTEGER
)
begin      
   select *, DATE_FORMAT(c.DT_CONFIRMACAO,'%d/%m/%Y') as DT_CONFIRMACAO_FORMATADA, U.NM_Usuario, U.PSN_Id
   from TB_CONFIRMACAO_TEMPORADA C, TB_USUARIO U
   where C.ID_TEMPORADA = pIdTemporada
   and C.ID_CAMPEONATO = pIdCampeonato
   and C.ID_USUARIO = pIdUsu
   and C.ID_USUARIO = U.ID_USUARIO;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetLastOrdemConfirmacaoTemporada` $$
CREATE FUNCTION `fcGetLastOrdemConfirmacaoTemporada`(
	pIdTemporada INTEGER,
	pIdsCampeonato VARCHAR(30)
) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _inOrdenacao INTEGER DEFAULT NULL;
	
	select IN_ORDENACAO into _inOrdenacao
	from TB_CONFIRMACAO_TEMPORADA
	where ID_TEMPORADA = pIdTemporada
	and ID_CAMPEONATO IN (pIdsCampeonato)
	order by IN_ORDENACAO desc
	limit 1;
	
	IF (_inOrdenacao IS NULL) THEN
	
		SET _inOrdenacao = 1000;
	
	ELSE
	
		SET _inOrdenacao = _inOrdenacao + 1;

	END IF;
	
	RETURN _inOrdenacao;
End$$
DELIMITER ;





DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddConfirmacaoTemporadaRenovacaoPRO` $$
CREATE PROCEDURE `spAddConfirmacaoTemporadaRenovacaoPRO`(
	pIdTemporada INTEGER,
	pIdUsu INTEGER,
	pNmTime VARCHAR(50),
	pDDD VARCHAR(10),
	pCelular VARCHAR(30)
)
begin
	DECLARE _total INTEGER DEFAULT 0;
	DECLARE _idTime INTEGER DEFAULT NULL;
	DECLARE _inOrdenacao INTEGER DEFAULT NULL;
	DECLARE _IdBcoPRO INTEGER DEFAULT 13;
	DECLARE _IdPRO VARCHAR(5) DEFAULT "14,15";
	
	select count(1) into _total
	from TB_CONFIRMACAO_TEMPORADA
	where ID_TEMPORADA = pIdTemporada
	and ID_USUARIO = pIdUsu
	and ID_CAMPEONATO IN (_IdPRO)
	and NM_TIME = pNmTime;
	
	IF (_total > 0) THEN
	
		select '1' as COD_VALIDATION, 'Incorrect validation - renewal already is done.' as DSC_VALIDATION;
	
	ELSE
	
		select count(1) into _total
		from TB_CONFIRMACAO_TEMPORADA
		where ID_TEMPORADA = pIdTemporada
		and ID_USUARIO = pIdUsu
		and ID_CAMPEONATO IN (_IdPRO)
		and IN_CONFIRMACAO = 1;
		
		IF _total > 0 THEN
		
			select '2' as COD_VALIDATION, 'Incorrect validation - renewal has already been made.' as DSC_VALIDATION;
	
		ELSE
		
			SET _total = 0;
		
			select count(1) into _total
			from TB_CONFIRMACAO_TEMPORADA
			where ID_TEMPORADA = pIdTemporada
			and ID_USUARIO <> pIdUsu
			and ID_CAMPEONATO IN (_IdPRO)
			and NM_TIME = pNmTime;
			
			IF _total > 0 THEN

				select '3' as COD_VALIDATION, 'Incorrect validation - There is a renewal for another manager.' as DSC_VALIDATION;
	
			ELSE
			
				SET _inOrdenacao = fcGetLastOrdemConfirmacaoTemporada(pIdTemporada,_IdPRO);
			
				SET _total = 0;
		
				select count(1) into _total
				from TB_CONFIRMACAO_TEMPORADA
				where ID_TEMPORADA = pIdTemporada
				and ID_USUARIO = pIdUsu
				and ID_CAMPEONATO IN (_IdPRO);
				
				IF _total > 0 THEN
				
					update TB_CONFIRMACAO_TEMPORADA
					set IN_ORDENACAO = _inOrdenacao,
					IN_CONFIRMACAO = 1,
					DS_STATUS = 'AP',
					DT_CONFIRMACAO = NOW(),
					NM_TIME = pNmTime,
					NO_DDD = pDDD,
					NO_CELULAR = pCelular,
					IN_UPLOAD_LOGO_TIME = false
					where ID_TEMPORADA = pIdTemporada
					and ID_USUARIO = pIdUsu
					and ID_CAMPEONATO IN (_IdPRO);
	
				ELSE
				
					insert into TB_CONFIRMACAO_TEMPORADA (ID_TEMPORADA, ID_USUARIO, ID_CAMPEONATO, IN_CONSOLE, IN_ORDENACAO, IN_CONFIRMACAO, DS_STATUS, DT_CONFIRMACAO, NM_TIME, NO_DDD,
					NO_CELULAR, IN_UPLOAD_LOGO_TIME)
					values (pIdTemporada, pIdUsu, _IdBcoPRO, 'PS4', _inOrdenacao, 1, 'AP', NOW(), pNmTime, pDDD, pCelular, false);
					
				END IF;
			
				update TB_USUARIO
				set NO_DDD = pDDD,
				NO_CELULAR = pCelular
				where ID_USUARIO = pIdUsu;
				
				insert into TB_CONFIRM_ELENCO_PRO (ID_TEMPORADA, ID_USUARIO_MANAGER, ID_USUARIO, DT_CONFIRMACAO)
				values (pIdTemporada, pIdUsu, pIdUsu, NOW());
				
				SET _idTime = fcGetCurrentIdTimePRO(pIdUsu);
				
				IF (_idTime IS NOT NULL) THEN
				
					insert into TB_CONFIRM_ELENCO_PRO (ID_TEMPORADA, ID_USUARIO_MANAGER, ID_USUARIO, DT_CONFIRMACAO)
					select pIdTemporada, pIdUsu, TB_GOLEADOR.ID_USUARIO, DATE_ADD(NOW(), INTERVAL 10 SECOND) 
					from TB_GOLEADOR
					where ID_TIME = _idTime
					and ID_USUARIO NOT IN (pIdUsu)
					order by ID_USUARIO;
				
				END IF;
				
				select '0' as COD_VALIDATION, 'Validation done successfully.' as DSC_VALIDATION;
			
			END IF;

		END IF;

	END IF;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddDeclineConfirmacaoTemporadaRenovacao` $$
CREATE PROCEDURE `spAddDeclineConfirmacaoTemporadaRenovacao`(
	pIdTemporada INTEGER,
	pIdUsu INTEGER,
	pIdCampeonato INTEGER
)
begin
	DECLARE _total INTEGER DEFAULT 0;
	
	select count(1) into _total
	from TB_CONFIRMACAO_TEMPORADA
	where ID_TEMPORADA = pIdTemporada
	and ID_USUARIO = pIdUsu
	and ID_CAMPEONATO = pIdCampeonato;
	
	IF _total > 0 THEN
	
		update TB_CONFIRMACAO_TEMPORADA
		set IN_ORDENACAO = 0,
		IN_CONFIRMACAO = 0,
		DS_STATUS = 'AP',
		DT_CONFIRMACAO = NOW()
		where ID_TEMPORADA = pIdTemporada
		and ID_USUARIO = pIdUsu
		and ID_CAMPEONATO = pIdCampeonato;

	ELSE
	
		insert into TB_CONFIRMACAO_TEMPORADA (ID_TEMPORADA, ID_USUARIO, ID_CAMPEONATO, IN_CONSOLE, IN_ORDENACAO, IN_CONFIRMACAO, DS_STATUS, DT_CONFIRMACAO)
		values (pIdTemporada, pIdUsu, pIdCampeonato, 'PS4', 0, 0, 'AP', NOW());
		
	END IF;
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
DROP FUNCTION IF EXISTS `fcGetIdTempPrevious` $$
CREATE FUNCTION `fcGetIdTempPrevious`() RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idTemp INTEGER DEFAULT NULL;
	
	SELECT H.id_temporada into _idTemp FROM TB_TEMPORADA H 
	WHERE H.DT_FIM IS NOT NULL ORDER BY H.id_temporada DESC LIMIT 1;
	
	IF (_idTemp IS NULL) THEN
		SET _idTemp = 0;
	END IF;
	
	RETURN _idTemp;
End$$
DELIMITER ;

