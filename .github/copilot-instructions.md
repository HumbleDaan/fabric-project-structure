# Copilot Instructions

You are working in a **Microsoft Fabric** repository. Fabric items in this repo are synchronised
with live Fabric workspaces through Git integration. Treat them accordingly.

## How this repository is organised

| Path | What it is | Can you edit it? |
|---|---|---|
| `.github/` | Shared core — standards, skills, agents, prompts. True for every project. | Yes, via PR |
| `projects/<project>/` | Project docs, context, decisions | Yes |
| `projects/<project>/workspaces/<workspace>/` | **Synced with a live Fabric workspace.** | Yes — under the rules below |
| `docs/` | How to operate this repo | Yes |
| `scripts/` | Validation, bootstrap | Yes |

## The rules that matter

Git integration is **bidirectional**, and authoring in Git is much of the point. You can change an
item in Fabric and commit it, or change the definition in Git and sync it into the workspace.
Microsoft supports both — and for Warehouse [actively recommends the Git-first
path](https://learn.microsoft.com/fabric/data-warehouse/how-to-git-integration#develop-locally-by-using-a-database-project)
over incremental live edits.

So the rule is not *don't edit*. It is **don't edit the identity layer, and don't author in both
directions at once.**

### 1. Never touch the identity layer

Three things in an item folder are the plumbing that links the file to the item. Changing them is
what actually breaks a sync:

- **`logicalId`** in `.platform` — the link itself. Docs are unambiguous: *"it's essential not to
  change it in any way."*
- **`type`** in `.platform` — case-sensitive; changing how it's generated can fail the sync.
- **The item directory name** — renaming it in Git stops the name syncing, and silently breaks
  dependency paths in *other* items (a report's `definition.pbir` refers to its semantic model by
  path). Rename in the workspace instead, or update every dependent reference by hand.

Copying an item folder to seed a new item is fine, but you **must** give the copy a fresh
`logicalId` GUID *and* a unique `displayName` — duplicate names fail the update outright.

### 2. Sync one direction at a time

> "You can only sync in one direction at a time. You can't commit and update at the same time."

Decide who authors a given change *before* starting, then finish the round trip:

- **Git-first** — edit the definition → PR → **Update from Git** into the workspace.
- **Fabric-first** — change it in the portal → **Commit to Git** → review the diff.

Half-finished changes sitting on both sides at once is what produces conflicts. That is the real
hazard here, and it is operational, not corruption.

### 3. Know which files are meant to be hand-written

| File | Author it by hand? |
|---|---|
| `definition/*.tmdl` — semantic model | **Yes** — TMDL exists for exactly this |
| `notebook-content.py` | **Yes** |
| Warehouse database project (`.sqlproj` + SQL) | **Yes** — MS recommends it over live edits |
| `function-app.py` — user data functions | **Yes** — docs call it "the main file you edit" |
| `*.rdl` — paginated report | Carefully; it's XML with a schema |
| `report.json`, `definition.pbir` | Only with the schema open — don't improvise it |
| `resources/functions.json` | **No** — docs: "Don't edit this file manually" |
| `.platform` | **No**, other than `description` |

Expect **cosmetic diff noise** after a Git-authored change. The engine that regenerates a definition
may reorder things — rename a semantic model column in Git and it gets pushed to the end of the
`columns` array on the next commit. Docs call this semantically insignificant. Don't chase it. (The
same applies to line endings: Fabric writes LF, which is why `.gitattributes` pins `eol=lf`.)

### 4. Nothing extra inside an *item* folder

> "During the *Commit to Git* process, the Fabric service deletes files inside the item folder that
> aren't part of the item definition."

A note left inside `LH_Sales.Lakehouse/` is **deleted** on the next commit. Files outside an item
folder survive — but we still keep workspace documentation *beside* the synced directory
(`ws-sales-dev.md` next to `ws-sales-dev/`) so the sync surface is exactly what Fabric manages.
That second part is a house rule, not a platform constraint.

References:
[source code format](https://learn.microsoft.com/fabric/cicd/git-integration/source-code-format) ·
[basic concepts](https://learn.microsoft.com/fabric/cicd/git-integration/git-integration-process#considerations-and-limitations) ·
[warehouse Git integration](https://learn.microsoft.com/fabric/data-warehouse/how-to-git-integration)

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
- [ ] No `logicalId`, `type`, or item folder name was changed
- [ ] Changes to a workspace directory went one direction, and the round trip is finished
- [ ] No secrets, no hard-coded workspace/capacity IDs outside the parameter file
- [ ] The relevant `README.md` index was updated
- [ ] A decision that future-you would question is written up in `projects/<project>/decisions/`
- [ ] `scripts/validate-structure.ps1` passes
