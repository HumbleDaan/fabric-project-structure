# Naming Conventions

> **This is a starting point, not gospel.** Every rule below has its reasoning attached so you can
> tell which parts to keep and which to change. Change it once, here, and let everything else follow.

## Why bother

Three reasons, in order of how much they actually cost you:

1. **Git directories are derived from display names.** Fabric names each item folder
   `{display name}.{type}`. Rename an item in the workspace and the folder moves in Git. Sloppy or
   duplicated display names produce a Git tree nobody can read.
2. **Some characters are illegal.** Names with `" / : < > \ * ? |`, or more than 256 characters, or
   a trailing space or dot, cause Fabric to fall back to the item's GUID as the folder name. You lose
   readability permanently. ([Reference](https://learn.microsoft.com/fabric/cicd/git-integration/git-integration-process))
3. **Agents pattern-match on names.** A consistent prefix is the cheapest possible way to tell an
   agent what kind of thing it is looking at.

## Workspaces

```
<org>-<domain>-<stage>
```

| Part | Values | Example |
|---|---|---|
| `org` | short company/tenant tag, lowercase | `contoso` |
| `domain` | business domain, not team name | `sales`, `finance`, `supply-chain` |
| `stage` | `dev` \| `test` \| `prod` \| `sbx` | `dev` |

`contoso-sales-dev` · `contoso-sales-prod` · `contoso-supply-chain-test`

**Use the domain, not the team.** Teams reorganise every eighteen months; domains don't. A workspace
called `bi-team-2` outlives the BI team and tells no one anything.

Personal/feature workspaces get a suffix so they're obviously disposable:
`contoso-sales-dev-dhumble` · `contoso-sales-dev-feat-returns`

## Fabric items

```
<PREFIX>_<Subject>[_<Qualifier>]
```

| Item type | Prefix | Example |
|---|---|---|
| Lakehouse | `LH_` | `LH_Sales` |
| Warehouse | `WH_` | `WH_Sales` |
| Notebook | `NB_` | `NB_Sales_Bronze_Ingest` |
| Data pipeline | `PL_` | `PL_Sales_Daily_Load` |
| Dataflow Gen2 | `DF_` | `DF_Sales_Crm_Contacts` |
| Semantic model | `SM_` | `SM_Sales` |
| Report | `RPT_` | `RPT_Sales_Overview` |
| Eventhouse / KQL DB | `EH_` / `KQL_` | `EH_Telemetry` |
| Eventstream | `ES_` | `ES_Orders_Stream` |
| Environment | `ENV_` | `ENV_Sales_Spark` |
| Data agent | `DA_` | `DA_Sales_Assistant` |
| Variable library | `VL_` | `VL_Sales` |

Rules:
- `PascalCase` after the prefix, `_` between concepts. No spaces — spaces survive in Fabric but make
  every shell command, path and URL more annoying than it needs to be.
- **No stage suffix on items.** The workspace already carries the stage. `LH_Sales_Dev` inside
  `contoso-sales-dev` is redundant, and it breaks deployment pipelines, which match items across
  stages by name.
- Notebooks read left to right as `subject → layer → action`: `NB_Sales_Silver_Conform`.

## Delta tables and columns

`snake_case`, singular-noun table names, no prefixes: `sales_order`, `sales_order_line`, `dim_customer`.

Columns must avoid ` `, tab, CR, LF and `` [ ] , ; { } ( ) = `` — these are illegal in Delta/Parquet
and fail late, at write time or when a Direct Lake model frames.
([Reference](https://learn.microsoft.com/fabric/data-engineering/lakehouse-table-format))

## Branches

| Pattern | For | Merges into |
|---|---|---|
| `main` | The state of production | — |
| `feature/<initials>-<short-description>` | One change | `main` |
| `fix/<initials>-<short-description>` | A production defect | `main` |
| `ws/<workspace-name>` | A long-lived workspace-bound branch, if you use branch-per-stage | see below |

Lowercase, hyphens, no spaces. Keep it under ~50 characters — Fabric shows the branch name in the
workspace header and it truncates.

## Repository folders

| Level | Pattern | Example |
|---|---|---|
| Project | `kebab-case` business name | `projects/sales-analytics/` |
| Workspace directory | `ws-<workspace-name-without-org>` | `workspaces/ws-sales-analytics-dev/` |

The `ws-` prefix exists purely so a human scanning the tree can tell instantly which folders are
synced with a live Fabric workspace — and therefore where the identity-layer and one-direction-at-a-time
rules apply.

## When you break the convention

Sometimes you must — an item you inherited, a vendor-generated name, a Power BI report that is
already linked from a hundred places. That's fine. Write it down in the project's
`decisions/` folder with one line of reasoning, so the next person doesn't "fix" it.

## Related

- [`branching-and-workspaces.md`](branching-and-workspaces.md) — how branch names map to workspaces
- [`review-checklist.md`](review-checklist.md) — naming is the first thing a reviewer checks
- [`../skills/naming-check/SKILL.md`](../skills/naming-check/SKILL.md) — the agent skill that enforces this
