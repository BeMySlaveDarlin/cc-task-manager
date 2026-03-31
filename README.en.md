# cc-task-manager

[Русский](README.md)

Claude Code plugin for project task management. Auto-activating skills + explicit commands.

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

- `create task: auth refactoring` — task-manager creates a task
- `show tasks` — task-manager lists tasks
- `finalize` — finalize updates the registry
- `let's continue` — resume shows context

**Explicit commands:**

- `/task` — task management
- `/finalize` (alias `/fin`) — session finalization
- `/resume` — context restore

## Storage

Tasks are stored in `.claude/session/` of the target project:

- `tasks.md` — index
- `queue.md` — queue
- `details/` — task files (YAML frontmatter + markdown)

## Customization

`.claude/finalize.local.md` — local finalization steps (before/pre + post).

## Skills

| Skill | Triggers | What it does |
|-------|----------|--------------|
| task-manager | create task, show tasks, close task... | Task CRUD |
| finalize | finalize, wrap up, summarize session... | Session finalization |
| resume | let's continue, where we left off, resume... | Context restore |

## License

[MIT](LICENSE)
