# cc-task-manager

[Русский](README.md)

Claude Code plugin for project task management. State is owned by the `cctm` CLI — the model only phrases tasks, the code holds the invariants.

## Requirements

- Claude Code CLI
- python3
- macOS, Linux, Windows (WSL)

## Installation

### As a Claude Code plugin (recommended)

```
/plugin marketplace add BeMySlaveDarlin/cc-task-manager
/plugin install cc-task-manager@bemyslavedarlin-cc-task-manager
```

### Manual install (legacy)

```bash
git clone https://github.com/BeMySlaveDarlin/cc-task-manager.git
cd cc-task-manager && bash install.sh
```

Legacy mode does not wire up hooks — autosync only works with the plugin install.

## Usage

Skills activate on keywords or explicitly:

- `/ts` — task CRUD: "create task", "show tasks", "close task #5"
- `/finalize` — session finalization: "finalize", "wrap up"
- `/rs` — context resume: "resume", "where did we stop"

The CLI is also available directly:

```
cctm list             # active tasks
cctm next             # what to do next (blocked excluded)
cctm show 7           # full task
cctm create --title "..." --priority HIGH
cctm close 7
cctm grep "auth"      # search task bodies
cctm sync             # reconcile with Claude Code native tasks
cctm doctor           # invariant check
cctm export --md      # human-readable dump
```

## Storage

`.claude/session/` of the target project:

```
meta.json        id counter, schema version
tasks/007.json   one task = one file, complete
```

Statuses: `open`, `deferred`, `done`, `cancelled`. No markdown files in the store,
no duplicated state — the index is built on the fly.

### Native store sync

Claude Code keeps its own tasks (TaskCreate/TaskUpdate) in `~/.claude/tasks/session-*/`.
`cctm sync` finds the project's sessions, matches tasks (by the `external` link, then by title)
and carries the state into the registry. The `TaskCompleted` and `SessionEnd` hooks run the sync
automatically — an interrupted session no longer leaves the registry stale.

## Migrating from 1.x

**Automatic.** The first registry access in a project on the old format triggers the migration:
a `.claude/session.bak-YYYYMMDD` backup is taken, tasks move into the JSON store, the old
`tasks.md` / `queue.md` / `details/` are removed, and a report is printed. The original command then runs as usual.

Handles `tasks.md` + `details/*.md` (including `archive/`, date-based names, `cancelled-`/`superseded-`).
Non-task files stay in place and are listed in the report.

Manual control if you want it:

```
cctm --no-auto-migrate list        # opt out, just report (exit 3)
cctm migrate --dry-run             # plan, no changes
cctm migrate --path /path/to/proj  # migrate another project without entering it
```

## Customization

`.claude/finalize.local.md` — local finalization steps (before/pre + post).

## License

[MIT](LICENSE)
