$SiteDir = "C:\Users\phc220001\OneDrive\alpha\site"
$Python  = "C:\Users\phc220001\AppData\Local\Programs\Python\Python312\python.exe"
$LogFile = "C:\Users\phc220001\OneDrive\alpha\logs\daily_publish.log"

function Log($msg) {
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg" | Out-File -FilePath $LogFile -Append -Encoding utf8
}

Set-Location $SiteDir
Log "=== Run started ==="

& $Python "publish_site.py" *>> $LogFile
if ($LASTEXITCODE -ne 0) {
    Log "ERROR: publish_site.py failed (exit $LASTEXITCODE)"
    Log "=== Run finished ==="
    exit 1
}

git add -A *>> $LogFile
$changes = git status --porcelain
if ($changes) {
    git commit -m "Daily update $(Get-Date -Format 'yyyy-MM-dd')" *>> $LogFile
    git push *>> $LogFile
    if ($LASTEXITCODE -eq 0) {
        Log "Pushed changes."
    } else {
        Log "ERROR: git push failed (exit $LASTEXITCODE)"
    }
} else {
    Log "No changes to commit."
}

Log "=== Run finished ==="
