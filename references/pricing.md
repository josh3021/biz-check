# pricing — subscription vs one-time

Needed facts: what is sold (app, feature, physical goods, service), current price list/plans, whether cost recurs, usage frequency.
assumptions.md names: `aov`, `cost_per_user_monthly`, `monthly_churn`, `competitor_price`.

If the project has no price or plan information, mark ❌ "not defined" and do not invent prices. Any suggested price is always marked "assumption".

## Model selection signals

| Signal | Leans subscription | Leans one-time |
| --- | --- | --- |
| Cost | Recurs per user every month (servers, APIs, content) | Near zero |
| Value | Keeps being created (accumulated records, updates, consumable refills) | Delivered once (tool, template) |
| Usage | Weekly or more | Occasional |
| Buyer resistance | Needs a low entry price | Strong subscription fatigue |

Hybrid: free + one-time purchases (consumables, physical goods), or one-time + optional subscription (sync, premium).

## Checks

1. The model fits what is sold (≥2 signals above agree) — ❌ opposite signals dominate
2. If subscription: monthly price ≥ `cost_per_user_monthly × 3` — ⚠️ if cost unknown
3. A value metric is defined — the unit the customer pays more for as they get more (seats, usage, managed items, order cadence). Unit price × quantity is not a value metric
4. The free/paid boundary sits after the aha moment — ❌ payment asked before value is seen
5. Position vs competitors/alternatives (cheaper / same / premium) and the reason are stated — ⚠️ assumption without `market`
6. Churn reducers exist (annual plan, bundle, trial) when subscription
7. Prices are set server-side, and app-store in-app purchase rules (digital-goods fees) are accounted for

## deep

- **Calculation**: 2–3 candidates `model | price (assumption) | monthly contribution/user | break-even users`.
- **Alternatives**: one recommendation with the reason, plus one line on how to validate it (price A/B, pre-orders, etc.).
