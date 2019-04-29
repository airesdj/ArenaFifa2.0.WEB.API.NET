#
# DUMP FILE
#
# Database is ported from MS Access
#------------------------------------------------------------------
# Created using "MS Access to MySQL" form http://www.bullzip.com
# Program Version 5.5.282
#
# OPTIONS:
#   sourcefilename=C:/Aplicacao/Fifa/Database/ArenaFifa_SPOOLER.mdb
#   sourceusername=admin
#   sourcepassword=** HIDDEN **
#   sourcesystemdatabase=
#   destinationdatabase=Arena_Spooler
#   storageengine=MyISAM
#   dropdatabase=1
#   createtables=1
#   unicode=0
#   autocommit=0
#   transferdefaultvalues=1
#   transferindexes=1
#   transferautonumbers=1
#   transferrecords=0
#   columnlist=0
#   tableprefix=
#   negativeboolean=0
#   ignorelargeblobs=0
#   memotype=LONGTEXT
#   datetimetype=DATETIME
#


CREATE DATABASE IF NOT EXISTS `arena_spooler`;
USE `arena_spooler`;

#
# Table structure for table 'TB_HISTORICO_SPOOLER'
#

DROP TABLE IF EXISTS `TB_HISTORICO_SPOOLER`;

CREATE TABLE `TB_HISTORICO_SPOOLER` (
  `id_processo` INTEGER NOT NULL DEFAULT 0, 
  `dt_execucao_processo` DATETIME NOT NULL, 
  `hr_execucao_processo` VARCHAR(5) NOT NULL, 
  `qtd_emails_enviados` INTEGER DEFAULT 0, 
  INDEX (`dt_execucao_processo`, `hr_execucao_processo`, `id_processo`), 
  PRIMARY KEY (`id_processo`, `dt_execucao_processo`, `hr_execucao_processo`)
) ENGINE=myisam;

#
# Table structure for table 'TB_PROCESSOS_ADMINISTRATIVOS'
#

DROP TABLE IF EXISTS `TB_PROCESSOS_ADMINISTRATIVOS`;

CREATE TABLE `TB_PROCESSOS_ADMINISTRATIVOS` (
  `sl_processo_adm` VARCHAR(30) NOT NULL, 
  `ds_processo_adm` VARCHAR(80) NOT NULL, 
  `ds_periodicidade` VARCHAR(20), 
  `ds_horario_execucao` VARCHAR(5), 
  `dt_ultima_execucao` DATETIME, 
  `hr_ultima_execucao` VARCHAR(5), 
  `qtd_emails_enviados` INTEGER DEFAULT 0, 
  `in_ativo` TINYINT(1) DEFAULT 0, 
  INDEX (`ds_horario_execucao`, `sl_processo_adm`), 
  INDEX (`ds_periodicidade`, `in_ativo`, `sl_processo_adm`), 
  PRIMARY KEY (`sl_processo_adm`)
) ENGINE=myisam;

#
# Table structure for table 'TB_PROCESSOS_EMAIL_DETALHE'
#

DROP TABLE IF EXISTS `TB_PROCESSOS_EMAIL_DETALHE`;

CREATE TABLE `TB_PROCESSOS_EMAIL_DETALHE` (
  `id_processo` INTEGER NOT NULL DEFAULT 0, 
  `id_usuario` INTEGER NOT NULL DEFAULT 0, 
  `id_sequencial` INTEGER NOT NULL DEFAULT 0, 
  `dt_execucao_processo` DATETIME, 
  `hr_execucao_processo` VARCHAR(5), 
  `nm_usuario` VARCHAR(50), 
  `psn_id` VARCHAR(30), 
  `ds_email` VARCHAR(80), 
  `ds_time_atual` VARCHAR(50), 
  `id_temporada` INTEGER DEFAULT 0, 
  `id_campeonato` INTEGER DEFAULT 0, 
  `in_usuario_moderador` TINYINT(1), 
  `id_blog` INTEGER DEFAULT 0, 
  `dt_blog` VARCHAR(10), 
  `id_moderador` INTEGER DEFAULT 0, 
  `ds_titulo` VARCHAR(100), 
  `in_tecnico` TINYINT(3) UNSIGNED DEFAULT 0, 
  INDEX (`dt_execucao_processo`, `hr_execucao_processo`, `id_processo`), 
  INDEX (`id_usuario`, `id_processo`), 
  INDEX (`id_sequencial`, `id_processo`), 
  INDEX (`id_processo`, `id_sequencial`), 
  PRIMARY KEY (`id_processo`, `id_usuario`)
) ENGINE=myisam;

#
# Table structure for table 'TB_SPOOLER_PROCESSOS_EMAIL'
#

DROP TABLE IF EXISTS `TB_SPOOLER_PROCESSOS_EMAIL`;

CREATE TABLE `TB_SPOOLER_PROCESSOS_EMAIL` (
  `id_processo` INTEGER NOT NULL AUTO_INCREMENT, 
  `ds_processo` VARCHAR(250), 
  `sl_processo` VARCHAR(30), 
  `dt_criacao_processo` DATETIME, 
  `hr_criacao_processo` VARCHAR(5), 
  `qtd_total_emails` INTEGER DEFAULT 0, 
  `qtd_emails_enviados` INTEGER DEFAULT 0, 
  `qtd_emails_restantes` INTEGER DEFAULT 0, 
  `dt_ultima_execucao` DATETIME, 
  `hr_ultima_execucao` VARCHAR(5), 
  `dt_fim_processo` DATETIME, 
  `hr_fim_processo` VARCHAR(5), 
  `psn_id_responsavel` VARCHAR(30) NOT NULL, 
  `id_temporada` INTEGER DEFAULT 0, 
  `id_campeonato` INTEGER DEFAULT 0, 
  `id_tabela_jogo` INTEGER DEFAULT 0, 
  `id_fase` INTEGER DEFAULT 0, 
  `in_numero_rodada` INTEGER DEFAULT 0, 
  `nm_campeonato` VARCHAR(100), 
  INDEX (`dt_fim_processo`, `hr_fim_processo`, `id_processo`), 
  INDEX (`dt_criacao_processo`, `hr_criacao_processo`, `id_processo`), 
  INDEX (`ds_processo`), 
  PRIMARY KEY (`id_processo`)
) ENGINE=myisam;

