# ⚡ Quick Deploy Guide

Hướng dẫn triển khai nhanh PhanMemKeToan lên cloud server trong 15 phút.

## 🚀 **Bước 1: Tạo Cloud Server**

### **Chọn Cloud Provider:**

#### **DigitalOcean (Recommended - Dễ nhất)**
1. Tạo account tại [digitalocean.com](https://digitalocean.com)
2. Click "Create" → "Droplets"
3. Chọn:
   - **Image**: Ubuntu 22.04 LTS
   - **Size**: Basic Plan - 2GB RAM / 1 CPU / 50GB SSD
   - **Region**: Singapore (Asia)
   - **Authentication**: SSH Key (recommended) hoặc Password
4. Click "Create Droplet"

#### **AWS EC2**
1. Tạo account tại [aws.amazon.com](https://aws.amazon.com)
2. Launch EC2 Instance
3. Chọn:
   - **AMI**: Ubuntu 22.04 LTS
   - **Instance Type**: t3.micro (free tier) hoặc t3.small
   - **Security Group**: Allow ports 22, 80, 443
4. Launch instance

#### **Vultr**
1. Tạo account tại [vultr.com](https://vultr.com)
2. Deploy New Instance
3. Chọn:
   - **Server**: Cloud Compute
   - **Location**: Singapore
   - **Image**: Ubuntu 22.04 LTS
   - **Size**: 2GB RAM / 1 CPU / 55GB SSD

## 🔧 **Bước 2: Setup Server**

### **Connect to Server:**
```bash
ssh root@your-server-ip
```

### **Run Automated Setup:**
```bash
# Download setup script
wget https://raw.githubusercontent.com/your-username/PhanMemKeToan/main/setup-server.sh
chmod +x setup-server.sh

# Run setup (takes 5-10 minutes)
sudo bash setup-server.sh
```

## 📦 **Bước 3: Deploy Application**

### **Switch to Application User:**
```bash
sudo -u phanmemketoan bash
```

### **Run Automated Deployment:**
```bash
# Download deployment script
wget https://raw.githubusercontent.com/your-username/PhanMemKeToan/main/deploy-app.sh
chmod +x deploy-app.sh

# Run deployment (takes 5-10 minutes)
bash deploy-app.sh
```

## 🌐 **Bước 4: Configure Domain (Optional)**

### **If you have a domain:**
1. Point domain to server IP:
   ```
   your-domain.com → your-server-ip
   www.your-domain.com → your-server-ip
   ```

2. Update Nginx config:
   ```bash
   sudo nano /etc/nginx/sites-available/phanmemketoan
   # Replace 'your-domain.com' with actual domain
   sudo systemctl restart nginx
   ```

3. Install SSL certificate:
   ```bash
   sudo certbot --nginx -d your-domain.com -d www.your-domain.com
   ```

### **If no domain (use IP address):**
```bash
# Update Nginx config to use IP
sudo nano /etc/nginx/sites-available/phanmemketoan
# Replace 'your-domain.com' with '_'
sudo systemctl restart nginx
```

## ✅ **Bước 5: Verify Deployment**

### **Check Application Status:**
```bash
# System status
monitor-phanmemketoan

# Service status
sudo systemctl status phanmemketoan-backend
sudo systemctl status phanmemketoan-frontend
sudo systemctl status nginx
```

### **Access Application:**
- **With domain**: `https://your-domain.com`
- **With IP**: `http://your-server-ip`

### **Default Login:**
- **Username**: `admin`
- **Password**: `admin123`

## 🔒 **Bước 6: Security (Important!)**

### **Change Default Password:**
1. Login to application
2. Go to "Quản lý tài khoản"
3. Change admin password

### **Update Server Passwords:**
```bash
# Change database password
sudo -u postgres psql -c "ALTER USER ketoan_user WITH PASSWORD 'new_secure_password';"

# Update .env files
sudo nano /var/www/phanmemketoan/PhanMemKeToan_backend/.env
sudo nano /var/www/phanmemketoan/PhanMemKeToan-frontend/.env
```

## 📊 **Bước 7: Monitoring & Maintenance**

### **Setup Monitoring:**
```bash
# Check system status
monitor-phanmemketoan

# Setup automatic backups
sudo crontab -e
# Add: 0 2 * * * /usr/local/bin/backup-phanmemketoan
```

### **Update Application:**
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
chmod +x /usr/local/bin/update-phanmemketoan
```

## 🆘 **Troubleshooting**

### **Common Issues:**

#### **Application not accessible:**
```bash
# Check services
sudo systemctl status phanmemketoan-backend
sudo systemctl status phanmemketoan-frontend
sudo systemctl status nginx

# Check logs
sudo journalctl -u phanmemketoan-backend -f
sudo journalctl -u phanmemketoan-frontend -f
```

#### **Database connection error:**
```bash
# Check PostgreSQL
sudo systemctl status postgresql

# Test connection
psql -h localhost -U ketoan_user -d ketoan
```

#### **Permission issues:**
```bash
# Fix permissions
sudo chown -R phanmemketoan:phanmemketoan /var/www/phanmemketoan/
sudo chmod -R 755 /var/www/phanmemketoan/
```

### **Useful Commands:**
```bash
# System status
monitor-phanmemketoan

# Backup
backup-phanmemketoan

# Update
update-phanmemketoan

# Restart services
sudo systemctl restart phanmemketoan-backend
sudo systemctl restart phanmemketoan-frontend
sudo systemctl restart nginx

# View logs
sudo journalctl -u phanmemketoan-backend -f
sudo tail -f /var/log/nginx/error.log
```

## 💰 **Cost Estimation**

### **Monthly Costs:**

| Provider | Plan | Monthly Cost |
|----------|------|--------------|
| DigitalOcean | 2GB RAM / 1 CPU | $12/month |
| AWS EC2 | t3.small | $15-20/month |
| Vultr | 2GB RAM / 1 CPU | $10/month |

### **Additional Costs:**
- **Domain**: $10-15/year
- **SSL Certificate**: Free (Let's Encrypt)
- **Backup Storage**: $5-10/month (optional)

## 🎯 **Next Steps**

1. **Customize Application:**
   - Update company information
   - Configure email settings
   - Customize UI/UX

2. **Add Features:**
   - Email notifications
   - Advanced reporting
   - Mobile app

3. **Scale Up:**
   - Load balancer
   - Database replication
   - CDN for static files

4. **Security:**
   - Regular security updates
   - Vulnerability scanning
   - Access logging

---

**🎉 Congratulations! Your PhanMemKeToan application is now live and ready for business!**

**Need help?** Check the full [DEPLOYMENT.md](DEPLOYMENT.md) guide or create an issue on GitHub.
