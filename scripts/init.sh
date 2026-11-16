#!/usr/bin/env bash
# Turns a fresh copy of this template into a named project, then deletes itself.
#
#   scripts/init.sh <name> "<one-line description>" [owner]
#
# <name> is kebab-case (my-tool). It replaces template-rust-cli, template_rust_cli
# and TEMPLATE_RUST_CLI in every tracked file; owner (default: the origin
# remote's owner, else bcmyguest) replaces bcmyguest.
set -euo pipefail
cd "$(dirname "$0")/.."

[ $# -ge 2 ] || { sed -n '2,8s/^# \{0,1\}//p' "$0" >&2; exit 2; }
name=$1
[[ $name =~ ^[a-z][a-z0-9-]*$ ]] || { echo "init: name must be kebab-case: $name" >&2; exit 2; }
remote_owner=$(git remote get-url origin 2>/dev/null | sed -nE 's#.*[:/]([^/]+)/[^/]+(\.git)?$#\1#p')
export NAME=$name DESC=$2 OWNER=${3:-${remote_owner:-bcmyguest}}
export SNAKE=${name//-/_} UPPER
UPPER=$(tr 'a-z-' 'A-Z_' <<<"$name")

git ls-files -z | grep -zv '^scripts/init\.sh$' | xargs -0 perl -pi -e '
    s/template-rust-cli/$ENV{NAME}/g;
    s/template_rust_cli/$ENV{SNAKE}/g;
    s/TEMPLATE_RUST_CLI/$ENV{UPPER}/g;
    s/__DESCRIPTION__/$ENV{DESC}/g;
    s/bcmyguest/$ENV{OWNER}/g;
'
# Drop the template-only README section.
perl -0pi -e 's/<!-- template:start -->.*?<!-- template:end -->\n?//s' README.md
git rm -q scripts/init.sh
cargo generate-lockfile
echo "init: $NAME ready. Review with git diff, then commit." >&2
