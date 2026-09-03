---
name: naming-check
description: Check or fix names of Fabric workspaces, items, tables, columns, branches and repo folders against the team's naming conventions. Use when creating anything new in Fabric, reviewing a pull request, when the user asks "what should I call this", or before committing workspace changes.
---

# Naming Check

Enforces [`../../standards/naming-conventions.md`](../../standards/naming-conventions.md). That file
is the source of truth — this skill is how it gets applied.

## When to use

- Anything new is being created in Fabric or in this repo
- Reviewing a PR that adds or renames items
- The user asks what to call something
- Before a commit from a workspace

## When not to use

- Deciding whether the *thing* should exist — that's a design conversation
- Renaming items already in production without checking downstream dependencies first

## Procedure

1. **Read the standard.** Do not answer from memory; it is edited more often than you think.
2. **Classify** what is being named: workspace, item, table, column, branch, or repo folder.
3. **Apply the pattern** and produce a concrete proposal, not a description of the rule.
4. **Run the hard checks** — these are correctness, not style:

   | Check | Applies to | Why |
   |---|---|---|
   | No `" / : < > \ * ? \|` | Item display names | Fabric replaces the Git folder name with a GUID |
   | No trailing space or `.` | Item display names | Same |
   | ≤ 256 characters | Item display names | Same |
   | No ` `, tab, CR, LF, `[ ] , ; { } ( ) =` | Delta column names | Illegal in Delta/Parquet; fails at write time |
   | No stage suffix (`_dev`, `_prod`) | Item names | Breaks deployment-pipeline item matching across stages |
   | Unique within the workspace | Item names | Two items with one name make the Git folder ambiguous |

5. **If renaming an existing item**, check what points at it first: reports referencing a semantic
   model, notebooks referencing a lakehouse, pipeline activities. Renaming the item renames its Git
   folder, and dependency paths do not update themselves.
6. **Report** as a table: `current → proposed → reason`. If everything passes, say so in one line.

## Failure modes

| Symptom | Cause | Fix |
|---|---|---|
| Git folder is a GUID instead of a name | Forbidden character / trailing space / too long | Rename in Fabric, commit again |
| Report broken after a rename | Semantic model folder renamed, `definition.pbir` still points at the old path | Update the dependency path, or rename back |
| Deployment pipeline creates duplicates instead of updating | Item names differ between stages | Make names identical across stages |
| Spark write fails on a valid-looking column | Space or bracket in the column name | Rename the column upstream |

## Related

- [`../../standards/naming-conventions.md`](../../standards/naming-conventions.md) — the rules
- [`../../standards/review-checklist.md`](../../standards/review-checklist.md) — naming in review
- [Git integration process](https://learn.microsoft.com/fabric/cicd/git-integration/git-integration-process) — the platform limits behind the hard checks
