# Glossary

The shared vocabulary. Agents read this file to resolve ambiguous business terms, so it is worth
keeping short and precise rather than long and complete.

> **Replace the business section entirely.** The Fabric section below is generic and can stay.

## Business terms

*(example content — swap in your own)*

| Term | Definition | Owner | Don't confuse with |
|---|---|---|---|
| **Net Sales** | Gross sales minus returns, discounts and credit notes. Excludes VAT and freight. | Finance | *Gross Sales*, which excludes nothing |
| **Order** | A confirmed customer commitment. Quotes are not orders. | Sales Ops | *Shipment* — one order can ship several times |
| **Customer** | A billing entity, keyed on `customer_id`. A group with five subsidiaries is five customers. | MDM | *Account*, which is a CRM relationship record |
| **Active Customer** | Bought at least once in the trailing 12 months. | Sales Ops | *Registered Customer* |
| **Fiscal Year** | Runs 1 Feb – 31 Jan. `FY26` ends 31 Jan 2026. | Finance | Calendar year |

Rules for this table:
- One line per term. If it needs a paragraph, it needs a page in `projects/<project>/`.
- Name an **owner** — a term with no owner has no answer when two teams disagree.
- The "don't confuse with" column is the one that earns its keep.

## Fabric terms

| Term | Meaning here |
|---|---|
| **Workspace** | A Fabric workspace. Our unit of deployment and permission. Maps to one directory in this repo. |
| **Item** | Anything inside a workspace: lakehouse, notebook, pipeline, semantic model, report. |
| **Git integration** | The workspace↔branch↔directory sync built into Fabric. Source control, not deployment. |
| **Deployment pipeline** | Fabric's built-in dev→test→prod promotion. Deployment, not source control. |
| **`logicalId`** | The GUID in a `.platform` file linking a Git item folder to a workspace item. Never edit it. |
| **Stage** | `dev` / `test` / `prod`. Encoded in the workspace name, never in the item name. |
| **Medallion** | Bronze (raw, as-landed) → Silver (conformed, typed) → Gold (business-shaped, serving). |
| **Direct Lake** | Semantic model storage mode reading Delta files directly from OneLake. |
| **Shortcut** | A OneLake pointer to data held elsewhere. Moves as metadata; the data stays put. |

## Related

- [`naming-conventions.md`](naming-conventions.md) — how these terms become names
- [`../skills/business-glossary/SKILL.md`](../skills/business-glossary/SKILL.md) — the skill that keeps this file honest
