# Install

Source: `~/.agents/skills/biz-check/`

| Tool | How | Verified |
| --- | --- | --- |
| Claude Code | `ln -s ~/.agents/skills/biz-check ~/.claude/skills/biz-check` | 2026-11-24 (listed in skills) |
| Codex | Nothing to do; reads `~/.agents/skills` directly | 2026-11-24 (appears in `codex debug prompt-input`) |
| Gemini CLI | Reportedly reads `~/.agents/skills`. If not listed: `ln -s ~/.agents/skills/biz-check ~/.gemini/skills/biz-check` | Not verified — check that tool's docs |
| Grok CLI | Skill support unknown. If unsupported, add the line below to the project's `AGENTS.md` | Not verified |

AGENTS.md fallback line:

```
- For business reviews (MVP, viability, pricing, personas, etc.), read `~/.agents/skills/biz-check/SKILL.md` and follow it exactly.
```

Other machines: copy this folder (or clone it as a git repo) and recreate the links above.

Language: the first run in each project asks which language to use and stores it in `.biz/config` (`lang: <code>`). Change it with the `lang=<code>` argument.
