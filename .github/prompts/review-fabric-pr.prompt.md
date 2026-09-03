---
mode: agent
description: Review a pull request that touches Fabric items, using the team review checklist. Reports blocking issues separately from suggestions.
---

# Review Fabric PR

Apply [`../standards/review-checklist.md`](../standards/review-checklist.md) to the current diff
(`git diff origin/main...HEAD`, or the branch I name).

## Do this

1. **Mechanical checks first** — these are objective and block a merge:
   - Any changed `logicalId` or `type` in a `.platform` file → **blocking**. An item folder was
     copied without regenerating it, and the workspace link will break.
   - Any renamed item directory → **blocking** unless every dependent reference was updated in the
     same PR (a report's `definition.pbir` points at its semantic model by path)
   - Any non-definition file added inside an item folder — Fabric deletes it on the next commit
   - Secrets, keys, tokens, connection strings
   - Hard-coded workspace / capacity / lakehouse IDs outside a parameter file
   - Names that violate [`../standards/naming-conventions.md`](../standards/naming-conventions.md)
   - A missing `README.md` index update for a newly added file
2. **Structural review** — layering, duplication, storage-mode choices, notebook idempotency,
   measure documentation.
3. **Decisions** — if the change embeds a non-obvious choice with no ADR in
   `projects/<project>/decisions/`, say so.

## Rules

- **Do not review generated JSON line by line.** Say what the change does at item level and flag
  anything structurally odd. Pretending to have read a 4,000-line report diff helps nobody.
- Cite file and line for every finding.
- If you cannot tell whether something is a problem, say that explicitly rather than guessing.

## Output

```
## Blocking (n)
- `path:line` — what's wrong, why it blocks, how to fix

## Suggestions (n)
- `path:line` — what could be better

## Not reviewed
- files skipped, and why (generated / binary / too large)

## Verdict
Approve | Request changes — one sentence
```
