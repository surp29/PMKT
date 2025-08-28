#!/bin/bash

# PhanMemKeToan Server Setup Script
# Chạy với quyền root: sudo bash setup-server.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "========================================"
echo "    PHAN MEM KE TOAN SERVER SETUP"
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

# Update system
print_status "Updating system packages..."
apt update && apt upgrade -y

# Install essential packages
print_status "Installing essential packages..."
apt install -y curl wget git unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Install Python 3.9+
print_status "Installing Python 3.9+..."
apt install -y python3 python3-pip python3-venv python3-dev

# Install PostgreSQL
print_status "Installing PostgreSQL..."
apt install -y postgresql postgresql-contrib

# Install Nginx
print_status "Installing Nginx..."
apt install -y nginx

# Install Redis (optional, for caching)
print_status "Installing Redis..."
apt install -y redis-server

# Install Certbot for SSL
print_status "Installing Certbot..."
apt install -y certbot python3-certbot-nginx

# Install UFW firewall
print_status "Installing UFW firewall..."
apt install -y ufw

# Install Fail2ban for security
print_status "Installing Fail2ban..."
apt install -y fail2ban

# Install monitoring tools
print_status "Installing monitoring tools..."
apt install -y htop iotop nethogs

# Create application user
print_status "Creating application user..."
useradd -m -s /bin/bash phanmemketoan
usermod -aG sudo phanmemketoan

# Setup PostgreSQL
print_status "Setting up PostgreSQL..."
sudo -u postgres psql -c "CREATE DATABASE ketoan;"
sudo -u postgres psql -c "CREATE USER ketoan_user WITH PASSWORD 'your_secure_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ketoan TO ketoan_user;"
sudo -u postgres psql -c "ALTER USER ketoan_user CREATEDB;"

# Configure PostgreSQL
print_status "Configuring PostgreSQL..."
echo "listen_addresses = '*'" >> /etc/postgresql/*/main/postgresql.conf
echo "host ketoan ketoan_user 127.0.0.1/32 md5" >> /etc/postgresql/*/main/pg_hba.conf
echo "host ketoan ketoan_user ::1/128 md5" >> /etc/postgresql/*/main/pg_hba.conf

# Restart PostgreSQL
systemctl restart postgresql
systemctl enable postgresql

# Setup firewall
print_status "Configuring firewall..."
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 5000/tcp
ufw allow 5001/tcp

# Create application directory
print_status "Creating application directory..."
mkdir -p /var/www/phanmemketoan
chown phanmemketoan:phanmemketoan /var/www/phanmemketoan

# Setup Nginx configuration
print_status "Setting up Nginx configuration..."
cat > /etc/nginx/sites-available/phanmemketoan << 'EOF'
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    # Frontend
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Backend API
    location /api/ {
        proxy_pass http://127.0.0.1:5001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files
    location /static/ {
        alias /var/www/phanmemketoan/PhanMemKeToan-frontend/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/phanmemketoan /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart Nginx
systemctl restart nginx
systemctl enable nginx

# Setup systemd services
print_status "Setting up systemd services..."

# Backend service
cat > /etc/systemd/system/phanmemketoan-backend.service << 'EOF'
[Unit]
Description=PhanMemKeToan Backend
After=network.target postgresql.service

[Service]
Type=simple
User=phanmemketoan
Group=phanmemketoan
WorkingDirectory=/var/www/phanmemketoan/PhanMemKeToan_backend
Environment=PATH=/var/www/phanmemketoan/PhanMemKeToan_backend/.venv/bin
ExecStart=/var/www/phanmemketoan/PhanMemKeToan_backend/.venv/bin/python main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Frontend service
cat > /etc/systemd/system/phanmemketoan-frontend.service << 'EOF'
[Unit]
Description=PhanMemKeToan Frontend
After=network.target

[Service]
Type=simple
User=phanmemketoan
Group=phanmemketoan
WorkingDirectory=/var/www/phanmemketoan/PhanMemKeToan-frontend
Environment=PATH=/var/www/phanmemketoan/PhanMemKeToan-frontend/.venv/bin
ExecStart=/var/www/phanmemketoan/PhanMemKeToan-frontend/.venv/bin/python app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
systemctl daemon-reload

# Setup monitoring script
print_status "Setting up monitoring script..."
cat > /usr/local/bin/monitor-phanmemketoan << 'EOF'
#!/bin/bash
echo "=== PhanMemKeToan System Status ==="
echo "Backend: $(systemctl is-active phanmemketoan-backend)"
echo "Frontend: $(systemctl is-active phanmemketoan-frontend)"
echo "PostgreSQL: $(systemctl is-active postgresql)"
echo "Nginx: $(systemctl is-active nginx)"
echo "Redis: $(systemctl is-active redis-server)"
echo
echo "=== System Resources ==="
echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "Memory Usage: $(free | grep Mem | awk '{printf "%.2f%%", $3/$2 * 100.0}')"
echo "Disk Usage: $(df -h / | awk 'NR==2 {print $5}')"
echo
echo "=== Recent Logs ==="
journalctl -u phanmemketoan-backend --since "5 minutes ago" --no-pager | tail -5
EOF

chmod +x /usr/local/bin/monitor-phanmemketoan

# Setup backup script
print_status "Setting up backup script..."
mkdir -p /backups
cat > /usr/local/bin/backup-phanmemketoan << 'EOF'
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="phanmemketoan_backup_$DATE"

# Create backup directory
mkdir -p $BACKUP_DIR/$BACKUP_NAME

# Backup database
sudo -u postgres pg_dump ketoan > $BACKUP_DIR/$BACKUP_NAME/database.sql

# Backup application files
cp -r /var/www/phanmemketoan $BACKUP_DIR/$BACKUP_NAME/

# Backup configuration files
cp -r /etc/nginx/sites-available/phanmemketoan $BACKUP_DIR/$BACKUP_NAME/
cp -r /etc/systemd/system/phanmemketoan-*.service $BACKUP_DIR/$BACKUP_NAME/

# Create archive
tar -czf $BACKUP_DIR/$BACKUP_NAME.tar.gz -C $BACKUP_DIR $BACKUP_NAME
rm -rf $BACKUP_DIR/$BACKUP_NAME

# Keep only last 7 backups
find $BACKUP_DIR -name "phanmemketoan_backup_*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
EOF

chmod +x /usr/local/bin/backup-phanmemketoan

# Setup cron jobs
print_status "Setting up cron jobs..."
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-phanmemketoan") | crontab -
(crontab -l 2>/dev/null; echo "0 3 * * 0 /usr/local/bin/backup-phanmemketoan") | crontab -

# Final status
print_status "Server setup completed!"
echo
echo -e "${BLUE}Next steps:${NC}"
echo "1. Clone your repository to /var/www/phanmemketoan/"
echo "2. Setup virtual environments and install dependencies"
echo "3. Configure environment variables"
echo "4. Initialize database"
echo "5. Start services"
echo
echo -e "${BLUE}Useful commands:${NC}"
echo "monitor-phanmemketoan    - Check system status"
echo "backup-phanmemketoan     - Create backup"
echo "systemctl status phanmemketoan-backend"
echo "systemctl status phanmemketoan-frontend"
echo
echo -e "${YELLOW}⚠️  Remember to:${NC}"
echo "- Change default passwords"
echo "- Configure SSL certificate"
echo "- Update domain name in Nginx config"
echo "- Setup monitoring and alerts"
echo "- Configure firewall rules"
echo
print_status "Server is ready for application deployment!"
