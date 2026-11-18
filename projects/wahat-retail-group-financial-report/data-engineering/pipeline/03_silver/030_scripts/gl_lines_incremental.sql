-- Silver: gl_lines (incremental)
-- The ledger at line grain, typed, with its group line and its store.
-- Reads {{increment}}: the Bronze lines not yet in Silver (loader 037 merges them on GLLineID).
--   Group line: the mapping rules (manual chapters 3 to 6). Where several rules match, the
--               lowest Priority wins.
--   Store:      the dated cost-centre history first (manual 6.4), otherwise today's store.
-- Every rule depends only on entity, account, cost centre and month, so the rules are
-- resolved once per distinct combination of those and joined back to the lines. The range
-- join then runs on thousands of keys instead of 14.4M lines.

WITH lines AS (
    SELECT
        GLLineID,
        EntityCode,
        JournalID,
        LineNo,
        to_date(CAST(PostingDateKey AS STRING), 'yyyyMMdd')     AS PostingDate,
        make_date(
            CAST(PeriodKey div 100 AS INT),
            CAST(PeriodKey % 100 AS INT),
            1
        )                                                       AS MonthStart,
        LocalAccountCode,
        CAST(LocalAccountCode AS INT)                           AS AccountNo,
        CostCentreCode,
        CategoryCode,
        SupplierCode,
        SourceType,
        TenderType,
        DocumentRef,
        LineText,
        CurrencyCode,
        AmountLCY
    FROM {{increment}}
),
posting_keys AS (
    SELECT DISTINCT
        EntityCode,
        MonthStart,
        LocalAccountCode,
        AccountNo,
        CostCentreCode
    FROM lines
),
ranked_rules AS (
    SELECT
        k.EntityCode,
        k.MonthStart,
        k.LocalAccountCode,
        k.CostCentreCode,
        cc.CurrentStoreCode,
        m.GroupLineCode,
        ROW_NUMBER() OVER (
            PARTITION BY
                k.EntityCode,
                k.MonthStart,
                k.LocalAccountCode,
                k.CostCentreCode
            ORDER BY m.Priority
        )                                                       AS RuleRank
    FROM posting_keys AS k
    LEFT JOIN {{silver}}.cost_centre AS cc
        ON cc.CostCentreCode = k.CostCentreCode
    LEFT JOIN {{silver}}.account_mapping AS m
        ON  m.EntityCode = k.EntityCode
        AND k.AccountNo BETWEEN m.RangeFrom AND m.RangeTo
        AND k.MonthStart BETWEEN m.ValidFrom AND m.ValidTo
        AND (m.CostCentreFunction IS NULL OR m.CostCentreFunction = cc.Function)
),
resolved AS (
    SELECT
        r.EntityCode,
        r.MonthStart,
        r.LocalAccountCode,
        r.CostCentreCode,
        r.GroupLineCode,
        COALESCE(h.StoreCode, r.CurrentStoreCode)               AS StoreCode
    FROM ranked_rules AS r
    LEFT JOIN {{silver}}.cost_centre_history AS h
        ON  h.CostCentreCode = r.CostCentreCode
        AND r.MonthStart BETWEEN h.ValidFrom AND h.ValidTo
    WHERE r.RuleRank = 1
)
SELECT
    l.GLLineID,
    l.EntityCode,
    l.JournalID,
    l.LineNo,
    l.PostingDate,
    l.MonthStart,
    l.LocalAccountCode,
    l.AccountNo,
    l.CostCentreCode,
    l.CategoryCode,
    l.SupplierCode,
    l.SourceType,
    l.TenderType,
    l.DocumentRef,
    l.LineText,
    l.CurrencyCode,
    l.AmountLCY,
    r.GroupLineCode,
    r.StoreCode
FROM lines AS l
LEFT JOIN resolved AS r
    ON  r.EntityCode = l.EntityCode
    AND r.MonthStart = l.MonthStart
    AND r.LocalAccountCode = l.LocalAccountCode
    AND r.CostCentreCode <=> l.CostCentreCode
