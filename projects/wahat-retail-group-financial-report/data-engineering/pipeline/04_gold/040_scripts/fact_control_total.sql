-- Gold: fact_control_total (materialized view)
-- One row per signed-off figure (Management Accounts Summary: FY2023 and FY2024, five metrics
-- per banner), next to the same figure rebuilt from the published ledger in gold.fact_gl.
-- IsReconciled: the two agree to within one unit. The report counts these for the
-- "reconciled to sign-off" checks, so the check reads exactly what Power BI shows.

WITH pnl AS (
    SELECT
        EntityCode,
        year(Date)                                                                      AS Year,
        -SUM(AmountLCY) FILTER (WHERE GroupLineCode LIKE 'REV-%')                       AS NetRevenue,
        COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode LIKE 'COGS-%'), 0)          AS CostOfSales,
        COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode LIKE 'OPX-%'), 0)           AS Opex,
        -COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode = 'OTH-01'), 0)            AS OtherIncome,
        COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode IN ('BEL-01', 'BEL-04')), 0) AS Depreciation,
        -COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode = 'OTH-02'), 0)            AS ExchangeDifference,
        COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode = 'BEL-02'), 0)            AS FinanceCost,
        COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode = 'BEL-03'), 0)            AS Tax
    FROM {{gold}}.fact_gl
    GROUP BY
        EntityCode,
        year(Date)
),
model_figures AS (
    SELECT EntityCode, Year, 'Net revenue' AS Metric, NetRevenue AS Model FROM pnl
    UNION ALL
    SELECT EntityCode, Year, 'Gross profit', NetRevenue - CostOfSales FROM pnl
    UNION ALL
    SELECT EntityCode, Year, 'Operating expenses', Opex FROM pnl
    UNION ALL
    SELECT EntityCode, Year, 'EBITDA', NetRevenue - CostOfSales - Opex + OtherIncome FROM pnl
    UNION ALL
    SELECT
        EntityCode,
        Year,
        'Net profit',
        NetRevenue - CostOfSales - Opex + OtherIncome - Depreciation + ExchangeDifference - FinanceCost - Tax
    FROM pnl
)
SELECT
    make_date(c.Year, 1, 1)                                     AS Date,
    c.EntityCode,
    c.Metric,
    c.MetricOrder,
    c.SignedOff,
    CAST(ROUND(m.Model, 0) AS DECIMAL(18, 2))                   AS Model,
    CAST(ROUND(m.Model, 0) - c.SignedOff AS DECIMAL(18, 2))     AS Difference,
    COALESCE(ABS(ROUND(m.Model, 0) - c.SignedOff) <= 1, false)  AS IsReconciled
FROM {{silver}}.control_totals AS c
LEFT JOIN model_figures AS m
    ON  m.EntityCode = c.EntityCode
    AND m.Year = c.Year
    AND m.Metric = c.Metric
