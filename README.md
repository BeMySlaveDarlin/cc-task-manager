# cc-task-manager

[English](README.en.md)

Claude Code plugin для управления задачами проекта. Состояние ведёт CLI `cctm` — модель только формулирует задачи, инварианты держит код.

## Требования

- Claude Code CLI
- python3
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
cd cc-task-manager && bash install.sh
```

Legacy-режим не подключает hooks — автосинк работает только при установке плагином.

## Использование

Skills активируются по ключевым словам или явно:

- `/ts` — CRUD задач: «создай задачу», «покажи задачи», «закрой задачу #5»
- `/finalize` — финализация сессии: «финализируй», «подведи итоги»
- `/rs` — восстановление контекста: «продолжим», «где остановились»

CLI доступен и напрямую:

```
cctm list             # активные задачи
cctm next             # что делать дальше (без заблокированных)
cctm show 7           # задача целиком
cctm create --title "..." --priority HIGH
cctm close 7
cctm grep "auth"      # поиск по телам задач
cctm sync             # сверка с нативными задачами Claude Code
cctm doctor           # проверка инвариантов
cctm export --md      # человекочитаемый дамп

cctm handoff latest   # снимок последней сессии
cctm handoff list     # кто и когда финализировался, включая параллельные сессии
cctm handoff show ab12cd34
cctm handoff write --md handoff.md
```

## Хранение

`.claude/session/` целевого проекта:

```
meta.json               счётчик id, версия схемы
tasks/007.json          одна задача = один файл, вся целиком
handoff/ab12cd34.json   снимок сессии: один файл на сессию
```

Статусы: `open`, `deferred`, `done`, `cancelled`. Никаких markdown-файлов в сторе,
никакого дублирования состояния — индекс строится на лету.

### Синхронизация с нативным стором

Claude Code ведёт свои задачи (TaskCreate/TaskUpdate) в `~/.claude/tasks/session-*/`.
`cctm sync` находит сессии проекта, сопоставляет задачи (по связке `external`, затем по заголовку)
и переносит состояние в реестр. Hook `TaskCompleted` запускает синк автоматически, `SessionEnd` —
синк плюс handoff (`cctm session-end`), так что оборванная сессия не оставляет реестр протухшим.

## Handoff между сессиями

Задачи говорят «что», handoff — «где остановились». Пишется на `/finalize`, читается на `/rs`.

Файл на сессию (`handoff/<первые 8 символов session id>.json`), поэтому параллельные сессии
не перетирают друг друга: каждая пишет своё, `cctm handoff latest` отдаёт самый свежий и
отдельной строкой сообщает, что параллельно писали ещё N сессий — их видно в `cctm handoff list`.

Списки задач в handoff проставляются автоматически: каждая правка помечает задачу id сессии
(`session`, `created_by` в JSON задачи), так что чужая работа в чужой handoff не попадает.

Хук `SessionEnd` дописывает handoff сам:

- сессия закрылась без `/finalize`, но задачи трогала → технический handoff (`kind: auto`,
  списки задач без текста — видно, что вообще происходило);
- после `/finalize` ещё что-то делали → к сводке дописывается блок «После финализации»,
  ручной текст не затирается.

Хранится 20 последних, дальше вытесняются; `cctm handoff prune --keep N --days D` — вручную.

## Миграция с 1.x

**Автоматическая.** Первое же обращение к реестру в проекте со старым форматом запускает миграцию:
делается бэкап `.claude/session.bak-YYYYMMDD`, задачи переносятся в JSON-стор, старые
`tasks.md` / `queue.md` / `details/` удаляются, печатается отчёт. Затем исходная команда выполняется как обычно.

Переносит `tasks.md` + `details/*.md` (включая `archive/`, датные имена, `cancelled-`/`superseded-`).
Файлы, не являющиеся задачами, остаются на месте и перечисляются в отчёте.

Ручной контроль, если нужен:

```
cctm --no-auto-migrate list        # отказаться от автомиграции, только сообщить (exit 3)
cctm migrate --dry-run             # план без изменений
cctm migrate --path /path/to/proj  # мигрировать чужой проект, не заходя в него
```

## Кастомизация

`.claude/finalize.local.md` — локальные шаги финализации (before/pre + post).

## Лицензия

[MIT](LICENSE)
