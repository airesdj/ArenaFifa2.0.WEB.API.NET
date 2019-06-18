USE `arena_spooler`;

ALTER TABLE TB_SPOOLER_PROCESSOS_EMAIL MODIFY dt_criacao_processo DATE;
ALTER TABLE TB_SPOOLER_PROCESSOS_EMAIL MODIFY dt_ultima_execucao DATE;
ALTER TABLE TB_SPOOLER_PROCESSOS_EMAIL MODIFY dt_fim_processo DATE;
ALTER TABLE TB_PROCESSOS_EMAIL_DETALHE MODIFY dt_execucao_processo DATE;
ALTER TABLE TB_PROCESSOS_ADMINISTRATIVOS MODIFY dt_ultima_execucao DATE;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcGetLastProcessID` $$
CREATE FUNCTION `fcGetLastProcessID`() RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _id INTEGER DEFAULT NULL;
	
	SELECT id_processo into _id
	FROM TB_SPOOLER_PROCESSOS_EMAIL
	ORDER BY id_processo desc
	LIMIT 1;

	If _id IS NULL THEN
		SET _id = 0;
	END IF;
	
	RETURN _id;
End$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `fcValidateExistProcessUser` $$
CREATE FUNCTION `fcValidateExistProcessUser`(pIdProcess INTEGER, pIdUsu INTEGER) RETURNS INTEGER
	DETERMINISTIC
begin

	DECLARE _exist INTEGER DEFAULT NULL;
	
	SELECT count(1) into _exist
	FROM TB_PROCESSOS_EMAIL_DETALHE
	WHERE id_processo = pIdProcess and id_usuario = pIdUsu;

	RETURN _exist;
End$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllSpoolerInProgress` $$
CREATE PROCEDURE `spGetAllSpoolerInProgress`()
begin
	
	SELECT *, DATE_FORMAT(dt_ultima_execucao,'%d/%m') as dt_ultima_execucao_formatada, '' as ds_horario_execucao, '' as ds_periodicidade FROM TB_SPOOLER_PROCESSOS_EMAIL
	WHERE dt_fim_processo is null and dt_ultima_execucao is not null and qtd_emails_enviados > 0 ORDER BY dt_criacao_processo, hr_criacao_processo, id_processo;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllSpoolerWaitingProcess` $$
CREATE PROCEDURE `spGetAllSpoolerWaitingProcess`()
begin
	
	SELECT *, DATE_FORMAT(dt_ultima_execucao,'%d/%m') as dt_ultima_execucao_formatada, '' as ds_horario_execucao, '' as ds_periodicidade FROM TB_SPOOLER_PROCESSOS_EMAIL
	WHERE dt_fim_processo is null and qtd_emails_enviados = 0 ORDER BY dt_criacao_processo, hr_criacao_processo, id_processo;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllSpoolerFinished` $$
CREATE PROCEDURE `spGetAllSpoolerFinished`()
begin
	
	SELECT *, DATE_FORMAT(dt_ultima_execucao,'%d/%m') as dt_ultima_execucao_formatada, '' as ds_horario_execucao, '' as ds_periodicidade FROM TB_SPOOLER_PROCESSOS_EMAIL
	WHERE dt_fim_processo is not null and qtd_emails_enviados > 0 ORDER BY dt_fim_processo desc, hr_fim_processo desc, id_processo LIMIT 5;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllSpoolerAdmin` $$
CREATE PROCEDURE `spGetAllSpoolerAdmin`()
begin
	
	SELECT *, DATE_FORMAT(dt_ultima_execucao,'%d/%m') as dt_ultima_execucao_formatada, ds_processo_adm as ds_processo, sl_processo_adm as sl_processo, '' as psn_id_responsavel, 0 as qtd_total_emails, 0 as qtd_emails_restantes FROM TB_PROCESSOS_ADMINISTRATIVOS
	WHERE in_ativo = True ORDER BY ds_periodicidade, ds_horario_execucao, sl_processo_adm;
	
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddSpooler` $$
CREATE PROCEDURE `spAddSpooler`(
		pDescription VARCHAR(250),
		pTypeSpooler VARCHAR(30),
		pUsuResponsavelID INTEGER
)
begin

	INSERT INTO TB_SPOOLER_PROCESSOS_EMAIL (ds_processo, sl_processo, dt_criacao_processo, hr_criacao_processo, qtd_total_emails, qtd_emails_enviados, qtd_emails_restantes, psn_id_responsavel)
	VALUES (pDescription, pTypeSpooler, DATE_FORMAT(now(),'%Y-%m-%d'), DATE_FORMAT(now(),'%H:%i'), 0, 0, 0, pUsuResponsavelID);

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddSpoolerDetailsDraw` $$
CREATE PROCEDURE `spAddSpoolerDetailsDraw`(
		pProcessoID INTEGER,
		pUsuID INTEGER,
		pSequenceID INTEGER,
		pUsuName VARCHAR(50),
		pPsnID VARCHAR(30),
		pEmail VARCHAR(80),
		pInModerator TINYINT,
		pTempID INTEGER,
		pCampID INTEGER,
		pInTecnico INTEGER,
		pUsuResponsavelID INTEGER
)
begin

	INSERT INTO TB_PROCESSOS_EMAIL_DETALHE (id_processo, id_usuario, id_sequencial, nm_usuario, psn_id, ds_email, in_usuario_moderador, id_temporada, id_campeonato, id_moderador, in_tecnico)
	VALUES (pProcessoID, pUsuID, pSequenceID, pUsuName, pPsnID, pEmail, pInModerator, pTempID, pCampID, pUsuResponsavelID, pInTecnico);

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateTotalSpooler` $$
CREATE PROCEDURE `spUpdateTotalSpooler`(
		pProcessoID INTEGER
)
begin

	UPDATE TB_SPOOLER_PROCESSOS_EMAIL S 
	   SET S.qtd_total_emails = (SELECT count(1) FROM TB_PROCESSOS_EMAIL_DETALHE D WHERE D.id_processo = pProcessoID) 
	 WHERE S.id_processo = pProcessoID;

End$$
DELIMITER ;

