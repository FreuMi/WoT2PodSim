import fetch from 'node-fetch';

global.start;

const pollingInterval = 10;

// Pass IP as input parameter
const args = process.argv.slice(2);
const uri = `http://${args[0].split('/')[0]}:3003/temp`;
console.log('Send request to', uri);

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function doSomeProcessing(response) {
  await sleep(10);
  const res = await response.json();
  return res;
}

async function main() {
  // Start fetch
  const startFetch = fetch(uri);
  // Start timer
  const totalRuntime = performance.now();
  // wait for fetch
  const response = await startFetch;
  // process some data
  const data = await doSomeProcessing(response);
  // Stop time measruement (global.start defined in ./node_modules/node-fetch/index.js)
  console.log('t_data(X)', performance.now() - global.start);
  console.log('RTT_XY', 100); // Is set in startPollingTest.sh
  await sleep(pollingInterval);
  console.log('PI_X', pollingInterval);
  console.log('total runtime', performance.now() - totalRuntime);
}

main();
