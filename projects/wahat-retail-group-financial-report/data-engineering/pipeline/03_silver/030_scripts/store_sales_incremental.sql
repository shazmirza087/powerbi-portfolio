-- Silver: store_sales (incremental)
-- Daily till sales by store and category, typed.
-- Reads {{increment}}: the Bronze rows not yet in Silver (loader 037 merges them on StoreSalesID).

SELECT
    StoreSalesID,
    to_date(CAST(DateKey AS STRING), 'yyyyMMdd')    AS SalesDate,
    StoreCode,
    CategoryCode,
    GrossSales,
    Units,
    Transactions
FROM {{increment}}
