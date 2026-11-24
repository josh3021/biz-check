# mvp — MVP scope

Needed facts: one-line core value, feature list with status (built/planned), launch gate, roadmap.

## Checks

1. The core value is defined in one sentence — ❌ not in any doc
2. Every built feature can be tied to the core value in one line — ⚠️ n unrelated features (list)
3. Nothing essential to validating the core value is missing — ❌ missing items (list)
4. Out-of-scope features are written down (a "won't build" list)
5. The launch decision is defined by metrics/gates, not a date
6. External dependencies (payments, login, store review) don't block progress — fakes or fallbacks exist
7. A solo/small team can operate it after launch (admin screens, support path) — ⚠️ no ops tooling

## deep

- Table: `feature | link to core value | keep / defer / cut`.
- 1–3 things that can be cut now and the time saved (assumption).
