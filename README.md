# gh-monday

Local-first Monday morning GitHub triage as a `gh` extension.

Run one command and get:
- local repositories that are behind upstream
- local repositories untouched for 30+ days (cleanup suggestions)
- review requests in repositories you have locally
- mentions in repositories you have locally
- a filtered global activity snapshot

## Why this exists

`gh status` is good for global activity, but it does not prioritize repos you actually have checked out.  
`gh-monday` adds that local bias first, then falls back to the global view.

It also applies a time window:
- rolling lookback window (default 7 days)
- plus a weekly baseline cache: during the week, follow-up runs only show activity since that week’s first run

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
--no-global     Skip the final global activity section
--no-mentions   Skip mentions section
--jobs N        Parallelism for local repo checks (default: 8)
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
- `GH_MONDAY_JOBS` parallel workers for local repo checks
- `GH_MONDAY_MAX_DEPTH` max directory depth for repo discovery
- `GH_MONDAY_DAYS` rolling lookback window in days
- `GH_MONDAY_STALE_DAYS` stale repo threshold in days
- `GH_MONDAY_REPO_CACHE_TTL` discovery cache TTL in seconds
- `GH_MONDAY_DEBUG=true` enable debug output

## Performance Tips

- Keep `GH_MONDAY_ROOTS` narrow (for example only active work folders).
- Leave fetch off by default and use `--fetch` only when you want freshest behind counts.
- Increase `--jobs` on fast machines.
- Use cache (default) so only the first run does full discovery.

## Notes

- The extension uses `jq` for JSON parsing in local review/mention sections.
- If `jq` is not installed, those sections are skipped and the rest still works.
