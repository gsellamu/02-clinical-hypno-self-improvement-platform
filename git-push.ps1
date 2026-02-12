# 1. Configuration
$TargetRepo = "origin"
$TargetBranch = "main"
$BatchSizeLimit = 1.5GB
$CurrentBatchSize = 0
$BatchCount = 1

# 2. Get all top-level items (folders and files)
$Items = Get-ChildItem -Path . -Exclude ".git", ".gitignore", ".venv", "workbooks", "carljung"

foreach ($Item in $Items) {
    # Calculate size of the current item (folder or file)
    $ItemSize = (Get-ChildItem $Item.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    
    if ($null -eq $ItemSize) { $ItemSize = 0 }

    # Check if adding this item exceeds the batch limit
    if (($CurrentBatchSize + $ItemSize) -gt $BatchSizeLimit -and $CurrentBatchSize -gt 0) {
        Write-Host "--- Pushing Batch $BatchCount (Size: $('{0:N2}' -f ($CurrentBatchSize / 1GB)) GB) ---" -ForegroundColor Cyan
        git commit -m "Add Batch $BatchCount"
        git push $TargetRepo $TargetBranch
        
        # Reset for next batch
        $CurrentBatchSize = 0
        $BatchCount++
    }

    # Add item to current batch
    Write-Host "Adding: $($Item.Name) ($('{0:N2}' -f ($ItemSize / 1MB)) MB)"
    git add "$($Item.Name)"
    $CurrentBatchSize += $ItemSize
}

# 3. Final Push for any remaining files
if ($CurrentBatchSize -gt 0) {
    Write-Host "--- Pushing Final Batch $BatchCount ---" -ForegroundColor Cyan
    git commit -m "Add Batch $BatchCount (Final)"
    git push $TargetRepo $TargetBranch
}


