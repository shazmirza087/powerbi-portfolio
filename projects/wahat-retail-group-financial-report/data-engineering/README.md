# Wahat Retail Group Financial Report: the data engineering side

[Back to the portfolio](../../../README.md) · [Project overview](../README.md) · [The Power BI side](../power-bi/README.md)

**A little data factory that takes 14.4 million messy money lines and turns them into clean, checked, report-ready tables. On every run, it proves its own numbers are right.**

---

## The business

**Wahat Retail Group** is a family of grocery businesses:

- about **110 grocery shops in Saudi Arabia** (*Grocery*),
- an **online grocery shop** it bought on 1 April 2024 (*Online*),
- a **franchise of shops in Bahrain** (*Bahrain*).

The boss wants **one profit and loss report for the whole group, in Saudi riyals**. He also wants to know the **true profit of every single shop**.

## The data

Three years of data, 2023 to 2025, delivered as 18 files:

- **14,431,784 lines from the money diary** (the general ledger). Every riyal in or out.
- **2,237,680 till records**: what each shop sold, each day, per aisle.
- **Three different lists of accounts**, one from each business's accounting system: 272, 98 and 99 accounts.
- **The budget**, **exchange rates**, and lists of **shops, cost centres, aisles and dates**.
- **A rule book** that says how every account should be counted.
- **The signed-off totals for 2023 and 2024.** These are the answers the accountants already agreed on.

## The challenge

Imagine three kids who each keep a money diary, but in **different notebooks, with different labels, and one of them counts in a different currency**. Now someone asks: "How much did all three of you spend on sweets?"

That is this project.

- **There is no matching list.** Nobody says "account 6100 in this book is the same as account 600000 in that book". The only clue is a rule book written in sentences, and two of its rules contradict each other.
- **Some rules only apply between certain dates.** The same account means one thing before a date and another thing after it.
- **Old shop codes get reused.** When a shop closes, a new shop can take over its cost code. If you only look at today's list, you blame the new shop for the old shop's bills.
- **Bahrain counts in dinars.** Its amounts have to be turned into riyals at each month's rate.
- **The budget has its plus and minus signs the other way round.**
- **It's big.** 14.4 million lines is too much to sort out every time someone opens a report.
- **And it has to be right.** If the rebuilt 2023 and 2024 numbers don't match what the accountants signed, nothing else matters.

---

## What I built, and why

### The big idea: a kitchen with three counters

I built it the way a good kitchen works. This is called a **medallion** design, with Bronze, Silver and Gold layers.

| Counter | What happens there | Kitchen version |
|---|---|---|
| **Bronze** | The 18 files land exactly as they arrived, with a note of when they came in | Groceries put away just as they came from the shop |
| **Silver** | Everything is cleaned, labelled and matched up. All 14.4 million lines get sorted into the right group line and the right shop | Washed, chopped, sorted into bowls |
| **Gold** | Tables shaped exactly the way the report needs them, all in riyals | The meal on the plate |

At the end, the Gold tables are **handed to Power BI** as simple files.

<img alt="Medallion architecture: raw files to Bronze, Silver, Gold and Power BI, run by a control layer" src="images/medallion-architecture.png" width="900">

**Why:** if something goes wrong, you know which counter it went wrong on. You can also cook a different meal (a new report) from the same chopped ingredients without going back to the shop.

### 1. One recipe card per job, not one giant program

Every job the pipeline does is **one row in a control table**. Think of it as a list of recipe cards. Each card says:
- what to load,
- where it goes,
- what it has to wait for,
- how many times to retry if it hiccups.

There are 51 cards. Each "cook" (a loader notebook) knows how to handle one type of card. Every change is **a plain SQL query**.

**Why:** adding a new table means adding one card and one small SQL file. You don't write a new program. This is the same pattern big companies use on Databricks, so it can move to the cloud with almost no changes.

### 2. It turns the rule book into a matching table

All the rules from the rule book became **rows in a matching table**: "accounts from here to here, in this business, between these dates, go to this group line".

**Why:** when finance changes a rule, you **edit a row, not the code**. Finance can also read the table and sign it off, because it's just a list.

### 3. It finds the right shop for every bill, on the right day

A separate history table says **which shop owned each cost code on each date**. Every money line gets matched to the shop that was really there that day.

**Why:** that is the only way to get the **true** profit of each shop. It is the whole point of the boss's second question.

### 4. It remembers how shops change over time

When a shop changes (gets bigger, changes type, or closes), the pipeline **doesn't overwrite the old version**. It closes the old version and opens a new one. It works like a photo album: you can always flip back and see what a shop looked like last year. Data people call this **SCD Type 2**.

**Why:** last year's numbers should stay last year's numbers, even after a shop is changed today.

### 5. It only does the new homework

After the first full load (about 3 minutes on a laptop), each run **only picks up what's new**:
- **Bronze** adds only the new diary lines and till records.
- **Silver** merges in only those new rows. Running it twice changes nothing.
- **Gold** rebuilds only the days that got new data.

I tested it by feeding it the data in pieces. First everything up to November 2025, then December, with one shop changed and one shop removed. The second run:
- picked up only the new rows,
- spotted the changed shop and the removed shop,
- rebuilt only December,
- and gave **exactly the same answer** as loading everything from scratch.

A third run with nothing new **changed nothing**.

**Why:** fast runs, small bills, and the same answer every time.

### 6. It checks its own homework and refuses to hand in a wrong answer

Two checks run in Silver, before any report table is touched:

1. **Did every one of the 14.4 million lines get sorted?** If even one line has no home, the run stops.
2. **Do the rebuilt 2023 and 2024 numbers match the 25 signed-off totals?** If any one is off by more than one unit, the run stops.

Today: **25 out of 25 match, and 100% of lines are sorted.**

If a check fails, the report keeps showing the last good data. A bad run **never** overwrites good numbers.

**Why:** this is the difference between "I think it's right" and "I can prove it's right".

### 7. It keeps a diary of every run

Every job writes to a **run log**: started, finished, failed, retried, how long it took and how many rows it wrote. One small report shows the latest run, the slowest jobs, and the full error message for anything that broke.

**Why:** when something breaks at 3 a.m., the log says what broke and why. Nobody has to guess.

### 8. The hard work happens here, so the report stays simple

By the time the data reaches Power BI:
- every line is already matched to its group line,
- every bill is already on the right shop,
- the dinars are already riyals,
- the budget signs are already the right way round,
- and the data is **daily**, so the report can be viewed by day, week, month, quarter or year.

The 14.4 million diary lines are squeezed into about **6 million daily rows**. That keeps every detail the report needs and nothing it doesn't.

**Why:** Power BI just adds things up, which is fast. The tricky logic lives in one place you can test, not scattered across fifty report formulas.

### Under the hood (for the techies)

- **Tools:** PySpark and Delta Lake, running locally in Jupyter. The same notebooks and SQL run on Databricks or Microsoft Fabric.
- **Layers:** Bronze (18 tables plus delivery history), Silver (16 tables plus 2 checks), Gold (15 tables built from plain SQL, refreshed in full or one day at a time).
- **Load types:** incremental append, snapshot history, incremental MERGE, SCD Type 1, SCD Type 2. Change Data Feed is on for every table.
- **Orchestration:** jobs run in waves based on what they depend on, four at a time, with retries. A job whose input failed is skipped, not run.
- **Environments:** dev and prod data are kept in separate folders. Every path is a setting, nothing is hard-coded.

---

## What you get, in one breath

You get a pipeline that takes messy data from three systems and turns it into one clean set of numbers. It proves the numbers against the signed-off accounts on every run, and it only does the new work each time. Adding a table is one row and one SQL file, and it can move to the cloud as it is.

If your data lives in more than one system and your finance team keeps asking "but is this number right?", **this is exactly the kind of thing I build.**
