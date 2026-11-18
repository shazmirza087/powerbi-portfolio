-- Gold: dim_store_year
-- One row per store and year: its contribution (manual 7.4) and the SAR 0.5M band it falls in.
-- A dimension on fact_gl through StoreYearKey, so picking a band on the spread histogram
-- filters every visual to the stores in that band. Income is negative in the ledger, so the
-- sum is turned round.
-- StoreKey is the dim_store version valid on the last day of the year.
-- Materialized view, incremental refresh: only the years refreshed in fact_gl.

WITH store_year AS (
    SELECT
        make_date(year(f.Date), 1, 1)                           AS Date,
        f.StoreCode,
        f.EntityCode,
        -SUM(f.AmountLCY)                                       AS ContributionLCY,
        -SUM(f.AmountSAR)                                       AS ContributionSAR
    FROM {{gold}}.fact_gl AS f
    JOIN {{gold}}.dim_group_line AS g
        ON g.GroupLineCode = f.GroupLineCode
    WHERE g.InStoreContribution
      AND f.HasStore
    GROUP BY
        year(f.Date),
        f.StoreCode,
        f.EntityCode
)
SELECT
    concat(y.StoreCode, '|', year(y.Date))                     AS StoreYearKey,
    y.Date,
    y.StoreCode,
    s.StoreKey,
    y.EntityCode,
    CAST(y.ContributionLCY AS DECIMAL(18, 2))                   AS ContributionLCY,
    CAST(y.ContributionSAR AS DECIMAL(18, 2))                   AS ContributionSAR,
    CAST(FLOOR(y.ContributionSAR / 500000) * 0.5 AS DOUBLE)     AS ContributionBandM
FROM store_year AS y
LEFT JOIN {{gold}}.dim_store AS s
    ON  s.StoreCode = y.StoreCode
    AND make_date(year(y.Date), 12, 31) >= s.ValidFrom
    AND make_date(year(y.Date), 12, 31) < s.ValidTo
