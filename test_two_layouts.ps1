Add-Type -AssemblyName System.Drawing

$pfc = New-Object System.Drawing.Text.PrivateFontCollection
$pfc.AddFontFile("F:\Dev\techIncubator\watchFace\app\src\main\res\font\mr_robot.ttf")
$pfc.AddFontFile("F:\Dev\techIncubator\watchFace\app\src\main\res\font\roboto_mono_bold.ttf")
$mrRobot = $pfc.Families | Where-Object { $_.Name -like "*Robot*" } | Select-Object -First 1
$mono    = $pfc.Families | Where-Object { $_.Name -like "*Roboto*" -or $_.Name -like "*Mono*" } | Select-Object -First 1

# Color Palette (Lavender Theme)
$colText = [System.Drawing.Color]::FromArgb(233, 213, 255) # E9D5FF
$colNeon = [System.Drawing.Color]::FromArgb(192, 132, 252) # C084FC
$colDark = [System.Drawing.Color]::FromArgb(76, 29, 149)   # 4C1D95
$colTrack = [System.Drawing.Color]::FromArgb(45, 25, 75)   # Track arc bg
$colCardBg = [System.Drawing.Color]::FromArgb(15, 9, 24)

$brushText = New-Object System.Drawing.SolidBrush($colText)
$brushNeon = New-Object System.Drawing.SolidBrush($colNeon)
$brushDark = New-Object System.Drawing.SolidBrush($colDark)
$brushCard = New-Object System.Drawing.SolidBrush($colCardBg)

$penTrack = New-Object System.Drawing.Pen($colTrack, 5.0)
$penNeon  = New-Object System.Drawing.Pen($colNeon, 5.0)
$penNeon.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$penNeon.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
$penBorder = New-Object System.Drawing.Pen($colDark, 1.2)

$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

# Helper to draw a circular arc gauge
function Draw-ArcGauge($g, $cx, $cy, $radius, $percent, $tag, $val, $sub, $iconChar) {
    $d = $radius * 2
    $x = $cx - $radius
    $y = $cy - $radius

    # Card background circle
    $g.FillEllipse($brushCard, $x - 2, $y - 2, $d + 4, $d + 4)

    # 270-degree track (from 135 to 405 deg)
    $g.DrawArc($penTrack, $x, $y, $d, $d, 135, 270)

    # Progress arc (from 135 deg clockwise)
    $sweep = [Math]::Max(10, [Math]::Min(270, 270 * ($percent / 100.0)))
    $g.DrawArc($penNeon, $x, $y, $d, $d, 135, $sweep)

    # Complication inner contents
    $fTag = New-Object System.Drawing.Font($mono, 7.5, [System.Drawing.FontStyle]::Bold)
    $fVal = New-Object System.Drawing.Font($mono, 13, [System.Drawing.FontStyle]::Bold)
    $fSub = New-Object System.Drawing.Font($mono, 7.5, [System.Drawing.FontStyle]::Regular)

    $g.DrawString($tag, $fTag, $brushNeon, $cx, $cy - 20, $sfCenter)
    $g.DrawString($val, $fVal, $brushText, $cx, $cy + 2, $sfCenter)
    $g.DrawString($iconChar, $fSub, $brushNeon, $cx, $cy + 20, $sfCenter)
}

# =========================================================================
# LAYOUT 1: SYMMETRICAL 4-ARC GAUGES + BIG CENTER MR. ROBOT HUD
# =========================================================================
$bmp1 = New-Object System.Drawing.Bitmap 550, 550
$g1 = [System.Drawing.Graphics]::FromImage($bmp1)
$g1.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g1.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$g1.Clear([System.Drawing.Color]::FromArgb(18, 18, 22))

# Bezel and screen
$caseBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(38, 38, 44))
$g1.FillEllipse($caseBrush, 35, 35, 480, 480)
$crownBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(85, 85, 92))
$g1.FillRectangle($crownBrush, 508, 250, 14, 50)
$bezelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(8, 8, 10))
$g1.FillEllipse($bezelBrush, 45, 45, 460, 460)
$screenBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
$g1.FillEllipse($screenBrush, 50, 50, 450, 450)

$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddEllipse(50, 50, 450, 450)
$g1.SetClip($path)

# 1. Top Header - PERFECTLY CENTERED WITH FULL SCREEN WIDTH
$fPrompt = New-Object System.Drawing.Font($mono, 9.5, [System.Drawing.FontStyle]::Bold)
$fHello  = New-Object System.Drawing.Font($mono, 14, [System.Drawing.FontStyle]::Bold)

# Use full width 450 centered at 50 + 225 = 275!
$g1.DrawString("root@fsociety:~# ./time", $fPrompt, $brushNeon, [System.Drawing.RectangleF]::FromLTRB(50, 50 + 44, 50 + 450, 50 + 64), $sfCenter)
$g1.DrawString("HELLO, FRIEND.", $fHello, $brushText, [System.Drawing.RectangleF]::FromLTRB(50, 50 + 66, 50 + 450, 50 + 90), $sfCenter)

# 2. Four Arc Gauges along the 45-degree diagonals
# Gauge 0: Top-Left (10:30) Weather
Draw-ArcGauge $g1 (50 + 82) (50 + 96) 36 65 "[WTH]" "21`u{00B0}C" "`u{2601}"
# Gauge 1: Top-Right (01:30) Heart Rate
Draw-ArcGauge $g1 (50 + 368) (50 + 96) 36 74 "[BPM]" "74" "`u{2665} bpm"
# Gauge 2: Bottom-Left (07:30) Readiness
Draw-ArcGauge $g1 (50 + 82) (50 + 326) 36 85 "[RDN]" "85" "`u{26A1} SCORE"
# Gauge 3: Bottom-Right (04:30) Steps
Draw-ArcGauge $g1 (50 + 368) (50 + 326) 36 84 "[STP]" "8.4k" "`u{25BA} STEPS"

# 3. Center Digital Clock - MR. ROBOT FONT (HEROIC & CLEAN)
$fClock = New-Object System.Drawing.Font($mrRobot, 50, [System.Drawing.FontStyle]::Regular)
$timeStr = (Get-Date).ToString("HH:mm:ss")
$g1.DrawString($timeStr, $fClock, $brushNeon, [System.Drawing.RectangleF]::FromLTRB(50, 50 + 170, 50 + 450, 50 + 242), $sfCenter)

# Date Line
$fDate = New-Object System.Drawing.Font($mono, 11, [System.Drawing.FontStyle]::Bold)
$dateStr = "> SYS_DATE: " + (Get-Date).ToString("yyyy.MM.dd") + " // " + (Get-Date).ToString("ddd").ToUpper()
$g1.DrawString($dateStr, $fDate, $brushText, [System.Drawing.RectangleF]::FromLTRB(50, 50 + 246, 50 + 450, 50 + 268), $sfCenter)

# 4. Center Divider & Terminal Footer
$g1.DrawLine($penBorder, 50 + 130, 50 + 280, 50 + 320, 50 + 280)
$fFoot = New-Object System.Drawing.Font($mono, 9.5, [System.Drawing.FontStyle]::Bold)
$g1.DrawString("fsociety // dont-delete-me", $fFoot, $brushText, [System.Drawing.RectangleF]::FromLTRB(50, 50 + 348, 50 + 450, 50 + 370), $sfCenter)
$g1.DrawString("root@fsociety:~# _", $fFoot, $brushNeon, [System.Drawing.RectangleF]::FromLTRB(50, 50 + 372, 50 + 450, 50 + 394), $sfCenter)

$bmp1.Save("F:\Dev\techIncubator\watchFace\arc_option_1.png", [System.Drawing.Imaging.ImageFormat]::Png)
Copy-Item "F:\Dev\techIncubator\watchFace\arc_option_1.png" "C:\Users\mario.marques\.gemini\antigravity-cli\brain\b0ce02aa-35a7-4ecd-a25b-6d8896edb36c\arc_option_1.png" -Force

# =========================================================================
# LAYOUT 2: ASYMMETRIC (TIME CAPSULE ON LEFT + 3 STACKED ARC GAUGES ON RIGHT)
# Exactly matching the composition of the user's reference photo!
# =========================================================================
$bmp2 = New-Object System.Drawing.Bitmap 550, 550
$g2 = [System.Drawing.Graphics]::FromImage($bmp2)
$g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g2.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$g2.Clear([System.Drawing.Color]::FromArgb(18, 18, 22))
$g2.FillEllipse($caseBrush, 35, 35, 480, 480)
$g2.FillRectangle($crownBrush, 508, 250, 14, 50)
$g2.FillEllipse($bezelBrush, 45, 45, 460, 460)
$g2.FillEllipse($screenBrush, 50, 50, 450, 450)
$g2.SetClip($path)

# Outer Bezel Progress Arcs (like in photo!)
# Top-Left Bezel Arc
$penOuterTrack = New-Object System.Drawing.Pen($colTrack, 8.0)
$penOuterNeon  = New-Object System.Drawing.Pen($colNeon, 8.0)
$penOuterNeon.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$penOuterNeon.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round

# Outer perimeter arc for Readiness/Battery (from 190 to 260 deg)
$g2.DrawArc($penOuterTrack, 50 + 16, 50 + 16, 418, 418, 195, 60)
$g2.DrawArc($penOuterNeon,  50 + 16, 50 + 16, 418, 418, 195, 48)
$fOuter = New-Object System.Drawing.Font($mono, 8, [System.Drawing.FontStyle]::Bold)
$g2.DrawString("`u{26A1}85%", $fOuter, $brushNeon, 50 + 38, 50 + 185)

# Left Side: Terminal Header + Big Time Capsule + Footer
# Header
$fPrompt2 = New-Object System.Drawing.Font($mono, 9, [System.Drawing.FontStyle]::Bold)
$g2.DrawString("root@fsociety:~#", $fPrompt2, $brushNeon, 50 + 40, 50 + 80)
$fHello2  = New-Object System.Drawing.Font($mono, 13, [System.Drawing.FontStyle]::Bold)
$g2.DrawString("HELLO, FRIEND.", $fHello2, $brushText, 50 + 40, 50 + 102)

# Time Capsule (Left side)
# Rounded capsule background
$capsuleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, 20, 55))
$g2.FillPath($capsuleBrush, (New-Object System.Drawing.Drawing2D.GraphicsPath)) # simplified
# Draw rounded rectangle for capsule
$capsuleRect = New-Object System.Drawing.Rectangle(50 + 36, 50 + 170, 205, 96)
$pathCapsule = New-Object System.Drawing.Drawing2D.GraphicsPath
$pathCapsule.AddArc(50 + 36, 50 + 170, 48, 48, 180, 90)
$pathCapsule.AddArc(50 + 36 + 205 - 48, 50 + 170, 48, 48, 270, 90)
$pathCapsule.AddArc(50 + 36 + 205 - 48, 50 + 170 + 96 - 48, 48, 48, 0, 90)
$pathCapsule.AddArc(50 + 36, 50 + 170 + 96 - 48, 48, 48, 90, 90)
$pathCapsule.CloseFigure()
$g2.FillPath($capsuleBrush, $pathCapsule)
$g2.DrawPath($penBorder, $pathCapsule)

# Clock inside capsule (Mr. Robot font)
$fClock2 = New-Object System.Drawing.Font($mrRobot, 44, [System.Drawing.FontStyle]::Regular)
$timeStrShort = (Get-Date).ToString("HH:mm")
$g2.DrawString($timeStrShort, $fClock2, $brushNeon, [System.Drawing.RectangleF]::FromLTRB(50 + 36, 50 + 175, 50 + 241, 50 + 260), $sfCenter)

# Under the capsule: Date & prompt
$fDate2 = New-Object System.Drawing.Font($mono, 9.5, [System.Drawing.FontStyle]::Bold)
$g2.DrawString("> " + (Get-Date).ToString("yyyy.MM.dd"), $fDate2, $brushText, 50 + 42, 50 + 280)
$g2.DrawString("root@fsociety:~# _", $fPrompt2, $brushNeon, 50 + 42, 50 + 302)

# Right Side: 3 Stacked Arc Gauges (Step, BPM, Weather) - EXACTLY LIKE PHOTO!
# Gauge 1: Steps (Top Right)
Draw-ArcGauge $g2 (50 + 320) (50 + 115) 42 84 "[STP]" "8,420" "`u{25BA} STEPS" "`u{25BA}"
# Gauge 2: Heart Rate (Mid Right)
Draw-ArcGauge $g2 (50 + 338) (50 + 225) 42 74 "[BPM]" "71" "`u{2665} bpm" "`u{2665}"
# Gauge 3: Weather (Bottom Right)
Draw-ArcGauge $g2 (50 + 320) (50 + 335) 42 65 "[WTH]" "21`u{00B0}C" "`u{2601} SUN" "`u{2601}"

$bmp2.Save("F:\Dev\techIncubator\watchFace\arc_option_2.png", [System.Drawing.Imaging.ImageFormat]::Png)
Copy-Item "F:\Dev\techIncubator\watchFace\arc_option_2.png" "C:\Users\mario.marques\.gemini\antigravity-cli\brain\b0ce02aa-35a7-4ecd-a25b-6d8896edb36c\arc_option_2.png" -Force

Write-Host "Both layout options generated!"
