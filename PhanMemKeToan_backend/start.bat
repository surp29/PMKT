@echo off
title PhanMemKeToan Backend
color 0A

echo.
echo ========================================
echo    PHAN MEM KE TOAN BACKEND
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

REM Check if database is accessible
echo 🔍 Checking database connection...
python -c "from app.database import test_database_connection; test_database_connection()" 2>nul
if errorlevel 1 (
    echo ⚠️  Warning: Database connection failed
    echo Please check your database configuration
)

echo.
echo 🚀 Starting FastAPI server...
echo 📡 API will be available at: http://localhost:5001
echo 📚 API documentation: http://localhost:5001/docs
echo.
echo Press Ctrl+C to stop the server
echo.

REM Start the application
python main.py

if errorlevel 1 (
    echo.
    echo ❌ Error: Application failed to start
    pause
    exit /b 1
)

pause
