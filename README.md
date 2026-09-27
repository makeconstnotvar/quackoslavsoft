# Quackoslav Software site

Static bilingual site for `quackoslavsoft.ru`. The Russian page is at `/`; the English page is at `/en/`. There is no build step or JavaScript.

## Files

- `index.html` — Russian page
- `en/index.html` — English page
- `styles.css` — shared design
- `assets/quackoslav-logo.png` — original transparent mascot artwork
- `assets/quackoslav-hero.webp`, `assets/quackoslav-icon.webp`, `assets/quackoslav-favicon.png`, `assets/quackoslav-social.png` — optimized page and social images
- `robots.txt`, `sitemap.xml` — indexing metadata

## Deployment

The production files are served by Caddy from `/var/www/quackoslavsoft.ru/current` on the Hermes server. The site block is in `/etc/caddy/Caddyfile`. DNS is managed in Timeweb: the apex A record points to the server; `www` is a CNAME to the apex. Caddy manages HTTPS certificates automatically when DNS resolves publicly.

Run `./scripts/deploy.sh` to publish the static files to Hermes. It defaults to
`root@82.26.193.46`; pass another `user@host` as the argument if server access
changes. SSH asks for a password if no authorized key is available. The script
copies the site with `tar`, keeps a backup of the previous site outside the
public directory, and verifies the Russian and English pages and stylesheet
over HTTPS. Use `./scripts/deploy.sh --dry-run` to list the files it would copy.

The website contains no checkout or contact form. License prices appear here;
checkout and delivery details belong on the individual product sites.
Static-file updates do not require a Caddy reload.
