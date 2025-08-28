# Phần Mềm Kế Toán - Professional Architecture

## 🏗️ Project Structure

```
ketoan/
├── frontend/                 # Frontend Application (Flask)
│   ├── app.py               # Main Flask application
│   ├── config.py            # Configuration settings
│   ├── requirements.txt     # Python dependencies
│   ├── static/              # Static files (CSS, JS, images)
│   ├── templates/           # HTML templates
│   ├── start.bat            # Windows startup script
│   ├── start.sh             # Linux/Mac startup script
│   └── README.md            # Frontend documentation
├── backend/                  # Backend API (FastAPI)
│   ├── main.py              # FastAPI application entry point
│   ├── requirements.txt     # Python dependencies
│   ├── app/                 # Application modules
│   │   ├── __init__.py
│   │   ├── main.py          # FastAPI app configuration
│   │   ├── config.py        # Backend configuration
│   │   ├── database.py      # Database connection
│   │   ├── models.py        # SQLAlchemy models
│   │   ├── schemas.py       # Pydantic schemas
│   │   ├── crud.py          # Database operations
│   │   ├── api/             # API routes
│   │   │   ├── __init__.py
│   │   │   ├── auth.py      # Authentication endpoints
│   │   │   ├── users.py     # User management
│   │   │   ├── products.py  # Product management
│   │   │   ├── orders.py    # Order management
│   │   │   ├── invoices.py  # Invoice management
│   │   │   └── reports.py   # Reporting endpoints
│   │   └── utils.py         # Utility functions
│   ├── start.bat            # Windows startup script
│   ├── start.sh             # Linux/Mac startup script
│   └── README.md            # Backend documentation
├── shared/                   # Shared resources
│   ├── database/            # Database scripts and migrations
│   └── docs/                # Project documentation
├── docker/                   # Docker configuration
│   ├── docker-compose.yml   # Multi-service setup
│   ├── frontend.Dockerfile  # Frontend container
│   └── backend.Dockerfile   # Backend container
├── scripts/                  # Development and deployment scripts
├── .env.example             # Environment variables template
├── .gitignore               # Git ignore rules
└── README.md                # This file
```

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- PostgreSQL 12+
- Node.js 14+ (for future frontend development)

### 1. Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

### 2. Frontend Setup
```bash
cd frontend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

### 3. Using Scripts
- **Windows**: Double-click `start.bat` in each directory
- **Linux/Mac**: Run `./start.sh` in each directory

## 🔧 Development Workflow

### Backend Development
- **API First**: Design APIs before implementing frontend
- **Database Migrations**: Use Alembic for schema changes
- **Testing**: Unit tests for each API endpoint
- **Documentation**: Auto-generated API docs with FastAPI

### Frontend Development
- **Template Based**: Jinja2 templates for server-side rendering
- **Static Assets**: Organized CSS/JS with build process
- **Responsive Design**: Mobile-first approach
- **Accessibility**: WCAG 2.1 compliance

## 📊 Database Management

### Setup Database
```bash
cd backend
python setup_database.py
```

### Database Schema
- **Users**: Authentication and user management
- **Products**: Product catalog and inventory
- **Orders**: Order processing and management
- **Invoices**: Billing and invoicing
- **Reports**: Financial reporting and analytics

## 🐳 Docker Deployment

### Development
```bash
docker-compose up --build
```

### Production
```bash
docker-compose -f docker-compose.prod.yml up --build
```

## 🔒 Security Features

- **JWT Authentication**: Secure token-based auth
- **CORS Protection**: Cross-origin request handling
- **Input Validation**: Pydantic schema validation
- **SQL Injection Prevention**: SQLAlchemy ORM
- **XSS Protection**: Template escaping

## 📈 Performance Optimization

- **Database Indexing**: Optimized queries
- **Caching**: Redis integration (planned)
- **CDN**: Static asset delivery (planned)
- **Load Balancing**: Nginx configuration (planned)

## 🧪 Testing Strategy

### Backend Testing
- **Unit Tests**: pytest for individual functions
- **Integration Tests**: API endpoint testing
- **Database Tests**: Test database operations
- **Performance Tests**: Load testing with locust

### Frontend Testing
- **Unit Tests**: JavaScript function testing
- **Integration Tests**: Template rendering tests
- **E2E Tests**: Selenium for user workflows
- **Accessibility Tests**: Automated a11y checks

## 📚 API Documentation

- **Interactive Docs**: Swagger UI at `/docs`
- **ReDoc**: Alternative docs at `/redoc`
- **OpenAPI Spec**: Machine-readable API definition
- **Postman Collection**: Import-ready API collection

## 🔄 CI/CD Pipeline

### GitHub Actions
- **Code Quality**: Linting and formatting
- **Security Scanning**: Dependency vulnerability checks
- **Automated Testing**: Run tests on every commit
- **Deployment**: Auto-deploy to staging/production

## 🌐 Environment Configuration

### Frontend (.env)
```env
FLASK_ENV=development
BACKEND_URL=http://localhost:8000
SECRET_KEY=your-secret-key
```

### Backend (.env)
```env
DATABASE_URL=postgresql://user:pass@localhost/ketoan
JWT_SECRET_KEY=your-jwt-secret
CORS_ORIGINS=http://localhost:5000
```

## 📝 Contributing

1. **Fork** the repository
2. **Create** a feature branch
3. **Commit** your changes
4. **Push** to the branch
5. **Create** a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Support

- **Issues**: GitHub Issues for bug reports
- **Discussions**: GitHub Discussions for questions
- **Wiki**: Project documentation and guides
- **Email**: Support email for urgent matters

---

**Built with ❤️ using FastAPI, Flask, and PostgreSQL**
