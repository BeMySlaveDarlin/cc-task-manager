#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BIN_DIR="$HOME/.local/bin"

echo "cc-task-manager: installing (legacy mode)..."

command -v python3 >/dev/null || { echo "error: python3 required"; exit 1; }

mkdir -p "$CLAUDE_DIR/skills" "$BIN_DIR"

for skill in ts finalize rs; do
  rm -rf "$CLAUDE_DIR/skills/$skill"
  cp -r "$REPO_DIR/skills/$skill" "$CLAUDE_DIR/skills/"
done

ln -sf "$REPO_DIR/bin/cctm" "$BIN_DIR/cctm"
chmod +x "$REPO_DIR/bin/cctm"

for cmd in ts finalize fin rs; do
  rm -f "$CLAUDE_DIR/commands/$cmd.md"
done

echo "cc-task-manager: installed"
echo "  skills → $CLAUDE_DIR/skills/{ts,finalize,rs}/SKILL.md"
echo "  cctm   → $BIN_DIR/cctm (symlink)"
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "  warning: $BIN_DIR is not in PATH" ;;
esac
echo ""
echo "Note: hooks (TaskCompleted sync, SessionEnd sync+handoff) work only with plugin install."
echo "Usage: /ts, /finalize, /rs; CLI: cctm --help"
