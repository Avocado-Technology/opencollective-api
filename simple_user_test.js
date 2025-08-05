import './server/env';
import { expect } from 'chai';
import sequelize from './server/lib/sequelize';

describe('Simple Database Test', () => {
  before(async () => {
    // Create Users table if it doesn't exist
    await sequelize.query(`
      CREATE TABLE IF NOT EXISTS "Users" (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
        "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
      );
    `);
  });

  beforeEach(async () => {
    // Clean the table before each test
    await sequelize.query('TRUNCATE TABLE "Users" RESTART IDENTITY CASCADE;');
  });

  after(async () => {
    await sequelize.close();
  });

  it('should connect to the database', async () => {
    const [results] = await sequelize.query('SELECT NOW() as now');
    expect(results[0].now).to.be.a('date');
  });

  it('should create and query a user', async () => {
    // Insert a test user
    await sequelize.query(`
      INSERT INTO "Users" (email) VALUES ('test@example.com');
    `);

    // Query the user
    const [results] = await sequelize.query('SELECT * FROM "Users" WHERE email = ?', {
      replacements: ['test@example.com'],
    });

    expect(results).to.have.length(1);
    expect(results[0].email).to.equal('test@example.com');
  });
});
