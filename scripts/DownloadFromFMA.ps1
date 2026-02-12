<#
.SYNOPSIS
    Download audio from Free Music Archive
#>

$PROJECT_ROOT = Get-Location
$AUDIO_DIR = Join-Path $PROJECT_ROOT "frontend\public\sounds"

Write-Host ""
Write-Host "DOWNLOADING FROM FREE MUSIC ARCHIVE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $AUDIO_DIR)) {
    New-Item -ItemType Directory -Path $AUDIO_DIR -Force | Out-Null
}

# Using archive.org public domain sounds
$audioFiles = @{
    "birds-chirping.mp3" = "https://archive.org/download/birds-chirping-sound/birds-chirping.mp3"
    "stream-water.mp3" = "https://archive.org/download/nature-sounds-stream/stream-water.mp3"
    "soft-ambient.mp3" = "https://archive.org/download/calm-meditation-music/soft-ambient.mp3"
    "meditation-tone.mp3" = "https://archive.org/download/meditation-bell-sound/meditation-bell.mp3"
}

foreach ($fileName in $audioFiles.Keys) {
    $destination = Join-Path $AUDIO_DIR $fileName
    $url = $audioFiles[$fileName]
    
    if (Test-Path $destination) {
        Write-Host "$fileName already exists" -ForegroundColor Green
    }
    else {
        Write-Host "Downloading: $fileName" -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $url -OutFile $destination -ErrorAction Stop
            Write-Host "   Downloaded successfully" -ForegroundColor Green
        }
        catch {
            Write-Host "   Could not download from archive.org" -ForegroundColor Yellow
            Write-Host "   Creating placeholder instead..." -ForegroundColor Gray
            
            # Create placeholder
            $bytes = [byte[]](0xFF, 0xFB, 0x90, 0x00) * 50
            [System.IO.File]::WriteAllBytes($destination, $bytes)
            Write-Host "   Placeholder created" -ForegroundColor Green
        }
    }
}

# Create placeholders for remaining files
$remainingFiles = @(
    "wind-rustling.mp3",
    "soft-wind.mp3",
    "wind-chimes.mp3",
    "calm-tone.mp3"
)

Write-Host ""
Write-Host "Creating placeholders for remaining files..." -ForegroundColor Yellow

foreach ($file in $remainingFiles) {
    $filePath = Join-Path $AUDIO_DIR $file
    if (-not (Test-Path $filePath)) {
        $bytes = [byte[]](0xFF, 0xFB, 0x90, 0x00) * 50
        [System.IO.File]::WriteAllBytes($filePath, $bytes)
        Write-Host "Created: $file (placeholder)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green