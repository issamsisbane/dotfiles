# Dotfiles

Mes fichiers de configuration, gérés avec [chezmoi](https://www.chezmoi.io/), pour :

- **Linux/WSL** (Ubuntu) : `.bashrc`, `.tmux.conf`/`.tmux-18.conf`, `.vimrc`, `.inputrc`, surcharges de plugins nvim
- **Windows** : VS Code (`settings.json`, `keybindings.json`, snippets, css) et Windows Terminal
- **Git Bash** (sur Windows) : `.bashrc`, `.vimrc` (les mêmes fichiers que Linux/WSL, voir plus bas)
- **Devcontainers / Codespaces** : appliqué automatiquement au démarrage, voir plus bas

## Structure du repo

Le *source state* chezmoi vit dans `home/` (déclaré par le fichier `.chezmoiroot`), pour garder ce `README.md` et `install.sh` hors de `$HOME`. Dans `home/` :

- `home/.chezmoi.toml.tmpl` : génère la config chezmoi et détecte/demande le type de machine (`chassis`) : `wsl`, `linux`, `windows-gitbash` ou `devcontainer`.
- `home/.chezmoiignore` : exclut les fichiers non pertinents pour le `chassis` détecté (ex. pas de tmux sous Git Bash, pas les configs Windows sous WSL).
- `dot_*` → fichiers `~/.xxx` classiques (bashrc, vimrc, inputrc, tmux).
- `dot_config/nvim/...` → surcharges de plugins déposées dans `~/.config/nvim` (le reste de la config nvim est un repo séparé, cloné indépendamment).
- `dot_config/vscode-dotfiles/` et `dot_config/windows-terminal/` : copies canoniques des configs Windows, gérées par chezmoi sous `$HOME` puis reliées par lien symbolique vers leur emplacement réel (`%APPDATA%\Code\User`, le dossier `LocalState` de Windows Terminal) par les deux scripts `run_link-*.ps1.tmpl` — ces emplacements sont hors de `$HOME`, donc hors de portée directe de chezmoi.
  - **Si le Mode développeur Windows est activé** (ou le script lancé en admin) : vrai lien symbolique, tout changement (repo ou édité dans VS Code) est instantanément vu des deux côtés, `chezmoi diff` fonctionne normalement.
  - **Sinon** (poste pro géré, Mode développeur bloqué) : chezmoi ne peut pas créer de lien, donc ces deux scripts font une **copie**, et tournent à *chaque* `chezmoi apply` (pas seulement quand le repo change) pour comparer les dates de modification des deux côtés et copier le plus récent sur l'autre — une édition faite dans VS Code est donc récupérée dans le repo (visible ensuite via `chezmoi diff` puis à committer) au lieu d'être silencieusement écrasée au prochain `apply`. Implication pratique : une modif faite dans VS Code n'est prise en compte par chezmoi **qu'après avoir relancé `chezmoi apply`** — ce n'est pas instantané comme avec un vrai lien.
- `dot_wslconfig` → `~/.wslconfig` (réglages WSL2 globaux).

## Installation sur une nouvelle machine

```sh
git clone git@github.com:issamsisbane/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` installe `chezmoi` si besoin (vers `~/.local/bin`), puis lance `chezmoi init --apply`. Le type de machine est détecté automatiquement (WSL via le noyau, Windows via l'OS) ; si l'environnement ne peut pas être détecté, il te sera demandé une seule fois.

Sur Windows natif (pour Git Bash + VS Code + Windows Terminal), lancer la même commande depuis PowerShell ou Git Bash avec le binaire chezmoi natif Windows.

Une fois initialisé, les mises à jour se font avec :

```sh
chezmoi update   # git pull + apply
# ou, après avoir édité un fichier directement dans ~/dotfiles/home :
chezmoi apply
```

## Usage au quotidien

- `link-vscode-settings.ps1` et `link-windows-terminal.ps1` sont des scripts `run_` simples (pas `run_once_`/`run_onchange_`) : ils n'ont **aucun état "déjà appliqué" mémorisé**, exprès, pour se relancer à *chaque* `chezmoi apply` et refaire la vérification hardlink/sync à chaque fois (voir ci-dessus). Du coup `chezmoi diff`/`chezmoi apply` les affiche systématiquement, même quand il n'y a rien de nouveau à faire — ce n'est pas un signe de problème. Pour un diff plus lisible qui ne montre que les vrais fichiers :
  ```sh
  chezmoi diff --exclude=scripts
  ```
- Au tout premier `apply` sur une machine qui a déjà des dotfiles existants (cas normal), chezmoi demande confirmation avant d'écraser chaque fichier (`.bashrc has changed since chezmoi last wrote it?`) : c'est sa protection standard contre l'écrasement accidentel, pas une erreur. Répondre `a` (all-overwrite) accepte le remplacement pour ce fichier et les suivants sans redemander. Une fois ce premier `apply` passé, les `apply` suivants n'ont plus besoin de `--force`.

## Devcontainers / Codespaces

Pas de configuration à faire par projet : les réglages `dotfiles.repository` / `dotfiles.targetPath` / `dotfiles.installCommand` dans les settings VS Code (gérés ici dans `home/dot_config/vscode-dotfiles/settings.json`) font que VS Code clone automatiquement ce repo dans `~/dotfiles` et exécute `install.sh` à chaque création de devcontainer/Codespace, sans prompt (le chassis `devcontainer` est forcé non-interactivement).

## Hors scope

- `obsidian/` : config du vault Obsidian, toujours gérée manuellement (pas de chezmoi).
- `.gitconfig` : non versionné ici (diffère entre machines perso/pro).
