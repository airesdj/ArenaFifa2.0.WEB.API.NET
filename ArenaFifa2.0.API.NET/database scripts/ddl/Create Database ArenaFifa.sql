#
# DUMP FILE
#
# Database is ported from MS Access
#------------------------------------------------------------------
# Created using "MS Access to MySQL" form http://www.bullzip.com
# Program Version 5.5.282
#
# OPTIONS:
#   sourcefilename=C:/Aplicacao/Fifa/Database/ArenaFifa.mdb
#   sourceusername=admin
#   sourcepassword=** HIDDEN **
#   sourcesystemdatabase=
#   destinationdatabase=ArenaFifaDB
#   storageengine=MyISAM
#   dropdatabase=1
#   createtables=1
#   unicode=1
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

CREATE DATABASE IF NOT EXISTS `arenafifadb`;
USE `arenafifadb`;

#
# Table structure for table 'TB_CAMPEONATO'
#

DROP TABLE IF EXISTS `TB_CAMPEONATO`;

CREATE TABLE `TB_CAMPEONATO` (
  `ID_CAMPEONATO` INTEGER NOT NULL AUTO_INCREMENT, 
  `ID_TEMPORADA` INTEGER NOT NULL DEFAULT 0, 
  `NM_CAMPEONATO` VARCHAR(50) NOT NULL, 
  `QT_TIMES` INTEGER NOT NULL DEFAULT 0, 
  `DT_INICIO` DATETIME NOT NULL, 
  `DT_SORTEIO` DATETIME NOT NULL, 
  `IN_CAMPEONATO_ATIVO` TINYINT(1) NOT NULL, 
  `IN_CAMPEONATO_GRUPO` TINYINT(1), 
  `IN_CAMPEONATO_TURNO_UNICO` TINYINT(1), 
  `IN_CAMPEONATO_TURNO_RETURNO` TINYINT(1), 
  `QT_GRUPOS` INTEGER NOT NULL DEFAULT 0, 
  `IN_SISTEMA_MATA` TINYINT(1), 
  `IN_SISTEMA_IDA_VOLTA` TINYINT(1), 
  `QT_TIMES_CLASSIFICADOS` INTEGER NOT NULL DEFAULT 0, 
  `QT_TIMES_REBAIXADOS` INTEGER NOT NULL DEFAULT 0, 
  `DS_LOGO_PEQ` VARCHAR(50), 
  `DS_LOGO_MED` VARCHAR(50), 
  `ID_USUARIO_MODERADOR` INTEGER NOT NULL DEFAULT 0, 
  `DS_FRIENDS_LEAGUE` LONGTEXT, 
  `QT_DIAS_PARTIDA_CLASSIFICACAO` INTEGER, 
  `QT_DIAS_PARTIDA_FASE_MATAxMATA` INTEGER, 
  `SG_TIPO_CAMPEONATO` VARCHAR(4), 
  `QT_TIMES_PROX_CLASSIF` INTEGER, 
  `IN_Console` VARCHAR(3), 
  `ID_USUARIO_2oMODERADOR` INTEGER, 
  `ID_USUARIO_1oAUXILIAR` INTEGER, 
  `ID_USUARIO_2oAUXILIAR` INTEGER, 
  `ID_USUARIO_3oAUXILIAR` INTEGER, 
  `DT_ULTIMA_ALTERACAO` DATETIME, 
  `DS_LOGIN_ALTERACAO` VARCHAR(30), 
  `DS_FASE_MATAxMATA_MONTADA` VARCHAR(100), 
  `QT_TIMES_ACESSO` INTEGER, 
  `IN_DISPUTA_3o_4o_Lugar` TINYINT(1), 
  `ID_CAMPEONATO_DESTINO` INTEGER, 
  `ID_CAMPEONATO_ORIGEM` INTEGER, 
  `IN_POSICAO_ORIGEM` INTEGER, 
  `IN_DOUBLE_ROUND` TINYINT(3) UNSIGNED, 
  INDEX (`ID_CAMPEONATO`, `ID_USUARIO_MODERADOR`), 
  INDEX (`ID_TEMPORADA`, `ID_USUARIO_MODERADOR`, `ID_CAMPEONATO`), 
  INDEX (`NM_CAMPEONATO`), 
  INDEX (`SG_TIPO_CAMPEONATO`, `ID_CAMPEONATO`), 
  INDEX (`ID_USUARIO_MODERADOR`), 
  PRIMARY KEY (`ID_CAMPEONATO`), 
  INDEX (`ID_TEMPORADA`, `DT_INICIO`, `NM_CAMPEONATO`), 
  INDEX (`IN_CAMPEONATO_ATIVO`, `ID_TEMPORADA`, `SG_TIPO_CAMPEONATO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_CAMPEONATO_TIME'
#

DROP TABLE IF EXISTS `TB_CAMPEONATO_TIME`;

CREATE TABLE `TB_CAMPEONATO_TIME` (
  `ID_CAMPEONATO` INTEGER NOT NULL DEFAULT 0, 
  `ID_TIME` INTEGER NOT NULL DEFAULT 0, 
  PRIMARY KEY (`ID_CAMPEONATO`, `ID_TIME`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_CAMPEONATO_USUARIO'
#

DROP TABLE IF EXISTS `TB_CAMPEONATO_USUARIO`;

CREATE TABLE `TB_CAMPEONATO_USUARIO` (
  `ID_CAMPEONATO` INTEGER NOT NULL DEFAULT 0, 
  `ID_USUARIO` INTEGER NOT NULL DEFAULT 0, 
  `DT_ENTRADA` DATETIME, 
  PRIMARY KEY (`ID_CAMPEONATO`, `ID_USUARIO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_CAMPEONATO_USUARIO_SEG_FASE'
#

DROP TABLE IF EXISTS `TB_CAMPEONATO_USUARIO_SEG_FASE`;

CREATE TABLE `TB_CAMPEONATO_USUARIO_SEG_FASE` (
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_USUARIO` INTEGER NOT NULL, 
  `IN_ORDENACAO_SORTEIO` INTEGER, 
  PRIMARY KEY (`ID_CAMPEONATO`, `ID_USUARIO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_CLASSIFICACAO'
#

DROP TABLE IF EXISTS `TB_CLASSIFICACAO`;

CREATE TABLE `TB_CLASSIFICACAO` (
  `ID_CAMPEONATO` INTEGER NOT NULL DEFAULT 0, 
  `ID_TIME` INTEGER NOT NULL DEFAULT 0, 
  `ID_GRUPO` INTEGER NOT NULL DEFAULT 0, 
  `QT_PONTOS_GANHOS` INTEGER NOT NULL DEFAULT 0, 
  `QT_VITORIAS` INTEGER DEFAULT 0, 
  `QT_JOGOS` INTEGER DEFAULT 0, 
  `QT_EMPATES` INTEGER DEFAULT 0, 
  `QT_DERROTAS` INTEGER DEFAULT 0, 
  `QT_GOLS_PRO` INTEGER DEFAULT 0, 
  `QT_GOLS_CONTRA` INTEGER DEFAULT 0, 
  `IN_ORDENACAO_GRUPO` TINYINT(3) UNSIGNED, 
  INDEX (`ID_CAMPEONATO`, `ID_GRUPO`, `ID_TIME`), 
  PRIMARY KEY (`ID_CAMPEONATO`, `ID_TIME`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_COMENTARIO_JOGO'
#

DROP TABLE IF EXISTS `TB_COMENTARIO_JOGO`;

CREATE TABLE `TB_COMENTARIO_JOGO` (
  `ID_COMENTARIO` INTEGER NOT NULL AUTO_INCREMENT, 
  `ID_TABELA_JOGO` INTEGER NOT NULL DEFAULT 0, 
  `ID_USUARIO` INTEGER NOT NULL DEFAULT 0, 
  `DT_COMENTARIO` DATETIME NOT NULL, 
  `HR_COMENTARIO` VARCHAR(8) NOT NULL, 
  `DS_COMENTARIO` LONGTEXT NOT NULL, 
  INDEX (`ID_TABELA_JOGO`, `ID_USUARIO`, `DT_COMENTARIO`, `HR_COMENTARIO`, `DS_COMENTARIO`(100)), 
  PRIMARY KEY (`ID_COMENTARIO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_COMENTARIO_USUARIO'
#

DROP TABLE IF EXISTS `TB_COMENTARIO_USUARIO`;

CREATE TABLE `TB_COMENTARIO_USUARIO` (
  `ID_TABELA_JOGO` INTEGER NOT NULL, 
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_USUARIO` INTEGER NOT NULL, 
  PRIMARY KEY (`ID_TABELA_JOGO`, `ID_USUARIO`, `ID_CAMPEONATO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_CONFIRM_ELENCO_PRO'
#

DROP TABLE IF EXISTS `TB_CONFIRM_ELENCO_PRO`;

CREATE TABLE `TB_CONFIRM_ELENCO_PRO` (
  `ID_TEMPORADA` INTEGER NOT NULL, 
  `ID_USUARIO_MANAGER` INTEGER NOT NULL, 
  `ID_USUARIO` INTEGER NOT NULL, 
  `DT_CONFIRMACAO` DATETIME NOT NULL, 
  PRIMARY KEY (`ID_TEMPORADA`, `ID_USUARIO_MANAGER`, `ID_USUARIO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_CONFIRMACAO_TEMPORADA'
#

DROP TABLE IF EXISTS `TB_CONFIRMACAO_TEMPORADA`;

CREATE TABLE `TB_CONFIRMACAO_TEMPORADA` (
  `ID_TEMPORADA` INTEGER NOT NULL, 
  `ID_USUARIO` INTEGER NOT NULL, 
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `IN_CONFIRMACAO` TINYINT(3) UNSIGNED, 
  `DT_CONFIRMACAO` DATETIME, 
  `IN_ORDENACAO` INTEGER, 
  `NM_TIME` VARCHAR(50), 
  `IN_Console` VARCHAR(3), 
  `DS_Status` VARCHAR(2), 
  `DS_Descricao_Status` VARCHAR(50), 
  `ID_TIME_PRO` INTEGER, 
  `NO_DDD` VARCHAR(2), 
  `NO_CELULAR` VARCHAR(15), 
  `IN_UPLOAD_LOGO_TIME` TINYINT(1), 
  INDEX (`ID_TEMPORADA`, `ID_USUARIO`, `ID_CAMPEONATO`), 
  INDEX (`ID_CAMPEONATO`), 
  INDEX (`IN_ORDENACAO`, `DT_CONFIRMACAO`), 
  PRIMARY KEY (`ID_TEMPORADA`, `ID_USUARIO`, `ID_CAMPEONATO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_FASE'
#

DROP TABLE IF EXISTS `TB_FASE`;

CREATE TABLE `TB_FASE` (
  `ID_FASE` INTEGER NOT NULL DEFAULT 0, 
  `NM_FASE` VARCHAR(50) NOT NULL, 
  `DS_XPATH_TABELA` VARCHAR(100), 
  PRIMARY KEY (`ID_FASE`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_FASE_CAMPEONATO'
#

DROP TABLE IF EXISTS `TB_FASE_CAMPEONATO`;

CREATE TABLE `TB_FASE_CAMPEONATO` (
  `ID_CAMPEONATO` INTEGER NOT NULL DEFAULT 0, 
  `ID_FASE` INTEGER NOT NULL DEFAULT 0, 
  `IN_ORDENACAO` TINYINT(3) UNSIGNED DEFAULT 0, 
  INDEX (`ID_CAMPEONATO`), 
  INDEX (`ID_FASE`), 
  INDEX (`IN_ORDENACAO`), 
  PRIMARY KEY (`ID_CAMPEONATO`, `ID_FASE`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_GOLEADOR'
#

DROP TABLE IF EXISTS `TB_GOLEADOR`;

CREATE TABLE `TB_GOLEADOR` (
  `ID_GOLEADOR` INTEGER NOT NULL, 
  `ID_TIME` INTEGER NOT NULL, 
  `NM_GOLEADOR` VARCHAR(50), 
  `NM_GOLEADOR_COMPLETO` VARCHAR(100), 
  `DS_LINK_IMAGEM` VARCHAR(200), 
  `DS_PAIS` VARCHAR(80), 
  `ID_TIME_SOFIFA` INTEGER, 
  `IN_RATING` INTEGER, 
  `ID_USUARIO` INTEGER, 
  `DT_INSCRICAO` DATETIME, 
  INDEX (`ID_TIME`, `NM_GOLEADOR`), 
  INDEX (`NM_GOLEADOR`, `ID_TIME`), 
  INDEX (`ID_TIME_SOFIFA`, `NM_GOLEADOR`, `ID_TIME`), 
  INDEX (`ID_TIME`, `DT_INSCRICAO`, `NM_GOLEADOR_COMPLETO`), 
  INDEX (`NM_GOLEADOR_COMPLETO`), 
  INDEX (`ID_USUARIO`), 
  PRIMARY KEY (`ID_GOLEADOR`, `ID_TIME`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_GOLEADOR_JOGO'
#

DROP TABLE IF EXISTS `TB_GOLEADOR_JOGO`;

CREATE TABLE `TB_GOLEADOR_JOGO` (
  `ID_TABELA_JOGO` INTEGER NOT NULL, 
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_TIME` INTEGER NOT NULL, 
  `ID_GOLEADOR` INTEGER NOT NULL, 
  `QT_GOLS` INTEGER, 
  INDEX (`ID_CAMPEONATO`, `QT_GOLS`, `ID_TIME`), 
  PRIMARY KEY (`ID_CAMPEONATO`, `ID_TABELA_JOGO`, `ID_TIME`, `ID_GOLEADOR`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_GRUPO'
#

DROP TABLE IF EXISTS `TB_GRUPO`;

CREATE TABLE `TB_GRUPO` (
  `ID_CAMPEONATO` INTEGER NOT NULL DEFAULT 0, 
  `ID_GRUPO` INTEGER NOT NULL DEFAULT 0, 
  `NM_GRUPO` VARCHAR(50) NOT NULL, 
  INDEX (`NM_GRUPO`), 
  INDEX (`ID_CAMPEONATO`), 
  INDEX (`ID_GRUPO`), 
  PRIMARY KEY (`ID_CAMPEONATO`, `ID_GRUPO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_HISTORICO_ALT_CAMPEONATO'
#

DROP TABLE IF EXISTS `TB_HISTORICO_ALT_CAMPEONATO`;

CREATE TABLE `TB_HISTORICO_ALT_CAMPEONATO` (
  `ID_CAMPEONATO_ALTERADO` INTEGER NOT NULL, 
  `DT_OPERACAO` DATETIME NOT NULL, 
  `TP_OPERACAO` VARCHAR(30) NOT NULL, 
  `ID_USUARIO_OPERACAO` INTEGER NOT NULL, 
  `DS_PAGINA` VARCHAR(30), 
  `PSN_ID_OPERACAO` VARCHAR(30), 
  `NM_CAMP_ALTERADO` VARCHAR(100), 
  INDEX (`DT_OPERACAO`, `ID_CAMPEONATO_ALTERADO`), 
  PRIMARY KEY (`ID_CAMPEONATO_ALTERADO`, `DT_OPERACAO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_HISTORICO_ALT_USUARIO'
#

DROP TABLE IF EXISTS `TB_HISTORICO_ALT_USUARIO`;

CREATE TABLE `TB_HISTORICO_ALT_USUARIO` (
  `ID_USUARIO_ALTERADO` INTEGER NOT NULL, 
  `DT_OPERACAO` DATETIME NOT NULL, 
  `TP_OPERACAO` VARCHAR(30) NOT NULL, 
  `ID_USUARIO_OPERACAO` INTEGER NOT NULL, 
  `DS_PAGINA` VARCHAR(30), 
  `PSN_ID_OPERACAO` VARCHAR(30), 
  `PSN_ID_ALTERADO` VARCHAR(30), 
  INDEX (`DT_OPERACAO`, `ID_USUARIO_ALTERADO`), 
  PRIMARY KEY (`ID_USUARIO_ALTERADO`, `DT_OPERACAO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_HISTORICO_ARTILHARIA'
#

DROP TABLE IF EXISTS `TB_HISTORICO_ARTILHARIA`;

CREATE TABLE `TB_HISTORICO_ARTILHARIA` (
  `ID_TEMPORADA` INTEGER NOT NULL, 
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_GOLEADOR` INTEGER NOT NULL, 
  `ID_TIME` INTEGER, 
  `QT_GOLS` INTEGER, 
  `ID_TECNICO` INTEGER, 
  PRIMARY KEY (`ID_TEMPORADA`, `ID_CAMPEONATO`, `ID_GOLEADOR`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_HISTORICO_ARTILHARIA_PRO'
#

DROP TABLE IF EXISTS `TB_HISTORICO_ARTILHARIA_PRO`;

CREATE TABLE `TB_HISTORICO_ARTILHARIA_PRO` (
  `ID_TEMPORADA` INTEGER NOT NULL, 
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_GOLEADOR` INTEGER NOT NULL, 
  `ID_TIME` INTEGER, 
  `QT_GOLS` INTEGER, 
  `ID_TECNICO` INTEGER, 
  PRIMARY KEY (`ID_TEMPORADA`, `ID_CAMPEONATO`, `ID_GOLEADOR`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_HISTORICO_ATUAL'
#

DROP TABLE IF EXISTS `TB_HISTORICO_ATUAL`;

CREATE TABLE `TB_HISTORICO_ATUAL` (
  `ID_TEMPORADA` INTEGER NOT NULL, 
  `ID_USUARIO` INTEGER NOT NULL, 
  `TP_MODALIDADE` VARCHAR(3) NOT NULL, 
  `PT_TOTAL` INTEGER, 
  `PT_DIVISAO` INTEGER, 
  `PT_COPA_CLUBE` INTEGER, 
  `PT_COPA_MUNDO` INTEGER, 
  `PT_LIGA` INTEGER, 
  `QT_JOGOS` INTEGER, 
  PRIMARY KEY (`ID_TEMPORADA`, `ID_USUARIO`, `TP_MODALIDADE`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_HISTORICO_CLASSIFICACAO'
#

DROP TABLE IF EXISTS `TB_HISTORICO_CLASSIFICACAO`;

CREATE TABLE `TB_HISTORICO_CLASSIFICACAO` (
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_TIME` INTEGER NOT NULL, 
  `IN_NUMERO_RODADA` INTEGER NOT NULL, 
  `DT_EFETIVACAO_JOGO` DATETIME NOT NULL, 
  `ID_GRUPO` INTEGER, 
  `QT_PONTOS_GANHOS` INTEGER, 
  `QT_VITORIAS` INTEGER, 
  `QT_JOGOS` INTEGER, 
  `QT_EMPATES` INTEGER, 
  `QT_DERROTAS` INTEGER, 
  `QT_GOLS_PRO` INTEGER, 
  `QT_GOLS_CONTRA` INTEGER, 
  `IN_POSICAO` INTEGER, 
  PRIMARY KEY (`ID_CAMPEONATO`, `ID_TIME`, `IN_NUMERO_RODADA`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_HISTORICO_CONQUISTA'
#

DROP TABLE IF EXISTS `TB_HISTORICO_CONQUISTA`;

CREATE TABLE `TB_HISTORICO_CONQUISTA` (
  `ID_TEMPORADA` INTEGER NOT NULL, 
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_USUARIO_CAMPEAO` INTEGER NOT NULL, 
  `ID_TIME_CAMPEAO` INTEGER, 
  `ID_USUARIO_VICECAMPEAO` INTEGER, 
  `ID_TIME_VICECAMPEAO` INTEGER, 
  PRIMARY KEY (`ID_TEMPORADA`, `ID_CAMPEONATO`, `ID_USUARIO_CAMPEAO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_HISTORICO_CONQUISTA_FUT'
#

DROP TABLE IF EXISTS `TB_HISTORICO_CONQUISTA_FUT`;

CREATE TABLE `TB_HISTORICO_CONQUISTA_FUT` (
  `ID_TEMPORADA` INTEGER NOT NULL, 
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_USUARIO_CAMPEAO` INTEGER NOT NULL, 
  `ID_TIME_CAMPEAO` INTEGER, 
  `ID_USUARIO_VICECAMPEAO` INTEGER, 
  `ID_TIME_VICECAMPEAO` INTEGER, 
  PRIMARY KEY (`ID_TEMPORADA`, `ID_CAMPEONATO`, `ID_USUARIO_CAMPEAO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_HISTORICO_CONQUISTA_PRO'
#

DROP TABLE IF EXISTS `TB_HISTORICO_CONQUISTA_PRO`;

CREATE TABLE `TB_HISTORICO_CONQUISTA_PRO` (
  `ID_TEMPORADA` INTEGER NOT NULL, 
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_TIME_CAMPEAO` INTEGER NOT NULL, 
  `ID_USUARIO_CAMPEAO` INTEGER, 
  `ID_TIME_VICECAMPEAO` INTEGER, 
  `ID_USUARIO_VICECAMPEAO` INTEGER, 
  PRIMARY KEY (`ID_TEMPORADA`, `ID_CAMPEONATO`, `ID_TIME_CAMPEAO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_HISTORICO_TEMPORADA'
#

DROP TABLE IF EXISTS `TB_HISTORICO_TEMPORADA`;

CREATE TABLE `TB_HISTORICO_TEMPORADA` (
  `ID_TEMPORADA` INTEGER NOT NULL, 
  `ID_USUARIO` INTEGER NOT NULL, 
  `PT_TOTAL` INTEGER, 
  `PT_CAMPEAO` INTEGER, 
  `PT_VICECAMPEAO` INTEGER, 
  `PT_SEMIS` INTEGER, 
  `PT_QUARTAS` INTEGER, 
  `PT_OITAVAS` INTEGER, 
  `PT_CLASSIF_FASE2` INTEGER, 
  `PT_VITORIAS_FASE1` INTEGER, 
  `PT_EMPATES_FASE1` INTEGER, 
  `IN_POSICAO_ATUAL` INTEGER, 
  `PT_TOTAL_TEMPORADA_ANTERIOR` INTEGER, 
  `IN_POSICAO_ANTERIOR` INTEGER, 
  `PT_LIGAS` INTEGER, 
  `PT_COPAS` INTEGER, 
  `PT_TOTAL_TEMPORADA` INTEGER, 
  `QT_JOGOS_TEMPORADA` INTEGER, 
  `QT_JOGOS_GERAL` INTEGER, 
  `QT_TOTAL_PONTOS_TEMPORADA` INTEGER, 
  `QT_TOTAL_PONTOS_GERAL` INTEGER, 
  `QT_TOTAL_VITORIAS_TEMPORADA` INTEGER, 
  `QT_TOTAL_VITORIAS_GERAL` INTEGER, 
  `QT_TOTAL_EMPATES_TEMPORADA` INTEGER, 
  `QT_TOTAL_EMPATES_GERAL` INTEGER, 
  `PC_APROVEITAMENTO_TEMPORADAS` DOUBLE NULL, 
  `PC_APROVEITAMENTO_GERAL` DOUBLE NULL, 
  `IN_REBAIXADO_TEMP_ANTERIOR` TINYINT(3) UNSIGNED, 
  `IN_ACESSO_TEMP_ATUAL` TINYINT(3) UNSIGNED, 
  `QT_LstNegra` INTEGER, 
  PRIMARY KEY (`ID_TEMPORADA`, `ID_USUARIO`), 
  INDEX (`IN_POSICAO_ANTERIOR`), 
  INDEX (`IN_POSICAO_ATUAL`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_HISTORICO_TEMPORADA_FUT'
#

DROP TABLE IF EXISTS `TB_HISTORICO_TEMPORADA_FUT`;

CREATE TABLE `TB_HISTORICO_TEMPORADA_FUT` (
  `ID_TEMPORADA` INTEGER NOT NULL, 
  `ID_USUARIO` INTEGER NOT NULL, 
  `PT_TOTAL` INTEGER, 
  `PT_CAMPEAO` INTEGER, 
  `PT_VICECAMPEAO` INTEGER, 
  `PT_SEMIS` INTEGER, 
  `PT_QUARTAS` INTEGER, 
  `PT_OITAVAS` INTEGER, 
  `PT_CLASSIF_FASE2` INTEGER, 
  `PT_VITORIAS_FASE1` INTEGER, 
  `PT_EMPATES_FASE1` INTEGER, 
  `IN_POSICAO_ATUAL` INTEGER, 
  `PT_TOTAL_TEMPORADA_ANTERIOR` INTEGER, 
  `IN_POSICAO_ANTERIOR` INTEGER, 
  `PT_LIGAS` INTEGER, 
  `PT_COPAS` INTEGER, 
  `PT_TOTAL_TEMPORADA` INTEGER, 
  `QT_JOGOS_TEMPORADA` INTEGER, 
  `QT_JOGOS_GERAL` INTEGER, 
  `QT_TOTAL_PONTOS_TEMPORADA` INTEGER, 
  `QT_TOTAL_PONTOS_GERAL` INTEGER, 
  `QT_TOTAL_VITORIAS_TEMPORADA` INTEGER, 
  `QT_TOTAL_VITORIAS_GERAL` INTEGER, 
  `QT_TOTAL_EMPATES_TEMPORADA` INTEGER, 
  `QT_TOTAL_EMPATES_GERAL` INTEGER, 
  `PC_APROVEITAMENTO_TEMPORADAS` DOUBLE NULL, 
  `PC_APROVEITAMENTO_GERAL` DOUBLE NULL, 
  `IN_REBAIXADO_TEMP_ANTERIOR` TINYINT(3) UNSIGNED, 
  `IN_ACESSO_TEMP_ATUAL` TINYINT(3) UNSIGNED, 
  `QT_LstNegra` INTEGER, 
  PRIMARY KEY (`ID_TEMPORADA`, `ID_USUARIO`), 
  INDEX (`IN_POSICAO_ANTERIOR`), 
  INDEX (`IN_POSICAO_ATUAL`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_HISTORICO_TEMPORADA_PRO'
#

DROP TABLE IF EXISTS `TB_HISTORICO_TEMPORADA_PRO`;

CREATE TABLE `TB_HISTORICO_TEMPORADA_PRO` (
  `ID_TEMPORADA` INTEGER NOT NULL, 
  `ID_TIME` INTEGER NOT NULL, 
  `ID_USUARIO` INTEGER NOT NULL, 
  `PT_TOTAL` INTEGER, 
  `PT_CAMPEAO` INTEGER, 
  `PT_VICECAMPEAO` INTEGER, 
  `PT_SEMIS` INTEGER, 
  `PT_QUARTAS` INTEGER, 
  `PT_OITAVAS` INTEGER, 
  `PT_CLASSIF_FASE2` INTEGER, 
  `PT_VITORIAS_FASE1` INTEGER, 
  `PT_EMPATES_FASE1` INTEGER, 
  `IN_POSICAO_ATUAL` INTEGER, 
  `PT_TOTAL_TEMPORADA_ANTERIOR` INTEGER, 
  `IN_POSICAO_ANTERIOR` INTEGER, 
  `PT_LIGAS` INTEGER, 
  `PT_COPAS` INTEGER, 
  `PT_TOTAL_TEMPORADA` INTEGER, 
  `QT_JOGOS_TEMPORADA` INTEGER, 
  `QT_JOGOS_GERAL` INTEGER, 
  `QT_TOTAL_PONTOS_TEMPORADA` INTEGER, 
  `QT_TOTAL_PONTOS_GERAL` INTEGER, 
  `QT_TOTAL_VITORIAS_TEMPORADA` INTEGER, 
  `QT_TOTAL_VITORIAS_GERAL` INTEGER, 
  `QT_TOTAL_EMPATES_TEMPORADA` INTEGER, 
  `QT_TOTAL_EMPATES_GERAL` INTEGER, 
  `PC_APROVEITAMENTO_TEMPORADAS` DOUBLE NULL, 
  `PC_APROVEITAMENTO_GERAL` DOUBLE NULL, 
  `IN_REBAIXADO_TEMP_ANTERIOR` TINYINT(3) UNSIGNED, 
  `IN_ACESSO_TEMP_ATUAL` TINYINT(3) UNSIGNED, 
  `QT_LstNegra` INTEGER, 
  PRIMARY KEY (`ID_TEMPORADA`, `ID_TIME`), 
  INDEX (`IN_POSICAO_ANTERIOR`), 
  INDEX (`IN_POSICAO_ATUAL`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_HISTORICO_TRANSMISSAO_AOVIVO'
#

DROP TABLE IF EXISTS `TB_HISTORICO_TRANSMISSAO_AOVIVO`;

CREATE TABLE `TB_HISTORICO_TRANSMISSAO_AOVIVO` (
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_TABELA_JOGO` INTEGER NOT NULL, 
  `ID_TIME` INTEGER, 
  `ID_USUARIO` INTEGER, 
  `DS_URL_LINK_AOVIVO` LONGTEXT, 
  `DT_JOGO` DATETIME, 
  `HR_JOGO` VARCHAR(5), 
  INDEX (`DT_JOGO`, `HR_JOGO`, `ID_CAMPEONATO`, `ID_TABELA_JOGO`), 
  PRIMARY KEY (`ID_CAMPEONATO`, `ID_TABELA_JOGO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_LISTA_BANCO_RESERVA'
#

DROP TABLE IF EXISTS `TB_LISTA_BANCO_RESERVA`;

CREATE TABLE `TB_LISTA_BANCO_RESERVA` (
  `ID_BANCO_RESERVA` INTEGER NOT NULL AUTO_INCREMENT, 
  `ID_USUARIO` INTEGER NOT NULL, 
  `TP_BANCO_RESERVA` VARCHAR(3) NOT NULL, 
  `DT_INICIO` DATETIME NOT NULL, 
  `DT_FIM` DATETIME, 
  `NM_TIME_FUT` VARCHAR(50), 
  `IN_CONSOLE` VARCHAR(3), 
  INDEX (`DT_FIM`, `ID_USUARIO`), 
  INDEX (`DT_FIM`, `ID_BANCO_RESERVA`), 
  INDEX (`TP_BANCO_RESERVA`, `ID_BANCO_RESERVA`), 
  INDEX (`ID_USUARIO`, `TP_BANCO_RESERVA`), 
  INDEX (`ID_USUARIO`, `TP_BANCO_RESERVA`, `IN_CONSOLE`, `DT_FIM`), 
  INDEX (`TP_BANCO_RESERVA`, `IN_CONSOLE`, `ID_BANCO_RESERVA`), 
  PRIMARY KEY (`ID_BANCO_RESERVA`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_LISTA_NEGRA'
#

DROP TABLE IF EXISTS `TB_LISTA_NEGRA`;

CREATE TABLE `TB_LISTA_NEGRA` (
  `ID_TEMPORADA` INTEGER NOT NULL, 
  `ID_USUARIO` INTEGER NOT NULL, 
  `QT_ADVERTENCIAS` INTEGER, 
  `QT_OMISSAO_PARCIAL` INTEGER, 
  `QT_OMISSAO_TOTAL` INTEGER, 
  `PT_TOTAL` INTEGER, 
  `QT_ANTIDESPORTIVA` INTEGER, 
  INDEX (`ID_TEMPORADA`, `ID_USUARIO`, `PT_TOTAL`), 
  INDEX (`PT_TOTAL`), 
  PRIMARY KEY (`ID_TEMPORADA`, `ID_USUARIO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_LISTA_NEGRA_DETALHE'
#

DROP TABLE IF EXISTS `TB_LISTA_NEGRA_DETALHE`;

CREATE TABLE `TB_LISTA_NEGRA_DETALHE` (
  `ID_TEMPORADA` INTEGER NOT NULL, 
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_USUARIO` INTEGER NOT NULL, 
  `ID_TABELA_JOGO` INTEGER NOT NULL, 
  `IN_ADVERTENCIAS` TINYINT(3) UNSIGNED, 
  `IN_OMISSAO_PARCIAL` TINYINT(3) UNSIGNED, 
  `IN_OMISSAO_TOTAL` TINYINT(3) UNSIGNED, 
  `PT_NEGATIVO` INTEGER, 
  `DT_ATUALIZACAO` DATETIME, 
  `IN_ANTIDESPORTIVA` INTEGER, 
  INDEX (`ID_TABELA_JOGO`, `ID_USUARIO`), 
  INDEX (`ID_TEMPORADA`, `ID_USUARIO`), 
  INDEX (`DT_ATUALIZACAO`), 
  PRIMARY KEY (`ID_TEMPORADA`, `ID_CAMPEONATO`, `ID_USUARIO`, `ID_TABELA_JOGO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_PALPITE_JOGO'
#

DROP TABLE IF EXISTS `TB_PALPITE_JOGO`;

CREATE TABLE `TB_PALPITE_JOGO` (
  `ID_USUARIO` INTEGER NOT NULL, 
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_TABELA_JOGO` INTEGER NOT NULL, 
  `ID_FASE` INTEGER, 
  `IN_NUMERO_RODADA` INTEGER, 
  `IN_TIME_CASA` TINYINT(3) UNSIGNED, 
  `IN_TIME_VISITANTE` TINYINT(3) UNSIGNED, 
  `IN_EMPATE` TINYINT(3) UNSIGNED, 
  INDEX (`ID_CAMPEONATO`, `ID_TABELA_JOGO`), 
  PRIMARY KEY (`ID_USUARIO`, `ID_CAMPEONATO`, `ID_TABELA_JOGO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_PONTUACAO_CAMPEONATO'
#

DROP TABLE IF EXISTS `TB_PONTUACAO_CAMPEONATO`;

CREATE TABLE `TB_PONTUACAO_CAMPEONATO` (
  `PT_CAMPEAO` INTEGER NOT NULL, 
  `PT_VICECAMPEAO` INTEGER NOT NULL, 
  `PT_SEMIS` INTEGER NOT NULL, 
  `PT_QUARTAS` INTEGER NOT NULL, 
  `PT_OITAVAS` INTEGER NOT NULL, 
  `PT_CLASSIF_FASE2` INTEGER NOT NULL, 
  `PT_VITORIAS_FASE1` INTEGER NOT NULL, 
  `PT_EMPATES_FASE1` INTEGER NOT NULL, 
  `SG_TIPO_CAMPEONATO` VARCHAR(4) NOT NULL, 
  `PT_FASE2` INTEGER, 
  PRIMARY KEY (`SG_TIPO_CAMPEONATO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_POTE_TIME_GRUPO'
#

DROP TABLE IF EXISTS `TB_POTE_TIME_GRUPO`;

CREATE TABLE `TB_POTE_TIME_GRUPO` (
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_TIME` INTEGER NOT NULL, 
  `IN_ORDEM_GRUPO` INTEGER, 
  INDEX (`ID_CAMPEONATO`, `IN_ORDEM_GRUPO`), 
  PRIMARY KEY (`ID_CAMPEONATO`, `ID_TIME`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_RESULTADOS_LANCADOS'
#

DROP TABLE IF EXISTS `TB_RESULTADOS_LANCADOS`;

CREATE TABLE `TB_RESULTADOS_LANCADOS` (
  `DT_LANCAMENTO` DATETIME NOT NULL, 
  `ID_TABELA_JOGO` INTEGER NOT NULL, 
  `TP_LANCAMENTO` VARCHAR(15) NOT NULL, 
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `DS_DT_LANCAMENTO` VARCHAR(50) NOT NULL, 
  `NM_CAMPEONATO` VARCHAR(100) NOT NULL, 
  `DS_TABELA_JOGO_RESULTADO` VARCHAR(100) NOT NULL, 
  `DS_TABELA_JOGO_TECNICOS` VARCHAR(100) NOT NULL, 
  `DS_TECNICO_EXECUTOR` VARCHAR(100) NOT NULL, 
  INDEX (`DT_LANCAMENTO`, `ID_CAMPEONATO`), 
  INDEX (`DT_LANCAMENTO`, `TP_LANCAMENTO`), 
  PRIMARY KEY (`DT_LANCAMENTO`, `ID_TABELA_JOGO`, `TP_LANCAMENTO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_TABELA_JOGO'
#

DROP TABLE IF EXISTS `TB_TABELA_JOGO`;

CREATE TABLE `TB_TABELA_JOGO` (
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

#
# Table structure for table 'TB_TEMPORADA'
#

DROP TABLE IF EXISTS `TB_TEMPORADA`;

CREATE TABLE `TB_TEMPORADA` (
  `ID_TEMPORADA` INTEGER NOT NULL AUTO_INCREMENT, 
  `NM_TEMPORADA` VARCHAR(50) NOT NULL, 
  `DT_INICIO` DATETIME, 
  `DT_FIM` DATETIME, 
  `IN_TEMPORADA_ATIVA` TINYINT(3) UNSIGNED, 
  INDEX (`IN_TEMPORADA_ATIVA`, `NM_TEMPORADA`), 
  INDEX (`ID_TEMPORADA`), 
  INDEX (`NM_TEMPORADA`), 
  PRIMARY KEY (`ID_TEMPORADA`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_TIME'
#

DROP TABLE IF EXISTS `TB_TIME`;

CREATE TABLE `TB_TIME` (
  `ID_TIME` INTEGER NOT NULL AUTO_INCREMENT, 
  `NM_TIME` VARCHAR(50) NOT NULL, 
  `DS_LOGO_PEQ` VARCHAR(50), 
  `DS_LOGO_MED` VARCHAR(50), 
  `DS_URL_TIME` VARCHAR(200), 
  `ID_TIPO_TIME` INTEGER NOT NULL DEFAULT 0, 
  `DS_TIPO` VARCHAR(3), 
  `ID_TECNICO_FUT` INTEGER, 
  `IN_TIME_EXCLUIDO_TEMP_ATUAL` TINYINT(3) UNSIGNED, 
  `ID_TIME_SOFIFA` INTEGER, 
  `IN_TIME_COM_IMAGEM` TINYINT(3) UNSIGNED, 
  INDEX (`ID_TIME_SOFIFA`), 
  INDEX (`NM_TIME`), 
  PRIMARY KEY (`ID_TIME`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_TIMES_FASE_PRECOPA'
#

DROP TABLE IF EXISTS `TB_TIMES_FASE_PRECOPA`;

CREATE TABLE `TB_TIMES_FASE_PRECOPA` (
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_TIME` INTEGER NOT NULL, 
  `ID_ORDEM_SORTEIO` INTEGER, 
  PRIMARY KEY (`ID_CAMPEONATO`, `ID_TIME`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_TIPO_CAMPEONATO'
#

DROP TABLE IF EXISTS `TB_TIPO_CAMPEONATO`;

CREATE TABLE `TB_TIPO_CAMPEONATO` (
  `SG_TIPO_CAMPEONATO` VARCHAR(4) NOT NULL, 
  `DS_TIPO_CAMPEONATO` VARCHAR(200), 
  PRIMARY KEY (`SG_TIPO_CAMPEONATO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_TIPO_TIME'
#

DROP TABLE IF EXISTS `TB_TIPO_TIME`;

CREATE TABLE `TB_TIPO_TIME` (
  `ID_TIPO_TIME` INTEGER NOT NULL AUTO_INCREMENT, 
  `NM_TIPO_TIME` VARCHAR(50) NOT NULL, 
  INDEX (`ID_TIPO_TIME`), 
  PRIMARY KEY (`ID_TIPO_TIME`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_ULTIMOS_ACONTECIMENTOS'
#

DROP TABLE IF EXISTS `TB_ULTIMOS_ACONTECIMENTOS`;

CREATE TABLE `TB_ULTIMOS_ACONTECIMENTOS` (
  `DT_ACONTECIMENTO` DATETIME NOT NULL, 
  `ID_CAMPEONATO` INTEGER NOT NULL, 
  `ID_TIME` INTEGER NOT NULL, 
  `ID_BLOG` INTEGER NOT NULL, 
  `ID_FASE` INTEGER NOT NULL, 
  `TP_ACONTECIMENTO` VARCHAR(15) NOT NULL, 
  `DS_DT_ACONTECIMENTO` VARCHAR(50) NOT NULL, 
  `DS_TECNICOS_CONVITE` VARCHAR(100), 
  `DS_TECNICO_EXECUTOR` VARCHAR(100) NOT NULL, 
  INDEX (`DT_ACONTECIMENTO`, `TP_ACONTECIMENTO`), 
  PRIMARY KEY (`DT_ACONTECIMENTO`, `ID_CAMPEONATO`, `ID_TIME`, `ID_BLOG`, `ID_FASE`, `TP_ACONTECIMENTO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_USUARIO'
#

DROP TABLE IF EXISTS `TB_USUARIO`;

CREATE TABLE `TB_USUARIO` (
  `ID_USUARIO` INTEGER NOT NULL AUTO_INCREMENT, 
  `NM_USUARIO` VARCHAR(50) NOT NULL, 
  `PSN_ID` VARCHAR(30) NOT NULL, 
  `DS_SENHA` VARCHAR(10), 
  `IN_USUARIO_ATIVO` TINYINT(1) NOT NULL, 
  `IN_USUARIO_MODERADOR` TINYINT(1) NOT NULL, 
  `DS_EMAIL` VARCHAR(80), 
  `DT_ULTIMO_ACESSO` DATETIME, 
  `DT_NASCIMENTO` DATETIME, 
  `DS_ESTADO` VARCHAR(50), 
  `DS_COMO_FICOU_SABENDO` VARCHAR(50), 
  `DS_QUAL` VARCHAR(80), 
  `NM_TIME` VARCHAR(50), 
  `DS_NOME_IMAGEM_ESCUDO` VARCHAR(80), 
  `IN_RECEBER_EMAIL_ALERTA` INTEGER, 
  `IN_RECEBER_EMAIL_SITUACAO_CAMPEONATO` INTEGER, 
  `IN_DESEJA_PARTICIPAR` INTEGER, 
  `DT_CADASTRO` DATETIME NOT NULL, 
  `DS_URL_LINK_AOVIVO` LONGTEXT, 
  `PSN_ID_EXTRA_NBA` VARCHAR(30), 
  `DT_ULTIMA_ALTERACAO` DATETIME, 
  `DS_LOGIN_ALTERACAO` VARCHAR(30), 
  `IN_PARTICIPA_TIME_PROCLUBE` INTEGER, 
  `IN_USUARIO_AUXILIAR` INTEGER, 
  `DS_SENHA_CONFIRMACAO` VARCHAR(40), 
  `PSN_ID_EXTRA_NFL` VARCHAR(30), 
  `IN_PERTENCE_DIRETORIAFC` INTEGER, 
  `DS_EMAIL_CORPORATIVO` VARCHAR(80), 
  `NO_DDD` VARCHAR(2), 
  `NO_CELULAR` VARCHAR(15), 
  INDEX (`PSN_ID`), 
  INDEX (`IN_USUARIO_ATIVO`, `IN_DESEJA_PARTICIPAR`, `ID_USUARIO`), 
  PRIMARY KEY (`ID_USUARIO`), 
  INDEX (`NM_USUARIO`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

#
# Table structure for table 'TB_USUARIO_TIME'
#

DROP TABLE IF EXISTS `TB_USUARIO_TIME`;

CREATE TABLE `TB_USUARIO_TIME` (
  `ID_CAMPEONATO` INTEGER NOT NULL DEFAULT 0, 
  `ID_USUARIO` INTEGER NOT NULL DEFAULT 0, 
  `ID_TIME` INTEGER NOT NULL DEFAULT 0, 
  `DT_SORTEIO` DATETIME NOT NULL, 
  `DT_VIGENCIA_FIM` DATETIME, 
  `INDICADOR_ORDEM_SORTEIO` INTEGER, 
  INDEX (`DT_SORTEIO`), 
  INDEX (`DT_VIGENCIA_FIM`), 
  PRIMARY KEY (`ID_CAMPEONATO`, `ID_USUARIO`, `ID_TIME`, `DT_SORTEIO`), 
  INDEX (`ID_USUARIO`, `ID_CAMPEONATO`, `ID_TIME`, `DT_VIGENCIA_FIM`), 
  INDEX (`ID_TIME`, `ID_CAMPEONATO`, `DT_VIGENCIA_FIM`)
) ENGINE=myisam DEFAULT CHARSET=utf8;

