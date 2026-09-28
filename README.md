# Power BI Portfolio

Dashboards and semantic models, presented as screenshots and build notes.

Report files, semantic models, DAX and datasets are deliberately not published
here. Each project is written up as a case study — the modelling decisions, the
measures behind the visuals, and the trade-offs made along the way — alongside
screenshots of the working report.

> Every report is built in a dark and a light theme. The screenshots below
> follow whichever theme you are reading GitHub in.

---

# HealthStat — elective hip replacement

**26,286** discharges · **151** facilities · **627** surgeons ·
**2.65 days** average stay · **\$20.9K** average cost

Six report pages over every elective total and partial hip replacement
discharged from a New York State hospital in a single year, built around one
question: once you account for how sick the patients are, which hospitals are
actually different?

Raw averages make hospitals look different when mostly they are treating
different patients. The spine of the report is a severity-adjusted comparison:
every facility is scored against the stay and cost its own case mix predicts,
so the pages can separate hospitals that are genuinely outliers from those that
simply admit sicker people.

`Power BI` · `DAX` · `TMDL` · `Deneb / Vega` · `HTML & SVG measures` · `Bookmarks`

## Landing page

<picture>
  <source media="(prefers-color-scheme: light)" srcset="docs/healthstat/img/home-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="docs/healthstat/img/home-dark.webp">
  <img alt="HealthStat home page" src="docs/healthstat/img/home-dark.webp">
</picture>

The cohort in five numbers, then a route into each area of the report. Each card
carries its own headline finding rather than a label alone — the stay gap, the
markup, the volume dividend.

## Length of stay

The state average stay is 2.65 days and the median is 2. That gap is the page's
first point: the mean is pulled up by a thin tail, so a facility sitting above
it is not automatically doing anything wrong. 113 of 151 facilities run above
the stay their case mix predicts.

<picture>
  <source media="(prefers-color-scheme: light)" srcset="docs/healthstat/img/los-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="docs/healthstat/img/los-dark.webp">
  <img alt="Length of stay page, ranked facilities" src="docs/healthstat/img/los-dark.webp">
</picture>

Three highest and three lowest of 151 facilities — 9.10 days down to 1.37 —
with the severity-adjusted ratio behind it, so a long stay explained by case mix
reads differently from one that is not. The panel holds three views behind the
chips: this ranking, the full matrix, and the distribution below.

<picture>
  <source media="(prefers-color-scheme: light)" srcset="docs/healthstat/img/los-spread-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="docs/healthstat/img/los-spread-dark.webp">
  <img alt="Length of stay, distribution view" src="docs/healthstat/img/los-spread-dark.webp">
</picture>

The third view, at patient grain rather than facility grain — a custom Vega
histogram of every discharge by nights stayed. Half are home by night two, but
the mean sits at 2.65, and the chart marks both so the gap is visible rather
than asserted. The 69 stays past fourteen nights fold into a final column,
separated by a dotted rule so it cannot be misread as a fifteenth night.

## Cost and charges

Cost per discharge runs from \$7.7K to \$84.6K — an eleven-fold spread. What a
hospital bills tracks what it spends only loosely: the statewide markup is
2.84×, and individual facilities sit a long way either side of it — some
billing barely above cost, others several times it.

<picture>
  <source media="(prefers-color-scheme: light)" srcset="docs/healthstat/img/cost-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="docs/healthstat/img/cost-dark.webp">
  <img alt="Cost and charges page" src="docs/healthstat/img/cost-dark.webp">
</picture>

The same three-view panel applied to cost, with charge-to-cost ratio alongside.
Half of all charges land in New York City.

<picture>
  <source media="(prefers-color-scheme: light)" srcset="docs/healthstat/img/cost-spread-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="docs/healthstat/img/cost-spread-dark.webp">
  <img alt="Cost and charges, distribution view" src="docs/healthstat/img/cost-spread-dark.webp">
</picture>

The same idea applied to cost, in \$2.5K bands with everything above \$50K capped
into the last column. Half of all discharges cost under \$18.6K against a \$20.9K
mean — 711 of them cost \$50K or more, and those are what move the average. The
banding is a calculated column rather than something the chart does, so each bar
remains a real value of a real field.

## Value and efficiency

Does doing more of an operation make a hospital better at it? Only six of 151
programmes do 600 or more a year, and they handle 36% of the state's volume.
Those programmes average 2.42 days against 3.20 at programmes under 200, and do
it \$2.0K cheaper per discharge — and the gap survives severity adjustment, at
0.92× expected stay against 1.20×.

<picture>
  <source media="(prefers-color-scheme: light)" srcset="docs/healthstat/img/value-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="docs/healthstat/img/value-dark.webp">
  <img alt="Value and efficiency page" src="docs/healthstat/img/value-dark.webp">
</picture>

Every facility plotted as caseload against outcome, with the measure on the
vertical axis switchable between stay, cost, charge-to-cost, throughput per
surgeon and the severity-adjusted ratio.

## Access to care

If high-volume programmes really are better, who can reach one? Just 32% of New
York residents having this operation do. Three of the eight service areas have
no high-volume programme at all, and the spread runs from 5% of Southern Tier
residents to 45% in New York City.

<picture>
  <source media="(prefers-color-scheme: light)" srcset="docs/healthstat/img/access-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="docs/healthstat/img/access-dark.webp">
  <img alt="Access to care page" src="docs/healthstat/img/access-dark.webp">
</picture>

A custom Vega choropleth of home region against hospital location, shaded by the
measure selected above it. The bars beside it show, for each region, how much of
its volume stays home, how much travels into the city, and how much goes
elsewhere.

## Hospital profile

<picture>
  <source media="(prefers-color-scheme: light)" srcset="docs/healthstat/img/profile-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="docs/healthstat/img/profile-dark.webp">
  <img alt="Hospital profile page" src="docs/healthstat/img/profile-dark.webp">
</picture>

One facility against the state — volume and rank, stay and cost against
expected, case mix and discharge destination. The written summary underneath is
generated from the measures, so it re-resolves for whichever of the 151
facilities is selected.

---

## How it is built

### The data

New York State SPARCS de-identified inpatient discharge data, public at source,
loaded straight from one CSV and filtered in Power Query to a single procedure:

```m
#"Filtered Rows" = Table.SelectRows(
    #"Changed Type",
    each ([ccs_procedure_description] = "HIP REPLACEMENT,TOT/PRT")
)
```

That leaves **26,286 rows and 30 columns — one row per inpatient stay**, across
151 facilities and a single discharge year. The columns fall into five families:

| Family | Columns |
|---|---|
| Where | health service area, hospital county, facility id and name, operating certificate |
| Who | age group, 3-digit ZIP, gender, race, ethnicity |
| Clinical | CCS diagnosis and procedure, APR-DRG, APR-MDC, severity of illness, risk of mortality, medical/surgical |
| Pathway | type of admission, patient disposition, length of stay in nights |
| Money | total charges, total costs |

Two things the extract does **not** contain shaped the whole report. There is no
date finer than the year, so there is no trend to analyse. And there is no
patient key, so there is no readmission, no journey and no outcome beyond
discharge disposition. The demographic columns exist but are deliberately left
out of the analysis; severity and risk of mortality carry the case-mix work
instead.

Length of stay is an integer count of nights, which is why the distribution view
is a histogram over whole numbers rather than a density curve.

### The model

One fact table, three related dimension tables, and a set of deliberately
**disconnected** helper tables. Only three relationships exist in the whole
model:

```
hospital_discharges[facility_name]    →  surgical_program_size_summary[facility_name]
hospital_discharges[Patient Region]   →  'Home Region'[Region]
hospital_discharges[hospital_county]  →  'Map County'[Data County]
```

Everything else — the theme palette, the metric pickers, the driver band list —
is joined to nothing on purpose, so selecting in it changes what a visual *shows*
without changing what the page *counts*.

**Three calculated columns** do work the source file could not — `Age Bins`
collapses the age groups to a single over/under-50 split, and these two:

```dax
-- Home region of the patient, from the 3-digit ZIP, so "where they live"
-- can be compared against "where they were treated"
Patient Region =
VAR z = hospital_discharges[zip_code_3_digits]
RETURN
SWITCH (
    TRUE (),
    z = "OOS", "Out of state",
    z IN { "100", "101", "102", "103", "104", "111", "112", "113", "114", "116" }, "New York City",
    z IN { "105", "106", "107", "108", "109", "124", "125", "126", "127" },        "Hudson Valley",
    ...
    "Unknown"
)
```

```dax
-- What one discharge costs, floored into $2,500 bands and capped, so the top
-- band means "$50,000 and above". Evaluated once, at refresh.
Cost Band = MIN ( INT ( hospital_discharges[total_costs] / 2500 ) * 2500, 50000 )
```

#### Why calculated tables

The rule the whole model turns on: **a measure can be displayed, but only a
column can be grouped by, sorted on, placed on an axis, put in a slicer, or
clicked to cross-filter the page.** Every calculated table here exists because
something needed to be a real column.

| Table | What it is | Why it had to be a table |
|---|---|---|
| `surgical_program_size_summary` | `SUMMARIZECOLUMNS` of facility → discharges, surgeons | Programme size is a property of the *facility*, not of the current filter. Materialised at refresh it becomes a real column that can be binned (200-wide) and banded into `<200 / 200–399 / 400–599 / ≥600` — a dimension the value page slices, colours and cross-filters on. As a measure it could be shown and nothing more. |
| `Driver Bands` | `UNION` of five `SELECTCOLUMNS`, giving every *(dimension, category)* pair as `Group` / `Band` | A field parameter substitutes the referenced column at query time, so the dataset column **name** changes with the slicer — and a hand-laid-out Vega spec needs a stable name. Here `Group` and `Band` are ordinary columns with fixed names, and the dimension label is available per row rather than through `SELECTEDVALUE`. Being disconnected, it also cannot filter the page from underneath the comparison it is describing. |
| `Refresh Stamp` | `ROW ( "Stamp", NOW () )` | A calculated table is evaluated at refresh, so the landing page can honestly say when the data was **loaded**. The same expression in a measure reports query time — which is to say, always "now", which is a lie. |
| `Theme` | 15 colour tokens × 2 rows (Dark, Light) | Each page pins it with a hidden single-select slicer, so one set of HTML and SVG measures serves both the dark and the light page sets. Without it the report would be two reports. |
| `Break down by`, `Compare by` | Field parameters (`NAMEOF`) | Let one visual switch between five measures or four dimensions without five copies of the visual and five bookmarks holding them. |
| `Home Region`, `Profile Metric`, `Access Measure` | `DATATABLE` literals with an explicit sort order | Ordered, stable labels for "what should this visual show", with no filter path into the fact table. The order column is what stops Power BI alphabetising a sequence that is not alphabetical. |
| `Map County` | County → region lookup with lat/long and a `County` data category | Gives the choropleth a geography to bind to that the discharge table does not carry. |

### Severity adjustment

Expected stay and expected cost come from **indirect standardisation**: score
every facility against the statewide figure for its *own* severity mix, then
compare what actually happened to that.

$$
E_f \;=\; \frac{\sum_{s} n_{f,s}\,\bar{y}_{s}}{\sum_{s} n_{f,s}}
\qquad\qquad
\mathrm{O{:}E}_f \;=\; \frac{\bar{y}_f}{E_f}
$$

where $n_{f,s}$ is facility $f$'s discharges at severity level $s$, and
$\bar{y}_s$ is the statewide mean for that severity level. An O:E of 1.00 means
"exactly what this case mix predicts"; 1.20 means twenty per cent longer than
predicted.

```dax
Expected LOS Days =
DIVIDE (
    SUMX (
        VALUES ( hospital_discharges[apr_severity_of_illness_description] ),
        VAR vN = [Total Discharges]
        VAR vStateAvg =
            CALCULATE (
                [Average LOS Days],
                -- hold the severity level put by context transition,
                -- strip the facility and every geography filter
                ALLEXCEPT ( hospital_discharges,
                            hospital_discharges[apr_severity_of_illness_description] ),
                REMOVEFILTERS ( surgical_program_size_summary ),
                REMOVEFILTERS ( 'Home Region' ),
                REMOVEFILTERS ( 'Map County' )
            )
        RETURN vN * vStateAvg
    ),
    [Total Discharges]
)

LOS O to E Ratio = DIVIDE ( [Average LOS Days], [Expected LOS Days] )
```

> Cheap evaluated once for the state, ruinous evaluated per facility across 151
> rows. Where that bit, the aggregation was restructured rather than the visual
> simplified.

### The measures behind the KPIs

183 measures, of which 29 build HTML, 4 build SVG, 17 return formatted strings
for titles and captions, and 15 are colour tokens. The arithmetic underneath is
mostly ordinary — the work is in what each one is allowed to see.

| On screen | Formula |
|---|---|
| Average stay | $\bar{y} = \dfrac{1}{n}\sum_i \mathrm{los}_i$ |
| Median stay | 50th percentile of nights — reported beside the mean precisely because they disagree |
| Cost per discharge | $\dfrac{\sum_i \mathrm{cost}_i}{n}$ |
| Charge : cost | $\dfrac{\sum_i \mathrm{charges}_i}{\sum_i \mathrm{costs}_i}$ — a ratio of sums, not a mean of ratios |
| Discharges per surgeon | $\dfrac{n}{\lvert \{\text{operating provider}\} \rvert}$ |
| Expected stay / cost | $\sum_s n_s \bar{y}_s \,/\, \sum_s n_s$ |
| O : E ratio | observed $/$ expected |
| % home at discharge | share of discharges whose disposition begins "Home" |
| Above expected | $\lvert \{f : \mathrm{O{:}E}_f > 1\} \rvert$ |
| High-volume share | discharges at facilities doing $\geq 600$ a year $/$ all discharges |
| Access | residents of a region reaching a $\geq 600$ programme $/$ residents of that region |
| Cost band | $\min\!\left(2500\left\lfloor \tfrac{\mathrm{cost}}{2500} \right\rfloor,\; 50000\right)$ |

The one that is not ordinary is the scatter's outlier test. It fits the
volume–outcome trend by least squares on $\log_{10}$ of caseload, then
standardises the residuals on **median and MAD** rather than mean and standard
deviation — because the outliers being looked for are exactly what would inflate
a standard deviation and hide themselves:

$$
\hat{y}_i = a + b\log_{10} n_i
\qquad
r_i = y_i - \hat{y}_i
\qquad
z_i = \frac{0.6745\,\bigl(r_i - \mathrm{med}(r)\bigr)}{\mathrm{MAD}(r)}
$$

```dax
VAR vRes = ADDCOLUMNS ( vFit, "@r", [@y] - ( vA + vB * [@x] ) )
VAR vMed = MEDIANX ( vRes, [@r] )
VAR vMAD = MEDIANX ( vRes, ABS ( [@r] - vMed ) )
RETURN
    IF (
        vN < 10 || vMAD = 0 || COALESCE ( vThisN, 0 ) < vMinN,
        BLANK (),
        DIVIDE ( 0.6745 * ( ( vThisY - ( vA + vB * LOG10 ( vThisN ) ) ) - vMed ), vMAD )
    )
```

> The comment left in the model is the honest one: this re-fits the line for
> every point the scatter draws, so it is O(n²) over facilities. At 151 that is
> fine; on a larger cohort it would want a calculated table instead.

A second kind of guard runs through the ranked measures — a **minimum volume
floor**, applied identically everywhere a facility is named as best or worst:

```dax
Min Volume = 50

Max Facility LOS =
CALCULATE (
    MAXX (
        FILTER ( VALUES ( hospital_discharges[facility_name] ),
                 [Total Discharges] >= [Min Volume] ),
        [Average LOS Days]
    ),
    ALL ( hospital_discharges[facility_name] ),
    REMOVEFILTERS ( surgical_program_size_summary )
)
```

Thirteen measures take extremes or ranks over facilities, and all thirteen apply
the same floor. They have to: a written banner naming a different worst hospital
from the card directly above it is worse than no banner at all.

### The custom visuals

#### Deneb — Vega, not Vega-Lite

The distribution views, the region map and the range tracks are hand-written Vega
specs. Vega rather than Vega-Lite because these need signals, multiple derived
datasets and explicit pixel geometry — none of which Vega-Lite exposes.

The histogram projects **two fields only**, `length_of_stay` and
`Total Discharges`, and derives everything else in the spec. Folding the tail is
a `filter` plus an `aggregate`, and the mean is taken from the *unfolded* data so
the fold cannot bias it:

```js
// clean rows, plus the weighted pieces the true mean needs —
// taken BEFORE the fold, so folding the tail cannot bias it
{ name: 'raw', source: 'dataset', transform: [
    { type: 'formula', as: 'wt', expr: "datum['length_of_stay'] * datum['Total Discharges']" } ] },
{ name: 'stat', source: 'raw', transform: [
    { type: 'aggregate', fields: ['wt', 'Total Discharges'], ops: ['sum','sum'], as: ['wsum','nsum'] } ] },

// nights 1..14 keep their own row, so each column's datum still carries
// length_of_stay and can cross-filter on it directly
{ name: 'body', source: 'raw', transform: [
    { type: 'filter', expr: "datum['length_of_stay'] <= 14" } ] },
{ name: 'tailAgg', source: 'raw', transform: [
    { type: 'filter', expr: "datum['length_of_stay'] > 14" },
    { type: 'aggregate', fields: ['Total Discharges'], ops: ['sum'], as: ['n'] } ] },
```

Cross-filtering is what makes it a visual rather than a picture. A normal column
emits the value it stands for; the folded column stands for a *range*, so it
emits a literal predicate instead:

```js
{ name: 'tailExpr', value: "datum['length_of_stay'] > 14" },
{ name: 'pbiCrossFilterSelection', value: [], on: [
  { events: { source: 'scope', type: 'mouseup', markname: 'data-point' },
    update: "pbiCrossFilterApply(event, \"datum['length_of_stay'] == _{length_of_stay}_\")" },
  { events: { source: 'scope', type: 'mouseup', markname: 'tail-point' },
    update: "pbiCrossFilterApply(event, tailExpr)" },
  { events: { source: 'view', type: 'mouseup',
              filter: ["!event.item || event.item.mark.name != 'data-point'"] },
    update: "pbiCrossFilterClear()" } ] },
```

The cost histogram works the same way, except that its banding is a calculated
column rather than something the spec does. Folding a tail inside the chart
would make it a picture; folding it in the model keeps every bar a real value of
a real field, which is the only thing a reader can click.

Small decisions that only show up once it is on screen: the median and mean
markers are drawn **behind** the bars so each descends from its label into the
column it marks; the mean marker is deliberately *not* the bars' own hue, because
the first version was invisible where it crossed one; and a count label moves
inside its bar when the bar is tall enough to hold it.

```js
// label sits inside the column when there is room, above it when there is not
y:    { signal: "scale('y', datum.n) + (scale('y',0) - scale('y',datum.n) > 24 ? 15 : -7)" },
fill: { signal: "scale('y',0) - scale('y',datum.n) > 24 ? '#06211F' : '#7B93A3'" },
```

#### HTML and SVG measures

The KPI heroes and tiles are not native cards. Each is a single DAX measure that
returns markup, rendered by an HTML Content visual — which buys exact control
over layout, and lets the same measure serve both themes by reading its colours
from the `Theme` table instead of hard-coding them.

```dax
HTML Hero LOS =
VAR cInk    = [Theme Ink]          -- every colour is a token, never a literal
VAR vAvg    = [Average LOS Days]
VAR vMin    = [Min Facility LOS]
VAR vMax    = [Max Facility LOS]
-- COALESCE: a one-facility cohort makes this 0/0, and a blank width
-- renders as the literal string "%" in the markup
VAR vPct    = COALESCE ( ROUND ( 100 * DIVIDE ( vAvg - vMin, vMax - vMin ), 1 ), 0 )
RETURN
"<div style='font-family:Arial,Helvetica,sans-serif'>" &
  "<span style='font-size:56px;font-weight:700;color:" & cInk & "'>" &
      FORMAT ( vAvg, "0.00", "en-US" ) & "</span>" &
  "<span style='...;padding:0 0 7px 7px'>days</span>" &
  -- the thumb is 18px wide, so its travel is the track minus its own width;
  -- without the clamp it overhangs the end of the track at 100%
  "<div style='position:absolute;width:18px;height:18px;border-radius:50%;" &
    "background:" & cInk & ";left:calc(" &
      FORMAT ( DIVIDE ( vPct, 100 ), "0.0000", "en-US" ) & " * (100% - 18px))'></div>" &
"</div>"
```

The same approach writes the prose. Insight banners are measures that resolve
names, figures and the sentence around them under whatever filter is live, and
rewrite themselves when a selection would make the usual sentence nonsense:

```dax
VAR vFac =
    -- the same population the KPI card and the ranked chart use
    FILTER ( VALUES ( hospital_discharges[facility_name] ),
             [Total Discharges] >= [Min Volume] )
VAR vN = COUNTROWS ( vFac )
RETURN
    IF ( COALESCE ( vN, 0 ) = 0, "",        -- nothing in scope: say nothing
    IF ( vN <= 1, vSingle,                  -- one facility: no "spread" to report
                  vCohort ) )               -- the normal sentence
```

Facility names are trimmed of their house style in the same measure, so the
sentence reads the way a person would write it rather than the way the source
file spells it.

### Nothing on screen is typed twice

- **All text is measure-driven.** Titles, subtitles, insight sentences and tile
  footnotes are DAX. Every number and every hospital name in prose re-resolves
  under a filter instead of going stale.
- **Display units follow magnitude.** Figures switch between plain, K, M and B
  by size rather than carrying a fixed suffix, so the same measure reads
  correctly for one hospital or the whole state.
- **Sentences are guarded.** A selection that collapses a comparison rewrites
  the sentence rather than printing a degenerate one.

### Judgement calls worth naming

- **A noise floor, with a reason.** Breakdown bands under 50 discharges are
  blanked. The threshold was set against the data rather than picked: it sits
  below the smallest clinically real groups while excluding bands of fifteen or
  twenty patients that would otherwise top every ranking on delta alone.
- **No trend analysis, deliberately.** The extract carries a single discharge
  year. Rather than manufacture a time axis, the report states that every figure
  is a snapshot — a constraint named is better than a trend implied.
- **Interactions are chosen, not defaulted.** The distribution charts respond to
  slicers and to other visuals but do not filter outward: on a page where every
  measure is a function of stay length, emitting a filter on stay length would
  pin the variable and flatten the page.

## A note on what is published

The dataset is public and de-identified at source; no record identifies an
individual. The report definition, semantic model and source extract are not
published in this repository — the code above is shown as excerpts, in context,
rather than as files to download.
