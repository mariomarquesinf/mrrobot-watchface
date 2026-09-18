# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

"Mr. Robot Terminal" is a Wear OS watch face for the Google Pixel Watch (Wear OS 4/5, API 33+), built entirely with Google's declarative **Watch Face Format (WFF)** — there is no Kotlin/Java code (`android:hasCode="false"`). The entire visual and behavioral definition lives in `app/src/main/res/raw/watchface.xml`, an XML scene graph interpreted natively by the OS. `app/build.gradle.kts` has an empty `dependencies {}` block by design.

## Build and deploy commands

Two parallel build paths exist. The Gradle path is the official/IDE path; the `aapt2` script is the fast local iteration path actually used day-to-day (see `mrrobot_*.apk` artifacts in repo root).

**Gradle (Android Studio / CI-style):**
```bash
./gradlew assembleDebug
```
Output: `app/build/outputs/apk/debug/app-debug.apk`

**Fast manual build (used for quick iteration), from repo root:**
```powershell
./build_apk.ps1
```
This calls `aapt2 compile` → `aapt2 link` → `zipalign` → `apksigner sign` directly (hardcoded SDK path `C:\Program Files (x86)\Android\android-sdk`, build-tools `36.0.0`, platform `android-35`), producing `mrrobot_watchface.apk` in the repo root and mirroring it to `app/build/outputs/apk/debug/app-debug.apk`. Fonts must stay uncompressed (`--no-compress-fonts`) or `TextCircular`/`TimeText` rendering breaks — the script verifies this with `zipalign -c -v 4`.

**Install to a physical Pixel Watch over Wi-Fi ADB:**
```powershell
./install_to_watch.ps1 -WatchIP <ip> [-Port 5555]
```
Wear OS caches the previously-selected watch face's rendering — after installing an update you must switch to a *different* watch face on the device and back to force a reload of the new XML.

**Launch/preview in the Wear OS emulator:**
```
./abrir_emulador.bat
```
(wraps `open_emulator.ps1`, which locates/starts an AVD).

**Render static PNG mockups without a device/emulator** (used for design iteration on layout/colors before touching the XML): `generate_preview.py` (Python + Pillow) and `generate_emulator_preview.ps1` / `open_emulator.ps1` (PowerShell + `System.Drawing`) independently re-implement the watch face's visual layout as raster drawing code.

There is no lint/test suite — validation is visual (render a preview or install to device/emulator) plus `apksigner verify`.

## Architecture: watchface.xml scene graph

`app/src/main/res/raw/watchface.xml` is a single `<WatchFace>` (450x450, `clipShape="CIRCLE"`) containing:

- **`<UserConfigurations>`**: defines the one user-facing setting, `themeColor`, as a set of `ColorOption`s. Each option supplies exactly 3 colors in order: `[0]=text/highlight`, `[1]=neon/primary accent`, `[2]=dark/track`. These are referenced throughout the scene via `[CONFIGURATION.themeColor.N]`. Display names resolve through `app/src/main/res/values/strings.xml`.
- **`<Scene>`**: the visual tree, built from `PartDraw` (vector shapes: `Ellipse`, `Line`, `Arc`), `PartText`/`DigitalClock` (text, including `TextCircular` for arc-following text and `Template`/`Parameter` for interpolated strings like the date line), and `PartImage`.
- **Four `<ComplicationSlot>`** elements (weather/date, heart rate, battery, steps), each defining a `BoundingArc` around the bezel and per-type `<Complication>` layouts (`SHORT_TEXT`, `RANGED_VALUE`, `MONOCHROMATIC_IMAGE`, `EMPTY`). Each complication independently lays out an icon (`PartImage`) and curved text (`TextCircular`), and `RANGED_VALUE` types additionally draw a background "track" arc plus a foreground progress arc whose `endAngle` is computed from `[COMPLICATION.RANGED_VALUE_VALUE/MIN/MAX]` via a `<Transform>` expression.

Slot geometry (angles, radii, arc thickness) is hand-tuned per element and interdependent — e.g. an icon's `x`/`y` position, its `TextCircular` `startAngle`/`endAngle`, and the progress-arc track angles all correspond to the same physical bezel arc, so changing a `BoundingArc` typically requires re-deriving the coordinates of everything nested inside that slot.

**Fonts**: `mr_robot` (display face, used for the main time) and `roboto_mono_bold`/`roboto_mono_regular` (all other terminal-style text) live in `app/src/main/res/font/`.

**Non-obvious coupling**: the color palette (6 themes) is defined once in `watchface.xml` but re-declared independently in `generate_preview.py` and `generate_emulator_preview.ps1`/`open_emulator.ps1` for the mockup renderers. When adding/editing a theme color, update all three, or the static previews will drift from the actual on-device rendering.

**Metadata**: `app/src/main/res/xml/watch_face_info.xml` controls store listing behavior (preview image, editability, multi-instance support); `AndroidManifest.xml` declares `com.google.wear.watchface.format.version = 1`.
