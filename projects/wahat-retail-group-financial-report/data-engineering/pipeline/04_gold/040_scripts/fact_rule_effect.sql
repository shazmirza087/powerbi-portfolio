-- Gold: fact_rule_effect (materialized view)
-- How much each dated exception or contradiction in the mapping manual moves, per banner and
-- year, in the banner's own currency (AmountLCY) and in SAR at each month's average rate
-- (AmountSAR). One rule = one account range on one banner, optionally
-- from a month and for one cost-centre function. Sign turns the ledger amount into the amount
-- the rule moves (credits shown positive for income rules).

WITH rules AS (
    SELECT *
    FROM VALUES
        (1, 'Bahrain rent to ROU depreciation from Jul 2024 (6.2a)', 'BAH', 6400, 6449, DATE'2024-07-01', NULL, 1),
        (2, 'Grocery DC staff to COGS-03 (6.1)', 'GRC', 600000, 604999, DATE'2023-01-01', 'Distribution centre', 1),
        (3, 'Grocery shrinkage to COGS-04 from 2025 (6.2c)', 'GRC', 568000, 568999, DATE'2025-01-01', NULL, 1),
        (4, 'Intercompany recharge income eliminated (6.5)', 'GRC', 790000, 790999, DATE'2023-01-01', NULL, -1),
        (5, 'Loyalty redemptions to REV-05 (memo GM-2024-07)', 'GRC', 405000, 405999, DATE'2023-01-01', NULL, 1),
        (6, 'Online delivery fees to REV-02 from 2025 (6.2b)', 'ONL', 41500, 41599, DATE'2025-01-01', NULL, -1),
        (7, 'Supplier rebates to COGS-02 (body 3.3 over App. B)', 'GRC', 430000, 434999, DATE'2023-01-01', NULL, -1)
    AS r (RuleOrder, RuleName, EntityCode, AccountFrom, AccountTo, ValidFrom, CostCentreFunction, Sign)
)
SELECT
    make_date(year(g.Date), 1, 1)                               AS Date,
    r.EntityCode,
    r.RuleName,
    r.RuleOrder,
    CAST(SUM(g.AmountLCY) * r.Sign AS DECIMAL(18, 2))           AS AmountLCY,
    CAST(SUM(g.AmountSAR) * r.Sign AS DECIMAL(18, 2))           AS AmountSAR
FROM {{gold}}.fact_gl AS g
JOIN {{gold}}.dim_account AS a
    ON a.AccountKey = g.AccountKey
LEFT JOIN {{gold}}.dim_cost_centre AS cc
    ON cc.CostCentreCode = g.CostCentreCode
JOIN rules AS r
    ON  r.EntityCode = g.EntityCode
    AND TRY_CAST(a.LocalAccountCode AS INT) BETWEEN r.AccountFrom AND r.AccountTo
    AND g.Date >= r.ValidFrom
    AND (r.CostCentreFunction IS NULL OR cc.Function = r.CostCentreFunction)
GROUP BY
    make_date(year(g.Date), 1, 1),
    r.EntityCode,
    r.RuleName,
    r.RuleOrder,
    r.Sign
