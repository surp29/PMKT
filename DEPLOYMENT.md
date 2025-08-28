# 🚀 Hướng dẫn triển khai PhanMemKeToan lên Cloud Server

Hướng dẫn chi tiết để triển khai ứng dụng PhanMemKeToan lên cloud server thực tế.

## 📋 **Mục lục**

1. [Chuẩn bị Cloud Server](#1-chuẩn-bị-cloud-server)
2. [Setup Server Environment](#2-setup-server-environment)
3. [Deploy Application](#3-deploy-application)
4. [Configure Domain & SSL](#4-configure-domain--ssl)
5. [Security & Monitoring](#5-security--monitoring)
6. [Maintenance & Backup](#6-maintenance--backup)
7. [Troubleshooting](#7-troubleshooting)

## 1. Chuẩn bị Cloud Server

### **1.1 Chọn Cloud Provider**

#### **AWS EC2 (Recommended)**
```bash
# Instance Type: t3.medium hoặc t3.large
# OS: Ubuntu 22.04 LTS
# Storage: 40GB GP3 SSD
# Security Group: Allow ports 22, 80, 443
```

#### **DigitalOcean**
```bash
# Droplet: Basic Plan
# Size: 2GB RAM / 1 CPU / 50GB SSD
# OS: Ubuntu 22.04 LTS
# Region: Singapore (Asia)
```

#### **Vultr**
```bash
# Instance: Cloud Compute
# Plan: 2GB RAM / 1 CPU / 55GB SSD
# OS: Ubuntu 22.04 LTS
# Location: Singapore
```

### **1.2 Server Specifications tối thiểu**

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 1 core | 2 cores |
| RAM | 2GB | 4GB |
| Storage | 20GB SSD | 40GB SSD |
| Network | 100Mbps | 1Gbps |
| OS | Ubuntu 20.04+ | Ubuntu 22.04 LTS |

### **1.3 Initial Server Setup**

```bash
# Connect to server
ssh root@your-server-ip

# Update system
apt update && apt upgrade -y

# Create non-root user
adduser phanmemketoan
usermod -aG sudo phanmemketoan

# Setup SSH key authentication
mkdir -p /home/phanmemketoan/.ssh
cp ~/.ssh/authorized_keys /home/phanmemketoan/.ssh/
chown -R phanmemketoan:phanmemketoan /home/phanmemketoan/.ssh
chmod 700 /home/phanmemketoan/.ssh
chmod 600 /home/phanmemketoan/.ssh/authorized_keys

# Disable root login
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd
```

## 2. Setup Server Environment

### **2.1 Automated Setup**

```bash
# Download setup script
wget https://raw.githubusercontent.com/your-username/PhanMemKeToan/main/setup-server.sh
chmod +x setup-server.sh

# Run setup script
sudo bash setup-server.sh
```

### **2.2 Manual Setup**

#### **Install Dependencies**
```bash
# Essential packages
apt install -y curl wget git unzip software-properties-common

# Python 3.9+
apt install -y python3 python3-pip python3-venv python3-dev

# PostgreSQL
apt install -y postgresql postgresql-contrib

# Nginx
apt install -y nginx

# Redis (optional)
apt install -y redis-server

# Certbot for SSL
apt install -y certbot python3-certbot-nginx

# Security tools
apt install -y ufw fail2ban
```

#### **Configure PostgreSQL**
```bash
# Create database and user
sudo -u postgres psql -c "CREATE DATABASE ketoan;"
sudo -u postgres psql -c "CREATE USER ketoan_user WITH PASSWORD 'your_secure_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ketoan TO ketoan_user;"
sudo -u postgres psql -c "ALTER USER ketoan_user CREATEDB;"

# Configure PostgreSQL
echo "listen_addresses = '*'" >> /etc/postgresql/*/main/postgresql.conf
echo "host ketoan ketoan_user 127.0.0.1/32 md5" >> /etc/postgresql/*/main/pg_hba.conf

# Restart PostgreSQL
systemctl restart postgresql
systemctl enable postgresql
```

#### **Configure Firewall**
```bash
# Enable UFW
ufw --force enable
ufw default deny incoming
ufw default allow outgoing

# Allow necessary ports
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 5000/tcp
ufw allow 5001/tcp

# Check status
ufw status
```

## 3. Deploy Application

### **3.1 Automated Deployment**

```bash
# Switch to application user
sudo -u phanmemketoan bash

# Download deployment script
wget https://raw.githubusercontent.com/your-username/PhanMemKeToan/main/deploy-app.sh
chmod +x deploy-app.sh

# Run deployment
bash deploy-app.sh
```

### **3.2 Manual Deployment**

#### **Clone Repository**
```bash
# Create application directory
mkdir -p /var/www/phanmemketoan
cd /var/www/phanmemketoan

# Clone repository
git clone https://github.com/your-username/PhanMemKeToan.git .
```

#### **Setup Backend**
```bash
cd /var/www/phanmemketoan/PhanMemKeToan_backend

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Configure environment
cp env.example .env
nano .env  # Edit configuration

# Initialize database
python setup_database.py
```

#### **Setup Frontend**
```bash
cd /var/www/phanmemketoan/PhanMemKeToan-frontend

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Configure environment
cp env.example .env
nano .env  # Edit configuration
```

#### **Configure Systemd Services**

**Backend Service**
```bash
sudo nano /etc/systemd/system/phanmemketoan-backend.service
```

```ini
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
```

**Frontend Service**
```bash
sudo nano /etc/systemd/system/phanmemketoan-frontend.service
```

```ini
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
```

#### **Start Services**
```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable and start services
sudo systemctl enable phanmemketoan-backend
sudo systemctl enable phanmemketoan-frontend
sudo systemctl start phanmemketoan-backend
sudo systemctl start phanmemketoan-frontend

# Check status
sudo systemctl status phanmemketoan-backend
sudo systemctl status phanmemketoan-frontend
```

### **3.3 Configure Nginx**

```bash
sudo nano /etc/nginx/sites-available/phanmemketoan
```

```nginx
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
```

```bash
# Enable site
sudo ln -sf /etc/nginx/sites-available/phanmemketoan /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```

## 4. Configure Domain & SSL

### **4.1 Domain Configuration**

1. **Point domain to server IP**
   ```bash
   # Add A record in DNS
   your-domain.com -> your-server-ip
   www.your-domain.com -> your-server-ip
   ```

2. **Update Nginx configuration**
   ```bash
   sudo nano /etc/nginx/sites-available/phanmemketoan
   # Replace your-domain.com with actual domain
   ```

### **4.2 SSL Certificate**

```bash
# Install SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Test auto-renewal
sudo certbot renew --dry-run

# Setup auto-renewal cron job
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 5. Security & Monitoring

### **5.1 Security Hardening**

```bash
# Configure Fail2ban
sudo nano /etc/fail2ban/jail.local
```

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 3
```

```bash
# Restart Fail2ban
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban
```

### **5.2 Monitoring Setup**

```bash
# Create monitoring script
sudo nano /usr/local/bin/monitor-phanmemketoan
```

```bash
#!/bin/bash
echo "=== PhanMemKeToan System Status ==="
echo "Backend: $(systemctl is-active phanmemketoan-backend)"
echo "Frontend: $(systemctl is-active phanmemketoan-frontend)"
echo "PostgreSQL: $(systemctl is-active postgresql)"
echo "Nginx: $(systemctl is-active nginx)"
echo
echo "=== System Resources ==="
echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "Memory Usage: $(free | grep Mem | awk '{printf "%.2f%%", $3/$2 * 100.0}')"
echo "Disk Usage: $(df -h / | awk 'NR==2 {print $5}')"
```

```bash
# Make executable
sudo chmod +x /usr/local/bin/monitor-phanmemketoan

# Test monitoring
monitor-phanmemketoan
```

## 6. Maintenance & Backup

### **6.1 Backup System**

```bash
# Create backup script
sudo nano /usr/local/bin/backup-phanmemketoan
```

```bash
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
```

```bash
# Make executable
sudo chmod +x /usr/local/bin/backup-phanmemketoan

# Setup automatic backups
sudo crontab -e
# Add: 0 2 * * * /usr/local/bin/backup-phanmemketoan
```

### **6.2 Update Application**

```bash
# Create update script
sudo nano /usr/local/bin/update-phanmemketoan
```

```bash
#!/bin/bash
cd /var/www/phanmemketoan

# Backup before update
/usr/local/bin/backup-phanmemketoan

# Update backend
cd PhanMemKeToan_backend
git pull origin main
source .venv/bin/activate
pip install -r requirements.txt

# Update frontend
cd ../PhanMemKeToan-frontend
git pull origin main
source .venv/bin/activate
pip install -r requirements.txt

# Restart services
sudo systemctl restart phanmemketoan-backend
sudo systemctl restart phanmemketoan-frontend

echo "Application updated successfully!"
```

```bash
# Make executable
sudo chmod +x /usr/local/bin/update-phanmemketoan
```

## 7. Troubleshooting

### **7.1 Common Issues**

#### **Service won't start**
```bash
# Check logs
sudo journalctl -u phanmemketoan-backend -f
sudo journalctl -u phanmemketoan-frontend -f

# Check permissions
ls -la /var/www/phanmemketoan/
sudo chown -R phanmemketoan:phanmemketoan /var/www/phanmemketoan/

# Check virtual environment
cd /var/www/phanmemketoan/PhanMemKeToan_backend
source .venv/bin/activate
python -c "import app; print('Backend OK')"
```

#### **Database connection error**
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Test connection
psql -h localhost -U ketoan_user -d ketoan

# Check database exists
sudo -u postgres psql -c "\l"

# Recreate database if needed
sudo -u postgres dropdb ketoan
sudo -u postgres createdb ketoan
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ketoan TO ketoan_user;"
```

#### **Nginx configuration error**
```bash
# Test configuration
sudo nginx -t

# Check syntax
sudo nginx -T | grep -A 10 -B 10 "server_name"

# Check logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### **7.2 Performance Issues**

#### **High CPU/Memory usage**
```bash
# Check resource usage
htop
free -h
df -h

# Check database performance
sudo -u postgres psql -d ketoan -c "SELECT * FROM pg_stat_activity;"

# Optimize database
sudo -u postgres psql -d ketoan -c "VACUUM ANALYZE;"
```

#### **Slow response times**
```bash
# Check nginx configuration
sudo nginx -T

# Enable caching
sudo nano /etc/nginx/sites-available/phanmemketoan
# Add caching headers

# Check application logs
sudo journalctl -u phanmemketoan-backend --since "1 hour ago"
```

### **7.3 Security Issues**

#### **Failed login attempts**
```bash
# Check Fail2ban status
sudo fail2ban-client status

# Check banned IPs
sudo fail2ban-client status sshd

# Unban IP if needed
sudo fail2ban-client set sshd unbanip your-ip-address
```

#### **SSL certificate issues**
```bash
# Check certificate status
sudo certbot certificates

# Renew certificate
sudo certbot renew --dry-run

# Reinstall certificate
sudo certbot --nginx -d your-domain.com
```

## 📞 **Support**

### **Getting Help**
- Create issue on GitHub
- Check logs: `sudo journalctl -u phanmemketoan-backend -f`
- Monitor system: `monitor-phanmemketoan`
- Backup data: `backup-phanmemketoan`

### **Useful Commands**
```bash
# System status
monitor-phanmemketoan

# Service management
sudo systemctl status phanmemketoan-backend
sudo systemctl restart phanmemketoan-backend
sudo systemctl restart phanmemketoan-frontend

# Logs
sudo journalctl -u phanmemketoan-backend --since "1 hour ago"
sudo tail -f /var/log/nginx/error.log

# Database
sudo -u postgres psql -d ketoan
sudo -u postgres pg_dump ketoan > backup.sql

# Backup
backup-phanmemketoan

# Update
update-phanmemketoan
```

---

**🎉 Congratulations! Your PhanMemKeToan application is now deployed and ready for production use!**
