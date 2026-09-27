# Quackoslav Software site

Static bilingual site for `quackoslavsoft.ru`. The Russian page is at `/`; the English page is at `/en/`. There is no build step or JavaScript.

## Files

- `index.html` — Russian page
- `en/index.html` — English page
- `styles.css` — shared design
- `assets/quackoslav-logo.png` — transparent mascot logo
- `robots.txt`, `sitemap.xml` — indexing metadata

## Deployment

The production files are served by Caddy from `/var/www/quackoslavsoft.ru/current` on the Hermes server. The site block is in `/etc/caddy/Caddyfile`. DNS is managed in Timeweb: the apex A record points to the server; `www` is a CNAME to the apex. Caddy manages HTTPS certificates automatically when DNS resolves publicly.

Copy changed static files to the production directory, validate Caddy if its configuration changed, and check both language routes over HTTPS. The website contains no checkout or contact form; sales details belong on the individual product sites.
