(function () {
  'use strict';
  const data = window.PortfolioData;
  const ui = window.PortfolioUI;
  const root = document.getElementById('portfolio-root');
  if (!data || !ui || !root) return;

  const storage = {
    get: function (key) { try { return localStorage.getItem(key); } catch (_) { return null; } },
    set: function (key, value) { try { localStorage.setItem(key, value); } catch (_) { /* Preferences are optional. */ } }
  };
  const requestedLocale = new URLSearchParams(location.search).get('locale');
  let locale = requestedLocale === null ? storage.get('portfolio-locale') : requestedLocale;
  locale = locale === 'en' ? 'en' : 'pt';
  let category = 'all';
  let selectedTab = 'work';
  let theme = document.documentElement.dataset.theme === 'light' ? 'light' : 'dark';
  const canUseDialogs = typeof HTMLDialogElement !== 'undefined' && typeof HTMLDialogElement.prototype.showModal === 'function';

  function setHash(hash) {
    const url = new URL(location.href);
    url.hash = hash;
    try { history.replaceState(null, '', url.href); } catch (_) { /* file:// can restrict history changes. */ }
  }

  function applyTheme() {
    document.documentElement.dataset.theme = theme;
    const button = root.querySelector('[data-theme-toggle]');
    button.setAttribute('aria-pressed', String(theme === 'dark'));
    root.querySelector('[data-theme-label]').textContent = ui.translate(data, locale, 'navigation.' + theme);
  }

  function renderClock() {
    const now = new Date();
    const language = locale === 'pt' ? 'pt-BR' : 'en-US';
    const time = root.querySelector('[data-clock-time]');
    const date = root.querySelector('[data-clock-date]');
    if (!time || !date) return;
    time.textContent = new Intl.DateTimeFormat(language, {hour: '2-digit', minute: '2-digit'}).format(now);
    date.textContent = new Intl.DateTimeFormat(language, {day: '2-digit', month: 'short', year: 'numeric'}).format(now);
    time.dateTime = date.dateTime = now.toISOString();
  }

  function selectTab(name, focus) {
    selectedTab = name;
    root.querySelector('[data-tabs]').setAttribute('role', 'tablist');
    root.querySelectorAll('[data-tab]').forEach(function (tab) {
      const active = tab.dataset.tab === name;
      tab.setAttribute('role', 'tab');
      tab.setAttribute('aria-controls', tab.dataset.tab + '-panel');
      tab.setAttribute('aria-selected', String(active));
      tab.tabIndex = active ? 0 : -1;
      tab.classList.toggle('tab--active', active);
      if (active && focus) tab.focus();
    });
    root.querySelectorAll('[data-tab-panel]').forEach(function (panel) {
      panel.setAttribute('role', 'tabpanel');
      panel.tabIndex = 0;
      panel.hidden = panel.dataset.tabPanel !== name;
    });
  }

  function filterProjects() {
    const search = root.querySelector('[data-project-search]');
    if (!search) return;
    const query = ui.normalize(search.value);
    let visible = 0;
    root.querySelectorAll('[data-project-item]').forEach(function (item) {
      item.hidden = !((category === 'all' || item.dataset.category === category) && ui.normalize(item.dataset.searchText).includes(query));
      if (!item.hidden) visible += 1;
    });
    root.querySelectorAll('button[data-category]').forEach(function (button) {
      const active = button.dataset.category === category;
      button.classList.toggle('is-active', active);
      button.setAttribute('aria-pressed', String(active));
    });
    root.querySelector('[data-project-count]').textContent = ui.translate(data, locale, visible === 1 ? 'projects.count.one' : 'projects.count.other', {count: visible});
    root.querySelector('[data-project-empty]').hidden = visible !== 0;
  }

  function showDialog(dialog, opener) {
    if (dialog.open) return;
    dialog.returnFocus = opener || document.activeElement;
    dialog.showModal();
    document.body.classList.add('modal-open');
  }

  function openDocument(id, opener) {
    const item = data.documents.find(function (document) { return document.id === id; });
    if (!item || !canUseDialogs) return;
    const panel = document.getElementById('document-' + id);
    root.querySelectorAll('[data-document-panel]').forEach(function (candidate) { candidate.hidden = candidate !== panel; });
    root.querySelector('[data-document-title]').textContent = ui.localized(item.titles, locale);
    showDialog(document.getElementById('document-dialog'), opener);
    root.querySelector('[data-document-body]').scrollTop = 0;
    panel.querySelectorAll('iframe[data-src]').forEach(function (frame) {
      if (!frame.getAttribute('src')) frame.setAttribute('src', frame.dataset.src);
    });
    setHash('document-' + id);
  }

  function openHash() {
    const match = /^#document-([a-zA-Z0-9_-]+)$/.exec(location.hash);
    if (!match) return;
    const opener = Array.from(root.querySelectorAll('[data-document]')).find(function (link) { return link.dataset.document === match[1]; });
    openDocument(match[1], opener);
  }

  function enhanceDocuments() {
    if (!canUseDialogs) return;
    const body = root.querySelector('[data-document-body]');
    // Move the pre-rendered sections, rather than duplicate or fetch their content.
    root.querySelectorAll('[data-document-panel]').forEach(function (panel) {
      panel.hidden = true;
      body.appendChild(panel);
    });
    root.querySelector('[data-static-documents]').hidden = true;
    root.querySelectorAll('dialog').forEach(function (dialog) {
      dialog.addEventListener('click', function (event) {
        if (event.target !== dialog) return;
        const rect = dialog.getBoundingClientRect();
        if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) dialog.close();
      });
      dialog.addEventListener('close', function () {
        if (!root.querySelector('dialog[open]')) {
          document.body.classList.remove('modal-open');
          if (location.hash.startsWith('#document-')) setHash('');
          if (dialog.returnFocus && dialog.returnFocus.isConnected) dialog.returnFocus.focus({preventScroll: true});
        }
      });
    });
  }

  function render(focusLocale) {
    document.body.classList.remove('modal-open');
    root.innerHTML = ui.renderSite(data, locale);
    document.documentElement.lang = locale === 'pt' ? 'pt-BR' : 'en';
    document.title = ui.translate(data, locale, 'meta.title');
    document.querySelector('meta[name="description"]').content = ui.translate(data, locale, 'meta.description');
    document.querySelector('meta[name="application-name"]').content = ui.translate(data, locale, 'meta.application_name');
    enhanceDocuments();
    selectTab(selectedTab, false);
    category = 'all';
    root.querySelectorAll('[data-project-controls]').forEach(function (controls) { controls.hidden = false; });
    filterProjects();
    applyTheme();
    renderClock();
    document.documentElement.classList.add('js');
    if (focusLocale) root.querySelector('[data-locale]').focus({preventScroll: true});
    openHash();
  }

  root.addEventListener('click', function (event) {
    const target = event.target.closest('a, button');
    if (!target || !root.contains(target)) return;
    // Preserve normal browser behavior for modified clicks and opening anchors in new tabs.
    if (target.tagName === 'A' && (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey || event.button !== 0)) return;
    if (target.hasAttribute('data-theme-toggle')) {
      theme = theme === 'dark' ? 'light' : 'dark';
      storage.set('portfolio-theme', theme);
      applyTheme();
    } else if (target.hasAttribute('data-close-dialog')) {
      target.closest('dialog').close();
    } else if (target.hasAttribute('data-document') && canUseDialogs) {
      event.preventDefault();
      if (target.hasAttribute('data-skills-preview')) showDialog(document.getElementById('skills-dialog'), target);
      else openDocument(target.dataset.document, target);
    } else if (target.hasAttribute('data-tab')) {
      event.preventDefault();
      selectTab(target.dataset.tab, false);
    } else if (target.matches('button[data-category]')) {
      category = target.dataset.category;
      filterProjects();
    }
  });

  root.addEventListener('keydown', function (event) {
    const tab = event.target.closest('[data-tab]');
    if (!tab) return;
    const tabs = Array.from(root.querySelectorAll('[data-tab]'));
    let index = tabs.indexOf(tab);
    if (event.key === 'ArrowRight') index = (index + 1) % tabs.length;
    else if (event.key === 'ArrowLeft') index = (index + tabs.length - 1) % tabs.length;
    else if (event.key === 'Home') index = 0;
    else if (event.key === 'End') index = tabs.length - 1;
    else if (event.key !== ' ' && event.key !== 'Enter') return;
    event.preventDefault();
    selectTab(tabs[index].dataset.tab, true);
  });

  root.addEventListener('input', function (event) {
    if (event.target.matches('[data-project-search]')) filterProjects();
  });

  root.addEventListener('change', function (event) {
    if (!event.target.matches('[data-locale]')) return;
    locale = event.target.value === 'en' ? 'en' : 'pt';
    storage.set('portfolio-locale', locale);
    const url = new URL(location.href);
    url.searchParams.set('locale', locale);
    try { history.replaceState(null, '', url.href); } catch (_) { /* The current page still changes on file://. */ }
    render(true);
  });

  window.addEventListener('hashchange', openHash);
  document.addEventListener('visibilitychange', function () { if (!document.hidden) renderClock(); });
  render(false);
  window.setInterval(renderClock, 30000);
})();
