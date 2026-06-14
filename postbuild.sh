#!/usr/bin/env bash
# postbuild.sh — replaces Flutter's self-destructing SW with a real caching one
# Run after each "flutter build web" for all 3 apps
set -e

patch_app() {
  local BUILD="$1"   # path to build/web
  local DEPLOY="$2"  # path to deployed directory
  local APP_NAME="$3"

  echo "Patching $APP_NAME..."

  # Extract the SW version Flutter embedded (used as cache key)
  SW_VER=$(grep -o 'serviceWorkerVersion: "[0-9]*"' "$BUILD/flutter_bootstrap.js" \
    | grep -o '[0-9]*' | head -1)
  [ -z "$SW_VER" ] && SW_VER=$(date +%s)

  # Keep serviceWorkerSettings intact — Flutter uses it to register our
  # custom caching SW at the correct URL (now that base-href is right).
  # Flutter will find the SW already active on repeat visits and proceed
  # immediately, giving fast cached loads.

  # Build file list for pre-cache (all same-origin critical files)
  cat > "$BUILD/flutter_service_worker.js" <<SW_EOF
'use strict';

// Cache version — tied to Flutter build. Change triggers cache clear + re-download.
const CACHE = 'adstick-${APP_NAME}-${SW_VER}';

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
SW_EOF

  echo "  ✓ Wrote flutter_service_worker.js (cache: adstick-${APP_NAME}-${SW_VER})"

  # Sync to deploy directory
  rsync -a --delete "$BUILD/" "$DEPLOY/"
  echo "  ✓ Deployed to $DEPLOY"
}

BASE="/Users/abdelrahmanalhaj/Documents/Claude/Projects/Ads"

patch_app "$BASE/adstick_admin/build/web"      "$BASE/admin"      "admin"
patch_app "$BASE/adstick_driver/build/web"     "$BASE/driver"     "driver"
patch_app "$BASE/adstick_advertiser/build/web" "$BASE/advertiser" "advertiser"

echo ""
echo "✅ All 3 apps patched and deployed."
