-- Quality check: the mapped ledger must reproduce the 25 signed-off FY2023 and FY2024
-- figures (Management Accounts Summary) to within one unit. Returns the figures that do
-- not match, or are missing on either side. No rows = pass.

WITH pnl AS (
    SELECT
        EntityCode,
        year(MonthStart)                                                                AS Year,
        -SUM(AmountLCY) FILTER (WHERE GroupLineCode LIKE 'REV-%')                       AS NetRevenue,
        COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode LIKE 'COGS-%'), 0)          AS CostOfSales,
        COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode LIKE 'OPX-%'), 0)           AS Opex,
        -COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode = 'OTH-01'), 0)            AS OtherIncome,
        COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode IN ('BEL-01', 'BEL-04')), 0) AS Depreciation,
        -COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode = 'OTH-02'), 0)            AS ExchangeDifference,
        COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode = 'BEL-02'), 0)            AS FinanceCost,
        COALESCE(SUM(AmountLCY) FILTER (WHERE GroupLineCode = 'BEL-03'), 0)            AS Tax
    FROM {{silver}}.gl_lines
    GROUP BY
        EntityCode,
        year(MonthStart)
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
    c.EntityCode,
    c.Year,
    c.Metric,
    c.SignedOff,
    ROUND(m.Model, 0)                       AS Model,
    ROUND(m.Model, 0) - c.SignedOff         AS Difference
FROM {{silver}}.control_totals AS c
LEFT JOIN model_figures AS m
    ON  m.EntityCode = c.EntityCode
    AND m.Year = c.Year
    AND m.Metric = c.Metric
WHERE m.Model IS NULL
   OR ABS(ROUND(m.Model, 0) - c.SignedOff) > 1
