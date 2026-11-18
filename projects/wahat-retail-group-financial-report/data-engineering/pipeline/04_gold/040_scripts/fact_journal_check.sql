-- Gold: fact_journal_check (materialized view)
-- Double entry check per banner and month: how many journals were posted and how many of them
-- do not net to zero in local currency. A journal is balanced when its lines sum to zero
-- within half a cent.
-- Refreshed by 045 as MV_INCREMENTAL: only the months touched by new ledger lines are rebuilt.

WITH journals AS (
    SELECT
        EntityCode,
        MonthStart,
        JournalID,
        ABS(SUM(AmountLCY)) > 0.005                             AS IsUnbalanced
    FROM {{silver}}.gl_lines
    GROUP BY
        EntityCode,
        MonthStart,
        JournalID
)
SELECT
    MonthStart                                                  AS Date,
    EntityCode,
    CAST(COUNT(*) AS BIGINT)                                    AS Journals,
    CAST(COUNT_IF(IsUnbalanced) AS BIGINT)                      AS UnbalancedJournals
FROM journals
GROUP BY
    MonthStart,
    EntityCode
