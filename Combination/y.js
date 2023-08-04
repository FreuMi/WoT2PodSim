import fetch from 'node-fetch';
import { appendFileSync } from 'fs';

global.start;

const pollingInterval = 10;

// Pass IP as input parameter
const args = process.argv.slice(2);
const uriX = `http://${args[0].split('/')[0]}:3003/temp`;
const uriZ = `http://${args[1].split('/')[0]}:3003/temp`;

console.log('X at', uriX);
console.log('Z at', uriZ);


function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function doSomeProcessing(response) {
  await sleep(10);
  const res = await response.json();
  return res;
}

async function main() {
  // Get data from X
  // Start fetch
  const startFetch = fetch(uriX);
  // Start time
  const now = new Date();
  // wait for fetch
  const response = await startFetch;
  // process some data
  const data = await doSomeProcessing(response);
  // Stop time measruement (global.start defined in ./node_modules/node-fetch/index.js)
  console.log('t_data(Y)', performance.now() - global.start);
  console.log('RTT_XY', 100); // Is set in startPollingTest.sh
  await sleep(pollingInterval);
  console.log('PI_X', pollingInterval);

  // Send data to Z
  const startSecondFetch = fetch(uriZ, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      key1: 'value1',
    }),
  });
  const response2 = await startSecondFetch;
  try {
    appendFileSync('./timestampY.txt', `${now.getTime()}\n`);
  } catch (error) {
    console.error(`Error writing file: ${error}`);
  }
}

main();
