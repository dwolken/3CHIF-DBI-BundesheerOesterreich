# Bundesheer Österreich – Organigramm (PNG & SVG)

Dieses Projekt erzeugt ein Organigramm des österreichischen Bundesheeres
aus einer MySQL-Datenbank und generiert daraus **Bundesheer_Ogranigram.svg** und **Bundesheer_Organigram.png**.

Es werden nur folgende Programme benötigt:

- Node.js (>= 18 empfohlen)
- MySQL-Server (lokal, `localhost`)
- eine Bash-Shell
- `npm` zum Installieren der Node-Module

Es werden **keine zusätzlichen Grafikprogramme** benötigt (kein Graphviz, kein VS Code).

---

## 1. Repository herunterladen

```bash
git clone https://github.com/dwolken/3CHIF-DBI-BundesheerOesterreich.git
cd 3CHIF-DBI-BundesheerOesterreich
```

oder ZIP herunterladen und entpacken.

---

## 2. Abhängigkeiten installieren

```bash
npm install mysql2 sharp
```

---

## 3. MySQL vorbereiten

Stelle sicher, dass ein MySQL-Server auf `localhost` läuft
und du mit Benutzer `root` zugreifen kannst.

Standardwerte des Scripts:

- Host: `localhost`
- Benutzer: `root`
- Passwort: `mysql`

Falls dein Passwort anders ist, setze vorher:

```bash
export MYSQL_PWD="deinpasswort"
```

Optional kannst du auch Benutzer und Host setzen:

```bash
export MYSQL_USER="root"
export MYSQL_HOST="localhost"
```

---

## 4. Script ausführen

```bash
node Bundesheer_GenerateOrganigramm.js
```

Das Script:

1. spielt `Bundesheer_SQL-Schema.sql` in MySQL ein  
2. verwendet die Datenbank `Bundesheer_DB`  
3. liest alle Personen mit Rang + Über-/Unterstellung  
4. baut ein Baumlayout  
5. erzeugt die Dateien:

- `Bundesheer_Organigram.svg`
- `Bundesheer_Organigram.png`

---

## 5. Ergebnis

- **Bundesheer_Organigram.svg** – Vektorgrafik des Organigramms  
- **Bundesheer_Organigram.png** – PNG-Version der Struktur  

Beide Dateien werden im Projektordner erzeugt.

---

## 6. Dateien im Projekt

- `Bundesheer_GenerateOrganigramm.js` – Node-Script zum Erzeugen der Grafiken  
- `Bundesheer_SQL-Schema.sql` – Datenbankschema + Beispiel-Daten  
- `README.md` – diese Anleitung
