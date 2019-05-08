USE `arena_spooler`;



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