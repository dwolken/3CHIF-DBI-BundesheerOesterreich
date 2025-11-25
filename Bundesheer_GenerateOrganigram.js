import mysql from "mysql2/promise";
import sharp from "sharp";
import { writeFileSync } from "fs";

const MYSQL_HOST = process.env.MYSQL_HOST || "localhost";
const MYSQL_USER = process.env.MYSQL_USER || "root";
const MYSQL_PWD  = process.env.MYSQL_PWD  || "mysql";
const MYSQL_PORT = process.env.MYSQL_PORT || 3306;

const connection = await mysql.createConnection({
  host: MYSQL_HOST,
  user: MYSQL_USER,
  password: MYSQL_PWD,
  port: MYSQL_PORT,
  database: "bundesheer_db"
});

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
    const parentCenterX = parent.x + parent.width / 2;
    const parentBottomY = parent.y + nodeHeight;
    const childCenterX = node.x + node.width / 2;
    const childTopY = node.y;
    svgParts.push(
      `<line x1="${parentCenterX}" y1="${parentBottomY}" x2="${childCenterX}" y2="${childTopY}" />`
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

const pngBuffer = await sharp(Buffer.from(svgContent)).png().toBuffer();
writeFileSync("Bundesheer_Organigram.png", pngBuffer);

await connection.end();
