/* HW3.3 - Ora24 QLNhanSu
 * 21HTTT1 - ATBM-A-01
 *  + 21127004, Tran Nguyen An Phong   - 100%
 *      - Cau 3a, 3b, 3c
 *  + 21127135, Diep Huu Phuc          - 100%
 *      - Cau 4a, 4b, 4c
 *  + 21127149, Huynh Minh Quang       - 100%
 *      - Cau 1, 2, 3d
 *  + 21127296, Dang Ha Huy            - 100%
 *      - Cau 3e, 4d, 4e
 */
CL SCR;

/* KHOI TAO SCHEMA ATBMA01_QLNHANSU
 */
BEGIN EXECUTE IMMEDIATE 'DROP USER ATBMA01_QLNHANSU CASCADE';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -1918 THEN RAISE;
    END IF;
END;
/
CREATE USER ATBMA01_QLNHANSU IDENTIFIED BY 123;
GRANT DBA TO ATBMA01_QLNHANSU;
GRANT GRANT ANY ROLE TO ATBMA01_QLNHANSU;
ALTER SESSION SET CURRENT_SCHEMA = ATBMA01_QLNHANSU;

/* Cau 1: Tao cau truc va nhap du lieu.
 */
CREATE TABLE NHANVIEN(
    MANV VARCHAR2(6) PRIMARY KEY,
    MAPB INT,
    CHUCVU CHAR(2)
);

CREATE TABLE LUONG(
    MANV VARCHAR2(6),
    THANG NUMBER(2),
    LUONGCB INT,
    PHUCAP INT,
    TONGLUONG INT,

    CONSTRAINT PK_LUONG PRIMARY KEY(MANV, THANG),
    CONSTRAINT FK_LUONG_NHANVIEN
    FOREIGN KEY(MANV) REFERENCES NHANVIEN(MANV)
    ON DELETE CASCADE
);

CREATE TABLE TONGHOP(
    NAM INT,
    MAPB INT,
    THU INT,
    CHI INT,

    CONSTRAINT PK_TONGHOP PRIMARY KEY(NAM, MAPB)
);

INSERT INTO TONGHOP
    SELECT 2024, 100, 100, 100 FROM DUAL UNION ALL
    SELECT 2024, 200, 200, 200 FROM DUAL UNION ALL
    SELECT 2024, 300, 300, 300 FROM DUAL;

CREATE OR REPLACE PROCEDURE USP_NHANVIEN_GEN(
    RL VARCHAR2, PB INT, CAP INT, PB_STEP INT DEFAULT 0
) AS CPB INT; BEGIN
    CPB := PB;
    FOR IX IN 1..CAP LOOP
        CPB := CPB + PB_STEP;
        EXECUTE IMMEDIATE 'INSERT INTO NHANVIEN VALUES '
            || '(''' || RL || LPAD(IX, 4, '0') || ''', '
            || CPB || ', ''' || RL || ''')';
    END LOOP;
END;
/
-- 1 GIAM DOC (GD)
EXEC USP_NHANVIEN_GEN('GD', 1, 1);
-- 3 TRUONG PHONG (TP)
EXEC USP_NHANVIEN_GEN('TP', 100, 3, 100);
-- 10 NHAN VIEN KE TOAN (TO)
EXEC USP_NHANVIEN_GEN('TO', 100, 10);
-- 15 NHAN VIEN KE HOACH (HO)
EXEC USP_NHANVIEN_GEN('HO', 200, 15);
-- 10 NHAN VIEN KY THUAT (TH)
EXEC USP_NHANVIEN_GEN('TH', 300, 10);

/* Cau 2: Tao users
 */
DECLARE CURSOR CUR_NV IS (SELECT MANV FROM NHANVIEN
        WHERE MANV IN (SELECT USERNAME FROM ALL_USERS));
BEGIN
    FOR USR IN CUR_NV LOOP
        EXECUTE IMMEDIATE 'DROP USER ' || USR.MANV || ' CASCADE';
    END LOOP;
END;
/
DECLARE CURSOR CUR_NV IS (SELECT MANV FROM NHANVIEN
        WHERE MANV NOT IN (SELECT USERNAME FROM ALL_USERS));
BEGIN
    FOR USR IN CUR_NV LOOP
        EXECUTE IMMEDIATE 'CREATE USER ' || USR.MANV || ' IDENTIFIED BY 123';
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || USR.MANV;
    END LOOP;
END;
/

/* Cau 3: Dung cac lenh cap quyen va lay lai quyen (DAC).
 */
ALTER SESSION SET CURRENT_SCHEMA = ATBMA01_QLNHANSU;
CREATE OR REPLACE PROCEDURE USP_GRANT_ON_TABLE(
    RL VARCHAR2, XY CHAR, TAB VARCHAR2,
    COLS VARCHAR2 DEFAULT '', GR CHAR DEFAULT '0'
) AS CUR SYS_REFCURSOR; USR VARCHAR2(6); STR VARCHAR2(200);
BEGIN
    STR := 'GRANT ';
    IF SUBSTR(XY, 2) = '1' THEN
        STR := STR || 'SELECT';
        IF SUBSTR(XY, 1, 1) = '1' THEN
            STR := STR || ','; END IF;
    END IF;
    IF SUBSTR(XY, 1, 1) = '1' THEN
        IF COLS != '' THEN
            STR := STR || 'INSERT(' || COLS
                || '), UPDATE(' || COLS || '), DELETE';
        ELSE STR := STR || 'INSERT, UPDATE, DELETE'; END IF;
    END IF;
    STR := STR || ' ON ' || TAB;

    OPEN CUR FOR 'SELECT MANV FROM NHANVIEN
        WHERE MANV LIKE ''' || RL
        || '%'' AND MANV IN (SELECT USERNAME FROM ALL_USERS)';

    LOOP FETCH CUR INTO USR; EXIT WHEN CUR%NOTFOUND;
        IF GR != 0 THEN
            EXECUTE IMMEDIATE STR || ' TO ' || USR || ' WITH GRANT OPTION';
        ELSE EXECUTE IMMEDIATE STR || ' TO ' || USR;
        END IF;
    END LOOP; CLOSE CUR;
END;
/
-- a) Ket noi bang sys, cap quyen theo ma tran quyen truy xuat.
--  GIAM DOC (GD)
EXEC USP_GRANT_ON_TABLE('GD', '01', 'NHANVIEN');
EXEC USP_GRANT_ON_TABLE('GD', '01', 'LUONG');
EXEC USP_GRANT_ON_TABLE('GD', '11', 'TONGHOP', 'NAM,THU,CHI', '1');
--  TRUONG PHONG (TP)
EXEC USP_GRANT_ON_TABLE('TP', '11', 'NHANVIEN');
EXEC USP_GRANT_ON_TABLE('TP', '11', 'LUONG');
CREATE OR REPLACE VIEW V_TONGHOP_MAPB
AS SELECT MAPB FROM TONGHOP WITH CHECK OPTION;
EXEC USP_GRANT_ON_TABLE('TP', '11', 'V_TONGHOP_MAPB');
-- NHAN VIEN KE TOAN (TO)
EXEC USP_GRANT_ON_TABLE('TO', '01', 'NHANVIEN');
CREATE OR REPLACE VIEW V_LUONG_MANV
AS SELECT MANV FROM LUONG;
EXEC USP_GRANT_ON_TABLE('TO', '01', 'V_LUONG_MANV');
EXEC USP_GRANT_ON_TABLE('TO', '01', 'V_TONGHOP_MAPB');
-- NHAN VIEN KE HOACH (HO)
EXEC USP_GRANT_ON_TABLE('HO', '01', 'NHANVIEN');
EXEC USP_GRANT_ON_TABLE('HO', '01', 'V_LUONG_MANV');
EXEC USP_GRANT_ON_TABLE('HO', '01', 'V_TONGHOP_MAPB');
-- NHAN VIEN KY THUAT (TH)
EXEC USP_GRANT_ON_TABLE('TH', '01', 'NHANVIEN');
EXEC USP_GRANT_ON_TABLE('TH', '01', 'V_LUONG_MANV');
EXEC USP_GRANT_ON_TABLE('TH', '01', 'V_TONGHOP_MAPB');

-- b) Ket noi bang Giam doc, cap quyen Doc tren TONGHOP cho truong phong.
CONN GD0001/123@LOCALHOST:1521/XEPDB1;
GRANT SELECT ON ATBMA01_QLNHANSU.TONGHOP
    TO TP0001, TP0002, TP0003 WITH GRANT OPTION;
-- c) Ket noi bang Truong phong, cap quyen Doc tren TONGHOP cho nhan vien
--  trong phong.
CONN TP0001/123@LOCALHOST:1521/XEPDB1;
DECLARE CUR SYS_REFCURSOR; USR VARCHAR2(6);
BEGIN
    OPEN CUR FOR 'SELECT MANV FROM ATBMA01_QLNHANSU.NHANVIEN '
        || 'WHERE CHUCVU = ''TO'' AND MANV IN (SELECT USERNAME FROM ALL_USERS)';
    LOOP FETCH CUR INTO USR; EXIT WHEN CUR%NOTFOUND;
        EXECUTE IMMEDIATE 'GRANT SELECT ON ATBMA01_QLNHANSU.TONGHOP '
            || 'TO ' || USR;
    END LOOP; CLOSE CUR;
END;
/
CONN TP0002/123@LOCALHOST:1521/XEPDB1;
DECLARE CUR SYS_REFCURSOR; USR VARCHAR2(6);
BEGIN
    OPEN CUR FOR 'SELECT MANV FROM ATBMA01_QLNHANSU.NHANVIEN '
        || 'WHERE CHUCVU = ''HO'' AND MANV IN (SELECT USERNAME FROM ALL_USERS)';
    LOOP FETCH CUR INTO USR; EXIT WHEN CUR%NOTFOUND;
        EXECUTE IMMEDIATE 'GRANT SELECT ON ATBMA01_QLNHANSU.TONGHOP '
            || 'TO ' || USR;
    END LOOP; CLOSE CUR;
END;
/
CONN TP0003/123@LOCALHOST:1521/XEPDB1;
DECLARE CUR SYS_REFCURSOR; USR VARCHAR2(6);
BEGIN
    OPEN CUR FOR 'SELECT MANV FROM ATBMA01_QLNHANSU.NHANVIEN '
        || 'WHERE CHUCVU = ''TH'' AND MANV IN (SELECT USERNAME FROM ALL_USERS)';
    LOOP FETCH CUR INTO USR; EXIT WHEN CUR%NOTFOUND;
        EXECUTE IMMEDIATE 'GRANT SELECT ON ATBMA01_QLNHANSU.TONGHOP '
            || 'TO ' || USR;
    END LOOP; CLOSE CUR;
END;
/
-- d) Ket noi bang Giam doc, lay lai quyen Doc tren thuoc tinh Chi cua cac
--  truong phong.
CONN GD0001/123@LOCALHOST:1521/XEPDB1;
REVOKE SELECT ON ATBMA01_QLNHANSU.TONGHOP FROM TP0001, TP0002, TP0003;
-- Khong the thuc hien REVOKE SELECT(Chi). Tuy nhien, gia su neu co the,
--  khi do cac nhan vien cung se mat quyen Doc tren Chi.

-- e) Ve lai ma tran quyen truy xuat sau khi da thuc hien cac lenh cap
--  quyen va lay lai quyen theo yeu cau.
/* Ma tran duoc ve voi gia dinh thuc hien duoc yeu cau d).
 *              MANV   MAPB   CHUCVU   THANG   LUONGCB   PHUCAP   TONGLUONG   NAM   THU   CHI
 *  GIAMDOC      01     01      01       01      01        01        01       11    11    11
 *  TRUONGPHONG  11     11      11       11      11        11        11       01    01    00
 *  NHANVIEN     01     01      01       00      00        00        00       01    01    00
 */

/* Cau 4: Dung co che RBAC thuc hien lai cac yeu cau o cau 3.
 */
CONN SYS@LOCALHOST:1521/XEPDB1 AS SYSDBA;
ALTER SESSION SET CURRENT_SCHEMA = ATBMA01_QLNHANSU;
-- DROP ROLES
BEGIN
    EXECUTE IMMEDIATE 'DROP ROLE RL_ATBMA01_TP';
    EXECUTE IMMEDIATE 'DROP ROLE RL_ATBMA01_NV';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -1919 THEN RAISE; END IF;
END;
/
CREATE OR REPLACE PROCEDURE USP_ASSIGN_ROLE(
    RL VARCHAR2, WHO VARCHAR2, TAB VARCHAR2, COLN VARCHAR2
) AS CUR SYS_REFCURSOR; USR VARCHAR2(7);
BEGIN
    OPEN CUR FOR 'SELECT ' || COLN || ' FROM ' || TAB
        || ' WHERE ' || COLN || ' LIKE ''' || WHO || '%'' AND '
        || COLN || ' IN (SELECT USERNAME FROM ALL_USERS)';
    LOOP
        FETCH CUR INTO USR;
        EXIT WHEN CUR%NOTFOUND;
        EXECUTE IMMEDIATE 'GRANT RL_ATBMA01_' || RL || ' TO ' || USR;
    END LOOP;
    CLOSE CUR;
END;
/
-- a) Ket noi bang sys, cap quyen theo ma tran quyen truy xuat.
--  GIAM DOC (GD)
EXEC USP_GRANT_ON_TABLE('GD', '01', 'NHANVIEN');
EXEC USP_GRANT_ON_TABLE('GD', '01', 'LUONG');
EXEC USP_GRANT_ON_TABLE('GD', '11', 'TONGHOP', 'NAM,THU,CHI', '1');
--  TRUONG PHONG (TP)
CREATE OR REPLACE VIEW V_TONGHOP_MAPB
AS SELECT MAPB FROM TONGHOP WITH CHECK OPTION;

CREATE ROLE RL_ATBMA01_TP;
GRANT SELECT, INSERT, UPDATE, DELETE ON NHANVIEN TO RL_ATBMA01_TP;
GRANT SELECT, INSERT, UPDATE, DELETE ON LUONG TO RL_ATBMA01_TP;
GRANT SELECT, INSERT, UPDATE, DELETE ON V_TONGHOP_MAPB TO RL_ATBMA01_TP;
GRANT RL_ATBMA01_TP TO TP0001, TP0002, TP0003;
-- NHAN VIEN (TO, HO, TH)
CREATE OR REPLACE VIEW V_LUONG_MANV AS SELECT MANV FROM LUONG;

CREATE ROLE RL_ATBMA01_NV;
GRANT SELECT ON NHANVIEN TO RL_ATBMA01_NV;
GRANT SELECT ON V_LUONG_MANV TO RL_ATBMA01_NV;
GRANT SELECT ON V_TONGHOP_MAPB TO RL_ATBMA01_NV;
EXEC USP_ASSIGN_ROLE('NV', 'TO', 'NHANVIEN', 'MANV');
EXEC USP_ASSIGN_ROLE('NV', 'TH', 'NHANVIEN', 'MANV');
EXEC USP_ASSIGN_ROLE('NV', 'HO', 'NHANVIEN', 'MANV');

-- b) Ket noi bang Giam doc, cap quyen Doc tren TONGHOP cho truong phong.
CONN GD0001/123@LOCALHOST:1521/XEPDB1;
GRANT SELECT ON ATBMA01_QLNHANSU.TONGHOP
    TO TP0001, TP0002, TP0003 WITH GRANT OPTION;
-- c) Ket noi bang Truong phong, cap quyen Doc tren TONGHOP cho nhan vien
--  trong phong.
CONN TP0001/123@LOCALHOST:1521/XEPDB1;
GRANT SELECT ON ATBMA01_QLNHANSU.TONGHOP TO RL_ATBMA01_NV;
-- d) Ket noi bang Giam doc, lay lai quyen Doc tren thuoc tinh Chi cua cac
--  truong phong.
CONN GD0001/123@LOCALHOST:1521/XEPDB1;
REVOKE SELECT ON ATBMA01_QLNHANSU.TONGHOP FROM TP0001, TP0002, TP0003;
-- Khong the thuc hien REVOKE SELECT(Chi). Tuy nhien, gia su neu co the,
--  khi do cac nhan vien cung se mat quyen Doc tren Chi.

-- e) Ve lai ma tran quyen truy xuat sau khi da thuc hien cac lenh cap
--  quyen va lay lai quyen theo yeu cau.
/* Ma tran duoc ve voi gia dinh thuc hien duoc yeu cau d).
 *              MANV   MAPB   CHUCVU   THANG   LUONGCB   PHUCAP   TONGLUONG   NAM   THU   CHI
 *  GIAMDOC      01     01      01       01      01        01        01       11    11    11
 *  TRUONGPHONG  11     11      11       11      11        11        11       01    01    00
 *  NHANVIEN     01     01      01       00      00        00        00       01    01    00
 */
