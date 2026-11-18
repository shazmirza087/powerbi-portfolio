-- Gold: fact_gl
-- The ledger at report grain: posting day x banner x group line x account x cost centre x
-- store x source x tender, in local currency and in SAR at the monthly average rate (manual
-- 2.3: every day of a month uses that month's rate). Day grain lets the report show days,
-- weeks, months, quarters and years. Line detail stays in silver.gl_lines.
-- StoreKey is the dim_store version valid on the posting day.
-- Materialized view, incremental refresh: only the days touched by new ledger lines.

WITH daily AS (
    SELECT
        PostingDate,
        MonthStart,
        EntityCode,
        GroupLineCode,
        LocalAccountCode,
        CostCentreCode,
        StoreCode,
        SourceType,
        TenderType,
        SUM(AmountLCY)                                      AS AmountLCY,
        COUNT(*)                                            AS LineCount
    FROM {{silver}}.gl_lines
    GROUP BY
        PostingDate,
        MonthStart,
        EntityCode,
        GroupLineCode,
        LocalAccountCode,
        CostCentreCode,
        StoreCode,
        SourceType,
        TenderType
)
SELECT
    g.PostingDate                                           AS Date,
    g.EntityCode,
    g.GroupLineCode,
    concat(g.EntityCode, '|', g.LocalAccountCode)           AS AccountKey,
    g.CostCentreCode,
    g.StoreCode,
    s.StoreKey,
    -- links each store posting to its store-year row in dim_store_year (contribution band)
    concat(g.StoreCode, '|', year(g.PostingDate))           AS StoreYearKey,
    g.StoreCode IS NOT NULL                                 AS HasStore,
    g.SourceType,
    g.TenderType,
    CAST(g.AmountLCY AS DECIMAL(18, 2))                     AS AmountLCY,
    CAST(g.AmountLCY * fx.AvgRateToSAR AS DECIMAL(18, 4))   AS AmountSAR,
    g.LineCount
FROM daily AS g
JOIN {{silver}}.entity AS e
    ON e.EntityCode = g.EntityCode
JOIN {{silver}}.fx_rate AS fx
    ON  fx.CurrencyCode = e.CurrencyCode
    AND fx.MonthStart = g.MonthStart
LEFT JOIN {{gold}}.dim_store AS s
    ON  s.StoreCode = g.StoreCode
    AND g.PostingDate >= s.ValidFrom
    AND g.PostingDate < s.ValidTo
