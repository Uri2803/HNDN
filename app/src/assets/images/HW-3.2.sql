-- 21127328 - Cao Tuan Kiet -- 
-- HW 3.2 
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
-- Cau 1: Xoa user neu ton tai va tao user, phan quyen cho cac user
DROP USER John;
CREATE USER John IDENTIFIED BY JOHN;
ALTER USER John DEFAULT TABLESPACE SYSTEM QUOTA 10M ON SYSTEM;

DROP USER Joe;
CREATE USER Joe IDENTIFIED BY JOE;
ALTER USER Joe DEFAULT TABLESPACE SYSTEM QUOTA 10M ON SYSTEM;

DROP USER Fred;
CREATE USER Fred IDENTIFIED BY FRED;
ALTER USER Fred DEFAULT TABLESPACE SYSTEM QUOTA 10M ON SYSTEM;

DROP USER Lynn;
CREATE USER Lynn IDENTIFIED BY LYNN;
ALTER USER Lynn DEFAULT TABLESPACE SYSTEM QUOTA 10M ON SYSTEM;

DROP USER Amy;
CREATE USER Amy IDENTIFIED BY AMY;
ALTER USER Amy DEFAULT TABLESPACE SYSTEM QUOTA 10M ON SYSTEM;

DROP USER Beth;
CREATE USER Beth IDENTIFIED BY BETH;
ALTER USER Beth DEFAULT TABLESPACE SYSTEM QUOTA 10M ON SYSTEM;

GRANT CREATE TABLE, CREATE SESSION TO John, Joe, Fred, Lynn, Amy, Beth;

-- Cau 2:
-- Xoa bang neu ton tai va tao bang moi
DROP TABLE Attendance;
CREATE TABLE Attendance(
    ID INT PRIMARY KEY,
    Name NVARCHAR2(255)
);

-- a) Tao cac role
DROP ROLE DataEntry;
CREATE ROLE DataEntry;

DROP ROLE Supervisor;
CREATE ROLE Supervisor;

DROP ROLE Management;
CREATE ROLE Management;

-- b) Cap role cho user
GRANT DataEntry TO John, Joe, Lynn;
GRANT Supervisor TO Fred;
GRANT Management TO Amy, Beth;

-- c) Cap quyen cho role
GRANT SELECT, INSERT, UPDATE ON sys.Attendance TO DataEntry;
GRANT SELECT, DELETE ON sys.Attendance TO Supervisor;
GRANT SELECT ON sys.Attendance TO Management;

-- d) Kiem tra ket qua phan quyen
--Role DataEntry
--Xem thanh cong
CONNECT Joe/JOE;
SELECT * FROM sys.Attendance;
--Them thanh cong
CONNECT Joe/JOE;
INSERT INTO sys.Attendance (ID, Name) VALUES(1, 'Joe');
--Xoa that bai
CONNECT Joe/JOE;
DELETE FROM sys.Attendance WHERE ID = 1;
--Sua thanh cong
CONNECT Joe/JOE;
UPDATE sys.Attendance SET Name= 'Kiet' WHERE ID = 1;

--Role Supervisor
--Xem thanh cong
CONNECT Fred/FRED;
SELECT * FROM sys.Attendance;
--Them that bai
CONNECT Fred/FRED;
INSERT INTO sys.Attendance (ID, Name) VALUES(2, 'Fred');
--Sua that bai
CONNECT Fred/FRED;
UPDATE sys.Attendance SET Name= 'Kiet' WHERE ID = 1;
--Xoa thanh cong
CONNECT Fred/FRED;
DELETE FROM sys.Attendance WHERE ID = 1;

--Role Management
--Xem thanh cong
CONNECT Beth/BETH;
SELECT * FROM sys.Attendance;
--Them that bai
CONNECT Beth/BETH;
INSERT INTO sys.Attendance (ID, Name) VALUES(3, 'Beth');
--Xoa that bai
CONNECT Beth/BETH;
DELETE FROM sys.Attendance WHERE ID = 1;
--Sua that bai
CONNECT Beth/BETH;
UPDATE sys.Attendance SET Name= 'Kiet' WHERE ID = 1;

-- Cau 3
--Tao user
DROP USER NameManager;
CREATE USER NameManager IDENTIFIED BY pc123;

--Cap quyen update tren view
GRANT CREATE SESSION, CREATE ANY TABLE TO NameManager;
GRANT UPDATE (Name) ON Attendance TO NameManager;

-- Cau 4
--Danh sach cac quyen co chu 'CONTEXT'
SELECT * FROM DBA_SYS_PRIVS WHERE PRIVILEGE LIKE '%CONTEXT%';
--Danh sach cac user co quyen 'SELECT ANY TABLE'
SELECT * FROM DBA_SYS_PRIVS WHERE PRIVILEGE='SELECT ANY TABLE';

-- Cau 5
--Them mat khau cho role DataEntry
ALTER ROLE DataEntry IDENTIFIED BY mgt;

--Cap quyen cho John co the cap quyen cho cac user khac
GRANT GRANT ANY PRIVILEGE TO John;
GRANT SELECT, INSERT, UPDATE on ATTENDANCE TO John WITH GRANT OPTION;

--Gan tat ca cac quyen cua John cho Beth
CREATE OR REPLACE PROCEDURE grant_privs_to_Beth AS
BEGIN
  FOR c_privs IN (SELECT privilege 
                  FROM sys.user_tab_privs 
                  WHERE table_name = 'ATTENDANCE' 
                  AND grantee = 'JOHN') LOOP
    EXECUTE IMMEDIATE 'GRANT ' || c_privs.privilege || ' ON ATTENDANCE TO Beth';
    DBMS_OUTPUT.PUT_LINE(c_privs.privilege);
  END LOOP;
END;
/

EXECUTE grant_privs_to_Beth;

-- Kiem tra quyen cua Beth sau khi duoc cap
CONNECT Beth/BETH;
INSERT INTO sys.Attendance (ID, Name) VALUES(3, 'Beth');

CONNECT Beth/BETH;
UPDATE sys.Attendance SET Name= 'Kiet' WHERE ID = 3;
--> Beth co quyen INSERT va UPDATE tren bang Attendance
