#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "========================================"
echo "    PHAN MEM KE TOAN BACKEND"
echo "========================================"
echo -e "${NC}"
echo

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Error: Python3 is not installed${NC}"
    echo "Please install Python 3.8+ and try again"
    exit 1
fi

# Check Python version
PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
REQUIRED_VERSION="3.8"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo -e "${YELLOW}⚠️  Warning: Python $PYTHON_VERSION detected, $REQUIRED_VERSION+ recommended${NC}"
fi

# Activate virtual environment if exists
if [ -d ".venv" ]; then
    echo -e "${BLUE}🔧 Activating virtual environment...${NC}"
    source .venv/bin/activate
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error: Failed to activate virtual environment${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Warning: Virtual environment not found${NC}"
    echo "Creating virtual environment..."
    python3 -m venv .venv
    source .venv/bin/activate
fi

# Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error: Failed to install dependencies${NC}"
    exit 1
fi

# Check if database is accessible
echo -e "${BLUE}🔍 Checking database connection...${NC}"
python3 -c "from app.database import test_database_connection; test_database_connection()" 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Warning: Database connection failed${NC}"
    echo "Please check your database configuration"
fi

echo
echo -e "${GREEN}🚀 Starting FastAPI server...${NC}"
echo -e "${BLUE}📡 API will be available at: http://localhost:5001${NC}"
echo -e "${BLUE}📚 API documentation: http://localhost:5001/docs${NC}"
echo
echo "Press Ctrl+C to stop the server"
echo

# Start the application
python3 main.py

if [ $? -ne 0 ]; then
    echo
    echo -e "${RED}❌ Error: Application failed to start${NC}"
    exit 1
fi
