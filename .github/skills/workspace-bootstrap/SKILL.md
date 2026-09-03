---
name: workspace-bootstrap
description: Add a new Fabric workspace to this repository and connect it to Git. Use when the user says "new workspace", "onboard a workspace", "connect a workspace to Git", "add a project", or is setting up a new domain, project or environment in Fabric.
---

# Workspace Bootstrap

Creates the repository side of a new Fabric workspace and walks the user through the Fabric side.
The repo half is automatable; the Fabric half is deliberately not — connecting a workspace to Git is
an action with real consequences and a human should press the button.

## When to use

- A new project needs its first workspace
- An existing project needs another stage (`test`, `prod`) or a developer workspace
- Someone asks where a new workspace folder should go

## When not to use

- Creating Fabric **items** inside an existing workspace — that happens in Fabric, then gets committed
- Deployment / promotion between stages — see [`../../standards/branching-and-workspaces.md`](../../standards/branching-and-workspaces.md)

## Procedure

### 1. Settle the names first

Derive both names from [`../../standards/naming-conventions.md`](../../standards/naming-conventions.md):

| Thing | Pattern | Example |
|---|---|---|
| Fabric workspace | `<org>-<domain>-<stage>` | `contoso-sales-dev` |
| Repo directory | `ws-<workspace-name-without-org>` | `ws-sales-dev` |

Confirm with the user before creating anything. Renaming a Git-connected directory later means
disconnecting and reconnecting the workspace.

### 2. Decide project-level or new project

- Workspace belongs to an existing project → `projects/<project>/workspaces/`
- New business area → copy `projects/_template/` to `projects/<new-project>/` first, and fill in
  `README.md` and `project-context.md`. Do not leave template placeholders behind.

### 3. Create the repo side

```
projects/<project>/workspaces/
├── README.md                    ← add a row to the mapping table
├── <workspace-name>.md          ← workspace notes, OUTSIDE the synced directory
└── ws-<workspace-name>/         ← empty; Fabric fills this
    └── .gitkeep
```

**Workspace documentation goes next to the directory, never inside it.** Everything inside
`ws-*/` is owned by Fabric's sync. Keep it clean so the diff on the first commit is only Fabric items.

Commit and push before touching Fabric — the branch must exist remotely for Fabric to offer it.

### 4. Hand the Fabric side to the user

Give them these steps; do not attempt them yourself:

1. Fabric workspace → **Workspace settings → Git integration**
2. Choose the provider (GitHub or Azure DevOps), then organisation/owner, repository, branch
3. Set **Git folder** to `projects/<project>/workspaces/ws-<workspace-name>`
4. **Connect and sync**
5. Direction on first sync:
   - Workspace already has content → commit **workspace → Git**
   - Directory already has content → update **Git → workspace**

Requirements to flag: the user needs workspace **Admin** and write access to the repo, and the
workspace must sit on a Fabric capacity (F or trial), not a Pro workspace.

### 5. Verify

- [ ] Workspace settings shows the branch and the correct folder
- [ ] The first commit lands **only** inside `ws-<workspace-name>/`
- [ ] Each item folder is named `{DisplayName}.{Type}` and contains a `.platform`
- [ ] `scripts/validate-structure.ps1` passes
- [ ] `projects/<project>/workspaces/README.md` lists the new workspace

## Failure modes

| Symptom | Cause | Fix |
|---|---|---|
| Branch not listed in Fabric | Branch only exists locally | `git push -u origin <branch>` |
| Fabric commits files at repo root | Git folder left blank on connect | Disconnect, reconnect with the folder path set |
| Item folders named as GUIDs | Display name has forbidden characters, a trailing space/dot, or is >256 chars | Rename the item in Fabric, commit again |
| First sync shows conflicts | Both sides had content | Pick a direction deliberately; don't merge generated files by hand |
| Git integration greyed out | Not on Fabric capacity, or tenant setting disabled | Fabric admin: capacity assignment + Git integration tenant setting |

## Related

- [`../../standards/branching-and-workspaces.md`](../../standards/branching-and-workspaces.md) — which branch this workspace should use
- [`../../../docs/02-connect-a-workspace.md`](../../../docs/02-connect-a-workspace.md) — the same walkthrough for humans
- [Get started with Git integration](https://learn.microsoft.com/fabric/cicd/git-integration/git-get-started) — Microsoft Learn
