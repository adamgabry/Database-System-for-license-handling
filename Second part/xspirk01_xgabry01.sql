-----------------------------------------------
---- SQL SCRIPT -> SECOND PART OF PROJECT  ----
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
    datum_vydania VARCHAR(8) NOT NULL CHECK (REGEXP_LIKE(datum_vydania,'^(0?[1-9]|[1-2][0-9]|3[0-1])-(0?[1-9]|1[0-2])-(\d{4})$')),
    aplikace_id INT NOT NULL,
    FOREIGN KEY (aplikace_id) REFERENCES aplikace ON DELETE CASCADE
);


CREATE TABLE organizace (
    ico varchar(20) NOT NULL CHECK (REGEXP_LIKE(ico,'^\d{8}$')) PRIMARY KEY ,
    obchodny_nazov VARCHAR(100) NOT NULL,
    sidlo VARCHAR(50) NOT NULL,
    pravna_forma VARCHAR(100) NOT NULL,
    predmet_podnikania VARCHAR(150) NOT NULL,
    iban  VARCHAR(29) NOT NULL CHECK (REGEXP_LIKE(iban, 'CZ\d{2}[ ]\d{4}[ ]\d{4}[ ]\d{4}[ ]\d{4}[ ]\d{4}|CZ\d{22}'))
);

CREATE TABLE zamestnanec (
    rodne_cislo NUMBER(10) NOT NULL PRIMARY KEY,
    meno VARCHAR(50) NOT NULL,
    priezvisko VARCHAR(50) NOT NULL,
    tel_cislo NUMBER(12) NOT NULL , --berieme s predvolbou bez pluska
    mail VARCHAR(50)
);

CREATE TABLE smlouva (
    id_zmluvy INT GENERATED ALWAYS AS IDENTITY (START WITH 1 increment by 1) primary key,
    datum_zavretia VARCHAR(8) NOT NULL CHECK (REGEXP_LIKE(datum_zavretia,'^(0?[1-9]|[1-2][0-9]|3[0-1])-(0?[1-9]|1[0-2])-(\d{4})$')),  --   DD-MM-YYYY
    ucinost_od VARCHAR(8) NOT NULL CHECK (REGEXP_LIKE(ucinost_od,'^(0?[1-9]|[1-2][0-9]|3[0-1])-(0?[1-9]|1[0-2])-(\d{4})$')),
    ucinost_do VARCHAR(8) NOT NULL CHECK (REGEXP_LIKE(ucinost_do,'^(0?[1-9]|[1-2][0-9]|3[0-1])-(0?[1-9]|1[0-2])-(\d{4})$')),
    predavajuci VARCHAR(100) NOT NULL,
    kupujuci VARCHAR(100) NOT NULL
);

CREATE TABLE vyvojar (
    id_vyvojar INT GENERATED ALWAYS AS IDENTITY (START WITH 1 increment by 1) primary key,
    prog_jazyk VARCHAR(20),
    FOREIGN KEY (id_vyvojar) REFERENCES zamestnanec(rodne_cislo)
);


CREATE TABLE manazer (
    id_manazer INT GENERATED ALWAYS AS IDENTITY (START WITH 1 increment by 1) primary key,
    oddelenie VARCHAR(7) CHECK (oddelenie IN('Vývojářske oddělení', 'Logistika a prodej', 'Technické oddělení', 'Finanční oddělení', 'Oddelenie plánování', 'Testovací oddělení')),
    FOREIGN KEY (id_manazer) REFERENCES zamestnanec(rodne_cislo)
);





