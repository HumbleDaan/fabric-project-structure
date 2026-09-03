# Branching and Workspaces

The single most consequential decision in this repo. Get it wrong and every deployment is a
negotiation; get it right and promotion is a merge.

## The constraint everything follows from

> A Fabric workspace is a **shared runtime environment**. Each workspace can be connected to a
> **single branch** and a **single directory** in that repository.
> — [Development process in Microsoft Fabric](https://learn.microsoft.com/fabric/cicd/git-integration/manage-branches)

Three consequences:

1. **One repo can serve many workspaces** — each needs its own directory. That is exactly what
   `projects/*/workspaces/*/` gives you.
2. **Two people editing the same workspace overwrite each other.** Isolation comes from having a
   different *workspace*, not a different branch.
3. **A branch can be synced to more than one workspace.** Same directory, same branch, two
   workspaces is legal — and is how branch-per-stage works.

## Pick one of two patterns

### Pattern A — Deployment pipelines (default in this repo)

Git is your source of truth for **dev only**. Promotion to test and prod is done by a
[Fabric deployment pipeline](https://learn.microsoft.com/fabric/cicd/deployment-pipelines/intro-to-deployment-pipelines).

```
                       ┌──────────────────────────────┐
  feature/dh-returns ─▶│  contoso-sales-dev-dhumble   │  (developer workspace, optional)
                       └──────────────────────────────┘
                                    │ PR
                                    ▼
  main ────────────────▶ contoso-sales-dev ──▶ contoso-sales-test ──▶ contoso-sales-prod
   (git-connected)         Git-connected        deployment pipeline    deployment pipeline
                                                                         + approval gate
```

- Repo directory: `projects/sales-analytics/workspaces/ws-sales-analytics-dev/`
- Only **one** workspace per project is Git-connected.
- Test and prod are never touched by Git; deployment rules handle rebinding connections per stage.

**Choose this when** the team is new to Git, or when most changes are Power BI / low-code and the
value of a reviewable diff is lower than the cost of teaching everyone Git branching. This is where
most teams should start.

**Cost:** test and prod content is not in version control. Your rollback story is "redeploy from
dev", not "revert a commit".

### Pattern B — Branch per stage

Every stage workspace is Git-connected, to its own branch, using the **same directory path**.

```
  feature/dh-returns ──▶ contoso-sales-dev-dhumble
          │ PR
          ▼
  develop ──────────────▶ contoso-sales-dev
          │ PR
          ▼
  release ──────────────▶ contoso-sales-test
          │ PR + approval
          ▼
  main ─────────────────▶ contoso-sales-prod
```

- Repo directory: the *same* `.../workspaces/ws-sales-analytics/` on all four branches.
- Promotion is a pull request. Rollback is `git revert`.
- Environment differences (connection strings, capacity, workspace IDs) are handled by
  [`fabric-cicd`](https://microsoft.github.io/fabric-cicd/) parameterisation or a Variable Library,
  **not** by different content per branch.

**Choose this when** you have engineers comfortable with Git, code-heavy content (notebooks, SQL,
TMDL), and you want every production change to be a reviewed diff.

**Cost:** four workspaces per project, real merge conflicts in generated files, and a parameterisation
layer you must maintain.

### Don't mix them per project

Both patterns are fine. A project that uses both is not — you get changes arriving in test from two
directions with no single source of truth. Record the choice in the project's
`decisions/` folder.

## Developer workspaces

In both patterns, work that is more than a small edit belongs in its own workspace:

```
contoso-sales-dev-<initials>   ↔   feature/<initials>-<description>
```

Fabric can create these for you — **Branch out to new workspace** provisions the workspace, creates
the branch, and connects them in one action.
([Reference](https://learn.microsoft.com/fabric/cicd/git-integration/manage-branches))

Delete the workspace when the branch merges. They are cheap; stale ones are not — they hold capacity
and confuse everyone about which one is real.

## What crosses stages, and what doesn't

This catches people out on their first promotion, in both patterns.

| Moves automatically | Does **not** move |
|---|---|
| Item definitions and metadata | Table / file / folder **data** |
| Notebook code, SQL, TMDL | Spark views |
| Internal OneLake shortcut pointers (auto-remapped) | External shortcut targets, unless parameterised |
| Report and semantic model structure | OneLake data access role *assignments* |
| Pipeline definitions | Connection bindings, unless a deployment rule sets them |

**Metadata moves; data does not.** A freshly promoted lakehouse is empty until the load runs there.
Plan the first run of the target stage as part of the release, not as an afterthought.

## Related

- [`naming-conventions.md`](naming-conventions.md) — branch and workspace naming
- [`../../docs/02-connect-a-workspace.md`](../../docs/02-connect-a-workspace.md) — the click-path
- [`../../docs/03-branching-and-promotion.md`](../../docs/03-branching-and-promotion.md) — day-to-day flow
- [`../../docs/04-ci-cd.md`](../../docs/04-ci-cd.md) — automating either pattern
