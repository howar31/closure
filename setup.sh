#!/usr/bin/env bash
# closure setup — idempotent installer for the skill(s).
#
# Symlinks the repo's skill directory(ies) into ~/.claude/skills/ so Claude Code
# picks them up. There is no hook and no settings.json patch — pure, prompt-only
# skills with no runtime dependencies.
#
# Safe to re-run. Backs up before any destructive action. Verifies after install.
#
# Flags:
#   --dry-run   Show what would happen, don't apply
#   --force     Replace an existing real directory at ~/.claude/skills/<skill>/
#   -h, --help  Show this help

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIRS=("closure")
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --force)   FORCE=1 ;;
    -h|--help)
      sed -n '2,13p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

if [ -t 1 ]; then
  C_OK=$'\033[0;32m'; C_ERR=$'\033[0;31m'; C_WARN=$'\033[0;33m'; C_DIM=$'\033[0;90m'; C_RST=$'\033[0m'
else
  C_OK=""; C_ERR=""; C_WARN=""; C_DIM=""; C_RST=""
fi

ok()    { printf '  %sok%s   %s\n'   "$C_OK"   "$C_RST" "$*"; }
warn()  { printf '  %swarn%s %s\n'   "$C_WARN" "$C_RST" "$*"; }
err()   { printf '  %serr%s  %s\n'   "$C_ERR"  "$C_RST" "$*" >&2; }
note()  { printf '  %s··%s   %s\n'   "$C_DIM"  "$C_RST" "$*"; }
header(){ printf '\n=== %s ===\n' "$*"; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '  %s[dry-run]%s would: %s\n' "$C_DIM" "$C_RST" "$*"
  else
    eval "$@"
  fi
}

# --- Phase 1: install skill directories (symlinks) ---
header "Phase 1 — install skill directories"
mkdir -p "$CLAUDE_SKILLS_DIR"
backup_dir="$CLAUDE_SKILLS_DIR/.bak/$TIMESTAMP"

for d in "${SKILL_DIRS[@]}"; do
  src="$SCRIPT_DIR/skills/$d"
  dst="$CLAUDE_SKILLS_DIR/$d"

  [ -d "$src" ] || { err "Source missing: $src"; exit 1; }
  [ -f "$src/SKILL.md" ] || { err "Source missing SKILL.md: $src/SKILL.md"; exit 1; }

  if [ -L "$dst" ]; then
    actual="$(readlink "$dst")"
    if [ "$actual" = "$src" ]; then
      ok "$d skill symlink already correct"
    elif [ "$FORCE" -eq 1 ]; then
      run "rm '$dst' && ln -s '$src' '$dst'"
      ok "$d skill relinked (was: $actual)"
    else
      err "$d skill symlink points elsewhere: $actual"
      err "  use --force to relink"
      exit 1
    fi
  elif [ -e "$dst" ]; then
    if [ "$FORCE" -eq 1 ]; then
      run "mkdir -p '$backup_dir' && mv '$dst' '$backup_dir/skill-$d' && ln -s '$src' '$dst'"
      ok "$d skill real dir replaced (backup: $backup_dir/skill-$d)"
    else
      err "$d skill real directory exists at $dst"
      err "  use --force to backup-and-replace"
      exit 1
    fi
  else
    run "ln -s '$src' '$dst'"
    ok "$d skill symlinked (fresh)"
  fi
done

# --- Phase 2: verify ---
header "Phase 2 — verify"
fail=0

if [ "$DRY_RUN" -eq 1 ]; then
  note "[dry-run] skipping verification (nothing applied)"
else
  for d in "${SKILL_DIRS[@]}"; do
    dst="$CLAUDE_SKILLS_DIR/$d"
    src="$SCRIPT_DIR/skills/$d"
    if [ ! -L "$dst" ]; then
      err "$d: $dst is not a symlink"; fail=1; continue
    elif [ "$(readlink "$dst")" != "$src" ]; then
      err "$d: symlink → $(readlink "$dst") (expected $src)"; fail=1; continue
    fi
    ok "$d skill symlink → repo"
    if [ ! -f "$dst/SKILL.md" ]; then
      err "$d: SKILL.md missing at $dst/SKILL.md"; fail=1
    elif ! grep -q "^name: *$d *$" "$dst/SKILL.md"; then
      err "$d: SKILL.md frontmatter must include 'name: $d'"; fail=1
    else
      ok "$d SKILL.md frontmatter ok"
    fi
  done
fi

# --- Summary ---
header "Summary"
if [ "$fail" -eq 0 ]; then
  printf '  %sAll checks passed.%s closure skill(s) installed.\n\n' "$C_OK" "$C_RST"
  printf '  Skills are picked up dynamically; run /reload-plugins in an active session if needed.\n'
  exit 0
else
  printf '  %sVerification failed.%s See errors above.\n' "$C_ERR" "$C_RST"
  exit 1
fi
