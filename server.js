require('dotenv').config();
const express = require('express');
const mysql = require('mysql2');
const path = require('path');
const fs = require('fs');

const PORTAL = process.env.PORTAL || 'hub';

const app = express();

const db = mysql.createConnection({
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  socketPath: process.env.DB_SOCKET
});

app.use(express.json());

let publicDir = path.join(__dirname, PORTAL, 'public');
if (!fs.existsSync(publicDir)) {
  publicDir = path.join(__dirname, 'public');
}
if (PORTAL === 'babsapp') {
  console.log('⚙️ Detected babsapp portal.');
  publicDir = path.join(__dirname, 'babsapp', 'public');
}

app.use(express.static(publicDir));

app.post('/api/contact', (req, res) => {
  const { name, email, message } = req.body;
  const query = 'INSERT INTO contacts (name, email, message) VALUES (?, ?, ?)';
  db.query(query, [name, email, message], (err) => {
    if (err) {
      console.error('❌ DB error:', err);
      return res.json({ success: false });
    }
    return res.json({ success: true });
  });
});

app.post('/api/participate', (req, res) => {
  const { name, email, skills } = req.body;
  const query = 'INSERT INTO participate (name, email, skills) VALUES (?, ?, ?)';
  db.query(query, [name, email, skills], (err) => {
    if (err) {
      console.error('❌ DB error:', err);
      return res.json({ success: false });
    }
    return res.json({ success: true });
  });
});

app.get('/', (req, res) => {
  res.sendFile(path.join(publicDir, 'index.html'));
});

// ❌ REMOVE app.listen(...) for Vercel
// ✅ Export the app for serverless
module.exports = app;


