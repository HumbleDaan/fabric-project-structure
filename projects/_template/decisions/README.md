# Decisions

Architecture Decision Records for this project. One file per decision, numbered, never deleted.

| # | Decision | Status | Date |
|---|---|---|---|
| — | *none yet* | | |

## When to write one

When the answer to *"why is it done that way?"* is interesting. In practice:

- A choice between two defensible options (Direct Lake vs Import, pipelines vs branch-per-stage)
- A deliberate deviation from a team standard
- A constraint you had to design around
- Something you reversed — including why the first answer was wrong

Not for: anything the standards already settle, or anything obvious from the code.

## Format

Copy [`0000-template.md`](0000-template.md). Number sequentially. Keep it to one page.

**Superseded records stay.** Mark the status `Superseded by 000X` and leave the file. The history of
what you tried is the point; a folder of only-current decisions is just documentation.

## Related

- [`../README.md`](../README.md)
- [`../project-context.md`](../project-context.md)
