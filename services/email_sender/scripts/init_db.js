// Simple DB init script to create required tables
const { Client } = require('pg');
const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  console.error('DATABASE_URL is not set. Set it in your environment to run this script.');
  process.exit(1);
}

const client = new Client({ connectionString, ssl: { rejectUnauthorized: false } });

(async () => {
  try {
    await client.connect();
    console.log('Connected to Postgres, creating tables if needed...');

    await client.query(`
      CREATE TABLE IF NOT EXISTS jobs (
        id SERIAL PRIMARY KEY,
        title TEXT NOT NULL,
        company TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
      );
    `);

    console.log('Init complete.');
    await client.end();
  } catch (err) {
    console.error('Init DB failed', err);
    process.exit(1);
  }
})();
