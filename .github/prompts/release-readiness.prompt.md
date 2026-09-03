---
mode: agent
description: Pre-flight check before promoting a project to test or production. Produces a go/no-go with the reasons.
---

# Release Readiness

Act as the release manager ([`../agents/release-manager.md`](../agents/release-manager.md)).

## Ask me

1. Which **project** and which **target stage**?
2. What is being released — a one-line change summary.

## Check

**Process**
- [ ] Validation is green on the commit being promoted
- [ ] A named human has approved (not just "CI passed")
- [ ] The promotion pattern matches the project's recorded decision — pipelines *or* branches, not both
- [ ] The change is announced if the target is production

**Content — what does not travel**
- [ ] Spark views recreated in the target
- [ ] External shortcut targets parameterised, or correct for the target stage
- [ ] OneLake data access role **names** identical across stages
- [ ] Connection bindings covered by deployment rules or the parameter file
- [ ] No stage-specific value hard-coded in an item definition

**Data**
- [ ] The load that populates the target is scheduled or triggered as part of this release
- [ ] Someone will verify row counts in the target before it is called done

**Rollback**
- [ ] The previous state is identified (commit sha, or deployment-pipeline state)
- [ ] The rollback path is stated, with an honest time estimate
- [ ] "We would rebuild it" is recorded as **no rollback**, not as a rollback

## Output

```
## Verdict: GO | NO-GO

## Blockers
- what, and what would clear it

## Risks accepted
- what, and who accepted it

## Post-deploy actions
1. …
```

Do not perform the deployment. This prompt produces a decision, not a release.
