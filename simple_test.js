import './server/env';
import sequelize from './server/lib/sequelize';

async function testSequelizeConnection() {
  try {
    console.log('Testing Sequelize connection...');
    await sequelize.authenticate();
    console.log('✅ Sequelize connection has been established successfully.');

    // Try a simple query
    const result = await sequelize.query('SELECT NOW()');
    console.log('✅ Query executed successfully:', result[0][0]);

    await sequelize.close();
    console.log('✅ Connection closed.');
  } catch (error) {
    console.error('❌ Unable to connect to the database:', error);
  }
}

console.log('NODE_ENV:', process.env.NODE_ENV);
testSequelizeConnection();
