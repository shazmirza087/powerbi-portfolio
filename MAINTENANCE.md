# Maintenance notes

Notes for working on this repository. Not part of the portfolio itself.

## Structure

The root `README.md` is the front page. It lists every project with a short
summary, a cover image and a link. Each project's full write-up lives in its
own README under `projects/`. GitHub renders them all directly, so there is no
site to build and nothing to deploy.

```
README.md                          Front page: one short entry per project
projects/
└── <project>/
    └── README.md                  The full write-up for that project
screenshots/
└── <project>/                     That project's images, plus a README.md
    │                              listing the filenames the write-up expects
    └── *.webp
```

## Adding a project

1. Make `screenshots/<project>/` and put its images there, as `.webp`.
2. Copy that folder's `README.md` from an existing project and update the
   filename table.
3. Make `projects/<project>/README.md` for the full write-up. Start it with a
   heading and a `[Back to the portfolio](../../README.md)` link, and end it
   with the same link.
4. Add an entry to the root `README.md`. There is a commented-out template at
   the bottom of that file. Keep the entry short: what the report is, what is
   interesting about the build, a cover image, and a link to the write-up.

## Image paths

Paths are relative to the file they are written in, so they differ between the
two levels:

| Written in | Path to an image |
|---|---|
| root `README.md` | `screenshots/PROJECT/home.webp` |
| `projects/PROJECT/README.md` | `../../screenshots/PROJECT/home.webp` |

A project with a dark and a light version uses a `<picture>` with both sources,
so each figure follows the reader's own GitHub theme:

```html
<picture>
  <source media="(prefers-color-scheme: light)" srcset="../../screenshots/PROJECT/home-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="../../screenshots/PROJECT/home-dark.webp">
  <img alt="..." src="../../screenshots/PROJECT/home-dark.webp">
</picture>
```

A single-theme project just uses a plain `<img>`.

## Formatting the write-ups

- **Formulas use English words, not symbols.** They are still rendered as real
  maths with `$$...$$` or inline `$...$`, but every term inside is plain words
  wrapped in `\text{}`. No Greek letters, no subscripts, no summation signs. The
  test is whether a reader can say the fraction out loud:

  ```
  $$
  \text{Score} = \frac{\text{what actually happened}}{\text{what was expected}}
  $$
  ```

  Anything with genuinely moving parts gets a worked example in a plain code
  block underneath, with real numbers.
- **Never use spacing commands** such as `\;`, `\,`, `\quad` or `\qquad`.
  GitHub renders `\;` as a literal semicolon, which once put `expected; = ;` on
  the page. Put each formula in its own `$$` block instead of spacing two of
  them apart on one line.
- **No `|` inside maths in a table cell.** It ends the cell.
- **Dollar amounts in prose are escaped** as `\$`. GitHub will otherwise try to
  pair a stray `$20.9K` with another dollar sign further down the paragraph and
  render everything between them as a formula.
- Code excerpts are excerpts. They are there to be read in place, not copied
  out and run.

## What must never be committed

`.gitignore` blocks Power BI and data file types outright: `.pbix`, `.pbip`,
`.tmdl`, `.bim`, `.dax`, any `*.Report/` or `*.SemanticModel/` folder at any
depth, plus CSV/XLSX and anything env- or secret-shaped.

To check a specific path before committing:

```
git check-ignore -v path/to/file
```

No output means the file is **not** ignored and would be committed.

Source PNGs are not committed either. Convert to `.webp` and delete the PNG.
