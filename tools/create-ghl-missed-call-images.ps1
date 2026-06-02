Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $root "output\fiverr-ghl-missed-call-images"
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

function Brush($hex) { New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($hex)) }
function Pen($hex, $size = 1) { New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml($hex), $size) }
function Font($name, $size, $style = [System.Drawing.FontStyle]::Regular) { New-Object System.Drawing.Font($name, $size, $style, [System.Drawing.GraphicsUnit]::Pixel) }

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
        [System.Drawing.ColorTranslator]::FromHtml("#10382F"),
        28
    )
    $g.FillRectangle($bg, 0, 0, $w, $h)
    $gridPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(24, 255, 255, 255), 1)
    for ($x = 0; $x -le $w; $x += 80) { $g.DrawLine($gridPen, $x, 0, $x, $h) }
    for ($y = 0; $y -le $h; $y += 80) { $g.DrawLine($gridPen, 0, $y, $w, $y) }
    $glow = New-Object System.Drawing.Drawing2D.PathGradientBrush((RoundRectPath 760 -140 580 580 290))
    $glow.CenterColor = [System.Drawing.Color]::FromArgb(80, 34, 197, 94)
    $glow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 34, 197, 94))
    $g.FillPath($glow, (RoundRectPath 760 -140 580 580 290))
    $glow2 = New-Object System.Drawing.Drawing2D.PathGradientBrush((RoundRectPath -180 450 520 420 210))
    $glow2.CenterColor = [System.Drawing.Color]::FromArgb(56, 14, 165, 233)
    $glow2.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 14, 165, 233))
    $g.FillPath($glow2, (RoundRectPath -180 450 520 420 210))
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
    $g.DrawEllipse((Pen "#22C55E" 5), $x + 4, $y + 4, $size - 8, $size - 8)
    $img.Dispose()
}

function DrawPhone($g, $x, $y, $width, $height, $missed = $false) {
    DrawSoftShadow $g $x $y $width $height 36
    FillRoundGradient $g $x $y $width $height 36 "#0B1220" "#182235" 35
    FillRound $g ($x + 14) ($y + 16) ($width - 28) ($height - 32) 28 "#FFFFFF"
    FillRound $g ($x + 64) ($y + 30) ($width - 128) 14 7 "#111827"
    DrawCenteredText $g "Missed Call" (Font "Segoe UI" 22 ([System.Drawing.FontStyle]::Bold)) "#111827" ($x + 24) ($y + 72) ($width - 48) 34
    FillRound $g ($x + 38) ($y + 122) ($width - 76) 54 20 "#FEE2E2"
    DrawCenteredText $g "+1 (555) 0184" (Font "Segoe UI" 23 ([System.Drawing.FontStyle]::Bold)) "#B91C1C" ($x + 38) ($y + 122) ($width - 76) 54
    FillRound $g ($x + 54) ($y + 218) 62 62 31 "#EF4444"
    DrawCenteredText $g "X" (Font "Segoe UI" 28 ([System.Drawing.FontStyle]::Bold)) "#FFFFFF" ($x + 54) ($y + 218) 62 62
    FillRound $g ($x + $width - 116) ($y + 218) 62 62 31 "#22C55E"
    DrawCenteredText $g "SMS" (Font "Segoe UI" 17 ([System.Drawing.FontStyle]::Bold)) "#FFFFFF" ($x + $width - 116) ($y + 218) 62 62
}

function DrawSmsCard($g, $x, $y, $width, $height) {
    DrawSoftShadow $g $x $y $width $height 22
    FillRound $g $x $y $width $height 22 "#FFFFFF"
    StrokeRound $g $x $y $width $height 22 "#DCE6EF" 2
    DrawText $g "Auto SMS Reply" (Font "Segoe UI" 24 ([System.Drawing.FontStyle]::Bold)) "#102033" ($x + 26) ($y + 24) ($width - 52) 36
    FillRound $g ($x + 26) ($y + 84) ($width - 52) 82 18 "#E9FFF6"
    DrawText $g "Sorry we missed your call" (Font "Segoe UI" 21 ([System.Drawing.FontStyle]::Bold)) "#087F5B" ($x + 46) ($y + 98) ($width - 92) 58
    FillRound $g ($x + 26) ($y + 196) ($width - 142) 58 18 "#EEF5FA"
    DrawText $g "AI Reply" (Font "Segoe UI" 21 ([System.Drawing.FontStyle]::Bold)) "#263445" ($x + 46) ($y + 210) ($width - 180) 38
    FillRound $g ($x + 26) ($y + 282) ($width - 82) 58 18 "#FFF4E6"
    DrawText $g "CRM pipeline" (Font "Segoe UI" 21 ([System.Drawing.FontStyle]::Bold)) "#B45309" ($x + 46) ($y + 296) ($width - 120) 38
}

function DrawPipeline($g, $x, $y, $width, $height) {
    DrawSoftShadow $g $x $y $width $height 22
    FillRound $g $x $y $width $height 22 "#FFFFFF"
    StrokeRound $g $x $y $width $height 22 "#DCE6EF" 2
    DrawText $g "GoHighLevel Lead Flow" (Font "Segoe UI" 25 ([System.Drawing.FontStyle]::Bold)) "#102033" ($x + 24) ($y + 22) ($width - 48) 34
    $cols = @(
        @("New Lead", "#E8F7FF", "#075985"),
        @("AI Reply", "#EDEBFF", "#4C1D95"),
        @("Booked", "#E9FFF6", "#087F5B")
    )
    for ($i = 0; $i -lt 3; $i++) {
        $cx = $x + 24 + $i * (($width - 64) / 3)
        $cw = (($width - 88) / 3)
        FillRound $g $cx ($y + 92) $cw ($height - 126) 16 "#F3F7FB"
        FillRound $g ($cx + 14) ($y + 112) ($cw - 28) 42 12 $cols[$i][1]
        DrawCenteredText $g $cols[$i][0] (Font "Segoe UI" 18 ([System.Drawing.FontStyle]::Bold)) $cols[$i][2] ($cx + 14) ($y + 112) ($cw - 28) 42
        for ($j = 0; $j -lt 2; $j++) {
            FillRound $g ($cx + 16) ($y + 178 + $j * 72) ($cw - 32) 48 12 "#FFFFFF"
            DrawText $g "Lead #$($j+1)" (Font "Segoe UI" 16 ([System.Drawing.FontStyle]::Bold)) "#263445" ($cx + 30) ($y + 191 + $j * 72) ($cw - 60) 24
        }
    }
}

function SavePng($bmp, $g, $name) {
    $path = Join-Path $outDir $name
    $g.Dispose()
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host $path
}

# Image 1: main thumbnail.
$pair = New-Bmp
$bmp = $pair[0]; $g = $pair[1]
DrawPremiumBg $g
FillRoundGradient $g 30 30 1220 709 28 "#0B1726" "#0B2F28" 30
StrokeRound $g 30 30 1220 709 28 "#2EE59D" 3
StrokeRound $g 42 42 1196 685 24 "#203A4D" 1
DrawText $g "GoHighLevel Automation" (Font "Segoe UI" 31 ([System.Drawing.FontStyle]::Bold)) "#2EE59D" 74 58 520 46
DrawText $g "Missed Call" (Font "Segoe UI" 72 ([System.Drawing.FontStyle]::Bold)) "#FFFFFF" 72 126 570 86
DrawText $g "Text Back" (Font "Segoe UI" 72 ([System.Drawing.FontStyle]::Bold)) "#FFFFFF" 72 205 520 86
DrawText $g "AI Lead Follow-Up System" (Font "Segoe UI" 31 ([System.Drawing.FontStyle]::Regular)) "#C9D6E4" 76 304 560 48
DrawPill $g "SMS" 78 382 110 "#E9FFF6" "#087F5B"
DrawPill $g "AI Reply" 206 382 140 "#EDEBFF" "#4C1D95"
DrawPill $g "Pipeline" 364 382 150 "#E8F7FF" "#075985"
DrawPhone $g 650 98 258 428
DrawSmsCard $g 928 146 278 338
$arrowPen = Pen "#22C55E" 13
$arrowPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
$g.DrawLine($arrowPen, 566, 392, 638, 392)
DrawSoftShadow $g 74 586 620 72 36
FillRoundGradient $g 74 586 620 72 36 "#2EE59D" "#22C55E" 0
DrawCenteredText $g "Never lose a lead from missed calls" (Font "Segoe UI" 31 ([System.Drawing.FontStyle]::Bold)) "#062C22" 74 586 620 72
SavePng $bmp $g "ghl-missed-call-main.png"

# Image 2: workflow/service details.
$pair = New-Bmp
$bmp = $pair[0]; $g = $pair[1]
DrawPremiumBg $g
StrokeRound $g 30 30 1220 709 28 "#203A4D" 2
DrawText $g "Automation Workflow Setup" (Font "Segoe UI" 56 ([System.Drawing.FontStyle]::Bold)) "#FFFFFF" 70 58 900 72
DrawText $g "Missed calls, SMS follow-up, AI replies, pipeline updates and notifications" (Font "Segoe UI" 25 ([System.Drawing.FontStyle]::Regular)) "#C9D6E4" 74 132 1050 42
DrawPipeline $g 72 232 600 374
$steps = @(
    @("1", "Missed Call Trigger", "Lead calls but no one answers"),
    @("2", "Instant SMS Reply", "GoHighLevel sends text back"),
    @("3", "AI Lead Follow Up", "Qualify, reply and guide lead"),
    @("4", "CRM Pipeline Update", "Notify team and track status")
)
for ($i = 0; $i -lt $steps.Length; $i++) {
    $y = 228 + $i * 96
    FillRound $g 726 $y 470 70 16 "#FFFFFF"
    FillRound $g 746 ($y + 16) 38 38 19 "#22C55E"
    DrawCenteredText $g $steps[$i][0] (Font "Segoe UI" 21 ([System.Drawing.FontStyle]::Bold)) "#062C22" 746 ($y + 16) 38 38
    DrawText $g $steps[$i][1] (Font "Segoe UI" 23 ([System.Drawing.FontStyle]::Bold)) "#102033" 804 ($y + 10) 340 30
    DrawText $g $steps[$i][2] (Font "Segoe UI" 17 ([System.Drawing.FontStyle]::Regular)) "#4B5B6B" 804 ($y + 40) 350 22
}
SavePng $bmp $g "ghl-missed-call-workflow.png"

# Image 3: trust/process with portrait.
$pair = New-Bmp
$bmp = $pair[0]; $g = $pair[1]
DrawPremiumBg $g
DrawSoftShadow $g 62 58 1156 650 30
FillRound $g 62 58 1156 650 30 "#FFFFFF"
StrokeRound $g 62 58 1156 650 30 "#2EE59D" 4
DrawPortraitCircle $g $portraitPath 92 112 260
DrawText $g "GoHighLevel Automation" (Font "Segoe UI" 54 ([System.Drawing.FontStyle]::Bold)) "#102033" 402 104 760 72
DrawText $g "Missed call text back, AI lead follow-up, CRM pipeline and workflow setup." (Font "Segoe UI" 25 ([System.Drawing.FontStyle]::Regular)) "#4B5B6B" 406 178 720 72
DrawPill $g "10+ Years Experience" 94 418 252 "#E8F7FF" "#075985"
DrawPill $g "Clean Workflows" 94 488 252 "#E9FFF6" "#087F5B"
DrawPill $g "Tested Setup" 94 558 252 "#FFF4E6" "#B45309"
$steps = @(
    @("1", "Review Account", "Check your phone setup, workflow needs and goal."),
    @("2", "Build Automation", "Set up missed call SMS, AI reply, tags, pipeline and notifications."),
    @("3", "Test & Deliver", "Test the workflow and confirm leads are captured correctly.")
)
for ($i = 0; $i -lt $steps.Length; $i++) {
    $y = 300 + $i * 128
    FillRound $g 402 $y 736 90 18 "#F3F7FB"
    FillRound $g 428 ($y + 18) 54 54 27 "#22C55E"
    DrawCenteredText $g $steps[$i][0] (Font "Segoe UI" 26 ([System.Drawing.FontStyle]::Bold)) "#062C22" 428 ($y + 18) 54 54
    DrawText $g $steps[$i][1] (Font "Segoe UI" 29 ([System.Drawing.FontStyle]::Bold)) "#102033" 506 ($y + 14) 560 38
    DrawText $g $steps[$i][2] (Font "Segoe UI" 20 ([System.Drawing.FontStyle]::Regular)) "#4B5B6B" 506 ($y + 52) 590 34
}
SavePng $bmp $g "ghl-missed-call-process.png"
