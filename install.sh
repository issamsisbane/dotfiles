#!/usr/bin/env bash
# Bootstrap script: installs chezmoi if needed, then applies this repo's dotfiles.
#
# Used two ways:
#   - manually, on any machine:        ./install.sh
#   - automatically in devcontainers/Codespaces, via VS Code's
#     dotfiles.repository/targetPath/installCommand settings (see
#     home/dot_config/vscode-dotfiles/settings.json). In that case it runs
#     non-interactively, so we force chassis=devcontainer and never prompt.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"

# Resolve the chezmoi binary without relying on PATH (on a fresh shell, e.g.
# Git Bash right after installing, ~/.local/bin often isn't on PATH yet, which
# would otherwise make this script "reinstall" chezmoi on every run).
chezmoi_bin() {
  if command -v chezmoi >/dev/null 2>&1; then
    command -v chezmoi
  elif [ -x "$LOCAL_BIN/chezmoi" ]; then
    echo "$LOCAL_BIN/chezmoi"
  elif [ -x "$LOCAL_BIN/chezmoi.exe" ]; then
    echo "$LOCAL_BIN/chezmoi.exe"
  fi
}

CHEZMOI="$(chezmoi_bin || true)"

if [ -z "$CHEZMOI" ]; then
  echo "chezmoi not found, installing to $LOCAL_BIN ..."
  sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$LOCAL_BIN"
  CHEZMOI="$(chezmoi_bin || true)"
  if [ -z "$CHEZMOI" ]; then
    echo "error: chezmoi installer ran but no binary found in $LOCAL_BIN" >&2
    exit 1
  fi
fi

# Running non-interactively (no TTY, e.g. a devcontainer's postCreateCommand)?
# Force the "devcontainer" chassis so .chezmoi.toml.tmpl never blocks on a prompt.
if [ ! -t 0 ] && [ -z "${CHEZMOI_CHASSIS:-}" ]; then
  export CHEZMOI_CHASSIS="devcontainer"
fi

"$CHEZMOI" init --apply --source "$REPO_DIR"

case ":$PATH:" in
  *":$LOCAL_BIN:"*) ;;
  *) echo "Note: add $LOCAL_BIN to your PATH to call chezmoi directly later." ;;
esac
