# cc-task-manager

[Русский](README.md)

Claude Code plugin for project task management. Auto-activating skills, also invocable as slash commands.

## Requirements

- Claude Code CLI
- macOS, Linux, Windows (WSL)

## Installation

### As a Claude Code plugin (recommended)

```
/plugin marketplace add BeMySlaveDarlin/cc-task-manager
/plugin install cc-task-manager@bemyslavedarlin-cc-task-manager
```

### Manual installation (legacy)

```bash
git clone https://github.com/BeMySlaveDarlin/cc-task-manager.git
cd cc-task-manager
bash install.sh
```

## Usage

Skills activate automatically based on keywords in your message.

**Examples:**

- `create task: auth refactoring` — ts creates a task
- `show tasks` — ts lists tasks
- `finalize` — finalize updates the registry
- `let's continue` — rs shows context

**Explicit commands:**

- `/ts` — task management
- `/finalize` — session finalization
- `/rs` — context restore

## Storage

Tasks are stored in `.claude/session/` of the target project:

- `tasks.md` — index
- `queue.md` — queue
- `details/` — task files (YAML frontmatter + markdown)

### Relation to the native Claude Code task store

Claude Code maintains its own task store — `.claude/tasks/tasks.json` (TaskCreate/TaskUpdate tools).
During a working session, progress often lands there. The plugin reconciles both sources:

- `/ts list` and `/rs` compare the registry against `tasks.json` and report divergence
- `/finalize` merges the state from `tasks.json` into the registry
- Tasks are linked across stores via the `external_id` field in detail file frontmatter

The registry (`.claude/session/`) is the source of truth between sessions, `tasks.json` is the
live state of the current session.

## Customization

`.claude/finalize.local.md` — local finalization steps (before/pre + post).

## Skills

| Skill    | Triggers                                     | What it does         |
|----------|----------------------------------------------|----------------------|
| ts       | create task, show tasks, close task...       | Task CRUD            |
| finalize | finalize, wrap up, summarize session...      | Session finalization |
| rs       | let's continue, where we left off, resume... | Context restore      |

## License

[MIT](LICENSE)
