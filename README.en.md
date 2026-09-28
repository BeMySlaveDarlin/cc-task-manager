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
cctm doctor           # invariant check, including store forks in worktrees
cctm merge ../wt      # merge another store (a worktree fork) into this one
cctm export --md      # human-readable dump

cctm handoff latest   # snapshot of the last session in this worktree and branch
cctm handoff list     # who finalized and when, grouped by worktree and branch
cctm handoff show feat          # by key, branch, worktree, date or a word from the title
cctm handoff show --task 12     # the handoff that includes task 12
cctm handoff write --md handoff.md --attach probe.py --attach results/
```

## Storage

`.claude/session/` of the target project:

```
meta.json               id counter, schema version
tasks/007.json          one task = one file, complete
handoff/2026-09-28_1249_feat_ab12cd34.json   session snapshot: first write time, branch, key
handoff/2026-09-28_1249_feat_ab12cd34/       attachments of that handoff, if any
```

Statuses: `open`, `deferred`, `done`, `cancelled`. No markdown files in the store,
no duplicated state — the index is built on the fly.

### Native store sync

Claude Code keeps its own tasks (TaskCreate/TaskUpdate) in `~/.claude/tasks/session-*/`.
`cctm sync` finds the project's sessions, matches tasks (by the `external` link, then by title)
and carries the state into the registry. The `TaskCompleted` hook runs the sync automatically,
`SessionEnd` runs sync plus handoff (`cctm session-end`) — an interrupted session no longer leaves
the registry stale.

### Hooks

| Event | Command | What it does |
|---|---|---|
| `SessionStart` | `cctm session-start` | puts the previous session's context into the new one |
| `TaskCompleted` | `cctm sync` | carries the task status into the registry |
| `SessionEnd` | `cctm session-end` | sync + handoff for an interrupted session |

Hooks stay inside their own project (store lookup is described below). In a directory without
a store the hook exits quietly instead of picking up someone else's registry one level up.

## Worktrees, parallel sessions, projects without git

**Where the store is.** The nearest `.claude/session` from the current directory up to the git
repository root. If none is found and the directory is a git worktree, the main checkout's store
is used: all worktrees share one registry, and `cctm init` from a worktree creates it there rather
than a fork that dies with `git worktree remove`. Without git the boundary is the directory the
session started in (taken from Claude Code's live session registry or from the transcript): the
lookup never goes above it, so a non-git project in `~/proj` does not end up in `~/.claude/session`.

**Branch.** A task remembers the branch it was created on; inside a worktree `cctm next` and
`cctm list` show that branch's tasks first. A handoff remembers its worktree and branch:
`SessionStart` picks the handoff of its own worktree and branch, lists the others one line each
("ворктри repo-wt, ветка feat") and never passes them off as "the previous session".

**Neighbours.** A live session in the same tree (same branch, same directory) is reported to a new
one: "session X is working in this tree — its changes in git status are not yours". A task last
touched by a live neighbour is marked ⚑ in `next`/`list`. This is not a lock: nothing is stored or
blocked, and the mark disappears once the session ends.

**Forks.** If a worktree already has its own store (from older versions), `cctm doctor` in the
main checkout reports it, and `cctm merge <worktree> [--dry-run]` moves its tasks and handoffs
under new ids, tags likely duplicates with `dup` and renames the source to `session-merged-*`.

## Context at session start

Tasks and handoffs are useless until the agent has read them. The `/rs` skill fires on a user
phrase ("let's continue", "where did we stop") — which means it may not fire at all.
The `SessionStart` hook doesn't ask: it puts the summary into the new session's context itself.

About 15 lines are injected: the latest handoff header, its title, task counters, the
"Следующий шаг" (next step) section and the top three tasks from `cctm next`. The full handoff
body stays with `/rs` — pouring it in on every start would just burn context.

The injection happens on `startup` and `clear`; `resume` and `fork` are skipped — the transcript
is already restored there.

Per-project mode — the `session_start` key in `meta.json`:

```
"session_start": "brief"   default: summary
"session_start": "full"    the whole handoff
"session_start": "off"     disabled
```

To see what would go into the context:

```
cctm session-start --raw
```

## Session handoff

Tasks say "what", the handoff says "where we stopped". Written by `/finalize`, read by `/rs`.

One file per session, so parallel sessions never overwrite each other. The name is readable
without opening the file: `2026-09-28_1249_feat_ab12cd34.json` — date and time of the first write,
branch (absent without git), first 8 chars of the session id. Rewriting the same handoff keeps the
name. Old `<key>.json` names are renamed on the next handoff write or by `cctm doctor --fix`.

Finding the right handoff needs no file reading: `cctm handoff show <query>` takes the freshest
match by key, branch, worktree name, date (`2026-09-27`) or a word from the title; `--task 12`
finds the handoff that includes task 12. `cctm handoff list [query]` groups by worktree and branch,
your own group first.

Attachments are for what the next session needs but lives outside git or in a worktree about to be
removed: `cctm handoff write --md h.md --attach probe.py --attach results/` copies them into a
directory next to the handoff (up to 20 MB per handoff). `show` lists them with the path, prune
removes them together with the handoff.

Parallel sessions stay independent: `cctm handoff latest` returns the freshest one for your worktree and
branch and states on a separate line how many other sessions wrote in parallel — `cctm handoff list`
shows them all.

Task lists are filled in automatically: every edit stamps the task with the session id
(`session`, `touched_by`, `created_by` in the task JSON), so another session's work never lands in
your handoff, and a task touched by two sessions shows up in both handoffs.

The `SessionEnd` hook keeps the handoff honest:

- session ended without `/finalize` but touched tasks → a technical handoff (`kind: auto`);
- work continued after `/finalize` → an "После финализации" block is appended, the hand-written
  summary is never overwritten.

The last 20 are kept, but the 3 freshest per worktree and branch are never evicted — a busy
worktree cannot push the others out. `cctm handoff prune --keep N --days D` for manual cleanup.

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
