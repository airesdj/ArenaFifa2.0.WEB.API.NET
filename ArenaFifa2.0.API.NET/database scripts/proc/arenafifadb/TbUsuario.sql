USE `arenafifadb`;

ALTER TABLE TB_USUARIO
ADD COLUMN DS_SENHA20 VARCHAR(100) AFTER DS_SENHA, ADD COLUMN DS_SENHA_CONFIRMACAO20 VARCHAR(100) AFTER DS_SENHA_CONFIRMACAO;

UPDATE TB_USUARIO SET DS_SENHA20 = DS_SENHA, DS_SENHA_CONFIRMACAO20 = DS_SENHA_CONFIRMACAO;

DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetPassWDCrypto` $$
CREATE FUNCTION `fcGetPassWDCrypto`(pPassWDBase64 VARCHAR(30)) RETURNS VARCHAR(100)
	DETERMINISTIC
begin

	DECLARE _PassWDCrypto VARCHAR(100) DEFAULT "";
	
	SET _PassWDCrypto = SHA2(pPassWDBase64,256);
	
	RETURN _PassWDCrypto;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetIdUsuarioByTime` $$
CREATE FUNCTION `fcGetIdUsuarioByTime`(pIdCamp INTEGER, pIdTime INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idUsu INTEGER DEFAULT 0;
	
	SELECT UT1.ID_USUARIO into _idUsu
	FROM TB_USUARIO_TIME UT1, TB_CLASSIFICACAO TC1
	WHERE UT1.ID_CAMPEONATO = pIdCamp AND UT1.ID_TIME = pIdTime AND UT1.DT_VIGENCIA_FIM IS NULL
	AND UT1.ID_TIME = TC1.ID_TIME ORDER BY UT1.ID_USUARIO LIMIT 1;
	
	IF (_idUsu IS NULL) THEN
	
		SET _idUsu = 0;
	
	END IF;
	
	RETURN _idUsu;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetIdLastUsuario` $$
CREATE FUNCTION `fcGetIdLastUsuario`() RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idUsu INTEGER DEFAULT 0;
	
	SELECT ID_USUARIO into _idUsu
	FROM TB_USUARIO
	order by ID_USUARIO desc
	limit 1;
	
	IF (_idUsu IS NULL) THEN
	
		SET _idUsu = 0;
	
	END IF;
	
	RETURN _idUsu;
End$$
DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetIdUsuariosVazio` $$
CREATE FUNCTION `fcGetIdUsuariosVazio`() RETURNS VARCHAR(100)
	DETERMINISTIC
begin

	DECLARE _idUsuarios VARCHAR(100) DEFAULT "";
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _finished INTEGER DEFAULT 0;
	
	DECLARE tabela_cursor CURSOR FOR 
	select ID_USUARIO from TB_USUARIO where PSN_ID like '%vazio%' order by ID_USUARIO;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
	
	OPEN tabela_cursor;
	
	get_tabela: LOOP
	
		FETCH tabela_cursor INTO _idUsu;
		
		IF _finished = 1 THEN
			LEAVE get_tabela;
		END IF;

		IF _idUsuarios <> "" THEN
		
			SET _idUsuarios = CONCAT(_idUsuarios, ',');
		
		END IF;
		
		SET _idUsuarios = CONCAT(_idUsuarios, _idUsu);
		
	END LOOP get_tabela;
	
	CLOSE tabela_cursor;
	
	RETURN _idUsuarios;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spDeleteUsuario` $$
CREATE PROCEDURE `spDeleteUsuario`(
	pIdUsuario INTEGER,
	pIdUsuarioOperacao INTEGER,
	pPsnUsuario VARCHAR(30),
	pPsnUsuarioOperacao VARCHAR(30),
	pDsPaginaOperacao VARCHAR(30)
)
begin      
   
   update TB_USUARIO
   set IN_USUARIO_ATIVO = false
   where ID_USUARIO = pIdUsuario;
   
   call `arenafifadb`.`spAddHistAltUsuario`(pIdUsuario, pIdUsuarioOperacao, 'INATIVANDO USUARIO', pPsnUsuario, pPsnUsuarioOperacao, pDsPaginaOperacao);
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateUltimoAcesso` $$
CREATE PROCEDURE `spUpdateUltimoAcesso`(
	pIdUsuario INTEGER
)
begin      

   update TB_USUARIO
   set DT_ULTIMO_ACESSO = now()
   where ID_USUARIO = pIdUsuario;
   
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateMobile` $$
CREATE PROCEDURE `spUpdateMobile`(
	pIdUsuario INTEGER,
	pDDD VARCHAR(2),
	pMobile VARCHAR(15)
)
begin      

   update TB_USUARIO
   set NO_DDD = pDDD, NO_CELULAR = pMobile
   where ID_USUARIO = pIdUsuario;
   
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetLastUsuario` $$
CREATE PROCEDURE `spGetLastUsuario`()
begin      
   select *
   from TB_USUARIO
   order by ID_USUARIO desc
   limit 1;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetUsuarioById` $$
CREATE PROCEDURE `spGetUsuarioById`(pIdUsuario INTEGER)
begin      
   select *, DATE_FORMAT(DT_ULTIMO_ACESSO,'%d/%m/%Y') as DT_ACESSO_FORMATADA, 
   DATE_FORMAT(DT_CADASTRO,'%d/%m/%Y') as DT_CADASTRO_FORMATADA, DATE_FORMAT(DT_ULTIMA_ALTERACAO,'%d/%m/%Y') as DT_ALTERACAO_FORMATADA,
   fcGetCurrentIdTimeH2H(id_usuario) as id_TimeH2H, fcGetCurrentIdTimeFUT(id_usuario) as id_TimeFUT, fcGetCurrentIdTimePRO(id_usuario) as id_TimePRO
   from TB_USUARIO
   where ID_USUARIO = pIdUsuario;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetUsuarioByLogin` $$
CREATE PROCEDURE `spGetUsuarioByLogin`(dsLogin VARCHAR(30))
begin      
   select *, DATE_FORMAT(DT_ULTIMO_ACESSO,'%d/%m/%Y') as DATA_FORMADA, 
   fcGetCurrentIdTimeH2H(id_usuario) as id_TimeH2H, fcGetCurrentIdTimeFUT(id_usuario) as id_TimeFUT, fcGetCurrentIdTimePRO(id_usuario) as id_TimePRO
   from TB_USUARIO
   where PSN_ID = dsLogin
   and IN_USUARIO_ATIVO = true;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spValidatePasswdOfUsuario` $$
CREATE PROCEDURE `spValidatePasswdOfUsuario`(pIdUsuario INTEGER, pPassWDBase64 VARCHAR(30))
begin
	DECLARE _passWord20 VARCHAR(100) DEFAULT NULL;

	select DS_SENHA20 into _passWord20
	from TB_USUARIO
	where ID_USUARIO = pIdUsuario;

	IF (_passWord20 IS NOT NULL) THEN
	
		IF _passWord20 = fcGetPassWDCrypto(pPassWDBase64) THEN
		
			call `arenafifadb`.`spUpdateUltimoAcesso`(pIdUsuario);
		
			select '0' as COD_VALIDATION, 'Validation done successfully.' as DSC_VALIDATION;
		
		ELSE
		
			select '1' as COD_VALIDATION, 'Incorrect validation.' as DSC_VALIDATION;

		END IF;

	ELSE
	
		select '2' as COD_VALIDATION, 'New Password 2.0 is null.' as DSC_VALIDATION;
	
	END IF;
	
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spValidatePasswdModeradorOfUsuario` $$
CREATE PROCEDURE `spValidatePasswdModeradorOfUsuario`(pIdUsuario INTEGER, pPassWDBase64 VARCHAR(30))
begin
	DECLARE _passWord VARCHAR(100) DEFAULT NULL;

	select DS_SENHA_CONFIRMACAO20 into _passWord
	from TB_USUARIO
	where ID_USUARIO = pIdUsuario;

	IF _passWord = fcGetPassWDCrypto(pPassWDBase64) THEN

		select '0' as cod_validation, 'Validation done successfully.' as dsc_validation;
	
	ELSE
	
		select '1' as cod_validation, 'Incorrect validation.' as dsc_validation;

	END IF;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllUsuariosNoFilterCRUD` $$
CREATE PROCEDURE `spGetAllUsuariosNoFilterCRUD`()
begin      
   select *, DATE_FORMAT(DT_ULTIMO_ACESSO,'%d/%m/%Y') as DATA_FORMADA
   from TB_USUARIO
   order by ID_USUARIO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllUsuariosWithFilterCRUD` $$
CREATE PROCEDURE `spGetAllUsuariosWithFilterCRUD`(pFilter VARCHAR(20))
begin      
   select *, DATE_FORMAT(DT_ULTIMO_ACESSO,'%d/%m/%Y') as DATA_FORMADA
   from TB_USUARIO
   where (NM_USUARIO like CONCAT('%',pFilter,'%') or PSN_ID like CONCAT('%',pFilter,'%'))
   order by ID_USUARIO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spValidateRegistrationOfUsuarioNewUsuario` $$
CREATE PROCEDURE `spValidateRegistrationOfUsuarioNewUsuario`(pdsPsn VARCHAR(50), pNmUsuario VARCHAR(50), pDsEmail VARCHAR(100))
begin
	DECLARE _dsPsn VARCHAR(50) DEFAULT NULL;
	DECLARE _NmUsuario VARCHAR(50) DEFAULT NULL;
	DECLARE _dsDsEmail VARCHAR(50) DEFAULT NULL;
	DECLARE _Total INTEGER DEFAULT NULL;
	
	select count(1) into _Total
	from TB_USUARIO
	where PSN_ID = pdsPsn;

	IF _Total = 0 THEN
	
		SET _Total = NULL;

		select count(1) into _Total
		from TB_USUARIO
		where NM_USUARIO = pNmUsuario;

		IF _Total = 0 THEN
		
			SET _Total = NULL;

			select count(1) into _Total
			from TB_USUARIO
			where DS_EMAIL = pDsEmail;
			
			IF _Total = 0 THEN

				select '0' as cod_validation, 'validation successfully.' as dsc_validation;
				
			ELSE
			
				select '3' as cod_validation, 'Incorrect validation - E-mail.' as dsc_validation;

			END IF;

		ELSE
		
			select '2' as cod_validation, 'Incorrect validation - Nome.' as dsc_validation;

		END IF;
	
	ELSE
	
		select '1' as cod_validation, 'Incorrect validation - Psn.' as dsc_validation;

	END IF;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spValidateRegistrationOfUsuarioOldUsuario` $$
CREATE PROCEDURE `spValidateRegistrationOfUsuarioOldUsuario`(pIdUsuario INTEGER, pdsPsn VARCHAR(50), pNmUsuario VARCHAR(50), pDsEmail VARCHAR(100))
begin
	DECLARE _dsPsn VARCHAR(50) DEFAULT NULL;
	DECLARE _NmUsuario VARCHAR(50) DEFAULT NULL;
	DECLARE _dsDsEmail VARCHAR(50) DEFAULT NULL;
	DECLARE _Total INTEGER DEFAULT NULL;
	
	select count(1) into _Total
	from TB_USUARIO
	where PSN_ID = pdsPsn
	and ID_USUARIO <> pIdUsuario;

	IF _Total = 0 THEN
	
		SET _Total = NULL;

		select count(1) into _Total
		from TB_USUARIO
		where NM_USUARIO = pNmUsuario
		and ID_USUARIO <> pIdUsuario;

		IF _Total = 0 THEN
		
			SET _Total = NULL;

			select count(1) into _Total
			from TB_USUARIO
			where DS_EMAIL = pDsEmail
			and ID_USUARIO <> pIdUsuario;
			
			IF _Total = 0 THEN

				select '0' as cod_validation, 'validation successfully.' as dsc_validation;
				
			ELSE
			
				select '3' as cod_validation, 'Incorrect validation - E-mail.' as dsc_validation;

			END IF;

		ELSE
		
			select '2' as cod_validation, 'Incorrect validation - Nome.' as dsc_validation;

		END IF;
	
	ELSE
	
		select '1' as cod_validation, 'Incorrect validation - Psn.' as dsc_validation;

	END IF;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddUsuario` $$
CREATE PROCEDURE `spAddUsuario`(
	pNmUsuario VARCHAR(50),
	pDsSenhaBase64 VARCHAR(100),
	pDsEmail VARCHAR(80),
	pPsnId VARCHAR(80),
	pInAtivo TINYINT,
	pDsFicouSabendo VARCHAR(80),
	pDsQual VARCHAR(80),
	pNmTime VARCHAR(80),
	pDtNasc DATE,
	pDsEstado VARCHAR(80),
	pInReceberAlerta INTEGER,
	pInReceberSit INTEGER,
	pInDesejaPartic INTEGER,
	pInModerador TINYINT,
	pDsPsnCadastro VARCHAR(80),
	pIdUsuarioOperacao INTEGER,
	pPsnUsuarioOperacao VARCHAR(30),
	pDsPaginaOperacao VARCHAR(30)
)
begin
	DECLARE _idUsuario INTEGER DEFAULT NULL;
	insert into TB_USUARIO (NM_USUARIO, DS_EMAIL, PSN_ID, IN_USUARIO_ATIVO, DS_COMO_FICOU_SABENDO, DS_QUAL, NM_TIME, DT_NASCIMENTO, DS_ESTADO, IN_RECEBER_EMAIL_ALERTA, 
	                        IN_RECEBER_EMAIL_SITUACAO_CAMPEONATO, IN_DESEJA_PARTICIPAR, IN_USUARIO_MODERADOR, DT_CADASTRO, DT_ULTIMA_ALTERACAO, DS_LOGIN_ALTERACAO, DS_SENHA20)
	values (pNmUsuario, pDsEmail, pPsnId, pInAtivo, pDsFicouSabendo, pDsQual, pNmTime, pDtNasc, pDsEstado, pInReceberAlerta, pInReceberSit, 
	        pInDesejaPartic, pInModerador, now(), now(), pDsPsnCadastro, fcGetPassWDCrypto(pDsSenhaBase64));
	
	select ID_USUARIO into _idUsuario 
	from TB_USUARIO
	order by ID_USUARIO desc
	limit 1;
	
	IF pPsnUsuarioOperacao = "NULL" THEN
	
		SET pIdUsuarioOperacao = _idUsuario;
		SET pPsnUsuarioOperacao = pPsnId;
	
	END IF;
	
    call `arenafifadb`.`spAddHistAltUsuario`(_idUsuario, pIdUsuarioOperacao, 'INCLUINDO USUARIO', pPsnId, pPsnUsuarioOperacao, pDsPaginaOperacao);
	select _idUsuario as 'ID_USUARIO';
END$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdadeUsuario` $$
CREATE PROCEDURE `spUpdadeUsuario`(
	pIdUsuario INTEGER,
	pNmUsuario VARCHAR(50),
	pDsEmail VARCHAR(80),
	pPsnId VARCHAR(80),
	pInAtivo TINYINT,
	pDsFicouSabendo VARCHAR(80),
	pDsQual VARCHAR(80),
	pNmTime VARCHAR(80),
	pDtNasc DATE,
	pDsEstado VARCHAR(80),
	pInReceberAlerta INTEGER,
	pInReceberSit INTEGER,
	pInDesejaPartic INTEGER,
	pInModerador TINYINT,
	pDsPsnCadastro VARCHAR(80),
	pIdUsuarioOperacao INTEGER,
	pPsnUsuarioOperacao VARCHAR(30),
	pDsPaginaOperacao VARCHAR(30)
)
begin
	update TB_USUARIO
	set NM_USUARIO = pNmUsuario,
	    DS_EMAIL = pDsEmail,
		PSN_ID = pPsnId,
		IN_USUARIO_ATIVO = pInAtivo,
		DS_COMO_FICOU_SABENDO = pDsFicouSabendo,
		DS_QUAL = pDsQual,
		NM_TIME = pNmTime,
		DT_NASCIMENTO = pDtNasc,
		DS_ESTADO = pDsEstado,
		IN_RECEBER_EMAIL_ALERTA = pInReceberAlerta,
		IN_RECEBER_EMAIL_SITUACAO_CAMPEONATO = pInReceberSit,
		IN_DESEJA_PARTICIPAR = pInDesejaPartic,
		IN_USUARIO_MODERADOR = pInModerador,
		DT_ULTIMA_ALTERACAO = now(),
		DS_LOGIN_ALTERACAO = pDsPsnCadastro
	where ID_USUARIO = pIdUsuario;
	
   call `arenafifadb`.`spAddHistAltUsuario`(pIdUsuario, pIdUsuarioOperacao, 'ALTERANDO DDS/ATIVANDO USUARIO', pPsnId, pPsnUsuarioOperacao, pDsPaginaOperacao);
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdadePassWDUsuario` $$
CREATE PROCEDURE `spUpdadePassWDUsuario`(
	pIdUsuario INTEGER,
	pPassWDBase64 VARCHAR(100)
)
begin
	update TB_USUARIO
	set DS_SENHA20 = fcGetPassWDCrypto(pPassWDBase64)
	where ID_USUARIO = pIdUsuario
	and IN_USUARIO_ATIVO = true;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetCurrentIdTime` $$
CREATE FUNCTION `fcGetCurrentIdTime`(pIdUsu INTEGER, pIdCamp INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _idTime INTEGER DEFAULT NULL;
	
	select ID_TIME into _idTime
	from TB_USUARIO_TIME
	where ID_CAMPEONATO = pIdCamp
	and ID_USUARIO = pIdUsu
	and DT_VIGENCIA_FIM is null
	limit 1;
	
	RETURN _idTime;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetCurrentPsnIDByTime` $$
CREATE FUNCTION `fcGetCurrentPsnIDByTime`(pIdTemp INTEGER, pIdTime INTEGER) RETURNS VARCHAR(30)
	DETERMINISTIC
begin

	DECLARE _psnID VARCHAR(30) DEFAULT NULL;
	
	select U.PSN_ID into _psnID
	from TB_USUARIO_TIME T, TB_USUARIO U
	where T.ID_TIME = pIdTime
	and T.ID_USUARIO = U.ID_USUARIO
	and T.DT_VIGENCIA_FIM is null
	limit 1;
	
	RETURN _psnID;
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
DROP PROCEDURE IF EXISTS `spGetTitlesWonForUser` $$
CREATE PROCEDURE `spGetTitlesWonForUser`(idUsu INTEGER)
begin      
	DECLARE _TotalH2H INTEGER DEFAULT 0;
	DECLARE _TotalFUT INTEGER DEFAULT 0;
	DECLARE _TotalViceH2H INTEGER DEFAULT 0;
	DECLARE _TotalViceFUT INTEGER DEFAULT 0;
	
	select count(1) into _TotalH2H
	from TB_HISTORICO_CONQUISTA
	where ID_USUARIO_CAMPEAO = idUsu;
	
	select count(1) into _TotalFUT
	from TB_HISTORICO_CONQUISTA_FUT
	where ID_USUARIO_CAMPEAO = idUsu;
	
	select count(1) into _TotalViceH2H
	from TB_HISTORICO_CONQUISTA
	where ID_USUARIO_VICECAMPEAO = idUsu;
	
	select count(1) into _TotalViceFUT
	from TB_HISTORICO_CONQUISTA_FUT
	where ID_USUARIO_VICECAMPEAO = idUsu;
	
	select (_TotalH2H+_TotalFUT) as total_TitlesWon, (_TotalViceH2H+_TotalViceFUT) as total_Vices;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetListRankingSupporters` $$
CREATE PROCEDURE `spGetListRankingSupporters`()
begin
	SELECT X.* FROM 
	(SELECT NM_TIME, COUNT(1) as Total FROM TB_USUARIO WHERE IN_USUARIO_ATIVO = True  AND ID_USUARIO > 1 GROUP BY NM_TIME) as X 
	ORDER BY X.Total desc;

End$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetDetailsRankingSupporters` $$
CREATE PROCEDURE `spGetDetailsRankingSupporters`()
begin
	DECLARE _DataUpdate VARCHAR(15) DEFAULT "";
	DECLARE _TotalUser INTEGER DEFAULT 0;

	SELECT DATE_FORMAT(DT_CADASTRO,'%d/%m/%Y') into _DataUpdate FROM TB_USUARIO WHERE ID_USUARIO = fcGetIdLastUsuario();
	SELECT count(1) into _TotalUser FROM TB_USUARIO WHERE IN_USUARIO_ATIVO = True AND ID_USUARIO > 1;
	
	SELECT _DataUpdate as DT_CADASTRO_FORMATADA, _TotalUser as TOTAL_USUARIO;
End$$
DELIMITER ;
