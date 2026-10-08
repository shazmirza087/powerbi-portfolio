# Power BI Portfolio

Reports I have built in Power BI, each with its own write-up on how it is
engineered: the model, the measure layer, the visuals, and the decisions
behind them.

Only screenshots and writing are published here. The .pbip files, semantic
models and source data stay offline.

Pick a project below to open its full write-up with screenshots.

---

## Projects

### [Healthcare Dashboard](projects/healthstat/README.md)

<a href="projects/healthstat/README.md">
<picture>
  <source media="(prefers-color-scheme: light)" srcset="screenshots/healthstat/home-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="screenshots/healthstat/home-dark.webp">
  <img alt="Healthcare Dashboard landing page" src="screenshots/healthstat/home-dark.webp" width="720">
</picture>
</a>

Hospital performance across one year of New York hip replacements: 26,286
operations at 151 hospitals. Hospitals are ranked on a severity-adjusted score,
so a hospital that takes sicker patients is not punished for longer stays.

Every number, sentence and colour on screen comes from the model. Nothing is
typed into a text box, so changing a slicer rewrites the text too.

- **Built with:** PBIP and TMDL, DAX measures that return HTML and SVG, Deneb
  (Vega and Vega-Lite), field parameters, bookmarks
- **Scale:** 13 tables, 3 relationships, 183 measures, 7 report pages
- **Notable:** one model drives a dark and a light version of every page from a
  two-row theme table

**[Read the full write-up](projects/healthstat/README.md)**

---

<!--
Template for the next project. Copy, uncomment, fill in.

### [Project Name](projects/PROJECT/README.md)

<a href="projects/PROJECT/README.md">
  <img alt="Project Name landing page" src="screenshots/PROJECT/home.webp" width="720">
</a>

Two or three plain sentences: what the report covers and what the data is.

One or two sentences on what is interesting about how it is built.

- **Built with:** ...
- **Scale:** ...
- **Notable:** ...

**[Read the full write-up](projects/PROJECT/README.md)**

---
-->
