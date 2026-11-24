**English** | [한국어](README.ko.md)

# biz-check

**A business audit for your codebase.** `biz-check` is an agent skill that reviews the business side of a project (logic, MVP scope, unit economics, pricing, personas, competition, risk, KPIs, onboarding) against what the code and docs actually say, and returns a verdict table with `file:line` evidence.

It runs in Claude Code and Codex, and is designed to work in any agent that can read a skill folder.

## Why

- **Evidence over opinion.** Every verdict cites a `file:line`, a doc section, or an explicitly named assumption. Facts that don't exist in the project are reported as "not defined", never invented.
- **No unsupported numbers.** Calculations may only use values from a named assumptions table that you control.
- **Cheap to re-run.** Findings are cached in `.biz/`; later runs look only at what changed since the last synced commit.
- **Small footprint.** One skill description is loaded; only the modules you ask for are read. A full scan is capped at about 40KB of reads and about 5 command calls.
- **Your language.** Skill files are in English; reports are written in the language you choose per project.

## Example output

```
❌ 2 · ⚠️ 3 — most urgent: price computed client-side, no refund rule, no break-even assumption

### logic (2026-11-24, quick)
| Item                              | Verdict | Evidence                    | Next action                         |
| --------------------------------- | ------- | --------------------------- | ----------------------------------- |
| Core loop wired end to end        | ✅      | lib/order/checkout.dart:42  | —                                   |
| Price computed in one place       | ❌      | lib/cart/cart_view.dart:88  | Move total calculation to the server |
| Payment transitions idempotent    | ⚠️      | api/payments/webhook.ts:17  | Handle callback retries             |
```

*(Illustrative. Rows map 1:1 to the checks in each module file.)*

## Requirements

- An agent that supports skills (see [Installation](#installation))
- `bash` and [`ripgrep`](https://github.com/BurntSushi/ripgrep) (`rg`)
- `git` is optional, but required for incremental re-runs

## Installation

### As a Claude Code plugin

```
/plugin install biz-check --marketplace josh3021/biz-check
```

Requires Claude Code 2.1.275 or later. On older versions, run `/plugin marketplace add josh3021/biz-check` and then `/plugin install biz-check@josh3021`. Installed this way, the skill is invoked as `/biz-check:biz-check`.

### As a shared skill folder (Claude Code, Codex, and others)

Clone into the shared skills folder:

```bash
git clone https://github.com/josh3021/biz-check ~/.agents/skills/biz-check
```

Then connect it to your agent:

| Tool | Setup | Status |
| --- | --- | --- |
| Claude Code | `ln -s ~/.agents/skills/biz-check ~/.claude/skills/biz-check` | Verified |
| Codex | None. Reads `~/.agents/skills` directly | Verified |
| Gemini CLI | If not listed automatically: `ln -s ~/.agents/skills/biz-check ~/.gemini/skills/biz-check` | Not verified |
| Other agents | Add the fallback line below to the project's `AGENTS.md` | Not verified |

Fallback for agents without skill support:

```
- For business reviews (MVP, viability, pricing, personas, etc.), read `~/.agents/skills/biz-check/SKILL.md` and follow it exactly.
```

## Usage

Run it from the root of the project you want to audit.

```
/biz-check [module...] [quick|deep] [market] [lang=<code>]
```

Arguments can be given in any order. With no arguments, all modules run in `quick` mode. You can also ask in plain language ("review the pricing strategy of this project") and the agent will pick the skill up.

| Example | What it does |
| --- | --- |
| `/biz-check` | All modules, verdict tables only |
| `/biz-check pricing` | Pricing module only |
| `/biz-check viability pricing deep` | Two modules, with calculations and alternatives |
| `/biz-check competition market` | Looks up competitors and market prices on the web, with URLs |
| `/biz-check lang=ko` | Switches the report language to Korean |

### Modules

| Module | Checks |
| --- | --- |
| `logic` | Core loop and business rules are closed in code |
| `mvp` | Scope is minimal for the core value |
| `viability` | Unit economics, break-even |
| `pricing` | Subscription / one-time / hybrid, price level |
| `persona` | Target users vs. features |
| `competition` | Alternatives, differentiation |
| `risk` | Legal, regulatory, operational, dependency risk |
| `kpi` | Metric definitions and measurability |
| `aha` | Path to first value, drop-off points |

### Options

| Option | Effect |
| --- | --- |
| `quick` (default) | Verdict table only |
| `deep` | Table, plus calculations and 2–3 alternatives |
| `market` | Uses web search (if the agent has it) for competitors and market prices. Without it, nothing is searched and such values are marked as assumptions |
| `lang=<code>` | Report language (`en`, `ko`, `ja`, `zh`, `es`, ...). Saved for the project |

### Verdicts

| Symbol | Meaning |
| --- | --- |
| ✅ | Evidence meets the criterion |
| ⚠️ | Partial, or relies on an assumption |
| ❌ | Missing or conflicting |
| — | Not applicable (the reason is given as evidence) |

## The `.biz/` cache

The first run scans the project and creates a `.biz/` folder in its root. Later runs reuse it.

| File | Content |
| --- | --- |
| `config` | Report language (`lang: <code>`) |
| `facts.md` | Project facts: product, target, revenue model, price list, payment code locations |
| `assumptions.md` | Assumption table: `name \| value \| source` |
| `report.md` | Latest verdicts, one block per module |
| `state` | Commit the facts were last synced to |

- **First run** asks which language to use, then does a full scan.
- **Later runs** check only `git diff` since the commit in `state`. If nothing business-relevant changed, the facts are reused without rereading the project.
- **`assumptions.md` is yours to edit.** Fill in real numbers (CAC, conversion rate, costs) and they will be used in calculations. Values you write are never overwritten.
- Delete `.biz/` to force a fresh full scan.

Whether to commit `.biz/` is up to you: commit it to share findings with your team, or add it to `.gitignore` to keep it local.

## How it works

1. `scripts/scan.sh` prints only the locations of business keywords (pricing, payment, signup, analytics), capped at 200 lines, so the agent never reads the whole repo.
2. The agent reads one overview doc and greps the others, then records what it found in `.biz/facts.md`.
3. For each chosen module, it fills in one row per item in the module's checklist under `references/`.
4. Results are saved to `.biz/report.md` and shown as tables with a one-line summary.

See [DESIGN.md](DESIGN.md) for the design decisions and [SKILL.md](SKILL.md) for the exact instructions the agent follows.

## Project structure

```
biz-check/
├── .claude-plugin/  # Plugin and marketplace manifests
├── SKILL.md         # Instructions the agent follows
├── scripts/
│   └── scan.sh      # Keyword location scanner
├── references/      # One checklist per module
├── DESIGN.md        # Design intent and decisions
└── INSTALL.md       # Per-tool install notes
```

## Limitations

- `biz-check` is a review aid, not legal, financial, or investment advice.
- Verdicts are only as good as the project's code and docs, and the assumptions you provide.
- It is not a financial modeling tool and does no market research unless you pass `market`.

## Contributing

Issues and pull requests are welcome. To add or change a check, edit the matching file in `references/`; each row in a report maps 1:1 to an item under that file's `## Checks`.

## License

[MIT](LICENSE)
