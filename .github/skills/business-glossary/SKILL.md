---
name: business-glossary
description: Resolve or define business terms before they get baked into a measure, table or report name. Use when a request contains an ambiguous business term (revenue, customer, active, churn, order), when defining a new measure, when two people appear to mean different things by the same word, or when the user asks what a term means here.
---

# Business Glossary

The most expensive bugs in analytics are not code bugs — they are two people using one word for two
things, and nobody noticing until the numbers are in front of a board. This skill makes the agent
stop and check rather than guess.

## When to use

- A request contains a business term with more than one plausible meaning
- A new measure, table or report is being named after a business concept
- Two sources disagree on a number that "should" match
- The user asks what a term means in this organisation

## When not to use

- Fabric or Power BI technical vocabulary — that's [`../../standards/glossary.md`](../../standards/glossary.md#fabric-terms) and the Microsoft Fabric skills
- Terms local to a single project — check that project's `project-context.md` first

## Procedure

1. **Look it up** in [`../../standards/glossary.md`](../../standards/glossary.md), then in the
   project's `project-context.md`. Project scope wins over global scope where they differ — and if
   they differ, say so out loud, because that is usually a mistake worth fixing.
2. **If defined:** use it, and state the definition you are working from in one line so the user can
   correct you cheaply.
3. **If not defined, and it matters:** stop and ask. Offer the two or three readings you can see.
   Do not silently pick one — a wrong assumption becomes a measure, the measure gets a name, the name
   gets into a report, and it is a six-month problem.
4. **If not defined, and it doesn't matter:** proceed, and note the assumption.
5. **When a new term is agreed**, add it to the glossary in the *same* change as the artefact that
   uses it. A term agreed in chat and not written down was not agreed.
6. **Name the owner.** A term with no owner has no tiebreaker.

## Writing a definition

- One sentence, stated positively.
- Say what it **excludes** — that is where the disagreement lives (`Net Sales` excludes VAT and freight).
- Fill the "don't confuse with" column; it does more work than the definition itself.
- If it takes a paragraph, it isn't a glossary entry — write it up in the project folder and link it.

## Failure modes

| Symptom | Cause | Fix |
|---|---|---|
| Two measures, similar names, different numbers | Same term defined twice, independently | Consolidate; keep one, alias the other, deprecate loudly |
| A number "changed" with no code change | Definition drifted informally | Version the definition; note the change date in the glossary |
| Endless "which revenue?" in reviews | Term used in names but never defined | Define it, then rename the artefacts |
| Glossary nobody reads | It grew to 200 rows of obvious terms | Only define terms that have caused, or could cause, an argument |

## Related

- [`../../standards/glossary.md`](../../standards/glossary.md) — the glossary itself
- [`../naming-check/SKILL.md`](../naming-check/SKILL.md) — turning an agreed term into a compliant name
- `projects/*/project-context.md` — project-scoped overrides
