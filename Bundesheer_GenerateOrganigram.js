import mysql from "mysql2/promise";
import { readFileSync, writeFileSync } from "fs";
import { execSync } from "child_process";

const conn = await mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "mysql"
});

const sql = readFileSync("./Bundesheer_SQL-Schema.sql", "utf8");
for (const stmt of sql
  .split(/;\s*\n/)
  .map(s => s.trim())
  .filter(s => s.length > 0)) {
  await conn.query(stmt);
}

await conn.changeUser({ database: "militaer" });

const [personen] = await conn.query(`
SELECT 
  m.id,
  m.parent_id,
  CONCAT(r.bezeichnung, ' ', m.vorname, ' ', m.nachname) AS name
FROM mitglied m
LEFT JOIN mitglied_rang mr ON mr.mitglied_id = m.id
LEFT JOIN rang r ON r.id = mr.rang_id
WHERE mr.bis IS NULL OR mr.bis >= CURDATE();
`);

let dot = [];
dot.push("digraph militaer {");
dot.push("rankdir=TB;");
dot.push('node [shape=box, style=filled, fillcolor=lightgrey, fontname="Helvetica"];');

for (const p of personen)
  dot.push(`"P${p.id}" [label="${p.name.replace(/"/g, "'")}"];`);

for (const p of personen)
  if (p.parent_id)
    dot.push(`"P${p.parent_id}" -> "P${p.id}";`);

dot.push("}");
writeFileSync("militaer.dot", dot.join("\n"), "utf8");

const dotExe = `"C:\\Program Files\\Graphviz\\bin\\dot.exe"`;
execSync(`${dotExe} -Tsvg militaer.dot -o militaer.svg`);
execSync(`${dotExe} -Tpng militaer.dot -o militaer.png`);

console.log("fertig: militaer.svg und militaer.png erstellt");
await conn.end();
