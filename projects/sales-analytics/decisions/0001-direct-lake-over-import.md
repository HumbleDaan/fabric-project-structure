# 0001 — Direct Lake over Import for `SM_Sales`

**Status:** Accepted
**Date:** 2026-02-11
**Deciders:** Data Platform team, Maria Lindqvist (business owner)

## Context

`fact_sales_line` is ~180M rows and grows by roughly 400k per day. The business needs data available
by 07:00 CET, and the upstream chain does not finish until 06:00. An Import model of this size takes
about 25 minutes to refresh, which leaves almost no recovery headroom if anything upstream is late.

Reporting is aggregate-heavy — region, month, product category — with occasional drill to order line.

## Options considered

| Option | Pro | Con |
|---|---|---|
| **Import** | Predictable query performance; every DAX feature available; well understood by the team | 25-minute refresh eats the SLA buffer; a second copy of 180M rows; memory pressure on the capacity at peak |
| **Direct Lake** | No refresh step — reframes in seconds after the Delta write; one copy of the data; removes the largest item from the critical path | Fallback to DirectQuery under some conditions; guardrails vary by SKU; calculated columns are constrained |
| **DirectQuery on Warehouse** | Always current | Interactive performance insufficient for the aggregate workload at this volume |

## Decision

Use **Direct Lake** on the gold layer in `LH_Sales`.

Supporting choices:
- The semantic model reads **gold only** — never silver, never bronze.
- Gold tables are V-Order optimised and compacted after each load.
- No calculated columns in the model. Anything that would be one is computed upstream in gold.
- The SLA is measured on *reframe complete*, not on pipeline complete.

## Consequences

**Accepted**
- We depend on Direct Lake guardrails for the capacity SKU. Row and file-size limits must be
  monitored — exceeding them causes a silent fallback to DirectQuery, which shows up as a
  performance complaint rather than an error.
- The team must understand framing. "Refresh" no longer means what it meant in Import.
- Some DAX patterns that assume calculated columns need rewriting upstream.

**Enabled**
- Refresh drops out of the critical path — roughly 25 minutes of SLA headroom recovered.
- One copy of the data instead of two.
- Capacity memory pressure at the morning peak is materially lower.

**Revisit when**
- Fallback to DirectQuery is observed in normal operation (monitor it explicitly), **or**
- `fact_sales_line` approaches the guardrail for the capacity SKU, **or**
- The capacity SKU changes in either direction.

## Related

- [`../project-context.md`](../project-context.md) — the 07:00 SLA that drove this
- [`0002-deployment-pipelines-over-branch-per-stage.md`](0002-deployment-pipelines-over-branch-per-stage.md)
- [Direct Lake overview](https://learn.microsoft.com/fabric/fundamentals/direct-lake-overview) — Microsoft Learn
