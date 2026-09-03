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

In a real repository you don't author the `.platform` files — Fabric generates them, including the
`logicalId` that ties each folder to the item in the workspace. The item *definitions* beside them
(TMDL, notebook `.py`, warehouse SQL) you may well author in Git; that's a supported direction.

**Before connecting a real workspace to this directory, empty it.** Syncing Git → workspace would
otherwise create these example items in your Fabric workspace.

## Rules for this folder

1. **`ws-*/` is synced with a live workspace.** Editing item definitions here is allowed — that's
   half the point of Git integration — but sync **one direction at a time** and never change a
   `logicalId`, `type`, or item folder name. See [`.github/copilot-instructions.md`](../../../.github/copilot-instructions.md).
2. **Documentation lives beside the directory, not inside it.** `ws-sales-analytics-dev.md` sits next
   to `ws-sales-analytics-dev/` for exactly this reason. Fabric *deletes* non-definition files left
   inside an item folder on the next commit; files at the directory root survive, but keeping them
   out means the sync surface is exactly what Fabric manages.
3. **One directory per Git-connected workspace.**

## Related

- [`../README.md`](../README.md) — project overview
- [`../../../.github/standards/branching-and-workspaces.md`](../../../.github/standards/branching-and-workspaces.md)
- [`../../../docs/02-connect-a-workspace.md`](../../../docs/02-connect-a-workspace.md)
