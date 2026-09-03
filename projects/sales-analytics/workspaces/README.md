# Workspaces — Sales Analytics

| Repo directory | Fabric workspace | Stage | Branch | Git-connected | Notes |
|---|---|---|---|---|---|
| [`ws-sales-analytics-dev/`](ws-sales-analytics-dev/) | `contoso-sales-dev` | dev | `main` | ✅ | [`ws-sales-analytics-dev.md`](ws-sales-analytics-dev.md) |
| — | `contoso-sales-test` | test | — | ❌ deployment pipeline | Stage 2 of `Sales Analytics` pipeline |
| — | `contoso-sales-prod` | prod | — | ❌ deployment pipeline | Stage 3, approval required |

Only dev is Git-connected — see [ADR 0002](../decisions/0002-deployment-pipelines-over-branch-per-stage.md).

## Note on the example content

`ws-sales-analytics-dev/` contains **hand-written illustrative item folders** so you can see the shape
of a Git-connected workspace without having to connect one first.

In a real repository you never author these. You create items in Fabric and commit from Fabric, and
Fabric generates the `.platform` files — including the `logicalId`, which is the identifier tying each
folder to the item in the workspace.

**Before connecting a real workspace to this directory, empty it.** Syncing Git → workspace would
otherwise create these example items in your Fabric workspace.

## Rules for this folder

1. **`ws-*/` is owned by Fabric.** Nothing in it is hand-edited. Change items in Fabric, commit from
   Fabric, review the diff here.
2. **Documentation lives beside the directory, not inside it.** `ws-sales-analytics-dev.md` sits next
   to `ws-sales-analytics-dev/` for exactly this reason — a stray `README.md` inside the synced
   directory shows up as an unexpected change on every sync.
3. **One directory per Git-connected workspace.**

## Related

- [`../README.md`](../README.md) — project overview
- [`../../../.github/standards/branching-and-workspaces.md`](../../../.github/standards/branching-and-workspaces.md)
- [`../../../docs/02-connect-a-workspace.md`](../../../docs/02-connect-a-workspace.md)
