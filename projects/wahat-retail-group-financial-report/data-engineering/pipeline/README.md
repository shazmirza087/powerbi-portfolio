# Wahat data pipeline: local medallion lakehouse

The ETL for the Wahat Group Performance report. It takes the raw DD-RET-005 files through Bronze, Silver and Gold Delta tables on a local Spark install, then publishes the Gold tables as the parquet files Power BI imports.

It follows the same metadata-driven pattern as a Databricks lakehouse: every load is a row in a control table, each loader is a notebook chosen by source type, and every run is written to a log. Adding a table means adding a row and a SQL script, not writing a new notebook.

## What it produces

| Layer | Tables | What happens there |
|---|---|---|
| Bronze | 18 (+ snapshot history) | Raw files landed as delivered: 15 parquet files and the 3 mapping CSVs. No changes, plus load metadata |
| Silver | 16 + 2 checks | Cleaned and conformed, at source grain: all 14.4M ledger lines typed, mapped to a group line and assigned to a store; the three charts of accounts combined; budget in the ledger sign convention |
| Gold | 15 materialized views | The star schema the report uses: 8 dimensions and 7 facts (two of them assurance checks: control totals against sign-off, and journal balance), at report grain (ledger by day), in local currency and SAR |
| Publish | 15 files | One parquet file per Gold view in `lakehouse/<env>/publish`, the folder the Power BI model reads |

The two Silver checks are the reconciliation. `check_unmapped_gl` fails if any ledger line has no group line. `check_control_totals` fails if any of the 25 signed-off FY2023 and FY2024 figures is off by more than one unit. FactGL depends on both, so a failed check stops the run before the report data is touched.

The first run loads everything (about 3 to 4 minutes on a laptop). After that, each run only processes what is new.

### What each layer does

| Layer | Rule of thumb | In this pipeline |
|---|---|---|
| Bronze | Exactly what arrived, plus load columns | 18 files landed as delivered |
| Silver | The cleaned, conformed, enterprise view. Keeps the source grain. Applies rules every consumer should agree on | Types and blanks fixed. One chart of accounts across three ERPs. Every ledger line mapped to the group chart (manual chapters 3 to 6) and assigned to its store (6.4). Budget flipped to the ledger sign convention (7.5). Quality checks |
| Gold | Shaped for one consumer: this report | 14.4M ledger lines summed to about 6M rows at day grain. Budget spread from month to day. SAR translation (2.3). Report attributes on group lines (order, display sign, bridge step, store contribution). the Sankey flow columns on group lines, and the store-year table |

Gold reads only Silver. Silver keeps all 14.4M ledger lines, so an audit, a drill to journal or a weekly view can be built from it without going back to Bronze.

### Load patterns

History, change capture and incremental loading live in Bronze and Silver. Gold holds only materialized views.

| Layer | Table | Pattern | How |
|---|---|---|---|
| Bronze | `gl_lines`, `store_sales_daily` | **Incremental append** | Only rows above the table's highest `GLLineID` / `StoreSalesID` are appended. Every delivery stays on record with its `_batch_id` |
| Bronze | Every reference file | **Snapshot history** | The table holds the latest snapshot. `<table>_snapshots` keeps every delivery, append-only, so any past state can be replayed |
| Silver | `gl_lines`, `store_sales` | **Incremental MERGE** | The script runs over the Bronze rows newer than Silver's last `_batch_id`, then `MERGE`s on `GLLineID` / `StoreSalesID`. Re-running a batch changes nothing |
| Silver | `store_history` | **SCD type 2 with change capture** | The latest store snapshot is compared with the current versions. New stores get a first version, changed stores get their version closed and a new one opened, removed stores get their version closed |
| Silver | Other reference tables, budget | **SCD type 1** | Replaced from the latest snapshot: the latest values win |
| Gold | Every table | **Materialized view** | A SQL definition over Silver plus a stored result. Dimensions and small facts are recomputed in full. `fact_gl`, `fact_store_sales`, `dim_store_year` and `fact_journal_check` refresh incrementally: only the days or years touched by new Silver rows are recomputed (Delta `replaceWhere`) |

Every new Delta table has **Change Data Feed** switched on, so any consumer can read just the rows a write inserted, updated or deleted. Every Silver and Gold row records the batch that wrote it in `_batch_id`, which is the watermark for the next layer.

Other history already in the data: `CostCentreHistory.csv` (which store owned a re-used cost centre, by date) and the dated rules in `AccountMapping.csv` are type 2 histories applied in Silver. `DimAccount` carries a type 3 history from the ERPs (`AccountName` with `PreviousName` and `RenamedOn`).

**Gold has no state of its own.** It can be deleted and rebuilt from Silver at any time. `dim_store` gets `StoreKey` as a hash of the store and the start of its version, so a rebuild produces the same keys and the facts still point at the right version. Local Spark has no built-in materialized views, so `045_materialized_view` is the refresh engine.

**When to run a full refresh.** Incremental refreshes assume older rows do not change. After a change to reference data (a mapping rule, an FX rate, a group line), set `full_refresh = True` in `060_run_pipeline` for one run. Store history in Silver is kept either way.

**Tested by replaying deliveries.** First the ledger and till feed to November 2025. Then December 2025, with one store's selling area changed and one store removed. The second run:
- appended only the new rows;
- detected one changed and one removed store;
- refreshed only December 2025 (and the 2025 store-year);
- produced the same report data, and the same store keys, as a full load of all the data.

A third run with nothing new changed nothing.

## Folder layout

```
pipeline/
  00_shared/
    000_nb_configurations.ipynb      paths, environment, Spark session, table naming
    001_nb_utils.ipynb               control lookups, run log, write helpers, the flow engine
  01_ddl/
    010_provision_core_artifacts     lakehouse folders and databases
    011_create_data_flow_control_table   data_flow_control and source_type_registry
    012_create_pipeline_run_log_table
    013_run_ddl                      runs 010 to 012
  02_bronze/
    020_ingestion/0200, 0201         loaders: parquet file, CSV file
    021_orchestration/0210           runs every active Bronze flow
  03_silver/
    030_loaders/035, 036, 037, 039   loaders: full load, quality check, incremental MERGE, SCD2
    030_scripts/*.sql                one SELECT per Silver table or check
    031_orchestration/038            runs every active Silver flow
  04_gold/
    040_loaders/045                  loader: materialized view refresh (full or incremental)
    040_scripts/*.sql                one SELECT per Gold materialized view
    041_orchestration/048            runs every active Gold flow
    042_publish/0420                 writes Gold to lakehouse/<env>/publish for Power BI
  05_helper_scripts/
    050_populate_control_tables      loads 051 into the control tables
    051_populate_control_tables.sql  every flow, one row each
    052_pipeline_run_report          latest run, slowest flows, failures
  06_orchestration/
    060_run_pipeline                 Bronze, Silver, Gold, publish
  environment.yml
```

Data lives outside this folder:

```
Retail Dashboard/
  DD-RET-005_FactGLLines.parquet          raw (RAW_FOLDER)
  DD-RET-005_Supporting_Tables/           raw
  Wahat Group Performance/
    mapping/                              mapping CSVs (MAPPING_FOLDER)
    lakehouse/dev/bronze, silver, gold, metadata   Delta tables (LAKEHOUSE), not in git
    lakehouse/dev/publish/                published parquet for Power BI (PUBLISH_FOLDER)
    pipeline/                             this folder
```

## One-time setup on Windows

**1. Create the conda environment.** Open Anaconda Prompt in this folder:

```
conda env create -f environment.yml
conda activate wahat-pipeline
```

This installs Python 3.11, Java 17, PySpark 3.5.3, Delta Lake 3.2.1, pandas, pyarrow and JupyterLab. Java comes with the environment, so nothing else needs installing system-wide.

If Windows blocks the new environment's `python.exe` (a Device Guard or Smart App Control message), use the Anaconda `base` environment instead: install the Microsoft Build of OpenJDK 17 (tick *Set JAVA_HOME* in the installer), then run `pip install pyspark==3.5.3 delta-spark==3.2.1`. The pipeline works on Python versions newer than Spark 3.5 supports, because it never starts a Python worker.

**2. Add winutils.** Spark needs two Hadoop helper files to read and write local folders on Windows.
- Download `winutils.exe` and `hadoop.dll` for Hadoop 3.3 (the `cdarlint/winutils` repository on GitHub, folder `hadoop-3.3.5/bin`).
- Put both in `C:\hadoop\bin`.
- If you use another folder, set the `HADOOP_HOME` environment variable to the folder that holds `bin`.

The configuration notebook checks for this and stops with a clear message if the files are missing.

**3. First run needs internet.** On its first start, Spark downloads the Delta Lake jars from Maven (a few MB) into `%USERPROFILE%\.ivy2`. After that it runs offline.

**4. Start Jupyter from the environment:**

```
conda activate wahat-pipeline
jupyter lab
```

If you use the Anaconda Navigator or VS Code instead, pick the `wahat-pipeline` kernel.

## Running it

First time only, in this order:
1. `01_ddl/013_run_ddl` creates the folders, databases and the three control tables.
2. `05_helper_scripts/050_populate_control_tables` loads the 51 flow definitions.

Every refresh after that:
1. `06_orchestration/060_run_pipeline` runs Bronze, Silver and Gold, then publishes. Only new data is processed. Set `full_refresh = True` in its first cell to reload everything.
2. Refresh in Power BI Desktop.

To see what happened, open `05_helper_scripts/052_pipeline_run_report`. It shows the latest batch flow by flow, with status, retries, duration and rows written, and the full error message for anything that failed.

You can also run one layer on its own (`0210`, `038` or `048`) or only the publish (`0420`). A layer only starts a flow when that flow's dependencies have succeeded, including dependencies from an earlier layer.

## How it works

### The control tables

| Table | One row per | Main columns |
|---|---|---|
| `ctrl.data_flow_control` | flow | `control_id`, `layer`, `is_active`, `load_sequence`, `depends_on_control_ids`, `source_type`, `source_object`, `destination_table`, `load_type`, `primary_key_columns`, `publish_name`, `retry_count`, and for incremental flows `watermark_column`, `incremental_source`, `partition_column`, `partition_source_column`, `surrogate_key_column` |
| `ctrl.source_type_registry` | source type and layer | which loader notebook handles it |
| `ctrl.pipeline_run_log` | run event | `batch_id`, `status` (RUNNING, SUCCEEDED, FAILED, SKIPPED), `retry_attempt`, `duration_seconds`, `rows_written`, `error_message` |

Control ids: `1xx` Bronze, `2xx` Silver (`22x` quality checks), `3xx` Gold.

### A layer run

1. Read the active flows for the layer.
2. Sort them into waves by `depends_on_control_ids`. Each wave runs in parallel (4 at a time).
3. For each flow, look up its loader in the registry, run it, and log the start and the result.
4. A failed flow is retried up to `retry_count` times. A failed quality check is not retried, because it is a data problem, not a glitch.
5. Any flow whose dependency failed is marked SKIPPED, not run.

### Loaders

| Source type | Layer | Loader | What it does |
|---|---|---|---|
| PARQUET_FILE | Bronze | `0200_ingest_parquet_file` | Reads the file as delivered, adds load columns |
| CSV_FILE | Bronze | `0201_ingest_csv_file` | Reads the CSV as text, adds load columns |
| FULL_LOAD | Silver | `035_full_load` | Runs the flow's SQL script, replaces the table |
| QUALITY_CHECK | Silver | `036_quality_check` | Runs the check script, fails if it returns any rows |
| INCREMENTAL_MERGE | Silver | `037_incremental_merge` | Runs the script over the new Bronze rows, MERGEs on the key |
| SCD2 | Silver | `039_scd2` | Compares the latest snapshot with the current versions, closes and opens versions |
| MATERIALIZED_VIEW | Gold | `045_materialized_view` | Refreshes the view in full (`MV_FULL`) or only the changed periods (`MV_INCREMENTAL`) |

The Bronze loaders keep snapshot history when `load_type` is `SNAPSHOT`, and append above the watermark when it is `INCREMENTAL`.

Every Silver and Gold transformation is a plain `SELECT` in a `.sql` file. Inside a script, `{{bronze}}`, `{{silver}}` and `{{gold}}` stand for the layer databases, so the scripts never hard-code a location. An incremental script reads `{{increment}}`, the new rows of its source. Each Silver and Gold row records the batch that wrote it in `_batch_id`, which is the watermark for the next layer.

### Publishing

A Delta table is a folder of part files plus a transaction log. Power BI's parquet connector reads single files, so `0420` writes each Gold table once more as a single file named after its `publish_name` (for example `FactGL.parquet`), leaving out the lineage columns that start with `_`. Only Gold flows whose latest run succeeded are published, so a failed run never overwrites what the report shows.

## Settings

All paths have defaults that work from this folder. Override any of them with an environment variable before starting Jupyter:

| Variable | Default | Use |
|---|---|---|
| `WAHAT_ENV` | `dev` | Lakehouse sub-folder, so dev and prod data never mix |
| `WAHAT_RAW_FOLDER` | the folder above the project | Raw DD-RET-005 files |
| `WAHAT_MAPPING_FOLDER` | `../mapping` | Mapping CSVs |
| `WAHAT_LAKEHOUSE` | `../lakehouse` | Where the Delta tables live |
| `WAHAT_PUBLISH_FOLDER` | `../lakehouse/<env>/publish` | Where Power BI reads from |
| `WAHAT_TABLE_FORMAT` | `delta` | `parquet` runs without Delta, for a quick test |
| `WAHAT_DRIVER_MEMORY` | `6g` | Spark memory. Lower it on an 8 GB machine |

## Adding a flow

Example: a new Gold materialized view `dim_supplier`.

1. Write `04_gold/040_scripts/dim_supplier.sql` as a single `SELECT` from `{{silver}}`.
2. Add a row to `05_helper_scripts/051_populate_control_tables.sql`, for example with `control_id` 310, layer `GOLD`, source type `MATERIALIZED_VIEW`, load type `MV_FULL`, `source_object` `dim_supplier.sql`, the Silver flow it depends on, and `publish_name` `DimSupplier`.
3. Run `050_populate_control_tables`, then `060_run_pipeline`.
4. In Power BI, add `DimSupplier.parquet` from the `DataFolder` parameter.

To switch a flow off without deleting it, set `is_active` to false.

## Differences from the Databricks version

| Databricks | Here | Why |
|---|---|---|
| Unity Catalog: `catalog.schema.table` | Spark databases `bronze_wahat`, `silver_wahat`, `gold_wahat`, `ctrl` | Local Spark has no Unity Catalog. Tables are registered from the lakehouse folders at the start of each session |
| `%run ./notebook` | `run_notebook("path")` in each notebook's first cell | Jupyter's `%run` breaks on Windows paths with spaces |
| Workflows with one task per layer | `060_run_pipeline` | Same order and the same stop-on-failure rule |
| Cloud storage | Local folders under `lakehouse/` | |
| Gold read by Power BI through a SQL warehouse | Gold published as parquet files | Power BI Desktop reads local parquet directly, with no gateway |

The control tables, loaders, SQL scripts and run log are the same design, so the notebooks move to Databricks with the path and naming helpers changed in `000_nb_configurations`.
