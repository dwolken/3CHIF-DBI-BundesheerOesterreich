# Bundesheer Österreich – Organigramm (PNG & SVG)

Dieses Projekt erzeugt ein Organigramm des österreichischen Bundesheeres aus einer PostgreSQL-Datenbank und generiert die Dateien:

- Bundesheer_Organigram.svg  
- Bundesheer_Organigram.png

Es wird nur Folgendes benötigt:

- Node.js  
- ein laufender PostgreSQL-Server  
- eine Bash-Shell (Git Bash oder Linux/Mac Terminal)

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
npm install pg sharp
```

---

## 3. Datenbankverbindung setzen

Standardwerte:

- Host: localhost  
- Port: 5432  
- Benutzer: postgres
- Passwort: postgres  
- Datenbankname: Bundesheer_DB

Extern änderbar:

```bash
export PG_HOST="IhrHost"
export PG_PORT=IhrPort
export PG_USER="IhrUser"
export PG_PWD="IhrPasswort"
```

---

## 4. Script ausführen

```bash
node Bundesheer_GenerateOrganigramm.js
```

Das Script:

- verbindet sich mit PostgreSQL  
- legt die Datenbank an, falls sie nicht existiert  
- prüft, ob Tabellen existieren  
- spielt Bundesheer_Schema.sql ein, falls nötig  
- liest die Daten  
- erzeugt SVG und PNG  

---

## 5. Ergebnis

Nach dem Ausführen:

- Bundesheer_Organigram.svg  
- Bundesheer_Organigram.png  

befinden sich im Projektordner.

---

## 6. Struktur

- Bundesheer_GenerGenerateOrganigram.js  
- schema.sql  
- README.md  

---

## Hinweis

Der Ablauf funktioniert ohne zusätzliche Programme.  
Es wird nichts installiert außer Node.js, und alle Zugangsdaten werden über `export` gesetzt.
