import './server/env';
import { resetTestDB } from './test/utils';

async function runMinimalTest() {
  try {
    console.log('Running minimal test...');

    // Attempt to reset the test database
    await resetTestDB();
    console.log('✅ Test database reset successfully');
  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}

console.log('NODE_ENV:', process.env.NODE_ENV);
runMinimalTest();
