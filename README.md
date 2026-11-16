# template-rust-cli

[![CI](https://github.com/bcmyguest/template-rust-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/bcmyguest/template-rust-cli/actions/workflows/ci.yml)

__DESCRIPTION__

<!-- template:start -->
## Using this template

```bash
gh repo create my-tool --template bcmyguest/template-rust-cli --private --clone
cd my-tool
scripts/init.sh my-tool "One-line description"
git commit -am "chore: init from template-rust-cli"
pre-commit install --install-hooks --hook-type pre-commit --hook-type commit-msg
```

`init.sh` renames `template-rust-cli` / `template_rust_cli` / `TEMPLATE_RUST_CLI`,
fills the description, sets the owner from the `origin` remote, removes this
section and deletes itself. CI fails while any placeholder remains.

Optional: set the repository variable `PUBLISH_CRATES=true` after registering
`release.yml` as a crates.io trusted publisher.
<!-- template:end -->

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/bcmyguest/template-rust-cli/main/install.sh | sh
```

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/bcmyguest/template-rust-cli/main/install.ps1 | iex
```

The installer picks the release archive for your platform, checks its SHA-256
and installs to `~/.local/bin` (Windows: `%LOCALAPPDATA%\template-rust-cli\bin`).
`TEMPLATE_RUST_CLI_VERSION` pins a release; `TEMPLATE_RUST_CLI_INSTALL_DIR`
changes the target. The raw URLs work once the repository is public.

From source:

```bash
cargo install --git https://github.com/bcmyguest/template-rust-cli --locked
```

## Usage

```bash
template-rust-cli Ferris
# Hello, Ferris!
```

## License

Apache-2.0
