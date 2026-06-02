#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "cc-task-manager: installing (legacy mode)..."

mkdir -p "$CLAUDE_DIR/skills"

for skill in ts finalize rs; do
  rm -rf "$CLAUDE_DIR/skills/$skill"
  cp -r "$REPO_DIR/skills/$skill" "$CLAUDE_DIR/skills/"
done

for cmd in ts finalize fin rs; do
  rm -f "$CLAUDE_DIR/commands/$cmd.md"
done

echo "cc-task-manager: installed"
echo "  skills → $CLAUDE_DIR/skills/{ts,finalize,rs}/SKILL.md"
echo ""
echo "Usage: /ts, /finalize, /rs"
