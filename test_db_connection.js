import './server/env';
import pg from 'pg';

async function testConnection() {
  const client = new pg.Client({
    host: '127.0.0.1',
    port: 5432,
    database: 'opencollective_test',
    user: 'opencollective',
    password: 'password',
  });

  try {
    await client.connect();
    console.log('Successfully connected to database!');
    const res = await client.query('SELECT NOW()');
    console.log('Query result:', res.rows[0]);
    await client.end();
  } catch (error) {
    console.error('Database connection error:', error);
  }
}

testConnection();
