-- Gold: dim_store (materialized view over silver.store_history)
-- One row per version of a store. StoreKey is a hash of the store and the start of the version,
-- so the same version always gets the same key and the view can be rebuilt at any time
-- without the facts pointing at the wrong store.
-- IsCurrent: the version valid today (none for a store that has been removed).
-- IsLatest: the most recent version of each store, current or closed. Measures read a store's
-- lifecycle (open and close dates, name) from it, so removed stores still count for the
-- periods they traded.

SELECT
    xxhash64(StoreCode, ValidFrom)          AS StoreKey,
    StoreCode,
    EntityCode,
    StoreName,
    StoreFormat,
    City,
    SellingAreaSqm,
    OpenDate,
    CloseDate,
    IsProfitCentre,
    ValidFrom,
    ValidTo,
    IsCurrent,
    ValidFrom = MAX(ValidFrom) OVER (PARTITION BY StoreCode)    AS IsLatest
FROM {{silver}}.store_history
