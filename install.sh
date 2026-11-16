#!/bin/sh
# Installs the template-rust-cli release binary for this machine.
#
#   curl -fsSL https://raw.githubusercontent.com/bcmyguest/template-rust-cli/main/install.sh | sh
#
# TEMPLATE_RUST_CLI_VERSION      release to install, such as 0.1.0 (default: latest)
# TEMPLATE_RUST_CLI_INSTALL_DIR  where the binary goes (default: ~/.local/bin)
# TEMPLATE_RUST_CLI_RELEASE_URL  releases base URL (default: the GitHub releases page)
set -eu

version="${TEMPLATE_RUST_CLI_VERSION:-latest}"
install_dir="${TEMPLATE_RUST_CLI_INSTALL_DIR:-$HOME/.local/bin}"
base="${TEMPLATE_RUST_CLI_RELEASE_URL:-https://github.com/bcmyguest/template-rust-cli/releases}"

fail() {
    echo "template-rust-cli install: $*" >&2
    exit 1
}

target() {
    case "$(uname -m)" in
        x86_64 | amd64) arch=x86_64 ;;
        arm64 | aarch64) arch=aarch64 ;;
        *) return 1 ;;
    esac
    case "$(uname -s)" in
        Linux) echo "$arch-unknown-linux-musl" ;;
        Darwin) echo "$arch-apple-darwin" ;;
        MINGW* | MSYS* | CYGWIN*) [ "$arch" = x86_64 ] && echo "x86_64-pc-windows-msvc" ;;
        *) return 1 ;;
    esac
}

download() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$2" "$1"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$2" "$1"
    else
        fail "needs curl or wget"
    fi
}

sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | cut -d ' ' -f 1
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | cut -d ' ' -f 1
    else
        fail "needs sha256sum or shasum"
    fi
}

triple="$(target)" || fail "no release build for $(uname -s) $(uname -m)"
name="template-rust-cli-$triple.tar.gz"
case "$version" in
    latest) url="$base/latest/download/$name" ;;
    *) url="$base/download/v${version#v}/$name" ;;
esac

mkdir -p "$install_dir"
tmp="$(mktemp -d "$install_dir/.template-rust-cli-install.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT INT TERM

download "$url" "$tmp/$name" || fail "cannot download $url"
download "$url.sha256" "$tmp/$name.sha256" || fail "cannot download $url.sha256"
expected="$(cut -d ' ' -f 1 "$tmp/$name.sha256")"
[ "$(sha256 "$tmp/$name")" = "$expected" ] || fail "checksum mismatch for $name"

mkdir "$tmp/out"
tar -xzf "$tmp/$name" -C "$tmp/out"
for file in "$tmp/out"/*; do
    chmod +x "$file"
    # Same-filesystem rename, so a running copy is never half-written.
    mv -f "$file" "$install_dir/"
done
echo "template-rust-cli installed to $install_dir" >&2
