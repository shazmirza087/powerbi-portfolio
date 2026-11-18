-- Silver: account_mapping
-- The mapping workbook (manual chapters 3 to 6), typed. One row per rule.
-- A blank cost-centre function means the rule applies to any function.

SELECT
    EntityCode,
    CAST(RangeFrom AS INT)                  AS RangeFrom,
    CAST(RangeTo AS INT)                    AS RangeTo,
    NULLIF(CostCentreFunction, '')          AS CostCentreFunction,
    CAST(ValidFrom AS DATE)                 AS ValidFrom,
    CAST(ValidTo AS DATE)                   AS ValidTo,
    CAST(Priority AS INT)                   AS Priority,
    GroupLineCode,
    ManualRef,
    Note
FROM {{bronze}}.account_mapping
