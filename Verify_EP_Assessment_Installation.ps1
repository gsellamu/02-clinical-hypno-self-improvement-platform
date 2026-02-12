$newHomePath = "D:\ChatGPT Projects"
$RepoRoot = "$newHomePath\genai-portfolio"
$Project = "02-clinical-hypno-self-improvement-platform"
$Root = "$RepoRoot\projects\$Project"

# Frontend (React + XR)
$FrontEndDir = "$Root\frontend"
#EnsureDir $FrontEndDir
$BackEndDir = "$Root\backend"
#EnsureDir $BackEndDir

Write-Host " Running tests..." -ForegroundColor Yellow
$backendDir = $BackEndDir
Set-Location $backendDir
python -m venv .venv
.\.venv\Scripts\activate
pip install fastapi  sqlalchemy   pydantic    pytest      uvicorn      python-jose      passlib      redis 

$pythonExe = "D:\ChatGPT Projects\genai-portfolio\.venv\Scripts\python.exe"
Start-Process -FilePath "uvicorn" -ArgumentList "main:app --reload" -WindowStyle Hidden

if (Test-Path $pythonExe) {
    Write-Host "  Running pytest..." -ForegroundColor Cyan
    & $pythonExe -m pytest tests\test_assessment_api.py -v --tb=short
} else {
    Write-Host "   Python not found at: $pythonExe" -ForegroundColor Red
}

#pythonExe = "python"
# ============================================================================
# 7. SUMMARY
# ============================================================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "WHAT WAS FIXED:" -ForegroundColor Yellow
Write-Host "  Created services/assessment directory" -ForegroundColor Green
Write-Host "  Added ep_assessment_service_enhanced.py" -ForegroundColor Green
Write-Host "  Added conftest.py with mock auth" -ForegroundColor Green
Write-Host "  Added missing __init__.py files" -ForegroundColor Green
Write-Host "  Created mock auth module (if needed)" -ForegroundColor Green

Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Check test results above" -ForegroundColor White
Write-Host "  2. If tests still fail, check error messages" -ForegroundColor White
Write-Host "  3. Run: pytest tests\test_assessment_api.py -v" -ForegroundColor White

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "E and P ASSESSMENT PHASE 1 - INSTALLATION CHECKER" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$projectRoot = "D:\ChatGPT Projects\genai-portfolio\projects\02-clinical-hypno-self-improvement-platform"
$backendDir = "$projectRoot\backend"

# ============================================================================
# 1. CHECK PROJECT STRUCTURE
# ============================================================================

Write-Host " CHECKING PROJECT STRUCTURE..." -ForegroundColor Yellow

$requiredDirs = @(
    "$backendDir\models",
    "$backendDir\routes", 
    "$backendDir\schemas",
    "$backendDir\services\assessment",
    "$backendDir\tests",
    "$backendDir\utils"
)

$dirResults = @()
foreach ($dir in $requiredDirs) {
    if (Test-Path $dir) {
        Write-Host "  $dir" -ForegroundColor Green
        $dirResults += @{path=$dir; exists=$true}
    } else {
        Write-Host "   $dir (MISSING)" -ForegroundColor Red
        $dirResults += @{path=$dir; exists=$false}
    }
}

# ============================================================================
# 2. CHECK FILES CREATED
# ============================================================================

Write-Host " CHECKING REQUIRED FILES..." -ForegroundColor Yellow

$requiredFiles = @{
    "Models" = @(
        "$backendDir\models\questionnaire_models.py",
        "$backendDir\models\__init__.py"
    )
    "Routes" = @(
        "$backendDir\routes\assessment.py",
        "$backendDir\routes\__init__.py"
    )
    "Schemas" = @(
        "$backendDir\schemas\assessment.py",
        "$backendDir\schemas\__init__.py"
    )
    "Services" = @(
        "$backendDir\services\assessment\ep_assessment_service_enhanced.py",
        "$backendDir\services\assessment\__init__.py"
    )
    "Utils" = @(
        "$backendDir\utils\scoring_calculator.py"
    )
    "Tests" = @(
        "$backendDir\tests\test_assessment_routes.py",
        "$backendDir\tests\conftest.py"
    )
}

$missingFiles = @()
foreach ($category in $requiredFiles.Keys) {
    Write-Host "  ${category}:" -ForegroundColor Cyan
    foreach ($file in $requiredFiles[$category]) {
        $item = Get-Item $file -ErrorAction SilentlyContinue
        if ($item) {
            $size = $item.Length / 1KB
            Write-Host "$(Split-Path $file -Leaf) ($([math]::Round($size, 1)) KB)" -ForegroundColor Green
        } else {
            Write-Host "$(Split-Path $file -Leaf) (MISSING)" -ForegroundColor Red
            $missingFiles += $file
        }
    }
}

# ============================================================================
# 3. CHECK PYTHON ENVIRONMENT
# ============================================================================

Write-Host " CHECKING PYTHON ENVIRONMENT..." -ForegroundColor Yellow

# Check if virtual environment exists
$venvPath = "$projectRoot\.venv"
if (Test-Path $venvPath) {
    Write-Host "  Virtual environment found: $venvPath" -ForegroundColor Green
    
    # Activate venv and check packages
    $pythonExe = "$venvPath\Scripts\python.exe"
    
    if (Test-Path $pythonExe) {
        Write-Host "  Checking installed packages..." -ForegroundColor Cyan
        
        $requiredPackages = @(
            "fastapi",
            "sqlalchemy", 
            "pydantic",
            "pytest",
            "uvicorn",
            "python-jose",
            "passlib",
            "redis"
        )
        
        foreach ($package in $requiredPackages) {
            $installed = & $pythonExe -m pip show $package 2>$null
            if ($installed) {
                $version = ($installed | Select-String "Version:").Line.Split(":")[1].Trim()
                Write-Host "    $package ($version)" -ForegroundColor Green
            } else {
                Write-Host "     $package " -ForegroundColor Red
            }
        }
    }
} else {
    Write-Host "   Virtual environment NOT FOUND" -ForegroundColor Red
    Write-Host "    Expected: $venvPath" -ForegroundColor Yellow
}

# ============================================================================
# 4. CHECK DATABASE MIGRATION FILES
# ============================================================================

Write-Host "CHECKING DATABASE MIGRATIONS..." -ForegroundColor Yellow

$migrationsDir = "$backendDir\alembic\versions"
if (Test-Path $migrationsDir) {
    $migrationFiles = Get-ChildItem $migrationsDir -Filter "*.py" | Where-Object { $_.Name -match "ep_assessment" }
    if ($migrationFiles) {
        Write-Host "  Found E and P Assessment migrations:" -ForegroundColor Green
        foreach ($file in $migrationFiles) {
            Write-Host "    • $($file.Name)" -ForegroundColor Gray
        }
    } else {
        Write-Host "    No E and P Assessment migrations found" -ForegroundColor Yellow
        Write-Host "    You may need to run: alembic revision --autogenerate -m 'add ep assessment tables'" -ForegroundColor Gray
    }
} else {
    Write-Host "    Alembic not configured" -ForegroundColor Yellow
}

# ============================================================================
# 5. CHECK MAIN.PY INTEGRATION
# ============================================================================

Write-Host " CHECKING MAIN.PY INTEGRATION..." -ForegroundColor Yellow

$mainPy = "$backendDir\main.py"
if (Test-Path $mainPy) {
    $content = Get-Content $mainPy -Raw
    
    $checks = @(
        @{pattern = 'from routes import assessment'; description = "Assessment routes import"},
        @{pattern = 'app\.include_router\(assessment\.router'; description = "Assessment router registered"},
        @{pattern = '/api/v1/assessment'; description = "Assessment API prefix"}
    )
    
    foreach ($check in $checks) {
        if ($content -match $check.pattern) {
            Write-Host "  $($check.description)" -ForegroundColor Green
        } else {
            Write-Host "   $($check.description) (NOT FOUND)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "   main.py not found" -ForegroundColor Red
}

# ============================================================================
# 6. SUMMARY and RECOMMENDATIONS
# ============================================================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY and RECOMMENDATIONS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

if ($missingFiles.Count -eq 0) {
    Write-Host " ALL FILES CREATED SUCCESSFULLY!" -ForegroundColor Green
    
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "  1. Install dependencies:" -ForegroundColor White
    Write-Host "     .\.venv\Scripts\activate" -ForegroundColor Gray
    Write-Host "     pip install -r requirements.txt" -ForegroundColor Gray
    
    Write-Host "  2. Run database migrations:" -ForegroundColor White
    Write-Host "     alembic upgrade head" -ForegroundColor Gray
    
    Write-Host "  3. Run tests:" -ForegroundColor White
    Write-Host "     pytest tests/test_assessment_routes.py -v" -ForegroundColor Gray
    
    Write-Host "  4. Start FastAPI server:" -ForegroundColor White
    Write-Host "     uvicorn main:app --reload" -ForegroundColor Gray
    
} else {
    Write-Host "  MISSING FILES DETECTED" -ForegroundColor Red
    
    Write-Host "Missing files:" -ForegroundColor Yellow
    foreach ($file in $missingFiles) {
        Write-Host "  • $file" -ForegroundColor Gray
    }
    
    Write-Host "RECOMMENDED ACTION:" -ForegroundColor Yellow
    Write-Host "  Run the Phase 1 generation script again:" -ForegroundColor White
    Write-Host "  .\Generate_EP_Assessment_API_Phase1.ps1" -ForegroundColor Gray
}

# ============================================================================
# 7. TEST API ENDPOINTS (if server is running)
# ============================================================================

Write-Host " TESTING API ENDPOINTS..." -ForegroundColor Yellow

$baseUrl = "http://localhost:8000"

try {
    $healthCheck = Invoke-WebRequest -Uri "$baseUrl/health" -Method GET -TimeoutSec 2 -ErrorAction SilentlyContinue
    
    if ($healthCheck.StatusCode -eq 200) {
        Write-Host "  FastAPI server is running" -ForegroundColor Green
        
        # Test E and P endpoints
        $endpoints = @(
            "/api/v1/assessment/ep/submit",
            "/api/v1/assessment/ep/results/latest", 
            "/api/v1/assessment/ep/communication-preferences"
        )
        
        Write-Host "  Checking E and P Assessment endpoints:" -ForegroundColor Cyan
        foreach ($endpoint in $endpoints) {
            try {
                $response = Invoke-WebRequest -Uri "$baseUrl$endpoint" -Method GET -TimeoutSec 2 -ErrorAction SilentlyContinue
                Write-Host "    $endpoint (Status: $($response.StatusCode))" -ForegroundColor Green
            } catch {
                if ($_.Exception.Response.StatusCode -eq 401) {
                    Write-Host "    $endpoint (Requires auth - as expected)" -ForegroundColor Yellow
                } else {
                    Write-Host "     $endpoint (Error: $($_.Exception.Message))" -ForegroundColor Red
                }
            }
        }
    } else {
        Write-Host "    FastAPI server not responding" -ForegroundColor Yellow
        Write-Host "    Start server with: uvicorn main:app --reload" -ForegroundColor Gray
    }
} catch {
    Write-Host "    FastAPI server not running" -ForegroundColor Yellow
    Write-Host "    Start server with: uvicorn main:app --reload" -ForegroundColor Gray
}

Write-Host "============================================" -ForegroundColor Cyan

# ============================================================================
# 8. EXPORT RESULTS TO JSON (for debugging)
# ============================================================================

$results = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    directories_checked = $dirResults
    missing_files = $missingFiles
    venv_exists = Test-Path $venvPath
}

$resultsJson = $results | ConvertTo-Json -Depth 10
$resultsJson | Out-File "$projectRoot\installation_check_results.json"

Write-Host " Detailed results saved to: installation_check_results.json" -ForegroundColor Cyan
