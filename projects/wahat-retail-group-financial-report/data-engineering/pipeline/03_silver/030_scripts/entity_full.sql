-- Silver: entity
-- The three banners, with a display name, a sort order and a typed first period.

SELECT
    EntityCode,
    EntityName,
    Country,
    ERPSystem,
    CurrencyCode,
    ChartTable,
    CAST(FirstPeriod AS DATE)               AS FirstPeriod,
    CASE EntityCode
        WHEN 'GRC' THEN 'Grocery'
        WHEN 'ONL' THEN 'Online'
        ELSE 'Bahrain'
    END                                     AS Banner,
    CASE EntityCode
        WHEN 'GRC' THEN 1
        WHEN 'ONL' THEN 2
        ELSE 3
    END                                     AS BannerOrder
FROM {{bronze}}.entity
