# gh-monday

Ranked GitHub triage as a `gh` extension. Know what needs your attention *now*.

Run one command and get:
- **🔴 ACTION NEEDED** - PRs/issues where someone else acted last (waiting on you)
- **🟡 WAITING ON OTHERS** - your work where you acted last (ball in their court)
- **📥 LOCAL REPOS BEHIND** - local checkouts that need to sync
- **🤖 AI CODING SESSIONS** - recent Claude Code and Codex sessions you might want to resume
- **🗑️ CLEANUP CANDIDATES** - stale local repos with no open GitHub work

## Why this exists

`gh status` shows everything. `gh-monday` shows what *actually needs your attention*.

The ranking algorithm prioritizes by:
1. **Waiting on you** (+500) - someone else commented/reviewed last
2. **Local repo** (+200) - work you have checked out
3. **Your role** - author (+150) > reviewer (+100) > assignee (+75)
4. **Recency** (0-100) - more recent = higher priority
5. **Draft status** (-100) - drafts deprioritized

It also applies a time window:
- rolling lookback window (default 7 days)
- weekly baseline cache: during the week, follow-up runs only show activity since that week’s first run

## Install

### Local development install

```bash
cd ~/Developer/gh-monday
/opt/homebrew/bin/gh extension install .
```

### Upgrade from local checkout

```bash
cd ~/Developer/gh-monday
./install.sh
```

## Usage

```bash
gh monday
```

Options:

```text
--fetch         Fetch remotes before behind/ahead checks (slower, freshest counts)
--no-fetch      Do not fetch remotes before behind/ahead checks
--jobs N        Parallelism for checks (default: 8)
--max-depth N   Max directory depth when scanning for local repos (default: 6)
--days N        Rolling lookback window in days for activity (default: 7)
--stale-days N  Suggest cleanup for local repos untouched for N days (default: 30)
--reset-week-cache  Start a new weekly baseline now
--no-cache      Disable local repo discovery cache
--cache-ttl S   Cache TTL in seconds for repo discovery (default: 21600)
--limit N       Max search results fetched per section (default: 120)
--roots A:B:C   Colon-separated local roots to scan
--debug         Enable debug logging
```

## Configuration

Environment variables:

- `GH_REAL_BIN` path to gh binary used by the extension (default: `/opt/homebrew/bin/gh`)
- `GH_MONDAY_ROOTS` default roots (same format as `--roots`)
- `GH_MONDAY_LIMIT` default limit (same as `--limit`)
- `GH_MONDAY_FETCH` set `true` to fetch remotes by default
- `GH_MONDAY_JOBS` parallel workers (default: 8)
- `GH_MONDAY_MAX_DEPTH` max directory depth for repo discovery
- `GH_MONDAY_DAYS` rolling lookback window in days
- `GH_MONDAY_STALE_DAYS` stale repo threshold in days
- `GH_MONDAY_REPO_CACHE_TTL` discovery cache TTL in seconds
- `GH_MONDAY_ACTOR_CACHE_TTL` last-actor cache TTL in seconds (default: 3600)
- `GH_MONDAY_DEBUG=true` enable debug output

## How it works

1. **Discover local repos** - scans configured roots for git repos with GitHub remotes
2. **Fetch GitHub items** - PRs authored, review-requested, assigned; issues involving you
3. **Enrich with last actor** - checks who commented/reviewed last on each item (cached)
4. **Score and rank** - applies the ranking algorithm
5. **Find AI sessions** - scans Claude Code and Codex session history for recent work
6. **Display** - shows ranked results in priority order

## AI Sessions Integration

gh-monday scans for recent sessions from:
- **Claude Code** (`~/.claude/projects/`) - shows 🟠
- **OpenAI Codex** (`~/.codex/sessions/`) - shows 🟢

For each session, it displays:
- Timestamp of last activity
- Project directory
- First user prompt (to remind you what you were working on)

To resume a session:
- Claude Code: `claude --resume`
- Codex: `codex resume`

Environment variables:
- `AI_SESSION_DAYS` - how far back to look for sessions (default: 7)
- `AI_SESSION_MAX` - maximum sessions to scan per tool (default: 15)

## Performance Tips

- Keep `GH_MONDAY_ROOTS` narrow (for example only active work folders)
- Leave fetch off by default and use `--fetch` only when you want freshest behind counts
- Increase `--jobs` on fast machines
- Use cache (default) so only the first run does full discovery
- Last-actor results are cached per-item; re-runs are fast for unchanged items

## Requirements

- `gh` CLI (authenticated)
- `jq` for JSON processing
- `git`
