#!/usr/bin/env bash
# Checks the crate version agrees in Cargo.toml and Cargo.lock, and, given a
# tag, that the tag names that version. release.yml and prepare-release.yml run
# it before anything is built or pushed.
#
#   scripts/version-sync.sh           # Cargo.toml == Cargo.lock
#   scripts/version-sync.sh v0.2.0    # ... and == the tag
set -euo pipefail
cd "$(dirname "$0")/.."

name=$(sed -n 's/^name = "\(.*\)"$/\1/p' Cargo.toml | head -n 1)
toml=$(sed -n 's/^version = "\(.*\)"$/\1/p' Cargo.toml | head -n 1)
lock=$(awk -v n="$name" '$0 == "name = \"" n "\"" { getline; gsub(/version = |"/, ""); print; exit }' Cargo.lock)

echo "Cargo.toml: $toml"
echo "Cargo.lock: $lock"
rc=0
[ "$toml" = "$lock" ] || { echo "error: Cargo.lock has $lock, Cargo.toml has $toml (run cargo update -p $name)" >&2; rc=1; }
if [ $# -ge 1 ]; then
    echo "tag:        ${1#v}"
    [ "$toml" = "${1#v}" ] || { echo "error: tag $1 does not match Cargo.toml $toml" >&2; rc=1; }
fi
[ $rc -eq 0 ] && echo "ok: $toml"
exit $rc
