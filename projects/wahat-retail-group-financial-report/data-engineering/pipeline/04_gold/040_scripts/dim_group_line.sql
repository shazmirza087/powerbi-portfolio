-- Gold: dim_group_line
-- Group reporting lines with the attributes this report needs: report order (subtotals
-- interleaved), section order, display sign (credits shown positive), profit bridge step
-- and the store-contribution flag (manual 7.4).

SELECT
    g.GroupLineCode,
    g.GroupLineName,
    CASE
        WHEN g.IsSubtotal THEN g.GroupLineName
        ELSE concat(g.GroupLineCode, ' ', g.GroupLineName)
    END                                                         AS GroupLineLabel,
    g.Section,
    g.IsSubtotal,
    o.ReportOrder,
    -- Subtotal rows of the statement: the sum of the P&L lines from SubtotalFrom up to the
    -- row, times SubtotalSign. Profit subtotals start at the top and show income positive.
    -- Total operating expenses adds the opex lines only and shows them positive.
    CASE
        WHEN g.GroupLineCode = 'SUB-OPX' THEN 106
        WHEN g.IsSubtotal THEN 0
    END                                                         AS SubtotalFrom,
    CASE
        WHEN g.GroupLineCode = 'SUB-OPX' THEN 1
        WHEN g.IsSubtotal THEN -1
    END                                                         AS SubtotalSign,
    -- 1 when a higher shown value is good for profit, -1 when it is bad. Colours the change
    -- and budget variance columns.
    CASE
        WHEN g.GroupLineCode = 'SUB-OPX' THEN -1
        WHEN g.IsSubtotal THEN 1
        WHEN g.Section IN ('Revenue', 'Other income') THEN 1
        -- exchange differences: a gain is shown positive, so a higher value is good
        WHEN g.GroupLineCode = 'OTH-02' THEN 1
        ELSE -1
    END                                                         AS ProfitDirection,
    CASE g.Section
        WHEN 'Revenue' THEN 1
        WHEN 'Cost of sales' THEN 2
        WHEN 'Operating expenses' THEN 3
        WHEN 'Other income' THEN 4
        WHEN 'Below EBITDA' THEN 5
        WHEN 'Eliminations' THEN 6
        WHEN 'Balance sheet' THEN 7
        ELSE 8
    END                                                         AS SectionOrder,
    -- credits shown positive: revenue, other income, and exchange differences (a gain is income)
    CASE WHEN g.Section IN ('Revenue', 'Other income') OR g.GroupLineCode = 'OTH-02' THEN -1 ELSE 1 END AS DisplaySign,
    CASE
        WHEN g.GroupLineCode LIKE 'REV-%'  THEN 'Net revenue'
        WHEN g.GroupLineCode LIKE 'COGS-%' THEN 'Cost of sales'
        WHEN g.GroupLineCode LIKE 'OPX-%'  THEN 'Opex'
        WHEN g.GroupLineCode = 'OTH-01'    THEN 'Other income'
        WHEN g.GroupLineCode IN ('BEL-01', 'BEL-04') THEN 'D&A + ROU'
        WHEN g.GroupLineCode = 'OTH-02'    THEN 'FX diff.'
        WHEN g.GroupLineCode = 'BEL-02'    THEN 'Finance'
        WHEN g.GroupLineCode = 'BEL-03'    THEN 'Tax & zakat'
    END                                                         AS BridgeStep,
    CASE
        WHEN g.GroupLineCode LIKE 'REV-%'  THEN 1
        WHEN g.GroupLineCode LIKE 'COGS-%' THEN 2
        WHEN g.GroupLineCode LIKE 'OPX-%'  THEN 3
        WHEN g.GroupLineCode = 'OTH-01'    THEN 4
        WHEN g.GroupLineCode IN ('BEL-01', 'BEL-04') THEN 5
        WHEN g.GroupLineCode = 'OTH-02'    THEN 6
        WHEN g.GroupLineCode = 'BEL-02'    THEN 7
        WHEN g.GroupLineCode = 'BEL-03'    THEN 8
        ELSE 99
    END                                                         AS BridgeOrder,
    -- Profit flow Sankey: each line is one link from FlowSource to FlowDestination. Income
    -- flows into total income, total income flows out to each cost step and to net profit
    -- (the Net profit subtotal row carries that last link).
    CASE
        WHEN g.GroupLineCode LIKE 'REV-%'  THEN 'Net revenue'
        WHEN g.GroupLineCode = 'OTH-01'    THEN 'Other income'
        WHEN g.GroupLineCode LIKE 'COGS-%'
          OR g.GroupLineCode LIKE 'OPX-%'
          OR g.GroupLineCode LIKE 'BEL-%'
          OR g.GroupLineCode IN ('OTH-02', 'SUB-NP') THEN 'Total income'
    END                                                         AS FlowSource,
    CASE
        WHEN g.GroupLineCode LIKE 'REV-%'  THEN 'Total income'
        WHEN g.GroupLineCode = 'OTH-01'    THEN 'Total income'
        WHEN g.GroupLineCode LIKE 'COGS-%' THEN 'Cost of sales'
        WHEN g.GroupLineCode LIKE 'OPX-%'  THEN 'Operating expenses'
        WHEN g.GroupLineCode IN ('BEL-01', 'BEL-04') THEN 'Depreciation and ROU'
        WHEN g.GroupLineCode IN ('BEL-02', 'OTH-02') THEN 'Finance cost and FX'
        WHEN g.GroupLineCode = 'BEL-03'    THEN 'Tax and zakat'
        WHEN g.GroupLineCode = 'SUB-NP'    THEN 'Net profit'
    END                                                         AS FlowDestination,
    g.Section IN ('Revenue', 'Cost of sales', 'Operating expenses', 'Other income',
                  'Below EBITDA', 'Subtotal')                   AS IsPnL,
    g.GroupLineCode IN ('REV-01', 'REV-03', 'REV-04', 'REV-05', 'COGS-01', 'COGS-04', 'COGS-05',
                        'OPX-01', 'OPX-02', 'OPX-03', 'OPX-11') AS InStoreContribution,
    CASE
        WHEN g.GroupLineCode IN ('REV-01', 'REV-03', 'REV-04', 'REV-05') THEN 'Net sales'
        WHEN g.GroupLineCode IN ('COGS-01', 'COGS-04', 'COGS-05')         THEN 'COGS & stock'
        WHEN g.GroupLineCode = 'OPX-01'                                   THEN 'Staff'
        WHEN g.GroupLineCode = 'OPX-02'                                   THEN 'Rent'
        WHEN g.GroupLineCode = 'OPX-03'                                   THEN 'Utilities'
        WHEN g.GroupLineCode = 'OPX-11'                                   THEN 'Consumables'
    END                                                         AS StoreBridgeStep,
    CASE
        WHEN g.GroupLineCode IN ('REV-01', 'REV-03', 'REV-04', 'REV-05') THEN 1
        WHEN g.GroupLineCode IN ('COGS-01', 'COGS-04', 'COGS-05')         THEN 2
        WHEN g.GroupLineCode = 'OPX-01'                                   THEN 3
        WHEN g.GroupLineCode = 'OPX-02'                                   THEN 4
        WHEN g.GroupLineCode = 'OPX-03'                                   THEN 5
        WHEN g.GroupLineCode = 'OPX-11'                                   THEN 6
        ELSE 99
    END                                                         AS StoreBridgeOrder
FROM {{silver}}.group_line AS g
JOIN (
    VALUES
        ('REV-01', 10), ('REV-02', 20), ('REV-03', 30), ('REV-04', 40), ('REV-05', 50), ('SUB-NR', 55),
        ('COGS-01', 60), ('COGS-02', 70), ('COGS-03', 80), ('COGS-04', 90), ('COGS-05', 100), ('SUB-GP', 105),
        ('OPX-01', 110), ('OPX-02', 120), ('OPX-03', 130), ('OPX-04', 140), ('OPX-05', 150), ('OPX-06', 160),
        ('OPX-07', 170), ('OPX-08', 180), ('OPX-09', 190), ('OPX-10', 200), ('OPX-11', 210), ('SUB-OPX', 215),
        ('OTH-01', 220), ('SUB-EBITDA', 225), ('BEL-01', 240), ('BEL-04', 245), ('SUB-EBIT', 247),
        ('OTH-02', 250), ('BEL-02', 255), ('SUB-PBT', 257), ('BEL-03', 260), ('SUB-NP', 265), ('ELIM-01', 280),
        ('BS-01', 290), ('BS-02', 300), ('BS-03', 310), ('BS-04', 320), ('BS-05', 330), ('BS-06', 340),
        ('BS-07', 350), ('BS-08', 360), ('BS-09', 370), ('BS-10', 380), ('BS-11', 390)
) AS o (GroupLineCode, ReportOrder)
    ON o.GroupLineCode = g.GroupLineCode
