## What and why

<!-- One sentence a stakeholder would understand. Not "update SM_Sales". -->

**Project:** <!-- projects/… -->
**Workspace:** <!-- the Fabric workspace this was built in -->

## Checks

- [ ] Names follow [`naming-conventions.md`](../.github/standards/naming-conventions.md)
- [ ] Nothing under `projects/*/workspaces/*/` was hand-edited — changes came from a Fabric commit
- [ ] No `logicalId` changed
- [ ] No secrets, no hard-coded workspace / capacity / lakehouse IDs
- [ ] The relevant `README.md` index is updated in this PR
- [ ] Non-obvious choices are written up in `projects/<project>/decisions/`
- [ ] Validation is green

## Not reviewable by eye

<!-- Generated files in this diff that a human cannot meaningfully read, and how you verified them
     instead — tested in the workspace, validated by CI, compared row counts. -->

## Deployment notes

<!-- Anything the release manager needs: a load to run first, a connection to rebind, a Spark view
     to recreate, a OneLake role name to check. "None" is a fine answer. -->
