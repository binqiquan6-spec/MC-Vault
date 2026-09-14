@echo off
chcp 65001 >nul
cd /d "%~dp0..\.."
echo ==========================================
echo  Push MC Vault to GitHub
echo  Remote: origin
echo ==========================================
echo.
git status -sb
echo.
echo Pushing...
git push -u origin main
echo.
if %ERRORLEVEL% neq 0 (
    echo.
    echo [FAILED] Check VPN/network and GitHub PAT.
) else (
    echo.
    echo [OK] Push completed.
)
echo.
pause
