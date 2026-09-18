Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# Load Custom Fonts
$pfc = New-Object System.Drawing.Text.PrivateFontCollection
$fontRobotPath = "$PSScriptRoot\app\src\main\res\font\mr_robot.ttf"
$fontMonoPath  = "$PSScriptRoot\app\src\main\res\font\roboto_mono_bold.ttf"

if (Test-Path $fontRobotPath) { $pfc.AddFontFile($fontRobotPath) }
if (Test-Path $fontMonoPath)  { $pfc.AddFontFile($fontMonoPath) }

$mrRobotFontFamily = $pfc.Families | Where-Object { $_.Name -like "*Robot*" } | Select-Object -First 1
$monoFontFamily    = $pfc.Families | Where-Object { $_.Name -like "*Roboto*" -or $_.Name -like "*Mono*" } | Select-Object -First 1

# Color Themes
$themes = @{
    "Lavanda (Default)" = @{
        Text = [System.Drawing.Color]::FromArgb(233, 213, 255) # E9D5FF
        Neon = [System.Drawing.Color]::FromArgb(192, 132, 252) # C084FC
        Dark = [System.Drawing.Color]::FromArgb(76, 29, 149)   # 4C1D95
        Sub  = [System.Drawing.Color]::FromArgb(40, 20, 70)
        Bg   = [System.Drawing.Color]::FromArgb(16, 10, 26)
    }
    "fsociety Red" = @{
        Text = [System.Drawing.Color]::FromArgb(255, 228, 230) # FFE4E6
        Neon = [System.Drawing.Color]::FromArgb(244, 63, 94)   # F43F5E
        Dark = [System.Drawing.Color]::FromArgb(136, 19, 55)   # 881337
        Sub  = [System.Drawing.Color]::FromArgb(60, 10, 25)
        Bg   = [System.Drawing.Color]::FromArgb(24, 8, 14)
    }
    "Kali Green" = @{
        Text = [System.Drawing.Color]::FromArgb(220, 252, 231) # DCFCE7
        Neon = [System.Drawing.Color]::FromArgb(34, 197, 94)   # 22C55E
        Dark = [System.Drawing.Color]::FromArgb(20, 83, 45)    # 14532D
        Sub  = [System.Drawing.Color]::FromArgb(10, 40, 20)
        Bg   = [System.Drawing.Color]::FromArgb(8, 22, 12)
    }
    "Cyber Cyan" = @{
        Text = [System.Drawing.Color]::FromArgb(224, 242, 254) # E0F2FE
        Neon = [System.Drawing.Color]::FromArgb(6, 182, 212)   # 06B6D4
        Dark = [System.Drawing.Color]::FromArgb(22, 78, 99)    # 164E63
        Sub  = [System.Drawing.Color]::FromArgb(10, 35, 45)
        Bg   = [System.Drawing.Color]::FromArgb(8, 18, 26)
    }
    "CRT Amber" = @{
        Text = [System.Drawing.Color]::FromArgb(254, 243, 199) # FEF3C7
        Neon = [System.Drawing.Color]::FromArgb(245, 158, 11)  # F59E0B
        Dark = [System.Drawing.Color]::FromArgb(120, 53, 15)   # 78350F
        Sub  = [System.Drawing.Color]::FromArgb(50, 25, 8)
        Bg   = [System.Drawing.Color]::FromArgb(24, 16, 6)
    }
    "Stealth White" = @{
        Text = [System.Drawing.Color]::FromArgb(255, 255, 255) # FFFFFF
        Neon = [System.Drawing.Color]::FromArgb(203, 213, 225) # CBD5E1
        Dark = [System.Drawing.Color]::FromArgb(51, 65, 85)    # 334155
        Sub  = [System.Drawing.Color]::FromArgb(25, 30, 40)
        Bg   = [System.Drawing.Color]::FromArgb(18, 20, 26)
    }
}

$currentThemeName = "Lavanda (Default)"
$currentTheme = $themes[$currentThemeName]

# Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Pixel Watch 4 Emulator - Mr. Robot Arc HUD Watch Face"
$form.Size = New-Object System.Drawing.Size(620, 700)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 22)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Watch Canvas
$pb = New-Object System.Windows.Forms.PictureBox
$pb.Size = New-Object System.Drawing.Size(550, 550)
$pb.Location = New-Object System.Drawing.Point(30, 15)
$pb.BackColor = [System.Drawing.Color]::Transparent
$form.Controls.Add($pb)

# Draw Function
$DrawWatch = {
    $bmp = New-Object System.Drawing.Bitmap 550, 550
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $g.Clear([System.Drawing.Color]::FromArgb(18, 18, 22))

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

    $t = $themes[$currentThemeName]
    $brushText = New-Object System.Drawing.SolidBrush($t.Text)
    $brushNeon = New-Object System.Drawing.SolidBrush($t.Neon)
    $brushDark = New-Object System.Drawing.SolidBrush($t.Dark)
    $brushCard = New-Object System.Drawing.SolidBrush($t.Bg)
    $penBorder = New-Object System.Drawing.Pen($t.Dark, 1.2)
    $penSubtle = New-Object System.Drawing.Pen($t.Sub, 1.0)

    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
    $sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

    # 1. Bezel Arcs Setup
    $cx = 50 + 225; $cy = 50 + 225; $d = 390; $rx = $cx - $d/2; $ry = $cy - $d/2
    $penTrack = New-Object System.Drawing.Pen($t.Sub, 15.0)
    $penTrack.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $penTrack.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
    $penNeonArc = New-Object System.Drawing.Pen($t.Neon, 15.0)
    $penNeonArc.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $penNeonArc.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round

    # Outer thin accent ring
    $penThinAccent = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(26, 13, 46), 1.0)
    $g.DrawEllipse($penThinAccent, 50 + 12, 50 + 12, 426, 426)

    # Function to draw Curved Text along circular path
    function DrawCurvedText($text, $font, $brush, $centerX, $centerY, $radius, $centerAngleDeg, $clockwise = $true) {
        if ([string]::IsNullOrEmpty($text)) { return }
        $chars = $text.ToCharArray()
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

    $fCurvedVal = New-Object System.Drawing.Font($monoFontFamily, 18, [System.Drawing.FontStyle]::Bold)
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
    $fPrompt = New-Object System.Drawing.Font($monoFontFamily, 12, [System.Drawing.FontStyle]::Bold)
    $fHello  = New-Object System.Drawing.Font($monoFontFamily, 18, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("root@fsociety:~#", $fPrompt, $brushNeon, $cx, 50 + 64, $sfCenter)
    $g.DrawString("HELLO, FRIEND.", $fHello, $brushText, $cx, 50 + 88, $sfCenter)

    # 3. Hero Clock (Mr. Robot Font 42pt with seconds)
    $fClock = New-Object System.Drawing.Font($mrRobotFontFamily, 42, [System.Drawing.FontStyle]::Regular)
    $timeStr = (Get-Date).ToString("HH:mm:ss")
    $g.DrawString($timeStr, $fClock, $brushNeon, [System.Drawing.RectangleF]::FromLTRB(50, 50 + 112, 50 + 450, 50 + 180), $sfCenter)

    # 4. System Date (13pt Bold)
    $fDate = New-Object System.Drawing.Font($monoFontFamily, 13, [System.Drawing.FontStyle]::Bold)
    $dateStr = "> SYS_DATE: " + (Get-Date).ToString("yyyy.MM.dd") + " // " + (Get-Date).ToString("ddd").ToUpper()
    $g.DrawString($dateStr, $fDate, $brushText, $cx, 50 + 196, $sfCenter)
    $g.DrawLine($penBorder, 50 + 85, 50 + 216, 50 + 365, 50 + 216)

    # 5. Bold, Readable Hacker Telemetry (12pt Bold, No micro-text!)
    $fTeleB = New-Object System.Drawing.Font($monoFontFamily, 12, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("FSOCIETY_OS // ENCRYPT: AES-256", $fTeleB, $brushNeon, $cx, 50 + 236, $sfCenter)
    $g.DrawString("STATUS: ROOT PRIVILEGES GRANTED", $fTeleB, $brushText, $cx, 50 + 258, $sfCenter)
    $g.DrawLine($penBorder, 50 + 110, 50 + 274, 50 + 340, 50 + 274)

    # 6. Terminal Footer (Centered, 13pt bold)
    $g.DrawString("root@fsociety:~# _", $fDate, $brushNeon, $cx, 50 + 320, $sfCenter)

    $oldBmp = $pb.Image
    $pb.Image = $bmp
    if ($oldBmp) { $oldBmp.Dispose() }
}

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({ & $DrawWatch })
$timer.Start()

& $DrawWatch

$panel = New-Object System.Windows.Forms.FlowLayoutPanel
$panel.Location = New-Object System.Drawing.Point(30, 580)
$panel.Size = New-Object System.Drawing.Size(550, 60)
$panel.FlowDirection = "LeftToRight"
$form.Controls.Add($panel)

$themeNames = @("Lavanda (Default)", "fsociety Red", "Kali Green", "Cyber Cyan", "CRT Amber", "Stealth White")
$themeColors = @(
    [System.Drawing.Color]::FromArgb(192, 132, 252),
    [System.Drawing.Color]::FromArgb(244, 63, 94),
    [System.Drawing.Color]::FromArgb(34, 197, 94),
    [System.Drawing.Color]::FromArgb(6, 182, 212),
    [System.Drawing.Color]::FromArgb(245, 158, 11),
    [System.Drawing.Color]::FromArgb(203, 213, 225)
)

for ($i = 0; $i -lt $themeNames.Count; $i++) {
    $btn = New-Object System.Windows.Forms.Button
    $name = $themeNames[$i]
    $btn.Text = $name
    $btn.Tag = $name
    $btn.Width = 85
    $btn.Height = 35
    $btn.FlatStyle = "Flat"
    $btn.ForeColor = $themeColors[$i]
    $btn.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 35)
    $btn.FlatAppearance.BorderColor = $themeColors[$i]
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 7.5, [System.Drawing.FontStyle]::Bold)
    $btn.Add_Click({
        param($sender, $e)
        $script:currentThemeName = $sender.Tag
        & $DrawWatch
    })
    $panel.Controls.Add($btn)
}

$form.ShowDialog() | Out-Null
$form.Dispose()
