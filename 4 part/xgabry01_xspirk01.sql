-----------------------------------------------
---- SQL SCRIPT -> THIRD PART OF PROJECT  ----
-- Autor: Marek Spirka -- xlogin: xspirk01 ----
-- Autor: Adam Gabrys  -- xlogin: xgabry01 ----
-----------------------------------------------

----------------DROP TABLES--------------------

DROP TABLE aplikace CASCADE CONSTRAINTS;
DROP TABLE verze CASCADE CONSTRAINTS;
DROP TABLE organizace CASCADE CONSTRAINTS;
DROP TABLE zamestnanec CASCADE CONSTRAINTS;
DROP TABLE smlouva CASCADE CONSTRAINTS;
DROP TABLE manazer CASCADE CONSTRAINTS;
DROP TABLE vyvojar CASCADE CONSTRAINTS;
DROP TABLE doba_smlouvy CASCADE CONSTRAINTS;
DROP TABLE pocet_instalaci CASCADE CONSTRAINTS;

----------------MAKE TABLES--------------------

CREATE TABLE aplikace (
    id_aplikace INT GENERATED ALWAYS AS IDENTITY (START WITH 1 increment by 1) primary key,
    nazov VARCHAR(255) NOT NULL,
    popis VARCHAR(255),
    platforma VARCHAR(7) CHECK (platforma IN('IOS', 'Android', 'LINUX', 'Windows')),
    webstranka VARCHAR(255) NOT NULL
);

CREATE TABLE verze (
    id_verze INT GENERATED ALWAYS AS IDENTITY (START WITH 1 increment by 1) primary key,
    nazov VARCHAR(255) NOT NULL,
    popis VARCHAR(500) NOT NULL,
    datum_vydania DATE NOT NULL,
    id_aplikace INT NOT NULL,
    FOREIGN KEY (id_aplikace) REFERENCES aplikace(id_aplikace) ON DELETE CASCADE
);

CREATE TABLE organizace (
    ico varchar(20) NOT NULL CHECK (REGEXP_LIKE(ico,'^\d{8}$')) PRIMARY KEY , --regex na ICO
    obchodny_nazov VARCHAR(100) NOT NULL,
    sidlo VARCHAR(50) NOT NULL,
    pravna_forma VARCHAR(100) NOT NULL,
    predmet_podnikania VARCHAR(150) NOT NULL,
    iban  VARCHAR(30) NOT NULL CHECK (REGEXP_LIKE(iban, 'CZ\d{2}[ ]\d{4}[ ]\d{4}[ ]\d{4}[ ]\d{4}[ ]\d{4}|CZ\d{22}')) --check validný input pre IBAN
);

CREATE TABLE zamestnanec (
    rodne_cislo NUMBER(10) NOT NULL CHECK (REGEXP_LIKE(rodne_cislo, '\d{2}(0[1-9]|1[0-2]|5[1-9]|6[0-2])(0[1-9]|1[0-9]|2[0-9]|3[0-1])\d{3,4}')) PRIMARY KEY, --bez lomitka
    meno VARCHAR(50) NOT NULL,
    priezvisko VARCHAR(50) NOT NULL,
    telefon VARCHAR(20) NOT NULL CHECK (REGEXP_LIKE(telefon,'^\+\d{12}$')), --berieme s predvolbou bez pluska
    mail VARCHAR(50)
);

CREATE TABLE smlouva (
    id_zmluvy INT GENERATED ALWAYS AS IDENTITY (START WITH 1 increment by 1) primary key,
    datum_zavretia DATE NOT NULL,
    predavajuci VARCHAR(100) NOT NULL,
    kupujuci VARCHAR(100) NOT NULL
);

CREATE TABLE pocet_instalaci(
    pocet_instalaci INT NOT NULL,
    id_zmluvy INT PRIMARY KEY,
    id_verze INT,
    FOREIGN KEY (id_zmluvy) REFERENCES smlouva(id_zmluvy),
    FOREIGN KEY (id_verze) REFERENCES verze(id_verze)
);

CREATE TABLE doba_smlouvy (
    ucinost_od DATE NOT NULL,
    ucinost_do DATE NOT NULL,
    id_zmluvy INT PRIMARY KEY,
    rodne_cislo INT,
    FOREIGN KEY (id_zmluvy) REFERENCES smlouva(id_zmluvy),
    FOREIGN KEY (rodne_cislo) REFERENCES zamestnanec(rodne_cislo)
);

CREATE TABLE vyvojar (
    rodne_cislo NUMBER(10) NOT NULL PRIMARY KEY CHECK (REGEXP_LIKE(rodne_cislo, '\d{2}(0[1-9]|1[0-2]|5[1-9]|6[0-2])(0[1-9]|1[0-9]|2[0-9]|3[0-1])\d{3,4}')), --rodne cislo bez lomitku
    prog_jazyk VARCHAR(20),
    FOREIGN KEY (rodne_cislo) REFERENCES zamestnanec(rodne_cislo)
);

CREATE TABLE manazer (
    rodne_cislo NUMBER(10) NOT NULL PRIMARY KEY CHECK (REGEXP_LIKE(rodne_cislo, '\d{2}(0[1-9]|1[0-2]|5[1-9]|6[0-2])(0[1-9]|1[0-9]|2[0-9]|3[0-1])\d{3,4}')), --rodne cislo bez lomitku
    oddeleni VARCHAR(25) CHECK (oddeleni IN('Vyvojarske oddeleni', 'Logistika a prodej', 'Technicke oddeleni', 'Financni oddeleni', 'Oddeleni planovani', 'Testovaci oddeleni')),
    FOREIGN KEY (rodne_cislo) REFERENCES zamestnanec(rodne_cislo)
);
-------------------Triggers------------------------

/*
This trigger checks whether a new or updated row in the aplikace table has a platforma value of 'LINUX',
and if it does, it checks that the webstranka column contains the substring '.linux'.
If the webstranka value is invalid, it raises an error with a custom error message (-20001).
This trigger can help ensure data integrity and prevent incorrect data from being inserted or updated in the aplikace table.
*/

DROP SEQUENCE new_id_facebook;

CREATE SEQUENCE new_id_facebook;

CREATE OR REPLACE TRIGGER aplikace_platforma_trigger
BEFORE INSERT OR UPDATE ON aplikace
FOR EACH ROW
BEGIN
  IF (:NEW.platforma = 'LINUX' AND :NEW.webstranka NOT LIKE '%.linux%') THEN
    RAISE_APPLICATION_ERROR(-20001, 'Invalid webstranka for LINUX aplikace');
  END IF;
END;
/

/* this should raise an error ORA-20001: Invalid webstranka for LINUX aplikace */

/*
INSERT INTO aplikace (nazov, popis, platforma, webstranka) 
VALUES ('myapp', 'myapp description', 'LINUX', 'http://www.myapp.com');
*/

/*this shouldnt raise error*/
INSERT INTO aplikace (nazov, popis, platforma, webstranka) 
VALUES ('myapp2', 'myapp2 description', 'LINUX', 'http://www.myapp2.linux.com');

/*check if prevent_delte trigger exists*/
SELECT trigger_name, table_name, status
FROM user_triggers
WHERE trigger_name = 'PREVENT_DELETE';


/*Trigger to prevent deleting a version that has been used in a contract:*/
CREATE OR REPLACE TRIGGER prevent_delete
BEFORE DELETE ON verze
FOR EACH ROW
DECLARE
  l_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_count
  FROM pocet_instalaci
  WHERE id_verze = :old.id_verze
    AND id_zmluvy IS NOT NULL;

  IF l_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'This version cannot be deleted because it has been used in a contract.');
  END IF;
END;
/

/*this should raise this error:
ORA-20001: This version cannot be deleted because it has been used in a contract.
ORA-06512: at "YOUR_SCHEMA_NAME.PREVENT_DELETE", line 10
ORA-04088: error during execution of trigger 'YOUR_SCHEMA_NAME.PREVENT_DELETE'
*/


----------------INPUT TO TABLES--------------------

INSERT INTO zamestnanec VALUES(3002056954, 'adam', 'Novak', '+420056789012', 'adamko@gmail.com');
INSERT INTO zamestnanec VALUES(1202316955, 'marek', 'Hess', '+420654000012', 'marek123@gmail.com');
INSERT INTO zamestnanec VALUES(2402056966, 'jan', 'Plecko', '+420356789012', 'plec123@gmail.com');
INSERT INTO zamestnanec VALUES(2902316977, 'tomas', 'Hecko', '+456456789012', 'marek456@gmail.com');
INSERT INTO zamestnanec VALUES(2402056986, 'janek', 'Plecko', '+420756789012', 'janek@gmail.com');
INSERT INTO zamestnanec VALUES(3002316977, 'jarek', 'Hecko', '+789654000012', 'marek789@gmail.com');


INSERT INTO vyvojar(rodne_cislo, prog_jazyk) VALUES(3002056954, 'Python');
INSERT INTO vyvojar(rodne_cislo, prog_jazyk) VALUES(2402056966, 'PHP');


INSERT INTO manazer(rodne_cislo, oddeleni) VALUES(2402056966, 'Logistika a prodej');
INSERT INTO manazer(rodne_cislo, oddeleni) VALUES(3002316977, 'Vyvojarske oddeleni');


INSERT INTO aplikace(nazov, popis, platforma, webstranka) VALUES('firstapp', 'krasna appka', 'IOS', 'firstapp.com');
INSERT INTO aplikace(nazov, popis, platforma, webstranka) VALUES('secondapp', 'vyborna appka', 'Android', 'secondtapp.com');
INSERT INTO aplikace(nazov, popis, platforma, webstranka) VALUES('thirdapp', 'mobilni appka', 'Android', 'thirdapp.com');


INSERT INTO verze(nazov, popis, datum_vydania, id_aplikace) VALUES('v2', 'edited config',TO_DATE('24-03-2006', 'DD-MM-YYYY'), 2);
INSERT INTO verze(nazov, popis, datum_vydania, id_aplikace) VALUES('v3.4', 'for config', TO_DATE('21-03-2021', 'DD-MM-YYYY'), 1);
INSERT INTO verze(nazov, popis, datum_vydania, id_aplikace) VALUES('v9.4', 'final version',TO_DATE('21-03-2023', 'DD-MM-YYYY'), 3);


INSERT INTO smlouva(DATUM_ZAVRETIA, PREDAVAJUCI, KUPUJUCI) VALUES(TO_DATE('24-04-2015', 'DD-MM-YYYY'), 'adam', 'marek');
INSERT INTO smlouva(DATUM_ZAVRETIA, PREDAVAJUCI, KUPUJUCI) VALUES(TO_DATE('24-04-2015', 'DD-MM-YYYY'), 'adam', 'jozef');
INSERT INTO smlouva(DATUM_ZAVRETIA, PREDAVAJUCI, KUPUJUCI) VALUES(TO_DATE('20-04-2015', 'DD-MM-YYYY'), 'adam', 'anicka');
INSERT INTO smlouva(DATUM_ZAVRETIA, PREDAVAJUCI, KUPUJUCI) VALUES(TO_DATE('04-06-2016', 'DD-MM-YYYY'), 'marek', 'adam');


INSERT INTO doba_smlouvy(UCINOST_OD, UCINOST_DO, ID_ZMLUVY, RODNE_CISLO) VALUES(TO_DATE('24-04-2015', 'DD-MM-YYYY'),TO_DATE('24-04-2022', 'DD-MM-YYYY'), 1, 3002056954);
INSERT INTO doba_smlouvy(UCINOST_OD, UCINOST_DO, ID_ZMLUVY, RODNE_CISLO) VALUES(TO_DATE('26-02-2012', 'DD-MM-YYYY'),TO_DATE('21-12-2032', 'DD-MM-YYYY'), 2, 2402056966);
INSERT INTO doba_smlouvy(UCINOST_OD, UCINOST_DO, ID_ZMLUVY, RODNE_CISLO) VALUES(TO_DATE('26-02-2012', 'DD-MM-YYYY'),TO_DATE('21-12-2032', 'DD-MM-YYYY'), 3, 3002316977);


INSERT INTO ORGANIZACE(ICO, OBCHODNY_NAZOV, SIDLO, PRAVNA_FORMA, PREDMET_PODNIKANIA, IBAN)
VALUES('12345678', 'Facebook', 'Amsterdam', 'Vedecka', 'vyvoj umele inteligence','CZ12 3456 7890 1234 5678 9012');
INSERT INTO ORGANIZACE(ICO, OBCHODNY_NAZOV, SIDLO, PRAVNA_FORMA, PREDMET_PODNIKANIA, IBAN)
VALUES('87654321', 'Google', 'Amsterdam', 's.r.o.', 'vyvoj regexu','CZ34 5634 7890 1234 5678 9012');


INSERT INTO pocet_instalaci(pocet_instalaci, ID_ZMLUVY, ID_VERZE) VALUES(10000, 1, 1);
INSERT INTO pocet_instalaci(pocet_instalaci, ID_ZMLUVY, ID_VERZE) VALUES(200000, 2, 2);
INSERT INTO pocet_instalaci(pocet_instalaci, ID_ZMLUVY, ID_VERZE) VALUES(1000000, 3, 3);

COMMIT;

----TRIGGER DELETE CHECK----
-- This should raise an error message due to the prevent_delete trigger
--DELETE FROM verze WHERE id_verze = 3;


EXPLAIN PLAN FOR
SELECT z.RODNE_CISLO AS RODNE_CISLO, z.MENO AS meno, z.telefon AS telefon, COUNT(v.RODNE_CISLO) AS VYVOJAR
FROM ZAMESTNANEC z JOIN VYVOJAR v ON z.RODNE_CISLO = v.RODNE_CISLO
WHERE z.telefon LIKE '+420%' AND v.prog_jazyk = 'Python'
GROUP BY z.RODNE_CISLO, z.MENO, z.telefon
HAVING COUNT(v.RODNE_CISLO) > 0
ORDER BY z.RODNE_CISLO;

SELECT * FROM TABLE(dbms_xplan.display);

CREATE INDEX tel_zamestanec ON ZAMESTNANEC (telefon);

EXPLAIN PLAN FOR
SELECT z.RODNE_CISLO AS RODNE_CISLO, z.MENO AS meno, z.telefon AS telefon, COUNT(v.RODNE_CISLO) AS VYVOJAR
FROM ZAMESTNANEC z JOIN VYVOJAR v ON z.RODNE_CISLO = v.RODNE_CISLO
WHERE z.telefon LIKE '+420%' AND v.prog_jazyk = 'Python'
GROUP BY z.RODNE_CISLO, z.MENO, z.telefon 
HAVING COUNT(v.RODNE_CISLO) > 0
ORDER BY z.RODNE_CISLO;

SELECT * FROM TABLE(dbms_xplan.display);




--1. Vypise zamestnanca spolu s programovacim jazykom, ktory ovlada
SELECT meno, priezvisko, prog_jazyk AS Jazyk
FROM zamestnanec NATURAL JOIN vyvojar;

--2. Vypis verzii, ich datum vydania a naslede maximalny pocet instalacii
SELECT verze.nazov Verzia, verze.datum_vydania, pocet_instalaci.pocet_instalaci
FROM pocet_instalaci INNER JOIN verze ON pocet_instalaci.id_verze = verze.id_verze;

--3. Ake aplikacie boli vytvorene pre android? (nazov aplikacie, verzia, pocet instalacii)
SELECT A.nazov, V.nazov Verzia, V.datum_vydania , pocet_instalaci
FROM aplikace A, verze V, pocet_instalaci P
WHERE A.id_aplikace = V.id_aplikace AND V.id_verze = P.id_verze AND A.platforma='Android';

--4. Kolko zmluv podpisali zamestnanci s rovnakym krstnym menom? (Pocet, pocet_stiahnutia)
SELECT meno, telefon, COUNT(*) Pocet_podpisov
FROM zamestnanec Z, smlouva S
WHERE Z.meno=S.predavajuci GROUP BY meno, telefon;

--5. Vypise zamestnancov, ktory nezacali pracovat pre firmu v rozmedzi  12.08.2012 - 32.12.2024 (meno, priezvisko, mail)
SELECT meno, priezvisko, mail
FROM zamestnanec
WHERE NOT EXISTS(SELECT * FROM doba_smlouvy D WHERE zamestnanec.rodne_cislo = D.rodne_cislo AND ucinost_od BETWEEN TO_DATE('01-01-2012', 'DD-MM-YYYY') AND TO_DATE('31-12-2014', 'DD-MM-YYYY'));

--6. Vraci vsechny zamestnance, kteri jsou Python vyvojari podle rodneho cisla (dotaz s predikatem IN s vnorenym selectem)
SELECT * FROM zamestnanec
WHERE rodne_cislo IN (
    SELECT rodne_cislo FROM vyvojar
    WHERE prog_jazyk = 'Python'     --second condition
);

--7. Zobraz pocet aplikaci podle platfo@rmy a zobraz posledni verzi aplikace(2. GROUP BY, agregacni funkce)
SELECT aplikace.platforma, COUNT(*) AS pocet_aplikacii, MAX(verze.datum_vydania) AS posledna_verzia
FROM aplikace
JOIN verze ON aplikace.id_aplikace = verze.id_aplikace
GROUP BY aplikace.platforma;
