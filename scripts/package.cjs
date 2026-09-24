const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const output = path.join(root, '_site');
const data = require('../assets/js/content.js');
const ui = require('../assets/js/ui.js');
if (fs.readFileSync(path.join(root, 'index.html'), 'utf8') !== ui.renderPage(data, 'pt')) throw new Error('Run npm run build before packaging.');
if (fs.existsSync(output)) {
  if (!process.argv.includes('--clean')) throw new Error('_site already exists. Pass --clean to replace only this generated directory.');
  if (fs.lstatSync(output).isSymbolicLink()) throw new Error('Refusing a symbolic link for _site.');
  fs.rmSync(output, {recursive: true});
}
fs.mkdirSync(output);
for (const item of ['index.html', '.nojekyll', 'assets']) fs.cpSync(path.join(root, item), path.join(output, item), {recursive: true, dereference: false});
console.log('Packaged index.html, .nojekyll and assets into _site. No Rails files, tests or private data are published.');
