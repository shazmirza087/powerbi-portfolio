-- Silver: store_history (SCD type 2)
-- The latest snapshot of every store. Loader 039 compares it with the current versions:
-- a changed store (format, selling area, closure, name) gets its current version closed and a
-- new one opened; a store missing from the snapshot has its current version closed.
-- Columns added by the loader: ValidFrom (inclusive), ValidTo (exclusive), IsCurrent, _row_hash.

SELECT
    StoreCode,
    EntityCode,
    StoreName,
    StoreFormat,
    City,
    SellingAreaSqm,
    OpenDate,
    CloseDate,
    IsProfitCentre
FROM {{silver}}.store
