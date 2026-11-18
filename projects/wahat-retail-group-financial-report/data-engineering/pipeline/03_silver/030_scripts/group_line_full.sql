-- Silver: group_line
-- The group chart of reporting lines, as delivered. Report-specific attributes (order,
-- display sign, bridge step, store contribution) are added in Gold.

SELECT
    GroupLineCode,
    GroupLineName,
    Section,
    IsSubtotal
FROM {{bronze}}.group_line
