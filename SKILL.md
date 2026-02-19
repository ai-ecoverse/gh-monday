---
name: gh-monday
description: |
  Ranked GitHub triage — show what needs attention right now. Scans open PRs, issues,
  local repos, and AI coding sessions, then prioritizes by who acted last.
  Use when: (1) starting the day or week, (2) triaging GitHub notifications,
  (3) checking what needs attention, (4) reviewing PR queue, (5) finding stale work.
  Triggers on: "what should I work on", "Monday morning", "triage my GitHub",
  "what needs my attention", "check my PRs", "review queue", "It's Monday again",
  "weekly triage", "what's waiting on me", "GitHub status", "open PRs",
  "clean my inbox", "dismiss noise", "notification triage", "unread notifications".
---

# gh-monday — GitHub Triage Skill

Mondays are an opportunity to delegate and delete.

Run `gh monday` to get a prioritized view of GitHub work needing attention — PRs, issues, and notifications — then dismiss the noise, act on what matters, and unsubscribe from what doesn't.

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

Notifications are included by default. To skip them: `gh monday --no-notifications`.

See the [README.md](README.md) in this repo for the full list of CLI options and environment variables.

## Parsing the Output

The output has 6 sections. Handle each differently:

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

### 📬 NOTIFICATIONS — triage by tier

Unread GitHub notifications, categorized into four tiers:

- **🔴 ACTION NEEDED** — `review_requested`, `mention`, `assign`, `approval_requested`. Items requiring your response. Cross-referenced with the main ACTION NEEDED section to avoid duplicates.
- **🟡 YOUR STUFF** — `author`, `manual`. Activity on your own PRs/issues.
- **🟠 STATE CHANGES** — `state_change`, `ci_activity`. Merges, closures, CI results.
- **🟢 NOISE** — `subscribed`, `team_mention`, everything else. Shown as repo-grouped counts with a hint to run `--dismiss-noise`.

**After the tiers, look for:**
- **🔕 NOISY REPOS** — Repos with 5+ noise notifications and zero engagement. Each includes a `gh api graphql` mutation command to unsubscribe.

**How to present notifications:**
- Lead with 🔴 tier items — these are your action items
- Mention 🟡 and 🟠 tiers briefly (counts + notable items)
- For 🟢 noise: report count and offer to dismiss with `--dismiss-noise`
- For 🔕 noisy repos: suggest unsubscribing and offer to run the provided commands

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

## Notification Triage Workflow

After presenting the initial dashboard, guide the user through notification triage:

1. **Dismiss noise** — If there are 🟢 NOISE notifications, offer to clean them up:
```bash
gh monday --dismiss-noise 2>&1 | cat
```
This marks all noise-tier notifications as done on GitHub. It's safe — these are `subscribed`, `team_mention`, and other low-signal reasons.

2. **Mark specific threads done** — If the user wants to dismiss individual notifications:
```bash
gh monday --mark-done THREAD_ID1 THREAD_ID2 2>&1 | cat
```

3. **Unsubscribe from noisy repos** — If 🔕 NOISY REPOS are listed, suggest running the provided `gh api graphql` mutation commands. Explain that this stops future notifications from repos where the user has no active work and only receives noise.

4. **Act on what matters** — From the 🔴 tiers (both main ACTION NEEDED and notification ACTION NEEDED), help the user with concrete next steps: review a PR, respond to an issue, or address a mention.

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

**Fine-grained PAT warning:**
```
Fine-grained PAT detected — notifications API requires a classic token (ghp_) or OAuth token.
```
→ Explain that GitHub fine-grained PATs (`github_pat_*`) don't support the notifications API. Suggest running `gh auth login` to switch to an OAuth token, or using `--no-notifications` to skip the notification section.

**Empty results (all sections show "(none)"):**
→ "All clear! Nothing needs your attention right now."

