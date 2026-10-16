# closure

English | [正體中文](README.zh-Hant.md)

A [Claude Code](https://claude.com/claude-code) skill that **audits a work session before it ends** and gives **every open thread a disposition**: resolved now, documented, memorized, handed off, or dropped with your approval. It re-reads the session instead of summarizing it, so a thread raised midway is not lost when the session closes. No hook, no MCP server, no external service.

## What you get

### Audit: `/closure`

Re-reads the current session and checks four categories:

1. **Opening requests**: was each one fully resolved, including verification? "Implemented but untested" counts as open.
2. **Mid-session threads**: side requests, pivots and deferrals raised along the way.
3. **Unexpected findings**: bugs, risks or tech debt noticed in passing.
4. **Decisions**: calls made only in conversation and not yet written anywhere durable.

It also lists uncommitted or unpushed changes.

```text
/closure            → audit this session and propose a disposition for each open item
```

The skill is model-invocable. Phrases such as "anything left?", "wrap up", "loose ends", 「還有未盡事宜嗎」 or 「收工」 trigger it, and the model may also run it before ending a long session.

### Dispositions

Every open item gets exactly one:

| Disposition | When |
|---|---|
| **Resolve now** | quick and in scope |
| **Document** | decisions, behavior, deprecations: the project's docs or issue tracker |
| **Memorize** | durable preferences, decisions or project state: the agent's persistent memory |
| **Hand off** | unfinished work that needs context in the next session |
| **Drop** | not needed, only with your explicit approval |

The report lists each item with its disposition and ends by confirming that no item is left without one. Items that need action are carried out, or proposed for your go-ahead.

### Works with your own setup

The skill names no specific companion tool. When a skill for a disposition is available, such as a memory-writing skill, a session handoff skill or a skill that maintains a project doc, it delegates to that skill; otherwise it does the work directly. When your own instructions (for example your `CLAUDE.md`) say where decisions, docs or handoffs go, it follows them.

Two public skills fit these slots: [claude-memory](https://github.com/howar31/claude-memory) for memory and [handoff](https://github.com/howar31/handoff) for handoff documents. Neither is required.

## Architecture

```
/closure  -->  re-read the session; sweep four categories plus
               uncommitted / unpushed changes; assign one disposition
               per open item; report; act or propose
```

Files involved:

```
~/.claude/skills/closure/          the skill (symlink → repo)
```

The skill writes no files of its own. No hook is installed and `settings.json` is not modified.

## Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/howar31/closure
```

The location is up to you; the installer resolves its own path and works from anywhere.

### 2. Install

```bash
cd closure && ./setup.sh
```

The installer symlinks `skills/closure` into `~/.claude/skills/`, so the skill is invoked as **`/closure`** (no namespace prefix) and the repo stays the single source of truth. It is idempotent and safe to re-run. If a real directory already exists at the skill path, it stops with a message; `--force` backs that directory up to `~/.claude/skills/.bak/<timestamp>/` and replaces it.

### 3. Verify

```bash
./setup.sh             # re-run any time; reports all checks or what is wrong
./setup.sh --dry-run   # preview without applying
./setup.sh --force     # replace an existing real directory at the skill path (backed up first)
```

To update, run `git pull` in the clone: the installed skill is a symlink, so Claude Code reads the new files directly. Re-run `setup.sh` only when the link is missing or points elsewhere.

### 4. Use it

Skills are picked up dynamically; run `/reload-plugins` in an active session if `/closure` does not appear immediately. No restart is required.

## Other install methods

### Plugin manager

Installs the same skill through Claude Code's plugin manager. Plugin-managed skills are **namespaced**, so it appears as **`/closure:closure`**. Two registration paths install the same plugin; pick one.

**Self-hosted marketplace** (this repo is its own marketplace):

```bash
claude plugin marketplace add howar31/closure
claude plugin install closure@closure
```

**Central marketplace** (all of howar31's plugins; register once, then install any of them by name):

```bash
claude plugin marketplace add howar31/howar31-marketplace
claude plugin install closure@howar31
```

Update a plugin install with `claude plugin update closure@howar31` (or `closure@closure`). Claude Code auto-updates only official marketplaces by default; turn it on for this one in `/plugin` → Marketplaces if you want it.

### npx skills

The skill uses no Claude Code-specific paths or tools, so it also works in other coding agents. The cross-agent [`npx skills`](https://github.com/vercel-labs/skills) CLI installs it for the agents you pick in its wizard:

```bash
npx skills add howar31/closure -g     # then follow the wizard
npx skills update closure -g          # update later
```

### Which install method?

| | `setup.sh` (symlink) | npx skills | plugin manager |
|---|---|---|---|
| Slash name | `/closure` (shortest) | `/closure` | `/closure:closure` |
| Install / update | clone + `setup.sh`; update with `git pull` | `npx skills add` / `update` | `claude plugin install` / `update` |
| Discoverable | no | no | yes (via marketplace) |

Install only one method: `setup.sh` and `npx skills` both write `~/.claude/skills/closure`, and the plugin manager exposes the same skill under a second name.

## What you'll see

After `/closure`, the agent prints the open items it found, each with its disposition, as a short list or table, and confirms that none is left without one. It then carries out the items in scope or asks for your go-ahead on the rest. When nothing is open, it says so.

## Backup

The skill directory in `~/.claude/skills/` is a symlink back into the repo, so the repo is the single source of truth and any backup that includes the clone covers it.

## Uninstall

```bash
# setup.sh install (the replaced real dir, if any, is in ~/.claude/skills/.bak/<timestamp>/)
rm ~/.claude/skills/closure

# npx skills install
npx skills remove closure -g

# Plugin install
claude plugin uninstall closure@closure   # or closure@howar31
```

There is nothing to undo in `settings.json`.

## License

MIT. See [LICENSE](LICENSE).
