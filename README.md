# cc-task-manager

[English](README.en.md)

Claude Code plugin для управления задачами проекта. Auto-activate skills, вызываемые и как slash-команды.

## Требования

- Claude Code CLI
- macOS, Linux, Windows (WSL)

## Установка

### Как плагин Claude Code (рекомендуется)

```
/plugin marketplace add BeMySlaveDarlin/cc-task-manager
/plugin install cc-task-manager@bemyslavedarlin-cc-task-manager
```

### Ручная установка (legacy)

```bash
git clone https://github.com/BeMySlaveDarlin/cc-task-manager.git
cd cc-task-manager
bash install.sh
```

## Использование

Skills активируются автоматически по ключевым словам в сообщении.

**Примеры:**

- `создай задачу: рефакторинг auth` — ts создаёт задачу
- `покажи задачи` — ts показывает список
- `финализируй` — finalize обновляет реестр
- `продолжим` — rs показывает контекст

**Явные команды:**

- `/ts` — управление задачами
- `/finalize` — финализация сессии
- `/rs` — восстановление контекста

## Хранение

Задачи хранятся в `.claude/session/` целевого проекта:

- `tasks.md` — индекс
- `queue.md` — очередь
- `details/` — файлы задач (YAML frontmatter + markdown)

### Связь с нативным стором Claude Code

Claude Code ведёт собственный стор задач — `.claude/tasks/tasks.json` (тулы TaskCreate/TaskUpdate).
Во время рабочей сессии прогресс часто оседает именно там. Плагин учитывает оба источника:

- `/ts list` и `/rs` сверяют реестр с `tasks.json` и показывают расхождения
- `/finalize` переносит состояние из `tasks.json` в реестр
- Связь задач между сторами — поле `external_id` во frontmatter detail-файлов

Реестр (`.claude/session/`) — источник истины между сессиями, `tasks.json` — оперативное
состояние текущей сессии.

## Кастомизация

`.claude/finalize.local.md` — локальные шаги финализации (before/pre + post).

## Skills

| Skill    | Триггеры                                       | Что делает               |
|----------|------------------------------------------------|--------------------------|
| ts       | создай задачу, покажи задачи, закрой задачу... | CRUD для задач           |
| finalize | финализируй, подведи итоги, wrap up...         | Финализация сессии       |
| rs       | продолжим, где остановились, resume...         | Восстановление контекста |

## Лицензия

[MIT](LICENSE)
