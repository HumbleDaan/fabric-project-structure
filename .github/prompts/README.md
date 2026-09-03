# Prompts

Reusable workflows. A skill fires when the agent decides it's relevant; a prompt fires when *you*
ask for it by name.

| Prompt | Run it when |
|---|---|
| [`new-workspace.prompt.md`](new-workspace.prompt.md) | Adding a Fabric workspace to this repo |
| [`review-fabric-pr.prompt.md`](review-fabric-pr.prompt.md) | Reviewing a PR that touches Fabric items |
| [`document-workspace.prompt.md`](document-workspace.prompt.md) | A workspace's docs have drifted from what's in it |
| [`release-readiness.prompt.md`](release-readiness.prompt.md) | Before promoting to test or production |

## How to run them

| Host | How |
|---|---|
| VS Code Copilot Chat | `/new-workspace` — files in `.github/prompts/` are picked up automatically |
| Copilot CLI / Claude Code / any host | Point at the file: *"Follow `.github/prompts/new-workspace.prompt.md`"* |

Both work on GitHub and Azure DevOps repositories — these are plain files, not a platform feature.

## Writing one

- Frontmatter: `mode` and a `description` that says when to run it.
- Body: numbered steps, and an explicit statement of what the output should look like.
- Put the reasoning in a skill or a standard and **link** to it. A prompt that restates the rules
  becomes a second, competing source of truth the first time someone edits only one of them.

## Related

- [`../skills/`](../skills/README.md) — model-invoked know-how
- [`../agents/`](../agents/README.md) — ongoing roles
