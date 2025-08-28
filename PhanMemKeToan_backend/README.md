# PhanMemKeToan Backend API

Backend API cho phần mềm kế toán chuyên nghiệp, được xây dựng với FastAPI và PostgreSQL.

## 🚀 Tính năng

- **RESTful API** với FastAPI
- **Database ORM** với SQLAlchemy
- **Authentication** với JWT
- **Data Validation** với Pydantic
- **Auto-generated Documentation** với Swagger UI
- **CORS Support** cho frontend integration
- **Error Handling** chuyên nghiệp
- **Logging** chi tiết

## 📋 Yêu cầu hệ thống

- Python 3.8+
- PostgreSQL 12+
- pip (Python package manager)

## 🛠️ Cài đặt

### 1. Clone repository
```bash
git clone <repository-url>
cd PhanMemKeToan_backend
```

### 2. Tạo virtual environment
```bash
python -m venv .venv

# Windows
.venv\Scripts\activate

# Linux/Mac
source .venv/bin/activate
```

### 3. Cài đặt dependencies
```bash
pip install -r requirements.txt
```

### 4. Cấu hình database
1. Tạo database PostgreSQL
2. Copy `env.example` thành `.env`
3. Cập nhật thông tin database trong `.env`

### 5. Khởi tạo database
```bash
python setup_database.py
```

## 🚀 Chạy ứng dụng

### Sử dụng script tự động
```bash
# Windows
start.bat

# Linux/Mac
./start.sh
```

### Chạy thủ công
```bash
python main.py
```

Ứng dụng sẽ chạy tại: http://localhost:5001

## 📚 API Documentation

- **Swagger UI**: http://localhost:5001/docs
- **ReDoc**: http://localhost:5001/redoc
- **OpenAPI JSON**: http://localhost:5001/openapi.json

## 🗄️ Database Schema

### Bảng chính:
- `user` - Quản lý người dùng
- `accounts` - Quản lý tài khoản khách hàng
- `products` - Quản lý sản phẩm
- `prices` - Quản lý bảng giá
- `orders` - Quản lý đơn hàng
- `invoices` - Quản lý hóa đơn
- `warehouses` - Quản lý kho hàng
- `reports` - Báo cáo
- `debts` - Quản lý công nợ
- `general_diary` - Nhật ký chung

## 🔧 Cấu hình

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://postgres:password@localhost:5432/ketoan` |
| `JWT_SECRET_KEY` | Secret key for JWT tokens | `change-this-in-production` |
| `CORS_ORIGINS` | Allowed CORS origins | `http://127.0.0.1:5000,http://localhost:5000` |
| `FLASK_ENV` | Environment mode | `development` |
| `BACKEND_PORT` | Server port | `5001` |
| `LOG_LEVEL` | Logging level | `INFO` |

## 🧪 Testing

```bash
# Run tests
pytest

# Run with coverage
pytest --cov=app

# Run specific test
pytest tests/test_auth.py
```

## 📦 Deployment

### Production
1. Set `FLASK_ENV=production`
2. Update `SECRET_KEY` và `JWT_SECRET_KEY`
3. Configure production database
4. Set up reverse proxy (nginx)
5. Use process manager (systemd, supervisor)

### Docker
```bash
docker build -t phanmemketoan-backend .
docker run -p 5001:5001 phanmemketoan-backend
```

## 🔒 Security

- JWT authentication
- Password hashing với Werkzeug
- CORS protection
- Input validation với Pydantic
- SQL injection prevention với SQLAlchemy

## 📝 Logging

Logs được lưu với các level:
- `INFO`: Thông tin chung
- `WARNING`: Cảnh báo
- `ERROR`: Lỗi
- `DEBUG`: Thông tin debug (chỉ trong development)

## 🤝 Contributing

1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request

## 📄 License

MIT License - xem file LICENSE để biết thêm chi tiết.

## 🆘 Support

- **Issues**: Tạo issue trên GitHub
- **Documentation**: Xem API docs tại `/docs`
- **Email**: Liên hệ qua email support

---

**Built with ❤️ using FastAPI, SQLAlchemy, and PostgreSQL**
