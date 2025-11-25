BEGIN;

-- Tables
CREATE TABLE rang (
    id INT,
    bezeichnung VARCHAR(50) NOT NULL
);

CREATE TABLE einsatzgebiet (
    id INT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE einheit (
    id INT,
    name VARCHAR(100) NOT NULL,
    parent_id INT
);

CREATE TABLE einheit_einsatzgebiet (
    einheit_id INT NOT NULL,
    einsatzgebiet_id INT NOT NULL,
    von DATE NOT NULL,
    bis DATE
);

CREATE TABLE mitglied (
    id INT,
    vorname VARCHAR(50) NOT NULL,
    nachname VARCHAR(50) NOT NULL,
    von DATE NOT NULL,
    bis DATE,
    parent_id INT
);

CREATE TABLE mitglied_rang (
    mitglied_id INT NOT NULL,
    rang_id INT NOT NULL,
    von DATE NOT NULL,
    bis DATE
);

CREATE TABLE mitglied_einheit (
    mitglied_id INT NOT NULL,
    einheit_id INT NOT NULL,
    von DATE NOT NULL,
    bis DATE,
    rolle VARCHAR(50)
);

-- Primary Keys
ALTER TABLE rang ADD PRIMARY KEY (id);
ALTER TABLE einsatzgebiet ADD PRIMARY KEY (id);
ALTER TABLE einheit ADD PRIMARY KEY (id);
ALTER TABLE mitglied ADD PRIMARY KEY (id);
ALTER TABLE einheit_einsatzgebiet ADD PRIMARY KEY (einheit_id, einsatzgebiet_id, von);
ALTER TABLE mitglied_rang ADD PRIMARY KEY (mitglied_id, rang_id, von);
ALTER TABLE mitglied_einheit ADD PRIMARY KEY (mitglied_id, einheit_id, von);

-- Foreign Keys
ALTER TABLE einheit
    ADD CONSTRAINT fk_einheit_parent
    FOREIGN KEY (parent_id) REFERENCES einheit(id)
    ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE einheit_einsatzgebiet
    ADD CONSTRAINT fk_eeg_einheit
    FOREIGN KEY (einheit_id) REFERENCES einheit(id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE einheit_einsatzgebiet
    ADD CONSTRAINT fk_eeg_gebiet
    FOREIGN KEY (einsatzgebiet_id) REFERENCES einsatzgebiet(id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE mitglied
    ADD CONSTRAINT fk_mitglied_parent
    FOREIGN KEY (parent_id) REFERENCES mitglied(id)
    ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE mitglied_rang
    ADD CONSTRAINT fk_mr_mitglied
    FOREIGN KEY (mitglied_id) REFERENCES mitglied(id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE mitglied_rang
    ADD CONSTRAINT fk_mr_rang
    FOREIGN KEY (rang_id) REFERENCES rang(id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE mitglied_einheit
    ADD CONSTRAINT fk_me_mitglied
    FOREIGN KEY (mitglied_id) REFERENCES mitglied(id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE mitglied_einheit
    ADD CONSTRAINT fk_me_einheit
    FOREIGN KEY (einheit_id) REFERENCES einheit(id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Inserts
INSERT INTO rang VALUES
(1,'Bundesminister/in für Landesverteidigung'),
(2,'General'),
(3,'Generalmajor'),
(4,'Brigadier'),
(5,'Oberst'),
(6,'Oberstleutnant'),
(7,'Major'),
(8,'Hauptmann'),
(9,'Oberleutnant'),
(10,'Leutnant'),
(11,'Wachtmeister'),
(12,'Zugsführer'),
(13,'Korporal'),
(14,'Gefreiter'),
(15,'Rekrut');

INSERT INTO einsatzgebiet VALUES
(1,'Heeresführung Wien'),
(2,'Garnison Graz'),
(3,'Militärkommando Salzburg'),
(4,'Kaserne Innsbruck'),
(5,'Einsatzbasis Allentsteig');

INSERT INTO einheit VALUES
(1,'Bundesministerium für Landesverteidigung', NULL),
(2,'Streitkräfteführungskommando', 1),
(3,'Landstreitkräftekommando', 2),
(4,'Luftstreitkräftekommando', 2),
(5,'1. Panzergrenadierbrigade', 3),
(6,'3. Jägerbrigade', 3),
(7,'Luftunterstützung', 4),
(8,'Fliegerabwehrbataillon', 4),
(9,'Militärakademie Wiener Neustadt', 1),
(10,'Nachrichtendienst Abt. I', 1);

INSERT INTO mitglied VALUES
(1,'Claudia','Tanner','2020-01-01',NULL,NULL),
(2,'Franz','Leitner','2020-01-01',NULL,1),
(3,'Michael','Bauer','2020-01-01',NULL,1),
(4,'Markus','Nehammer','2020-01-01',NULL,2),
(5,'Andreas','Pichler','2020-01-01',NULL,2),
(6,'Thomas','Gruber','2020-01-01',NULL,3),
(7,'Gerhard','Lenz','2020-01-01',NULL,3),
(8,'Lukas','Auer','2020-01-01',NULL,4),
(9,'Stefan','Huber','2020-01-01',NULL,4),
(10,'Peter','Koller','2020-01-01',NULL,5),
(11,'Johann','Mayer','2020-01-01',NULL,5),
(12,'Elisabeth','Weber','2020-01-01',NULL,6),
(13,'Christoph','Hauser','2020-01-01',NULL,6),
(14,'Martin','Wolf','2020-01-01',NULL,7),
(15,'Daniel','Eder','2020-01-01',NULL,7),
(16,'Patrick','Hofer','2020-01-01',NULL,8),
(17,'Julia','Grasl','2020-01-01',NULL,8),
(18,'Helmut','Fink','2020-01-01',NULL,9),
(19,'Karin','Lehner','2020-01-01',NULL,9),
(20,'David','Krenn','2020-01-01',NULL,10);

INSERT INTO mitglied_rang VALUES
(1,1,'2020-01-01',NULL),
(2,2,'2020-01-01',NULL),
(3,2,'2020-01-01',NULL),
(4,3,'2020-01-01',NULL),
(5,3,'2020-01-01',NULL),
(6,4,'2020-01-01',NULL),
(7,4,'2020-01-01',NULL),
(8,5,'2020-01-01',NULL),
(9,5,'2020-01-01',NULL),
(10,6,'2020-01-01',NULL),
(11,6,'2020-01-01',NULL),
(12,7,'2020-01-01',NULL),
(13,7,'2020-01-01',NULL),
(14,8,'2020-01-01',NULL),
(15,8,'2020-01-01',NULL),
(16,10,'2020-01-01',NULL),
(17,10,'2020-01-01',NULL),
(18,13,'2020-01-01',NULL),
(19,14,'2020-01-01',NULL),
(20,15,'2020-01-01',NULL);

INSERT INTO mitglied_einheit VALUES
(1,1,'2020-01-01',NULL,'Bundesministerin'),
(2,2,'2020-01-01',NULL,'Kommandant Streitkräfte'),
(3,3,'2020-01-01',NULL,'Chef Landstreitkräfte'),
(4,4,'2020-01-01',NULL,'Chef Luftstreitkräfte'),
(5,5,'2020-01-01',NULL,'Brigadekommandant'),
(6,6,'2020-01-01',NULL,'Brigadekommandant'),
(7,7,'2020-01-01',NULL,'Leiter Luftunterstützung'),
(8,8,'2020-01-01',NULL,'Kommandant Fliegerabwehr'),
(9,9,'2020-01-01',NULL,'Leiter Akademie'),
(10,10,'2020-01-01',NULL,'Leiter Nachrichtendienst'),
(11,5,'2020-01-01',NULL,'Zugskommandant'),
(12,6,'2020-01-01',NULL,'Zugskommandant'),
(13,7,'2020-01-01',NULL,'Technischer Offizier'),
(14,8,'2020-01-01',NULL,'Leutnant'),
(15,9,'2020-01-01',NULL,'Ausbildner'),
(16,5,'2020-01-01',NULL,'Soldat'),
(17,6,'2020-01-01',NULL,'Sanitäter'),
(18,8,'2020-01-01',NULL,'Gefreiter'),
(19,9,'2020-01-01',NULL,'Rekrut'),
(20,10,'2020-01-01',NULL,'Analyst');

COMMIT;