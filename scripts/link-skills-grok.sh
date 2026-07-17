#!/usr/bin/env bash
# Link matt-pocock skills (EN + JA) into ~/.grok/skills for Grok Build TUI.
#
# EN  : original names  (e.g. tdd, grill-me)
# JA  : names with -ja  (e.g. tdd-ja, grill-me-ja)
#
# JA は frontmatter の name が原文と同じため、単純 symlink だと EN と衝突する。
# そこで JA は:
#   - SKILL.md だけ name を {base}-ja に書き換えて生成
#   - 同梱の companion ファイル (tests.md 等) は fork へ symlink（編集が即反映）
#
# Usage:
#   ./scripts/link-skills-grok.sh
#   ./scripts/link-skills-grok.sh --dry-run
#   ./scripts/link-skills-grok.sh --uninstall

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${GROK_SKILLS_DIR:-$HOME/.grok/skills}"
MARKER=".matt-pocock-from-skills-matt-fork"
DRY_RUN=0
UNINSTALL=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help)
      sed -n '2,20p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

log() { printf '%s\n' "$*"; }

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "  [dry-run] $*"
  else
    "$@"
  fi
}

# --- uninstall: only remove entries we previously installed ---
if [[ "$UNINSTALL" -eq 1 ]]; then
  if [[ ! -d "$DEST" ]]; then
    log "No dest dir: $DEST"
    exit 0
  fi
  removed=0
  for entry in "$DEST"/*; do
    [[ -e "$entry" || -L "$entry" ]] || continue
    if [[ -f "$entry/$MARKER" ]] || [[ -L "$entry" && "$(readlink "$entry" 2>/dev/null || true)" == "$REPO"/skills/* ]]; then
      log "remove $(basename "$entry")"
      run rm -rf "$entry"
      removed=$((removed + 1))
    fi
  done
  log "uninstalled $removed entries from $DEST"
  exit 0
fi

mkdir -p "$DEST"

# --- EN: symlink skill dirs under engineering + productivity ---
link_en() {
  local skill_md="$1"
  local src name target
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$DEST/$name"

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -L "$target" ]]; then
      run ln -sfn "$src" "$target"
      log "EN  relink $name -> $src"
    elif [[ -f "$target/$MARKER" ]]; then
      # previously installed as JA wrapper with same name — shouldn't happen
      run rm -rf "$target"
      run ln -sfn "$src" "$target"
      log "EN  replace $name -> $src"
    else
      log "EN  SKIP $name (exists and is not our symlink): $target"
      return 0
    fi
  else
    run ln -sfn "$src" "$target"
    log "EN  link  $name -> $src"
  fi
}

# --- JA: wrapper dir with rewritten name + companion symlinks ---
install_ja() {
  local skill_md="$1"
  local src base name_ja target
  src="$(dirname "$skill_md")"
  base="$(basename "$src")"
  name_ja="${base}-ja"
  target="$DEST/$name_ja"

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -f "$target/$MARKER" ]] || [[ -L "$target" ]]; then
      run rm -rf "$target"
    else
      log "JA  SKIP $name_ja (exists and is not ours): $target"
      return 0
    fi
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "JA  wrap  $name_ja <- $src"
    return 0
  fi

  mkdir -p "$target"
  # marker so --uninstall / re-run can identify our wrappers
  printf 'source=%s\nrepo=%s\n' "$src" "$REPO" >"$target/$MARKER"

  # companion files: symlink everything except SKILL.md（scripts/ 等のサブdir含む）
  local f b
  while IFS= read -r -d '' f; do
    b="$(basename "$f")"
    [[ "$b" == "SKILL.md" ]] && continue
    ln -sfn "$f" "$target/$b"
  done < <(find "$src" -mindepth 1 -maxdepth 1 -print0)

  # SKILL.md: rewrite frontmatter name to *-ja（本文・相対リンクは維持）
  if [[ -f "$src/SKILL.md" ]]; then
    awk -v n="$name_ja" '
      BEGIN { in_fm=0; done=0 }
      NR==1 && $0=="---" { in_fm=1; print; next }
      in_fm && $0=="---" { in_fm=0; print; next }
      in_fm && !done && /^name:[[:space:]]*/ {
        print "name: " n
        done=1
        next
      }
      { print }
    ' "$src/SKILL.md" >"$target/SKILL.md"
  fi

  log "JA  wrap  $name_ja <- $src"
}

log "REPO=$REPO"
log "DEST=$DEST"
log "--- English (engineering + productivity) ---"

while IFS= read -r -d '' skill_md; do
  link_en "$skill_md"
done < <(find "$REPO/skills/engineering" "$REPO/skills/productivity" \
  -name SKILL.md -print0 2>/dev/null)

log "--- Japanese (skills-ja → *-ja) ---"

while IFS= read -r -d '' skill_md; do
  install_ja "$skill_md"
done < <(find "$REPO/skills-ja" -name SKILL.md -print0 2>/dev/null)

log "--- done ---"
log "Verify: grok inspect | grep -E 'tdd|grill-me|diagnose|handoff'"
log "Slash:  /tdd  (EN)   /tdd-ja  (JA)"
log "Note: Claude plugin 版 mattpocock-skills / matt-pocock-skills-ja が有効だと同名 skill が二重になる。"
log "      整理するなら Grok の /plugins で disable、または Claude 側で uninstall。"
