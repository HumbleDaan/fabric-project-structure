---
mode: agent
description: Regenerate the documentation for a workspace from what is actually committed in its Git directory, so the docs match reality.
---

# Document Workspace

Workspace documentation drifts within weeks. This regenerates it from the committed truth.

## Ask me

Which workspace? (path under `projects/*/workspaces/`)

## Do this

1. **Read the directory, not the docs.** Enumerate every item folder; parse each `.platform` for
   `displayName`, `type` and `description`.
2. **Read the item definitions** for structure — notebook `.py` for what it reads and writes,
   `definition.pbir` / `definition.pbism` for report→model dependencies, pipeline JSON for activities.
3. **Build the dependency picture**: which notebooks write which tables, which model reads which
   lakehouse, which reports use which model. Mermaid diagram if it's non-trivial.
4. **Compare with the existing notes file** next to the directory. List what changed since it was
   last written — that delta is the most useful part of the output.
5. **Write** to `projects/<project>/workspaces/<workspace-name>.md`.

## Rules

- **Never write inside an item folder.** Fabric deletes non-definition files there on the next
  commit. Workspace documentation belongs beside the synced directory, not in it.
- Say what you could not determine, rather than inferring. "Source system unknown — not derivable
  from the definition" is a useful line; a plausible guess is not.
- Keep it under two pages. Long documentation is unread documentation.

## Output

```markdown
# <workspace-name>

**Fabric workspace:** … · **Stage:** … · **Git folder:** … · **Branch:** …

## Purpose
one paragraph

## Items
| Item | Type | Purpose |

## Data flow
source → bronze → silver → gold → model → report  (Mermaid if useful)

## Dependencies
inbound / outbound, including anything outside this workspace

## Notes
open questions, known gaps, things a newcomer would trip over

*Generated from commit <sha> on <date>. Regenerate rather than hand-edit.*
```
