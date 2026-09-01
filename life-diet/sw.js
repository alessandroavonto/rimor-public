/* Life Diet — service worker.
   L'app deve funzionare in aereo, in hotel e in cantina di un ristorante:
   la copia locale è la copia buona, la rete serve solo ad aggiornarla. */
const CACHE = "life-diet-v1";
const FILE = ["./", "./index.html", "./manifest.webmanifest", "./icone/icona-192.png", "./icone/icona-512.png"];

self.addEventListener("install", function(e){
  e.waitUntil(caches.open(CACHE).then(function(c){ return c.addAll(FILE); }).then(function(){ return self.skipWaiting(); }));
});

self.addEventListener("activate", function(e){
  e.waitUntil(caches.keys().then(function(chiavi){
    return Promise.all(chiavi.filter(function(k){ return k !== CACHE; }).map(function(k){ return caches.delete(k); }));
  }).then(function(){ return self.clients.claim(); }));
});

self.addEventListener("fetch", function(e){
  const req = e.request;
  if(req.method !== "GET") return;
  const url = new URL(req.url);
  if(url.origin !== location.origin) return;   // i font di Google li gestisce il browser
  e.respondWith(
    caches.match(req).then(function(cache){
      const rete = fetch(req).then(function(r){
        if(r && r.status === 200){
          const copia = r.clone();
          caches.open(CACHE).then(function(c){ c.put(req, copia); });
        }
        return r;
      }).catch(function(){ return cache; });
      return cache || rete;
    })
  );
});
