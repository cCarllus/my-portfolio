(function () {
  'use strict';
  // Storage is optional: privacy modes must not prevent the site from loading.
  try {
    document.documentElement.dataset.theme = localStorage.getItem('portfolio-theme') === 'light' ? 'light' : 'dark';
  } catch (_) {
    document.documentElement.dataset.theme = 'dark';
  }
})();
