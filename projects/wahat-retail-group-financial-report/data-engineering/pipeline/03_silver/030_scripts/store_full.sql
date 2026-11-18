-- Silver: store
-- Stores with typed dates. Dark stores are not profit centres (manual 7.4).

SELECT
    StoreCode,
    EntityCode,
    StoreName,
    StoreFormat,
    City,
    SellingAreaSqm,
    CAST(OpenDate AS DATE)                  AS OpenDate,
    CAST(NULLIF(CloseDate, '') AS DATE)     AS CloseDate,
    StoreFormat <> 'Dark store'             AS IsProfitCentre
FROM {{bronze}}.store
