# Power BI Portfolio

Somewhere to keep the dashboards I build, shown as screenshots with notes on how
each one works.

The report files, the data model and the raw data are not published here. What
you get instead is a walk through each project: what it shows, how it was put
together, and the decisions that went into it.

> Every report is built twice, once in a dark theme and once in a light one. The
> screenshots below follow whichever theme you are reading GitHub in.

---

# HealthStat: elective hip replacement

**26,286** operations · **151** hospitals · **627** surgeons ·
**2.65 days** average stay · **\$20.9K** average cost

New York State publishes a record of every hospital stay. I took one year of it,
kept only the planned hip replacements, and asked one question: which hospitals
are genuinely different from the rest?

That sounds simple until you try it. A hospital with a long average stay might
be doing a poor job. Or it might be taking the sickest patients, who were always
going to stay longer. A raw average cannot tell those two apart.

So the whole report rests on one idea. For each hospital, work out the stay you
would expect given how sick its own patients were. Then compare that against
what actually happened. A hospital that keeps people in longer than its own
patient mix predicts is worth a closer look. One that lands on its prediction is
doing fine, however high its raw average looks.

Six pages follow that thread, from the state as a whole down to a single
hospital.

`Power BI` · `DAX` · `TMDL` · `Deneb / Vega` · `HTML and SVG measures` · `Bookmarks`

## Landing page

<picture>
  <source media="(prefers-color-scheme: light)" srcset="screenshots/healthstat/home-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="screenshots/healthstat/home-dark.webp">
  <img alt="HealthStat home page" src="screenshots/healthstat/home-dark.webp">
</picture>

The whole year in five numbers, then a way into each part of the report. Each
card says what you will find on that page instead of just naming it. One card
leads with the stay gap, another with the markup, another with what the busiest
programmes manage.

## Length of stay

The average stay across the state is 2.65 days. The median is 2. Those two
numbers disagree because a small number of very long stays drag the average up.
That matters: a hospital sitting above the average is not automatically doing
anything wrong. Once you adjust for how sick the patients were, 113 of the 151
hospitals still run longer than they should.

<picture>
  <source media="(prefers-color-scheme: light)" srcset="screenshots/healthstat/los-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="screenshots/healthstat/los-dark.webp">
  <img alt="Length of stay page, ranked hospitals" src="screenshots/healthstat/los-dark.webp">
</picture>

The three longest and three shortest of the 151 hospitals, running from 9.10 days
down to 1.37. Beside each one sits its adjusted score, so you can see at a glance
whether a long stay is explained by sick patients or not. The panel holds three
views and the chips above it switch between them: this ranking, a full table, and
the chart below.

<picture>
  <source media="(prefers-color-scheme: light)" srcset="screenshots/healthstat/los-spread-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="screenshots/healthstat/los-spread-dark.webp">
  <img alt="Length of stay, spread of every patient" src="screenshots/healthstat/los-spread-dark.webp">
</picture>

The third view drops from hospitals down to individual patients. Every operation
in the year, counted by how many nights the patient stayed. Half are home by
night two, yet the average sits at 2.65, and the chart marks both so you can see
the gap for yourself. The 69 stays longer than fourteen nights are gathered into
a final column, kept apart by a dotted line so nobody reads it as night fifteen.

## Cost and charges

Cost per operation runs from \$7.7K to \$84.6K, a spread of eleven times. What a
hospital bills has only a loose connection to what it spends. Across the state
the bill comes to 2.84 times the cost, and individual hospitals sit a long way
either side of that. Some bill barely above cost. Others bill several times it.

<picture>
  <source media="(prefers-color-scheme: light)" srcset="screenshots/healthstat/cost-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="screenshots/healthstat/cost-dark.webp">
  <img alt="Cost and charges page" src="screenshots/healthstat/cost-dark.webp">
</picture>

The same three views as the stay page, applied to money, with the bill-to-cost
ratio alongside. Half of all the billing in the state happens in New York City.

<picture>
  <source media="(prefers-color-scheme: light)" srcset="screenshots/healthstat/cost-spread-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="screenshots/healthstat/cost-spread-dark.webp">
  <img alt="Cost and charges, spread of every operation" src="screenshots/healthstat/cost-spread-dark.webp">
</picture>

Every operation again, this time grouped into \$2,500 price brackets, with
everything above \$50K gathered into the last column. Half of all operations cost
under \$18.6K against a \$20.9K average. The 711 that cost \$50K or more are what
pull the average up.

## Value and efficiency

Does doing more of an operation make a hospital better at it? Only six of the 151
programmes do 600 or more a year, and between them they handle 36% of the state's
work. Those six average 2.42 days against 3.20 at the programmes doing fewer than
200, and they do it for \$2.0K less per patient. The gap holds up after adjusting
for how sick the patients were: 0.92 against 1.20 times the expected stay.

<picture>
  <source media="(prefers-color-scheme: light)" srcset="screenshots/healthstat/value-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="screenshots/healthstat/value-dark.webp">
  <img alt="Value and efficiency page" src="screenshots/healthstat/value-dark.webp">
</picture>

Every hospital plotted as workload against result. The vertical axis switches
between stay, cost, bill-to-cost ratio, operations per surgeon and the adjusted
score.

## Access to care

If the busy programmes really are better, who can get to one? Only 32% of New
Yorkers having this operation do. Three of the eight service areas have no busy
programme at all. Reach runs from 5% of Southern Tier residents up to 45% in New
York City.

<picture>
  <source media="(prefers-color-scheme: light)" srcset="screenshots/healthstat/access-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="screenshots/healthstat/access-dark.webp">
  <img alt="Access to care page" src="screenshots/healthstat/access-dark.webp">
</picture>

A map I drew from scratch, showing where patients live against where they were
treated, shaded by whichever measure is picked above it. The bars beside it break
each region down three ways: how much of its work stays local, how much travels
into the city, and how much goes somewhere else.

## Hospital profile

<picture>
  <source media="(prefers-color-scheme: light)" srcset="screenshots/healthstat/profile-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="screenshots/healthstat/profile-dark.webp">
  <img alt="Hospital profile page" src="screenshots/healthstat/profile-dark.webp">
</picture>

One hospital held up against the state. Its workload and rank, its stay and cost
against what was expected, the mix of patients it takes and where they go
afterwards. The summary written underneath is generated from the numbers, so it
rewrites itself for whichever of the 151 hospitals you pick.
---

## How it is put together

A few words that come up below, in case they are new:

- **Measure**: a calculation Power BI works out on the spot, for whatever is on
  screen at that moment. Change a filter and it recalculates.
- **Column**: a value stored against every row, worked out once when the data
  loads. Because it is stored, you can sort by it, group by it, or click it.
- **Calculated table**: a whole table built by a formula instead of loaded from
  a file.
- **DAX**: the formula language Power BI uses for all of the above.
- **Deneb**: an add-in that lets you draw a chart from scratch when none of the
  built-in ones will do what you want.
- **Cross-filter**: click something in one chart and the rest of the page
  narrows down to match it.

### The data

New York State publishes this data openly. I load one CSV file straight from the
web and cut it down to a single operation as it comes in:

```m
#"Filtered Rows" = Table.SelectRows(
    #"Changed Type",
    each ([ccs_procedure_description] = "HIP REPLACEMENT,TOT/PRT")
)
```

That leaves **26,286 rows and 30 columns, one row per hospital stay**, across 151
hospitals in a single year. The columns fall into five groups:

| Group | Columns |
|---|---|
| Where | service area, county, hospital id and name, operating certificate |
| Who | age group, first three digits of the postcode, gender, race, ethnicity |
| Clinical | diagnosis and procedure codes, severity of illness, risk of death, medical or surgical |
| The stay | how the patient was admitted, where they went afterwards, nights stayed |
| Money | total charges, total costs |

Two things missing from the file shaped the entire report. There is no date more
precise than the year, so there is no trend to plot and I do not pretend
otherwise. And there is nothing tying one patient's stays together, so there is
no readmission rate and no follow-up. The report says what it can say and stops
there.

The demographic columns are in the file but I left them out of the analysis. The
severity and risk-of-death columns do the work of describing how sick each
patient was.

One small thing with large consequences: length of stay is a whole number of
nights. That is why the spread chart is a column per night and not a smooth
curve.

### How the tables fit together

One main table of operations, three lookup tables joined to it, and a handful of
small helper tables joined to nothing at all. There are only three joins in the
entire model:

```
hospital_discharges  ->  surgical_program_size_summary   (by hospital name)
hospital_discharges  ->  Home Region                     (by region)
hospital_discharges  ->  Map County                      (by county)
```

The helper tables sit on their own on purpose. Picking a colour theme or
switching which measure a chart shows should change what you are looking at. It
should never change what is being counted. Leaving those tables unjoined is what
guarantees that.

Three columns are worked out when the data loads, doing jobs the source file
cannot:

```dax
-- Which part of the state the patient lives in, worked out from the first three
-- digits of their postcode. This is what lets the report compare where people
-- live against where they were treated.
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
-- What one operation cost, rounded down into $2,500 brackets and capped, so the
-- top bracket means "$50,000 and above".
Cost Band = MIN ( INT ( hospital_discharges[total_costs] / 2500 ) * 2500, 50000 )
```

### Why some tables are built by formula

This is the rule the whole model turns on:

> A measure can only be shown. A column can be sorted by, grouped by, put on an
> axis, dropped into a slicer, and clicked to filter the page.

So every calculated table in this model exists because something needed to be a
column and was not one yet.

**Hospital summary.** How busy a hospital is belongs to the hospital, not to
whatever filter you happen to have on. Building the table when the data loads
turns workload into a stored column. I can then cut it into size bands (under
200, 200 to 399, 400 to 599, 600 or more) and use those bands to colour the
scatter, fill a slicer, and filter the page on a click. As a measure, programme
size could be displayed and nothing else.

```dax
surgical_program_size_summary =
SUMMARIZECOLUMNS (
    hospital_discharges[facility_name],
    "Total Discharges", [Total Discharges],
    "Total Surgeons",   [Total Surgeons]
)
```

**Driver bands.** The breakdown panel needs every category of every dimension in
one list: severity, risk of death, age, admission type and where the patient went
afterwards. Power BI has a built-in way to switch between fields, but it works by
swapping the column in behind the scenes, which means the column's *name* changes
every time you click. A chart I have laid out by hand needs that name to stay
still. Stacking all five dimensions into one table with fixed column names solves
it, and the dimension label comes along on every row.

**Refresh stamp.** A one-row table holding `NOW()`. Because it is a table, the
clock is read once when the data loads, so the home page can honestly say when
the data was last refreshed. Put the same `NOW()` in a measure and it reports the
time you looked at it, which would always read as this second.

**Theme.** Two rows, dark and light, holding fifteen colours each. Every page
pins one of them with a hidden slicer. That is what lets a single set of hand
written cards serve both versions of the report. Without it I would be
maintaining two reports instead of one.

**The picker tables** (home region, profile metric, access measure) are short
hand-typed lists with a sort order attached. They give a slicer a tidy set of
labels in a sensible order, without opening a path that could filter the main
table by accident. The sort column is there because Power BI otherwise puts them
in alphabetical order, and none of these lists are alphabetical.

**County lookup** carries the map coordinates, which the operations file does not
have.

### Working out the expected stay

This is the calculation the whole report leans on.

Think of it like comparing two schools by exam results. One takes every child in
the area, the other only takes the strongest applicants. Comparing their raw
averages tells you almost nothing. What you want to know is how each school did
against the results its own intake would predict.

Same idea here. Patients are graded by how sick they were on arrival. I work out
the statewide average stay at each severity grade, then rebuild each hospital's
prediction from its own mix of grades:

$$
\text{expected} \;=\; \frac{\sum_{s} n_{s}\,\bar{y}_{s}}{\sum_{s} n_{s}}
\qquad\qquad
\text{score} \;=\; \frac{\text{actual}}{\text{expected}}
$$

Here $n_s$ is how many of that hospital's patients were at severity grade $s$,
and $\bar y_s$ is the statewide average stay for that grade. A score of 1.00
means the hospital landed exactly where its patient mix predicted. 1.20 means
20% longer than predicted.

```dax
Expected LOS Days =
DIVIDE (
    SUMX (
        VALUES ( hospital_discharges[apr_severity_of_illness_description] ),
        VAR vN = [Total Discharges]
        VAR vStateAvg =
            CALCULATE (
                [Average LOS Days],
                -- hold the severity grade, drop the hospital and geography
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

This is cheap to work out once for the state and expensive to work out 151 times
over, once per hospital. Where it got slow I reorganised the calculation. I did
not drop the comparison to make the page faster.

### The numbers behind the cards

There are 183 calculations in the model. 29 of them build HTML, 4 build SVG, 17
return finished sentences for titles and captions, and 15 are just colours. The
arithmetic in most of them is ordinary. The care goes into controlling what each
one is allowed to see.

| On screen | How it is worked out |
|---|---|
| Average stay | total nights, divided by number of operations |
| Median stay | the middle value, shown next to the average because the two disagree |
| Cost per operation | $\dfrac{\sum \text{cost}}{\text{operations}}$ |
| Bill to cost | $\dfrac{\sum \text{charges}}{\sum \text{costs}}$, total over total, not an average of ratios |
| Operations per surgeon | operations, divided by the count of different surgeons |
| Expected stay or cost | $\sum_s n_s \bar y_s \,/\, \sum_s n_s$, as explained above |
| Score | actual, divided by expected |
| Sent home | share of patients whose destination starts with "Home" |
| Above expected | how many hospitals score above 1.00 |
| Busy-programme share | operations at hospitals doing 600 or more a year, over all operations |
| Reach | residents of a region who got to a busy programme, over all residents of that region |
| Price bracket | $\min\!\left(2500\left\lfloor \tfrac{\text{cost}}{2500} \right\rfloor,\; 50000\right)$ |

One calculation is not ordinary. On the scatter chart I wanted to flag hospitals
sitting well off the trend. The usual way to do that is to measure how far each
point is from the line in standard deviations. The trouble is that the few
extreme points inflate the standard deviation, so they end up hiding inside their
own effect on the yardstick.

The fix is to measure the spread using the middle of the pack instead of the
average. So I fit the trend line, then judge each gap against the typical gap
rather than the average one:

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

The comment I left in the model is the honest one: this refits the trend line
once for every point the chart draws. At 151 hospitals that is fine. On a bigger
dataset it would need rebuilding as a table.

There is a second guard running through the report. Any calculation that names a
best or worst hospital first throws out the hospitals with fewer than 50
operations:

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

Thirteen calculations pick out a top or bottom hospital, and all thirteen use the
same cut-off. They have to. Without it, a hospital that did four operations tops
the ranking, and the sentence under the card ends up naming a different worst
hospital from the card itself.

### The charts I drew myself

Most of the report uses the charts that come with Power BI. Four things needed
more control than those allow, so I drew them from scratch using Deneb.

Deneb lets you write a chart specification by hand. I used the fuller of its two
languages, Vega, because these charts need to react to clicks, build several
working datasets on the way, and place things at exact pixel positions. The
simpler language cannot do that.

The stay chart is a good example. It gets only two fields from the model, the
night count and the operation count, and works everything else out for itself.
Gathering the long stays into one final column is a filter and a total. The
average is taken before that gathering happens, so folding the tail cannot shift
it:

```js
// clean rows, plus the pieces the true average needs, taken BEFORE the fold
{ name: 'raw', source: 'dataset', transform: [
    { type: 'formula', as: 'wt', expr: "datum['length_of_stay'] * datum['Total Discharges']" } ] },
{ name: 'stat', source: 'raw', transform: [
    { type: 'aggregate', fields: ['wt', 'Total Discharges'], ops: ['sum','sum'], as: ['wsum','nsum'] } ] },

// nights 1 to 14 keep their own row, so each column still carries a real night
// count and can filter the page on a click
{ name: 'body', source: 'raw', transform: [
    { type: 'filter', expr: "datum['length_of_stay'] <= 14" } ] },
{ name: 'tailAgg', source: 'raw', transform: [
    { type: 'filter', expr: "datum['length_of_stay'] > 14" },
    { type: 'aggregate', fields: ['Total Discharges'], ops: ['sum'], as: ['n'] } ] },
```

Clicking a column filters the rest of the page, which is the difference between
a chart and a picture. A normal column sends out the value it stands for. The
gathered column covers a whole range of nights, so it sends out a condition
instead:

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

The cost chart works the same way, except its price brackets are worked out when
the data loads instead of inside the chart. Doing the grouping inside the chart
would leave every bar as a drawing with no real value behind it, and nothing for
a reader to click.

A few things only showed up once it was on screen. The average and median markers
had to be drawn behind the bars, so each one drops from its own label down into
the column it marks. The average marker also had to be a different colour from
the bars, because my first attempt was invisible wherever it crossed one. And the
count above each bar moves inside the bar when the bar is tall enough to hold it:

```js
// label sits inside the column when there is room, above it when there is not
y:    { signal: "scale('y', datum.n) + (scale('y',0) - scale('y',datum.n) > 24 ? 15 : -7)" },
fill: { signal: "scale('y',0) - scale('y',datum.n) > 24 ? '#06211F' : '#7B93A3'" },
```

### Cards and sentences that write themselves

The big number cards are not the ones Power BI provides. Each one is a single
calculation that returns web page markup, which a viewer then draws. That gives
exact control over the layout, and it lets one card serve both the dark and the
light report, because it looks its colours up in the theme table instead of
having them typed in:

```dax
HTML Hero LOS =
VAR cInk = [Theme Ink]          -- every colour is looked up, never typed in
VAR vAvg = [Average LOS Days]
VAR vMin = [Min Facility LOS]
VAR vMax = [Max Facility LOS]
-- if only one hospital is selected this works out as 0 divided by 0, and a
-- blank width prints as the literal text "%" in the markup
VAR vPct = COALESCE ( ROUND ( 100 * DIVIDE ( vAvg - vMin, vMax - vMin ), 1 ), 0 )
RETURN
"<div style='font-family:Arial,Helvetica,sans-serif'>" &
  "<span style='font-size:56px;font-weight:700;color:" & cInk & "'>" &
      FORMAT ( vAvg, "0.00", "en-US" ) & "</span>" &
  "<span style='...;padding:0 0 7px 7px'>days</span>" &
  -- the slider knob is 18px wide, so it can only travel the track minus its own
  -- width. Without that allowance it hangs off the end at 100%
  "<div style='position:absolute;width:18px;height:18px;border-radius:50%;" &
    "background:" & cInk & ";left:calc(" &
      FORMAT ( DIVIDE ( vPct, 100 ), "0.0000", "en-US" ) & " * (100% - 18px))'></div>" &
"</div>"
```

The written summaries work the same way. Nothing on screen is typed in by hand.
Every hospital name, every figure and the sentence wrapped around them are worked
out live, so they stay correct whatever you have filtered to. They also know when
the usual sentence would stop making sense and write a different one:

```dax
VAR vFac =
    -- the same set of hospitals the card above it uses
    FILTER ( VALUES ( hospital_discharges[facility_name] ),
             [Total Discharges] >= [Min Volume] )
VAR vN = COUNTROWS ( vFac )
RETURN
    IF ( COALESCE ( vN, 0 ) = 0, "",     -- nothing selected, so say nothing
    IF ( vN <= 1, vSingle,               -- one hospital, so there is no spread
                  vCohort ) )            -- the normal sentence
```

The same calculation trims the formal ending off hospital names, so the sentence
reads the way a person would write it instead of the way the file spells it.

Numbers size themselves too. The same calculation prints 847, 12.4K, 3.1M or
1.2B depending on how big it turns out, so one card reads properly whether you
are looking at a single hospital or the whole state.

### Calls I had to make

**A cut-off, with a reason behind it.** Breakdown groups with fewer than 50
patients are left blank. I did not pick 50 because it looked tidy. I checked it
against the data: it sits below the smallest groups that are clinically real,
while cutting out groups of fifteen or twenty patients that would otherwise top
every ranking on noise alone.

**No trend charts.** The file covers one year, with nothing finer than the year
inside it. I could have invented a time axis. Instead the report states plainly
that every figure is a snapshot.

**Clicks that go one way.** The two spread charts react to slicers and to other
charts, but clicking them does not filter outward. On a page where everything is
a function of length of stay, sending a length-of-stay filter back out would pin
the one thing the page is trying to show you and flatten every other chart on it.

## A note on what is published

The data is public and anonymous at source. No record identifies a patient. The
report file, the data model and the source extract are not published in this
repository. The code above is shown in pieces, in context, to explain the
thinking. It is not here to be downloaded and run.
