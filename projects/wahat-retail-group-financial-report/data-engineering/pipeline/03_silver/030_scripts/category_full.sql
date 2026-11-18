-- Silver: category
-- Till product categories, straight pass-through.

SELECT
    CategoryCode,
    CategoryName,
    Department,
    CostRatio
FROM {{bronze}}.category
