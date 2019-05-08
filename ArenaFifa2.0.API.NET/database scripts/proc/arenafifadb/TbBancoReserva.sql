USE `arenafifadb`;

DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllBancoReservaNoFilterCRUD` $$
CREATE PROCEDURE `spGetAllBancoReservaNoFilterCRUD`()
begin      
   select B.*, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO
   from TB_LISTA_BANCO_RESERVA B, TB_USUARIO U
   where B.DT_FIM IS NULL
   and B.ID_USUARIO = U.ID_USUARIO
   order by B.TP_BANCO_RESERVA DESC, B.IN_CONSOLE DESC, B.ID_BANCO_RESERVA;      
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllBancoReservaWithFilterCRUD` $$
CREATE PROCEDURE `spGetAllBancoReservaWithFilterCRUD`(pFilter VARCHAR(20))
begin      
   select B.*, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO
   from TB_LISTA_BANCO_RESERVA B, TB_USUARIO U
   where (U.NM_USUARIO like CONCAT('%',pFilter,'%') or B.NM_Time_FUT like CONCAT('%',pFilter,'%'))
   and  B.DT_FIM IS NULL
   and B.ID_USUARIO = U.ID_USUARIO
   order by B.TP_BANCO_RESERVA DESC, B.IN_CONSOLE DESC, B.ID_BANCO_RESERVA;      
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetAllBancoReservaByTipo` $$
CREATE PROCEDURE `spGetAllBancoReservaByTipo`(pTpBancoReserva VARCHAR(3))
begin      
   select B.*, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO, U.DS_EMAIL
   from TB_LISTA_BANCO_RESERVA B, TB_USUARIO U
   where B.TP_BANCO_RESERVA = pTpBancoReserva
   and  B.DT_FIM IS NULL
   and U.IN_USUARIO_ATIVO = true
   and U.IN_DESEJA_PARTICIPAR = 1
   and B.ID_USUARIO = U.ID_USUARIO
   order by B.ID_BANCO_RESERVA;      
End$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetBancoReserva` $$
CREATE PROCEDURE `spGetBancoReserva`(pIdBancoReserva INTEGER)
begin      
   select B.*, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO
   from TB_LISTA_BANCO_RESERVA B, TB_USUARIO U
   where B.ID_BANCO_RESERVA = pIdBancoReserva
   and B.ID_USUARIO = U.ID_USUARIO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spGetBancoReservaByTipo` $$
CREATE PROCEDURE `spGetBancoReservaByTipo`(pIdUsu INTEGER, pTpBancoReserva VARCHAR(3))
begin      
   select B.*, U.NM_USUARIO, U.PSN_ID, U.DS_ESTADO
   from TB_LISTA_BANCO_RESERVA B, TB_USUARIO U
   where B.ID_USUARIO = pIdUsu
   and B.TP_BANCO_RESERVA = pTpBancoReserva
   and B.DT_FIM IS NULL
   and B.ID_USUARIO = U.ID_USUARIO;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateToEndBancoReservaById` $$
CREATE PROCEDURE `spUpdateToEndBancoReservaById`(pIdBancoReserva INTEGER)
begin      
   update TB_LISTA_BANCO_RESERVA
   set DT_FIM = now()
   where ID_BANCO_RESERVA = pIdBancoReserva;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateToEndBancoReserva` $$
CREATE PROCEDURE `spUpdateToEndBancoReserva`(pIdUser INTEGER, PTpBco VARCHAR(5))
begin      
   update TB_LISTA_BANCO_RESERVA
   set DT_FIM = now()
   where id_usuario = pIdUser
   and DT_FIM IS NULL AND TP_BANCO_RESERVA = PTpBco;
End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spUpdateToEndBancoReservaByUsuario` $$
CREATE PROCEDURE `spUpdateToEndBancoReservaByUsuario`(pIdUsu INTEGER, pTpBancoReserva VARCHAR(3))
begin      
   update TB_LISTA_BANCO_RESERVA
   set DT_FIM = now()
   where ID_USUARIO = pIdUsu
   and TP_BANCO_RESERVA = pTpBancoReserva
   and DT_FIM IS NULL;
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
	   insert into TB_LISTA_BANCO_RESERVA (ID_USUARIO, TP_BANCO_RESERVA, NM_TIME_FUT, IN_CONSOLE, DT_INICIO)
	   values (pIdUsu, pTpBanco, pNmTime, 'PS4', now());
	END IF;

End$$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS `spAddBancoReservaToEndOfQueue` $$
CREATE PROCEDURE `spAddBancoReservaToEndOfQueue`(
	pIdBancoReserva INTEGER
)
begin      
	DECLARE _idUsu INTEGER DEFAULT NULL;
	DECLARE _nmTime VARCHAR(50) DEFAULT "";
	DECLARE _tpBanco VARCHAR(3) DEFAULT "";
	DECLARE _console VARCHAR(3) DEFAULT "";
	
	SELECT ID_USUARIO, TP_BANCO_RESERVA, NM_TIME_FUT, IN_CONSOLE into _idUsu, _tpBanco, _nmTime, _console
	FROM TB_LISTA_BANCO_RESERVA
	WHERE ID_BANCO_RESERVA = pIdBancoReserva;
	
	call `arenafifadb`.`spUpdateToEndBancoReservaByUsuario`(_idUsu, _tpBanco);

	insert into `TB_LISTA_BANCO_RESERVA` (ID_USUARIO, TP_BANCO_RESERVA, NM_TIME_FUT, IN_CONSOLE, DT_INICIO)
	values (_idUsu, _tpBanco, _nmTime, _console, now());
	
End$$
DELIMITER ;
