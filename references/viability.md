# viability — business viability

Needed facts: revenue streams, prices / average order value, cost structure, infra and ops cost, acquisition channels.
assumptions.md names: `aov`, `conversion_rate`, `purchase_freq`, `gross_margin`, `payment_fee_rate`, `cac`, `monthly_churn`, `fixed_cost_monthly`, `mau`.

If the project has no price or cost information, mark ❌ "not defined" and do not invent numbers.

## Checks

1. Revenue streams are stated and prioritized
2. Contribution margin per unit (order or subscriber) is positive — `aov×gross_margin − aov×payment_fee_rate − variable cost per unit`
3. LTV/CAC ≥ 3 — `LTV = aov×purchase_freq×gross_margin ÷ monthly_churn`; ⚠️ if `cac` is an assumption
4. CAC payback ≤ 12 months — `cac ÷ monthly contribution per customer`
5. Break-even MAU is computed — `fixed_cost_monthly ÷ monthly contribution per MAU`
6. Costs that scale with users or accumulate (storage, egress, external APIs) are identified — ❌ unbounded accumulation
7. The assumption that moves the result most is flagged (sensitivity)

## deep

- **Calculation**: low/mid/high 3-column table for checks 2, 3 and 5, using only assumptions.md names.
- **Alternatives**: 2–3 levers that raise contribution (AOV↑, variable cost↓, churn↓) and which is cheapest to pull in code.
