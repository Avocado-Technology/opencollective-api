import './server/env';
import config from 'config';
import { getDBConf } from './server/lib/db';

console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('Raw config database:', JSON.stringify(config.database, null, 2));
console.log('getDBConf result:', getDBConf('database'));
console.log('Password type:', typeof getDBConf('database').password);
console.log('Password value:', JSON.stringify(getDBConf('database').password));
