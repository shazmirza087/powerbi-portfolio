-- Gold: dim_entity
-- The three banners, each with its own ERP and currency.

SELECT
    EntityCode,
    EntityName,
    Country,
    ERPSystem,
    CurrencyCode,
    FirstPeriod,
    Banner,
    BannerOrder
FROM {{silver}}.entity
