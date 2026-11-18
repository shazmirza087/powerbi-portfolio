-- Silver: account
-- The three local charts of accounts in one list, plus codes that were posted
-- but are missing from every chart.

WITH charts AS (
    SELECT 'GRC' AS EntityCode, * FROM {{bronze}}.account_sap
    UNION ALL
    SELECT 'ONL' AS EntityCode, * FROM {{bronze}}.account_ns
    UNION ALL
    SELECT 'BAH' AS EntityCode, * FROM {{bronze}}.account_leg
),
posted AS (
    SELECT DISTINCT
        EntityCode,
        LocalAccountCode
    FROM {{silver}}.gl_lines
)
SELECT
    concat(COALESCE(c.EntityCode, p.EntityCode), '|', COALESCE(c.LocalAccountCode, p.LocalAccountCode))
                                                        AS AccountKey,
    COALESCE(c.EntityCode, p.EntityCode)                AS EntityCode,
    COALESCE(c.LocalAccountCode, p.LocalAccountCode)    AS LocalAccountCode,
    COALESCE(c.AccountName, '(posted, not in chart)')   AS AccountName,
    concat(
        COALESCE(c.LocalAccountCode, p.LocalAccountCode), ' ',
        COALESCE(c.AccountName, '(posted, not in chart)')
    )                                                   AS AccountLabel,
    c.LocalClass,
    c.NormalBalance,
    NULLIF(c.PreviousName, '')                          AS PreviousName,
    NULLIF(c.RenamedOn, '')                             AS RenamedOn,
    c.LocalAccountCode IS NULL                          AS MissingFromChart
FROM charts AS c
FULL OUTER JOIN posted AS p
    ON  p.EntityCode = c.EntityCode
    AND p.LocalAccountCode = c.LocalAccountCode
