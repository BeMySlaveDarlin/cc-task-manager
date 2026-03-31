# cc-task-manager Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Claude Code plugin for project task lifecycle management with auto-activating skills and YAML+markdown storage.

**Architecture:** 3 skills (task-manager, finalize, resume) with auto-activation by description matching + 4 commands as explicit entry points. Tasks stored in `.claude/session/details/` as YAML frontmatter + markdown body, indexed in `tasks.md`.

**Tech Stack:** Markdown (skills, commands), Bash (install script), YAML frontmatter (task storage)

**Spec:** `docs/specs/2026-03-31-cc-task-manager-design.md`

---

## File Structure

```
cc-task-manager/
  .claude-plugin/
    plugin.json               # Plugin manifest
    marketplace.json           # Self-hosted marketplace registry
  skills/
    task-manager/
      SKILL.md                 # Task CRUD router (auto-activate)
    finalize/
      SKILL.md                 # Session finalization (auto-activate)
    resume/
      SKILL.md                 # Session resume (auto-activate)
  commands/
    task.md                    # /task command → invokes task-manager skill
    finalize.md                # /finalize command → invokes finalize skill
    fin.md                     # /fin alias → invokes finalize skill
    resume.md                  # /resume command → invokes resume skill
  install.sh                   # Legacy install script
  README.md                    # Russian docs
  README.en.md                 # English docs
  CLAUDE.md                    # Project instructions
  LICENSE                      # MIT
```

---

### Task 1: Project scaffold

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `.claude-plugin/marketplace.json`
- Create: `LICENSE`
- Create: `CLAUDE.md`

- [ ] **Step 1: Init git repo**

```bash
cd /opt/Projects/Services/cc-task-manager
git init
```

- [ ] **Step 2: Create plugin.json**

```json
{
  "name": "cc-task-manager",
  "description": "Task lifecycle management for Claude Code projects. Create, track, close tasks. Session finalization and resume.",
  "version": "1.0.0",
  "author": {
    "name": "BeMySlaveDarlin",
    "url": "https://github.com/BeMySlaveDarlin"
  },
  "license": "MIT",
  "keywords": ["tasks", "session", "finalize", "resume", "project-management"]
}
```

- [ ] **Step 3: Create marketplace.json**

```json
{
  "name": "bemyslavedarlin-cc-task-manager",
  "description": "Task lifecycle management plugins",
  "owner": {
    "name": "BeMySlaveDarlin",
    "url": "https://github.com/BeMySlaveDarlin"
  },
  "plugins": [
    {
      "name": "cc-task-manager",
      "description": "Task lifecycle management for Claude Code projects.",
      "version": "1.0.0",
      "source": "./",
      "repository": "https://github.com/BeMySlaveDarlin/cc-task-manager",
      "license": "MIT",
      "keywords": ["tasks", "session", "finalize", "resume"]
    }
  ]
}
```

- [ ] **Step 4: Create LICENSE** (MIT, author BeMySlaveDarlin)

- [ ] **Step 5: Create CLAUDE.md**

Minimal project instructions: overview, rules (Russian prompts, no comments, no auto-commit), structure reference.

- [ ] **Step 6: Create .gitignore**

```
.claude
.idea
.vscode
.DS_Store
.env
```

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "init: project scaffold with plugin manifest and marketplace"
```

---

### Task 2: Skill — task-manager

**Files:**
- Create: `skills/task-manager/SKILL.md`

- [ ] **Step 1: Create SKILL.md**

Frontmatter:
```yaml
---
name: task-manager
description: "Управление задачами проекта. Используй когда пользователь говорит: \"создай задачу\", \"добавь таск\", \"новая задача\", \"что в очереди\", \"покажи задачи\", \"список задач\", \"закрой задачу\", \"task done\", \"обнови задачу\", \"приоритет задачи\", \"удали задачу\", \"какие задачи открыты\", \"что осталось сделать\"."
user-invocable: true
argument-hint: "<описание задачи или операция>"
---
```

Body — полный промпт для роутинга операций:
- Определение операции по ключевым словам (create/list/show/update/close/delete)
- Формат хранения: `.claude/session/details/` с YAML frontmatter
- Формат `tasks.md` — индексная таблица
- Сквозная нумерация
- AskUserQuestion на close/delete
- Создание `.claude/session/` и `details/` если не существуют

- [ ] **Step 2: Verify SKILL.md parses correctly**

```bash
head -20 skills/task-manager/SKILL.md
```

- [ ] **Step 3: Commit**

```bash
git add skills/task-manager/SKILL.md
git commit -m "feat: add task-manager skill — CRUD router for project tasks"
```

---

### Task 3: Skill — finalize

**Files:**
- Create: `skills/finalize/SKILL.md`

- [ ] **Step 1: Create SKILL.md**

Frontmatter:
```yaml
---
name: finalize
description: "Финализация сессии: сводка задач, обновление memory и CLAUDE.md, отчёт. Используй когда пользователь говорит: \"финализируй\", \"заверши сессию\", \"закрой сессию\", \"подведи итоги\", \"сохрани прогресс\", \"на сегодня всё\", \"давай закругляться\", \"что сделали\", \"wrap up\", \"end session\", \"save progress\"."
user-invocable: true
argument-hint: ""
aliases: ["fin"]
---
```

Body — полный промпт финализации:
1. Прочитать `.claude/finalize.local.md` → выполнить before/pre шаги
2. Обновить `.claude/session/tasks.md` по итогам сессии
3. Обновить/создать файлы в `details/` (YAML frontmatter формат)
4. Обновить `queue.md`
5. Обновить memory (архитектурные решения, feedback)
6. Обновить CLAUDE.md (если изменилась структура/правила)
7. Выполнить оставшиеся шаги из `finalize.local.md`
8. Отчёт пользователю: выполнено X, открыто Y (Z HIGH), артефакт

- [ ] **Step 2: Commit**

```bash
git add skills/finalize/SKILL.md
git commit -m "feat: add finalize skill — session finalization with task sync"
```

---

### Task 4: Skill — resume

**Files:**
- Create: `skills/resume/SKILL.md`

- [ ] **Step 1: Create SKILL.md**

Frontmatter:
```yaml
---
name: resume
description: "Восстановление контекста сессии. Используй когда пользователь говорит: \"продолжим\", \"что было\", \"resume\", \"где остановились\", \"начнём с прошлого\", \"что в работе\", \"контекст сессии\", \"какие задачи\", \"что делали прошлый раз\"."
user-invocable: true
argument-hint: ""
---
```

Body — промпт восстановления:
1. Прочитать `tasks.md` — показать открытые задачи (HIGH первые)
2. Прочитать последние `details/open-*.md` — показать контекст каждой
3. Прочитать `queue.md` — что дальше по плану
4. Предложить с чего начать (AskUserQuestion с вариантами из HIGH-задач)

- [ ] **Step 2: Commit**

```bash
git add skills/resume/SKILL.md
git commit -m "feat: add resume skill — session context restoration"
```

---

### Task 5: Commands

**Files:**
- Create: `commands/task.md`
- Create: `commands/finalize.md`
- Create: `commands/fin.md`
- Create: `commands/resume.md`

- [ ] **Step 1: Create task.md**

```markdown
---
name: task
description: "Управление задачами проекта"
user-invocable: true
argument-hint: "<create|list|show|close|delete> [описание]"
---

Выполни skill `task-manager` с аргументами: $ARGUMENTS
```

- [ ] **Step 2: Create finalize.md**

```markdown
---
name: finalize
description: "Финализация сессии"
user-invocable: true
argument-hint: ""
---

Выполни skill `finalize` с аргументами: $ARGUMENTS
```

- [ ] **Step 3: Create fin.md**

```markdown
---
name: fin
description: "Алиас для /finalize"
user-invocable: true
argument-hint: ""
---

Выполни skill `finalize` с аргументами: $ARGUMENTS
```

- [ ] **Step 4: Create resume.md**

```markdown
---
name: resume
description: "Восстановление контекста сессии"
user-invocable: true
argument-hint: ""
---

Выполни skill `resume` с аргументами: $ARGUMENTS
```

- [ ] **Step 5: Commit**

```bash
git add commands/
git commit -m "feat: add slash commands — /task, /finalize, /fin, /resume"
```

---

### Task 6: Install script (legacy)

**Files:**
- Create: `install.sh`

- [ ] **Step 1: Create install.sh**

```bash
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
```

- [ ] **Step 2: chmod +x**

```bash
chmod +x install.sh
```

- [ ] **Step 3: Commit**

```bash
git add install.sh
git commit -m "feat: add legacy install script"
```

---

### Task 7: README + docs

**Files:**
- Create: `README.md`
- Create: `README.en.md`

- [ ] **Step 1: Create README.md** (Russian)

Sections:
- Overview (что делает)
- Installation (plugin marketplace + legacy)
- Usage (skills auto-activate, commands, примеры)
- Storage format (`.claude/session/`, YAML frontmatter)
- Customization (`finalize.local.md`)
- License

- [ ] **Step 2: Create README.en.md** (English)

Same structure, translated.

- [ ] **Step 3: Commit**

```bash
git add README.md README.en.md
git commit -m "docs: add README.md and README.en.md"
```

---

### Task 8: Verification

- [ ] **Step 1: Verify plugin structure**

```bash
cd /opt/Projects/Services/cc-task-manager
# Check all required files exist
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json \
         skills/task-manager/SKILL.md skills/finalize/SKILL.md skills/resume/SKILL.md \
         commands/task.md commands/finalize.md commands/fin.md commands/resume.md \
         install.sh README.md README.en.md CLAUDE.md LICENSE; do
  [ -f "$f" ] && echo "[OK] $f" || echo "[MISS] $f"
done
```

- [ ] **Step 2: Verify YAML frontmatter in all skills**

```bash
for f in skills/*/SKILL.md; do
  echo "--- $f ---"
  head -10 "$f"
  echo ""
done
```

- [ ] **Step 3: Test local install**

```bash
/plugin marketplace add /opt/Projects/Services/cc-task-manager
/plugin install cc-task-manager@bemyslavedarlin-cc-task-manager
/reload-plugins
```

Verify: `/task`, `/finalize`, `/resume` appear as available commands.

- [ ] **Step 4: Test auto-activation**

Write "покажи задачи" in Claude Code — verify task-manager skill activates.
Write "финализируй" — verify finalize skill activates.

- [ ] **Step 5: Final commit + tag**

```bash
git tag v1.0.0
```
