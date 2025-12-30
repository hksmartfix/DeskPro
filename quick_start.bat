@echo off
echo ================================
echo DeskPro Quick Start Script
echo ================================
echo.

echo [1/4] Checking Flutter...
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter not found! Please install Flutter first.
    pause
    exit /b 1
)

echo.
echo [2/4] Installing Flutter dependencies...
call flutter pub get
if errorlevel 1 (
    echo ERROR: Failed to get dependencies!
    pause
    exit /b 1
)

echo.
echo [3/4] Checking for connected devices...
call flutter devices

echo.
echo [4/4] Choose an option:
echo   1) Run on Android
echo   2) Run on Windows
echo   3) Build APK (Release)
echo   4) Build Windows (Release)
echo   5) Exit
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" (
    echo.
    echo Starting on Android...
    flutter run
) else if "%choice%"=="2" (
    echo.
    echo Starting on Windows...
    flutter run -d windows
) else if "%choice%"=="3" (
    echo.
    echo Building APK...
    flutter build apk --release
    echo.
    echo APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-release.apk
) else if "%choice%"=="4" (
    echo.
    echo Building Windows executable...
    flutter build windows --release
    echo.
    echo Windows app built successfully!
    echo Location: build\windows\runner\Release\
) else if "%choice%"=="5" (
    echo Exiting...
    exit /b 0
) else (
    echo Invalid choice!
)

echo.
echo.
echo ================================
echo Important Reminders:
echo ================================
echo 1. Start the signaling server first:
echo    cd signaling_server
echo    npm install
echo    npm start
echo.
echo 2. Update server URL in:
echo    lib\core\constants\app_constants.dart
echo.
echo 3. For more help, read:
echo    - README.md
echo    - SETUP.md
echo    - FEATURES.md
echo ================================
echo.

pause

