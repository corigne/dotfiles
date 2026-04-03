# Copilot Instructions

## Environment
- OS: Linux (Wayland/Hyprland)
- Shell: fish (primary), bash fallback
- Editor: Neovim
- Multiplexer: tmux / zellij
- Package managers: apt, cargo, pip, npm (via fnm), go install
- Secrets: pass + GPG — never store secrets in plaintext

## Languages & style
- Go: stdlib-first, explicit errors, no magic
- Python: type hints, PEP 8, prefer stdlib over heavy deps
- TypeScript: strict mode, functional patterns, no `any`
- Shell: POSIX-compatible unless fish-specific is required; always quote variables
- Rust: idiomatic ownership, no `unwrap()` in library code

## Behaviour
- Make surgical, minimal changes — don't refactor what wasn't asked
- Prefer existing patterns in the codebase over introducing new ones
- If unsure, ask — don't guess and proceed
- Never delete or overwrite data without explicit confirmation
- All scripts should be idempotent unless the task requires otherwise

## Boundaries
- Never commit secrets, tokens, or credentials
- Never touch `.env*`, `*.secret`, or `~/.password-store/`
- Do not suggest `oh-my-zsh`, heavy shell frameworks, or GUI-only tools
- Do not add `Co-authored-by` trailers to git commits
