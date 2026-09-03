# Project Context — Sales Analytics

> Worked example. Fictional company, realistic content. This is the file agents read before doing
> anything in this project.

## What this project is for

Give Sales Operations one trustworthy view of order-to-cash: what was ordered, what was invoiced,
what came back, and what it was worth — reconciled to the ERP, refreshed daily, available by 07:00.

Today the same questions are answered by four spreadsheets that disagree with each other. The measure
of success is that they stop being maintained.

## Domain language

Project-specific. Global terms: [`../../.github/standards/glossary.md`](../../.github/standards/glossary.md).

| Term | Means here | Not to be confused with |
|---|---|---|
| **Order** | A confirmed line on a sales order in the ERP. Quotes are excluded. | *Opportunity* in CRM — a pre-order concept |
| **Net Sales** | Invoiced amount minus returns and credit notes, excluding VAT and freight | *Gross Sales* (excludes nothing), *Booked Sales* (order value, not invoiced) |
| **Return** | Physical goods received back against an invoice | *Credit note* — a financial correction that may have no goods movement |
| **Region** | ERP sales organisation hierarchy, **not** the CRM territory | CRM territory, which is owned by Sales and changes quarterly |

The Region distinction is the single most common source of "the numbers are wrong" tickets on this
project. If a request says "region", ask which one.

## Data sources

| Source | System | Load | Owner | Gotchas |
|---|---|---|---|---|
| Sales orders | SAP ECC | Incremental on `changed_on`, daily 02:00 | ERP team | Late-arriving changes up to 5 days back — the incremental window is 7 days, not 1 |
| Invoices | SAP ECC | Incremental daily 02:30 | ERP team | Cancelled invoices are **updated in place**, not deleted; a naive append double-counts |
| Returns | SAP ECC | Full daily 03:00 | ERP team | Low volume, full load is cheaper than change tracking |
| Customer master | Dynamics 365 | Full daily 01:00 | MDM team | `customer_id` is the ERP key; the CRM GUID is not usable as a join key |
| FX rates | Treasury SFTP | Daily 01:30 | Finance | Missing rates on public holidays — carry forward the last known rate, never default to 1.0 |

## Architecture

```
SAP ECC ─┐
D365 ────┼─▶ LH_Sales (bronze)  ─▶ silver (conformed)  ─▶ gold (star)  ─▶ SM_Sales  ─▶ RPT_Sales_Overview
SFTP ────┘   as-landed, typed      dedup, FX applied      fact + dims     Direct Lake
```

- **Bronze** — as-landed, no business logic, source column names preserved. Append-only with a load
  timestamp; nothing is ever deleted.
- **Silver** — typed, deduplicated on business key + latest change timestamp, FX applied, glossary
  names applied.
- **Gold** — `fact_sales_line`, `dim_customer`, `dim_product`, `dim_date`, `dim_region`. This is the
  only layer the semantic model reads.

## Constraints

- **SAP is read-only.** No pushdown of business logic to the source; every transformation lives in Fabric.
- **Figures must reconcile to SAP to the cent.** No approximate aggregation, no sampling, no
  floating-point money — decimal types throughout.
- **Currency:** all facts carry both transaction currency and EUR. EUR uses the daily rate at
  invoice date, never at query time.
- **Customer data is personal data** under the project DPIA. No unrestricted extracts; contact-level
  fields do not leave the silver layer.
- **07:00 SLA.** The full chain must finish by 06:30 to leave recovery headroom. Anything that adds
  more than 10 minutes to the critical path needs a conversation first.

## Refresh and SLA

| What | When | Paged |
|---|---|---|
| `PL_Sales_Daily_Load` | 02:00 CET daily | Data Platform on-call |
| `SM_Sales` reframe | On pipeline success | Data Platform on-call |
| Availability | 07:00 CET | Sales Ops informed, not paged |

## Known issues

- Returns arriving more than 90 days after invoice fall outside the current match window and land
  unmatched. Roughly 0.3% of return value. Accepted; revisit if it exceeds 1%.
- `dim_product` has ~40 items with no category, inherited from an unfinished 2024 MDM migration.
  They roll up to "Unassigned" rather than being dropped — deliberately visible, not hidden.

## Related

- [`README.md`](README.md)
- [`decisions/0001-direct-lake-over-import.md`](decisions/0001-direct-lake-over-import.md)
- [`workspaces/README.md`](workspaces/README.md)
