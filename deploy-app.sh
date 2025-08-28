#!/bin/bash

# PhanMemKeToan Application Deployment Script
# Chạy với user phanmemketoan: sudo -u phanmemketoan bash deploy-app.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "========================================"
echo "    PHAN MEM KE TOAN DEPLOYMENT"
echo "========================================"
echo -e "${NC}"
echo

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running as correct user
if [ "$USER" != "phanmemketoan" ]; then
    print_error "This script must be run as phanmemketoan user"
    print_warning "Run: sudo -u phanmemketoan bash deploy-app.sh"
    exit 1
fi

# Application directory
APP_DIR="/var/www/phanmemketoan"
BACKEND_DIR="$APP_DIR/PhanMemKeToan_backend"
FRONTEND_DIR="$APP_DIR/PhanMemKeToan-frontend"

# Create application directory if not exists
mkdir -p $APP_DIR
cd $APP_DIR

# Clone or update repository
if [ -d "$BACKEND_DIR" ]; then
    print_status "Updating existing repository..."
    cd $BACKEND_DIR
    git pull origin main
    cd $FRONTEND_DIR
    git pull origin main
else
    print_status "Cloning repository..."
    # Replace with your actual repository URL
    git clone https://github.com/your-username/PhanMemKeToan.git temp
    mv temp/* .
    mv temp/.* . 2>/dev/null || true
    rmdir temp
fi

# Setup Backend
print_status "Setting up Backend..."
cd $BACKEND_DIR

# Create virtual environment
if [ ! -d ".venv" ]; then
    print_status "Creating backend virtual environment..."
    python3 -m venv .venv
fi

# Activate virtual environment
source .venv/bin/activate

# Install dependencies
print_status "Installing backend dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Create .env file if not exists
if [ ! -f ".env" ]; then
    print_status "Creating backend .env file..."
    cp env.example .env
    print_warning "Please edit .env file with your configuration"
fi

# Initialize database
print_status "Initializing database..."
python setup_database.py

# Setup Frontend
print_status "Setting up Frontend..."
cd $FRONTEND_DIR

# Create virtual environment
if [ ! -d ".venv" ]; then
    print_status "Creating frontend virtual environment..."
    python3 -m venv .venv
fi

# Activate virtual environment
source .venv/bin/activate

# Install dependencies
print_status "Installing frontend dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Create .env file if not exists
if [ ! -f ".env" ]; then
    print_status "Creating frontend .env file..."
    cp env.example .env
    print_warning "Please edit .env file with your configuration"
fi

# Set proper permissions
print_status "Setting permissions..."
chmod -R 755 $APP_DIR
chmod 600 $BACKEND_DIR/.env
chmod 600 $FRONTEND_DIR/.env

# Test applications
print_status "Testing applications..."

# Test backend
cd $BACKEND_DIR
source .venv/bin/activate
python -c "
import sys
sys.path.append('.')
from app.database import test_database_connection
if test_database_connection():
    print('Backend database connection: OK')
else:
    print('Backend database connection: FAILED')
    sys.exit(1)
"

# Test frontend
cd $FRONTEND_DIR
source .venv/bin/activate
python -c "
import sys
from config import Config
print(f'Frontend config: OK')
print(f'Backend URL: {Config.BACKEND_URL}')
"

# Restart services
print_status "Restarting services..."
sudo systemctl restart phanmemketoan-backend
sudo systemctl restart phanmemketoan-frontend
sudo systemctl restart nginx

# Wait for services to start
sleep 5

# Check service status
print_status "Checking service status..."
if systemctl is-active --quiet phanmemketoan-backend; then
    print_status "Backend service: RUNNING"
else
    print_error "Backend service: FAILED"
    sudo journalctl -u phanmemketoan-backend --no-pager | tail -10
fi

if systemctl is-active --quiet phanmemketoan-frontend; then
    print_status "Frontend service: RUNNING"
else
    print_error "Frontend service: FAILED"
    sudo journalctl -u phanmemketoan-frontend --no-pager | tail -10
fi

if systemctl is-active --quiet nginx; then
    print_status "Nginx service: RUNNING"
else
    print_error "Nginx service: FAILED"
    sudo journalctl -u nginx --no-pager | tail -10
fi

# Test application endpoints
print_status "Testing application endpoints..."
sleep 3

# Test backend API
if curl -s http://localhost:5001/health > /dev/null; then
    print_status "Backend API: ACCESSIBLE"
else
    print_error "Backend API: NOT ACCESSIBLE"
fi

# Test frontend
if curl -s http://localhost:5000 > /dev/null; then
    print_status "Frontend: ACCESSIBLE"
else
    print_error "Frontend: NOT ACCESSIBLE"
fi

# Create admin user if not exists
print_status "Checking admin user..."
cd $BACKEND_DIR
source .venv/bin/activate
python -c "
import sys
sys.path.append('.')
from app.database import SessionLocal
from app.models import User
from werkzeug.security import generate_password_hash

db = SessionLocal()
admin = db.query(User).filter(User.username == 'admin').first()

if not admin:
    admin = User(
        username='admin',
        password=generate_password_hash('admin123'),
        name='Administrator',
        email='admin@example.com',
        status=True
    )
    db.add(admin)
    db.commit()
    print('Admin user created: admin/admin123')
else:
    print('Admin user already exists')
db.close()
"

# Final status
print_status "Deployment completed!"
echo
echo -e "${BLUE}Application URLs:${NC}"
echo "Frontend: http://your-domain.com"
echo "Backend API: http://your-domain.com/api"
echo "API Docs: http://your-domain.com/api/docs"
echo
echo -e "${BLUE}Default Login:${NC}"
echo "Username: admin"
echo "Password: admin123"
echo
echo -e "${BLUE}Useful commands:${NC}"
echo "monitor-phanmemketoan    - Check system status"
echo "backup-phanmemketoan     - Create backup"
echo "sudo systemctl restart phanmemketoan-backend"
echo "sudo systemctl restart phanmemketoan-frontend"
echo
echo -e "${YELLOW}⚠️  Important:${NC}"
echo "- Change default admin password"
echo "- Configure SSL certificate"
echo "- Update domain name in configuration"
echo "- Setup monitoring and alerts"
echo "- Regular backups"
echo
print_status "Application is ready for use!"
