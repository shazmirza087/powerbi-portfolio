-- Gold: dim_account
-- Union of the three local charts of accounts, plus codes posted but missing from the charts.

SELECT
    AccountKey,
    EntityCode,
    LocalAccountCode,
    AccountName,
    AccountLabel,
    LocalClass,
    NormalBalance,
    PreviousName,
    RenamedOn,
    MissingFromChart
FROM {{silver}}.account
