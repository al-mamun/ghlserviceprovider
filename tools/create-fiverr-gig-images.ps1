Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $root "output\fiverr-gig-images"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$portraitPath = "D:\personal\my pic\my-pro.jpeg"
$w = 1280
$h = 769

function New-Bmp {
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    return @($bmp, $g)
}

function Brush($hex) {
    return New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($hex))
}

function Pen($hex, $size = 1) {
    return New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml($hex), $size)
}

function Font($name, $size, $style = [System.Drawing.FontStyle]::Regular) {
    return New-Object System.Drawing.Font($name, $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function RoundRectPath($x, $y, $width, $height, $radius) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $radius * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $width - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $width - $d, $y + $height - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $height - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function FillRound($g, $x, $y, $width, $height, $radius, $color) {
    $p = RoundRectPath $x $y $width $height $radius
    $g.FillPath((Brush $color), $p)
}

function StrokeRound($g, $x, $y, $width, $height, $radius, $color, $size = 2) {
    $p = RoundRectPath $x $y $width $height $radius
    $g.DrawPath((Pen $color $size), $p)
}

function DrawText($g, $text, $font, $color, $x, $y, $width, $height, $align = "Near") {
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = [System.Drawing.StringAlignment]::$align
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Near
    $g.DrawString($text, $font, (Brush $color), (New-Object System.Drawing.RectangleF($x, $y, $width, $height)), $fmt)
}

function DrawCenteredText($g, $text, $font, $color, $x, $y, $width, $height) {
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = [System.Drawing.StringAlignment]::Center
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($text, $font, (Brush $color), (New-Object System.Drawing.RectangleF($x, $y, $width, $height)), $fmt)
}

function DrawCheck($g, $x, $y, $size = 22) {
    $pen = Pen "#20C997" 5
    $g.DrawLines($pen, @(
        [System.Drawing.PointF]::new($x, $y + $size * .48),
        [System.Drawing.PointF]::new($x + $size * .35, $y + $size * .82),
        [System.Drawing.PointF]::new($x + $size, $y)
    ))
}

function DrawBrowserCard($g, $x, $y, $width, $height, $title, $accent, $broken) {
    FillRound $g $x $y $width $height 18 "#FFFFFF"
    StrokeRound $g $x $y $width $height 18 "#D9E3EE" 2
    FillRound $g ($x + 20) ($y + 18) ($width - 40) 38 10 "#F3F7FB"
    $g.FillEllipse((Brush "#FF5F57"), $x + 36, $y + 31, 12, 12)
    $g.FillEllipse((Brush "#FFBD2E"), $x + 56, $y + 31, 12, 12)
    $g.FillEllipse((Brush "#28C840"), $x + 76, $y + 31, 12, 12)
    DrawText $g $title (Font "Segoe UI" 18 ([System.Drawing.FontStyle]::Bold)) "#263445" ($x + 24) ($y + 72) ($width - 48) 36

    if ($broken) {
        FillRound $g ($x + 26) ($y + 126) ($width - 52) 52 8 "#FFE8E8"
        DrawText $g "Form error" (Font "Segoe UI" 20 ([System.Drawing.FontStyle]::Bold)) "#C73535" ($x + 46) ($y + 136) 220 40
        $g.DrawLine((Pen "#EF4444" 5), $x + 34, $y + 220, $x + $width - 34, $y + 198)
        $g.DrawLine((Pen "#EF4444" 5), $x + 34, $y + 250, $x + $width - 78, $y + 284)
        FillRound $g ($x + 34) ($y + 318) 128 44 8 "#FEE2E2"
        DrawCenteredText $g "404" (Font "Segoe UI" 23 ([System.Drawing.FontStyle]::Bold)) "#B91C1C" ($x + 34) ($y + 318) 128 44
        FillRound $g ($x + 182) ($y + 318) ($width - 216) 44 8 "#FEE2E2"
    } else {
        FillRound $g ($x + 26) ($y + 126) ($width - 52) 52 8 "#E9FFF6"
        DrawText $g "Working form" (Font "Segoe UI" 20 ([System.Drawing.FontStyle]::Bold)) "#087F5B" ($x + 46) ($y + 136) 240 40
        DrawCheck $g ($x + $width - 76) ($y + 140) 26
        FillRound $g ($x + 34) ($y + 212) ($width - 68) 20 5 "#D6E4F0"
        FillRound $g ($x + 34) ($y + 246) ($width - 124) 20 5 "#D6E4F0"
        FillRound $g ($x + 34) ($y + 294) 136 50 10 $accent
        DrawCenteredText $g "Fixed" (Font "Segoe UI" 22 ([System.Drawing.FontStyle]::Bold)) "#FFFFFF" ($x + 34) ($y + 294) 136 50
        FillRound $g ($x + 194) ($y + 294) ($width - 228) 50 10 "#EEF5FA"
    }
}

function DrawCompactBrowserCard($g, $x, $y, $width, $height, $title, $accent, $broken) {
    DrawSoftShadow $g $x $y $width $height 18
    FillRound $g $x $y $width $height 18 "#FFFFFF"
    StrokeRound $g $x $y $width $height 18 "#D9E3EE" 2
    FillRound $g ($x + 20) ($y + 18) ($width - 40) 38 10 "#F3F7FB"
    $g.FillEllipse((Brush "#FF5F57"), $x + 36, $y + 31, 12, 12)
    $g.FillEllipse((Brush "#FFBD2E"), $x + 56, $y + 31, 12, 12)
    $g.FillEllipse((Brush "#28C840"), $x + 76, $y + 31, 12, 12)
    DrawText $g $title (Font "Segoe UI" 18 ([System.Drawing.FontStyle]::Bold)) "#263445" ($x + 24) ($y + 72) ($width - 48) 34

    if ($broken) {
        FillRound $g ($x + 26) ($y + 118) ($width - 52) 48 8 "#FFE8E8"
        DrawText $g "Form error" (Font "Segoe UI" 20 ([System.Drawing.FontStyle]::Bold)) "#C73535" ($x + 46) ($y + 128) 220 34
        $g.DrawLine((Pen "#EF4444" 5), $x + 34, $y + 198, $x + $width - 34, $y + 178)
        $g.DrawLine((Pen "#EF4444" 5), $x + 34, $y + 228, $x + $width - 78, $y + 252)
        FillRound $g ($x + 34) ($y + 278) 128 40 8 "#FEE2E2"
        DrawCenteredText $g "404" (Font "Segoe UI" 22 ([System.Drawing.FontStyle]::Bold)) "#B91C1C" ($x + 34) ($y + 278) 128 40
        FillRound $g ($x + 182) ($y + 278) ($width - 216) 40 8 "#FEE2E2"
    } else {
        FillRound $g ($x + 26) ($y + 118) ($width - 52) 48 8 "#E9FFF6"
        DrawText $g "Working form" (Font "Segoe UI" 20 ([System.Drawing.FontStyle]::Bold)) "#087F5B" ($x + 46) ($y + 128) 240 34
        DrawCheck $g ($x + $width - 76) ($y + 130) 26
        FillRound $g ($x + 34) ($y + 190) ($width - 68) 18 5 "#D6E4F0"
        FillRound $g ($x + 34) ($y + 224) ($width - 124) 18 5 "#D6E4F0"
        FillRound $g ($x + 34) ($y + 272) 136 46 10 $accent
        DrawCenteredText $g "Fixed" (Font "Segoe UI" 22 ([System.Drawing.FontStyle]::Bold)) "#FFFFFF" ($x + 34) ($y + 272) 136 46
        FillRound $g ($x + 194) ($y + 272) ($width - 228) 46 10 "#EEF5FA"
    }
}

function DrawCodeCard($g, $x, $y, $width, $height) {
    FillRound $g $x $y $width $height 18 "#111827"
    StrokeRound $g $x $y $width $height 18 "#243244" 2
    FillRound $g ($x + 22) ($y + 20) ($width - 44) 40 10 "#182235"
    $g.FillEllipse((Brush "#FF5F57"), $x + 42, $y + 34, 12, 12)
    $g.FillEllipse((Brush "#FFBD2E"), $x + 64, $y + 34, 12, 12)
    $g.FillEllipse((Brush "#28C840"), $x + 86, $y + 34, 12, 12)
    $lines = @(
        "const issue = findBug(site);",
        "fix(forms, layout, css);",
        "test(mobile, desktop);",
        "deploy(cleanCode);"
    )
    $colors = @("#8BE9FD", "#50FA7B", "#F1FA8C", "#BD93F9")
    for ($i = 0; $i -lt $lines.Length; $i++) {
        DrawText $g $lines[$i] (Font "Consolas" 25 ([System.Drawing.FontStyle]::Regular)) $colors[$i] ($x + 44) ($y + 94 + $i * 54) ($width - 88) 40
    }
}

function DrawPill($g, $text, $x, $y, $width, $color = "#EEF5FA", $textColor = "#1F2937") {
    FillRound $g $x $y $width 46 23 $color
    DrawCenteredText $g $text (Font "Segoe UI" 20 ([System.Drawing.FontStyle]::Bold)) $textColor $x $y $width 46
}

function FillRoundGradient($g, $x, $y, $width, $height, $radius, $from, $to, $angle = 0) {
    $rect = New-Object System.Drawing.Rectangle($x, $y, $width, $height)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect,
        [System.Drawing.ColorTranslator]::FromHtml($from),
        [System.Drawing.ColorTranslator]::FromHtml($to),
        $angle
    )
    $p = RoundRectPath $x $y $width $height $radius
    $g.FillPath($brush, $p)
}

function DrawSoftShadow($g, $x, $y, $width, $height, $radius) {
    for ($i = 8; $i -ge 1; $i--) {
        $alpha = 7 * $i
        $color = [System.Drawing.Color]::FromArgb($alpha, 0, 0, 0)
        $brush = New-Object System.Drawing.SolidBrush($color)
        $p = RoundRectPath ($x - $i) ($y - $i) ($width + $i * 2) ($height + $i * 2) ($radius + $i)
        $g.FillPath($brush, $p)
    }
}

function DrawPremiumBg($g) {
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle(0,0,$w,$h)),
        [System.Drawing.ColorTranslator]::FromHtml("#07111F"),
        [System.Drawing.ColorTranslator]::FromHtml("#10243A"),
        28
    )
    $g.FillRectangle($bg, 0, 0, $w, $h)
    $gridPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(22, 255, 255, 255), 1)
    for ($gx = 0; $gx -le $w; $gx += 80) { $g.DrawLine($gridPen, $gx, 0, $gx, $h) }
    for ($gy = 0; $gy -le $h; $gy += 80) { $g.DrawLine($gridPen, 0, $gy, $w, $gy) }
    $glow = New-Object System.Drawing.Drawing2D.PathGradientBrush((RoundRectPath 720 -160 640 560 280))
    $glow.CenterColor = [System.Drawing.Color]::FromArgb(70, 32, 201, 151)
    $glow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 32, 201, 151))
    $g.FillPath($glow, (RoundRectPath 720 -160 640 560 280))
    $glow2 = New-Object System.Drawing.Drawing2D.PathGradientBrush((RoundRectPath -180 430 560 460 230))
    $glow2.CenterColor = [System.Drawing.Color]::FromArgb(54, 14, 165, 233)
    $glow2.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 14, 165, 233))
    $g.FillPath($glow2, (RoundRectPath -180 430 560 460 230))
}

function DrawPortraitCircle($g, $path, $x, $y, $size) {
    if (-not (Test-Path $path)) { return }
    $img = [System.Drawing.Image]::FromFile($path)
    $clip = New-Object System.Drawing.Drawing2D.GraphicsPath
    $clip.AddEllipse($x, $y, $size, $size)
    $oldClip = $g.Clip
    $g.SetClip($clip)
    $srcW = $img.Width
    $srcH = $img.Height
    $side = [Math]::Min($srcW, $srcH)
    $srcX = [Math]::Max(0, [int](($srcW - $side) / 2))
    $srcY = [Math]::Max(0, [int](($srcH - $side) / 8))
    $g.DrawImage($img, (New-Object System.Drawing.Rectangle($x, $y, $size, $size)), $srcX, $srcY, $side, $side, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Clip = $oldClip
    $g.DrawEllipse((Pen "#FFFFFF" 8), $x, $y, $size, $size)
    $g.DrawEllipse((Pen "#20C997" 5), $x + 4, $y + 4, $size - 8, $size - 8)
    $img.Dispose()
}

function SavePng($bmp, $g, $name) {
    $path = Join-Path $outDir $name
    $g.Dispose()
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host $path
}

# Image 1: main click-focused thumbnail.
$pair = New-Bmp
$bmp = $pair[0]; $g = $pair[1]
DrawPremiumBg $g
FillRoundGradient $g 30 30 1220 709 28 "#0B1726" "#0F2A3D" 30
StrokeRound $g 30 30 1220 709 28 "#20C997" 3
StrokeRound $g 42 42 1196 685 24 "#203A4D" 1
DrawText $g "Professional Website Repair" (Font "Segoe UI" 31 ([System.Drawing.FontStyle]::Bold)) "#20C997" 74 58 560 46
DrawText $g "Website Bug Fix" (Font "Segoe UI" 70 ([System.Drawing.FontStyle]::Bold)) "#FFFFFF" 72 124 650 84
DrawText $g "Forms, CSS, Layout & Mobile Issues" (Font "Segoe UI" 31 ([System.Drawing.FontStyle]::Regular)) "#C9D6E4" 76 212 650 48
DrawPill $g "CSS" 78 290 110 "#E8F7FF" "#075985"
DrawPill $g "Forms" 206 290 128 "#E9FFF6" "#087F5B"
DrawPill $g "Mobile" 352 290 138 "#FFF4E6" "#B45309"
DrawPill $g "JS/PHP" 508 290 132 "#EDEBFF" "#4C1D95"
DrawCompactBrowserCard $g 78 386 456 330 "Broken Website" "#EF4444" $true
DrawCompactBrowserCard $g 720 386 456 330 "Fixed Website" "#20C997" $false
$arrowPen = Pen "#20C997" 14
$arrowPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
$g.DrawLine($arrowPen, 570, 505, 688, 505)
DrawSoftShadow $g 678 286 490 66 33
FillRoundGradient $g 678 286 490 66 33 "#20C997" "#22C55E" 0
DrawCenteredText $g "Fast, clean and tested fixes" (Font "Segoe UI" 28 ([System.Drawing.FontStyle]::Bold)) "#062C22" 678 286 490 66
SavePng $bmp $g "website-bug-fix-main.png"

# Image 2: skills/services.
$pair = New-Bmp
$bmp = $pair[0]; $g = $pair[1]
DrawPremiumBg $g
StrokeRound $g 30 30 1220 709 28 "#203A4D" 2
DrawText $g "Fix Frontend & Backend Issues" (Font "Segoe UI" 54 ([System.Drawing.FontStyle]::Bold)) "#FFFFFF" 70 56 900 72
DrawText $g "HTML, CSS, JavaScript, React, Next.js, Node.js, PHP, Laravel, WordPress and databases" (Font "Segoe UI" 24 ([System.Drawing.FontStyle]::Regular)) "#C9D6E4" 74 135 1080 70
DrawSoftShadow $g 74 236 514 356 18
DrawCodeCard $g 74 236 514 356
$pillData = @(
    @("HTML", 666, 244, 136, "#FFFFFF", "#102033"),
    @("CSS", 824, 244, 118, "#E8F7FF", "#075985"),
    @("JavaScript", 964, 244, 196, "#FFF8DB", "#8A5A00"),
    @("React", 666, 314, 142, "#EDEBFF", "#4C1D95"),
    @("Next.js", 830, 314, 150, "#FFFFFF", "#111827"),
    @("Node.js", 1002, 314, 158, "#E9FFF6", "#087F5B"),
    @("PHP", 666, 384, 116, "#EEF2FF", "#3730A3"),
    @("Laravel", 804, 384, 162, "#FFECEC", "#B91C1C"),
    @("WordPress", 988, 384, 190, "#E8F7FF", "#075985"),
    @("Database", 666, 454, 178, "#F3F7FB", "#263445"),
    @("API Fix", 866, 454, 152, "#E9FFF6", "#087F5B"),
    @("Responsive", 1040, 454, 186, "#FFF4E6", "#B45309")
)
foreach ($p in $pillData) { DrawPill $g $p[0] $p[1] $p[2] $p[3] $p[4] $p[5] }
DrawSoftShadow $g 666 590 506 58 29
FillRoundGradient $g 666 590 506 58 29 "#20C997" "#22C55E" 0
DrawCenteredText $g "Clean code. Tested delivery." (Font "Segoe UI" 24 ([System.Drawing.FontStyle]::Bold)) "#062C22" 666 590 506 58
SavePng $bmp $g "website-bug-fix-skills.png"

# Image 3: trust/process with portrait.
$pair = New-Bmp
$bmp = $pair[0]; $g = $pair[1]
DrawPremiumBg $g
DrawSoftShadow $g 62 58 1156 650 30
FillRound $g 62 58 1156 650 30 "#FFFFFF"
StrokeRound $g 62 58 1156 650 30 "#20C997" 4
DrawPortraitCircle $g $portraitPath 92 112 260
DrawText $g "Professional Website Fixes" (Font "Segoe UI" 54 ([System.Drawing.FontStyle]::Bold)) "#102033" 402 104 760 72
DrawText $g "10+ years experience with frontend, backend, WordPress and custom web applications." (Font "Segoe UI" 25 ([System.Drawing.FontStyle]::Regular)) "#4B5B6B" 406 178 720 72
DrawPill $g "Fast Communication" 94 418 252 "#E8F7FF" "#075985"
DrawPill $g "Clean Code" 94 488 252 "#E9FFF6" "#087F5B"
DrawPill $g "Tested Delivery" 94 558 252 "#FFF4E6" "#B45309"
$steps = @(
    @("1", "Check Issue", "Review the bug, page URL, screenshots and access details."),
    @("2", "Fix Bug", "Repair layout, form, CSS, JavaScript, backend or database issue."),
    @("3", "Test Website", "Verify desktop, mobile and core functionality before delivery.")
)
for ($i = 0; $i -lt $steps.Length; $i++) {
    $y = 300 + $i * 128
    FillRound $g 402 $y 736 90 18 "#F3F7FB"
    FillRound $g 428 ($y + 18) 54 54 27 "#20C997"
    DrawCenteredText $g $steps[$i][0] (Font "Segoe UI" 26 ([System.Drawing.FontStyle]::Bold)) "#062C22" 428 ($y + 18) 54 54
    DrawText $g $steps[$i][1] (Font "Segoe UI" 29 ([System.Drawing.FontStyle]::Bold)) "#102033" 506 ($y + 14) 560 38
    DrawText $g $steps[$i][2] (Font "Segoe UI" 20 ([System.Drawing.FontStyle]::Regular)) "#4B5B6B" 506 ($y + 52) 560 34
}
SavePng $bmp $g "website-bug-fix-process.png"
