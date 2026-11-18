-- Gold: fact_store_sales
-- Daily till sales by store and category, with the store's banner, in local currency and
-- in SAR at the monthly average rate. StoreKey is the dim_store version valid on the day.
-- Materialized view, incremental refresh: only the days touched by new till rows.

SELECT
    f.SalesDate                                             AS Date,
    f.StoreCode,
    s.StoreKey,
    s.EntityCode,
    f.CategoryCode,
    CAST(f.GrossSales AS DECIMAL(18, 2))                    AS GrossSalesLCY,
    CAST(f.GrossSales * fx.AvgRateToSAR AS DECIMAL(18, 2))  AS GrossSalesSAR,
    f.Units,
    f.Transactions
FROM {{silver}}.store_sales AS f
JOIN {{gold}}.dim_store AS s
    ON  s.StoreCode = f.StoreCode
    AND f.SalesDate >= s.ValidFrom
    AND f.SalesDate < s.ValidTo
JOIN {{silver}}.entity AS e
    ON e.EntityCode = s.EntityCode
JOIN {{silver}}.fx_rate AS fx
    ON  fx.CurrencyCode = e.CurrencyCode
    AND fx.MonthStart = trunc(f.SalesDate, 'MM')
