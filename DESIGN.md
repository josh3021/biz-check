# biz-check design

## Intent
One skill file set that Claude Code, Codex, Gemini and Grok can all run to audit the business side of the current project. Token efficiency is a core requirement. Skill files are in English for every user and model; output follows a per-project language choice.

## Goals / non-goals / anti-goals
- Goals: business logic, MVP, viability, pricing (subscription vs one-time), personas, competition, risk/regulation, KPIs, aha moment/onboarding.
- Non-goals: a financial modeling tool; market research on its own (web search only with `market`).
- Anti-goals: stating unsupported numbers as facts; rereading the whole repo on every run.

## Approach (chosen: A)
- A. One skill + `references/` modules — one description always loaded, only chosen modules read. **Chosen.**
- B. One skill per module — 9 descriptions always loaded, shared rules duplicated.
- C. Single file — everything loaded every time.

## Decisions
- Location: source `~/.agents/skills/biz-check/`, symlink `~/.claude/skills/biz-check`.
- Cache in the project's `.biz/`: `config` (language), `facts.md`, `assumptions.md`, `report.md` (marker blocks per module), `state` (last synced commit). Later runs look only at `git diff --stat <state>..HEAD`.
- Language: stored per project in `.biz/config`, because sandboxed agents (e.g. Codex workspace-write) can't write outside the project. First run asks; non-interactive runs use the request's language.
- Output: per module `item | verdict (✅/⚠️/❌/—) | evidence | next action`. Three levels, stored per project in `.biz/config`: `easy` = plain sentences with no development terms, for planners and other non-developers; `standard` = the table (formerly `quick`); `deep` = table + calculations, alternatives, a re-check of failed items and a cross-module action plan.
- Levels change presentation only. Judging and evidence rules are identical, and `report.md` always keeps the evidence table, so an `easy` run still leaves developers something to verify and switching level needs no re-scan.
- Read budget ~40KB per full scan, ≤5 batched command calls (`deep`: +20KB and 2 calls to re-check failed items) (measured with Codex on a real project: input tokens 544k → 229k).
- Numbers without evidence are marked "assumption" with a formula.
