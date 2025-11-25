import pkg from "pg";
import sharp from "sharp";
import { readFileSync, writeFileSync } from "fs";

const { Client } = pkg;

const PG_HOST = process.env.PG_HOST || "localhost";
const PG_PORT = process.env.PG_PORT || 5432;
const PG_USER = process.env.PG_USER || "postgres";
const PG_PWD  = process.env.PG_PWD  || "postgres";
const PG_DB   = process.env.PG_DB   || "Bundesheer_DB";

async function tableExists(client, name) {
  const q = await client.query(
    "SELECT 1 FROM information_schema.tables WHERE table_name = $1",
    [name]
  );
  return q.rowCount > 0;
}

console.log("Verbinde zu PostgreSQL…");

const sys = new Client({
  host: PG_HOST,
  port: PG_PORT,
  user: PG_USER,
  password: PG_PWD,
  database: "postgres"
});
await sys.connect();
console.log("Verbunden (postgres)");

const dbCheck = await sys.query(
  "SELECT 1 FROM pg_database WHERE datname = $1",
  [PG_DB]
);

if (dbCheck.rowCount === 0) {
  console.log("Datenbank existiert nicht. Erstelle:", PG_DB);
  await sys.query(`CREATE DATABASE "${PG_DB}"`);
  console.log("Datenbank erstellt.");
} else {
  console.log("Datenbank existiert bereits:", PG_DB);
}

await sys.end();

console.log("Verbinde zu", PG_DB, "…");

const client = new Client({
  host: PG_HOST,
  port: PG_PORT,
  user: PG_USER,
  password: PG_PWD,
  database: PG_DB
});
await client.connect();

console.log("Verbunden:", PG_DB);

const firstTable = await tableExists(client, "rang");

if (!firstTable) {
  console.log("Tabellen fehlen. Spiele Schema ein…");
  const schema = readFileSync("./Bundesheer_Schema.sql", "utf8");
  await client.query(schema);
  console.log("Schema erfolgreich eingespielt.");
} else {
  console.log("Tabellen existieren bereits. Schema wird nicht erneut eingespielt.");
}

console.log("Lese Daten…");

const result = await client.query(`
SELECT 
  m.id,
  m.parent_id,
  (r.bezeichnung || ' ' || m.vorname || ' ' || m.nachname) AS name
FROM mitglied m
LEFT JOIN mitglied_rang mr ON mr.mitglied_id = m.id
LEFT JOIN rang r ON r.id = mr.rang_id
WHERE mr.bis IS NULL OR mr.bis >= CURRENT_DATE;
`);

console.log("Datensätze geladen:", result.rowCount);

const rows = result.rows;

const nodesById = new Map();
for (const row of rows) nodesById.set(row.id, { ...row, children: [] });

const roots = [];
for (const node of nodesById.values()) {
  if (node.parent_id && nodesById.has(node.parent_id)) {
    nodesById.get(node.parent_id).children.push(node);
  } else roots.push(node);
}

const nodeHeight = 40;
const hGap = 40;
const vGap = 80;
const margin = 40;

for (const node of nodesById.values()) {
  const label = node.name;
  node.width = Math.max(label.length * 7.5, 220);
}

let currentX = margin;

function layoutTree(node, depth = 0) {
  node.y = margin + depth * (nodeHeight + vGap);
  if (!node.children || node.children.length === 0) {
    node.x = currentX;
    currentX += node.width + hGap;
  } else {
    for (const child of node.children) layoutTree(child, depth + 1);
    const minX = Math.min(...node.children.map(c => c.x));
    const maxX = Math.max(...node.children.map(c => c.x + c.width));
    node.x = (minX + maxX) / 2 - node.width / 2;
  }
}

for (const root of roots) layoutTree(root);

const allNodes = Array.from(nodesById.values());
const maxX = Math.max(...allNodes.map(n => n.x + n.width)) + margin;
const maxY = Math.max(...allNodes.map(n => n.y)) + nodeHeight + margin;

let svgParts = [];

svgParts.push(
  '<?xml version="1.0" encoding="UTF-8"?>',
  `<svg xmlns="http://www.w3.org/2000/svg" width="${maxX}" height="${maxY}" viewBox="0 0 ${maxX} ${maxY}">`,
  `<style>
    rect { fill: #e0e0e0; stroke: #000; stroke-width: 1; rx: 4; ry: 4; }
    line { stroke: #777; stroke-width: 1.5; }
    text { font-family: Helvetica, Arial, sans-serif; font-size: 12px; }
  </style>`
);

for (const node of allNodes) {
  if (node.parent_id && nodesById.has(node.parent_id)) {
    const parent = nodesById.get(node.parent_id);
    svgParts.push(
      `<line x1="${parent.x + parent.width / 2}" y1="${parent.y + nodeHeight}"
             x2="${node.x + node.width / 2}" y2="${node.y}" />`
    );
  }
}

for (const node of allNodes) {
  const label = node.name.replace(/&/g, "&amp;").replace(/</g, "&lt;");
  svgParts.push(
    `<rect x="${node.x}" y="${node.y}" width="${node.width}" height="${nodeHeight}" />`,
    `<text x="${node.x + 10}" y="${node.y + 25}">${label}</text>`
  );
}

svgParts.push("</svg>");

const svgContent = svgParts.join("\n");
writeFileSync("Bundesheer_Organigram.svg", svgContent, "utf8");

console.log("SVG erstellt: Bundesheer_Organigram.svg");

const pngBuffer = await sharp(Buffer.from(svgContent)).png().toBuffer();
writeFileSync("Bundesheer_Organigram.png", pngBuffer);

console.log("PNG erstellt: Bundesheer_Organigram.png");

await client.end();

console.log("Fertig.");
