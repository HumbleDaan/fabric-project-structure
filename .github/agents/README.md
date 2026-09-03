# Agents

Role definitions. A skill is *know-how*; an agent is *a job*. Each file below describes what a role
is responsible for, which skills it draws on, and — most importantly — what it must not do.

| Agent | Job | Must never |
|---|---|---|
| [`data-engineer.md`](data-engineer.md) | Build and maintain lakehouse/warehouse pipelines and notebooks | Write to production |
| [`report-author.md`](report-author.md) | Build semantic models and reports | Invent a business definition |
| [`release-manager.md`](release-manager.md) | Move validated change between stages | Deploy without a green validation and an approver |

## How to use these

They are plain markdown, which means they work everywhere:

| Host | How |
|---|---|
| Copilot CLI / Claude Code | `Act as the release manager described in .github/agents/release-manager.md` |
| VS Code Copilot Chat | Reference the file, or copy the body into a `.chatmode.md` custom chat mode |
| Any host | Paste it. It's a prompt. |

Deliberately kept as portable markdown rather than a host-specific format — the roles outlive the
tooling, and this repo has to work on GitHub and Azure DevOps, in VS Code and in a terminal.

## Writing one

Four sections, in this order: **Job** (one sentence) · **Operating rules** · **Skills it uses** ·
**Never**. The "Never" section is the reason the file exists — it is the part that stops an
enthusiastic agent doing something irreversible.

## Related

- [`../skills/`](../skills/README.md) — the capabilities agents compose
- [`../prompts/`](../prompts/README.md) — one-shot workflows, not ongoing roles
- [`../copilot-instructions.md`](../copilot-instructions.md) — rules that apply to every role
