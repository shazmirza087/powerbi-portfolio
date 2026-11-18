-- Silver: control_totals
-- Signed-off FY2023 and FY2024 figures. Read by the quality check only, never published.

SELECT
    EntityCode,
    CAST(Year AS INT)                       AS Year,
    Metric,
    CAST(MetricOrder AS INT)                AS MetricOrder,
    CAST(SignedOff AS DECIMAL(18, 2))       AS SignedOff
FROM {{bronze}}.control_totals
