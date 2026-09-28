# Maintenance notes

Notes for working on this repository. Not part of the published site.

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

1. Copy an existing project folder under `docs/` and rename it.
2. Drop screenshots into its `img/` folder — each project's
   `img/README.md` lists the filenames its page expects.
3. Rewrite the case study text in its `index.html`.
4. Add a card to the grid in `docs/index.html` (copy the block that is
   already there and repoint the link and image).

The shared stylesheet means a new project inherits the look with no extra CSS.

Missing screenshots render as a "Screenshot pending" placeholder rather than a
broken image, so a project can go up before its images are ready.

## Publishing

Settings → Pages → Source: *Deploy from a branch* → `main` / `/docs`.

Pages on a free account requires a public repository. With a private repository
the site will not build until the repo is made public, or the account upgraded.

## What must never be committed

`.gitignore` blocks Power BI and data file types outright — `.pbix`, `.pbip`,
`.tmdl`, `.bim`, `.dax`, any `*.Report/` or `*.SemanticModel/` folder at any
depth, plus CSV/XLSX and anything env- or secret-shaped.

To check a specific path before committing:

```
git check-ignore -v path/to/file
```

No output means the file is **not** ignored and would be committed.
