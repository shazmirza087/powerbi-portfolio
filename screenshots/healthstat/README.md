# Screenshots — HealthStat

Sixteen images: every report page in both themes, plus both distribution views.
The case study in the repository root `README.md` pairs them with `<picture>`,
so each figure follows whichever theme the reader is viewing GitHub in.

| File | Page | Theme |
|---|---|---|
| `home-dark.webp` / `home-light.webp` | Home | dark / light |
| `los-dark.webp` / `los-light.webp` | Length of stay — Ranked view | dark / light |
| `los-spread-dark.webp` / `los-spread-light.webp` | Length of stay — Spread view | dark / light |
| `cost-dark.webp` / `cost-light.webp` | Cost and charges — Ranked view | dark / light |
| `cost-spread-dark.webp` / `cost-spread-light.webp` | Cost and charges — Spread view | dark / light |
| `value-dark.webp` / `value-light.webp` | Value and efficiency | dark / light |
| `access-dark.webp` / `access-light.webp` | Access to care | dark / light |
| `profile-dark.webp` / `profile-light.webp` | Hospital profile | dark / light |

## Format

WebP, quality 92, at the native capture resolution (about 1965 × 1105). That is
roughly a third the size of the equivalent PNG with no visible difference —
worth it, because the README loads sixteen of them.

To convert a new capture:

```python
from PIL import Image
Image.open("shot.png").convert("RGB").save("shot.webp", "WEBP", quality=92, method=6)
```

Convert, then delete the PNG. Only the `.webp` belongs in the repository.

## Capturing

- **Fit to page.** View → Page view → Fit to page, then capture the report
  canvas only — no ribbon, no page tabs.
- **Nothing hovered.** Move the mouse off the canvas before the snip. A hovered
  visual shows its `...` menu and can leave a tooltip in the shot.
- **Consistent state.** Slicers on *All*, except the hospital profile, which
  needs one facility selected.
- **Same view per pair.** The dark and light shots of a page must show the same
  bookmark view, or the toggle looks like two different reports.

## Replacing or adding a figure

Overwrite the file in place and the README picks it up — the filenames above are
the contract. A new figure needs a `<picture>` block added to the root
`README.md`; copy one that is already there and repoint both `srcset`s and the
fallback `src`.
