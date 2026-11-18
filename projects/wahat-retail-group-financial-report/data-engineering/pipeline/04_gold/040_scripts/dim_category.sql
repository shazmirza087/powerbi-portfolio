-- Gold: dim_category
-- Till product categories.

SELECT
    CategoryCode,
    CategoryName,
    Department,
    CostRatio
FROM {{silver}}.category
