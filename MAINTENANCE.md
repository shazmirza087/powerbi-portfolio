# Maintenance notes

Notes for working on this repository. Not part of the portfolio itself.

## Structure

The portfolio is the root `README.md`. GitHub renders it on the repository
front page, so there is no site to build and nothing to deploy.

```
README.md                          The portfolio, one section per project
screenshots/
└── <project>/                     That project's images, plus a README.md
    │                              listing the filenames the portfolio expects
    └── *.webp
```

## Adding a project

1. Make `screenshots/<project>/` and put its images there, as `.webp`.
2. Copy that folder's `README.md` from an existing project and update the
   filename table.
3. Add a section to the root `README.md`: a heading, the figures as `<picture>`
   blocks, and the prose between them.

Each figure is a `<picture>` with a light and a dark source, so it follows the
reader's own GitHub theme:

```html
<picture>
  <source media="(prefers-color-scheme: light)" srcset="screenshots/PROJECT/home-light.webp">
  <source media="(prefers-color-scheme: dark)"  srcset="screenshots/PROJECT/home-dark.webp">
  <img alt="..." src="screenshots/PROJECT/home-dark.webp">
</picture>
```

Paths are relative to the repository root and must stay that way.

## Formatting the README

- **No LaTeX maths.** It was tried and removed for two reasons. GitHub's
  renderer mangles spacing commands, so `\;` came out on the page as a literal
  semicolon and the formula read `expected; = ;`. And symbols shut out the half
  of the audience who are not statisticians. Explain arithmetic in words, or
  with a worked example in a plain code block. A reader should be able to follow
  a calculation without knowing what a sigma is.
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
