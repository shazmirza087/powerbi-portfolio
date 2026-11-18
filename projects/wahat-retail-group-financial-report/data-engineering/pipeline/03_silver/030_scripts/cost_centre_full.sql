-- Silver: cost_centre
-- Cost centres with their function and today's store. History is resolved in gl_mapped.

SELECT
    CostCentreCode,
    EntityCode,
    CostCentreName,
    Function,
    CurrentStoreCode
FROM {{bronze}}.cost_centre
