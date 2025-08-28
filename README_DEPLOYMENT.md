# 🚀 PhanMemKeToan - Deployment Guide

Hướng dẫn triển khai ứng dụng PhanMemKeToan lên các nền tảng cloud khác nhau.

## 📋 **Mục lục**

1. [Tổng quan](#tổng-quan)
2. [Deployment Options](#deployment-options)
3. [Free Cloud Deployment](#free-cloud-deployment)
4. [Paid Cloud Deployment](#paid-cloud-deployment)
5. [Local Development](#local-development)
6. [Troubleshooting](#troubleshooting)

## 🎯 **Tổng quan**

PhanMemKeToan là ứng dụng quản lý kế toán với kiến trúc:
- **Frontend**: Flask (Python)
- **Backend**: FastAPI (Python)
- **Database**: PostgreSQL
- **Authentication**: JWT

## 🌐 **Deployment Options**

### **1. Free Cloud (Recommended)**
- **Frontend**: Vercel (Free)
- **Backend**: Render (Free)
- **Database**: Render PostgreSQL (Free)
- **Cost**: $0/month
- **Best for**: Personal projects, small businesses

### **2. Paid Cloud**
- **Frontend**: AWS S3 + CloudFront
- **Backend**: AWS EC2, DigitalOcean, Vultr
- **Database**: AWS RDS, DigitalOcean Managed Database
- **Cost**: $10-50/month
- **Best for**: Production, enterprise

### **3. Local Development**
- **Frontend**: Local Flask server
- **Backend**: Local FastAPI server
- **Database**: Local PostgreSQL
- **Cost**: $0
- **Best for**: Development, testing

## 🆓 **Free Cloud Deployment**

### **Quick Start (10 minutes)**
```bash
# 1. Clone repository
git clone https://github.com/your-username/PhanMemKeToan.git
cd PhanMemKeToan

# 2. Follow quick guide
# See: QUICK_FREE_DEPLOY.md
```

### **Step-by-Step Guide**
```bash
# 1. Deploy Backend (Render)
# See: FREE_CLOUD_DEPLOY.md - Section 2

# 2. Deploy Frontend (Vercel)
# See: FREE_CLOUD_DEPLOY.md - Section 3

# 3. Configure Database
# See: FREE_CLOUD_DEPLOY.md - Section 4
```

### **Configuration Files**
- `render.yaml` - Render configuration
- `vercel.json` - Vercel configuration
- `backend/setup_database.py` - Database setup script

### **Environment Variables**

#### **Backend (Render)**
```env
DATABASE_URL=postgresql://user:pass@host:port/db
SECRET_KEY=your-secret-key
CORS_ORIGINS=https://your-frontend.vercel.app
ENVIRONMENT=production
```

#### **Frontend (Vercel)**
```env
BACKEND_URL=https://your-backend.onrender.com
FLASK_ENV=production
SECRET_KEY=your-secret-key
```

## 💰 **Paid Cloud Deployment**

### **AWS Deployment**
```bash
# 1. Setup EC2 Instance
# See: DEPLOYMENT.md - Section 1

# 2. Deploy Application
# See: DEPLOYMENT.md - Section 3

# 3. Configure Domain & SSL
# See: DEPLOYMENT.md - Section 4
```

### **DigitalOcean Deployment**
```bash
# 1. Create Droplet
# See: DEPLOYMENT.md - Section 1.1

# 2. Run setup script
sudo bash setup-server.sh

# 3. Deploy application
sudo -u phanmemketoan bash deploy-app.sh
```

### **Configuration Files**
- `setup-server.sh` - Server setup script
- `deploy-app.sh` - Application deployment script
- `DEPLOYMENT.md` - Detailed deployment guide

## 💻 **Local Development**

### **Prerequisites**
```bash
# Install Python 3.9+
# Install PostgreSQL
# Install Git
```

### **Setup**
```bash
# 1. Clone repository
git clone https://github.com/your-username/PhanMemKeToan.git
cd PhanMemKeToan

# 2. Setup Backend
cd PhanMemKeToan_backend
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt

# 3. Setup Database
python setup_database.py

# 4. Run Backend
python main.py

# 5. Setup Frontend (new terminal)
cd ../PhanMemKeToan-frontend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# 6. Run Frontend
python app.py
```

### **Access URLs**
- **Frontend**: http://localhost:5000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

## 🔧 **Configuration**

### **Database Configuration**
```python
# backend/app/database.py
DATABASE_URL = os.environ.get("DATABASE_URL", "postgresql://user:pass@localhost/ketoan")
```

### **CORS Configuration**
```python
# backend/main.py
CORS_ORIGINS = [
    "https://your-frontend.vercel.app",
    "http://localhost:5000",
    "http://localhost:3000"
]
```

### **Environment Files**
```bash
# backend/.env
DATABASE_URL=postgresql://user:pass@localhost/ketoan
SECRET_KEY=your-secret-key
ENVIRONMENT=development

# frontend/.env
BACKEND_URL=http://localhost:8000
FLASK_ENV=development
SECRET_KEY=your-secret-key
```

## 🆘 **Troubleshooting**

### **Common Issues**

#### **Database Connection Failed**
```bash
# Check DATABASE_URL format
# Render uses postgresql:// not postgres://
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)
```

#### **CORS Errors**
```python
# Update CORS_ORIGINS in backend
CORS_ORIGINS = [
    "https://your-frontend-domain.com",
    "http://localhost:5000"
]
```

#### **Build Failures**
```bash
# Check requirements.txt
# Verify Python version
# Check environment variables
```

### **Debug Commands**
```bash
# Test backend
curl https://your-backend.onrender.com/health

# Test frontend
curl -I https://your-frontend.vercel.app

# Test database
curl https://your-backend.onrender.com/api/products/
```

### **Logs & Monitoring**

#### **Render Logs**
- Dashboard → Service → Logs
- Real-time application logs
- Build logs

#### **Vercel Logs**
- Dashboard → Project → Functions
- Function logs
- Build logs

#### **Local Logs**
```bash
# Backend logs
tail -f backend/logs/app.log

# Frontend logs
tail -f frontend/logs/app.log
```

## 📊 **Performance Optimization**

### **Backend Optimization**
```python
# Add caching
from fastapi_cache import FastAPICache
from fastapi_cache.backends.redis import RedisBackend

# Add compression
from fastapi.middleware.gzip import GZipMiddleware
app.add_middleware(GZipMiddleware, minimum_size=1000)
```

### **Frontend Optimization**
```python
# Add static file caching
@app.after_request
def add_header(response):
    if 'static' in request.path:
        response.headers['Cache-Control'] = 'public, max-age=31536000'
    return response
```

### **Database Optimization**
```sql
-- Add indexes
CREATE INDEX idx_products_name ON products(ten_sp);
CREATE INDEX idx_orders_date ON orders(ngay_tao);

-- Optimize queries
VACUUM ANALYZE;
```

## 🔒 **Security**

### **Production Security**
```python
# Use strong passwords
# Enable HTTPS
# Configure CORS properly
# Use environment variables
# Regular security updates
```

### **Environment Variables**
```bash
# Never commit secrets
# Use .env files locally
# Use platform environment variables in production
```

## 📈 **Scaling**

### **Horizontal Scaling**
```bash
# Load balancer
# Database replication
# CDN for static files
# Microservices architecture
```

### **Vertical Scaling**
```bash
# Upgrade server resources
# Optimize database
# Use caching
# Monitor performance
```

## 📞 **Support**

### **Documentation**
- [Free Cloud Deployment](FREE_CLOUD_DEPLOY.md)
- [Quick Free Deploy](QUICK_FREE_DEPLOY.md)
- [Paid Cloud Deployment](DEPLOYMENT.md)
- [Quick Deploy](QUICK_DEPLOY.md)

### **Getting Help**
- Create issue on GitHub
- Check platform documentation
- Review logs and error messages
- Test locally first

### **Useful Links**
- [Render Documentation](https://render.com/docs)
- [Vercel Documentation](https://vercel.com/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Flask Documentation](https://flask.palletsprojects.com/)

---

**🎉 Happy Deploying!**

Choose the deployment option that best fits your needs and budget. The free cloud option is perfect for getting started quickly!
