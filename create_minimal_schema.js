import './server/env';
import sequelize from './server/lib/sequelize';

async function createMinimalSchema() {
  try {
    console.log('Creating minimal schema for testing...');

    // Create a simple Users table for testing
    await sequelize.query(`
      CREATE TABLE IF NOT EXISTS "Users" (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
        "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
      );
    `);

    console.log('✅ Users table created');

    // Test inserting a user
    await sequelize.query(`
      INSERT INTO "Users" (email) VALUES ('test@example.com')
      ON CONFLICT DO NOTHING;
    `);

    console.log('✅ Test user inserted');

    // Test querying
    const [results] = await sequelize.query('SELECT * FROM "Users" LIMIT 1;');
    console.log('✅ Query result:', results[0]);

    await sequelize.close();
    console.log('✅ Schema creation complete');
  } catch (error) {
    console.error('❌ Schema creation failed:', error);
  }
}

createMinimalSchema();
