# aha — aha moment and onboarding

Needed facts: signup/onboarding flow (scan.sh `auth`), the screen where first value appears, return-visit hooks (notifications, etc.).

## Checks

1. The aha moment is defined as "what the user sees and what they feel"
2. The number of steps from signup to first value is known — ⚠️ more than 5 steps; file:line per step screen
3. Some value is visible before signup (browse, sample), or signup is a single step
4. Onboarding input is used immediately (what the user entered shows up on the next screen) — ❌ collected but unused
5. If first value doesn't arrive on day one (e.g. a repurchase cycle), there are return-visit hooks in between
6. Expected drop-off points (permission prompts, payment, long forms) are marked and skippable
7. An event measures reaching the aha moment (linked to kpi)

## deep

- Flow table: `step | screen (file) | what the user does | drop-off risk | how to reduce it`.
- 1–2 proposals that remove one step before first value.
