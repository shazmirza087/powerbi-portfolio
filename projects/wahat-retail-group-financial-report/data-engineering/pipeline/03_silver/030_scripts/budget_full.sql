-- Silver: budget
-- Monthly budget by banner and group line, typed. The budget arrives with revenue and other
-- income as positive numbers; they are flipped to the ledger sign convention (credits
-- negative, manual 7.5) so actuals and budget can be compared line for line.

SELECT
    BudgetID,
    EntityCode,
    GroupLineCode,
    make_date(
        CAST(BudgetMonthKey div 10000 AS INT),
        CAST((BudgetMonthKey div 100) % 100 AS INT),
        1
    )                                       AS MonthStart,
    BudgetLCY
        * CASE
            WHEN GroupLineCode IN ('REV-01', 'REV-02', 'REV-03', 'OTH-01', 'COGS-02') THEN -1
            ELSE 1
          END                               AS BudgetLCY
FROM {{bronze}}.budget
