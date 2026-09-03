# Workspaces — <Project Name>

| Repo directory | Fabric workspace | Stage | Branch | Git-connected | Notes |
|---|---|---|---|---|---|
| `ws-<name>-dev/` | `<org>-<domain>-dev` | dev | `main` | ✅ | |
| — | `<org>-<domain>-test` | test | — | ❌ deployment pipeline | |
| — | `<org>-<domain>-prod` | prod | — | ❌ deployment pipeline | |

Keep this table accurate. It is the only place the workspace↔branch↔directory mapping is written
down, and it is the first thing anyone reads when a deployment surprises them.

## Rules for this folder

1. **`ws-*/` directories are owned by Fabric.** Nothing in them is hand-edited. Change items in
   Fabric, commit from Fabric, review the diff here.
2. **Documentation goes beside the directory, not inside it** — `ws-sales-dev/` is the sync target;
   `sales-dev.md` next to it is where the notes live.
3. **One directory per Git-connected workspace.** Two workspaces cannot share a directory on the
   same branch.

## Adding one

Follow [`../../../.github/skills/workspace-bootstrap/SKILL.md`](../../../.github/skills/workspace-bootstrap/SKILL.md),
or run the `/new-workspace` prompt.

## Related

- [`../README.md`](../README.md)
- [`../../../.github/standards/branching-and-workspaces.md`](../../../.github/standards/branching-and-workspaces.md)
