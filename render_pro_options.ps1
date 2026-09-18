Add-Type -AssemblyName System.Drawing

$pfc = New-Object System.Drawing.Text.PrivateFontCollection
$pfc.AddFontFile("F:\Dev\techIncubator\watchFace\app\src\main\res\font\mr_robot.ttf")
$pfc.AddFontFile("F:\Dev\techIncubator\watchFace\app\src\main\res\font\roboto_mono_bold.ttf")
$mrRobot = $pfc.Families | Where-Object { $_.Name -like "*Robot*" } | Select-Object -First 1
$mono    = $pfc.Families | Where-Object { $_.Name -like "*Roboto*" -or $_.Name -like "*Mono*" } | Select-Object -First 1

# Lavender Neon Theme
$colText   = [System.Drawing.Color]::FromArgb(233, 213, 255) # E9D5FF
$colNeon   = [System.Drawing.Color]::FromArgb(192, 132, 252) # C084FC
$colDark   = [System.Drawing.Color]::FromArgb(76, 29, 149)   # 4C1D95
$colTrack  = [System.Drawing.Color]::FromArgb(40, 20, 65)
$colCardBg = [System.Drawing.Color]::FromArgb(14, 8, 22)

$brushText = New-Object System.Drawing.SolidBrush($colText)
$brushNeon = New-Object System.Drawing.SolidBrush($colNeon)
$brushDark = New-Object System.Drawing.SolidBrush($colDark)
$brushCard = New-Object System.Drawing.SolidBrush($colCardBg)

$penTrack = New-Object System.Drawing.Pen($colTrack, 4.5)
$penNeon  = New-Object System.Drawing.Pen($colNeon, 4.5)
$penNeon.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$penNeon.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
$penBorder = New-Object System.Drawing.Pen($colDark, 1.2)

$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

function Draw-WatchBase($g) {
    $caseBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(38, 38, 44))
    $g.FillEllipse($caseBrush, 35, 35, 480, 480)
    $crownBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(85, 85, 92))
    $g.FillRectangle($crownBrush, 508, 250, 14, 50)
    $bezelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(8, 8, 10))
    $g.FillEllipse($bezelBrush, 45, 45, 460, 460)
    $screenBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    $g.FillEllipse($screenBrush, 50, 50, 450, 450)

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse(50, 50, 450, 450)
    $g.SetClip($path)
}

function Draw-ArcGaugePro($g, $cx, $cy, $radius, $percent, $tag, $val, $iconChar) {
    $d = $radius * 2
    $x = $cx - $radius
    $y = $cy - $radius

    # Pod background
    $g.FillEllipse($brushCard, $x, $y, $d, $d)

    # 270 deg track arc
    $g.DrawArc($penTrack, $x + 3, $y + 3, $d - 6, $d - 6, 135, 270)

    # Neon progress arc
    $sweep = [Math]::Max(15, [Math]::Min(270, 270 * ($percent / 100.0)))
    $g.DrawArc($penNeon, $x + 3, $y + 3, $d - 6, $d - 6, 135, $sweep)

    # Inner elements: BIG & READABLE
    $fTag = New-Object System.Drawing.Font($mono, 8, [System.Drawing.FontStyle]::Bold)
    $fVal = New-Object System.Drawing.Font($mono, 13, [System.Drawing.FontStyle]::Bold)
    $fIco = New-Object System.Drawing.Font($mono, 9, [System.Drawing.FontStyle]::Regular)

    $g.DrawString($tag, $fTag, $brushNeon, $cx, $cy - 18, $sfCenter)
    $g.DrawString($val, $fVal, $brushText, $cx, $cy + 2, $sfCenter)
    $g.DrawString($iconChar, $fIco, $brushNeon, $cx, $cy + 18, $sfCenter)
}

# =========================================================================
# DESIGN A: MR. ROBOT TERMINAL WITH 4 ARC GAUGES (SYMMETRIC HUD)
# =========================================================================
$bmpA = New-Object System.Drawing.Bitmap 550, 550
$gA = [System.Drawing.Graphics]::FromImage($bmpA)
$gA.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gA.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$gA.Clear([System.Drawing.Color]::FromArgb(18, 18, 22))
Draw-WatchBase $gA

# 1. Header (Centered, 100% safe width)
$fPrompt = New-Object System.Drawing.Font($mono, 9, [System.Drawing.FontStyle]::Bold)
$fHello  = New-Object System.Drawing.Font($mono, 13, [System.Drawing.FontStyle]::Bold)
$gA.DrawString("root@fsociety:~# ./time", $fPrompt, $brushNeon, [System.Drawing.RectangleF]::FromLTRB(50, 50 + 44, 50 + 450, 50 + 64), $sfCenter)
$gA.DrawString("HELLO, FRIEND.", $fHello, $brushText, [System.Drawing.RectangleF]::FromLTRB(50, 50 + 66, 50 + 450, 50 + 88), $sfCenter)

# 2. Main Clock (Mr. Robot font, big and bold)
$fClock = New-Object System.Drawing.Font($mrRobot, 48, [System.Drawing.FontStyle]::Regular)
$timeStr = (Get-Date).ToString("HH:mm:ss")
$gA.DrawString($timeStr, $fClock, $brushNeon, [System.Drawing.RectangleF]::FromLTRB(50, 50 + 104, 50 + 450, 50 + 176), $sfCenter)

# 3. Date
$fDate = New-Object System.Drawing.Font($mono, 10.5, [System.Drawing.FontStyle]::Bold)
$dateStr = "> SYS_DATE: " + (Get-Date).ToString("yyyy.MM.dd") + " // " + (Get-Date).ToString("ddd").ToUpper()
$gA.DrawString($dateStr, $fDate, $brushText, [System.Drawing.RectangleF]::FromLTRB(50, 50 + 180, 50 + 450, 50 + 202), $sfCenter)

# Divider Line
$gA.DrawLine($penBorder, 50 + 75, 50 + 214, 50 + 375, 50 + 214)

# 4. The 4 Arc Gauges (2x2 Balanced Cyber Grid - BIG & READABLE!)
# Pod size: radius 36 (diameter 72px)
$degChar = [char]0x00B0
$heartChar = [char]0x2665
$boltChar = [char]0x26A1
$stepChar = [char]0x25BA

# Top-Left: Weather
Draw-ArcGaugePro $gA (50 + 130) (50 + 262) 36 65 "[WTH]" "21$degChar`C" "WTH"
# Top-Right: Heart Rate
Draw-ArcGaugePro $gA (50 + 320) (50 + 262) 36 74 "[BPM]" "74" "$heartChar bpm"
# Bottom-Left: Readiness
Draw-ArcGaugePro $gA (50 + 130) (50 + 346) 36 85 "[RDN]" "85" "$boltChar SCORE"
# Bottom-Right: Steps
Draw-ArcGaugePro $gA (50 + 320) (50 + 346) 36 84 "[STP]" "8,420" "$stepChar STEPS"

# Bottom Terminal Prompt
$fPromptSmall = New-Object System.Drawing.Font($mono, 8.5, [System.Drawing.FontStyle]::Bold)
$gA.DrawString("root@fsociety:~# _", $fPromptSmall, $brushNeon, [System.Drawing.RectangleF]::FromLTRB(50, 50 + 396, 50 + 450, 50 + 416), $sfCenter)

$bmpA.Save("F:\Dev\techIncubator\watchFace\design_A_grid.png", [System.Drawing.Imaging.ImageFormat]::Png)
Copy-Item "F:\Dev\techIncubator\watchFace\design_A_grid.png" "C:\Users\mario.marques\.gemini\antigravity-cli\brain\b0ce02aa-35a7-4ecd-a25b-6d8896edb36c\design_A_grid.png" -Force

# =========================================================================
# DESIGN B: EXACT PIXEL WATCH "TRACK" STYLE (TIME CAPSULE + 3 STACKED ARCS)
# Directly replicating the user's reference photo!
# =========================================================================
$bmpB = New-Object System.Drawing.Bitmap 550, 550
$gB = [System.Drawing.Graphics]::FromImage($bmpB)
$gB.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gB.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$gB.Clear([System.Drawing.Color]::FromArgb(18, 18, 22))
Draw-WatchBase $gB

# 1. Outer Bezel Arc Complication (Top Bezel: Readiness 85%)
$penOuterTrack = New-Object System.Drawing.Pen($colTrack, 6.0)
$penOuterNeon  = New-Object System.Drawing.Pen($colNeon, 6.0)
$penOuterNeon.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$penOuterNeon.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round

# Perimeter arc along the top-left quadrant (from 215 to 275 deg)
$gB.DrawArc($penOuterTrack, 50 + 14, 50 + 14, 422, 422, 210, 60)
$gB.DrawArc($penOuterNeon,  50 + 14, 50 + 14, 422, 422, 210, 51)
$fOuter = New-Object System.Drawing.Font($mono, 8.5, [System.Drawing.FontStyle]::Bold)
$gB.DrawString("$boltChar RDN 85%", $fOuter, $brushNeon, 50 + 56, 50 + 58)

# 2. Left Side: Header + Time Capsule + Date
$fHdrP = New-Object System.Drawing.Font($mono, 8.5, [System.Drawing.FontStyle]::Bold)
$fHdrH = New-Object System.Drawing.Font($mono, 13.0, [System.Drawing.FontStyle]::Bold)
$gB.DrawString("root@fsociety:~#", $fHdrP, $brushNeon, 50 + 56, 50 + 96)
$gB.DrawString("HELLO, FRIEND.", $fHdrH, $brushText, 50 + 56, 50 + 114)

# Digital Time Capsule (Left Side)
$capsuleX = 50 + 44
$capsuleY = 50 + 166
$capsuleW = 186
$capsuleH = 92
$capsuleRadius = 42

$pathCap = New-Object System.Drawing.Drawing2D.GraphicsPath
$pathCap.AddArc($capsuleX, $capsuleY, $capsuleRadius, $capsuleRadius, 180, 90)
$pathCap.AddArc($capsuleX + $capsuleW - $capsuleRadius, $capsuleY, $capsuleRadius, $capsuleRadius, 270, 90)
$pathCap.AddArc($capsuleX + $capsuleW - $capsuleRadius, $capsuleY + $capsuleH - $capsuleRadius, $capsuleRadius, $capsuleRadius, 0, 90)
$pathCap.AddArc($capsuleX, $capsuleY + $capsuleH - $capsuleRadius, $capsuleRadius, $capsuleRadius, 90, 90)
$pathCap.CloseFigure()

$brushCapsule = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(32, 18, 50))
$gB.FillPath($brushCapsule, $pathCap)
$gB.DrawPath($penBorder, $pathCap)

# Clock inside Capsule (Mr. Robot font - HUGE HH:MM)
$fClockCap = New-Object System.Drawing.Font($mrRobot, 46, [System.Drawing.FontStyle]::Regular)
$timeHHMM = (Get-Date).ToString("HH:mm")
$gB.DrawString($timeHHMM, $fClockCap, $brushNeon, [System.Drawing.RectangleF]::FromLTRB($capsuleX, $capsuleY + 14, $capsuleX + $capsuleW, $capsuleY + $capsuleH), $sfCenter)

# Under Capsule: Date & Prompt
$fDateB = New-Object System.Drawing.Font($mono, 9, [System.Drawing.FontStyle]::Bold)
$gB.DrawString("> " + (Get-Date).ToString("yyyy.MM.dd"), $fDateB, $brushText, 50 + 48, 50 + 276)
$gB.DrawString("fsociety // pwned", $fDateB, $brushNeon, 50 + 48, 50 + 296)
$gB.DrawString("root@fsociety:~# _", $fHdrP, $brushNeon, 50 + 48, 50 + 316)

# 3. Right Side: 3 Stacked Arc Gauges (Steps, BPM, Weather) - DIRECTLY FROM PHOTO!
# Pod radius: 38 (diameter 76px)
# Gauge 1: Steps (Top-Right)
Draw-ArcGaugePro $gB (50 + 316) (50 + 108) 38 84 "[STP]" "8,420" "$stepChar STEPS"
# Gauge 2: Heart Rate (Mid-Right)
Draw-ArcGaugePro $gB (50 + 338) (50 + 225) 40 74 "[BPM]" "71" "$heartChar bpm"
# Gauge 3: Weather (Bottom-Right)
Draw-ArcGaugePro $gB (50 + 316) (50 + 342) 38 65 "[WTH]" "21$degChar`C" "WTH"

$bmpB.Save("F:\Dev\techIncubator\watchFace\design_B_photo_track.png", [System.Drawing.Imaging.ImageFormat]::Png)
Copy-Item "F:\Dev\techIncubator\watchFace\design_B_photo_track.png" "C:\Users\mario.marques\.gemini\antigravity-cli\brain\b0ce02aa-35a7-4ecd-a25b-6d8896edb36c\design_B_photo_track.png" -Force

Write-Host "Both pro designs generated successfully!"
