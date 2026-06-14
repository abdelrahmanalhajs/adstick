'use strict';

// Cache version — tied to Flutter build. Change triggers cache clear + re-download.
const CACHE = 'adstick-driver-2084505018';

// Critical files to pre-cache on install
const PRECACHE = [
  './',
  './index.html',
  './flutter.js',
  './flutter_bootstrap.js',
  './main.dart.js',
  './assets/FontManifest.json',
  './assets/AssetManifest.bin.json',
  './version.json',
];

// WASM + font byte patterns → cache-first (immutable once cached)
const CACHE_FIRST = [/\.wasm$/, /\.mjs$/, /assets\/fonts\//];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE)
      .then(c => c.addAll(PRECACHE.map(u => new Request(u, {cache: 'reload'}))))
      .then(() => self.skipWaiting())
      .catch(err => {
        // Pre-cache failure is non-fatal — we'll cache on first use instead
        console.warn('[SW] Pre-cache failed, will cache on first use:', err);
        return self.skipWaiting();
      })
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(
        keys.filter(k => k !== CACHE).map(k => caches.delete(k))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;

  const url = new URL(event.request.url);
  // Only cache same-origin requests
  if (url.origin !== location.origin) return;

  const useCacheFirst = CACHE_FIRST.some(p => p.test(url.pathname));

  if (useCacheFirst) {
    // WASM / fonts: serve from cache immediately, fetch+update in background
    event.respondWith(
      caches.open(CACHE).then(cache =>
        cache.match(event.request).then(cached => {
          const fresh = fetch(event.request).then(resp => {
            if (resp.ok) cache.put(event.request, resp.clone());
            return resp;
          }).catch(() => cached);
          return cached || fresh;
        })
      )
    );
  } else {
    // JS / HTML: network-first so updates land immediately; cache as fallback
    event.respondWith(
      caches.open(CACHE).then(cache =>
        fetch(event.request)
          .then(resp => {
            if (resp.ok) cache.put(event.request, resp.clone());
            return resp;
          })
          .catch(() => cache.match(event.request))
      )
    );
  }
});
