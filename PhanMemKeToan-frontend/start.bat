@echo off
title PhanMemKeToan Frontend
color 0B

echo.
echo ========================================
echo    PHAN MEM KE TOAN FRONTEND
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Python is not installed or not in PATH
    echo Please install Python 3.8+ and try again
    pause
    exit /b 1
)

REM Activate virtual environment if exists
if exist ".venv\Scripts\activate.bat" (
    echo 🔧 Activating virtual environment...
    call .venv\Scripts\activate.bat
    if errorlevel 1 (
        echo ❌ Error: Failed to activate virtual environment
        pause
        exit /b 1
    )
) else (
    echo ⚠️  Warning: Virtual environment not found
    echo Creating virtual environment...
    python -m venv .venv
    call .venv\Scripts\activate.bat
)

REM Install dependencies
echo 📦 Installing dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo ❌ Error: Failed to install dependencies
    pause
    exit /b 1
)

REM Validate configuration
echo 🔍 Validating configuration...
python -c "from config import Config; Config.validate()" 2>nul
if errorlevel 1 (
    echo ⚠️  Warning: Configuration validation failed
)

echo.
echo 🚀 Starting Flask server...
echo 🌐 Frontend will be available at: http://localhost:5000
echo 🔗 Backend API: http://localhost:5001
echo.
echo Press Ctrl+C to stop the server
echo.

REM Start the application
python app.py

if errorlevel 1 (
    echo.
    echo ❌ Error: Application failed to start
    pause
    exit /b 1
)

pause
