#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "cc-task-manager: installing (legacy mode)..."

mkdir -p "$CLAUDE_DIR/commands"

for cmd in task finalize fin resume; do
  cp "$REPO_DIR/commands/$cmd.md" "$CLAUDE_DIR/commands/"
done

echo "cc-task-manager: installed"
echo "  commands → $CLAUDE_DIR/commands/{task,finalize,fin,resume}.md"
echo ""
echo "Usage: /task, /finalize, /fin, /resume"
