[🇬🇧 English](README.md) | [🇵🇹 Português](README.pt.md)

# Mr. Robot Terminal — Wear OS Watch Face

[![Build](https://github.com/mariomarquesinf/mrrobot-watchface/actions/workflows/build.yml/badge.svg)](https://github.com/mariomarquesinf/mrrobot-watchface/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Built by [Mário Marques](https://mariomarquesinf.com) — [mariomarquesinf.com](https://mariomarquesinf.com)

A fully declarative, zero-code watch face for Wear OS, styled after the hacker/terminal
aesthetic of **Mr. Robot** (fsociety). Built entirely in Google's **Watch Face Format
(WFF)** — an XML scene graph interpreted natively by the OS, with no background service,
no APK code, and minimal battery impact.

![Demo](docs/screenshots/demo.gif)

![All six color themes](docs/screenshots/all_themes.png)

## Why Watch Face Format

Most third-party Wear OS watch faces historically shipped as a running Android service
(a `WatchFaceService` with a render loop, executing app code on every tick). WFF inverts
that: the face is a **declarative XML document** — shapes, text, complications, and
color configuration — that the system's own renderer draws, the same way it draws its
own first-party faces. The trade-offs that shaped this project:

- **No executable code at all** (`android:hasCode="false"`) — the whole visual and
  data-binding logic lives in `app/src/main/res/raw/watchface.xml`.
- **System-managed lifecycle** — ambient mode, burn-in protection, and battery budgeting
  are handled by the OS renderer, not custom logic.
- **No unit-testing story.** There's no runtime to attach a debugger or test harness to —
  correctness can only be verified by installing the compiled scene graph on a real
  watch and observing it. Every layout and data-binding decision in this repo was
  validated empirically over ADB (live `logcat` + on-device screenshots), which is worth
  knowing before assuming "it renders" means "it's correct."
- **Validated against Google's own Play Store tooling.** Ran the
  [`memory-footprint`](https://github.com/google/watchface/tree/main/play-validations)
  evaluator — the same schema/memory check Google Play runs on watch face submissions —
  against the built APK. It caught a real bug `aapt2` had missed:
  `isCustomizable="true"` is invalid per the WFF schema, which requires uppercase
  `TRUE`/`FALSE` (fixed in `watchface.xml`). It also surfaced what looks like a bug in the
  tool's own resource resolver for plain scene-level `PartImage` references (as opposed
  to complication icons) — traced to a recently-touched file in that project rather than
  worked around blindly.

## Features

- **Terminal HUD aesthetic** — `root@fsociety:~#` prompt, `HELLO, FRIEND.` greeting, and
  a footer cursor that blinks in sync with the seconds tick (real terminal cursor
  behavior, driven by a `[SECOND] % 2` expression, not a fixed animation).
- **Hero digital clock** — large centered `hh:mm:ss` display, the visual focal point,
  with a brief RGB chromatic-aberration glitch pulse every 10 seconds (two color-shifted
  ghost copies of the clock flash in and out via a `[SECOND] % 10` expression) —
  a VHS/hacker-glitch touch matching the fsociety logo's own aesthetic.
- **4 live, user-editable complications** (date, heart rate, battery, steps by default —
  freely reassignable to anything the OS offers) laid out as a straight, legible 2×2
  grid rather than curved bezel text.
- **fsociety mask watermark**, rendered as a monochrome alpha mask so it can be
  recolored live via the active theme's accent color, at low opacity so it stays a
  background element.
- **HUD corner reticle** instead of a plain bezel ring.
- **Real always-on/ambient (AOD) mode** — not just an unmodified low-power copy of the
  interactive face. The full HUD (watermark, reticle, header, status lines, footer)
  hides entirely in ambient, replaced by a dimmed, seconds-free clock and date; the
  4 complications stay visible but dimmed. Keeps well under the Wear OS guideline of
  15% illuminated pixels in ambient, and reduces AMOLED burn-in risk.
- **6 interchangeable color themes**, switchable on-device with zero code changes.

## Architecture notes

A few decisions worth calling out, since they weren't the first thing tried:

- **Ambient mode uses parallel `Group`s toggled by `Variant`, not a single reformatted
  scene.** WFF has no conditional layout ("if ambient, do X"); instead you declare two
  versions of a subtree — one for interactive, one for ambient — each with
  `<Variant mode="AMBIENT" target="alpha" value="…"/>` flipping its own visibility. The
  interactive HUD is one `Group` that fades to `alpha=0` in ambient; the ambient clock/
  date is a separate `Group` that starts at `alpha=0` and fades in only in ambient. Kept
  the 4 `ComplicationSlot`s outside both groups (nesting them in a `Group` isn't a
  documented pattern) and instead dimmed their icon/text directly via the same `Variant`
  mechanism.
- **Complications show only the raw value in brackets** (`[62]`, `[1189]`), never a
  hardcoded category label like `BAT:` or `STP:`. Early versions baked in a label per
  slot; the problem is a user can reassign any slot to a *different* data source (e.g.
  swap "date" for a fitness app's "readiness" score) via the standard Wear OS
  customization UI, and a hardcoded label would silently go stale. Instead, each
  complication renders the assigned provider's own `MONOCHROMATIC_IMAGE` icon next to
  the value — the label is always sourced from whatever is actually selected, so it can
  never drift out of sync.
- **Centralized theming.** Every colored element — text, icons, the watermark tint, the
  divider lines — binds to `[CONFIGURATION.themeColor.N]`. Adding a 7th theme means
  adding one `<ColorOption>` block; no other file changes.
- **Curved bezel text was tried and reverted.** An earlier iteration wrapped
  complication values around the bezel using `TextCircular`. It looked correct in the
  XML and matched the documented geometry, but was empirically illegible on-device —
  characters rotate to stay tangent to the arc, which at small font sizes near the
  9/3 o'clock positions renders as unreadable noise. The fix wasn't a bug fix, it was a
  design change: switch to straight horizontal text.

## Color themes

| Theme | Text | Accent | Deep |
|---|---|---|---|
| fsociety Vermelho (default) | `#FFE4E6` | `#F43F5E` | `#881337` |
| Lavanda Neon | `#E9D5FF` | `#C084FC` | `#4C1D95` |
| Kali Verde Terminal | `#DCFCE7` | `#22C55E` | `#14532D` |
| Cyber Ciano | `#E0F2FE` | `#06B6D4` | `#164E63` |
| Fósforo Âmbar | `#FEF3C7` | `#F59E0B` | `#78350F` |
| Stealth Branco | `#FFFFFF` | `#CBD5E1` | `#334155` |

## Install

**Pre-built APK:** grab the latest from [Releases](../../releases) and sideload it:
```bash
adb install mrrobot_watchface.apk
```
Then long-press your current watch face and select **Mr. Robot Terminal**.

**Build from source:**
```bash
./gradlew assembleDebug
```
or, for a faster local iteration loop using `aapt2` directly (see `tools/build_apk.ps1`):
```powershell
./tools/build_apk.ps1
```
Requires Wear OS 4+ (API 33+) as the target device.

## Project structure

```
watchFace/
├── app/
│   └── src/main/
│       ├── AndroidManifest.xml       # WFF format version declaration, no code
│       └── res/
│           ├── raw/watchface.xml     # The entire scene graph: layout, complications, theming
│           ├── drawable/             # Launcher icon, store preview, watermark asset
│           ├── font/                 # Custom terminal/display typefaces
│           └── values/strings.xml    # Theme + complication slot display names
├── tools/                            # Local dev scripts (fast aapt2 build, ADB install, emulator preview)
├── docs/screenshots/                 # Theme gallery
└── build.gradle.kts / settings.gradle.kts
```

## License

MIT — see [LICENSE](LICENSE). "Mr. Robot" and "fsociety" belong to their respective
rights holders; this is an unofficial, non-commercial fan project.
