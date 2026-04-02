# dotfiles
Authored by Nathan Jodoin

## Requires
- GNU stow
- fish shell
- gpg + pass (for secrets management)
- bass (fish plugin — source bash scripts inside fish)
- zoxide, pyenv, fnm, fzf, exa, fortune+cowsay

## How To Use
1. Clone repo: `git clone --recurse-submodules -j4 git@github.com:corigne/dotfiles.git ~/.dotfiles`
2. Enter repository directory: `cd ~/.dotfiles`
3. Use GNU stow to symlink everything: `stow -v --dotfiles .`

The `--dotfiles` flag makes stow translate `dot-` prefixed names to `.` in the
target, e.g. `dot-config/fish/config.fish` → `~/.config/fish/config.fish`.

### Updating submodules (nvim, tmux)

Pull the latest commits from each submodule's `main` branch, then record the
updated refs in the parent repo:

```bash
# From ~/.dotfiles
git submodule update --remote --merge
git add dot-config/nvim dot-config/tmux
git commit -m "Bump submodules to latest main"
git push
```

On another machine, pull everything including updated submodule refs:

```bash
git pull
git submodule update --init --recursive
```

---

## Repository layout

```
.dotfiles/
├── dot-bash_aliases            → ~/.bash_aliases
├── dot-bashrc                  → ~/.bashrc
└── dot-config/
    ├── environment.d/
    │   └── environment.conf    → ~/.config/environment.d/environment.conf
    ├── fish/
    │   ├── config.fish         → ~/.config/fish/config.fish
    │   ├── conf.d/
    │   │   ├── secrets.fish    # Auto-injects pass secrets on shell open
    │   │   └── ...             # fzf, fnm, hydro, omf, theme plugins
    │   ├── functions/
    │   │   ├── inject-secrets.fish  # Secret injection function
    │   │   └── ...             # bass, fzf helpers, prompt
    │   └── ...                 # themes, completions, fish_variables
    ├── hypr/                   → ~/.config/hypr/
    ├── nvim/                   → ~/.config/nvim/  (submodule)
    └── ...                     # kitty, waybar, dunst, etc.
```

---

## Secrets management (pass + GPG)

Secrets are stored encrypted in `~/.password-store/` using
[pass](https://www.passwordstore.org/) with GPG as the backend.
They are injected into the shell as environment variables automatically
on every interactive fish session. The token values are **never** stored
in plaintext in this repo.

### First-time setup

```bash
# 1. Initialise pass with your GPG key fingerprint
pass init <GPG-FINGERPRINT>

# 2. Insert a secret
pass insert api-tokens/MY_TOKEN
```

### Restoring on a new machine

1. Export GPG key on old machine:
   ```bash
   gpg --export-secret-keys --armor <FINGERPRINT> > secret-key.asc
   ```
2. Import on new machine and trust:
   ```bash
   gpg --import secret-key.asc
   gpg --edit-key <FINGERPRINT>   # trust → 5 → quit
   ```
3. Copy `~/.password-store/` (all files are GPG-encrypted, safe to transfer):
   ```bash
   rsync -av user@oldhost:~/.password-store/ ~/.password-store/
   ```

### Adding a new secret

```bash
# Store it in pass
pass insert api-tokens/MY_NEW_TOKEN

# Register it for auto-injection — add a line to the secret_map
# in dot-config/fish/functions/inject-secrets.fish:
#   "MY_NEW_TOKEN=api-tokens/MY_NEW_TOKEN"
```

### inject-secrets function

`dot-config/fish/functions/inject-secrets.fish` — callable manually at any
time with `inject-secrets`. The `secret_map` at the top is the single source
of truth for which secrets get injected:

```fish
set -l secret_map \
    "CANVAS_TOKEN=api-tokens/CANVAS_TOKEN"
#   "ENV_VAR_NAME=pass/path/to/secret"
```

**Debug mode** — verbose output (silent by default):
```bash
set -g pass_debug 1     # current session
set -U pass_debug 1     # persist across sessions (universal)
set -e pass_debug       # remove
```

**Bypass injection** for a subshell:
```bash
FISH_NO_SECRETS=1 fish
```

---

## Fish shell configuration (`dot-config/fish/config.fish`)

| Section | What it does |
|---------|-------------|
| Login guard | Launches Hyprland on a bare TTY (no display server running) |
| `bass source environment.conf` | Loads `environment.d` vars into fish |
| `bass source ~/.cargo/env` | Adds Rust/Cargo to PATH |
| `bass source ~/.rokit/env` | Adds Rokit toolchain to PATH |
| `ctrl-d` binding | Disables accidental logout on Ctrl-D |
| `bind_bang` / `bind_dollar` | `!!` and `!$` bash-history expansion shortcuts |
| `fish_greeting` | fortune + cowsay greeting on new shell |
| `postexec_test` | Adds a blank line after every command output |
| zoxide | Initialises smart `cd` replacement |
| pyenv | Initialises Python version management |
| `bass source ~/.bash_aliases` | Loads shared aliases |

---

## Environment variables (`dot-config/environment.d/environment.conf`)

Loaded by fish via `bass source` and by systemd user services automatically.

| Group | Variables |
|-------|-----------|
| Hyprland / Wayland | `XDG_CURRENT_DESKTOP`, `XDG_SESSION_TYPE` |
| SSH agent | `SSH_AUTH_SOCK` → `$XDG_RUNTIME_DIR/ssh-agent.socket` |
| GTK / Qt | Theming, portal, fcitx input method |
| Editor | `EDITOR=nvim`, `VISUAL=nvim` |
| DevkitPro | GBA/ARM/PPC cross-compilation toolchains |
| Languages | Go (`GOPATH`, `GOBIN`), Rust, Perl, Ruby gems |
| PostgreSQL | `LD_LIBRARY_PATH`, `PATH` additions |

---

## Shell aliases (`dot-bash_aliases`)

Sourced by fish via `bass`. Key aliases:

| Alias | Command |
|-------|---------|
| `l`, `la`, `ll`, `lal`, `ls` | `exa` variants with git status |
| `less` | `moor` (modern pager) |
| `clock` | `tty-clock` fullscreen clock |
| `logout` | `loginctl terminate-user $USER` |
| `vlime` | Start Vlime SBCL server for Neovim |
| `hyprkill` | Kill Hyprland session script |
