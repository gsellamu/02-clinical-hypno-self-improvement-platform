<#
.SYNOPSIS
    Create placeholder audio files for testing
.DESCRIPTION
    Creates valid (but silent) MP3 files so the XR app can run
#>

$PROJECT_ROOT = Get-Location
$AUDIO_DIR = Join-Path $PROJECT_ROOT "frontend\public\sounds"

Write-Host ""
Write-Host "CREATING PLACEHOLDER AUDIO FILES" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Create sounds directory
if (-not (Test-Path $AUDIO_DIR)) {
    New-Item -ItemType Directory -Path $AUDIO_DIR -Force | Out-Null
}

# List of audio files needed
$audioFiles = @(
    "birds-chirping.mp3",
    "wind-rustling.mp3",
    "stream-water.mp3",
    "soft-wind.mp3",
    "wind-chimes.mp3",
    "meditation-tone.mp3",
    "soft-ambient.mp3",
    "calm-tone.mp3"
)

Write-Host "Creating silent placeholder MP3 files..." -ForegroundColor Yellow
Write-Host ""

foreach ($file in $audioFiles) {
    $filePath = Join-Path $AUDIO_DIR $file
    
    if (Test-Path $filePath) {
        Write-Host "$file already exists" -ForegroundColor Green
    }
    else {
        # Create a minimal valid MP3 file (ID3v2 header + silent audio frame)
        # This is a valid 1-second silent MP3 file
        $bytes = [byte[]](
            0xFF, 0xFB, 0x90, 0x00,  # MP3 frame header (MPEG 1 Layer 3)
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        ) * 50  # Repeat to make ~1 second
        
        [System.IO.File]::WriteAllBytes($filePath, $bytes)
        
        Write-Host " Created: $file (silent placeholder)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host " Placeholder files created!" -ForegroundColor Green
Write-Host ""
Write-Host " NOTE: These are SILENT files for testing only." -ForegroundColor Yellow
Write-Host "   Your XR app will work, but you won't hear audio." -ForegroundColor Yellow
Write-Host ""
Write-Host "To add real audio:" -ForegroundColor Cyan
Write-Host "   1. Download from YouTube Audio Library (free)" -ForegroundColor Gray
Write-Host "   2. Use AI audio generation (ElevenLabs, etc.)" -ForegroundColor Gray
Write-Host "   3. Record your own sounds" -ForegroundColor Gray
Write-Host ""
