# ws-sales-analytics-dev

**Fabric workspace:** `contoso-sales-dev`
**Stage:** dev
**Git folder:** `projects/sales-analytics/workspaces/ws-sales-analytics-dev`
**Branch:** `main`
**Capacity:** `contoso-fabric-weu` (F64)

> This file sits *outside* the synced directory on purpose. Anything written inside
> `ws-sales-analytics-dev/` appears as an unexpected change the next time Fabric syncs.

## Purpose

The development workspace for Sales Analytics. All change starts here; test and prod are reached
through the `Sales Analytics` deployment pipeline.

## Items

| Item | Type | Purpose |
|---|---|---|
| `LH_Sales` | Lakehouse | Bronze / silver / gold Delta tables for order-to-cash |
| `NB_Sales_Bronze_Ingest` | Notebook | Lands SAP order, invoice and return extracts into bronze |
| `SM_Sales` | Semantic model | Direct Lake model over the gold star schema |
| `RPT_Sales_Overview` | Report | Sales Ops daily overview |

A production workspace would also hold `PL_Sales_Daily_Load`, the silver and gold notebooks, and
`ENV_Sales_Spark`. Trimmed here to keep the example readable.

## Data flow

```
SAP ECC / D365 / SFTP
        │
        ▼
NB_Sales_Bronze_Ingest ──▶ LH_Sales (bronze → silver → gold)
                                       │
                                       ▼
                                   SM_Sales  (Direct Lake, gold only)
                                       │
                                       ▼
                              RPT_Sales_Overview
```

## Dependencies

**Inbound** — SAP ECC extracts on ADLS (shortcut), D365 customer master, Treasury FX drop.
**Outbound** — `contoso-sales-test` via deployment pipeline; `RPT_Sales_Overview` is embedded in the
Sales Ops Teams channel.

## Notes

- The semantic model reads **gold only**. A model pointed at silver will pass review by accident and
  break the moment silver is restructured.
- Deployment carries metadata, not data. After promoting, run the load in the target before believing
  any number you see there.
- Regenerate this file with the `/document-workspace` prompt rather than editing it by hand.

## Related

- [`README.md`](README.md) — workspace mapping table
- [`../project-context.md`](../project-context.md) — sources, constraints, SLA
- [`../decisions/0001-direct-lake-over-import.md`](../decisions/0001-direct-lake-over-import.md)
