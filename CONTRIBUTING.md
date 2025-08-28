# Contributing to PhanMemKeToan

Cảm ơn bạn đã quan tâm đến việc đóng góp cho dự án PhanMemKeToan! 

## 🚀 Bắt đầu

### Prerequisites
- Python 3.8+
- PostgreSQL 12+
- Git
- pip

### Setup Development Environment

1. **Fork repository**
   ```bash
   git clone https://github.com/your-username/PhanMemKeToan.git
   cd PhanMemKeToan
   ```

2. **Setup Backend**
   ```bash
   cd PhanMemKeToan_backend
   python -m venv .venv
   source .venv/bin/activate  # Linux/Mac
   # hoặc .venv\Scripts\activate  # Windows
   pip install -r requirements.txt
   ```

3. **Setup Frontend**
   ```bash
   cd ../PhanMemKeToan-frontend
   python -m venv .venv
   source .venv/bin/activate  # Linux/Mac
   # hoặc .venv\Scripts\activate  # Windows
   pip install -r requirements.txt
   ```

4. **Configure Environment**
   - Copy `env.example` thành `.env` trong cả backend và frontend
   - Cập nhật thông tin database và các cấu hình khác

5. **Setup Database**
   ```bash
   cd ../PhanMemKeToan_backend
   python setup_database.py
   ```

## 📝 Quy tắc đóng góp

### Code Style

#### Python (Backend)
- Tuân thủ PEP 8
- Sử dụng type hints
- Viết docstrings cho functions và classes
- Đặt tên biến và function có ý nghĩa

```python
def calculate_total_price(items: List[OrderItem]) -> float:
    """
    Tính tổng giá trị đơn hàng.
    
    Args:
        items: Danh sách các item trong đơn hàng
        
    Returns:
        Tổng giá trị đơn hàng
    """
    return sum(item.price * item.quantity for item in items)
```

#### JavaScript (Frontend)
- Sử dụng ES6+ syntax
- Tuân thủ ESLint rules
- Viết comments cho logic phức tạp

```javascript
/**
 * Validate phone number format
 * @param {string} phone - Phone number to validate
 * @returns {boolean} - True if valid
 */
function validatePhoneNumber(phone) {
    const phoneRegex = /^0\d{9}$/;
    return phoneRegex.test(phone);
}
```

#### HTML/CSS
- Sử dụng semantic HTML
- Tuân thủ BEM methodology cho CSS
- Responsive design

### Commit Messages

Sử dụng conventional commits:

```
type(scope): description

feat(auth): add JWT token refresh functionality
fix(orders): resolve duplicate order creation issue
docs(api): update authentication documentation
style(ui): improve button styling consistency
refactor(database): optimize product queries
test(auth): add unit tests for login endpoint
chore(deps): update FastAPI to v0.104.1
```

**Types:**
- `feat`: Tính năng mới
- `fix`: Sửa lỗi
- `docs`: Cập nhật documentation
- `style`: Thay đổi format code
- `refactor`: Refactor code
- `test`: Thêm/sửa tests
- `chore`: Cập nhật build process, dependencies

### Branch Naming

```
feature/authentication-system
bugfix/order-validation-error
hotfix/security-vulnerability
docs/api-documentation-update
```

## 🧪 Testing

### Backend Tests
```bash
cd PhanMemKeToan_backend
pytest
pytest --cov=app
pytest tests/test_auth.py -v
```

### Frontend Tests
```bash
cd PhanMemKeToan-frontend
python -m pytest
```

### Test Coverage
- Backend: Tối thiểu 80% coverage
- Frontend: Tối thiểu 70% coverage

## 🔍 Code Review Process

1. **Create Pull Request**
   - Fork repository
   - Tạo feature branch
   - Commit changes với conventional commits
   - Push to your fork
   - Tạo Pull Request

2. **Pull Request Template**
   ```markdown
   ## Description
   Mô tả ngắn gọn về thay đổi

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update
   - [ ] Code refactoring
   - [ ] Performance improvement

   ## Testing
   - [ ] Unit tests added/updated
   - [ ] Manual testing completed
   - [ ] All tests passing

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Documentation updated
   - [ ] No breaking changes
   ```

3. **Review Process**
   - Code review bởi maintainer
   - Automated tests phải pass
   - Code coverage không giảm
   - Documentation được cập nhật

## 🐛 Bug Reports

Khi báo cáo bug, vui lòng cung cấp:

1. **Environment**
   - OS version
   - Python version
   - Database version
   - Browser (nếu liên quan frontend)

2. **Steps to Reproduce**
   - Các bước chi tiết để tái hiện lỗi
   - Screenshots/videos nếu cần

3. **Expected vs Actual Behavior**
   - Mô tả hành vi mong đợi
   - Mô tả hành vi thực tế

4. **Additional Information**
   - Error logs
   - Console output
   - Database queries

## 💡 Feature Requests

Khi đề xuất tính năng mới:

1. **Problem Statement**
   - Mô tả vấn đề cần giải quyết
   - Use cases cụ thể

2. **Proposed Solution**
   - Ý tưởng giải pháp
   - Technical approach

3. **Impact Assessment**
   - Lợi ích mang lại
   - Potential risks
   - Performance impact

## 📚 Documentation

### Code Documentation
- Viết docstrings cho tất cả functions và classes
- Sử dụng type hints
- Comment cho logic phức tạp

### API Documentation
- Cập nhật OpenAPI specs
- Viết examples cho endpoints
- Mô tả error responses

### User Documentation
- Cập nhật README files
- Viết user guides
- Tạo screenshots/videos

## 🔒 Security

### Security Guidelines
- Không commit sensitive data (passwords, API keys)
- Sử dụng environment variables
- Validate tất cả user inputs
- Implement proper authentication/authorization
- Follow OWASP guidelines

### Security Reporting
Nếu phát hiện lỗi bảo mật, vui lòng:
- Không công khai lỗi
- Báo cáo qua email bảo mật
- Cung cấp PoC nếu có thể

## 🎯 Performance

### Performance Guidelines
- Optimize database queries
- Implement caching khi cần thiết
- Minimize API response time
- Optimize frontend bundle size
- Use lazy loading

### Performance Testing
- Monitor API response times
- Test với large datasets
- Profile memory usage
- Load testing cho critical endpoints

## 📞 Support

### Getting Help
- Tạo issue trên GitHub
- Tham gia discussions
- Liên hệ maintainer qua email

### Community Guidelines
- Tôn trọng người khác
- Constructive feedback
- Help others
- Follow code of conduct

---

**Thank you for contributing to PhanMemKeToan! 🚀**
