# Sales Analytics

> **Worked example.** Fictional company (Contoso), realistic shape. Read it to see how the pieces fit,
> then delete this folder and start from [`../_template/`](../_template/README.md).

Order-to-cash reporting for the sales organisation: daily order, invoice and returns data from the
ERP and CRM, landed in a medallion lakehouse and served through a Direct Lake semantic model.

## At a glance

| | |
|---|---|
| **Business owner** | Maria Lindqvist, VP Sales Operations |
| **Technical owner** | Contoso Data Platform team |
| **Domain** | `sales` |
| **Promotion pattern** | Fabric deployment pipelines — see [ADR 0002](decisions/0002-deployment-pipelines-over-branch-per-stage.md) |
| **Status** | Live |

## Workspaces

| Fabric workspace | Stage | Git-connected |
|---|---|---|
| `contoso-sales-dev` | dev | ✅ `projects/sales-analytics/workspaces/ws-sales-analytics-dev/` |
| `contoso-sales-test` | test | ❌ promoted by deployment pipeline |
| `contoso-sales-prod` | prod | ❌ promoted by deployment pipeline |

Details: [`workspaces/README.md`](workspaces/README.md)

## Decisions

| # | Decision | Status |
|---|---|---|
| [0001](decisions/0001-direct-lake-over-import.md) | Direct Lake over Import for the sales semantic model | Accepted |
| [0002](decisions/0002-deployment-pipelines-over-branch-per-stage.md) | Deployment pipelines rather than branch per stage | Accepted |

## Context for agents

[`project-context.md`](project-context.md) — domain language, sources, constraints. Read it first.

## Related

- [`../README.md`](../README.md) — all projects
- [`../../.github/standards/`](../../.github/standards/README.md) — the standards this follows
