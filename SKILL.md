---
name: biz-check
description: Audit the business side of the current project against its code and docs — business logic, MVP scope, viability (unit economics, break-even), pricing (subscription vs one-time, price level), user personas, competitors/alternatives, risk/regulation, metrics/KPIs, aha moment/onboarding. Use this whenever the user asks whether a product makes business sense or will make money, what or how to charge, who it is for, what to cut from an MVP, which metrics to track, or what could kill it — in any language, even if they don't say "business review" or name a module. Reports at three levels — easy (plain words for planners and other non-developers), standard, deep — in the user's chosen language, and caches findings in .biz/ so later runs only re-check what changed.
compatibility: Requires bash and ripgrep (rg). git is optional but needed for incremental re-runs.
---

# biz-check

Run from the project root. Read only this file and the chosen module files; never open other modules.

Batch commands. Every command round-trip resends the whole conversation, so the number of calls is the cost. Aim for 5 or fewer (`deep`: 7):
① read `.biz/config`, the module files, and check the cache (§0, §2) ② all full-scan inputs (§3 steps 1–4, only when needed) ③ code line checks (§3 step 5, at most 2 calls) ④ write `.biz/` and `state`. `deep` adds ⑤ the re-check in §5.

## 0. Language and level

- `.biz/config` holds two lines: `lang: <code>` (e.g. `en`, `ko`, `ja`, `zh`, `es`) and `level: <easy|standard|deep>`.
- No `.biz/config` → ask the user once, in one message, and wait (skip whichever the arguments or the request's wording already settle): which language (offer en / ko / ja / zh / other), and which level, described without jargon — easy: plain words, no development terms; standard: a table with evidence for each check; deep: the table plus calculations, alternatives and an action plan. If the run is non-interactive and cannot ask, use the language of the user's request and `standard`. Write `.biz/config` either way.
- `.biz/config` exists but has no `level` line → `standard`; don't ask.
- `lang=<code>` or a level in the arguments overrides the stored value and rewrites `.biz/config`.
- A level implied by the request's wording applies to this run only and is not stored: "simply / in plain words / for a non-developer / 쉽게 / 간단히" → `easy`; "in detail / thoroughly / precisely / 자세히 / 정밀하게 / 깊게" → `deep`.
- Everything written for the user — chat output, `facts.md`, `assumptions.md`, `report.md` — is in that language. Keep as-is: file paths, `file:line`, code identifiers, module IDs, marker comments, verdict symbols — except in `easy` chat output, which hides the first four (§5).
- After a language change, translate `facts.md` and `assumptions.md` (small, keep values), and rewrite only the `report.md` blocks this run touches; other blocks change on their next run.

## 1. Arguments

`[module...] [easy|standard|deep] [market] [lang=<code>]` — any order. Empty → all modules, stored level. `quick` is the old name of `standard`; accept it.

| Module | File | Checks | Plain question (`easy` heading) |
| --- | --- | --- | --- |
| `logic` | references/logic.md | Core loop and business rules closed in code | Do the money and order rules work without holes? |
| `mvp` | references/mvp.md | Scope minimal for the core value | Are we building only what the first launch needs? |
| `viability` | references/viability.md | Unit economics, break-even | Can this earn more than it costs? |
| `pricing` | references/pricing.md | Subscription / one-time / hybrid, price level | Is the way we charge, and the price, right? |
| `persona` | references/persona.md | Target users vs features | Is it clear who this is for? |
| `competition` | references/competition.md | Alternatives, differentiation | Why would people pick this over the alternatives? |
| `risk` | references/risk.md | Legal, regulatory, operational, dependency risk | What could get us into trouble or stop the business? |
| `kpi` | references/kpi.md | Metric definitions and measurability | Can we tell from numbers whether it is working? |
| `aha` | references/aha.md | Path to first value, drop-off points | How quickly does a new user feel the value? |

- `easy` / `standard` / `deep`: how results are shown (§5).
- `market`: if a web search tool exists, look up competitors and market prices and cite URLs. Without it (or without the argument), do not search; mark as "assumption".

## 2. Cache (`.biz/`)

| File | Content |
| --- | --- |
| `config` | `lang: <code>`, `level: <easy\|standard\|deep>` |
| `facts.md` | Project facts, ≤60 lines: one-line product, target, revenue model, price list, payment/subscription code locations, phase plan |
| `assumptions.md` | Assumption table `name \| value \| source (assumption/citation)`. Calculations use only these names |
| `report.md` | Verdict table per module (the evidence, at every level), each in a `<!-- biz:<module> -->` … `<!-- /biz:<module> -->` block |
| `state` | One line: commit hash facts were last synced to |

Decide at start:

1. No `.biz/facts.md` → **full scan** (§3).
2. Exists, git repo, and `git cat-file -e <state hash>` succeeds → look only at `git diff --stat <hash>..HEAD -- . ':!.biz'` and `git status --short -- . ':!.biz'`.
   - Nothing changed → reuse facts as-is; do not reread.
   - Otherwise open only business-relevant changed files (pricing, payment, orders, subscription, signup, onboarding, README, planning docs) and fix the matching fact lines.
3. Not git, or hash missing → full scan.

Level switch only: if nothing changed, `market` is not passed, `assumptions.md` is not newer than `report.md`, and every chosen module already has a block in `report.md`, render `easy` or `standard` from those blocks without re-judging, and write nothing. `deep` on a block not saved as `deep` re-judges.

## 3. Full scan

Read budget for this whole section: ~40KB. Never open the same file twice. Don't pad output with `nl` or added line numbers (`rg -n` gives them).

1. Output of `bash <this skill's folder>/scripts/scan.sh .`. If it reports that `rg` is missing, tell the user to install ripgrep and stop; a scan without it finds nothing.
2. One overview doc (`BUSINESS.md`, else `README.md`) via `head -c 12000`.
3. Other docs (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, roadmap/decision docs under `docs/`): never read whole. `rg -n -i` for the chosen modules' "Needed facts" keywords; matching lines only (≤20 per file).
4. Manifests (`package.json`, `pubspec.yaml`, `pyproject.toml`, …): `rg` only for payment/analytics SDKs.
5. Only when a verdict needs it, open ±20 lines around a line scan.sh pointed at.

From this write `facts.md`; if the modules need numbers, add empty "assumption" rows to `assumptions.md`. Never overwrite values the user already wrote there.

## 4. Verdicts

Judging is the same at every level. Read the chosen module files and write one row per item under `## Checks`.

```
| Item | Verdict | Evidence | Next action |
| --- | --- | --- | --- |
| <item> | ✅/⚠️/❌/— | <file:line, doc section, or "assumption: …"> | <one line, or —> |
```

- Rows map 1:1 to the module's `## Checks` items. Don't add or drop items (extra findings go in `deep` alternatives).
- ✅ evidence meets the criterion, ⚠️ partial or relies on an assumption, ❌ missing or conflicting, — not applicable (reason in Evidence).
- No unsupported numbers. To use one, cite its `assumptions.md` name and the formula.
- If the fact doesn't exist in the project, write ❌ "not defined"; never invent it.
- No source quotes or long prose in the table.

## 5. Levels

The level changes how results are shown, never how they are judged or what counts as evidence.

### easy — for readers with no development background

No tables. Per module:

- Heading: the module's plain question from §1, not its ID, followed by "n of m fine".
- One bullet per ❌/⚠️ item, most serious first, at most 5 (then "+n more"): `<symbol> what is wrong, in one everyday sentence — what it costs the business if left (money, customers, legal trouble) → what to do`. Leave out ✅ and — items.
- Each action starts with who acts: a decision the reader can make themselves, or a request to pass to the developers, worded so it can be forwarded as is.

Keep it light: with 3 or more modules, at most 2 bullets per module and about 40 lines for the whole run; a module with nothing wrong gets its heading line only.

Then "Do first": the 3 most urgent actions across all modules. Last line: the evidence behind every item is saved in `.biz/report.md` for developers, and asking for more detail shows it.

Wording:

- No file paths, `file:line`, code identifiers, module IDs, formulas or `assumptions.md` names. The closing pointer to `.biz/report.md` is the only path allowed.
- No development terms (server, client, API, webhook, idempotent, SDK, …). Say what happens instead: "the price is calculated on the customer's phone, where it can be tampered with".
- Replace business abbreviations (MVP, KPI, CAC, LTV, churn, AOV, …) with everyday words: "what it costs to win one customer".
- "not defined" becomes "nobody has decided this yet".
- Numbers: results only, inside a sentence, and say "estimate" when one rests on an assumption.
- When a verdict is blocked by a missing number, ask for it in everyday words ("roughly how much do you spend to win one customer?"). When the user answers in chat, record it in `assumptions.md` with source "user" and re-judge that module.

### standard

The per-module tables from §4, nothing more.

### deep

Before writing, re-check every ❌/⚠️ against the code or doc it cites and correct the verdict if the evidence says otherwise (extra reads ≤20KB, ≤2 calls). Then, under each module's table:

- What the module's `## deep` section asks for (`**Calculation**`, `**Alternatives**`, tables), ≤15 lines each.
- `**Why it matters**`: one line per ❌ — what happens if it stays, and what evidence would flip the verdict.

When 2 or more modules ran, close with `**Across modules**`, ≤25 lines:

- Conflicts between modules (price vs cost, target user vs onboarding, …).
- Action plan as `now / next / later`, with what depends on what.
- Confidence: which verdicts rest on assumptions, and the one input that would change the most verdicts.

## 6. Save and output

1. In `report.md` replace only the chosen modules' blocks (append if absent); leave everything outside blocks alone. First line of a block: `### <module> (<date>, <level>)`. A block always holds the §4 table; at `deep`, also what was written under it. `easy` text is never saved. `**Across modules**` goes in a `<!-- biz:overview -->` block.
2. In a git repo, write `git rev-parse HEAD` to `state`.
3. Show the user one summary line (❌ count, ⚠️ count, the 1–3 most urgent items; at `easy`, one plain sentence on the overall state instead), then the output for the level (§5). The summary is not written to `report.md`. Don't echo cache files.
