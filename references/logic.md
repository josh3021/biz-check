# logic — business logic

Needed facts: core value loop, where money moves in code (facts.md), state transitions (orders, subscriptions, payments).

## Checks

1. The core loop (value → action → revenue → return visit) is wired end to end in code — ✅ file:line for every step / ❌ a step is missing
2. Price, discount, tax and shipping are computed in one place on the server (inside the trust boundary) — ❌ client-side or duplicated calculation
3. Payment state transitions (pending → approved → canceled/refunded) are explicit and idempotent — ❌ no handling of double approval or callback retries
4. Rules exist for carts/orders when stock, availability or price changes
5. If subscriptions exist: renewal, failed-payment retry, cancellation and refund rules exist — no subscriptions → —
6. Business rules (limits, rewards, coupon conditions) live in one constants/config place — ⚠️ magic numbers scattered
7. Each rule has a test, especially money — ✅ money test file:line

## deep

- Table per loop step: `step | code location | what's missing`.
- Pick the riskiest rule and write one failure scenario (input → wrong result).
