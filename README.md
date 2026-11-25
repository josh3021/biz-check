**English** | [한국어](README.ko.md)

# biz-check

**An AI reads your actual code and planning docs and tells you whether the product makes business sense.**

Ask in everyday words: "Is this price right?", "Is the launch scope too big?", "Will this make money?". You can get the answer at three levels, from a plain explanation that needs no development vocabulary to a deep analysis with calculations and alternatives.

> New here? Ask a developer to do the [installation](#installation) once. After that you only type questions into the chat.

## What it answers

| What you want to know | Check name |
| --- | --- |
| Do the money and order rules work without holes? | `logic` |
| Are we building only what the first launch needs? | `mvp` |
| Can this earn more than it costs? | `viability` |
| Is the way we charge (subscription or one-time), and the price, right? | `pricing` |
| Is it clear who this is for? | `persona` |
| Why would people pick this over the alternatives? | `competition` |
| Could legal or operational trouble stop the business? | `risk` |
| Can we tell from numbers whether it is working? | `kpi` |
| How quickly does a new user feel the value? | `aha` |

You don't need to remember the check names. Ask your question and the matching check runs.

## Three levels of detail

| Level | Who it suits | What you see |
| --- | --- | --- |
| **Easy** (`easy`) | Planners, founders, anyone who doesn't write code | Plain sentences, no tables: what is wrong, what it costs the business, and who should do what |
| **Standard** (`standard`) | Planners and developers reading together | A table per check with the verdict, the evidence (code location) and the next action |
| **Deep** (`deep`) | Before an important decision | The table plus calculations, compared alternatives, a re-check of failed items, and a now / next / later action plan |

The level changes **how results are shown, not what is checked or how strictly.** Even at the easy level the evidence is saved separately, so a developer can verify it later.

### The same problem at each level

**Easy**

```
The overall direction is fine, but two things need fixing before launch.

Do the money and order rules work without holes? — 5 of 7 fine
- ❌ The amount to pay is calculated on the customer's phone. Someone who tampers with the
  app can pay a different amount, which means lost revenue.
  → [Ask the developers] "Please calculate the payment amount on our own systems."
- ⚠️ If the payment confirmation arrives twice, the order can be processed twice. That means
  complaints and refund work.
  → [Ask the developers] "Please make sure the same payment can't be processed twice."

Do first
1. [Ask the developers] Move where the payment amount is calculated
2. [Your decision] Set the refund rules. Nobody has decided this yet
3. [Ask the developers] Prevent duplicate payments

The evidence for each item is saved for developers in .biz/report.md. Ask for "more detail" to see it.
```

**Standard**

```
❌ 1 · ⚠️ 1 — most urgent: price computed client-side, callback retries unhandled

### logic (2026-11-25, standard)
| Item                              | Verdict | Evidence                    | Next action                          |
| --------------------------------- | ------- | --------------------------- | ------------------------------------ |
| Core loop wired end to end        | ✅      | lib/order/checkout.dart:42  | —                                    |
| Price computed in one place       | ❌      | lib/cart/cart_view.dart:88  | Move total calculation to the server |
| Payment transitions idempotent    | ⚠️      | api/payments/webhook.ts:17  | Handle callback retries              |
```

**Deep** adds the following under the standard table.

```
| Loop step | Code location               | What's missing                |
| --------- | --------------------------- | ----------------------------- |
| Payment   | lib/cart/cart_view.dart:88  | Server-side total recalculation |

**Why it matters**
- Price calculation: left as is, a tampered amount gets approved. Turns ✅ once code that
  recomputes the total on the server is found.

**Across modules**
- Conflict: pricing is a monthly subscription, but the cost calculation leaves out retries
  for failed renewals.
- Now: server-side amount → next: duplicate-payment guard → later: annual plan
- Confidence: the break-even verdict rests on the assumed cost of winning a customer. That
  one value changes 3 verdicts.
```

*(Illustrative examples of the format.)*

## How to use it

Open the project you want checked and ask in plain language.

| Say this | And this happens |
| --- | --- |
| "Check whether this product makes business sense" | All checks, at your saved level |
| "Explain **in plain words** whether our pricing is OK" | Pricing only, easy level |
| "Analyse profitability and pricing **in detail**" | Two checks, deep level |
| "Compare us with competitors and look up market prices" | Competition check plus web search |

**The first run asks two things, once:** which language you want, and which level. Your choices are saved with the project and not asked again. Adding "in plain words" or "in detail" to a request changes the level for that one run.

### Reading the results

| Symbol | Meaning |
| --- | --- |
| ✅ | Fine. The evidence was found |
| ⚠️ | Only partly done, or resting on an unverified estimate |
| ❌ | Missing or contradictory. Look here first |
| — | Doesn't apply to this product |

### Can I trust it?

- **Nothing is made up.** Every verdict points at a place in the real code or docs. What the project doesn't contain is reported as "not defined".
- **No unsupported numbers.** Calculations only use values from a table called `.biz/assumptions.md`. The more real figures you fill in there (what it costs to win a customer, the share of visitors who pay, monthly fixed costs), the more accurate the result. Values you write are never overwritten.
- **It is a review aid.** It is not legal, financial, or investment advice.

---

Everything below covers installation and internals, and is written for developers.

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

## Running it as a command

Run it from the root of the project you want to audit.

```
/biz-check [module...] [easy|standard|deep] [market] [lang=<code>]
```

Arguments can be given in any order. With no arguments, all modules run at the saved level.

| Example | What it does |
| --- | --- |
| `/biz-check` | All modules, saved level |
| `/biz-check easy` | All modules in plain sentences. Also saves `easy` as the default level |
| `/biz-check pricing` | Pricing module only |
| `/biz-check viability pricing deep` | Two modules, with calculations, alternatives and an action plan |
| `/biz-check competition market` | Looks up competitors and market prices on the web, with URLs |
| `/biz-check lang=ko` | Switches the report language to Korean |

| Option | Effect |
| --- | --- |
| `easy` | Plain sentences, no tables. No file paths, code names, development terms or abbreviations |
| `standard` | Verdict table per module, with `file:line` evidence. The old name `quick` still works |
| `deep` | Table, plus calculations, alternatives, a re-check of ❌/⚠️ items, cross-module conflicts and an action plan |
| `market` | Uses web search (if the agent has it) for competitors and market prices. Without it, nothing is searched and such values are marked as assumptions |
| `lang=<code>` | Report language (`en`, `ko`, `ja`, `zh`, `es`, ...). Saved for the project |

A level or language passed as an argument is saved to `.biz/config`. A level implied by wording ("in plain words", "in detail") applies to that run only. A project where no level was ever chosen defaults to `standard`.

## The `.biz/` cache

The first run scans the project and creates a `.biz/` folder in its root. Later runs reuse it.

| File | Content |
| --- | --- |
| `config` | Report language and level (`lang: <code>`, `level: <easy\|standard\|deep>`) |
| `facts.md` | Project facts: product, target, revenue model, price list, payment code locations |
| `assumptions.md` | Assumption table: `name \| value \| source` |
| `report.md` | Latest verdict tables, one block per module. The evidence lands here at every level |
| `state` | Commit the facts were last synced to |

- **First run** asks for the language and level, then does a full scan.
- **Later runs** check only `git diff` since the commit in `state`. If nothing business-relevant changed, the facts are reused without rereading the project.
- **Switching level only** (say, easy after standard) re-renders the saved verdicts when nothing changed. `deep` judges again.
- **`assumptions.md` is yours to edit.** Values you write are never overwritten.
- Delete `.biz/` to force a fresh full scan.

Whether to commit `.biz/` is up to you: commit it to share findings with your team, or add it to `.gitignore` to keep it local.

## How it works

1. `scripts/scan.sh` prints only the locations of business keywords (pricing, payment, signup, analytics), capped at 200 lines, so the agent never reads the whole repo.
2. The agent reads one overview doc and greps the others, then records what it found in `.biz/facts.md`.
3. For each chosen module, it judges one row per item in the module's checklist under `references/`. Judging is the same at every level.
4. The verdict tables are saved to `.biz/report.md` and shown at the chosen level.

A full scan is capped at about 40KB of reads and about 5 command calls (`deep` adds 20KB and 2 calls for its re-check). See [DESIGN.md](DESIGN.md) for the design decisions and [SKILL.md](SKILL.md) for the exact instructions the agent follows.

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
