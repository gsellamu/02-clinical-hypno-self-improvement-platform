<#
.SYNOPSIS
    Download free audio assets for HMI Platform
#>
<#
.SYNOPSIS
    Download all audio assets for HMI Platform
.DESCRIPTION
    Downloads free Creative Commons audio files from Freesound.org
#>

param(
    [switch]$Force  # Re-download even if files exist
)

$PROJECT_ROOT = Get-Location
$AUDIO_DIR = Join-Path $PROJECT_ROOT "frontend\public\sounds"

Write-Host ""
Write-Host "HMI PLATFORM - AUDIO ASSET DOWNLOADER" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Create sounds directory
if (-not (Test-Path $AUDIO_DIR)) {
    Write-Host "Creating sounds directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $AUDIO_DIR -Force | Out-Null
    Write-Host "Directory created: $AUDIO_DIR" -ForegroundColor Green
    Write-Host ""
}

# Audio file mappings
$audioFiles = @{
    # Nature Scene
    "birds-chirping.mp3" = @{
        url = "https://freesound.org/data/previews/447/447899_5121236-lq.mp3"
        description = "Bird chirping sounds"
    }
    "wind-rustling.mp3" = @{
        url = "https://freesound.org/data/previews/416/416838_7903369-lq.mp3"
        description = "Wind through leaves"
    }
    "stream-water.mp3" = @{
        url = "https://freesound.org/data/previews/394/394438_7277373-lq.mp3"
        description = "Flowing stream water"
    }
    
    # Floating Platform Scene
    "soft-wind.mp3" = @{
        url = "https://freesound.org/data/previews/456/456966_3905652-lq.mp3"
        description = "Soft wind ambience"
    }
    "wind-chimes.mp3" = @{
        url = "https://freesound.org/data/previews/442/442819_7193358-lq.mp3"
        description = "Wind chimes"
    }
    "meditation-tone.mp3" = @{
        url = "https://freesound.org/data/previews/397/397443_7277273-lq.mp3"
        description = "Meditation tone"
    }
    
    # Soft Room Scene
    "soft-ambient.mp3" = @{
        url = "https://freesound.org/data/previews/517/517625_8580489-lq.mp3"
        description = "Soft ambient background"
    }
    "calm-tone.mp3" = @{
        url = "https://freesound.org/data/previews/242/242501_2394245-lq.mp3"
        description = "Tibetan singing bowl"
    }
}

$successCount = 0
$skipCount = 0
$failCount = 0

foreach ($fileName in $audioFiles.Keys) {
    $fileInfo = $audioFiles[$fileName]
    $destination = Join-Path $AUDIO_DIR $fileName
    $url = $fileInfo.url
    $description = $fileInfo.description
    
    if ((Test-Path $destination) -and -not $Force) {
        Write-Host "$fileName" -ForegroundColor Green -NoNewline
        Write-Host " - Already exists (use -Force to re-download)" -ForegroundColor Gray
        $skipCount++
    }
    else {
        Write-Host " Downloading: $fileName" -ForegroundColor Yellow
        Write-Host "   Description: $description" -ForegroundColor Gray
        Write-Host "   Source: Freesound.org (CC0)" -ForegroundColor Gray
        
        try {
            # Download with progress
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $url -OutFile $destination -ErrorAction Stop
            $ProgressPreference = 'Continue'
            
            # Verify file was created and has content
            if ((Test-Path $destination) -and ((Get-Item $destination).Length -gt 0)) {
                $fileSize = [math]::Round((Get-Item $destination).Length / 1KB, 2)
                Write-Host "   Downloaded successfully ($fileSize KB)" -ForegroundColor Green
                $successCount++
            }
            else {
                throw "File is empty or wasn't created"
            }
        }
        catch {
            Write-Host "   Failed to download: $_" -ForegroundColor Red
            Write-Host "   URL: $url" -ForegroundColor Gray
            $failCount++
        }
        
        Write-Host ""
    }
}



# Summary
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "DOWNLOAD SUMMARY" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Successfully downloaded: $successCount" -ForegroundColor Green
Write-Host "Already existed (skipped): $skipCount" -ForegroundColor Yellow
if ($failCount -gt 0) {
    Write-Host "Failed downloads: $failCount" -ForegroundColor Red
}
Write-Host ""
Write-Host "Audio files location: $AUDIO_DIR" -ForegroundColor Cyan
Write-Host ""

# List all MP3 files
$mp3Files = Get-ChildItem -Path $AUDIO_DIR -Filter "*.mp3" -ErrorAction SilentlyContinue
if ($mp3Files) {
    Write-Host " Available audio files ($($mp3Files.Count)):" -ForegroundColor Cyan
    $mp3Files | ForEach-Object {
        $size = [math]::Round($_.Length / 1KB, 2)
        Write-Host "   • $($_.Name) ($size KB)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Audio setup complete!" -ForegroundColor Green
Write-Host ""


<#
SOLUTION 2: Download from YouTube Audio Library (Free, High Quality)
Step-by-Step Instructions:

Go to YouTube Audio Library:

Visit: https://studio.youtube.com/
Sign in with Google account
Click "Audio Library" in left menu


Download these tracks:

File NameSearch TermSuggested TrackDurationbirds-chirping.mp3"Nature Birds"Any nature/birds track1-2 minwind-rustling.mp3"Wind Ambient""Weightless" or similar1-2 minstream-water.mp3"Water Stream"Any water/stream track1-2 minsoft-wind.mp3"Ambient Wind""Air" or "Breathe"1-2 minwind-chimes.mp3"Meditation Zen""Meditation Impromptu"1-2 minmeditation-tone.mp3"Meditation""Zen Garden"1 minsoft-ambient.mp3"Calm Ambient""Floating" or "Luminous"2-3 mincalm-tone.mp3"Zen Calm""Meditation Impromptu 01"1-2 min

Download and rename files:

Download each track
Rename to match the names above
Move to: frontend\public\sounds\

#>
<# 
$PROJECT_ROOT = Get-Location
$AUDIO_DIR = Join-Path $PROJECT_ROOT "frontend\public\sounds"

Write-Host "🎵 Downloading Audio Assets..." -ForegroundColor Cyan
Write-Host ""

# Create sounds directory
if (-not (Test-Path $AUDIO_DIR)) {
    New-Item -ItemType Directory -Path $AUDIO_DIR -Force | Out-Null
}

# Free audio sources (Creative Commons / Public Domain)
$audioFiles = @{
    "birds-chirping.mp3" = "https://freesound.org/data/previews/447/447899_5121236-lq.mp3"
    "wind-rustling.mp3" = "https://freesound.org/data/previews/416/416838_7903369-lq.mp3"
    "stream-water.mp3" = "https://freesound.org/data/previews/394/394438_7277373-lq.mp3"
    "soft-wind.mp3" = "https://freesound.org/data/previews/456/456966_3905652-lq.mp3"
    "wind-chimes.mp3" = "https://freesound.org/data/previews/442/442819_7193358-lq.mp3"
    "meditation-tone.mp3" = "https://freesound.org/data/previews/397/397443_7277273-lq.mp3"
    "soft-ambient.mp3" = "https://freesound.org/data/previews/456/456966_3905652-lq.mp3" # https://freesound.org/data/previews/517/517625_8580489-lq.mp3
    "calm-tone.mp3" = "https://freesound.org/data/previews/242/242501_2394245-lq.mp3" #https://freesound.org/data/previews/397/397443_7277273-lq.mp3
}

foreach ($file in $audioFiles.Keys) {
    $destination = Join-Path $AUDIO_DIR $file
    $url = $audioFiles[$file]
    
    if (Test-Path $destination) {
        Write-Host "⏩ $file already exists" -ForegroundColor Green
    }
    else {
        Write-Host "📥 Downloading $file..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $url -OutFile $destination -ErrorAction Stop
            Write-Host "✅ Downloaded $file" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Failed to download $file" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "✅ Audio assets setup complete!" -ForegroundColor Green

#>

<#

# Create sounds directory
$audioDir = "frontend\public\sounds"
New-Item -ItemType Directory -Force -Path $audioDir | Out-Null

# Download soft-ambient.mp3
Invoke-WebRequest `
    -Uri "https://freesound.org/data/previews/517/517625_8580489-lq.mp3" `
    -OutFile "$audioDir\soft-ambient.mp3"

# Download calm-tone.mp3
Invoke-WebRequest `
    -Uri "https://freesound.org/data/previews/242/242501_2394245-lq.mp3" `
    -OutFile "$audioDir\calm-tone.mp3"

Write-Host "✅ Audio files downloaded!" -ForegroundColor Green
```

---

## 🎹 OPTION 3: High-Quality Alternatives (YouTube Audio Library)

If you want **higher quality** audio (non-commercial use):

### **For soft-ambient.mp3:**
1. Go to: https://www.youtube.com/audiolibrary
2. Search: "Ambient" or "Meditation"
3. Filter by: Mood → Calm
4. Download any track (e.g., "Meditation Impromptu 01")
5. Rename to `soft-ambient.mp3`

### **For calm-tone.mp3:**
1. Search: "Meditation" or "Zen"
2. Good options:
   - "Meditation Impromptu"
   - "Zen Garden"
   - "Weightless"
3. Download and rename to `calm-tone.mp3`

---

## 🔊 OPTION 4: Generate Your Own (AI)

If you have access to audio generation:

### **Using ElevenLabs or Similar:**
```
Prompt for soft-ambient.mp3:
"Create a 2-minute loop of soft, gentle ambient background music. 
Include subtle nature sounds, very low volume, peaceful, no melody, 
just atmospheric tones. Suitable for meditation and relaxation."

Prompt for calm-tone.mp3:
"Create a 1-minute meditation tone. A single sustained harmonic note 
that slowly fades in and out. Peaceful, calming, like a singing bowl 
or tuning fork. Frequency around 432Hz."
#>


