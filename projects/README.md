# Projects

One folder per project. A project is a business initiative with an owner — not a team, and not a
single workspace.

| Project | What it does | Promotion pattern | Status |
|---|---|---|---|
| [`sales-analytics/`](sales-analytics/README.md) | Worked example: order-to-cash reporting on a medallion lakehouse | Deployment pipelines | Example |
| [`_template/`](_template/README.md) | Copy this to start a new project | — | Template |

## Anatomy of a project

```
projects/<project>/
├── README.md              ← what it is, who owns it, which workspaces it has
├── project-context.md     ← the file agents read before working here
├── decisions/             ← ADRs: why it is built the way it is
└── workspaces/
    ├── README.md          ← workspace ↔ Fabric ↔ branch mapping table
    ├── <workspace>.md     ← notes ABOUT a workspace (outside the synced directory)
    └── ws-<workspace>/    ← ★ Git-connected to a Fabric workspace. Sync one direction at a time.
```

## Why the extra level

Fabric only needs a directory per workspace — a flat `workspaces/` folder at the repo root would
work. The project level exists to hold what Fabric has no concept of:

- **Context that spans stages.** `contoso-sales-dev`, `-test` and `-prod` share one business purpose;
  writing it three times guarantees three versions of it.
- **Decisions that outlive workspaces.** Workspaces get rebuilt, migrated, renamed. The reason you
  chose Direct Lake over Import does not change when they do.
- **Ownership.** A workspace is infrastructure. A project has a business owner and stakeholders.

If you have one project, collapse the level and move on. Retrofitting a grouping level onto forty
flat workspace folders is the expensive direction.

## Adding a project

```powershell
Copy-Item projects/_template projects/<new-project> -Recurse
```

Then fill in `README.md` and `project-context.md` — both are seeded with placeholder markers that
`scripts/validate-structure.ps1` will fail on until you replace them. That is intentional; a template
left half-filled is worse than no template.

Add the project to the table above **in the same commit**.

## Related

- [`../.github/standards/branching-and-workspaces.md`](../.github/standards/branching-and-workspaces.md) — pick a promotion pattern before creating workspaces
- [`../.github/skills/workspace-bootstrap/SKILL.md`](../.github/skills/workspace-bootstrap/SKILL.md) — the agent skill that does this for you
- [`../docs/02-connect-a-workspace.md`](../docs/02-connect-a-workspace.md) — connecting the Fabric side
