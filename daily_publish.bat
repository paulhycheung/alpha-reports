@echo off
set SITE_DIR=C:\Users\phc220001\OneDrive\alpha\site
set PYTHON=C:\Users\phc220001\AppData\Local\Programs\Python\Python312\python.exe
set LOGFILE=C:\Users\phc220001\OneDrive\alpha\logs\daily_publish.log

cd /d "%SITE_DIR%"
echo ==== %date% %time% Run started ==== >> "%LOGFILE%"

"%PYTHON%" publish_site.py >> "%LOGFILE%" 2>&1
if errorlevel 1 (
    echo ERROR: publish_site.py failed >> "%LOGFILE%"
    goto :end
)

git add -A >> "%LOGFILE%" 2>&1

git diff --cached --quiet
if errorlevel 1 (
    git commit -m "Daily update %date%" >> "%LOGFILE%" 2>&1
    git push >> "%LOGFILE%" 2>&1
    if errorlevel 1 (
        echo ERROR: git push failed >> "%LOGFILE%"
    ) else (
        echo Pushed changes. >> "%LOGFILE%"
    )
) else (
    echo No changes to commit. >> "%LOGFILE%"
)

:end
echo ==== %date% %time% Run finished ==== >> "%LOGFILE%"
