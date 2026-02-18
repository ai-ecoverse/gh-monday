---
name: gh-monday
description: |
  Ranked GitHub triage — show what needs attention right now. Scans open PRs, issues,
  local repos, and AI coding sessions, then prioritizes by who acted last.
  Use when: (1) starting the day or week, (2) triaging GitHub notifications,
  (3) checking what needs attention, (4) reviewing PR queue, (5) finding stale work.
  Triggers on: "what should I work on", "Monday morning", "triage my GitHub",
  "what needs my attention", "check my PRs", "review queue", "It's Monday again",
  "weekly triage", "what's waiting on me", "GitHub status", "open PRs".
---

# gh-monday — GitHub Triage Skill

Run `gh monday` to get a prioritized view of GitHub work needing attention.

## Running the Tool

Execute in two steps for best UX:

1. **First** — Get a quick non-fetch summary (instant, uses cache):
```bash
gh monday --no-fetch 2>&1 | cat
```

2. **In parallel** — Start a background fetch for fresh data:
```bash
gh monday 2>&1 | cat &
```

Present the cached results first, then update if the background fetch returns meaningfully different data.

Piping through `cat` strips ANSI color codes for clean parsing.

See the [README.md](README.md) in this repo for the full list of CLI options and environment variables.

## Parsing the Output

The output has 5 sections. Handle each differently:

### 🔴 ACTION NEEDED (waiting on you) — PRIMARY FOCUS

Items where someone else acted last — the ball is in the user's court. Each item shows:
- Date, repo, PR/issue number
- Title
- Type (PR/Issue), role (author/reviewer/assignee), who acted last
- URL

**For each item, suggest a concrete next action:**
- PR where user is reviewer → "Review PR #N — @author pushed changes"
- PR where user is author and someone reviewed → "Address review on PR #N — @reviewer left feedback"
- Issue where someone commented → "Respond to issue #N — @commenter asked about X"

### 🟡 WAITING ON OTHERS (ball in their court) — FYI only

Items where the user acted last. Mention briefly: "N items waiting on others" with a short list. No action needed.

### 📥 LOCAL REPOS BEHIND UPSTREAM — brief mention

Repos that need `git pull`. Mention count: "N repos behind upstream." Offer to list them if the user wants.

### 🤖 RECENT AI CODING SESSIONS — highlight resumable

Recent Claude Code (🟠) and Codex (🟢) sessions. Highlight any that look resumable with their first prompt.

### 🗑️ CLEANUP CANDIDATES — count only

Stale local repos with no open GitHub work. **Summarize by count only** (e.g., "82 stale repos could be cleaned up"). Do NOT list them individually.

## Presenting Results

Provide a concise summary:

1. **Lead with action items** from the 🔴 section — prioritized list with concrete next steps
2. **Brief FYI** for waiting/behind sections (counts + notable items)
3. **Offer to help** with specific items: "Want me to review PR #320?" or "Should I check issue #549?"

If the 🔴 section is empty, lead with "All clear! Nothing needs your attention right now." and briefly mention the other sections.

## Error Handling

**Not installed:**
```
gh: "monday" is not a gh command.
```
→ Suggest: `gh extension install trieloff/gh-monday`

**Auth failure or gh not found:**
```
Could not determine GitHub username
```
→ Suggest: Run `gh auth status` to check authentication, then `gh auth login` if needed.

**Empty results (all sections show "(none)"):**
→ "All clear! Nothing needs your attention right now."

