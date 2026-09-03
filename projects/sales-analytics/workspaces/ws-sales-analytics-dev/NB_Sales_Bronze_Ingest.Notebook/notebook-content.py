# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse_name": "LH_Sales",
# META       "default_lakehouse_workspace_id": "00000000-0000-0000-0000-000000000000"
# META     }
# META   }
# META }

# MARKDOWN ********************

# ## NB_Sales_Bronze_Ingest
#
# Lands SAP extracts into bronze. Illustrative example — see
# `projects/sales-analytics/project-context.md` for the real constraints this encodes.
#
# **Design rules this notebook demonstrates**
# - Parameterised: no hard-coded dates or paths.
# - Idempotent: re-running for the same date produces the same result.
# - Bronze is as-landed: typed, timestamped, and otherwise untouched.
# - Fails loudly: no silent excepts.

# PARAMETERS CELL ********************

# Overridden by the pipeline. Defaults are for interactive runs only.
load_date = "2026-02-01"
lookback_days = 7          # late-arriving SAP changes; see project-context.md
source_root = "Files/landing/sap"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from datetime import datetime, timedelta

from pyspark.sql import functions as F

run_ts = datetime.utcnow()
window_start = (datetime.fromisoformat(load_date) - timedelta(days=lookback_days)).date()

print(f"load_date={load_date}  window_start={window_start}  run_ts={run_ts.isoformat()}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

def land_to_bronze(entity: str, change_column: str) -> int:
    """Land one SAP entity into bronze. Idempotent for a given load_date."""
    source_path = f"{source_root}/{entity}/"
    target_table = f"bronze_{entity}"

    df = (
        spark.read.format("parquet").load(source_path)
        .filter(F.col(change_column) >= F.lit(str(window_start)))
        .withColumn("_load_date", F.lit(load_date).cast("date"))
        .withColumn("_ingested_at_utc", F.lit(run_ts))
        .withColumn("_source_file", F.input_file_name())
    )

    row_count = df.count()
    if row_count == 0:
        # An empty extract is a real condition, not a success. Surface it.
        raise ValueError(
            f"{entity}: no rows at or after {window_start} in {source_path}. "
            "Check the upstream extract before re-running."
        )

    # replaceWhere makes the re-run safe: the same load_date is overwritten, not appended.
    (
        df.write.format("delta")
        .mode("overwrite")
        .option("replaceWhere", f"_load_date = '{load_date}'")
        .option("mergeSchema", "true")
        .saveAsTable(target_table)
    )

    print(f"{entity}: {row_count:,} rows -> {target_table}")
    return row_count

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

entities = {
    "sales_order": "changed_on",
    "invoice": "changed_on",
    "sales_return": "created_on",
}

results = {entity: land_to_bronze(entity, col) for entity, col in entities.items()}

# Let the pipeline see the row counts.
mssparkutils.notebook.exit(str(results))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
