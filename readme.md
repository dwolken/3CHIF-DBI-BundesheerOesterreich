# Projekt installieren und ausführen

1. Repository herunterladen  
git clone https://github.com/dwolken/3CHIF-DBI-BundesheerOesterreich.git

Oder als ZIP von GitHub herunterladen und entpacken.

2. In das Projektverzeichnis wechseln  
cd 3CHIF-DBI-BundesheerOesterreich

3. Node Modules installieren  
npm install

4. Dateien vorbereiten  
Stellen Sie sicher, dass folgende Dateien im Projektverzeichnis liegen:  
- Bundesheer_GenerateOrganigram.js  
- Bundesheer_SQL-Schema.sql

5. Visual Studio Code öffnen  
code .

6. Script ausführen  
node Bundesheer_GenerateOrganigram.js

7. Ergebnis  
Die generierten Bilder werden im Projektverzeichnis abgelegt.
