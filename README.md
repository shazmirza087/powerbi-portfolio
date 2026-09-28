# Power BI Portfolio

Dashboards and semantic models, presented as screenshots and build notes.

**Live site:** https://shazmirza087.github.io/powerbi-portfolio/

## What is and isn't here

This repository holds the portfolio site only — HTML, CSS and images.

Report files, semantic models, DAX and datasets are deliberately not
published. `.gitignore` blocks those file types outright, so they cannot be
committed by accident.

## Structure

```
docs/                     GitHub Pages root
├── index.html            Landing page — one card per project
├── assets/style.css      Shared styling for every page
└── <project>/
    ├── index.html        Case study
    └── img/              Screenshots
```

## Adding a project

1. Copy any existing project folder under `docs/` and rename it.
2. Drop screenshots into its `img/` folder.
3. Rewrite the case study text.
4. Add a card to the grid in `docs/index.html`.

The shared stylesheet means a new project inherits the look with no extra CSS.

## Publishing

Settings → Pages → Source: *Deploy from a branch* → `main` / `/docs`.

Pages on a free account requires a public repository. With a private
repository the site will not build until the repo is made public (or the
account is upgraded).
