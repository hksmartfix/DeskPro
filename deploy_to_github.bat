@echo off
echo ============================================
echo     DeskPro - GitHub Deployment Script
echo ============================================
echo.

echo [Step 1/5] Checking Git installation...
git --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is not installed!
    echo Please install Git from: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo ✓ Git is installed
echo.

echo [Step 2/5] Initializing Git repository...
if not exist ".git" (
    git init
    echo ✓ Git repository initialized
) else (
    echo ✓ Git repository already exists
)
echo.

echo [Step 3/5] Adding files to Git...
git add .
echo ✓ Files added to staging
echo.

echo [Step 4/5] Creating commit...
git commit -m "Initial commit: DeskPro Remote Desktop Application - Complete Flutter app with WebRTC, session-based connections, file sharing, and modern UI"
if errorlevel 1 (
    echo Note: No changes to commit or already committed
) else (
    echo ✓ Commit created successfully
)
echo.

echo [Step 5/5] Ready to push to GitHub
echo.
echo ============================================
echo.
echo Next steps:
echo.
echo 1. Create a new repository on GitHub:
echo    https://github.com/new
echo.
echo 2. Name it: DeskPro
echo.
echo 3. DO NOT initialize with README, license, or .gitignore
echo.
echo 4. After creating, run these commands:
echo.
echo    git remote add origin https://github.com/hksmartfix/DeskPro.git
echo    git branch -M main
echo    git push -u origin main
echo.
echo Replace YOUR_USERNAME with your actual GitHub username
echo.
echo ============================================
echo.

pause

