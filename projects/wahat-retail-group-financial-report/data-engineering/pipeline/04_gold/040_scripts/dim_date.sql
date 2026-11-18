-- Gold: dim_date
-- Calendar 2023 to 2025. Marked as the date table in the model.

SELECT
    Date,
    Year,
    Quarter,
    YearQuarter,
    YearQuarterNumber,
    MonthNumber,
    MonthName,
    YearMonth,
    YearMonthNumber,
    MonthStart,
    WeekStart,
    DayName,
    DayOfWeekNumber,
    IsWeekend
FROM {{silver}}.date
