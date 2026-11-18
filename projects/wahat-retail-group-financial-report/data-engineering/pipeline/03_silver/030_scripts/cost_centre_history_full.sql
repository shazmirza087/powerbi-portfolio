-- Silver: cost_centre_history
-- Which store owns a re-used cost centre, by date (manual 6.4), typed.

SELECT
    CostCentreCode,
    StoreCode,
    CAST(ValidFrom AS DATE)                 AS ValidFrom,
    CAST(ValidTo AS DATE)                   AS ValidTo,
    ManualRef
FROM {{bronze}}.cost_centre_history
