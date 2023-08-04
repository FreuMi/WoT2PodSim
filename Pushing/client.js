import fetch from 'node-fetch';
import { appendFileSync } from 'fs';

global.start;

// Pass IP as input parameter
const args = process.argv.slice(2);
const uri = `http://${args[0].split('/')[0]}:3003/temp`;
console.log('Send request to', uri);

async function main() {
  // Start fetch
  const startFetch = fetch(uri, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      key1: 'value1',
    }),
  });
  // Start time
  const now = new Date();

  // wait for fetch
  const response = await startFetch;

  // Write timestamp to file
  try {
    appendFileSync('./timestampClient.txt', `${now.getTime()}\n`);
  } catch (error) {
    console.error(`Error writing file: ${error}`);
  }
}

main();
