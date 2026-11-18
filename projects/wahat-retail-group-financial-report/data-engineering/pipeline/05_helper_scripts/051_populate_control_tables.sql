-- =====================================================================
-- 051_populate_control_tables.sql
-- Every flow of the Wahat pipeline, one row each, plus the loader registry.
-- INSERT OVERWRITE replaces the definitions, so this file is safe to re-run.
--
-- control_id ranges: 1xx Bronze, 2xx Silver (22x = quality checks), 3xx Gold.
--
-- load_type:
--   SNAPSHOT        Bronze reference files: latest snapshot, plus every delivery in <table>_snapshots
--   INCREMENTAL     Bronze: append rows above the watermark. Silver: MERGE the new rows on the key
--   FULL            Silver reference tables, budget: replace the table (type 1)
--   SCD2            Silver store_history: keep every version of a store (new, changed, removed)
--   CHECK           Silver quality checks
--   MV_FULL         Gold materialized view, recomputed in full
--   MV_INCREMENTAL  Gold materialized view, only the periods touched by new Silver rows
-- depends_on_control_ids: comma-separated flows that must succeed first. A dependency in an
-- earlier layer (Gold 311 on Silver checks 221, 222) is met only if its latest run succeeded.
-- Gold reads only Silver. Silver reads Bronze and other Silver tables.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Loader registry: source_type -> loader notebook, per layer
-- ---------------------------------------------------------------------
INSERT OVERWRITE {{ctrl}}.source_type_registry
VALUES
    ('PARQUET_FILE', 'BRONZE', '0200_ingest_parquet_file', true, 'Bronze: land a raw parquet file as delivered'),
    ('CSV_FILE', 'BRONZE', '0201_ingest_csv_file', true, 'Bronze: land a CSV file as delivered, all text'),
    ('FULL_LOAD', 'SILVER', '035_full_load', true, 'Silver: run a SELECT script, replace the table'),
    ('QUALITY_CHECK', 'SILVER', '036_quality_check', true, 'Silver: run a check script, fail if it returns rows'),
    ('INCREMENTAL_MERGE', 'SILVER', '037_incremental_merge', true, 'Silver: script over the new Bronze rows, MERGE on the key'),
    ('SCD2', 'SILVER', '039_scd2', true, 'Silver: type 2 history, close changed and removed members, open new versions'),
    ('MATERIALIZED_VIEW', 'GOLD', '045_materialized_view', true, 'Gold: refresh a materialized view, in full or only the changed periods');

-- ---------------------------------------------------------------------
-- 2. Flows
-- Columns: control_id, pipeline_name, layer, is_active, load_sequence, depends_on_control_ids,
--          source_system, source_type, source_connection_name, source_object, source_format,
--          destination_schema, destination_table, load_type, primary_key_columns, publish_name,
--          retry_count, timeout_minutes, watermark_column, incremental_source, partition_column,
--          partition_source_column, surrogate_key_column
-- ---------------------------------------------------------------------
INSERT OVERWRITE {{ctrl}}.data_flow_control
VALUES
    (101, 'gl_lines_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_FactGLLines.parquet', 'PARQUET', 'wahat', 'gl_lines', 'INCREMENTAL', NULL, NULL, 3, 30, 'GLLineID', NULL, NULL, NULL, NULL),
    (102, 'store_sales_daily_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_FactStoreSalesDaily.parquet', 'PARQUET', 'wahat', 'store_sales_daily', 'INCREMENTAL', NULL, NULL, 3, 30, 'StoreSalesID', NULL, NULL, NULL, NULL),
    (103, 'budget_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_FactBudget.parquet', 'PARQUET', 'wahat', 'budget', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (104, 'date_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_DimDate.parquet', 'PARQUET', 'wahat', 'date', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (105, 'entity_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_DimEntity.parquet', 'PARQUET', 'wahat', 'entity', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (106, 'group_line_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_DimGroupLine.parquet', 'PARQUET', 'wahat', 'group_line', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (107, 'store_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_DimStore.parquet', 'PARQUET', 'wahat', 'store', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (108, 'cost_centre_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_DimCostCentre.parquet', 'PARQUET', 'wahat', 'cost_centre', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (109, 'category_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_DimCategory.parquet', 'PARQUET', 'wahat', 'category', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (110, 'source_type_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_DimSourceType.parquet', 'PARQUET', 'wahat', 'source_type', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (111, 'fx_rate_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_DimFXRate.parquet', 'PARQUET', 'wahat', 'fx_rate', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (112, 'account_sap_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_DimLocalAccount_SAP.parquet', 'PARQUET', 'wahat', 'account_sap', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (113, 'account_ns_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_DimLocalAccount_NS.parquet', 'PARQUET', 'wahat', 'account_ns', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (114, 'account_leg_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_DimLocalAccount_LEG.parquet', 'PARQUET', 'wahat', 'account_leg', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (115, 'supplier_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'PARQUET_FILE', 'RAW_FOLDER', 'DD-RET-005_Supporting_Tables/DD-RET-005_DimSupplier.parquet', 'PARQUET', 'wahat', 'supplier', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (116, 'account_mapping_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'CSV_FILE', 'MAPPING_FOLDER', 'AccountMapping.csv', 'CSV', 'wahat', 'account_mapping', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (117, 'cost_centre_history_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'CSV_FILE', 'MAPPING_FOLDER', 'CostCentreHistory.csv', 'CSV', 'wahat', 'cost_centre_history', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (118, 'control_totals_bronze_load', 'BRONZE', true, 10, NULL, 'DD-RET-005', 'CSV_FILE', 'MAPPING_FOLDER', 'ControlTotals.csv', 'CSV', 'wahat', 'control_totals', 'SNAPSHOT', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (201, 'fx_rate_silver_load', 'SILVER', true, 10, NULL, 'DD-RET-005', 'FULL_LOAD', NULL, 'fx_rate_full.sql', 'SQL', 'wahat', 'fx_rate', 'FULL', 'CurrencyCode,MonthStart', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (202, 'entity_silver_load', 'SILVER', true, 10, NULL, 'DD-RET-005', 'FULL_LOAD', NULL, 'entity_full.sql', 'SQL', 'wahat', 'entity', 'FULL', 'EntityCode', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (203, 'store_silver_load', 'SILVER', true, 10, NULL, 'DD-RET-005', 'FULL_LOAD', NULL, 'store_full.sql', 'SQL', 'wahat', 'store', 'FULL', 'StoreCode', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (204, 'cost_centre_silver_load', 'SILVER', true, 10, NULL, 'DD-RET-005', 'FULL_LOAD', NULL, 'cost_centre_full.sql', 'SQL', 'wahat', 'cost_centre', 'FULL', 'CostCentreCode', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (205, 'category_silver_load', 'SILVER', true, 10, NULL, 'DD-RET-005', 'FULL_LOAD', NULL, 'category_full.sql', 'SQL', 'wahat', 'category', 'FULL', 'CategoryCode', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (206, 'source_type_silver_load', 'SILVER', true, 10, NULL, 'DD-RET-005', 'FULL_LOAD', NULL, 'source_type_full.sql', 'SQL', 'wahat', 'source_type', 'FULL', 'SourceType', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (207, 'date_silver_load', 'SILVER', true, 10, NULL, 'DD-RET-005', 'FULL_LOAD', NULL, 'date_full.sql', 'SQL', 'wahat', 'date', 'FULL', 'Date', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (208, 'group_line_silver_load', 'SILVER', true, 10, NULL, 'DD-RET-005', 'FULL_LOAD', NULL, 'group_line_full.sql', 'SQL', 'wahat', 'group_line', 'FULL', 'GroupLineCode', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (209, 'account_mapping_silver_load', 'SILVER', true, 10, NULL, 'DD-RET-005', 'FULL_LOAD', NULL, 'account_mapping_full.sql', 'SQL', 'wahat', 'account_mapping', 'FULL', 'EntityCode,RangeFrom,RangeTo,CostCentreFunction,ValidFrom', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (210, 'cost_centre_history_silver_load', 'SILVER', true, 10, NULL, 'DD-RET-005', 'FULL_LOAD', NULL, 'cost_centre_history_full.sql', 'SQL', 'wahat', 'cost_centre_history', 'FULL', 'CostCentreCode,ValidFrom', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (211, 'control_totals_silver_load', 'SILVER', true, 10, NULL, 'DD-RET-005', 'FULL_LOAD', NULL, 'control_totals_full.sql', 'SQL', 'wahat', 'control_totals', 'FULL', 'EntityCode,Year,Metric', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (212, 'gl_lines_silver_load', 'SILVER', true, 20, '101,204,209,210', 'DD-RET-005', 'INCREMENTAL_MERGE', NULL, 'gl_lines_incremental.sql', 'SQL', 'wahat', 'gl_lines', 'INCREMENTAL', 'GLLineID', NULL, 3, 30, '_batch_id', 'bronze.gl_lines', NULL, NULL, NULL),
    (213, 'budget_silver_load', 'SILVER', true, 10, NULL, 'DD-RET-005', 'FULL_LOAD', NULL, 'budget_full.sql', 'SQL', 'wahat', 'budget', 'FULL', 'BudgetID', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (214, 'account_silver_load', 'SILVER', true, 30, '212', 'DD-RET-005', 'FULL_LOAD', NULL, 'account_full.sql', 'SQL', 'wahat', 'account', 'FULL', 'AccountKey', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (215, 'store_sales_silver_load', 'SILVER', true, 10, '102', 'DD-RET-005', 'INCREMENTAL_MERGE', NULL, 'store_sales_incremental.sql', 'SQL', 'wahat', 'store_sales', 'INCREMENTAL', 'StoreSalesID', NULL, 3, 30, '_batch_id', 'bronze.store_sales_daily', NULL, NULL, NULL),
    (216, 'store_history_silver_load', 'SILVER', true, 20, '203', 'DD-RET-005', 'SCD2', NULL, 'store_history_scd2.sql', 'SQL', 'wahat', 'store_history', 'SCD2', 'StoreCode', NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (221, 'dq_unmapped_gl_silver_load', 'SILVER', true, 40, '212', 'DD-RET-005', 'QUALITY_CHECK', NULL, 'check_unmapped_gl.sql', 'SQL', 'wahat', 'dq_unmapped_gl', 'CHECK', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (222, 'dq_control_totals_silver_load', 'SILVER', true, 40, '212,211', 'DD-RET-005', 'QUALITY_CHECK', NULL, 'check_control_totals.sql', 'SQL', 'wahat', 'dq_control_totals', 'CHECK', NULL, NULL, 3, 30, NULL, NULL, NULL, NULL, NULL),
    (301, 'dim_date_gold_load', 'GOLD', true, 10, '207', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'dim_date.sql', 'SQL', 'wahat', 'dim_date', 'MV_FULL', 'Date', 'DimDate', 3, 30, NULL, NULL, NULL, NULL, NULL),
    (302, 'dim_entity_gold_load', 'GOLD', true, 10, '202', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'dim_entity.sql', 'SQL', 'wahat', 'dim_entity', 'MV_FULL', 'EntityCode', 'DimEntity', 3, 30, NULL, NULL, NULL, NULL, NULL),
    (303, 'dim_group_line_gold_load', 'GOLD', true, 10, '208', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'dim_group_line.sql', 'SQL', 'wahat', 'dim_group_line', 'MV_FULL', 'GroupLineCode', 'DimGroupLine', 3, 30, NULL, NULL, NULL, NULL, NULL),
    (304, 'dim_account_gold_load', 'GOLD', true, 10, '214', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'dim_account.sql', 'SQL', 'wahat', 'dim_account', 'MV_FULL', 'AccountKey', 'DimAccount', 3, 30, NULL, NULL, NULL, NULL, NULL),
    (305, 'dim_store_gold_load', 'GOLD', true, 10, '216', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'dim_store.sql', 'SQL', 'wahat', 'dim_store', 'MV_FULL', 'StoreKey', 'DimStore', 3, 30, NULL, NULL, NULL, NULL, NULL),
    (306, 'dim_cost_centre_gold_load', 'GOLD', true, 10, '204', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'dim_cost_centre.sql', 'SQL', 'wahat', 'dim_cost_centre', 'MV_FULL', 'CostCentreCode', 'DimCostCentre', 3, 30, NULL, NULL, NULL, NULL, NULL),
    (307, 'dim_category_gold_load', 'GOLD', true, 10, '205', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'dim_category.sql', 'SQL', 'wahat', 'dim_category', 'MV_FULL', 'CategoryCode', 'DimCategory', 3, 30, NULL, NULL, NULL, NULL, NULL),
    (308, 'dim_source_type_gold_load', 'GOLD', true, 10, '206', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'dim_source_type.sql', 'SQL', 'wahat', 'dim_source_type', 'MV_FULL', 'SourceType', 'DimSourceType', 3, 30, NULL, NULL, NULL, NULL, NULL),
    (311, 'fact_gl_gold_load', 'GOLD', true, 20, '221,222,201,202,305', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'fact_gl.sql', 'SQL', 'wahat', 'fact_gl', 'MV_INCREMENTAL', NULL, 'FactGL', 3, 30, '_batch_id', 'silver.gl_lines', 'Date', 'PostingDate', NULL),
    (312, 'fact_budget_gold_load', 'GOLD', true, 20, '213,201,202', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'fact_budget.sql', 'SQL', 'wahat', 'fact_budget', 'MV_FULL', 'Date,EntityCode,GroupLineCode', 'FactBudget', 3, 30, NULL, NULL, NULL, NULL, NULL),
    (313, 'fact_store_sales_gold_load', 'GOLD', true, 20, '215,201,202,203,305', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'fact_store_sales.sql', 'SQL', 'wahat', 'fact_store_sales', 'MV_INCREMENTAL', 'Date,StoreCode,CategoryCode', 'FactStoreSales', 3, 30, '_batch_id', 'silver.store_sales', 'Date', 'SalesDate', NULL),
    (315, 'dim_store_year_gold_load', 'GOLD', true, 30, '311,303,305', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'dim_store_year.sql', 'SQL', 'wahat', 'dim_store_year', 'MV_INCREMENTAL', 'Date,StoreCode', 'DimStoreYear', 3, 30, '_batch_id', 'gold.fact_gl', 'Date', 'make_date(year(Date), 1, 1)', NULL),
    (316, 'fact_control_total_gold_load', 'GOLD', true, 30, '311,211', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'fact_control_total.sql', 'SQL', 'wahat', 'fact_control_total', 'MV_FULL', 'Date,EntityCode,Metric', 'FactControlTotal', 3, 30, NULL, NULL, NULL, NULL, NULL),
    (317, 'fact_journal_check_gold_load', 'GOLD', true, 20, '212', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'fact_journal_check.sql', 'SQL', 'wahat', 'fact_journal_check', 'MV_INCREMENTAL', 'Date,EntityCode', 'FactJournalCheck', 3, 30, '_batch_id', 'silver.gl_lines', 'Date', 'MonthStart', NULL),
    (318, 'fact_rule_effect_gold_load', 'GOLD', true, 30, '311,304,306', 'DD-RET-005', 'MATERIALIZED_VIEW', NULL, 'fact_rule_effect.sql', 'SQL', 'wahat', 'fact_rule_effect', 'MV_FULL', 'Date,EntityCode,RuleName', 'FactRuleEffect', 3, 30, NULL, NULL, NULL, NULL, NULL);
