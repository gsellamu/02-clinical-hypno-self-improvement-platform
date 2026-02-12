# ============================================================================
# Epic 8, Feature 1, Story 1: Dimensional Taxonomy Implementation
# PowerShell Setup Script for Windows/VS Code
# ============================================================================
# Tasks Covered:
# - T1: Design 4D taxonomy schema (Mind/Body/Social/Spiritual)
# - T2: Create dimension scoring algorithm
# - T3: Implement dimensional weights & preferences
# - T4: Setup taxonomy navigation API
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  E8-F1-S1: Dimensional Taxonomy Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$ProjectRoot = "C:\Projects\Jeeth.ai"
$BackendPath = "$ProjectRoot\backend"
$ServicesPath = "$BackendPath\services"
$ModelsPath = "$BackendPath\models"
$APIPath = "$BackendPath\api"
$TestsPath = "$BackendPath\tests"
$DBScriptsPath = "$ProjectRoot\database\migrations"

# Check if project root exists
if (-Not (Test-Path $ProjectRoot)) {
    Write-Host "Creating project root: $ProjectRoot" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ProjectRoot -Force | Out-Null
}

# Create directory structure
$directories = @(
    $BackendPath,
    "$ServicesPath\taxonomy",
    "$ModelsPath\taxonomy",
    "$APIPath\v1\taxonomy",
    "$TestsPath\unit\taxonomy",
    "$TestsPath\integration\taxonomy",
    $DBScriptsPath
)

Write-Host "Creating directory structure..." -ForegroundColor Green
foreach ($dir in $directories) {
    if (-Not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  ✓ Created: $dir" -ForegroundColor Gray
    } else {
        Write-Host "  ✓ Exists: $dir" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Directory structure ready!" -ForegroundColor Green
Write-Host ""

# Check Python environment
Write-Host "Checking Python environment..." -ForegroundColor Green
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Python found: $pythonVersion" -ForegroundColor Gray
} else {
    Write-Host "  ✗ Python not found! Please install Python 3.11+" -ForegroundColor Red
    exit 1
}

# Check if virtual environment exists
$venvPath = "$ProjectRoot\venv"
if (-Not (Test-Path $venvPath)) {
    Write-Host "Creating Python virtual environment..." -ForegroundColor Yellow
    python -m venv $venvPath
    Write-Host "  ✓ Virtual environment created" -ForegroundColor Gray
} else {
    Write-Host "  ✓ Virtual environment exists" -ForegroundColor Gray
}

# Activate virtual environment
Write-Host "Activating virtual environment..." -ForegroundColor Green
& "$venvPath\Scripts\Activate.ps1"

# Install required packages
Write-Host ""
Write-Host "Installing required Python packages..." -ForegroundColor Green
$packages = @(
    "fastapi==0.104.1",
    "uvicorn[standard]==0.24.0",
    "pydantic==2.5.0",
    "sqlalchemy==2.0.23",
    "asyncpg==0.29.0",
    "redis==5.0.1",
    "python-dotenv==1.0.0",
    "pytest==7.4.3",
    "pytest-asyncio==0.21.1",
    "httpx==0.25.2"
)

foreach ($package in $packages) {
    Write-Host "  Installing $package..." -ForegroundColor Gray
    pip install $package --break-system-packages --quiet
}

Write-Host "  ✓ All packages installed" -ForegroundColor Green

# Create requirements.txt
$requirementsContent = @"
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
sqlalchemy==2.0.23
asyncpg==0.29.0
redis==5.0.1
python-dotenv==1.0.0
pytest==7.4.3
pytest-asyncio==0.21.1
httpx==0.25.2
"@

Set-Content -Path "$ProjectRoot\requirements.txt" -Value $requirementsContent
Write-Host "  ✓ requirements.txt created" -ForegroundColor Gray

# Create .env file if it doesn't exist
if (-Not (Test-Path "$ProjectRoot\.env")) {
    Write-Host ""
    Write-Host "Creating .env configuration file..." -ForegroundColor Green
    $envContent = @"
# Database Configuration
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/jeeth_ai
REDIS_URL=redis://localhost:6379/0

# API Configuration
API_VERSION=v1
API_PREFIX=/api/v1
DEBUG=True

# Taxonomy Configuration
TAXONOMY_DIMENSIONS=4
DEFAULT_DIMENSION_WEIGHTS=0.25,0.25,0.25,0.25

# LLM Configuration
ANTHROPIC_API_KEY=your_key_here
OPENAI_API_KEY=your_key_here
"@
    Set-Content -Path "$ProjectRoot\.env" -Value $envContent
    Write-Host "  ✓ .env file created (update API keys!)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Update .env with your API keys" -ForegroundColor White
Write-Host "  2. Run database migration: python $DBScriptsPath\001_dimensional_taxonomy.py" -ForegroundColor White
Write-Host "  3. Start FastAPI server: uvicorn backend.main:app --reload" -ForegroundColor White
Write-Host "  4. Access API docs: http://localhost:8000/docs" -ForegroundColor White
Write-Host ""
Write-Host "Files generated in: $ProjectRoot" -ForegroundColor Green
Write-Host "Ready to code! 🚀" -ForegroundColor Cyan
