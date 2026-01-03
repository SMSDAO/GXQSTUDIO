# Image Generation Script for FXSOLBOT
Write-Host "===== Generating Optimized Images for FXSOLBOT =====" -ForegroundColor Cyan

# Check if ImageMagick is installed
$imageMagickInstalled = $false
try {
    $magickVersion = & magick -version 2>&1
    $imageMagickInstalled = $true
    Write-Host "ImageMagick found: $magickVersion" -ForegroundColor Green
} catch {
    Write-Host "ImageMagick is not installed. Please install it to use this script." -ForegroundColor Red
    Write-Host "Download from: https://imagemagick.org/script/download.php" -ForegroundColor Yellow
    exit 1
}

# Source SVG file
$sourceSvg = "dashboard\public\images\neon-logo.svg"

# Check if source file exists
if (-not (Test-Path $sourceSvg)) {
    Write-Host "Source SVG file not found: $sourceSvg" -ForegroundColor Red
    exit 1
}

# Create output directory if it doesn't exist
$outputDir = "dashboard\public\images\app-icons"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Host "Created output directory: $outputDir" -ForegroundColor Green
}

# Define image sizes for different platforms
$imageSizes = @{
    # Windows icons
    "win-icon-16.png" = "16x16";
    "win-icon-32.png" = "32x32";
    "win-icon-48.png" = "48x48";
    "win-icon-64.png" = "64x64";
    "win-icon-128.png" = "128x128";
    "win-icon-256.png" = "256x256";
    
    # macOS icons
    "mac-icon-16.png" = "16x16";
    "mac-icon-32.png" = "32x32";
    "mac-icon-64.png" = "64x64";
    "mac-icon-128.png" = "128x128";
    "mac-icon-256.png" = "256x256";
    "mac-icon-512.png" = "512x512";
    "mac-icon-1024.png" = "1024x1024";
    
    # Web/PWA icons
    "favicon.png" = "32x32";
    "favicon-16.png" = "16x16";
    "favicon-32.png" = "32x32";
    "favicon-48.png" = "48x48";
    "favicon-64.png" = "64x64";
    "favicon-128.png" = "128x128";
    "apple-touch-icon.png" = "180x180";
    "android-chrome-192.png" = "192x192";
    "android-chrome-512.png" = "512x512";
    
    # App store icons
    "app-store-icon.png" = "1024x1024";
    "play-store-icon.png" = "512x512";
    
    # Social media
    "social-preview.png" = "1200x630";
    "twitter-card.png" = "1200x600";
}

# Generate all the images
foreach ($image in $imageSizes.GetEnumerator()) {
    $outputFile = Join-Path $outputDir $image.Key
    Write-Host "Generating $($image.Key) ($($image.Value))..." -ForegroundColor Yellow
    
    # Use ImageMagick to convert SVG to PNG with the specified size
    & magick convert -background none -size $image.Value $sourceSvg $outputFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Created: $outputFile" -ForegroundColor Green
    } else {
        Write-Host "  Failed to create: $outputFile" -ForegroundColor Red
    }
}

# Generate ICO file for Windows
$icoFile = "dashboard\resources\icon.ico"
Write-Host "Generating Windows ICO file..." -ForegroundColor Yellow
& magick convert "$outputDir\win-icon-16.png" "$outputDir\win-icon-32.png" "$outputDir\win-icon-48.png" "$outputDir\win-icon-64.png" "$outputDir\win-icon-128.png" "$outputDir\win-icon-256.png" $icoFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Created: $icoFile" -ForegroundColor Green
} else {
    Write-Host "  Failed to create: $icoFile" -ForegroundColor Red
}

# Generate ICNS file for macOS
$icnsFile = "dashboard\resources\icon.icns"
Write-Host "Generating macOS ICNS file..." -ForegroundColor Yellow

# For ICNS, we need to use a different approach
# This is a simplified version - for production, consider using a dedicated tool
& magick convert "$outputDir\mac-icon-16.png" "$outputDir\mac-icon-32.png" "$outputDir\mac-icon-64.png" "$outputDir\mac-icon-128.png" "$outputDir\mac-icon-256.png" "$outputDir\mac-icon-512.png" "$outputDir\mac-icon-1024.png" $icnsFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Created: $icnsFile" -ForegroundColor Green
} else {
    Write-Host "  Failed to create: $icnsFile" -ForegroundColor Red
}

# Generate web manifest file
$webManifestFile = "dashboard\public\manifest.json"
Write-Host "Generating Web App Manifest..." -ForegroundColor Yellow

$webManifest = @"
{
  "name": "NEON Aurora Dashboard",
  "short_name": "FXSOLBOT",
  "description": "NEON Aurora 3D Dashboard for DeFi bots and contracts management",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#050510",
  "theme_color": "#050510",
  "icons": [
    {
      "src": "/images/app-icons/favicon-16.png",
      "sizes": "16x16",
      "type": "image/png"
    },
    {
      "src": "/images/app-icons/favicon-32.png",
      "sizes": "32x32",
      "type": "image/png"
    },
    {
      "src": "/images/app-icons/favicon-48.png",
      "sizes": "48x48",
      "type": "image/png"
    },
    {
      "src": "/images/app-icons/favicon-64.png",
      "sizes": "64x64",
      "type": "image/png"
    },
    {
      "src": "/images/app-icons/favicon-128.png",
      "sizes": "128x128",
      "type": "image/png"
    },
    {
      "src": "/images/app-icons/android-chrome-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/images/app-icons/android-chrome-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
"@

$webManifest | Out-File -FilePath $webManifestFile -Encoding utf8

if (Test-Path $webManifestFile) {
    Write-Host "  Created: $webManifestFile" -ForegroundColor Green
} else {
    Write-Host "  Failed to create: $webManifestFile" -ForegroundColor Red
}

Write-Host ""
Write-Host "Image generation completed!" -ForegroundColor Green
Write-Host "All images have been generated in: $outputDir" -ForegroundColor Green
Write-Host ""

Pause