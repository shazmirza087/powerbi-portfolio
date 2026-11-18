-- Quality check: every posting must have a group line.
-- Returns one row per banner and account that has no mapping rule. No rows = pass.
-- Fix: add a rule to mapping/AccountMapping.csv.

SELECT
    EntityCode,
    LocalAccountCode,
    COUNT(*)                                AS GLLines
FROM {{silver}}.gl_lines
WHERE GroupLineCode IS NULL
GROUP BY
    EntityCode,
    LocalAccountCode
