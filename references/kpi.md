# kpi — metrics and KPIs

Needed facts: core value, target metrics (docs), analytics SDK and event code locations (scan.sh `metrics`).

## Checks

1. One north-star metric is defined (users receiving the core value, or its frequency) — ❌ revenue or downloads only
2. Activation, retention, conversion and revenue metrics are each defined as formulas (denominator and period included)
3. Each metric has a target and its basis (assumption/benchmark)
4. The data to compute each metric is actually collected — ✅ event/DB column file:line / ❌ no collection code
5. Phase transition criteria (MVP → next phase) are written as metrics
6. Metrics are visible in an admin/dashboard, or at least a query exists
7. No tracking happens without personal-data consent

## deep

- Table: `metric | definition (formula) | target | data source (file:line) | measurable now?`.
- Missing events, one line each with where to add them.
