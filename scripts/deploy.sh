#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./scripts/deploy.sh [--dry-run] [user@host]

Publishes the static site to Hermes. The default target is root@82.26.193.46.
SSH may ask for the server password; the script does not store credentials.
EOF
}

dry_run=false
if [[ ${1:-} == --help || ${1:-} == -h ]]; then
  usage
  exit 0
fi
if [[ ${1:-} == --dry-run ]]; then
  dry_run=true
  shift
fi
if (( $# > 1 )); then
  usage >&2
  exit 2
fi

target=${1:-root@82.26.193.46}
remote_root=/var/www/quackoslavsoft.ru
remote_site=$remote_root/current
backup_dir=$remote_root/backups/$(date -u +%Y%m%dT%H%M%SZ)-$$
repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"

for command in ssh tar curl cmp mktemp; do
  command -v "$command" >/dev/null || { printf 'Missing command: %s\n' "$command" >&2; exit 1; }
done

files=(index.html en/index.html styles.css robots.txt sitemap.xml assets)
tmp_dir=$(mktemp -d /tmp/quackoslav-deploy.XXXXXXXX)
control_socket=$tmp_dir/ssh.sock
cleanup() {
  ssh -S "$control_socket" -O exit "$target" >/dev/null 2>&1 || true
  rm -rf -- "$tmp_dir"
}
trap cleanup EXIT
ssh_options=(-o ConnectTimeout=10 -o ControlMaster=auto -o ControlPersist=120 -o "ControlPath=$control_socket")

printf 'Target: %s:%s\n' "$target" "$remote_site"
ssh "${ssh_options[@]}" "$target" \
  "command -v tar >/dev/null && command -v cp >/dev/null && test -d '$remote_site' && test -w '$remote_site'"

if [[ $dry_run == true ]]; then
  printf 'Files that would be copied:\n'
  printf '%s\n' "${files[@]}"
  printf 'Dry run complete; no files changed.\n'
  exit 0
fi

ssh "${ssh_options[@]}" "$target" \
  "mkdir -p '$backup_dir' && cp -a '$remote_site/.' '$backup_dir/'"
COPYFILE_DISABLE=1 tar --no-xattrs -cf - "${files[@]}" | \
  ssh "${ssh_options[@]}" "$target" "tar -xf - -C '$remote_site'"

verify() {
  local file=$1 url=$2
  curl -fsSL --retry 3 --max-time 20 -H 'Cache-Control: no-cache' \
    "$url?deploy=$(date -u +%s)" -o "$tmp_dir/response"
  if ! cmp -s "$file" "$tmp_dir/response"; then
    printf 'Published file differs from local source: %s\n' "$url" >&2
    exit 1
  fi
  printf 'Verified: %s\n' "$url"
}

verify index.html https://quackoslavsoft.ru/
verify en/index.html https://quackoslavsoft.ru/en/
verify styles.css https://quackoslavsoft.ru/styles.css
printf 'Deployment complete. Previous versions of changed files: %s\n' "$backup_dir"
