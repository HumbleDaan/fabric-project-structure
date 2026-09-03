## What and why

<!-- One sentence a stakeholder would understand. Not "update SM_Sales". -->

**Project:**
**Workspace:**

## Checks

- [ ] Names follow the naming conventions (`.github/standards/naming-conventions.md`)
- [ ] No `logicalId`, `type`, or item folder name changed
- [ ] Workspace-directory changes went one direction (Git-first or Fabric-first) and the round trip finished
- [ ] No non-definition files added inside an item folder — Fabric deletes them on the next commit
- [ ] No secrets, no hard-coded workspace / capacity / lakehouse IDs
- [ ] The relevant `README.md` index is updated in this PR
- [ ] Non-obvious choices are written up in the project's `decisions/` folder
- [ ] Validation pipeline is green

## Not reviewable by eye

<!-- Generated files a human cannot meaningfully read, and how you verified them instead. -->

## Deployment notes

<!-- Anything the release manager needs. "None" is a fine answer. -->
