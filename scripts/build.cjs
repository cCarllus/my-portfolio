const fs = require('node:fs');
const path = require('node:path');
const data = require('../assets/js/content.js');
const ui = require('../assets/js/ui.js');
const destination = path.resolve(__dirname, '../index.html');
const html = ui.renderPage(data, 'pt');
if (process.argv.includes('--check')) {
  if (!fs.existsSync(destination) || fs.readFileSync(destination, 'utf8') !== html) {
    console.error('index.html is out of date. Run npm run build.');
    process.exitCode = 1;
  } else console.log('Pre-rendered HTML is up to date.');
} else {
  fs.writeFileSync(destination, html);
  console.log('Generated index.html. It can be opened directly or hosted without Node/Rails.');
}
