# risk — risk and regulation

Needed facts: industry, data handled (personal, health, payment), external dependencies, team size.
Give no legal opinions. Write "needs verification" and where to verify (law name, authority).

## Checks

1. Industry-specific regulation (medical, finance, food, children, etc.) is identified and reflected in UI/copy rules
2. Personal data collected, retention period, and a deletion (account removal) path exist — ❌ no deletion on account removal
3. Payment, refund and withdrawal terms are shown per e-commerce rules (when selling physical goods)
4. App-store policy risks (forced in-app purchase, mandatory account deletion) are handled
5. What happens if a single dependency (one PG, one cloud, one API) fails is written down
6. Single-person dependencies (deploy, support, ops) and their backups are identified
7. If there is user-generated content: report, block and moderation paths exist
8. Cost blow-up risks (accumulating storage, traffic spikes) have caps and alarms

## deep

- Table: `risk | likelihood (H/M/L) | impact (H/M/L) | mitigation | owner`, H/H first.
