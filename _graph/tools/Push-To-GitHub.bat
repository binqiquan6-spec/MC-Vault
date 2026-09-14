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
git -c http.sslBackend=openssl push -u origin main
echo.
if %ERRORLEVEL% neq 0 (
    echo [FAILED] Check VPN/network and GitHub PAT.
    echo If a browser or credential window opened, complete the login there.
) else (
    echo [OK] Push completed.
)
echo.
pause
