# 03 — Branching and Promotion

The full reasoning lives in
[`../.github/standards/branching-and-workspaces.md`](../.github/standards/branching-and-workspaces.md).
This page is how it feels day to day.

## Choose the pattern first

| | Deployment pipelines | Branch per stage |
|---|---|---|
| Git-connected workspaces | dev only | all stages |
| Promotion | a button in Fabric | a pull request |
| Rollback | redeploy previous dev state | `git revert` |
| Test/prod in version control | no | yes |
| Learning curve | low | real |
| Parameterisation needed | deployment rules | from day one |
| Good for | mixed teams, Power BI-heavy work | engineer-heavy teams, code-heavy content |

**Most teams should start with deployment pipelines** and move later if they need auditable history.
Starting with branch-per-stage and a team that doesn't know Git produces a repo everyone routes
around.

Write the choice into `projects/<project>/decisions/`. Not for ceremony — because in eight months
someone will propose the other one, and the ADR is what stops that being a fresh argument.

## Day to day — deployment pipelines

```
1. Small change?     Work in contoso-sales-dev directly.
   Bigger change?    Branch out to new workspace → contoso-sales-dev-dh / feature/dh-returns

2. Build it in Fabric.

3. Source control panel → review → Commit.
   Read the diff. This is the moment you notice you edited the wrong item.

4. Push, open a PR into main. CI runs validate.

5. Merge → update contoso-sales-dev from Git.

6. Deployment pipeline → dev → test.
   Review changes BEFORE confirming. Always.

7. Run the load in test. Metadata moved; data did not.

8. Test → prod, with approval.

9. Delete the developer workspace and the branch.
```

## Day to day — branch per stage

```
1. Branch out to new workspace from contoso-sales-dev.

2. Build, commit, push.

3. PR into develop → merge → contoso-sales-dev updates from Git.

4. PR develop → release → contoso-sales-test updates.

5. PR release → main, with approval → contoso-sales-prod updates.

6. Each stage's differences come from parameterisation, never from different content per branch.
```

## Merge conflicts in generated files

You will get them: two people touch one report, and the diff is 3,000 lines of JSON.

**Do not hand-merge.** Pick a side, redo the other change in Fabric. It is faster and it does not
produce a file that parses but is subtly wrong.

Prevention beats cure:
- One person per item at a time. Say who is on what.
- Short-lived branches. A week-old branch on a report is already a conflict.
- Sync from the base branch before you start, not after you finish.

## Hotfixes

Same path, faster, no shortcuts around the approval:

```
fix/dh-missing-returns  →  developer workspace  →  PR  →  dev  →  test  →  prod
```

Editing production directly to "just fix it" is invisible to Git, and the next normal deployment
silently overwrites it. That is how the same incident happens twice.

## Related

- [`../.github/standards/branching-and-workspaces.md`](../.github/standards/branching-and-workspaces.md) — the reasoning
- [`../.github/agents/release-manager.md`](../.github/agents/release-manager.md) — the role that runs this
- [04 — CI/CD](04-ci-cd.md) — automating it
