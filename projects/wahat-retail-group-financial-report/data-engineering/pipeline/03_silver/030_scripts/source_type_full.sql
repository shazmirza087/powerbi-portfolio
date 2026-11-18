-- Silver: source_type
-- Ledger sources, straight pass-through.

SELECT
    SourceType,
    SourceName,
    Ledger
FROM {{bronze}}.source_type
