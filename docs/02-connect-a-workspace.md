# 02 — Connect a Workspace

Wiring a Fabric workspace to a directory in this repository.

## What you are connecting

```
Fabric workspace  ←──►  one branch  ←──►  one directory
contoso-sales-dev        main             projects/sales-analytics/workspaces/ws-sales-analytics-dev
```

All three are fixed at connect time. Changing any of them means disconnecting and reconnecting, so
settle the names before you click anything —
[`naming-conventions.md`](../.github/standards/naming-conventions.md).

A repository can serve many workspaces. Each needs its own directory.

## Before you start

- [ ] Workspace is on **Fabric capacity** (F SKU or trial). Pro-only workspaces have no Git integration.
- [ ] You are **workspace Admin** *and* have write access to the repo.
- [ ] The branch **exists on the remote**. Fabric lists remote branches, not your local ones.
- [ ] Azure DevOps: the repo is in the **same Entra tenant** as the workspace. Cross-tenant is unsupported.
- [ ] Tenant setting **"Users can synchronize workspace items with their Git repositories"** is on.

## Repo side

Either run the `/new-workspace` prompt, or by hand:

```powershell
$project   = 'sales-analytics'
$workspace = 'ws-sales-analytics-dev'

New-Item -ItemType Directory "projects/$project/workspaces/$workspace" -Force
New-Item -ItemType File      "projects/$project/workspaces/$workspace/.gitkeep"
```

Then:
1. Create `projects/<project>/workspaces/<workspace-name>.md` — the notes file, **outside** the directory.
2. Add a row to `projects/<project>/workspaces/README.md`.
3. Commit and **push**.

> **The notes file goes beside the directory, not inside it.** Fabric *deletes* non-definition files
> left inside an item folder on the next commit. Files at the directory root survive, but keeping
> them out means the sync surface is exactly what Fabric manages — and the diff stays readable.

## Fabric side

1. Open the workspace → **Workspace settings** → **Git integration**
2. Pick the provider: **GitHub** or **Azure DevOps**
3. Sign in / authorise
4. Select organisation (or GitHub owner), repository, and **branch**
5. **Git folder**: paste the directory path — no leading slash

   ```
   projects/sales-analytics/workspaces/ws-sales-analytics-dev
   ```

6. **Connect and sync**

## First sync — pick a direction deliberately

| Situation | Do |
|---|---|
| Workspace has items, directory is empty | Commit **workspace → Git**. Review the diff; this is your baseline. |
| Directory has items, workspace is empty | Update **Git → workspace** |
| Both have content | Stop. Decide which is truth. Do not hand-merge generated files — you will lose. |

After the first commit, look at what landed. Every item folder should be `{DisplayName}.{Type}` with
a `.platform` inside. Folders named as GUIDs mean the display name contains a forbidden character, a
trailing space or dot, or is over 256 characters — rename in Fabric and commit again.

## Verify

```powershell
./scripts/validate-structure.ps1
```

- [ ] Workspace settings shows the branch and the correct folder
- [ ] The commit touched **only** files inside your workspace directory
- [ ] Item folders are readable names, not GUIDs
- [ ] `projects/<project>/workspaces/README.md` lists the workspace
- [ ] Validation passes

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Git integration greyed out | Not on Fabric capacity, or tenant setting off | Assign capacity; ask your Fabric admin about the tenant setting |
| Branch not in the list | Only exists locally | `git push -u origin <branch>` |
| Files committed to repo root | Git folder left blank | Disconnect, reconnect with the folder set |
| Item folders are GUIDs | Illegal display name | Rename in Fabric, commit again |
| "Workspace is already connected" | A previous connection persists | Disconnect in workspace settings first |
| Changes in Fabric not showing in Git | Nobody committed | Git integration does not auto-commit. Source control panel → Commit. |

## Related

- [`../.github/skills/workspace-bootstrap/SKILL.md`](../.github/skills/workspace-bootstrap/SKILL.md) — the agent version of this page
- [03 — Branching and promotion](03-branching-and-promotion.md) — which branch you should have picked
- [Get started with Git integration](https://learn.microsoft.com/fabric/cicd/git-integration/git-get-started) — Microsoft Learn
