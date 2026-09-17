$ErrorActionPreference = "Stop"
$SiteDir = "C:\Users\phc220001\OneDrive\alpha\site"
$Python  = "C:\Users\phc220001\AppData\Local\Programs\Python\Python312\python.exe"
$LogFile = "C:\Users\phc220001\OneDrive\alpha\logs\daily_publish.log"

function Log($msg) {
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg" | Out-File -FilePath $LogFile -Append -Encoding utf8
}

Set-Location $SiteDir
Log "=== Run started ==="

try {
    & $Python "publish_site.py" 2>&1 | ForEach-Object { Log $_ }

    git add -A
    $changes = git status --porcelain
    if ($changes) {
        git commit -m "Daily update $(Get-Date -Format 'yyyy-MM-dd')" 2>&1 | ForEach-Object { Log $_ }
        git push 2>&1 | ForEach-Object { Log $_ }
        Log "Pushed changes."
    } else {
        Log "No changes to commit."
    }
} catch {
    Log "ERROR: $_"
}

Log "=== Run finished ==="
