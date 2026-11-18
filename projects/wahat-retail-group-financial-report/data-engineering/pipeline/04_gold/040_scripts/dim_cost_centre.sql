-- Gold: dim_cost_centre
-- Cost centres. CurrentStoreCode is today's store only; history is resolved in fact_gl.

SELECT
    CostCentreCode,
    CostCentreName,
    Function,
    CurrentStoreCode
FROM {{silver}}.cost_centre
