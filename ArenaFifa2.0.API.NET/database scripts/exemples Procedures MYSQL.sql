USE `arena_clashes`;

DELIMITER $$
CREATE PROCEDURE `spAddEmployee`(    
    pName VARCHAR(20),     
    pCity VARCHAR(20),    
    pDepartment VARCHAR(20),    
    pGender VARCHAR(6)    
)
Begin     
    Insert into tblEmployee (Name,City,Department, Gender)     
    Values (pName,pCity,pDepartment, pGender);    
End$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `spDeleteEmployee`(      
   pEmpId int      
)
begin      
   Delete from tblEmployee where EmployeeId=pEmpId;      
End$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `spGetAllEmployees`()
begin      
   select * from tblEmployee;      
End$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE `spUpdateEmployee`(      
   pEmpId INTEGER ,    
   pName VARCHAR(20),     
   pCity VARCHAR(20),    
   pDepartment VARCHAR(20),    
   pGender VARCHAR(6)    
)
begin      
   Update tblEmployee       
   set Name=pName,      
   City=pCity,      
   Department=pDepartment,    
   Gender=pGender      
   where EmployeeId=pEmpId;    
End$$
DELIMITER ;


