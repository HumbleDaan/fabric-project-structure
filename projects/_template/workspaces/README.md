# Workspaces — <Project Name>

| Repo directory | Fabric workspace | Stage | Branch | Git-connected | Notes |
|---|---|---|---|---|---|
| `ws-<name>-dev/` | `<org>-<domain>-dev` | dev | `main` | ✅ | |
| — | `<org>-<domain>-test` | test | — | ❌ deployment pipeline | |
| — | `<org>-<domain>-prod` | prod | — | ❌ deployment pipeline | |

Keep this table accurate. It is the only place the workspace↔branch↔directory mapping is written
down, and it is the first thing anyone reads when a deployment surprises them.

## Rules for this folder

1. **`ws-*/` directories are synced with a live workspace.** Editing item definitions here is
   allowed — sync **one direction at a time**, and never change a `logicalId`, `type`, or item
   folder name. See [`.github/copilot-instructions.md`](../../../.github/copilot-instructions.md).
2. **Documentation goes beside the directory, not inside it** — `ws-sales-dev/` is the sync target;
   `sales-dev.md` next to it is where the notes live. Fabric deletes non-definition files left
   inside an item folder.
3. **One directory per Git-connected workspace.** Two workspaces cannot share a directory on the
   same branch.

## Adding one

Follow [`../../../.github/skills/workspace-bootstrap/SKILL.md`](../../../.github/skills/workspace-bootstrap/SKILL.md),
or run the `/new-workspace` prompt.

## Related

- [`../README.md`](../README.md)
- [`../../../.github/standards/branching-and-workspaces.md`](../../../.github/standards/branching-and-workspaces.md)
