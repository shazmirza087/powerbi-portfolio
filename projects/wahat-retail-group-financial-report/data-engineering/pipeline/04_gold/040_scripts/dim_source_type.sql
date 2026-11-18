-- Gold: dim_source_type
-- Ledger source of each posting.

SELECT
    SourceType,
    SourceName,
    Ledger
FROM {{silver}}.source_type
