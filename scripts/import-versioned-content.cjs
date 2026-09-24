/* One-time importer for this repository's inspected seed literals. Does not run Ruby or access a database. */
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const railsRoot = path.resolve(root, '..');
const output = path.join(root, 'assets/js/content.js');
if (fs.existsSync(output)) throw new Error('Content already exists; edit content.js instead of overwriting your changes.');
const seed = fs.readFileSync(path.join(railsRoot, 'db/seeds.rb'), 'utf8');

function literal(source) {
  const heredocsExpanded = source.replace(/<<~([A-Z_]+)(,?)\n([\s\S]*?)^\s*\1\s*$/gm, (_, marker, comma, body) => {
    const lines = body.replace(/\n$/, '').split('\n');
    const indent = Math.min(...lines.filter((line) => line.trim()).map((line) => line.match(/^\s*/)[0].length));
    return JSON.stringify(lines.map((line) => line.slice(indent)).join('\n')) + comma;
  });
  const json = heredocsExpanded.replace(/"(?:\\.|[^"\\])*"|\b([A-Za-z_]\w*):/g, (token, key) => key ? `"${key}":` : token);
  return JSON.parse(json.replace(/,\s*$/, ''));
}

function arrayStarting(marker) {
  const start = seed.indexOf(marker);
  if (start < 0) throw new Error(`Missing seed section: ${marker}`);
  const end = seed.indexOf('].each_with_index', start);
  if (end < 0) throw new Error('Missing array terminator');
  return literal(seed.slice(start, end + 1));
}

// Read only scalar messages; profile and document content come from seeds, not old locale fixtures.
function messages(locale) {
  const text = fs.readFileSync(path.join(railsRoot, `config/locales/${locale}.yml`), 'utf8');
  const stack = [];
  const result = {};
  for (const line of text.split('\n')) {
    const match = /^(\s*)([a-z_]+):(?:\s+(.*))?$/.exec(line);
    if (!match) continue;
    const [, whitespace, key, value] = match;
    const depth = whitespace.length / 2;
    stack.length = depth;
    stack[depth] = key;
    if (!value || !value.startsWith('"')) continue;
    const fullKey = stack.slice(1).join('.');
    const uiKey = fullKey.startsWith('home.index.') ? fullKey.slice(11) : fullKey;
    // Arrays and obsolete hardcoded biography fixtures are deliberately not imported.
    if (/^(meta\.|navigation\.|profile\.(section_label|code_label)$|skills\.(label|show_all|eyebrow|all_title|close)$|experience\.(label|tabs\.)|details\.|location\.label$|documents\.(label|generated\.|modal\.|resume\.)|projects\.|footer\.label$)/.test(uiKey)) {
      result[uiKey] = JSON.parse(value);
    }
  }
  return result;
}

const profileStart = seed.indexOf('profile.update!(') + 'profile.update!('.length;
const profileEnd = seed.indexOf('  email_subjects:', profileStart);
const profile = literal('{' + seed.slice(profileStart, profileEnd).replace(/,\s*$/, '') + '}');
delete profile.phone;
profile.avatar = 'assets/images/carlos-henrique-caldeira.png';
profile.resume = 'assets/documents/carlos-henrique-caldeira-curriculo.pdf';
const skills = arrayStarting('[\n  [ "Ruby & Ruby on Rails"').map(([name, category, color, featured]) => ({ name: name.trim(), category, color, featured }));
const experiences = arrayStarting('[\n  {\n    company:');
const educations = arrayStarting('[\n  {\n    courses:');
const projects = arrayStarting('[\n  [ "40%"').map(([metric, ptTitle, ptDescription, enTitle, enDescription], index) => ({
  id: `highlight-${index + 1}`, metric, titles: {pt: ptTitle, en: enTitle},
  descriptions: {pt: ptDescription, en: enDescription}, category: 'highlight',
  category_color: '#a78bfa', primary_language: '', external_url: '', source: 'manual'
}));
const documents = arrayStarting('[\n  {\n    content_kind:').map((document) => ({ ...document, id: document.content_kind }));
const translations = { pt: messages('pt'), en: messages('en') };
Object.assign(translations.pt, {
  'access.title': 'Vamos conversar?',
  'access.description': 'Conheça minha trajetória nos documentos ao lado, baixe o currículo em PDF ou entre em contato para conversar sobre uma oportunidade.',
  'access.email_button': 'Entrar em contato',
  'access.email_hint': 'Abre seu aplicativo de e-mail. Nenhuma mensagem é enviada automaticamente.',
  'access.resume_button': 'Baixar currículo',
  'access.subject': 'Contato pelo portfólio',
  'documents.generated.live_data': 'Conteúdo do portfólio',
  'projects.intro': 'Projetos públicos e destaques profissionais em um só catálogo.',
  'projects.categories.project': 'Projetos',
  'projects.categories.highlight': 'Destaques',
  'projects.categories.open_source': 'Open source',
  'projects.sources.manual': 'Portfólio',
  'projects.sources.github': 'GitHub',
  'projects.open_catalog': 'Abrir catálogo completo',
  'projects.count.one': '1 projeto',
  'projects.count.other': '%{count} projetos',
  'navigation.skip': 'Ir para o conteúdo',
  'navigation.enable_js': 'Ative o JavaScript para alternar idioma e tema e usar os filtros. Os documentos e o currículo continuam disponíveis abaixo.',
  'documents.static_title': 'Documentos profissionais',
  'documents.resume.unavailable': 'Caso a visualização não seja compatível com seu navegador, abra ou baixe o PDF pelos links acima.',
  'skills.categories.backend': 'Backend', 'skills.categories.cloud': 'Cloud',
  'skills.categories.database': 'Banco de dados', 'skills.categories.architecture': 'Arquitetura',
  'skills.categories.ai': 'Inteligência artificial', 'skills.categories.quality': 'Qualidade',
  'skills.categories.Frontend': 'Frontend', 'skills.categories.DevOps': 'DevOps',
  'skills.categories.Metodologias & Arquitetura': 'Metodologias e arquitetura'
});
Object.assign(translations.en, {
  'access.title': "Let's talk?",
  'access.description': 'Explore my professional background in the documents, download my PDF resume, or get in touch to discuss an opportunity.',
  'access.email_button': 'Get in touch',
  'access.email_hint': 'Opens your email application. No message is sent automatically.',
  'access.resume_button': 'Download resume',
  'access.subject': 'Portfolio contact',
  'documents.generated.live_data': 'Portfolio content',
  'projects.intro': 'Public projects and professional highlights in one catalog.',
  'projects.categories.project': 'Projects',
  'projects.categories.highlight': 'Highlights',
  'projects.categories.open_source': 'Open source',
  'projects.sources.manual': 'Portfolio',
  'projects.sources.github': 'GitHub',
  'projects.open_catalog': 'Open full catalog',
  'projects.count.one': '1 project',
  'projects.count.other': '%{count} projects',
  'navigation.skip': 'Skip to content',
  'navigation.enable_js': 'Enable JavaScript to change language and theme and use filters. Documents and the resume remain available below.',
  'documents.static_title': 'Professional documents',
  'documents.resume.unavailable': 'If your browser cannot display the preview, open or download the PDF using the links above.',
  'skills.categories.backend': 'Backend', 'skills.categories.cloud': 'Cloud',
  'skills.categories.database': 'Databases', 'skills.categories.architecture': 'Architecture',
  'skills.categories.ai': 'Artificial intelligence', 'skills.categories.quality': 'Quality',
  'skills.categories.Frontend': 'Frontend', 'skills.categories.DevOps': 'DevOps',
  'skills.categories.Metodologias & Arquitetura': 'Methods and architecture'
});
const data = { provenance: { source: 'db/seeds.rb', note: 'Versioned public content. Not an export of production or local database collections.' }, profile, skills, experiences, educations, projects, documents, messages: translations };
fs.mkdirSync(path.dirname(output), {recursive: true});
fs.writeFileSync(output, '/* Edit this file to update the static portfolio. No credentials belong here. */\n(function (root, factory) {\n  if (typeof module === "object" && module.exports) module.exports = factory();\n  else root.PortfolioData = factory();\n})(typeof globalThis !== "undefined" ? globalThis : this, function () {\n  return ' + JSON.stringify(data, null, 2) + ';\n});\n');
for (const [source, destination] of [
  ['app/assets/stylesheets/application.css', 'assets/css/application.css'],
  ['app/assets/images/carlos-henrique-caldeira.png', profile.avatar],
  ['public/documents/carlos-henrique-caldeira-curriculo.pdf', profile.resume]
]) {
  const target = path.join(root, destination);
  if (fs.existsSync(target)) throw new Error(`Refusing to overwrite ${destination}`);
  fs.mkdirSync(path.dirname(target), { recursive: true });
  fs.copyFileSync(path.join(railsRoot, source), target);
}
console.log(`Imported ${skills.length} skills, ${experiences.length} experiences, ${educations.length} education entries, ${projects.length} highlights and ${documents.length} documents from versioned source. Copied CSS, avatar and PDF.`);
