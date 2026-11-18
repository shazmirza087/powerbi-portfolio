-- Silver: date
-- Calendar with the extra sort and grouping columns the model needs.
-- Weeks run Sunday to Saturday (the Saudi and Bahraini working week); WeekStart is the Sunday.

SELECT
    CAST(Date AS DATE)                              AS Date,
    Year,
    concat('Q', quarter(Date))                      AS Quarter,
    concat(Year, ' Q', quarter(Date))               AS YearQuarter,
    CAST(Year * 10 + quarter(Date) AS INT)          AS YearQuarterNumber,
    MonthNumber,
    MonthName,
    YearMonth,
    CAST(Year * 100 + MonthNumber AS INT)           AS YearMonthNumber,
    CAST(trunc(Date, 'MM') AS DATE)                 AS MonthStart,
    date_sub(CAST(Date AS DATE), dayofweek(Date) - 1) AS WeekStart,
    DayName,
    CAST(weekday(Date) + 1 AS BIGINT)               AS DayOfWeekNumber,
    IsWeekend
FROM {{bronze}}.date
