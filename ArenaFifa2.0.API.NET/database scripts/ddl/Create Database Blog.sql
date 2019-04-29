#
# DUMP FILE
#
# Database is ported from MS Access
#------------------------------------------------------------------
# Created using "MS Access to MySQL" form http://www.bullzip.com
# Program Version 5.5.282
#
# OPTIONS:
#   sourcefilename=C:/Aplicacao/Fifa/Database/ArenaFifa_BLOG.mdb
#   sourceusername=admin
#   sourcepassword=** HIDDEN **
#   sourcesystemdatabase=
#   destinationdatabase=Arena_Blog
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

CREATE DATABASE IF NOT EXISTS `arena_blog`;
USE `arena_blog`;

#
# Table structure for table 'TB_BLOG_MODERADOR'
#

DROP TABLE IF EXISTS `TB_BLOG_MODERADOR`;

CREATE TABLE `TB_BLOG_MODERADOR` (
  `ID_MODERADOR` INTEGER NOT NULL, 
  `ID_BLOG` INTEGER NOT NULL, 
  `DS_TITULO` VARCHAR(200), 
  `DT_BLOG` DATETIME, 
  `HR_BLOG` VARCHAR(8), 
  `DS_TEXTO_BLOG` LONGTEXT, 
  INDEX (`DT_BLOG`, `HR_BLOG`, `ID_MODERADOR`, `ID_BLOG`), 
  PRIMARY KEY (`ID_MODERADOR`, `ID_BLOG`)
) ENGINE=myisam;

#
# Table structure for table 'TB_COMENTARIO_BLOG'
#

DROP TABLE IF EXISTS `TB_COMENTARIO_BLOG`;

CREATE TABLE `TB_COMENTARIO_BLOG` (
  `ID_COMENTARIO` INTEGER NOT NULL AUTO_INCREMENT, 
  `ID_MODERADOR` INTEGER, 
  `ID_BLOG` INTEGER, 
  `ID_USUARIO` INTEGER, 
  `DT_COMENTARIO` DATETIME, 
  `HR_COMENTARIO` VARCHAR(8), 
  `DS_COMENTARIO` LONGTEXT, 
  `PSN_ID_TIME_ATUAL` VARCHAR(80), 
  INDEX (`ID_MODERADOR`, `ID_BLOG`, `ID_USUARIO`, `DT_COMENTARIO`, `HR_COMENTARIO`), 
  INDEX (`ID_MODERADOR`, `DT_COMENTARIO`, `HR_COMENTARIO`), 
  INDEX (`ID_BLOG`), 
  PRIMARY KEY (`ID_COMENTARIO`)
) ENGINE=myisam;

#
# Table structure for table 'TB_USUARIO'
#

DROP TABLE IF EXISTS `TB_USUARIO`;

CREATE TABLE `TB_USUARIO` (
  `ID_USUARIO` INTEGER NOT NULL DEFAULT 0, 
  `NM_USUARIO` VARCHAR(50) NOT NULL, 
  `PSN_ID` VARCHAR(30) NOT NULL, 
  `IN_USUARIO_ATIVO` TINYINT(1) NOT NULL, 
  `IN_USUARIO_MODERADOR` TINYINT(1) NOT NULL, 
  `DS_EMAIL` VARCHAR(80), 
  `DT_CADASTRO` DATETIME NOT NULL, 
  PRIMARY KEY (`ID_USUARIO`), 
  INDEX (`NM_USUARIO`)
) ENGINE=myisam;

