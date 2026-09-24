const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const {spawn} = require('node:child_process');

function startServer(base) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [path.resolve(__dirname, '../scripts/serve.cjs'), '--port', '0', '--base', base], {stdio: ['ignore', 'pipe', 'pipe']});
    let output = '';
    let errors = '';
    const timer = setTimeout(() => { child.kill('SIGTERM'); reject(new Error('Preview did not start: ' + errors)); }, 10000);
    child.on('error', (error) => { clearTimeout(timer); reject(error); });
    child.on('exit', (code) => { clearTimeout(timer); if (!output.includes('Static preview:')) reject(new Error('Preview exited: ' + code + ' ' + errors)); });
    child.stderr.on('data', (chunk) => { errors += chunk; });
    child.stdout.on('data', (chunk) => {
      output += chunk;
      const match = /Static preview: (http:\/\/127\.0\.0\.1:\d+\/[^\s]*)/.exec(output);
      if (!match) return;
      clearTimeout(timer);
      resolve({url: match[1], stop: () => new Promise((done) => {
        if (child.exitCode !== null) { done(); return; }
        child.once('exit', done);
        child.kill('SIGTERM');
      })});
    });
  });
}

for (const base of ['/', '/example-repository/']) {
  test('static site and all linked assets work at ' + base, {timeout: 20000}, async () => {
    const server = await startServer(base);
    try {
      const response = await fetch(server.url);
      assert.equal(response.status, 200);
      assert.match(response.headers.get('content-type'), /text\/html/);
      const html = await response.text();
      const assets = new Set([...html.matchAll(/(?:href|src|data-src)="(assets\/[^"#?]+)/g)].map((match) => match[1]));
      assert.ok(assets.size >= 8);
      for (const asset of assets) {
        const resource = await fetch(new URL(asset, server.url));
        assert.equal(resource.status, 200, asset);
        const bytes = new Uint8Array(await resource.arrayBuffer());
        assert.ok(bytes.length > 0, asset);
        if (asset.endsWith('.pdf')) {
          assert.equal(resource.headers.get('content-type'), 'application/pdf');
          assert.equal(new TextDecoder().decode(bytes.subarray(0, 5)), '%PDF-');
        }
        if (asset.endsWith('.js')) assert.match(resource.headers.get('content-type'), /javascript/);
      }
      assert.equal((await fetch(new URL('index.html?locale=en', server.url))).status, 200);
      assert.equal((await fetch(new URL('assets/not-found.png', server.url))).status, 404);
      assert.equal((await fetch(new URL('scripts/import-versioned-content.cjs', server.url))).status, 404);
      assert.equal((await fetch(new URL('.env', server.url))).status, 403);
      assert.equal((await fetch(server.url, {method: 'POST'})).status, 405);
      const head = await fetch(new URL('assets/js/app.js', server.url), {method: 'HEAD'});
      assert.equal(head.status, 200);
      assert.equal(await head.text(), '');
      if (base !== '/') {
        const redirect = await fetch(server.url.slice(0, -1), {redirect: 'manual'});
        assert.equal(redirect.status, 308);
        assert.equal(redirect.headers.get('location'), base);
        assert.equal((await fetch(new URL('/assets/js/app.js', server.url))).status, 404);
      }
    } finally { await server.stop(); }
  });
}
