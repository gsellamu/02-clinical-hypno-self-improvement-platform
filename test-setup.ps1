# Create test file: test-setup.ps1
Write-Host "=== Self Improvement Hyno Platform Development Environment Check ===" -ForegroundColor Cyan

Write-Host "`n1. Node.js" -ForegroundColor Yellow
try { 
    node --version
    npm --version
} catch {

.\install-node.ps1
[System.Environment]::SetEnvironmentVariable("Path", ($env:Path + ";C:\Program Files\nodejs\"), [System.EnvironmentVariableTarget]::User)
$nodePath = "C:\Program Files\nodejs\"
$env:Path += ";$nodePath"
# Check if the path exists first
if (Test-Path $nodePath) {
    Write-Host "Node.js directory found. Adding to User PATH..." -ForegroundColor Cyan

    # Get the current User PATH
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

    # Check if the path is already in the User PATH
    if ($userPath -notlike "*;*C:\Program Files\nodejs\*" -and $userPath -notlike "*C:\Program Files\nodejs\*") {
        # Add the path permanently to the User environment variable Path
        [System.Environment]::SetEnvironmentVariable("Path", ($userPath + ";$nodePath"), [System.EnvironmentVariableTarget]::User)
        Write-Host "PATH updated successfully." -ForegroundColor Green
        Write-Host "Please close and reopen ALL PowerShell/CMD windows for the changes to take effect." -ForegroundColor Yellow
    } else {
        Write-Host "The Node.js path is already present in your User PATH variable." -ForegroundColor Green
        Write-Host "You might just need to close and reopen your PowerShell window." -ForegroundColor Yellow
    }
} else {
    Write-Host "Directory $nodePath not found. Please verify your Node.js installation location." -ForegroundColor Red
}

}

node --version
npm --version

Write-Host "`n2. Python" -ForegroundColor Yellow
python --version
pip --version

Write-Host "`n3. Git" -ForegroundColor Yellow
git --version

Write-Host "`n4. Docker" -ForegroundColor Yellow
docker --version

Write-Host "`n5. VS Code Extensions" -ForegroundColor Yellow
code --list-extensions | Select-String -Pattern "eslint|prettier|tailwind|python"

Write-Host "`n=== Setup Complete! ===" -ForegroundColor Green

<#
 ➜  Local:   http://localhost:5173/
  ➜  Network: http://172.18.224.1:5173/
  ➜  Network: http://10.0.0.5:5173/
#>