import { Client, Users, Storage } from 'node-appwrite';
import fs from 'fs';
import path from 'path';
import speech from '@google-cloud/speech';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default async ({ req, res, log, error }) => {
  let transcription = '';

  try {
    // 1. Load credentials explicitly
    const credentialsPath = path.join(__dirname, '../application_default_credentials.json');
    const credentials = JSON.parse(fs.readFileSync(credentialsPath, 'utf8'));

    // 2. Use Beta Client (REQUIRED for MP3) with credentials
    const client = new speech.v1p1beta1.SpeechClient({ credentials });

    const appwriteClient = new Client()
      .setEndpoint('https://fra.cloud.appwrite.io/v1')
      .setProject('696ddda6001b28f2352e');

    const storage = new Storage(appwriteClient);

    const fileBuffer = await storage.getFileDownload(
      '698c93a00006c743c31f',
      req.bodyText
    );

    const audio = {
      content: Buffer.from(fileBuffer).toString('base64'),
    };

    const config = {
      encoding: 'MP3',        // 3. Must be 'MP3'
      sampleRateHertz: 8000,
      languageCode: 'en-GB',
    };

    const [speechResponse] = await client.recognize({ config, audio });

    transcription = speechResponse.results
      .map(result => result.alternatives[0].transcript)
      .join('\n');

  } catch (err) {
    error(err.message);
    return res.json({ error: err.message }, 500);
  }
//var len =  fileBuffer.length;

var q = req.query;
 var v = q['key2'];
  var t = req.bodyText;
  return res.json({
    t:t,
    transcription: transcription,
    body: (req.bodyText),
    method: (req.scheme),
    reMethod: (req.method),
    url: (req.url),
    hostname: (req.host),
    port: (req.port),
    path: (req.path),
    query: (req.queryString),
    parsed: (JSON.stringify(req.query))



  });
};
/*
    body: (req.bodyText),
    json: (JSON.stringify(req.bodyJson)),
    headers: (JSON.stringify(req.headers)),
    method: (req.scheme),
    reMethod: (req.method),
    url: (req.url),
    hostname: (req.host),
    port: (req.port),
    path: (req.path),
    query: (req.queryString),
    parsed: (JSON.stringify(req.query)),
*/