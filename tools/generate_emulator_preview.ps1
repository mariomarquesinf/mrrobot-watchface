Add-Type -AssemblyName System.Drawing

$pfc = New-Object System.Drawing.Text.PrivateFontCollection
$pfc.AddFontFile("$pwd\app\src\main\res\font\mr_robot.ttf")
$pfc.AddFontFile("$pwd\app\src\main\res\font\roboto_mono_bold.ttf")
$mrRobot = $pfc.Families | Where-Object { $_.Name -like "*Robot*" } | Select-Object -First 1
$mono    = $pfc.Families | Where-Object { $_.Name -like "*Roboto*" -or $_.Name -like "*Mono*" } | Select-Object -First 1

$bmp = New-Object System.Drawing.Bitmap 550, 550
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# Case Background
$g.Clear([System.Drawing.Color]::FromArgb(18, 18, 22))

# Outer Case & Crown
$caseBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(38, 38, 44))
$g.FillEllipse($caseBrush, 35, 35, 480, 480)
$crownBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(85, 85, 92))
$g.FillRectangle($crownBrush, 508, 250, 14, 50)
$bezelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(8, 8, 10))
$g.FillEllipse($bezelBrush, 45, 45, 460, 460)

# Pure Black OLED screen (450x450 at 50,50)
$screenBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
$g.FillEllipse($screenBrush, 50, 50, 450, 450)

# Clip to circular display
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddEllipse(50, 50, 450, 450)
$g.SetClip($path)

# Lavender Neon Theme
$colText   = [System.Drawing.Color]::FromArgb(233, 213, 255) # E9D5FF
$colNeon   = [System.Drawing.Color]::FromArgb(192, 132, 252) # C084FC
$colDark   = [System.Drawing.Color]::FromArgb(76, 29, 149)   # 4C1D95
$colSubtle = [System.Drawing.Color]::FromArgb(40, 20, 70)
$colCardBg = [System.Drawing.Color]::FromArgb(16, 10, 26)

$brushText = New-Object System.Drawing.SolidBrush($colText)
$brushNeon = New-Object System.Drawing.SolidBrush($colNeon)
$brushDark = New-Object System.Drawing.SolidBrush($colDark)
$brushCard = New-Object System.Drawing.SolidBrush($colCardBg)
$penBorder = New-Object System.Drawing.Pen($colDark, 1.2)
$penNeon   = New-Object System.Drawing.Pen($colNeon, 1.0)
$penSubtle = New-Object System.Drawing.Pen($colSubtle, 1.0)

$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

    # 1. Bezel Arcs Setup
    $cx = 50 + 225; $cy = 50 + 225; $d = 390; $rx = $cx - $d/2; $ry = $cy - $d/2
    $penTrack = New-Object System.Drawing.Pen($colSubtle, 15.0)
    $penTrack.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $penTrack.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
    $penNeonArc = New-Object System.Drawing.Pen($colNeon, 15.0)
    $penNeonArc.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $penNeonArc.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round

    # Outer thin accent ring
    $penThinAccent = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(26, 13, 46), 1.0)
    $g.DrawEllipse($penThinAccent, 50 + 12, 50 + 12, 426, 426)

    # Function to draw Curved Text along circular path
    function DrawCurvedText($text, $font, $brush, $centerX, $centerY, $radius, $centerAngleDeg, $clockwise = $true) {
        if ([string]::IsNullOrEmpty($text)) { return }
        $chars = $text.ToCharArray()
        # Measure characters
        $totalWidth = 0.0
        $widths = @()
        foreach ($c in $chars) {
            $sz = $g.MeasureString($c.ToString(), $font)
            $w = $sz.Width * 0.72
            $widths += $w
            $totalWidth += $w
        }
        $totalSpanDeg = ($totalWidth / $radius) * (180.0 / [Math]::PI)
        $currentAngle = if ($clockwise) { $centerAngleDeg - ($totalSpanDeg / 2.0) } else { $centerAngleDeg + ($totalSpanDeg / 2.0) }

        for ($i = 0; $i -lt $chars.Length; $i++) {
            $c = $chars[$i]
            $w = $widths[$i]
            $charSpanDeg = ($w / $radius) * (180.0 / [Math]::PI)
            $midAngle = if ($clockwise) { $currentAngle + ($charSpanDeg / 2.0) } else { $currentAngle - ($charSpanDeg / 2.0) }
            
            # Angle 0 is 12 o'clock, 90 is 3 o'clock
            $rad = ($midAngle - 90) * [Math]::PI / 180.0
            $px = $centerX + $radius * [Math]::Cos($rad)
            $py = $centerY + $radius * [Math]::Sin($rad)

            $state = $g.Save()
            $g.TranslateTransform($px, $py)
            $rotDeg = if ($clockwise) { $midAngle } else { $midAngle + 180 }
            $g.RotateTransform($rotDeg)
            $g.DrawString($c.ToString(), $font, $brush, 0, 0, $sfCenter)
            $g.Restore($state)

            if ($clockwise) {
                $currentAngle += $charSpanDeg
            } else {
                $currentAngle -= $charSpanDeg
            }
        }
    }

    # Function to draw an icon on the circle perimeter
    function DrawCurvedIcon($iconType, $brush, $centerX, $centerY, $radius, $angleDeg) {
        $rad = ($angleDeg - 90) * [Math]::PI / 180.0
        $ix = $centerX + $radius * [Math]::Cos($rad)
        $iy = $centerY + $radius * [Math]::Sin($rad)

        $state = $g.Save()
        $g.TranslateTransform($ix, $iy)
        $g.RotateTransform($angleDeg)

        switch ($iconType) {
            'weather' {
                # Sun with rays
                $g.FillEllipse($brush, -6, -6, 12, 12)
                $penRay = New-Object System.Drawing.Pen($brush.Color, 1.5)
                for ($r = 0; $r -lt 360; $r += 45) {
                    $rRad = $r * [Math]::PI / 180.0
                    $g.DrawLine($penRay, [float](9 * [Math]::Cos($rRad)), [float](9 * [Math]::Sin($rRad)), [float](12 * [Math]::Cos($rRad)), [float](12 * [Math]::Sin($rRad)))
                }
            }
            'heart' {
                $g.FillEllipse($brush, -8, -6, 8, 8)
                $g.FillEllipse($brush, 0, -6, 8, 8)
                $pts = @(
                    [System.Drawing.PointF]::new(-8, -2),
                    [System.Drawing.PointF]::new(8, -2),
                    [System.Drawing.PointF]::new(0, 8)
                )
                $g.FillPolygon($brush, $pts)
            }
            'battery' {
                $penB = New-Object System.Drawing.Pen($brush.Color, 1.5)
                $g.DrawRectangle($penB, -6, -8, 12, 16)
                $g.FillRectangle($brush, -3, -10, 6, 2)
                $g.FillRectangle($brush, -4, -4, 8, 10)
            }
            'steps' {
                $g.FillEllipse($brush, -4, -7, 8, 10)
                $g.FillEllipse($brush, -3, 4, 6, 4)
            }
        }
        $g.Restore($state)
    }

    $fCurvedVal = New-Object System.Drawing.Font($mono, 18, [System.Drawing.FontStyle]::Bold)
    $degChar = [char]0x00B0

    # ========================================================
    # 4 BEZEL COMPLICATIONS (NATIVE PIXEL WATCH ARCS, IMAGE 1)
    # ========================================================
    # Slot 0: Top-Left (Weather: 304° - 334°) -> NO ARC!
    DrawCurvedIcon 'weather' $brushNeon $cx $cy ($d/2) 304
    DrawCurvedText "24$degChar" $fCurvedVal $brushText $cx $cy ($d/2) 324 $true

    # Slot 1: Top-Right (Heart Rate: 30° - 62°) -> NO ARC!
    DrawCurvedIcon 'heart' $brushNeon $cx $cy ($d/2) 30
    DrawCurvedText '72' $fCurvedVal $brushText $cx $cy ($d/2) 51 $true

    # Slot 2: Bottom-Left (Readiness: 196° - 256°) -> RANGED VALUE
    DrawCurvedIcon 'battery' $brushNeon $cx $cy ($d/2) 196
    DrawCurvedText '88%' $fCurvedVal $brushText $cx $cy ($d/2) 214 $true
    # Thick target bar (30° sweep: 226° to 256°)
    $g.DrawArc($penTrack, $rx, $ry, $d, $d, (226 - 90), 30)
    $g.DrawArc($penNeonArc, $rx, $ry, $d, $d, (226 - 90), 24)

    # Slot 3: Bottom-Right (Steps: 108° - 170°) -> RANGED VALUE
    DrawCurvedIcon 'steps' $brushNeon $cx $cy ($d/2) 108
    DrawCurvedText '7 410' $fCurvedVal $brushText $cx $cy ($d/2) 127 $true
    # Thick target bar (30° sweep: 140° to 170°)
    $g.DrawArc($penTrack, $rx, $ry, $d, $d, (140 - 90), 30)
    $g.DrawArc($penNeonArc, $rx, $ry, $d, $d, (140 - 90), 20)

    # 2. Terminal Header (Centered, 12pt & 18pt bold)
    $fPrompt = New-Object System.Drawing.Font($mono, 12, [System.Drawing.FontStyle]::Bold)
    $fHello  = New-Object System.Drawing.Font($mono, 18, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("root@fsociety:~#", $fPrompt, $brushNeon, $cx, 50 + 64, $sfCenter)
    $g.DrawString("HELLO, FRIEND.", $fHello, $brushText, $cx, 50 + 88, $sfCenter)

    # 3. Hero Clock (Mr. Robot Font 42pt with seconds)
    $fClock = New-Object System.Drawing.Font($mrRobot, 42, [System.Drawing.FontStyle]::Regular)
    $timeStr = (Get-Date).ToString("HH:mm:ss")
    $g.DrawString($timeStr, $fClock, $brushNeon, [System.Drawing.RectangleF]::FromLTRB(50, 50 + 112, 50 + 450, 50 + 180), $sfCenter)

    # 4. System Date (13pt Bold)
    $fDate = New-Object System.Drawing.Font($mono, 13, [System.Drawing.FontStyle]::Bold)
    $dateStr = "> SYS_DATE: " + (Get-Date).ToString("yyyy.MM.dd") + " // " + (Get-Date).ToString("ddd").ToUpper()
    $g.DrawString($dateStr, $fDate, $brushText, $cx, 50 + 196, $sfCenter)
    $g.DrawLine($penBorder, 50 + 85, 50 + 216, 50 + 365, 50 + 216)

    # 5. Bold, Readable Hacker Telemetry (12pt Bold, No micro-text!)
    $fTeleB = New-Object System.Drawing.Font($mono, 12, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("FSOCIETY_OS // ENCRYPT: AES-256", $fTeleB, $brushNeon, $cx, 50 + 236, $sfCenter)
    $g.DrawString("STATUS: ROOT PRIVILEGES GRANTED", $fTeleB, $brushText, $cx, 50 + 258, $sfCenter)
    $g.DrawLine($penBorder, 50 + 110, 50 + 274, 50 + 340, 50 + 274)

    # 6. Terminal Footer (Centered, 13pt bold)
    $g.DrawString("root@fsociety:~# _", $fDate, $brushNeon, $cx, 50 + 320, $sfCenter)

    $bmp.Save("$pwd\emulator_preview.png", [System.Drawing.Imaging.ImageFormat]::Png)
    Copy-Item "$pwd\emulator_preview.png" "C:\Users\mario.marques\.gemini\antigravity-cli\brain\b0ce02aa-35a7-4ecd-a25b-6d8896edb36c\mrrobot_emulator_preview.png" -Force

    # Save to preview.jpg for Wear OS
    $bmpSquare = New-Object System.Drawing.Bitmap 450, 450
    $gSquare = [System.Drawing.Graphics]::FromImage($bmpSquare)
    $gSquare.DrawImage($bmp, [System.Drawing.Rectangle]::new(0, 0, 450, 450), [System.Drawing.Rectangle]::new(50, 50, 450, 450), [System.Drawing.GraphicsUnit]::Pixel)
    $bmpSquare.Save("$pwd\app\src\main\res\drawable\preview.jpg", [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $gSquare.Dispose()
    $bmpSquare.Dispose()

    Write-Host "emulator_preview.png and app/src/main/res/drawable/preview.jpg updated with Bezel Arcs HUD!"
