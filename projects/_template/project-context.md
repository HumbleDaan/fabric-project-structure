# Project Context — <Project Name>

> **Template.** Replace every `<placeholder>`. Delete sections that don't apply — an empty heading
> is worse than a missing one, because it reads as "we have nothing to say about security".

Agents read this file before doing anything in this project. Keep it under two pages: this is
context, not documentation.

## What this project is for

`<Two or three sentences. The business outcome, not the technical solution.>`

## Domain language

Terms specific to this project. Global terms live in
[`../../.github/standards/glossary.md`](../../.github/standards/glossary.md); anything here overrides
the global definition **for this project only** — and if it does, say why.

| Term | Means here | Not to be confused with |
|---|---|---|
| `<term>` | `<definition>` | `<the near-miss>` |

## Data sources

| Source | System | Load pattern | Owner | Gotchas |
|---|---|---|---|---|
| `<name>` | `<SAP / Dynamics / SQL>` | `<full / incremental / CDC>` | `<team>` | `<the thing that surprises newcomers>` |

## Architecture

`<Bronze/silver/gold shape, storage modes, refresh cadence. A Mermaid diagram beats three paragraphs.>`

## Constraints

Things that are true and non-negotiable, with the reason. This is the highest-value section — it is
where an agent learns what it cannot design around.

- `<e.g. Source system is read-only; no pushdown of business logic upstream.>`
- `<e.g. Financial figures must reconcile to SAP to the cent — no approximate aggregations.>`
- `<e.g. Personal data in scope; see the DPIA. Do not create unrestricted exports.>`

## Refresh and SLA

| What | When | Who is paged |
|---|---|---|
| `<pipeline>` | `<schedule>` | `<team>` |

## Known issues

- `<the thing everyone rediscovers in week two>`

## Related

- [`README.md`](README.md)
- [`decisions/README.md`](decisions/README.md)
- [`workspaces/README.md`](workspaces/README.md)
