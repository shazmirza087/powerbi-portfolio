-- Gold: fact_budget
-- Budget by day, banner and group line, in local currency and in SAR at the monthly average
-- rate. The budget is set by month; each month's amount is spread evenly over its days, so the
-- budget can sit next to actuals by day, week, month, quarter or year. Month totals are
-- unchanged. Already in the ledger sign convention (silver.budget).

WITH budget_days AS (
    SELECT
        d.Date,
        b.EntityCode,
        b.GroupLineCode,
        b.MonthStart,
        b.BudgetLCY / day(last_day(b.MonthStart))           AS BudgetLCY
    FROM {{silver}}.budget AS b
    JOIN {{silver}}.date AS d
        ON d.MonthStart = b.MonthStart
)
SELECT
    bd.Date,
    bd.EntityCode,
    bd.GroupLineCode,
    CAST(bd.BudgetLCY AS DECIMAL(18, 4))                    AS BudgetLCY,
    CAST(bd.BudgetLCY * fx.AvgRateToSAR AS DECIMAL(18, 4))  AS BudgetSAR
FROM budget_days AS bd
JOIN {{silver}}.entity AS e
    ON e.EntityCode = bd.EntityCode
JOIN {{silver}}.fx_rate AS fx
    ON  fx.CurrencyCode = e.CurrencyCode
    AND fx.MonthStart = bd.MonthStart
