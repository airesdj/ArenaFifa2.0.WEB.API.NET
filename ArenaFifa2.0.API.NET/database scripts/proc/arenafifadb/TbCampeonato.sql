USE `arenafifadb`;

ALTER TABLE TB_CAMPEONATO MODIFY DT_INICIO DATE;
ALTER TABLE TB_CAMPEONATO MODIFY DT_SORTEIO DATE;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcValidCampeonatoIsOnlyPlayoff` $$
CREATE FUNCTION `fcValidCampeonatoIsOnlyPlayoff`(pIdCamp INTEGER) RETURNS TINYINT
	DETERMINISTIC
begin

	DECLARE _exist TINYINT DEFAULT NULL;
	
	SELECT count(1) into _exist
	FROM TB_CAMPEONATO
	WHERE ID_CAMPEONATO = pIdCamp
	AND IN_CAMPEONATO_GRUPO = False AND IN_CAMPEONATO_TURNO_UNICO = False AND IN_CAMPEONATO_TURNO_RETURNO = False
	AND IN_SISTEMA_MATA = True;


	If _exist IS NULL THEN
		SET _exist = 0;
	END IF;
	
	RETURN _exist;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetTypeModelOfCampeonato` $$
CREATE FUNCTION `fcGetTypeModelOfCampeonato`(idTipo VARCHAR(4)) RETURNS VARCHAR(3)
	DETERMINISTIC
begin

	DECLARE _typeModel VARCHAR(3) DEFAULT NULL;
	
	If INSTR (idTipo, 'FUT') > 0 THEN
		SET _typeModel = "FUT";
	ELSEIF INSTR (idTipo, 'PRO') > 0 THEN
		SET _typeModel = "PRO";
	ELSE
		SET _typeModel = "H2H";
	END IF;
	
	RETURN _typeModel;
End$$
DELIMITER ;



DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetIdCurrentCampeonatoByTipo` $$
CREATE FUNCTION `fcGetIdCurrentCampeonatoByTipo`(pTipo VARCHAR(10)) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idCamp INTEGER DEFAULT NULL;
	
	SELECT id_campeonato into _idCamp FROM TB_CAMPEONATO
	WHERE ID_TEMPORADA = fcGetIdTempCurrent() AND SG_TIPO_CAMPEONATO = pTipo LIMIT 1;
	
	IF (_idCamp IS NULL) THEN
		SET _idCamp = 0;
	END IF;
	
	RETURN _idCamp;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetCampeonato` $$
CREATE PROCEDURE `spGetCampeonato`(pId INTEGER)
begin      
   select C.*, (C.DT_INICIO - CURDATE()) as DT_CAMPEONATO_INICIADO, T.NM_Temporada, fcGetTypeModelOfCampeonato(C.SG_TIPO_CAMPEONATO) as TIPO_CAMPEONATO from TB_CAMPEONATO C, TB_TEMPORADA T 
   where C.ID_Temporada = T.ID_Temporada
   and ID_CAMPEONATO = pId;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllCampeonatosActiveOfTemporada` $$
CREATE PROCEDURE `spGetAllCampeonatosActiveOfTemporada`(pIdTemporada INTEGER)
begin      
	IF pIdTemporada = 0 THEN
		SET pIdTemporada = fcGetIdTempCurrent();
	END IF;
  
   select C.*, T.NM_Temporada from TB_CAMPEONATO C, TB_TEMPORADA T 
   where C.ID_TEMPORADA = pIdTemporada
   and C.IN_CAMPEONATO_ATIVO = true
   and C.ID_Temporada = T.ID_Temporada
   order by C.NM_CAMPEONATO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllCampeonatosOfTemporada` $$
CREATE PROCEDURE `spGetAllCampeonatosOfTemporada`(pIdTemporada INTEGER)
begin
	IF pIdTemporada = 0 THEN
		SET pIdTemporada = fcGetIdTempCurrent();
	END IF;
  
   select * from TB_CAMPEONATO where ID_TEMPORADA = pIdTemporada order by ID_CAMPEONATO;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllCampeonatosNoFilterCRUD` $$
CREATE PROCEDURE `spGetAllCampeonatosNoFilterCRUD`()
begin      
   select C.*, T.NM_Temporada, DATE_FORMAT(C.DT_INICIO,'%d/%m/%Y') as DT_INICIO_FORMATADA, DATE_FORMAT(C.DT_SORTEIO,'%d/%m/%Y') as DT_SORTEIO_FORMATADA, U1.PSN_ID as PSN1,
   (select U2.PSN_ID from TB_USUARIO U2 where U2.ID_USUARIO = C.ID_USUARIO_2oMODERADOR) as PSN2
   from TB_CAMPEONATO C, TB_TEMPORADA T, TB_USUARIO U1
   where C.ID_Temporada = T.ID_Temporada
   and  C.ID_USUARIO_MODERADOR = U1.ID_USUARIO
   order by C.ID_TEMPORADA DESC, C.IN_CAMPEONATO_ATIVO, C.ID_CAMPEONATO;      
End$$
DELIMITER ;





DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddCampeonato` $$
CREATE PROCEDURE `spAddCampeonato`(    
    pIdTemp INTEGER,     
    pNmCamp VARCHAR(50),    
    pQtTimes INTEGER,    
    pDtInicio DATETIME,    
    pDtSorteio DATETIME,    
    pAtivo TINYINT,    
    pPorGrupo TINYINT,    
    pTurnoUnico TINYINT,    
    pTurnoReturno TINYINT,    
    pQtGrupos INTEGER,    
    pMataMata TINYINT,    
    pIdaVolta TINYINT,    
    pQtTimesClassif INTEGER,    
    pQtTimesRebaix INTEGER,    
    pIdUsuModera INTEGER,    
    pQtDiasFaseClassif INTEGER,    
    pQtDiasFaseMataMata INTEGER,    
    pSgTipoCamp VARCHAR(4),    
    pQtDiasProxClassif INTEGER,    
    pIdConsole VARCHAR(3),    
    pIdUsuario2Modera INTEGER,    
    pMataMataDone VARCHAR(100),    
    pQtTimesAcesso INTEGER,    
    pJogo3Lugar TINYINT,    
    PIdCampDestino INTEGER,    
    pIdCampOrigem INTEGER,    
    pPosOrigem INTEGER,    
    pDoubleRound TINYINT,    
	pPsnUsuOperacao VARCHAR(30),
	pIdUsuarioOperacao INTEGER,
	pDsPaginaOperacao VARCHAR(30)
)
Begin
	DECLARE _idCamp INTEGER DEFAULT NULL;
	insert into `TB_CAMPEONATO` (`ID_TEMPORADA`, `NM_CAMPEONATO`, `QT_TIMES`, `DT_INICIO`, `DT_SORTEIO`, `IN_CAMPEONATO_ATIVO`, `IN_CAMPEONATO_GRUPO`, `IN_CAMPEONATO_TURNO_UNICO`, 
	                             `IN_CAMPEONATO_TURNO_RETURNO`, `QT_GRUPOS`, `IN_SISTEMA_MATA`, `IN_SISTEMA_IDA_VOLTA`, `QT_TIMES_CLASSIFICADOS`, `QT_TIMES_REBAIXADOS`, 
								 `DS_LOGO_PEQ`, `DS_LOGO_MED`, `ID_USUARIO_MODERADOR`, `DS_FRIENDS_LEAGUE`, `QT_DIAS_PARTIDA_CLASSIFICACAO`, `QT_DIAS_PARTIDA_FASE_MATAxMATA`, 
								 `SG_TIPO_CAMPEONATO`, `QT_TIMES_PROX_CLASSIF`, `IN_Console`, `ID_USUARIO_2oMODERADOR`, `ID_USUARIO_1oAUXILIAR`, `ID_USUARIO_2oAUXILIAR`, 
								 `ID_USUARIO_3oAUXILIAR`, `DT_ULTIMA_ALTERACAO`, `DS_LOGIN_ALTERACAO`, `DS_FASE_MATAxMATA_MONTADA`, `QT_TIMES_ACESSO`, `IN_DISPUTA_3o_4o_Lugar`, 
								 `ID_CAMPEONATO_DESTINO`, `ID_CAMPEONATO_ORIGEM`, `IN_POSICAO_ORIGEM`, `IN_DOUBLE_ROUND`) 
	values (pIdTemp, pNmCamp, pQtTimes, pDtInicio, pDtSorteio, pAtivo, pPorGrupo, pTurnoUnico, pTurnoReturno, pQtGrupos, pMataMata, pIdaVolta, pQtTimesClassif, pQtTimesRebaix, 
	        NULL, NULL, pIdUsuModera, NULL, pQtDiasFaseClassif, pQtDiasFaseMataMata, pSgTipoCamp, pQtDiasProxClassif, pIdConsole, pIdUsuario2Modera, NULL, NULL, NULL, NULL, NULL, 
			pMataMataDone, pQtTimesAcesso, pJogo3Lugar, PIdCampDestino, pIdCampOrigem, pPosOrigem, pDoubleRound);

	select ID_CAMPEONATO into _idCamp 
	from TB_CAMPEONATO
	order by ID_CAMPEONATO desc
	limit 1;

    call `arenafifadb`.`spAddHistAltCampeonato`(_idCamp, pIdUsuarioOperacao, 'ALTERANDO DADOS CAMPEONATO', pPsnUsuOperacao, pNmCamp, pDsPaginaOperacao);
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateCampeonato` $$
CREATE PROCEDURE `spUpdateCampeonato`(    
    pId INTEGER,     
    pNmCamp VARCHAR(50),    
    pQtTimes INTEGER,    
    pDtInicio DATETIME,    
    pDtSorteio DATETIME,    
    pAtivo TINYINT,    
    pPorGrupo TINYINT,    
    pTurnoUnico TINYINT,    
    pTurnoReturno TINYINT,    
    pQtGrupos INTEGER,    
    pMataMata TINYINT,    
    pIdaVolta TINYINT,    
    pQtTimesClassif INTEGER,    
    pQtTimesRebaix INTEGER,    
    pIdUsuModera INTEGER,    
    pQtDiasFaseClassif INTEGER,    
    pQtDiasFaseMataMata INTEGER,    
    pSgTipoCamp VARCHAR(4),    
    pQtDiasProxClassif INTEGER,    
    pIdConsole VARCHAR(3),    
    pIdUsuario2Modera INTEGER,    
    pMataMataDone VARCHAR(100),    
    pQtTimesAcesso INTEGER,    
    pJogo3Lugar TINYINT,    
    PIdCampDestino INTEGER,    
    pIdCampOrigem INTEGER,    
    pPosOrigem INTEGER,    
    pDoubleRound TINYINT, 
	pPsnUsuOperacao VARCHAR(30),
	pIdUsuarioOperacao INTEGER,
	pDsPaginaOperacao VARCHAR(30)
)
Begin

	update `TB_CAMPEONATO`
	set NM_CAMPEONATO = pNmCamp,
	    QT_TIMES = pQtTimes,
		DT_INICIO = pDtInicio,
		DT_SORTEIO = pDtSorteio,
		IN_CAMPEONATO_ATIVO = pAtivo,
		IN_CAMPEONATO_GRUPO = pPorGrupo,
		IN_CAMPEONATO_TURNO_UNICO = pTurnoUnico,
		IN_CAMPEONATO_TURNO_RETURNO = pTurnoReturno,
		QT_GRUPOS = pQtGrupos,
		IN_SISTEMA_MATA = pMataMata,
		IN_SISTEMA_IDA_VOLTA = pIdaVolta,
		QT_TIMES_CLASSIFICADOS = pQtTimesClassif,
		QT_TIMES_REBAIXADOS = pQtTimesRebaix,
		ID_USUARIO_MODERADOR = pIdUsuModera,
		QT_DIAS_PARTIDA_CLASSIFICACAO = pQtDiasFaseClassif,
		QT_DIAS_PARTIDA_FASE_MATAxMATA = pQtDiasFaseMataMata,
		SG_TIPO_CAMPEONATO = pSgTipoCamp,
		QT_TIMES_PROX_CLASSIF = pQtDiasProxClassif,
		IN_Console = pIdConsole,
		ID_USUARIO_2oMODERADOR = pIdUsuario2Modera,
		DS_FASE_MATAxMATA_MONTADA = pMataMataDone,
		QT_TIMES_ACESSO = pQtTimesAcesso,
		IN_DISPUTA_3o_4o_Lugar = pJogo3Lugar,
		ID_CAMPEONATO_DESTINO = PIdCampDestino,
		ID_CAMPEONATO_ORIGEM = pIdCampOrigem,
		IN_POSICAO_ORIGEM = pPosOrigem,
		IN_DOUBLE_ROUND = pDoubleRound
	where ID_CAMPEONATO = pId;
	
   call `arenafifadb`.`spAddHistAltCampeonato`(pId, pIdUsuarioOperacao, 'ALTERANDO DADOS CAMPEONATO', pPsnUsuOperacao, pNmCamp, pDsPaginaOperacao);
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateCampeonatoCRUD` $$
CREATE PROCEDURE `spUpdateCampeonatoCRUD`(    
    pId INTEGER,     
    pNmCamp VARCHAR(50),    
    pQtTimes INTEGER,    
    pDtInicio DATETIME,    
    pDtSorteio DATETIME,    
    pAtivo TINYINT,    
    pPorGrupo TINYINT,    
    pTurnoUnico TINYINT,    
    pTurnoReturno TINYINT,    
    pQtGrupos INTEGER,    
    pMataMata TINYINT,    
    pIdaVolta TINYINT,    
    pQtTimesClassif INTEGER,    
    pQtTimesRebaix INTEGER,    
    pIdUsuModera INTEGER,    
    pIdUsuModera2 INTEGER,    
    pQtDiasFaseClassif INTEGER,    
    pQtDiasFaseMataMata INTEGER,    
    pSgTipoCamp VARCHAR(4),    
    pQtTimesProxClassif INTEGER,    
    pIdConsole VARCHAR(3),    
	pPsnUsuOperacao VARCHAR(30),
	pIdUsuarioOperacao INTEGER,
	pDsPaginaOperacao VARCHAR(30)
)
Begin

	update `TB_CAMPEONATO`
	set NM_CAMPEONATO = pNmCamp,
		QT_TIMES = pQtTimes,
		DT_INICIO = pDtInicio,
		DT_SORTEIO = pDtSorteio,
		IN_CAMPEONATO_ATIVO = pAtivo,
		IN_CAMPEONATO_GRUPO = pPorGrupo,
		IN_CAMPEONATO_TURNO_UNICO = pTurnoUnico,
		IN_CAMPEONATO_TURNO_RETURNO = pTurnoReturno,
		QT_GRUPOS = pQtGrupos,
		IN_SISTEMA_MATA = pMataMata,
		IN_SISTEMA_IDA_VOLTA = pIdaVolta,
		QT_TIMES_CLASSIFICADOS = pQtTimesClassif,
		QT_TIMES_REBAIXADOS = pQtTimesRebaix,
		ID_USUARIO_MODERADOR = pIdUsuModera,
		ID_USUARIO_2oMODERADOR = pIdUsuModera2,
		QT_DIAS_PARTIDA_CLASSIFICACAO = pQtDiasFaseClassif,
		QT_DIAS_PARTIDA_FASE_MATAxMATA = pQtDiasFaseMataMata,
		SG_TIPO_CAMPEONATO = pSgTipoCamp,
		QT_TIMES_PROX_CLASSIF = pQtTimesProxClassif,
		IN_Console = pIdConsole
	where ID_CAMPEONATO = pId;

   call `arenafifadb`.`spAddHistAltCampeonato`(pId, pIdUsuarioOperacao, 'ALTERANDO DADOS CAMPEONATO', pPsnUsuOperacao, pNmCamp, pDsPaginaOperacao);
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteCampeonato` $$
CREATE PROCEDURE `spDeleteCampeonato`(    
    pId INTEGER,     
	pPsnUsuOperacao VARCHAR(30),
	pIdUsuarioOperacao INTEGER,
	pDsPaginaOperacao VARCHAR(30)
)
Begin
	DECLARE _nmCamp VARCHAR(50) DEFAULT NULL;

	select NM_CAMPEONATO into _nmCamp 
	from TB_CAMPEONATO
	where ID_CAMPEONATO = pId;

 	delete from TB_CAMPEONATO where ID_CAMPEONATO = pId;

    call `arenafifadb`.`spAddHistAltCampeonato`(pId, pIdUsuarioOperacao, 'EXCLUINDO CAMPEONATO', pPsnUsuOperacao, _nmCamp, pDsPaginaOperacao);
End$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetCampeonatosDetails` $$
CREATE PROCEDURE `spGetCampeonatosDetails`(pIdCamp INTEGER)
begin      
   select C.*, T.NM_Temporada, U.NM_Usuario, U.PSN_ID, U2.NM_Usuario as NM_Usuario2, U2.PSN_ID as PSN_ID2, TI.DS_TIPO_CAMPEONATO,
   (select count(1) from TB_TABELA_JOGO where ID_CAMPEONATO = pIdCamp) as inInicioCampeonato,
   (select ID_Fase from TB_FASE_CAMPEONATO where ID_CAMPEONATO = pIdCamp order by ID_FASE limit 1) as idPrimFaseCampeonato, fcGetTypeModelOfCampeonato(C.SG_TIPO_CAMPEONATO) as TIPO_CAMPEONATO,
   fcGetCurrentStageRoundByCampeonato(pIdCamp) as ID_FASE_NUMERO_RODADA
   from TB_CAMPEONATO C, TB_TEMPORADA T, TB_USUARIO U, TB_USUARIO U2, TB_TIPO_CAMPEONATO TI
   where C.ID_CAMPEONATO = pIdCamp
   and C.ID_TEMPORADA = T.ID_TEMPORADA
   and C.ID_USUARIO_MODERADOR = U.ID_Usuario
   and C.ID_USUARIO_2oMODERADOR = U2.ID_Usuario
   and C.SG_TIPO_CAMPEONATO = TI.SG_TIPO_CAMPEONATO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteAllFaseOfCampeonato` $$
CREATE PROCEDURE `spDeleteAllFaseOfCampeonato`(pIdCamp INTEGER)
Begin
    delete from `TB_FASE_CAMPEONATO` 
	where ID_CAMPEONATO = pIdCamp;
End$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddLoadFaseOfCampeonatoById` $$
CREATE PROCEDURE `spAddLoadFaseOfCampeonatoById`(    
    pIdCamp INTEGER,     
    pIdsFase VARCHAR(250)
)
Begin
	DECLARE _next VARCHAR(250) DEFAULT NULL;
	DECLARE _nextlen INTEGER DEFAULT NULL;
	DECLARE _order INTEGER DEFAULT 0;
	DECLARE _idFase VARCHAR(5) DEFAULT NULL;
	DECLARE strDelimiter CHAR(1) DEFAULT ',';
	
	call `arenafifadb`.`spDeleteAllFaseOfCampeonato`(pIdCamp);
	
	iterator:
	LOOP
		IF LENGTH(TRIM(pIdsFase)) = 0 OR pIdsFase IS NULL THEN
			LEAVE iterator;
		END IF;
		
		SET _next = SUBSTRING_INDEX(pIdsFase,strDelimiter,1);
		
		SET _nextlen = LENGTH(_next);
		
		SET _idFase = TRIM(_next);
		
		insert into `TB_FASE_CAMPEONATO` (`ID_CAMPEONATO`, `ID_FASE`, `IN_ORDENACAO`) 
		values (pIdCamp, CAST(_idFase AS SIGNED), _order);
		
		SET pIdsFase = INSERT(pIdsFase,1,_nextlen + 1,'');
		SET _order = _order + 1;
	END LOOP;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllTipoCampeonato` $$
CREATE PROCEDURE `spGetAllTipoCampeonato`()
begin      
   select *
   from TB_TIPO_CAMPEONATO
   order by DS_TIPO_CAMPEONATO;      
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetTipoCampeonato` $$
CREATE PROCEDURE `spGetTipoCampeonato`(idTipo VARCHAR(4))
begin      
   select *
   from TB_TIPO_CAMPEONATO
   where SG_TIPO_CAMPEONATO = idTipo;
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllCampeonatosScoring` $$
CREATE PROCEDURE `spGetAllCampeonatosScoring`()
begin

   SELECT * FROM TB_PONTUACAO_CAMPEONATO WHERE SG_TIPO_CAMPEONATO IN ('CPDM', 'CPGL', 'DIV1', 'DIV2', 'CPSA', 'DIV3', 'CPRO');
    
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetAllSiglaByMode` $$
CREATE FUNCTION `fcGetAllSiglaByMode`( pMode VARCHAR(3)) RETURNS VARCHAR(80)
	DETERMINISTIC
begin

	DECLARE _sgCamp VARCHAR(80) DEFAULT NULL;
	
	IF pMode = "H2H" THEN
	
		SET _sgCamp = "DIV1, DIV2, DIV3, DIV4, CPDM, CPGL, CPSA, ERCP, MDCL";

	ELSEIF pMode = "FUT" THEN
	
		SET _sgCamp = "FUT1, FUT2, CFUT";
	
	ELSEIF pMode = "PRO" THEN
	
		SET _sgCamp = "PRO1, PRO2, CPRO";
	
	END IF;
	
	RETURN _sgCamp;
End$$
DELIMITER ;


