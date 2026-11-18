-- Silver: fx_rate
-- Monthly average and closing rate to SAR (manual 2.3), keyed by currency and month start.

SELECT
    CurrencyCode,
    make_date(
        CAST(MonthStartKey div 10000 AS INT),
        CAST((MonthStartKey div 100) % 100 AS INT),
        1
    )                       AS MonthStart,
    AvgRateToSAR,
    ClosingRateToSAR
FROM {{bronze}}.fx_rate
