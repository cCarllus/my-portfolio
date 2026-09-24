const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const args = process.argv.slice(2);
const argument = (name, fallback) => { const index = args.indexOf(name); return index < 0 ? fallback : args[index + 1]; };
const port = Number(argument('--port', process.env.PORT || 4173));
const prefix = '/' + String(argument('--base', '/')).split('/').filter(Boolean).join('/') + '/';
const base = prefix === '//' ? '/' : prefix;
if (!Number.isInteger(port) || port < 0 || port > 65535) throw new Error('Invalid port');
const mime = {'.html': 'text/html; charset=utf-8', '.css': 'text/css; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.png': 'image/png', '.svg': 'image/svg+xml', '.pdf': 'application/pdf'};
const server = http.createServer((request, response) => {
  if (!['GET', 'HEAD'].includes(request.method)) { response.writeHead(405); response.end(); return; }
  let pathname;
  try { pathname = decodeURIComponent(new URL(request.url, 'http://localhost').pathname); }
  catch (_) { response.writeHead(400); response.end(); return; }
  if (base !== '/' && pathname === base.slice(0, -1)) { response.writeHead(308, {Location: base}); response.end(); return; }
  if (!pathname.startsWith(base)) { response.writeHead(404); response.end('Not found'); return; }
  const relative = pathname.slice(base.length) || 'index.html';
  const file = path.resolve(root, relative);
  if (!file.startsWith(root + path.sep) || relative.split('/').some((part) => part.startsWith('.'))) { response.writeHead(403); response.end(); return; }
  // Preview only public assets, never local scripts, database files, or repository configuration.
  if (relative !== 'index.html' && !relative.startsWith('assets/')) { response.writeHead(404); response.end('Not found'); return; }
  fs.stat(file, (error, stat) => {
    if (error || !stat.isFile()) { response.writeHead(404); response.end('Not found'); return; }
    response.writeHead(200, {'Content-Type': mime[path.extname(file)] || 'application/octet-stream', 'Content-Length': stat.size, 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff'});
    if (request.method === 'HEAD') response.end();
    else fs.createReadStream(file).on('error', () => response.destroy()).pipe(response);
  });
});
server.on('error', (error) => { console.error(error.message); process.exitCode = 1; });
server.listen(port, '127.0.0.1', () => console.log(`Static preview: http://127.0.0.1:${server.address().port}${base}`));
for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => server.close());
