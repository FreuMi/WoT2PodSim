import express from 'express';
import { appendFileSync } from 'fs';


const app = express();
const port = 3003;

global.start;

app.use(express.json({ strict: false }));

// Pass IP as input parameter
const args = process.argv.slice(2);
const IP = `${args[0].split('/')[0]}:3003`;

app.post('/temp', async function (req, res) {
  console.log('t_data(Y)', performance.now() - global.start);
  console.log('RTT_XY', 100); // defined in startPushingTest.sh

  // Stop time
  const now = new Date();
  res.sendStatus(200);
  try {
    appendFileSync('./timestampServer.txt', `${now.getTime()}\n`);
  } catch (error) {
    console.error(`Error writing file: ${error}`);
  }
});

app.listen(port, () => {
  console.log(`Example app listening on ${IP}`);
});
