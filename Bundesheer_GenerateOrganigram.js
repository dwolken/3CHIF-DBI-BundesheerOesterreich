import mysql from "mysql2/promise";
import sharp from "sharp";
import { readFileSync, writeFileSync } from "fs";

// MySQL-Zugang
// Passwort wird zuerst aus ENV-Variable MYSQL_PWD gelesen,
// sonst default "mysql"
const MYSQL_HOST = process.env.MYSQL_HOST || "localhost";
const MYSQL_USER = process.env.MYSQL_USER || "root";
const MYSQL_PWD  = process.env.MYSQL_PWD  || "mysql";

const connection = await mysql.createConnection({
  host: MYSQL_HOST,
  user: MYSQL_USER,
  password: MYSQL_PWD
});

// 1. SQL-Schema einspielen
const sql = readFileSync("./Bundesheer_SQL-Schema.sql", "utf8");

for (const stmt of sql
  .split(/;\s*\n/)
  .map(s => s.trim())
  .filter(s => s.length > 0)) {
  await connection.query(stmt);
}

await connection.changeUser({ database: "Bundesheer_DB" });

// 2. Personen + parent_id holen
const [rows] = await connection.query(`
SELECT 
  m.id,
  m.parent_id,
  CONCAT(r.bezeichnung, ' ', m.vorname, ' ', m.nachname) AS name
FROM mitglied m
LEFT JOIN mitglied_rang mr ON mr.mitglied_id = m.id
LEFT JOIN rang r ON r.id = mr.rang_id
WHERE mr.bis IS NULL OR mr.bis >= CURDATE();
`);

// 3. Baumstruktur aufbauen
const nodesById = new Map();
for (const row of rows) {
  nodesById.set(row.id, { ...row, children: [] });
}

const roots = [];
for (const node of nodesById.values()) {
  if (node.parent_id && nodesById.has(node.parent_id)) {
    nodesById.get(node.parent_id).children.push(node);
  } else {
    roots.push(node);
  }
}

// 4. Layout berechnen (einfache Baum-Layout-Logik)
const nodeWidth = 260;
const nodeHeight = 40;
const hGap = 40;   // horizontaler Abstand zwischen Geschwistern
const vGap = 80;   // vertikaler Abstand zwischen Ebenen
const margin = 40;

let currentX = margin;

function layoutTree(node, depth = 0) {
  node.y = margin + depth * (nodeHeight + vGap);

  if (!node.children || node.children.length === 0) {
    node.x = currentX;
    currentX += nodeWidth + hGap;
  } else {
    // Kinder zuerst layouten
    for (const child of node.children) {
      layoutTree(child, depth + 1);
    }
    const minX = Math.min(...node.children.map(c => c.x));
    const maxX = Math.max(...node.children.map(c => c.x));
    node.x = (minX + maxX) / 2;
  }
}

// Layout für alle Wurzeln (falls es mehrere gibt)
for (const root of roots) {
  layoutTree(root, 0);
}

// 5. SVG erzeugen
let allNodes = Array.from(nodesById.values());
const maxX = Math.max(...allNodes.map(n => n.x)) + nodeWidth + margin;
const maxY = Math.max(...allNodes.map(n => n.y)) + nodeHeight + margin;

let svgParts = [];
svgParts.push(
  `<?xml version="1.0" encoding="UTF-8"?>`,
  `<svg xmlns="http://www.w3.org/2000/svg" width="${maxX}" height="${maxY}" viewBox="0 0 ${maxX} ${maxY}">`,
  `<style>
    rect {
      fill: #e0e0e0;
      stroke: #000000;
      stroke-width: 1;
      rx: 4;
      ry: 4;
    }
    line {
      stroke: #000000;
      stroke-width: 1;
    }
    text {
      font-family: Helvetica, Arial, sans-serif;
      font-size: 12px;
    }
  </style>`
);

// Kanten (Linien) zeichnen
for (const node of allNodes) {
  if (node.parent_id && nodesById.has(node.parent_id)) {
    const parent = nodesById.get(node.parent_id);

    const parentCenterX = parent.x + nodeWidth / 2;
    const parentBottomY = parent.y + nodeHeight;
    const childCenterX = node.x + nodeWidth / 2;
    const childTopY = node.y;

    svgParts.push(
      `<line x1="${parentCenterX}" y1="${parentBottomY}" x2="${childCenterX}" y2="${childTopY}" />`
    );
  }
}

// Boxen + Text zeichnen
for (const node of allNodes) {
  const x = node.x;
  const y = node.y;
  const label = node.name.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

  svgParts.push(
    `<rect x="${x}" y="${y}" width="${nodeWidth}" height="${nodeHeight}" />`,
    `<text x="${x + 10}" y="${y + 25}">${label}</text>`
  );
}

svgParts.push(`</svg>`);

const svgContent = svgParts.join("\n");
writeFileSync("Bundesheer_Organigram.svg", svgContent, "utf8");
console.log("SVG erstellt: Bundesheer_Organigram.svg");

// 6. Aus SVG ein PNG machen
const pngBuffer = await sharp(Buffer.from(svgContent))
  .png()
  .toBuffer();

writeFileSync("Bundesheer_Organigram.png", pngBuffer);
console.log("PNG erstellt: Bundesheer_Organigram.png");

await connection.end();
console.log("Fertig.");
