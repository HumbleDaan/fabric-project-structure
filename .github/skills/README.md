# Skills

Agent skills are markdown files that teach an AI assistant a repeatable piece of know-how. The host
loads them when the task matches the skill's description.

## The split that matters

|  | Technical basics | Functional guidance |
|---|---|---|
| **Question it answers** | "How does Fabric do X?" | "How do *we* do X?" |
| **Examples** | Spark tuning, Warehouse T-SQL dialect, Direct Lake framing, REST APIs, TMDL authoring, Dataflows Gen2 | Our medallion layering rules, our glossary, our naming, our review gates, our domain models |
| **Who writes it** | Microsoft | You |
| **Lives** | [`microsoft/skills-for-fabric`](https://github.com/microsoft/skills-for-fabric) | This folder |
| **Update model** | Installed and updated as a package | Version-controlled with your project |

**Do not fork the technical layer into this repo.** Fabric ships every month; a copied skill set is
stale within a quarter and you will not notice until an agent gives outdated advice with confidence.
Install it, pin it if you must, and spend your effort on the column nobody else can write.

## Install the technical basics

**GitHub Copilot CLI**

```bash
/plugin marketplace add microsoft/skills-for-fabric
/plugin install fabric-skills@fabric-collection
# Power BI semantic model / report authoring ships separately:
/plugin install powerbi-authoring@fabric-collection
```

**Everything else** — Claude Code, Cursor, Windsurf, or an air-gapped/Azure DevOps-only environment
where you cannot reach a GitHub marketplace:

```powershell
./scripts/bootstrap-skills.ps1 -Mode Vendor
```

That clones the skills to `vendor/skills-for-fabric/` (git-ignored) so agents can read them locally.
See [`../../docs/05-agentic-development.md`](../../docs/05-agentic-development.md) for the full setup,
including the pinned-submodule option for environments with no outbound GitHub access at all.

## Our skills

| Skill | Use it when |
|---|---|
| [`workspace-bootstrap/`](workspace-bootstrap/SKILL.md) | Adding a new Fabric workspace to this repo and connecting it to Git |
| [`naming-check/`](naming-check/SKILL.md) | Checking or fixing names against our conventions |
| [`business-glossary/`](business-glossary/SKILL.md) | A business term is ambiguous, or a new term needs defining |
| [`_template/`](_template/SKILL.md) | Writing a new skill |

## Writing a good one

1. **One job.** If the description needs "and", it's two skills.
2. **Trigger conditions in the description.** The host matches on it. "Use when the user asks about
   X, mentions Y, or is doing Z" beats a noun phrase.
3. **Procedure, not prose.** Numbered steps an agent can follow and you can audit.
4. **Say what not to do.** Failure modes are the highest-value content in a skill.
5. **Under 150 lines.** Push detail into linked reference files that the agent loads on demand.
6. **Never duplicate a Fabric platform fact.** Link the Microsoft skill or the Learn page instead.

Copy [`_template/SKILL.md`](_template/SKILL.md) to start.

## Related

- [`../copilot-instructions.md`](../copilot-instructions.md) — the always-on instructions
- [`../agents/`](../agents/README.md) — roles, which compose these skills
- [`../prompts/`](../prompts/README.md) — user-invoked workflows
