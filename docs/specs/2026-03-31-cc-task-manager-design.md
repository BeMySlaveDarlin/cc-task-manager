# cc-task-manager — Design Spec

## Overview

Claude Code plugin for project task lifecycle management. Auto-activates via skill description matching on natural language. Stores tasks as YAML frontmatter + markdown in `.claude/session/`.

## Skills

### task-manager (auto-activate)
**Triggers:** "создай задачу", "добавь таск", "что в очереди", "покажи задачи", "список задач", "закрой задачу", "task done", "обнови задачу", "приоритет задачи"

**Operations:**
- **create** — создать файл в `details/`, обновить `tasks.md`
- **list** — показать таблицу из `tasks.md` (фильтр по статусу/приоритету)
- **show** — прочитать конкретный `details/open-NN-slug.md`
- **update** — обновить frontmatter/body задачи
- **close** — AskUserQuestion подтверждение, переименовать `open-` → `done-`, перенести в "Выполненные"
- **delete** — AskUserQuestion подтверждение, удалить файл, убрать из таблицы

Роутинг по ключевым словам в запросе пользователя.

### finalize (auto-activate)
**Triggers:** "финализируй", "заверши сессию", "подведи итоги", "wrap up", "на сегодня всё", "сохрани прогресс", "закрой сессию", "давай закругляться"

**Steps:**
1. Прочитать `.claude/finalize.local.md` → выполнить `before`/`pre` шаги
2. Обновить `.claude/session/tasks.md` по итогам сессии
3. Обновить/создать файлы в `details/`
4. Обновить memory (если были архитектурные решения, feedback)
5. Обновить CLAUDE.md (если изменилась структура/правила)
6. Выполнить оставшиеся шаги из `finalize.local.md`
7. Отчёт пользователю

### resume (auto-activate)
**Triggers:** "продолжим", "что было", "resume", "где остановились", "начнём с прошлого", "что в работе", "контекст сессии"

**Steps:**
1. Прочитать `tasks.md` — показать HIGH-приоритет и открытые задачи
2. Прочитать последние `details/open-*.md` — показать контекст
3. Предложить с чего начать

## Commands

- `/task [args]` → вызывает skill task-manager
- `/finalize` → вызывает skill finalize
- `/fin` → алиас /finalize
- `/resume` → вызывает skill resume

## Storage

Directory: `.claude/session/`

### Task file format (details/)

```markdown
---
id: 7
status: open|done
priority: HIGH|MEDIUM|LOW
created: 2026-03-31
closed: null
blockedBy: []
tags: []
---

# Task title

## Problem/Description
What needs to be done.

## Context
Where it came from.

## Plan
Specific steps.

## How to verify
Command or test.
```

### Index (tasks.md)

```markdown
# Task Registry

Last updated: YYYY-MM-DD

## Open

| # | Task | Priority | Blocked by |
|---|------|----------|------------|

## Done

| # | Task | Date |
|---|------|------|
```

Numbering is sequential across sessions — never reset.

### Queue (queue.md)

Extended descriptions of queued tasks with context, order, artifacts.

## Confirmation Policy

- create, list, show, update — silent
- close, delete — AskUserQuestion before execution

## Plugin Structure

```
cc-task-manager/
  .claude-plugin/
    plugin.json
    marketplace.json
  skills/
    task-manager/
      SKILL.md
    finalize/
      SKILL.md
    resume/
      SKILL.md
  commands/
    task.md
    finalize.md
    fin.md
    resume.md
  install.sh
  README.md
  README.en.md
  CLAUDE.md
  LICENSE
```
