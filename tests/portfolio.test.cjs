const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const data = require('../assets/js/content.js');
const ui = require('../assets/js/ui.js');
const root = path.resolve(__dirname, '..');

test('preserves the versioned public content, without private collections', () => {
  assert.equal(data.profile.full_name, 'Carlos Henrique Caldeira');
  assert.equal(data.skills.length, 12);
  assert.equal(data.experiences.length, 3);
  assert.equal(data.educations.length, 2);
  assert.equal(data.projects.length, 3);
  assert.equal(data.documents.length, 6);
  assert.equal(data.profile.github_url, 'https://github.com/cCarllus');
  assert.equal(data.provenance.source, 'db/seeds.rb');
  for (const forbidden of ['contact_requests', 'email_bodies', 'email_subjects', 'credentials']) {
    assert.equal(Object.hasOwn(data, forbidden), false);
    assert.equal(Object.hasOwn(data.profile, forbidden), false);
  }
});

test('Portuguese and English have matching UI translation keys', () => {
  assert.deepEqual(Object.keys(data.messages.pt).sort(), Object.keys(data.messages.en).sort());
  for (const locale of ['pt', 'en']) {
    for (const value of Object.values(data.messages[locale])) assert.equal(typeof value, 'string');
    const html = ui.renderPage(data, locale);
    assert.ok(html.includes(`lang="${locale === 'pt' ? 'pt-BR' : 'en'}"`));
    assert.ok(!html.includes('undefined'));
    assert.ok(!html.includes('%{'));
    assert.ok(!html.includes('<%'));
    assert.ok(html.includes(locale === 'pt' ? 'Sobre mim' : 'About me'));
  }
});

test('project search is case- and accent-insensitive and composes with categories', () => {
  assert.equal(ui.normalize('AUTOMAÇÕES'), 'automacoes');
  assert.equal(ui.filterProjects(data.projects, 'automacoes', 'all', 'pt').length, 1);
  assert.equal(ui.filterProjects(data.projects, 'API PERFORMANCE', 'highlight', 'en').length, 1);
  assert.equal(ui.filterProjects(data.projects, '', 'open_source', 'pt').length, 0);
  assert.equal(ui.filterProjects(data.projects, 'does not exist', 'all', 'pt').length, 0);
});

test('escapes content, rejects unsafe URLs and constrains inline colors', () => {
  assert.equal(ui.escapeHtml('<script>"&'), '&lt;script&gt;&quot;&amp;');
  for (const url of ['javascript:alert(1)', 'data:text/html,boom', '//evil.example', 'vbscript:msgbox(1)']) {
    assert.equal(ui.safeUrl(url), '');
  }
  assert.equal(ui.safeUrl('assets/documents/resume.pdf'), 'assets/documents/resume.pdf');
  assert.equal(ui.safeUrl('https://github.com/cCarllus'), 'https://github.com/cCarllus');
  assert.equal(ui.safeColor('red; background:url(https://evil.example)'), '#71717a');
  assert.ok(!ui.markdown('<img src=x onerror=alert(1)>').includes('<img'));
  assert.ok(ui.markdown('**bold**\n\n- first\n- second').includes('<strong>bold</strong>'));
});

test('the committed HTML is up to date and contains usable no-JavaScript content', () => {
  assert.equal(fs.readFileSync(path.join(root, 'index.html'), 'utf8'), ui.renderPage(data, 'pt'));
  const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
  assert.ok(html.includes('Monde Sistemas'));
  assert.ok(html.includes('id="document-about"'));
  assert.ok(html.includes('mailto:crick.lucas@gmail.com'));
  assert.ok(html.includes('download="Carlos_Henrique_Caldeira_Curriculo.pdf"'));
  assert.ok(!/\b(?:href|src)="\/(?!\/)/.test(html), 'root-relative paths break project Pages');
  assert.ok(!/@hotwired|data-controller=|csrf-token|\/portfolio_request|rails_blob_path/.test(html));
});

test('all referenced local assets exist and the PDF is an actual PDF', () => {
  const html = ui.renderPage(data, 'pt');
  const assets = [...html.matchAll(/(?:href|src|data-src)="(assets\/[^"#?]+)/g)];
  assert.ok(assets.length >= 7);
  for (const [, asset] of assets) assert.ok(fs.existsSync(path.join(root, asset)), asset);
  const pdf = fs.readFileSync(path.join(root, data.profile.resume));
  assert.equal(pdf.subarray(0, 5).toString(), '%PDF-');
});

test('IDs are unique and document links resolve in both locales', () => {
  for (const locale of ['pt', 'en']) {
    const html = ui.renderPage(data, locale);
    const ids = [...html.matchAll(/\bid="([^"]+)"/g)].map((match) => match[1]);
    assert.equal(new Set(ids).size, ids.length);
    for (const [, target] of html.matchAll(/href="#([^"?]+)"/g)) assert.ok(ids.includes(target), target);
  }
});
