# CLAUDE.md

template-rust-cli: __DESCRIPTION__

Logic lives in `src/lib.rs`; `src/main.rs` only parses arguments and prints.

## Commands

```bash
cargo test --locked
cargo clippy --all-targets --locked -- -D warnings   # CI fails on any warning
cargo fmt --check
scripts/version-sync.sh                              # Cargo.toml == Cargo.lock
```

Pre-commit enforces Conventional Commits; commit types set the release version.

## Releases

Run the **Prepare release** workflow on `main` (tick `dry_run` to preview).
It computes the next version with git-cliff, bumps `Cargo.toml` and
`Cargo.lock`, tags `vX.Y.Z` and dispatches `release.yml`, which builds five
targets, writes a `.sha256` per archive and publishes the GitHub release that
`install.sh` / `install.ps1` download. Never bump the version by hand.
