# Docker has specific installation instructions for each operating system.
# Please refer to the official documentation at https://docker.com/get-started/

# Pull the Node.js Docker image:
docker pull node:24-alpine

# Create a Node.js container and start a Shell session:
docker run --rm node:24-alpine node --version
docker run --rm node:24-alpine npm --version



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

