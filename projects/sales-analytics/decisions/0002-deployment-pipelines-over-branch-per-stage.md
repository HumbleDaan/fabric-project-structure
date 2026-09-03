# 0002 — Deployment pipelines rather than branch per stage

**Status:** Accepted
**Date:** 2026-02-18
**Deciders:** Data Platform team

## Context

Sales Analytics is the first project in this repository, and it is the template everyone else will
copy. Five people work on it: two engineers comfortable with Git, three analysts whose experience of
version control is Power BI Desktop's save dialog.

Both promotion patterns in
[`branching-and-workspaces.md`](../../../.github/standards/branching-and-workspaces.md) are viable.
Choosing wrongly at the start is expensive because everyone copies the first project.

## Options considered

| Option | Pro | Con |
|---|---|---|
| **Deployment pipelines** | Promotion is a button in Fabric; deployment rules handle per-stage connections; nothing new to learn for the analysts | Test and prod content is not version-controlled; rollback means redeploying from dev |
| **Branch per stage** | Every stage in Git; promotion is a reviewed PR; `git revert` is a real rollback | Four workspaces per project; merge conflicts in generated report/model files; requires a parameterisation layer from day one |
| **Hybrid** | — | Two sources of truth arriving in test from two directions. Rejected without much debate. |

## Decision

Use **Fabric deployment pipelines**. Git-connect `contoso-sales-dev` only.

- Repo directory: `projects/sales-analytics/workspaces/ws-sales-analytics-dev/`, connected to `main`.
- Larger changes get a developer workspace via **Branch out to new workspace**, merged back by PR.
- Per-stage differences are handled by deployment rules, not by different content.

## Consequences

**Accepted**
- Test and prod are not in version control. Rollback is "redeploy the previous dev state", and we
  have written down what that means rather than pretending it is `git revert`.
- Drift is possible if someone edits test or prod directly. Mitigated by giving nobody Contributor on
  those workspaces — see [`security-and-access.md`](../../../.github/standards/security-and-access.md).

**Enabled**
- The three analysts can contribute on day one without a Git course.
- No parameterisation layer needed before the first release.

**Revisit when**
- The team is majority code-first (notebooks and TMDL rather than Power BI Desktop), **or**
- We need to prove to audit exactly what was in production on a given date — deployment pipelines
  cannot answer that, and branch-per-stage can, **or**
- We hit a rollback we cannot perform in an acceptable time.

## Related

- [`../../../.github/standards/branching-and-workspaces.md`](../../../.github/standards/branching-and-workspaces.md)
- [`../workspaces/README.md`](../workspaces/README.md)
- [Deployment pipelines](https://learn.microsoft.com/fabric/cicd/deployment-pipelines/intro-to-deployment-pipelines) — Microsoft Learn
