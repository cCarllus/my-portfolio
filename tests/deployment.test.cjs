const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const root = path.resolve(__dirname, '..');

// Dotfiles must survive copying the standalone site into a new repository.
test('standalone repository includes the Pages workflow and required dotfiles', () => {
  for (const file of ['.github/workflows/pages.yml', '.github/dependabot.yml', '.gitignore', '.nojekyll']) {
    assert.ok(fs.existsSync(path.join(root, file)), `Missing deployment file: ${file}`);
  }
});

test('packaging excludes private root files and safely replaces a previous build', (t) => {
  const fixture = fs.mkdtempSync(path.join(root, '.package-test-'));
  t.after(() => fs.rmSync(fixture, { recursive: true, force: true }));
  for (const file of ['index.html', '.nojekyll', 'assets', 'scripts/package.cjs']) {
    const destination = path.join(fixture, file);
    fs.mkdirSync(path.dirname(destination), { recursive: true });
    fs.cpSync(path.join(root, file), destination, { recursive: true });
  }
  // Synthetic fixtures only: never open the real local environment file.
  fs.writeFileSync(path.join(fixture, '.env'), 'TEST_ONLY=not-a-real-secret\n');
  fs.writeFileSync(path.join(fixture, 'private-notes.txt'), 'not for publication\n');
  const run = (...args) => spawnSync(process.execPath, ['scripts/package.cjs', ...args], {
    cwd: fixture, encoding: 'utf8', timeout: 15000
  });
  const first = run();
  assert.equal(first.status, 0, first.stderr || first.error?.message);
  const output = path.join(fixture, '_site');
  assert.deepEqual(fs.readdirSync(output).sort(), ['.nojekyll', 'assets', 'index.html']);
  fs.writeFileSync(path.join(output, 'stale-file.txt'), 'previous build\n');
  assert.notEqual(run().status, 0, 'Replacing an existing build requires --clean');
  assert.ok(fs.existsSync(path.join(output, 'stale-file.txt')));
  const rebuilt = run('--clean');
  assert.equal(rebuilt.status, 0, rebuilt.stderr || rebuilt.error?.message);
  assert.deepEqual(fs.readdirSync(output).sort(), ['.nojekyll', 'assets', 'index.html']);
  assert.ok(fs.existsSync(path.join(fixture, '.env')), 'Local files must remain untouched');
  assert.ok(fs.existsSync(path.join(output, 'assets/js/app.js')));
});
