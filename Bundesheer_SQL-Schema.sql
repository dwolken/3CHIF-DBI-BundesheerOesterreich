DROP DATABASE IF EXISTS Bundesheer_DB;
CREATE DATABASE Bundesheer_DB;
USE Bundesheer_DB;

CREATE TABLE rang (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bezeichnung VARCHAR(50) NOT NULL
);

CREATE TABLE einsatzgebiet (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE einheit (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id INT,
    FOREIGN KEY (parent_id) REFERENCES einheit(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE einheit_einsatzgebiet (
    einheit_id INT NOT NULL,
    einsatzgebiet_id INT NOT NULL,
    von DATE NOT NULL,
    bis DATE,
    PRIMARY KEY (einheit_id, einsatzgebiet_id, von),
    FOREIGN KEY (einheit_id) REFERENCES einheit(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (einsatzgebiet_id) REFERENCES einsatzgebiet(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CHECK (bis IS NULL OR bis >= von)
);

CREATE TABLE mitglied (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vorname VARCHAR(50) NOT NULL,
    nachname VARCHAR(50) NOT NULL,
    von DATE NOT NULL,
    bis DATE,
    parent_id INT,
    FOREIGN KEY (parent_id) REFERENCES mitglied(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE mitglied_rang (
    mitglied_id INT NOT NULL,
    rang_id INT NOT NULL,
    von DATE NOT NULL,
    bis DATE,
    PRIMARY KEY (mitglied_id, rang_id, von),
    FOREIGN KEY (mitglied_id) REFERENCES mitglied(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (rang_id) REFERENCES rang(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CHECK (bis IS NULL OR bis >= von)
);

CREATE TABLE mitglied_einheit (
    mitglied_id INT NOT NULL,
    einheit_id INT NOT NULL,
    von DATE NOT NULL,
    bis DATE,
    rolle VARCHAR(50),
    PRIMARY KEY (mitglied_id, einheit_id, von),
    FOREIGN KEY (mitglied_id) REFERENCES mitglied(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (einheit_id) REFERENCES einheit(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CHECK (bis IS NULL OR bis >= von)
);

INSERT INTO rang (bezeichnung) VALUES
('Bundesminister/in für Landesverteidigung'),
('General'),
('Generalmajor'),
('Brigadier'),
('Oberst'),
('Oberstleutnant'),
('Major'),
('Hauptmann'),
('Oberleutnant'),
('Leutnant'),
('Wachtmeister'),
('Zugsführer'),
('Korporal'),
('Gefreiter'),
('Rekrut');

INSERT INTO einsatzgebiet (name) VALUES
('Heeresführung Wien'),
('Garnison Graz'),
('Militärkommando Salzburg'),
('Kaserne Innsbruck'),
('Einsatzbasis Allentsteig');

INSERT INTO einheit (id, name, parent_id) VALUES
(1, 'Bundesministerium für Landesverteidigung', NULL),
(2, 'Streitkräfteführungskommando', 1),
(3, 'Landstreitkräftekommando', 2),
(4, 'Luftstreitkräftekommando', 2),
(5, '1. Panzergrenadierbrigade', 3),
(6, '3. Jägerbrigade', 3),
(7, 'Luftunterstützung', 4),
(8, 'Fliegerabwehrbataillon', 4),
(9, 'Militärakademie Wiener Neustadt', 1),
(10, 'Nachrichtendienst Abt. I', 1);

INSERT INTO einheit_einsatzgebiet (einheit_id, einsatzgebiet_id, von, bis) VALUES
(1, 1, '2020-01-01', NULL),
(2, 1, '2020-02-01', NULL),
(3, 2, '2020-03-01', NULL),
(4, 3, '2020-03-01', NULL),
(5, 4, '2020-04-01', NULL),
(6, 4, '2020-04-01', NULL),
(7, 5, '2020-05-01', NULL),
(8, 5, '2020-05-01', NULL),
(9, 2, '2020-01-01', NULL),
(10, 1, '2020-01-01', NULL);

INSERT INTO mitglied (id, vorname, nachname, von, bis, parent_id) VALUES
(1, 'Claudia', 'Tanner', '2020-01-01', NULL, NULL),
(2, 'Franz', 'Leitner', '2020-01-01', NULL, 1),
(3, 'Michael', 'Bauer', '2020-01-01', NULL, 1),
(4, 'Markus', 'Nehammer', '2020-01-01', NULL, 2),
(5, 'Andreas', 'Pichler', '2020-01-01', NULL, 2),
(6, 'Thomas', 'Gruber', '2020-01-01', NULL, 3),
(7, 'Gerhard', 'Lenz', '2020-01-01', NULL, 3),
(8, 'Lukas', 'Auer', '2020-01-01', NULL, 4),
(9, 'Stefan', 'Huber', '2020-01-01', NULL, 4),
(10, 'Peter', 'Koller', '2020-01-01', NULL, 5),
(11, 'Johann', 'Mayer', '2020-01-01', NULL, 5),
(12, 'Elisabeth', 'Weber', '2020-01-01', NULL, 6),
(13, 'Christoph', 'Hauser', '2020-01-01', NULL, 6),
(14, 'Martin', 'Wolf', '2020-01-01', NULL, 7),
(15, 'Daniel', 'Eder', '2020-01-01', NULL, 7),
(16, 'Patrick', 'Hofer', '2020-01-01', NULL, 8),
(17, 'Julia', 'Grasl', '2020-01-01', NULL, 8),
(18, 'Helmut', 'Fink', '2020-01-01', NULL, 9),
(19, 'Karin', 'Lehner', '2020-01-01', NULL, 9),
(20, 'David', 'Krenn', '2020-01-01', NULL, 10);

INSERT INTO mitglied_rang (mitglied_id, rang_id, von, bis) VALUES
(1, 1, '2020-01-01', NULL),
(2, 2, '2020-01-01', NULL),
(3, 2, '2020-01-01', NULL),
(4, 3, '2020-01-01', NULL),
(5, 3, '2020-01-01', NULL),
(6, 4, '2020-01-01', NULL),
(7, 4, '2020-01-01', NULL),
(8, 5, '2020-01-01', NULL),
(9, 5, '2020-01-01', NULL),
(10, 6, '2020-01-01', NULL),
(11, 6, '2020-01-01', NULL),
(12, 7, '2020-01-01', NULL),
(13, 7, '2020-01-01', NULL),
(14, 8, '2020-01-01', NULL),
(15, 8, '2020-01-01', NULL),
(16, 10, '2020-01-01', NULL),
(17, 10, '2020-01-01', NULL),
(18, 13, '2020-01-01', NULL),
(19, 14, '2020-01-01', NULL),
(20, 15, '2020-01-01', NULL);

INSERT INTO mitglied_einheit (mitglied_id, einheit_id, von, bis, rolle) VALUES
(1, 1, '2020-01-01', NULL, 'Bundesministerin'),
(2, 2, '2020-01-01', NULL, 'Kommandant Streitkräfte'),
(3, 3, '2020-01-01', NULL, 'Chef Landstreitkräfte'),
(4, 4, '2020-01-01', NULL, 'Chef Luftstreitkräfte'),
(5, 5, '2020-01-01', NULL, 'Brigadekommandant'),
(6, 6, '2020-01-01', NULL, 'Brigadekommandant'),
(7, 7, '2020-01-01', NULL, 'Leiter Luftunterstützung'),
(8, 8, '2020-01-01', NULL, 'Kommandant Fliegerabwehr'),
(9, 9, '2020-01-01', NULL, 'Leiter Akademie'),
(10, 10, '2020-01-01', NULL, 'Leiter Nachrichtendienst'),
(11, 5, '2020-01-01', NULL, 'Zugskommandant'),
(12, 6, '2020-01-01', NULL, 'Zugskommandant'),
(13, 7, '2020-01-01', NULL, 'Technischer Offizier'),
(14, 8, '2020-01-01', NULL, 'Leutnant'),
(15, 9, '2020-01-01', NULL, 'Ausbildner'),
(16, 5, '2020-01-01', NULL, 'Soldat'),
(17, 6, '2020-01-01', NULL, 'Sanitäter'),
(18, 8, '2020-01-01', NULL, 'Gefreiter'),
(19, 9, '2020-01-01', NULL, 'Rekrut'),
(20, 10, '2020-01-01', NULL, 'Analyst');
