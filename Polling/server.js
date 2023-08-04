import express from 'express';
import crypto from 'crypto';

const app = express();
const port = 3003;

// Added in node_modules/express/lib/application.js
global.start;

app.use(express.json({ strict: false }));

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// Pass IP as input parameter
const args = process.argv.slice(2);
//const IP = `${args[0].split('/')[0]}:3003`;
const IP = "127.0.0.1:3003"

// Read current temperature status
app.get('/temp', async function (req, res) {
  const temp = getRandomInt(10, 35);
  await sleep(3);
  res.send(temp.toString());
  console.log('t_req(Y)', performance.now() - global.start);
});

// Function to generate a random integer within a range
function getRandomInt(min, max) {
  const range = max - min + 1;
  const randomBytes = crypto.randomBytes(4);
  const randomNumber = randomBytes.readUInt32BE(0);
  return min + (randomNumber % range);
}

app.listen(port, () => {
  console.log(`Example app listening on ${IP}`);
});
