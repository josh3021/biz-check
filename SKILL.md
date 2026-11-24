---
name: biz-check
description: Audit the business side of the current project against its code and docs — business logic, MVP scope, viability (unit economics, break-even), pricing (subscription vs one-time, price level), user personas, competitors/alternatives, risk/regulation, metrics/KPIs, aha moment/onboarding. Use this whenever the user asks whether a product makes business sense or will make money, what or how to charge, who it is for, what to cut from an MVP, which metrics to track, or what could kill it — in any language, even if they don't say "business review" or name a module. Caches findings in .biz/ so later runs only re-check what changed, and reports in the user's chosen language.
compatibility: Requires bash and ripgrep (rg). git is optional but needed for incremental re-runs.
---

# biz-check

Run from the project root. Read only this file and the chosen module files; never open other modules.

Batch commands. Every command round-trip resends the whole conversation, so the number of calls is the cost. Aim for 5 or fewer:
① read `.biz/config`, the module files, and check the cache (§0, §2) ② all full-scan inputs (§3 steps 1–4, only when needed) ③ code line checks (§3 step 5, at most 2 calls) ④ write `.biz/` and `state`.

## 0. Language

- `.biz/config` holds `lang: <code>` (e.g. `en`, `ko`, `ja`, `zh`, `es`).
- Missing → ask the user once which language biz-check should use (offer en / ko / ja / zh / other) and wait. If the run is non-interactive and cannot ask, use the language of the user's request. Write `.biz/config` either way.
- `lang=<code>` in the arguments overrides it and rewrites `.biz/config`.
- Everything written for the user — chat output, `facts.md`, `assumptions.md`, `report.md` — is in that language. Keep as-is: file paths, `file:line`, code identifiers, module IDs, marker comments, verdict symbols.
- After a language change, translate `facts.md` and `assumptions.md` (small, keep values), and rewrite only the `report.md` blocks this run touches; other blocks change on their next run.

## 1. Arguments

`[module...] [quick|deep] [market] [lang=<code>]` — any order. Empty → all modules, `quick`.

| Module | File | Checks |
| --- | --- | --- |
| `logic` | references/logic.md | Core loop and business rules closed in code |
| `mvp` | references/mvp.md | Scope minimal for the core value |
| `viability` | references/viability.md | Unit economics, break-even |
| `pricing` | references/pricing.md | Subscription / one-time / hybrid, price level |
| `persona` | references/persona.md | Target users vs features |
| `competition` | references/competition.md | Alternatives, differentiation |
| `risk` | references/risk.md | Legal, regulatory, operational, dependency risk |
| `kpi` | references/kpi.md | Metric definitions and measurability |
| `aha` | references/aha.md | Path to first value, drop-off points |

- `quick`: verdict table only. `deep`: table + calculations + 2–3 alternatives.
- `market`: if a web search tool exists, look up competitors and market prices and cite URLs. Without it (or without the argument), do not search; mark as "assumption".

## 2. Cache (`.biz/`)

| File | Content |
| --- | --- |
| `config` | `lang: <code>` |
| `facts.md` | Project facts, ≤60 lines: one-line product, target, revenue model, price list, payment/subscription code locations, phase plan |
| `assumptions.md` | Assumption table `name \| value \| source (assumption/citation)`. Calculations use only these names |
| `report.md` | Verdicts per module, each in a `<!-- biz:<module> -->` … `<!-- /biz:<module> -->` block |
| `state` | One line: commit hash facts were last synced to |

Decide at start:

1. No `.biz/facts.md` → **full scan** (§3).
2. Exists, git repo, and `git cat-file -e <state hash>` succeeds → look only at `git diff --stat <hash>..HEAD -- . ':!.biz'` and `git status --short -- . ':!.biz'`.
   - Nothing changed → reuse facts as-is; do not reread.
   - Otherwise open only business-relevant changed files (pricing, payment, orders, subscription, signup, onboarding, README, planning docs) and fix the matching fact lines.
3. Not git, or hash missing → full scan.

## 3. Full scan

Read budget for this whole section: ~40KB. Never open the same file twice. Don't pad output with `nl` or added line numbers (`rg -n` gives them).

1. Output of `bash <this skill's folder>/scripts/scan.sh .`. If it reports that `rg` is missing, tell the user to install ripgrep and stop; a scan without it finds nothing.
2. One overview doc (`BUSINESS.md`, else `README.md`) via `head -c 12000`.
3. Other docs (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, roadmap/decision docs under `docs/`): never read whole. `rg -n -i` for the chosen modules' "Needed facts" keywords; matching lines only (≤20 per file).
4. Manifests (`package.json`, `pubspec.yaml`, `pyproject.toml`, …): `rg` only for payment/analytics SDKs.
5. Only when a verdict needs it, open ±20 lines around a line scan.sh pointed at.

From this write `facts.md`; if the modules need numbers, add empty "assumption" rows to `assumptions.md`. Never overwrite values the user already wrote there.

## 4. Verdicts

Read the chosen module files and write one row per item under `## Checks`.

```
| Item | Verdict | Evidence | Next action |
| --- | --- | --- | --- |
| <item> | ✅/⚠️/❌/— | <file:line, doc section, or "assumption: …"> | <one line, or —> |
```

- Rows map 1:1 to the module's `## Checks` items. Don't add or drop items (extra findings go in `deep` alternatives).
- ✅ evidence meets the criterion, ⚠️ partial or relies on an assumption, ❌ missing or conflicting, — not applicable (reason in Evidence).
- No unsupported numbers. To use one, cite its `assumptions.md` name and the formula.
- If the fact doesn't exist in the project, write ❌ "not defined"; never invent it.
- No source quotes or long prose. In `deep`, add `**Calculation**` and `**Alternatives**` under the table, ≤10 lines each.

## 5. Save and output

1. In `report.md` replace only the chosen modules' blocks (append if absent); leave everything outside blocks alone. First line of a block: `### <module> (<date>, <quick|deep>)`.
2. In a git repo, write `git rev-parse HEAD` to `state`.
3. Show the user only the per-module tables, topped by one summary line (❌ count, ⚠️ count, the 1–3 most urgent items). The summary is not written to `report.md`. Don't echo cache files.
