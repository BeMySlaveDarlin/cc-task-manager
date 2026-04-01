# cc-task-manager

[English](README.en.md)

Claude Code plugin для управления задачами проекта. Auto-activate skills + явные команды.

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
- `/finalize` (alias `/fin`) — финализация сессии
- `/rs` — восстановление контекста

## Хранение

Задачи хранятся в `.claude/session/` целевого проекта:

- `tasks.md` — индекс
- `queue.md` — очередь
- `details/` — файлы задач (YAML frontmatter + markdown)

## Кастомизация

`.claude/finalize.local.md` — локальные шаги финализации (before/pre + post).

## Skills

| Skill          | Триггеры                                       | Что делает               |
|----------------|------------------------------------------------|--------------------------|
| ts             | создай задачу, покажи задачи, закрой задачу... | CRUD для задач           |
| finalize / fin | финализируй, подведи итоги, wrap up...         | Финализация сессии       |
| rs             | продолжим, где остановились, resume...         | Восстановление контекста |

## Лицензия

[MIT](LICENSE)
