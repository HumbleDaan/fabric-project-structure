## What and why

<!-- One sentence a stakeholder would understand. Not "update SM_Sales". -->

**Project:** <!-- projects/… -->
**Workspace:** <!-- the Fabric workspace this was built in -->

## Checks

- [ ] Names follow [`naming-conventions.md`](../.github/standards/naming-conventions.md)
- [ ] No `logicalId`, `type`, or item folder name changed
- [ ] Workspace-directory changes went one direction (Git-first or Fabric-first) and the round trip finished
- [ ] No non-definition files added inside an item folder — Fabric deletes them on the next commit
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
