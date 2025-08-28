# 🆓 Hướng dẫn triển khai FREE trên Cloud (Render + Vercel)

Hướng dẫn chi tiết để triển khai PhanMemKeToan lên cloud miễn phí sử dụng Render cho backend và Vercel cho frontend.

## 🎯 **Tổng quan giải pháp**

### **Kiến trúc triển khai:**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   Database      │
│   (Vercel)      │◄──►│   (Render)      │◄──►│   (Render)      │
│   Free          │    │   Free          │    │   Free          │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **Ưu điểm:**
- ✅ **Hoàn toàn miễn phí**
- ✅ **Tự động scale**
- ✅ **SSL tự động**
- ✅ **CDN toàn cầu**
- ✅ **Deploy tự động từ Git**
- ✅ **Monitoring tích hợp**

## 📋 **Mục lục**

1. [Chuẩn bị Repository](#1-chuẩn-bị-repository)
2. [Deploy Backend lên Render](#2-deploy-backend-lên-render)
3. [Deploy Frontend lên Vercel](#3-deploy-frontend-lên-vercel)
4. [Cấu hình Database](#4-cấu-hình-database)
5. [Kết nối Frontend-Backend](#5-kết-nối-frontend-backend)
6. [Testing & Monitoring](#6-testing--monitoring)
7. [Troubleshooting](#7-troubleshooting)

## 1. Chuẩn bị Repository

### **1.1 Cấu trúc Repository**

Đảm bảo repository có cấu trúc như sau:
```
PhanMemKeToan/
├── backend/
│   ├── main.py
│   ├── requirements.txt
│   ├── app/
│   └── ...
├── frontend/
│   ├── app.py
│   ├── requirements.txt
│   ├── templates/
│   └── static/
├── render.yaml
├── vercel.json
└── README.md
```

### **1.2 Cập nhật Backend cho Render**

#### **Cập nhật main.py:**
```python
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI()

# CORS configuration for production
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://phanmemketoan.vercel.app",
        "http://localhost:3000",
        "http://localhost:5000"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Import your routes
from app.routes import auth, products, orders, customers, reports

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(products.router, prefix="/api/products", tags=["products"])
app.include_router(orders.router, prefix="/api/orders", tags=["orders"])
app.include_router(customers.router, prefix="/api/customers", tags=["customers"])
app.include_router(reports.router, prefix="/api/reports", tags=["reports"])

@app.get("/")
async def root():
    return {"message": "PhanMemKeToan API is running!"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
```

#### **Cập nhật requirements.txt:**
```txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
python-multipart==0.0.6
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-dotenv==1.0.0
alembic==1.12.1
```

### **1.3 Cập nhật Frontend cho Vercel**

#### **Cập nhật app.py:**
```python
import os
from flask import Flask, render_template, request, jsonify, redirect, url_for
import requests
from functools import wraps

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'your-secret-key')

# Backend URL from environment
BACKEND_URL = os.environ.get('BACKEND_URL', 'http://localhost:8000')

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        data = {
            'username': request.form['username'],
            'password': request.form['password']
        }
        response = requests.post(f'{BACKEND_URL}/api/auth/login', json=data)
        if response.status_code == 200:
            result = response.json()
            session['user_id'] = result['user_id']
            session['token'] = result['access_token']
            return redirect(url_for('dashboard'))
        else:
            return render_template('login.html', error='Login failed')
    return render_template('login.html')

@app.route('/dashboard')
@login_required
def dashboard():
    return render_template('dashboard.html')

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
```

#### **Cập nhật requirements.txt:**
```txt
flask==3.0.0
requests==2.31.0
python-dotenv==1.0.0
```

## 2. Deploy Backend lên Render

### **2.1 Tạo tài khoản Render**

1. Truy cập [render.com](https://render.com)
2. Đăng ký tài khoản (có thể dùng GitHub)
3. Xác thực email

### **2.2 Tạo Database**

1. **Tạo PostgreSQL Database:**
   - Click "New" → "PostgreSQL"
   - Name: `phanmemketoan-db`
   - Plan: Free
   - Region: Singapore (Asia)
   - Click "Create Database"

2. **Lưu thông tin kết nối:**
   - Internal Database URL
   - External Database URL
   - Database Name: `ketoan`
   - Username: `ketoan_user`

### **2.3 Deploy Backend Service**

1. **Tạo Web Service:**
   - Click "New" → "Web Service"
   - Connect GitHub repository
   - Chọn repository `PhanMemKeToan`

2. **Cấu hình Service:**
   ```
   Name: phanmemketoan-backend
   Environment: Python 3
   Build Command: pip install -r backend/requirements.txt
   Start Command: cd backend && python main.py
   Plan: Free
   ```

3. **Cấu hình Environment Variables:**
   ```
   DATABASE_URL = [Internal Database URL từ bước 2.2]
   SECRET_KEY = [Generate random key]
   CORS_ORIGINS = https://phanmemketoan.vercel.app,http://localhost:3000
   ENVIRONMENT = production
   ```

4. **Deploy:**
   - Click "Create Web Service"
   - Chờ build và deploy hoàn tất
   - Lưu URL: `https://phanmemketoan-backend.onrender.com`

### **2.4 Cấu hình Auto-Deploy**

1. **Kích hoạt Auto-Deploy:**
   - Vào service settings
   - Enable "Auto-Deploy"
   - Chọn branch `main`

2. **Setup Database Migration:**
   ```bash
   # Thêm vào build command
   pip install -r backend/requirements.txt && cd backend && python setup_database.py
   ```

## 3. Deploy Frontend lên Vercel

### **3.1 Tạo tài khoản Vercel**

1. Truy cập [vercel.com](https://vercel.com)
2. Đăng ký tài khoản (có thể dùng GitHub)
3. Xác thực email

### **3.2 Deploy Frontend**

1. **Import Project:**
   - Click "New Project"
   - Import Git Repository
   - Chọn repository `PhanMemKeToan`

2. **Cấu hình Project:**
   ```
   Framework Preset: Other
   Root Directory: frontend
   Build Command: pip install -r requirements.txt
   Output Directory: .
   Install Command: pip install -r requirements.txt
   ```

3. **Cấu hình Environment Variables:**
   ```
   BACKEND_URL = https://phanmemketoan-backend.onrender.com
   FLASK_ENV = production
   SECRET_KEY = [Generate random key]
   ```

4. **Deploy:**
   - Click "Deploy"
   - Chờ build và deploy hoàn tất
   - Lưu URL: `https://phanmemketoan.vercel.app`

### **3.3 Cấu hình Custom Domain (Optional)**

1. **Thêm Custom Domain:**
   - Vào project settings
   - Domains → Add Domain
   - Nhập domain của bạn
   - Cấu hình DNS records

2. **Cập nhật CORS:**
   - Quay lại Render backend
   - Cập nhật CORS_ORIGINS với domain mới

## 4. Cấu hình Database

### **4.1 Khởi tạo Database Schema**

1. **Tạo migration script:**
   ```python
   # backend/setup_database.py
   import os
   from sqlalchemy import create_engine
   from app.database import Base
   from app.models import *

   DATABASE_URL = os.environ.get("DATABASE_URL")
   if DATABASE_URL.startswith("postgres://"):
       DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

   engine = create_engine(DATABASE_URL)
   Base.metadata.create_all(bind=engine)
   print("Database tables created successfully!")
   ```

2. **Chạy migration:**
   - Vào Render dashboard
   - Vào backend service
   - Manual Deploy → Clear build cache & deploy

### **4.2 Tạo Admin User**

1. **Tạo script tạo admin:**
   ```python
   # backend/create_admin.py
   import os
   from app.database import SessionLocal
   from app.models import User
   from werkzeug.security import generate_password_hash

   db = SessionLocal()
   admin = User(
       username='admin',
       password=generate_password_hash('admin123'),
       name='Administrator',
       email='admin@example.com',
       status=True
   )
   db.add(admin)
   db.commit()
   db.close()
   print("Admin user created!")
   ```

2. **Chạy script:**
   - Thêm vào build command hoặc chạy manual

## 5. Kết nối Frontend-Backend

### **5.1 Cập nhật Frontend Configuration**

1. **Cập nhật config.py:**
   ```python
   # frontend/config.py
   import os

   class Config:
       SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key'
       BACKEND_URL = os.environ.get('BACKEND_URL') or 'http://localhost:8000'
       FLASK_ENV = os.environ.get('FLASK_ENV') or 'development'
   ```

2. **Cập nhật API calls:**
   ```python
   # frontend/utils/api.py
   import requests
   from config import Config

   def api_call(endpoint, method='GET', data=None, token=None):
       url = f"{Config.BACKEND_URL}/api{endpoint}"
       headers = {}
       if token:
           headers['Authorization'] = f'Bearer {token}'
       
       if method == 'GET':
           response = requests.get(url, headers=headers)
       elif method == 'POST':
           response = requests.post(url, json=data, headers=headers)
       elif method == 'PUT':
           response = requests.put(url, json=data, headers=headers)
       elif method == 'DELETE':
           response = requests.delete(url, headers=headers)
       
       return response.json() if response.status_code == 200 else None
   ```

### **5.2 Test Connection**

1. **Test Backend API:**
   ```bash
   curl https://phanmemketoan-backend.onrender.com/health
   ```

2. **Test Frontend:**
   - Truy cập: `https://phanmemketoan.vercel.app`
   - Login với: `admin/admin123`

## 6. Testing & Monitoring

### **6.1 Health Checks**

1. **Backend Health Check:**
   ```bash
   curl https://phanmemketoan-backend.onrender.com/health
   # Expected: {"status": "healthy"}
   ```

2. **Database Connection:**
   ```bash
   curl https://phanmemketoan-backend.onrender.com/api/products/
   # Expected: List of products or empty array
   ```

### **6.2 Monitoring**

1. **Render Dashboard:**
   - Logs: Real-time application logs
   - Metrics: CPU, Memory usage
   - Events: Deploy history

2. **Vercel Dashboard:**
   - Analytics: Page views, performance
   - Functions: Serverless function logs
   - Deployments: Build history

### **6.3 Performance Optimization**

1. **Backend Optimization:**
   ```python
   # Add caching
   from fastapi_cache import FastAPICache
   from fastapi_cache.backends.redis import RedisBackend
   
   @app.on_event("startup")
   async def startup():
       redis = aioredis.from_url("redis://localhost", encoding="utf8")
       FastAPICache.init(RedisBackend(redis), prefix="fastapi-cache")
   ```

2. **Frontend Optimization:**
   ```python
   # Add static file caching
   @app.after_request
   def add_header(response):
       response.headers['Cache-Control'] = 'public, max-age=31536000'
       return response
   ```

## 7. Troubleshooting

### **7.1 Common Issues**

#### **Backend không start:**
```bash
# Check logs in Render dashboard
# Common issues:
# - Missing environment variables
# - Database connection failed
# - Port configuration wrong
```

#### **Frontend không load:**
```bash
# Check Vercel build logs
# Common issues:
# - Build command failed
# - Missing dependencies
# - Environment variables not set
```

#### **CORS errors:**
```python
# Update CORS_ORIGINS in backend
CORS_ORIGINS = [
    "https://phanmemketoan.vercel.app",
    "https://your-custom-domain.com",
    "http://localhost:3000"
]
```

#### **Database connection failed:**
```python
# Check DATABASE_URL format
# Render uses postgresql:// not postgres://
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)
```

### **7.2 Debug Commands**

#### **Check Backend Status:**
```bash
# Health check
curl https://phanmemketoan-backend.onrender.com/health

# API test
curl https://phanmemketoan-backend.onrender.com/api/products/
```

#### **Check Frontend Status:**
```bash
# Page load test
curl -I https://phanmemketoan.vercel.app

# Check redirects
curl -L https://phanmemketoan.vercel.app
```

### **7.3 Logs & Debugging**

1. **Render Logs:**
   - Dashboard → Service → Logs
   - Real-time logs
   - Build logs

2. **Vercel Logs:**
   - Dashboard → Project → Functions
   - Function logs
   - Build logs

3. **Database Logs:**
   - Render → Database → Logs
   - Connection logs
   - Query logs

## 🎯 **Kết quả cuối cùng**

### **URLs:**
- **Frontend**: `https://phanmemketoan.vercel.app`
- **Backend API**: `https://phanmemketoan-backend.onrender.com`
- **API Docs**: `https://phanmemketoan-backend.onrender.com/docs`

### **Default Login:**
- **Username**: `admin`
- **Password**: `admin123`

### **Features:**
- ✅ **Hoàn toàn miễn phí**
- ✅ **Auto-deploy từ Git**
- ✅ **SSL tự động**
- ✅ **Global CDN**
- ✅ **Database PostgreSQL**
- ✅ **Monitoring tích hợp**
- ✅ **Scale tự động**

## 📊 **Limitations của Free Tier**

### **Render Free Tier:**
- 750 hours/month (31 days)
- Sleep after 15 minutes inactive
- 512MB RAM
- Shared CPU

### **Vercel Free Tier:**
- 100GB bandwidth/month
- 100GB storage
- 100GB function execution time
- 10,000 serverless function invocations

### **Giải pháp:**
- **Upgrade plan** khi cần
- **Optimize code** để giảm resource usage
- **Use caching** để giảm database calls

---

**🎉 Chúc mừng! Dự án PhanMemKeToan của bạn đã được triển khai thành công lên cloud miễn phí!**

**Need help?** Check logs hoặc tạo issue trên GitHub repository.
