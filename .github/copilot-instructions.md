# Copilot Instructions

You are working in a **Microsoft Fabric** repository. Fabric items in this repo are synchronised
with live Fabric workspaces through Git integration. Treat them accordingly.

## How this repository is organised

| Path | What it is | Can you edit it? |
|---|---|---|
| `.github/` | Shared core — standards, skills, agents, prompts. True for every project. | Yes, via PR |
| `projects/<project>/` | Project docs, context, decisions | Yes |
| `projects/<project>/workspaces/<workspace>/` | **Fabric-owned.** Synced with a live workspace. | **No — see below** |
| `docs/` | How to operate this repo | Yes |
| `scripts/` | Validation, bootstrap | Yes |

## The one rule that matters

**Do not hand-edit anything under `projects/*/workspaces/*/`.**

Those directories are the Git side of a Fabric workspace connection. Each item folder carries a
`.platform` file containing a `logicalId` — the identifier that ties the file to the item in the
workspace. Edit it, copy it into a second folder, or reformat it, and the sync breaks in ways that
are painful to unpick.

The safe loop is always: **change it in Fabric → commit from Fabric → review the diff in Git.**

Two narrow exceptions, both requiring review:
- Notebook `.py` content, when the team has agreed to author notebooks in VS Code.
- Deliberately duplicating an item folder as a template — in which case you **must** generate a new
  `logicalId` (a fresh GUID) and a new `displayName`.

Reference: [Git integration source code format](https://learn.microsoft.com/fabric/cicd/git-integration/source-code-format)

## Before you start work

1. Read [`standards/naming-conventions.md`](standards/naming-conventions.md) — every artefact you create needs a compliant name.
2. Read the target project's `project-context.md` — it carries the domain language and constraints.
3. Check [`standards/branching-and-workspaces.md`](standards/branching-and-workspaces.md) — know which workspace maps to which branch before you touch anything.

## Where your knowledge comes from

Fabric platform mechanics — Spark, Warehouse, Direct Lake, Dataflows, Eventhouse, REST APIs, Power BI
modelling — come from the **[Agent Skills for Fabric](https://github.com/microsoft/skills-for-fabric)**
bundle published by Microsoft. Use it. Don't reimplement it here, and don't copy chunks of it into
this repo — it is updated continuously and a copy goes stale fast.

This repository adds only what Microsoft cannot know about us:
- [`standards/`](standards/) — our naming, branching, review and security rules
- [`skills/`](skills/) — our functional skills (domain logic, house patterns)
- [`agents/`](agents/) — the roles we work in
- [`prompts/`](prompts/) — our repeatable workflows
- `projects/*/project-context.md` — per-project business context

If a question is *"how does Fabric do X"* → Fabric skills.
If a question is *"how do **we** do X"* → this repository.

## House rules

- **Never write to a production workspace.** Production changes ship through the release process.
- **No secrets in the repo.** Connection strings, keys, tokens and sensitive workspace IDs belong in
  the pipeline's variable/secret store. See [`standards/security-and-access.md`](standards/security-and-access.md).
- **Small, reviewable commits.** One item or one logical change per commit.
- **Conventional commits:** `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `data:`.
- **State uncertainty.** Fabric ships monthly and preview features change. If you are not sure a
  capability is GA, say so and link the docs rather than asserting.
- **Update the index in the same change.** Every folder has a `README.md`; if you add a file, add its
  row to that README in the same commit.

## Definition of done for a change

- [ ] Names follow the naming convention
- [ ] Nothing under `workspaces/*/` was hand-edited
- [ ] No secrets, no hard-coded workspace/capacity IDs outside the parameter file
- [ ] The relevant `README.md` index was updated
- [ ] A decision that future-you would question is written up in `projects/<project>/decisions/`
- [ ] `scripts/validate-structure.ps1` passes
