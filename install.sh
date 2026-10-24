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

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "chezmoi not found, installing to ~/.local/bin ..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
fi

# Running non-interactively (no TTY, e.g. a devcontainer's postCreateCommand)?
# Force the "devcontainer" chassis so .chezmoi.toml.tmpl never blocks on a prompt.
if [ ! -t 0 ] && [ -z "${CHEZMOI_CHASSIS:-}" ]; then
  export CHEZMOI_CHASSIS="devcontainer"
fi

chezmoi init --apply --source "$REPO_DIR"
