# 05 — Agentic Development

Three layers. Set them up in this order — each is useful without the next.

```
  MCP servers      live access      "query this semantic model"        optional
  ─────────────────────────────────────────────────────────────────────────────
  Fabric skills    platform know-how "how does Direct Lake frame?"     Microsoft's
  ─────────────────────────────────────────────────────────────────────────────
  This repository  house rules       "how do WE name things?"          yours
```

## Layer 1 — This repository

Already done, if you cloned it. Agents pick it up automatically:

| File | Read by |
|---|---|
| [`../.github/copilot-instructions.md`](../.github/copilot-instructions.md) | GitHub Copilot in VS Code and CLI |
| [`../AGENTS.md`](../AGENTS.md) | Codex, Jules, OpenCode, Copilot CLI |
| [`../CLAUDE.md`](../CLAUDE.md) | Claude Code |

All three point at the same content. Keep them thin pointers — three files that disagree is worse
than one file nobody reads.

Alongside them: [`skills/`](../.github/skills/README.md) (model-invoked know-how),
[`agents/`](../.github/agents/README.md) (roles),
[`prompts/`](../.github/prompts/README.md) (workflows you invoke by name),
[`standards/`](../.github/standards/README.md) (the rules).

**None of this is GitHub-specific.** It is a folder of markdown. It works identically from an Azure
DevOps working copy.

## Layer 2 — Microsoft's Fabric skills

[`microsoft/skills-for-fabric`](https://github.com/microsoft/skills-for-fabric) — Spark, Warehouse,
Lakehouse, Direct Lake, Eventhouse, Dataflows, REST APIs, Power BI modelling, migration patterns.

### Install

```bash
/plugin marketplace add microsoft/skills-for-fabric
/plugin install fabric-skills@fabric-collection
/plugin install powerbi-authoring@fabric-collection    # semantic models, reports, PBIP
```

Claude Code: `/plugin` → Marketplaces → add `microsoft/skills-for-fabric` → install.

Keep current: `copilot plugin update --all`.

### Without marketplace access

Locked-down network, Azure DevOps-only environment, or a host with no plugin system:

```powershell
./scripts/bootstrap-skills.ps1 -Mode Vendor
```

Clones to `vendor/skills-for-fabric/` (git-ignored) where any agent can read it. For a reviewed,
pinned version instead of latest:

```powershell
./scripts/bootstrap-skills.ps1 -Mode Submodule -Ref v0.3.0
```

### Why installed and not copied

This is the decision people get wrong, so it is worth being blunt about.

Fabric ships new capability every month. A copied skill set is stale in a quarter, and you find out
when an agent confidently recommends something that was deprecated two releases ago. Copying also
puts you on the hook for maintaining a body of platform documentation you did not write.

Install it. Spend your effort on the layer nobody else can write for you — your naming, your
glossary, your project context, your review gates.

**Where the boundary sits**

| Question | Answered by |
|---|---|
| "How do I write an incremental Spark load?" | Fabric skills |
| "Where does an incremental Spark load go in *our* medallion layering?" | This repo |
| "How does Direct Lake fallback work?" | Fabric skills |
| "Why did *we* choose Direct Lake here?" | `projects/*/decisions/` |
| "What does `net_amount_eur` mean?" | `projects/*/project-context.md` |

## Layer 3 — MCP servers (optional)

Skills carry know-how. MCP servers give live access — query a semantic model, run KQL, read
capacity metrics.

```powershell
Copy-Item .vscode/mcp.json.example .vscode/mcp.json
```

Then fill in your endpoints. The real file is git-ignored — it holds environment-specific values.

| Server | Gives you |
|---|---|
| [`fabric-rti-mcp`](https://github.com/microsoft/fabric-rti-mcp) | KQL against Eventhouse / ADX |
| [`powerbi-modeling-mcp`](https://github.com/microsoft/powerbi-modeling-mcp) | Semantic model authoring over XMLA |
| [`fabric-admin-mcp`](https://github.com/microsoft/fabric-admin-mcp) | Capacity and tenant administration |
| Fabric Data Agent | A governed, scoped question-answering endpoint over chosen sources |

Auth is your Azure CLI identity:

```bash
az login
az account get-access-token --resource https://api.fabric.microsoft.com
```

The agent acts as you and cannot reach anything you cannot reach. That is the property that makes
this safe to roll out — don't undermine it by wiring in a shared high-privilege principal because it
was easier.

**Add servers one at a time.** Each one consumes context in every session, and an agent with forty
tools is measurably worse at choosing the right one than an agent with six.

## Writing your own skills

Copy [`_template/SKILL.md`](../.github/skills/_template/SKILL.md). The guidance is in
[`../.github/skills/README.md`](../.github/skills/README.md).

The highest-value functional skills are the ones that encode something a newcomer gets wrong in their
first month: your layering rules, your glossary landmines, the deployment step everyone forgets.

## Related

- [`../.github/skills/README.md`](../.github/skills/README.md)
- [`../.github/agents/README.md`](../.github/agents/README.md)
- [`../.github/prompts/README.md`](../.github/prompts/README.md)
- [09 — Tooling](09-tooling.md) — why the workload "CLIs" are skills, not binaries
