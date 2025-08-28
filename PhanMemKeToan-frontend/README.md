# PhanMemKeToan Frontend

Frontend web application cho phần mềm kế toán chuyên nghiệp, được xây dựng với Flask và Jinja2 templates.

## 🚀 Tính năng

- **Responsive Design** - Tương thích với mọi thiết bị
- **Server-side Rendering** với Jinja2 templates
- **Real-time Validation** cho forms
- **Interactive UI** với JavaScript
- **Session Management** an toàn
- **Role-based Access Control** (RBAC)
- **Modern UI/UX** với Bootstrap và custom CSS

## 📋 Yêu cầu hệ thống

- Python 3.8+
- Backend API đang chạy (PhanMemKeToan Backend)
- pip (Python package manager)

## 🛠️ Cài đặt

### 1. Clone repository
```bash
git clone <repository-url>
cd PhanMemKeToan-frontend
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

### 4. Cấu hình
1. Copy `env.example` thành `.env`
2. Cập nhật `BACKEND_URL` trong `.env` để trỏ đến backend API

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
python app.py
```

Ứng dụng sẽ chạy tại: http://localhost:5000

## 📱 Giao diện

### Trang chính:
- **Đăng nhập** - Authentication system
- **Dashboard** - Tổng quan hệ thống
- **Quản lý sản phẩm** - CRUD operations cho sản phẩm
- **Quản lý đơn hàng** - Xử lý đơn hàng
- **Quản lý hóa đơn** - Tạo và quản lý hóa đơn
- **Quản lý kho hàng** - Kiểm soát tồn kho
- **Báo cáo** - Báo cáo tài chính
- **Quản lý tài khoản** - User management

## 🔧 Cấu hình

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SECRET_KEY` | Flask secret key | `change-this-in-production` |
| `FLASK_DEBUG` | Debug mode | `True` |
| `FRONTEND_PORT` | Server port | `5000` |
| `HOST` | Server host | `127.0.0.1` |
| `BACKEND_URL` | Backend API URL | `http://localhost:5001` |
| `API_TIMEOUT` | API request timeout | `10` |
| `LOG_LEVEL` | Logging level | `INFO` |

## 🎨 UI Components

### Templates:
- `base.html` - Layout chính
- `login.html` - Trang đăng nhập
- `products.html` - Quản lý sản phẩm
- `orders.html` - Quản lý đơn hàng
- `invoices.html` - Quản lý hóa đơn
- `warehouse.html` - Quản lý kho hàng
- `reports.html` - Báo cáo
- `account_management.html` - Quản lý tài khoản

### Static Files:
- `css/style.css` - Custom styles
- `js/` - JavaScript modules
- `images/` - Icons và images

## 🔒 Security

- Session-based authentication
- CSRF protection
- Input sanitization
- XSS prevention
- Secure headers với Flask-Talisman

## 📱 Responsive Design

- Mobile-first approach
- Bootstrap 5 framework
- Custom responsive components
- Touch-friendly interface

## 🧪 Testing

```bash
# Run tests
python -m pytest

# Run with coverage
python -m pytest --cov=app

# Run specific test
python -m pytest tests/test_auth.py
```

## 📦 Deployment

### Production
1. Set `FLASK_DEBUG=False`
2. Update `SECRET_KEY`
3. Configure production backend URL
4. Set up reverse proxy (nginx)
5. Use process manager (systemd, supervisor)

### Docker
```bash
docker build -t phanmemketoan-frontend .
docker run -p 5000:5000 phanmemketoan-frontend
```

## 🔄 API Integration

Frontend tích hợp với backend API thông qua:
- RESTful API calls
- JSON data exchange
- Error handling
- Loading states
- Real-time updates

## 📝 Logging

Logs được lưu với các level:
- `INFO`: Thông tin chung
- `WARNING`: Cảnh báo
- `ERROR`: Lỗi
- `DEBUG`: Thông tin debug (chỉ trong development)

## 🎯 Performance

- Static file caching
- Minified CSS/JS
- Image optimization
- Lazy loading
- Database query optimization

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
- **Documentation**: Xem inline comments
- **Email**: Liên hệ qua email support

---

**Built with ❤️ using Flask, Jinja2, and Bootstrap**
