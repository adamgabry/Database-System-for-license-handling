-----------------------------------------------
---- SQL SCRIPT -> SECOND PART OF PROJECT  ----
-- Autor: Marek Spirka -- xlogin: xspirk01 ----
-- Autor: Adam Gabrys  -- xlogin: xgabry01 ----
-----------------------------------------------

----------------DROP TABLES--------------------

DROP TABLE aplikace;
DROP TABLE verze;
DROP TABLE organizace;
DROP TABLE zamestanec;
DROP TABLE smlouva;
DROP TABLE manazer;
DROP TABLE vyvojar;

----------------MAKE TABLES--------------------

CREATE TABLE aplikace
(
    --tu bude ID
    nazov VARCHAR(255) NOT NULL,
    popis VARCHAR(255),
    platforma VARCHAR(255) NOT NULL,
    webstranka VARCHAR(255) NOT NULL,
)

