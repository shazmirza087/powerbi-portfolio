# Screenshots for this project

Drop the files below into this folder. The page renders a "Screenshot pending"
placeholder for anything missing, so it never shows a broken image — add them in
any order.

| Filename | What to capture |
|---|---|
| `home-dark.png` | Home page, dark. Also used as the card image on the landing page, so shoot this one first. |
| `los-ranked-dark.png` | Length of stay, dark, **Ranked** view active in the Facility outliers panel. |
| `los-spread-dark.png` | Length of stay, dark, **Spread** view active. |
| `cost-spread-dark.png` | Cost & charges, dark, **Spread** view active. |
| `hospital-profile-dark.png` | Hospital profile, dark, with one facility selected in the slicer. |
| `access-dark.png` | Access to care, dark. |
| `value-dark.png` | Value & efficiency, dark. |
| `los-light.png` | Length of stay, **light** theme — same view as `los-ranked-dark.png` so the pair reads as a true comparison. |

## Capturing them

- **Full page, no chrome.** In Power BI Desktop use View → Page view → Fit to
  page, then capture just the report canvas — no ribbon, no taskbar, no cursor.
- **Consistent state.** Slicers on *All* unless the shot is specifically about a
  selection (the hospital profile is the exception). No visual left in a
  hover or selected state.
- **Same size every time.** The canvas is 1280 × 720. Capture at 2× if you can
  (2560 × 1440) — it stays crisp on high-density screens and scales down
  cleanly.
- **PNG, not JPG.** These are flat-colour UI screenshots; JPG will fuzz the
  text and banding in the dark backgrounds.

## Keep them small

A full-page 2× PNG can land around 1–2 MB. Run them through an optimiser
(TinyPNG, `oxipng -o4`, `pngquant`) before committing — under ~400 KB each keeps
the page quick without visible loss.

## Adding more

Add a `<figure>` block to `../index.html` following the pattern already there;
the `onerror` attribute is what produces the placeholder, so copy it across.
