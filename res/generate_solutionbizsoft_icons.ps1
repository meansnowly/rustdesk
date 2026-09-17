Add-Type -AssemblyName System.Drawing

$code = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Collections.Generic;

public class IcoBuilder {
    public static void SaveIco(Bitmap src, string outputPath, int[] sizes) {
        using (var fs = new FileStream(outputPath, FileMode.Create, FileAccess.Write))
        using (var bw = new BinaryWriter(fs)) {
            // Header
            bw.Write((short)0); // reserved
            bw.Write((short)1); // type 1 = icon
            bw.Write((short)sizes.Length); // count

            List<byte[]> pngs = new List<byte[]>();
            foreach (int size in sizes) {
                using (var resized = new Bitmap(size, size, PixelFormat.Format32bppArgb)) {
                    using (var g = Graphics.FromImage(resized)) {
                        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
                        g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
                        g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;
                        g.Clear(Color.Transparent);
                        g.DrawImage(src, new Rectangle(0, 0, size, size));
                    }
                    using (var ms = new MemoryStream()) {
                        resized.Save(ms, ImageFormat.Png);
                        pngs.Add(ms.ToArray());
                    }
                }
            }

            int offset = 6 + (16 * sizes.Length);
            for (int i = 0; i < sizes.Length; i++) {
                int size = sizes[i];
                byte bSize = (size >= 256) ? (byte)0 : (byte)size;
                bw.Write(bSize); // width
                bw.Write(bSize); // height
                bw.Write((byte)0); // color count
                bw.Write((byte)0); // reserved
                bw.Write((short)1); // planes
                bw.Write((short)32); // bit count
                bw.Write(pngs[i].Length); // bytes in res
                bw.Write(offset); // offset
                offset += pngs[i].Length;
            }

            for (int i = 0; i < sizes.Length; i++) {
                bw.Write(pngs[i]);
            }
        }
    }
}
"@
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing

$logoFile = (Resolve-Path 'flutter/assets/logo.png').Path
$logo = [System.Drawing.Bitmap]::FromFile($logoFile)

# Content bounding box
$minX = 20; $maxX = 554; $minY = 20; $maxY = 350
$contentW = $maxX - $minX + 1
$contentH = $maxY - $minY + 1

# 1. Create 1024x1024 Master Icon
$masterSize = 1024
$master = New-Object System.Drawing.Bitmap($masterSize, $masterSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($master)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.Clear([System.Drawing.Color]::Transparent)

# Draw rounded squircle background
$padding = 48
$rectX = $padding
$rectY = $padding
$rectSize = $masterSize - ($padding * 2) # 928
$radius = 180

$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddArc($rectX, $rectY, $radius, $radius, 180, 90)
$path.AddArc($rectX + $rectSize - $radius, $rectY, $radius, $radius, 270, 90)
$path.AddArc($rectX + $rectSize - $radius, $rectY + $rectSize - $radius, $radius, $radius, 0, 90)
$path.AddArc($rectX, $rectY + $rectSize - $radius, $radius, $radius, 90, 90)
$path.CloseFigure()

$bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 18, 18, 18))
$g.FillPath($bgBrush, $path)

# Subtle border
$borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(40, 255, 255, 255), 4)
$g.DrawPath($borderPen, $path)

# Draw logo content scaled and centered inside squircle
$scale = [Math]::Min(760.0 / $contentW, 760.0 / $contentH)
$destW = [int]($contentW * $scale)
$destH = [int]($contentH * $scale)
$destX = [int](($masterSize - $destW) / 2)
$destY = [int](($masterSize - $destH) / 2)

$srcRect = New-Object System.Drawing.Rectangle($minX, $minY, $contentW, $contentH)
$destRect = New-Object System.Drawing.Rectangle($destX, $destY, $destW, $destH)
$g.DrawImage($logo, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

$g.Dispose()
$logo.Dispose()

# Save master PNG: res/icon.png
$resIconPath = Join-Path (Resolve-Path 'res').Path 'icon.png'
$master.Save($resIconPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Saved $resIconPath"

# Save 256x256: flutter/assets/icon.png
$fIcon = New-Object System.Drawing.Bitmap(256, 256, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$fg = [System.Drawing.Graphics]::FromImage($fIcon)
$fg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$fg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$fg.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$fg.DrawImage($master, 0, 0, 256, 256)
$fg.Dispose()
$flutterIconPath = Join-Path (Resolve-Path 'flutter/assets').Path 'icon.png'
$fIcon.Save($flutterIconPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Saved $flutterIconPath"
$fIcon.Dispose()

# Save ICOs
$icoSizes = @(16, 32, 48, 64, 128, 256)
$runnerAppIconPath = Join-Path (Resolve-Path 'flutter/windows/runner/resources').Path 'app_icon.ico'
[IcoBuilder]::SaveIco($master, $runnerAppIconPath, $icoSizes)
Write-Host "Saved $runnerAppIconPath"

$resIcoPath = Join-Path (Resolve-Path 'res').Path 'icon.ico'
[IcoBuilder]::SaveIco($master, $resIcoPath, $icoSizes)
Write-Host "Saved $resIcoPath"

$traySizes = @(16, 32)
$trayIcoPath = Join-Path (Resolve-Path 'res').Path 'tray-icon.ico'
[IcoBuilder]::SaveIco($master, $trayIcoPath, $traySizes)
Write-Host "Saved $trayIcoPath"

# Create SVG embedding base64 PNG of icon
$bytes = [System.IO.File]::ReadAllBytes($flutterIconPath)
$b64 = [Convert]::ToBase64String($bytes)
$svgContent = @"
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="256" height="256" viewBox="0 0 256 256">
  <image width="256" height="256" xlink:href="data:image/png;base64,$b64"/>
</svg>
"@
$svgPath = Join-Path (Resolve-Path 'flutter/assets').Path 'icon.svg'
[System.IO.File]::WriteAllText($svgPath, $svgContent)
Write-Host "Saved $svgPath"

$master.Dispose()
Write-Host "ALL ICONS GENERATED SUCCESSFULLY!"
