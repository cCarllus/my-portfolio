/* Shared by the browser and the optional Node build: one template, no framework. */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.PortfolioUI = factory();
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  'use strict';

  function escapeHtml(value) {
    return String(value == null ? '' : value).replace(/[&<>"']/g, function (character) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[character];
    });
  }

  function localized(value, locale) {
    if (value && typeof value === 'object') return value[locale] || value.pt || value.en || '';
    return value || '';
  }

  function translate(data, locale, key, params) {
    const message = data.messages[locale][key] || data.messages.pt[key];
    if (message == null) throw new Error('Missing translation: ' + key);
    return message.replace(/%\{([^}]+)\}/g, function (_, name) {
      return params && params[name] != null ? String(params[name]) : '';
    });
  }

  function safeUrl(value) {
    const url = String(value || '').trim();
    if (/[\u0000-\u0020\u007f\\]/.test(url)) return '';
    if (/^https?:\/\//i.test(url)) {
      try {
        const parsed = new URL(url);
        return parsed.hostname && !parsed.username && !parsed.password ? url : '';
      } catch (_) { return ''; }
    }
    if (/^mailto:[^?@]+@[^?@]+(?:\?[^\s]*)?$/i.test(url)) return url;
    if (/^assets\/[a-zA-Z0-9_./%\-]+(?:#[a-zA-Z0-9=._-]+)?$/.test(url) && !url.includes('..')) return url;
    if (/^#[a-zA-Z0-9_-]+$/.test(url)) return url;
    return '';
  }

  function safeColor(value) {
    return /^#[0-9a-f]{6}$/i.test(value || '') ? value : '#71717a';
  }

  function normalize(value) {
    return String(value || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim();
  }

  function filterProjects(projects, query, category, locale) {
    const normalized = normalize(query);
    return projects.filter(function (project) {
      const text = [localized(project.titles, locale), localized(project.descriptions, locale), project.primary_language].join(' ');
      return (category === 'all' || project.category === category) && normalize(text).includes(normalized);
    });
  }

  // A deliberately small Markdown subset. HTML is escaped before any formatting.
  function markdown(value) {
    function inline(text) {
      return escapeHtml(text).replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>').replace(/`([^`]+)`/g, '<code>$1</code>');
    }
    return String(value || '').trim().split(/\n\s*\n/).filter(Boolean).map(function (block) {
      const heading = /^(#{1,3})\s+(.+)$/.exec(block);
      if (heading) {
        const level = Math.min(heading[1].length + 1, 4);
        return '<h' + level + '>' + inline(heading[2]) + '</h' + level + '>';
      }
      if (/^\s*[-*]\s/.test(block)) {
        return '<ul>' + block.split(/\n(?=\s*[-*]\s)/).map(function (item) {
          return '<li>' + inline(item.replace(/^\s*[-*]\s/, '').replace(/\n\s*/g, ' ')) + '</li>';
        }).join('') + '</ul>';
      }
      return '<p>' + inline(block.replace(/\n\s*/g, ' ')) + '</p>';
    }).join('\n');
  }

  const iconPaths = {
    globe: '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a15 15 0 0 1 0 18M12 3a15 15 0 0 0 0 18"/>',
    sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2m0 16v2M4.93 4.93l1.42 1.42m11.3 11.3 1.42 1.42M2 12h2m16 0h2M4.93 19.07l1.42-1.42m11.3-11.3 1.42-1.42"/>',
    close: '<path d="m6 6 12 12M18 6 6 18"/>',
    mail: '<path d="M4 6h16v12H4zM4 7l8 6 8-6"/>',
    file: '<path d="M7 7h10M7 11h7M7 15h9"/>',
    search: '<circle cx="11" cy="11" r="7"/><path d="m16 16 4 4"/>',
    arrow: '<path d="M7 17 17 7M8 7h9v9"/>'
  };
  function icon(name) { return '<svg aria-hidden="true" viewBox="0 0 24 24">' + iconPaths[name] + '</svg>'; }
  function htmlText(data, locale, key, params) { return escapeHtml(translate(data, locale, key, params)); }
  function categoryLabel(data, locale, category) {
    return data.messages[locale]['skills.categories.' + category] || category;
  }

  function codeProfile(data, locale) {
    const profile = data.profile;
    const nameParts = profile.full_name.split(/\s+/);
    const className = escapeHtml((nameParts[0] + nameParts[nameParts.length - 1]).replace(/[^A-Za-z\u00c0-\u00ff0-9]/g, ''));
    const stack = data.skills.filter(function (skill) { return skill.featured; }).slice(0, 5);
    return `<div class="code-card__lines" aria-hidden="true">${Array.from({length: 16}, function (_, index) { return '<span>' + (index + 1) + '</span>'; }).join('')}</div>
<pre class="code-card__content" tabindex="0"><code><span class="code-keyword">class</span> <span class="code-class">${className}</span>
  <span class="code-keyword">def</span> <span class="code-method">initialize</span>
    <span class="code-instance">@name</span> <span class="code-operator">=</span> <span class="code-string">"${escapeHtml(profile.full_name)}"</span>
    <span class="code-instance">@role</span> <span class="code-operator">=</span> <span class="code-string">"${escapeHtml(localized(profile.roles, locale))}"</span>
    <span class="code-instance">@location</span> <span class="code-operator">=</span> <span class="code-string">"${escapeHtml(localized(profile.locations, locale))}"</span>
    <span class="code-instance">@stack</span> <span class="code-operator">=</span> <span class="code-punctuation">[</span>
      ${stack.map(function (skill) { return '<span class="code-value">"' + escapeHtml(skill.name) + '"</span>'; }).join('<span class="code-punctuation">,</span> ')}
    <span class="code-punctuation">]</span>
    <span class="code-instance">@philosophy</span> <span class="code-operator">=</span> <span class="code-string">"${escapeHtml(localized(profile.philosophies, locale))}"</span>
  <span class="code-keyword">end</span>
<span class="code-keyword">end</span>

<span class="code-keyword">if</span> <span class="code-constant">__FILE__</span> <span class="code-operator">==</span> <span class="code-global">$PROGRAM_NAME</span>
  <span class="code-name">me</span> <span class="code-operator">=</span> <span class="code-class">${className}</span><span class="code-punctuation">.</span><span class="code-method">new</span>
  <span class="code-method">puts</span> <span class="code-name">me</span><span class="code-cursor" aria-hidden="true">|</span>
<span class="code-keyword">end</span></code></pre>`;
  }

  function skillLanes(data) {
    const preview = data.skills.slice(0, 8);
    return [0, 1].map(function (parity) {
      const pills = preview.filter(function (_, index) { return index % 2 === parity; }).map(function (skill) {
        return '<span class="skill-pill" style="--skill-color: ' + safeColor(skill.color) + '">' + escapeHtml(skill.name) + '</span>';
      }).join('');
      return '<div class="skill-lane ' + (parity ? 'skill-lane--reverse' : '') + '"><div class="skill-lane__track"><div class="skill-lane__sequence">' + pills + '</div><div class="skill-lane__sequence" aria-hidden="true">' + pills + '</div></div></div>';
    }).join('');
  }

  function timeline(items) {
    return items.map(function (item) {
      return '<div class="timeline__item"><div><strong>' + escapeHtml(item.name) + '</strong><span>' + escapeHtml(item.role) + '</span></div><span class="timeline__period">' + escapeHtml(item.period) + '</span></div>';
    }).join('');
  }

  function intro(data, locale, key, params) {
    return '<header class="file-showcase__intro"><span>' + htmlText(data, locale, 'documents.generated.live_data') + '</span><p>' + htmlText(data, locale, key, params) + '</p></header>';
  }

  function projectCatalog(data, locale) {
    const t = function (key, params) { return htmlText(data, locale, key, params); };
    const countKey = data.projects.length === 1 ? 'projects.count.one' : 'projects.count.other';
    return `<div class="projects-catalog">
<header class="file-showcase__intro projects-catalog__intro"><div><span>${t('documents.generated.live_data')}</span><p>${t('projects.intro')}</p></div><strong data-project-count role="status" aria-live="polite" aria-atomic="true">${t(countKey, {count: data.projects.length})}</strong></header>
<div data-project-controls hidden>
  <div class="projects-catalog__search">${icon('search')}<input type="search" id="project-search" data-project-search placeholder="${t('projects.search')}" aria-label="${t('projects.search')}"></div>
  <div class="projects-catalog__filters" role="group" aria-label="${t('projects.filter_label')}">
  ${['all', 'project', 'highlight', 'open_source'].map(function (category) {
    return '<button type="button" class="' + (category === 'all' ? 'is-active' : '') + '" data-category="' + category + '" aria-pressed="' + (category === 'all') + '"><i aria-hidden="true" style="--project-color: #a78bfa"></i>' + t(category === 'all' ? 'projects.all' : 'projects.categories.' + category) + '</button>';
  }).join('')}
  </div>
</div>
<div class="projects-catalog__grid">${data.projects.map(function (project) {
  const url = safeUrl(project.external_url);
  const searchText = [localized(project.titles, locale), localized(project.descriptions, locale), project.primary_language].join(' ');
  return `<article class="project-card" data-project-item data-category="${escapeHtml(project.category)}" data-search-text="${escapeHtml(searchText)}">
<header><span class="project-card__category" style="--project-color: ${safeColor(project.category_color)}"><i aria-hidden="true"></i>${t('projects.categories.' + project.category)}</span><small>${t('projects.sources.' + project.source)}</small></header>
<h3>${escapeHtml(localized(project.titles, locale))}</h3><div class="project-card__description">${markdown(localized(project.descriptions, locale))}</div>
<footer><span>${escapeHtml(project.metric || project.primary_language || translate(data, locale, 'projects.portfolio'))}</span>${url ? '<a href="' + escapeHtml(url) + '" target="_blank" rel="noopener noreferrer" aria-label="' + t('projects.open', {name: localized(project.titles, locale)}) + '">' + t('projects.view') + icon('arrow') + '</a>' : ''}</footer>
</article>`;
  }).join('')}</div>
<p class="projects-catalog__empty" data-project-empty hidden>${t('projects.empty')}</p>
</div>`;
  }

  function documentContent(document, data, locale) {
    const t = function (key, params) { return htmlText(data, locale, key, params); };
    switch (document.content_kind) {
      case 'experience':
        return '<div class="experience-file">' + intro(data, locale, 'documents.generated.experience_intro') + '<div class="experience-file__timeline">' + data.experiences.map(function (item, index) {
          return '<article><div class="experience-file__marker"><span>' + (index + 1) + '</span></div><div class="experience-file__content"><header><div><h3>' + escapeHtml(item.company) + '</h3><p>' + escapeHtml(localized(item.roles, locale)) + '</p></div><span class="experience-file__period">' + escapeHtml(item.period) + '</span></header><span class="experience-file__location">' + escapeHtml(localized(item.locations, locale)) + '</span><div class="experience-file__summary">' + markdown(localized(item.summaries, locale)) + '</div></div></article>';
        }).join('') + '</div></div>';
      case 'skills': {
        const groups = data.skills.reduce(function (result, skill) { (result[skill.category] || (result[skill.category] = [])).push(skill); return result; }, Object.create(null));
        return '<div class="skills-file">' + intro(data, locale, 'documents.generated.skills_intro', {count: data.skills.length}) + '<div class="skills-file__groups">' + Object.keys(groups).map(function (category) {
          return '<section><header><span aria-hidden="true"></span><h3>' + escapeHtml(categoryLabel(data, locale, category)) + '</h3><small>' + String(groups[category].length).padStart(2, '0') + '</small></header><div>' + groups[category].map(function (skill) {
            return '<span class="skills-file__pill" style="--skill-color: ' + safeColor(skill.color) + '"><i aria-hidden="true"></i>' + escapeHtml(skill.name) + '</span>';
          }).join('') + '</div></section>';
        }).join('') + '</div></div>';
      }
      case 'highlights': return projectCatalog(data, locale);
      case 'education':
        return '<div class="education-file">' + intro(data, locale, 'documents.generated.education_intro') + '<div class="education-file__list">' + data.educations.map(function (item, index) {
          return '<article><div class="education-file__year" aria-hidden="true">' + String(index + 1).padStart(2, '0') + '</div><div><span>' + escapeHtml(localized(item.statuses, locale)) + '</span><h3>' + escapeHtml(localized(item.courses, locale)) + '</h3><p>' + escapeHtml(localized(item.institutions, locale)) + '</p></div></article>';
        }).join('') + '</div></div>';
      case 'resume': {
        const resume = escapeHtml(safeUrl(data.profile.resume));
        return '<div class="document-panel__lead">' + markdown(localized(document.bodies, locale)) + '</div><div class="resume-actions"><a href="' + resume + '" target="_blank" rel="noopener noreferrer">' + t('documents.resume.open') + '</a><a href="' + resume + '" download="Carlos_Henrique_Caldeira_Curriculo.pdf">' + t('documents.resume.download') + '</a></div><p>' + t('documents.resume.unavailable') + '</p><iframe class="resume-preview" data-src="' + resume + '#view=FitH" title="' + t('documents.resume.iframe_title') + '" loading="lazy"></iframe>';
      }
      default: return '<div class="document-panel__lead">' + markdown(localized(document.bodies, locale)) + '</div>';
    }
  }

  function renderSite(data, locale) {
    const t = function (key, params) { return htmlText(data, locale, key, params); };
    const profile = data.profile;
    const projectDocument = data.documents.find(function (item) { return item.content_kind === 'highlights'; });
    const skillsDocument = data.documents.find(function (item) { return item.content_kind === 'skills'; });
    const tabs = {
      work: data.experiences.map(function (item) { return {name: item.company, role: localized(item.roles, locale), period: item.period}; }),
      projects: data.projects.slice(0, 3).map(function (item) { return {name: localized(item.titles, locale), role: localized(item.descriptions, locale), period: item.metric || item.primary_language}; }),
      education: data.educations.map(function (item) { return {name: localized(item.courses, locale), role: localized(item.institutions, locale), period: localized(item.statuses, locale)}; })
    };
    const mail = safeUrl('mailto:' + profile.contact_email + '?subject=' + encodeURIComponent(translate(data, locale, 'access.subject')));
    const links = [ ['E-mail', safeUrl('mailto:' + profile.contact_email)], ['LinkedIn', safeUrl(profile.linkedin_url)], ['GitHub', safeUrl(profile.github_url)] ];
    return `<a class="skip-link" href="#main-content">${t('navigation.skip')}</a>
<main id="main-content" class="portfolio-shell">
  <h1 class="sr-only">${escapeHtml(profile.full_name)} — ${escapeHtml(localized(profile.roles, locale))}</h1>
  <nav class="portfolio-nav panel" aria-label="${t('navigation.label')}">
    <div class="identity"><img class="identity__avatar" src="${escapeHtml(safeUrl(profile.avatar))}" alt="${t('navigation.avatar_alt')}" width="28" height="28"><span>${t('navigation.greeting_dynamic', {name: profile.full_name, nickname: profile.nickname})} <span aria-hidden="true">👋</span></span></div>
    <div class="nav-tools">
      <label class="language-picker"><span class="sr-only">${t('navigation.language_label')}</span>${icon('globe')}<select id="locale" data-locale aria-label="${t('navigation.language_label')}"><option value="pt"${locale === 'pt' ? ' selected' : ''}>PT</option><option value="en"${locale === 'en' ? ' selected' : ''}>EN</option></select></label>
      <div class="local-time" aria-label="${t('navigation.local_time')}">${icon('sun')}<time data-clock-time></time><time data-clock-date></time></div>
      <button class="theme-toggle" type="button" data-theme-toggle aria-label="${t('navigation.change_theme')}" aria-pressed="true"><span class="theme-toggle__track" aria-hidden="true"><span></span></span><span class="theme-label" data-theme-label>${t('navigation.dark')}</span></button>
    </div>
  </nav>
  <noscript><p class="panel portfolio-notice">${t('navigation.enable_js')}</p></noscript>
  <section class="portfolio-grid portfolio-grid--top" aria-label="${t('profile.section_label')}">
    <article class="code-card panel" aria-label="${t('profile.code_label')}">${codeProfile(data, locale)}</article>
    <article class="skills-card panel" aria-label="${t('skills.label')}"><div class="skills-marquee">${skillLanes(data)}</div>${skillsDocument ? '<a class="skills-card__all" href="#document-' + escapeHtml(skillsDocument.id) + '" data-document="' + escapeHtml(skillsDocument.id) + '" data-skills-preview>' + t('skills.show_all', {count: data.skills.length}) + '</a>' : ''}</article>
    <article class="experience-card panel">
      <div class="tabs" data-tabs aria-label="${t('experience.label')}">${Object.keys(tabs).map(function (name, index) { return '<a href="#' + name + '-panel" id="' + name + '-tab" class="tab ' + (index === 0 ? 'tab--active' : '') + '" data-tab="' + name + '">' + t('experience.tabs.' + name) + '</a>'; }).join('')}</div>
      ${Object.keys(tabs).map(function (name) { return '<div class="timeline" id="' + name + '-panel" data-tab-panel="' + name + '" aria-labelledby="' + name + '-tab">' + timeline(tabs[name]) + (name === 'projects' && projectDocument ? '<a class="catalog-link" href="#document-' + escapeHtml(projectDocument.id) + '" data-document="' + escapeHtml(projectDocument.id) + '">' + t('projects.open_catalog') + icon('arrow') + '</a>' : '') + '</div>'; }).join('')}
    </article>
  </section>
  <section class="portfolio-grid portfolio-grid--bottom" aria-label="${t('details.section_label')}">
    <article class="map-card panel" aria-label="${t('location.label')}"><div class="location-pin" tabindex="0" aria-label="${escapeHtml(localized(profile.map_labels, locale))}" style="left: ${Math.min(90, Math.max(10, Number(profile.map_x_percent) || 35))}%; top: ${Math.min(90, Math.max(10, Number(profile.map_y_percent) || 60))}%;"><span class="location-pin__pulse" aria-hidden="true"></span><span class="location-pin__dot" aria-hidden="true"></span><span class="location-pin__tooltip">${escapeHtml(localized(profile.map_labels, locale))}</span></div><p class="map-card__caption">${escapeHtml(localized(profile.map_labels, locale))}</p></article>
    <article class="access-card panel"><div class="access-card__tab" aria-hidden="true">${icon('mail')}</div><div class="access-card__content"><h2>${t('access.title')}</h2><p>${t('access.description')}</p><div class="contact-actions"><a class="contact-action" href="${escapeHtml(mail)}">${t('access.email_button')}</a><a class="contact-action contact-action--secondary" href="${escapeHtml(safeUrl(profile.resume))}" download="Carlos_Henrique_Caldeira_Curriculo.pdf">${t('access.resume_button')}</a></div><p class="contact-hint">${t('access.email_hint')}</p><a class="contact-email" href="${escapeHtml(safeUrl('mailto:' + profile.contact_email))}">${escapeHtml(profile.contact_email)}</a></div></article>
    <article class="documents-card panel" aria-label="${t('documents.label')}"><div class="documents-grid">${data.documents.map(function (document) { return '<a class="document" href="#document-' + escapeHtml(document.id) + '" data-document="' + escapeHtml(document.id) + '"><span class="document__icon">' + (document.content_kind === 'resume' ? '<span class="document__pdf">PDF</span>' : icon('file')) + '<span class="document__fold" aria-hidden="true"></span></span><span>' + escapeHtml(localized(document.titles, locale)) + '</span></a>'; }).join('')}</div></article>
  </section>
  <footer class="portfolio-footer panel"><nav aria-label="${t('footer.label')}">${links.filter(function (link) { return link[1]; }).map(function (link) { return '<a href="' + escapeHtml(link[1]) + '"' + (link[1].startsWith('http') ? ' target="_blank" rel="noopener noreferrer"' : '') + '>' + escapeHtml(link[0]) + '</a>'; }).join('')}</nav></footer>
  <section class="static-documents panel" data-static-documents aria-label="${t('documents.static_title')}">
    ${data.documents.map(function (document) { return '<section class="document-panel document-panel--' + escapeHtml(document.content_kind) + '" id="document-' + escapeHtml(document.id) + '" data-document-panel="' + escapeHtml(document.id) + '"><h2 class="static-document-title">' + escapeHtml(localized(document.titles, locale)) + '</h2>' + documentContent(document, data, locale) + '</section>'; }).join('\n')}
  </section>
  <dialog id="document-dialog" class="document-modal" aria-labelledby="document-modal-title"><div class="document-modal__surface"><header class="document-modal__header"><div><span>${t('documents.modal.eyebrow')}</span><h2 id="document-modal-title" data-document-title></h2></div><button class="document-modal__close" type="button" data-close-dialog aria-label="${t('documents.modal.close')}">${icon('close')}</button></header><div class="document-modal__body" data-document-body></div></div></dialog>
  <dialog id="skills-dialog" class="skills-modal" aria-labelledby="skills-modal-title"><div class="skills-modal__surface"><header class="document-modal__header"><div><span>${t('skills.eyebrow')}</span><h2 id="skills-modal-title">${t('skills.all_title')}</h2></div><button class="document-modal__close" type="button" data-close-dialog aria-label="${t('skills.close')}">${icon('close')}</button></header><div class="skills-modal__grid">${data.skills.map(function (skill) { return '<div class="skills-modal__item"><span class="skill-color-dot" style="--skill-color: ' + safeColor(skill.color) + '"></span><div><strong>' + escapeHtml(skill.name) + '</strong><small>' + escapeHtml(categoryLabel(data, locale, skill.category)) + '</small></div></div>'; }).join('')}</div></div></dialog>
</main>`;
  }

  function renderPage(data, locale) {
    return `<!doctype html>
<html lang="${locale === 'pt' ? 'pt-BR' : 'en'}" data-theme="dark">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${htmlText(data, locale, 'meta.title')}</title>
  <meta name="description" content="${htmlText(data, locale, 'meta.description')}">
  <meta name="application-name" content="${htmlText(data, locale, 'meta.application_name')}">
  <meta name="color-scheme" content="dark light">
  <link rel="icon" href="${escapeHtml(safeUrl(data.profile.avatar))}" type="image/png">
  <link rel="apple-touch-icon" href="${escapeHtml(safeUrl(data.profile.avatar))}">
  <script src="assets/js/theme-init.js"></script>
  <link rel="stylesheet" href="assets/css/application.css">
  <link rel="stylesheet" href="assets/css/static.css">
  <script src="assets/js/content.js" defer></script>
  <script src="assets/js/ui.js" defer></script>
  <script src="assets/js/app.js" defer></script>
</head>
<body>
<div id="portfolio-root">${renderSite(data, locale)}</div>
</body>
</html>
`;
  }

  return { escapeHtml, localized, translate, safeUrl, safeColor, normalize, filterProjects, markdown, renderSite, renderPage };
});
