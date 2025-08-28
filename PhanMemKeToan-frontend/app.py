
from flask import Flask, render_template, request, redirect, url_for, flash, session, jsonify
import requests


from datetime import datetime
from config import Config
from functools import wraps
import json

app = Flask(__name__)
app.config.from_object(Config)

# Tắt auto-load .env file
app.config['LOAD_DOTENV'] = False

# Frontend utility functions
def format_currency(amount):
    """Format số tiền theo định dạng Việt Nam"""
    if amount is None:
        return "0 VNĐ"
    try:
        return f"{int(amount):,} VNĐ"
    except (ValueError, TypeError):
        return "0 VNĐ"

def format_date(date_str):
    """Format ngày tháng theo định dạng Việt Nam"""
    if not date_str:
        return ""
    try:
        if isinstance(date_str, str):
            # Parse date string
            date_obj = datetime.strptime(date_str, '%Y-%m-%d')
        else:
            date_obj = date_str
        
        return date_obj.strftime('%d/%m/%Y')
    except (ValueError, TypeError):
        return str(date_str)

# Inject BACKEND_URL to all templates
@app.context_processor
def inject_backend_url():
    return { 'BACKEND_URL': Config.BACKEND_URL }

# Decorator để kiểm tra user đã đăng nhập
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# API helper functions
def call_backend_api(endpoint, method='GET', data=None, headers=None):
    """Gọi API backend với timeout ngắn và retry logic"""
    url = f"{Config.BACKEND_URL}{endpoint}"
    
    if headers is None:
        headers = {'Content-Type': 'application/json'}
    
    # Timeout ngắn để tránh chờ lâu
    timeout = 3  # 3 giây
    
    try:
        if method.upper() == 'GET':
            response = requests.get(url, headers=headers, timeout=timeout)
        elif method.upper() == 'POST':
            response = requests.post(url, json=data, headers=headers, timeout=timeout)
        elif method.upper() == 'PUT':
            response = requests.put(url, json=data, headers=headers, timeout=timeout)
        elif method.upper() == 'DELETE':
            response = requests.delete(url, headers=headers, timeout=timeout)
        else:
            return None, "Method không được hỗ trợ"
        
        if response.status_code == 200:
            return response.json(), None
        else:
            # Xử lý error response từ backend
            try:
                error_data = response.json()
                if 'detail' in error_data:
                    return None, error_data['detail']
                elif 'error' in error_data:
                    return None, error_data['error']
                else:
                    return None, f"API Error: {response.status_code} - {response.text}"
            except:
                return None, f"API Error: {response.status_code} - {response.text}"
            
    except requests.exceptions.Timeout:
        return None, "Timeout: Backend không phản hồi trong 3 giây"
    except requests.exceptions.ConnectionError:
        return None, "Connection Error: Không thể kết nối đến backend"
    except requests.exceptions.RequestException as e:
        return None, f"Request Error: {str(e)}"

# Routes
@app.route('/')
@login_required
def general_diary():
    # Lấy dữ liệu cần thiết cho general diary
    current_date = datetime.now().strftime('%Y-%m-%d')
    
    # Lấy danh sách tài khoản khách hàng (với timeout ngắn)
    try:
        accounts_data, accounts_error = call_backend_api('/api/accounts/', 'GET')
        if accounts_error:
            print(f"General Diary API Error: {accounts_error}")
            accounts_data = []
    except Exception as e:
        print(f"General Diary Exception: {e}")
        accounts_data = []
    
    return render_template('general_diary.html', 
                         current_date=current_date,
                         accounts=accounts_data or [])

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        # Gọi API backend để xác thực
        data = {'username': username, 'password': password}
        result, error = call_backend_api('/api/auth/login', 'POST', data)
        
        if error:
            # Kiểm tra nếu lỗi liên quan đến tài khoản bị vô hiệu hóa
            if 'Tài khoản đã bị tắt' in error or 'vô hiệu hóa' in error.lower():
                return jsonify({'success': False, 'error': 'Tài khoản đang bị vô hiệu hóa!'}), 401
            else:
                return jsonify({'success': False, 'error': f'Lỗi đăng nhập: {error}'}), 400
        
        if result and result.get('success'):
            # Lưu thông tin user vào session
            session['user_id'] = result.get('user_id')
            session['username'] = result.get('username')
            flash('Đăng nhập thành công!', 'success')
            return redirect(url_for('general_diary'))
        else:
            # Trả về JSON response cho lỗi đăng nhập
            return jsonify({'success': False, 'error': 'Tên đăng nhập hoặc mật khẩu không đúng!'}), 401

    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    flash('Đã đăng xuất thành công!', 'success')
    return redirect(url_for('login'))

@app.route('/check-session')
def check_session():
    """API endpoint để kiểm tra session (cho JavaScript)"""
    if 'user_id' in session and 'username' in session:
        return jsonify({
            'logged_in': True,
            'user_id': session['user_id'],
            'username': session['username']
        })
    else:
        return jsonify({'logged_in': False})

# Account Management Routes
@app.route('/account-management')
@login_required
def account_management():
    return render_template('account_management.html')

@app.route('/products')
@login_required
def products():
    # Lấy danh sách sản phẩm từ backend
    response_data, error = call_backend_api('/api/products/', 'GET')
    if error:
        flash(f'Lỗi khi tải dữ liệu sản phẩm: {error}', 'error')
        products_data = []
    else:
        # Xử lý format dữ liệu từ backend: {"success":true,"products":[...]}
        if isinstance(response_data, dict) and 'products' in response_data:
            products_data = response_data['products']
        else:
            products_data = response_data or []
    
    # Lấy danh sách nhóm sản phẩm
    groups_response, groups_error = call_backend_api('/api/product-groups/', 'GET')
    if groups_error:
        groups_data = []
    else:
        # Xử lý format dữ liệu từ backend: {"success":true,"groups":[...]}
        if isinstance(groups_response, dict) and 'groups' in groups_response:
            groups_data = groups_response['groups']
        else:
            groups_data = groups_response or []
        
        # Chỉ lấy tên nhóm sản phẩm để hiển thị trong dropdown
        if groups_data and isinstance(groups_data, list):
            groups_data = [group.get('ten_nhom', str(group)) if isinstance(group, dict) else str(group) for group in groups_data]
    
    # Tính tổng số sản phẩm và tổng số lượng - xử lý an toàn
    total_products = 0
    total_quantity = 0
    if products_data and isinstance(products_data, list):
        total_products = len(products_data)
        for p in products_data:
            if isinstance(p, dict) and 'so_luong' in p:
                try:
                    total_quantity += int(p['so_luong'])
                except (ValueError, TypeError):
                    continue
    
    return render_template('products.html', 
                         products=products_data or [], 
                         product_groups=groups_data or [],
                         total_products=total_products,
                         total_quantity=total_quantity)

@app.route('/orders')
@login_required
def orders():
    # Lấy danh sách đơn hàng từ backend
    response_data, error = call_backend_api('/api/orders/', 'GET')
    if error:
        flash(f'Lỗi khi tải dữ liệu đơn hàng: {error}', 'error')
        orders_data = []
    else:
        # Xử lý format dữ liệu từ backend: {"success":true,"orders":[...]}
        if isinstance(response_data, dict) and 'orders' in response_data:
            orders_data = response_data['orders']
        else:
            orders_data = response_data or []
    
    # Lấy danh sách tài khoản khách hàng
    accounts_response, accounts_error = call_backend_api('/api/accounts/', 'GET')
    if accounts_error:
        accounts_data = []
    else:
        # Xử lý format dữ liệu từ backend: {"success":true,"accounts":[...]}
        if isinstance(accounts_response, dict) and 'accounts' in accounts_response:
            accounts_data = accounts_response['accounts']
        else:
            accounts_data = accounts_response or []
    
    return render_template('orders.html', orders=orders_data or [], accounts=accounts_data or [])

@app.route('/invoices')
@login_required
def invoices():
    # Lấy danh sách hóa đơn từ backend
    invoices_data, error = call_backend_api('/api/invoices/', 'GET')
    if error:
        flash(f'Lỗi khi tải dữ liệu hóa đơn: {error}', 'error')
        invoices_data = []
    
    # Lấy danh sách tài khoản khách hàng
    accounts_data, accounts_error = call_backend_api('/api/accounts/', 'GET')
    if accounts_error:
        accounts_data = []
    
    return render_template('invoices.html', invoices=invoices_data or [], accounts=accounts_data or [])

@app.route('/warehouse')
@login_required
def warehouse():
    # Lấy dữ liệu kho hàng từ backend
    warehouses_data, error = call_backend_api('/api/warehouses/', 'GET')
    if error:
        flash(f'Lỗi khi tải dữ liệu kho hàng: {error}', 'error')
        warehouses_data = []
    
    # Lấy danh sách nhóm sản phẩm
    groups_response, groups_error = call_backend_api('/api/product-groups/', 'GET')
    if groups_error:
        groups_data = []
    else:
        # Xử lý format dữ liệu từ backend: {"success":true,"groups":[...]}
        if isinstance(groups_response, dict) and 'groups' in groups_response:
            groups_data = groups_response['groups']
        else:
            groups_data = groups_response or []
    
    # Debug: In ra dữ liệu để kiểm tra
    print(f"DEBUG: warehouses_data type: {type(warehouses_data)}")
    print(f"DEBUG: warehouses_data content: {warehouses_data}")
    print(f"DEBUG: groups_response type: {type(groups_response)}")
    print(f"DEBUG: groups_response content: {groups_response}")
    print(f"DEBUG: groups_data type: {type(groups_data)}")
    print(f"DEBUG: groups_data content: {groups_data}")
    
    return render_template('warehouse.html', 
                         warehouses=warehouses_data or [],
                         product_groups=groups_data or [])

@app.route('/reports')
@login_required
def reports():
    # Lấy dữ liệu báo cáo từ backend
    reports_data, error = call_backend_api('/api/reports/', 'GET')
    if error:
        flash(f'Lỗi khi tải dữ liệu báo cáo: {error}', 'error')
        reports_data = []
    
    # Lấy dữ liệu doanh thu theo ngày (mặc định 5 ngày gần đây để có dữ liệu)
    from datetime import datetime, timedelta
    end_date = datetime.now()
    start_date = end_date - timedelta(days=5)
    
    revenue_data, revenue_error = call_backend_api(f'/api/reports/revenue-by-date?from_date={start_date.strftime("%Y-%m-%d")}&to_date={end_date.strftime("%Y-%m-%d")}', 'GET')
    if revenue_error:
        flash(f'Lỗi khi tải dữ liệu doanh thu: {revenue_error}', 'error')
        revenue_data = {}
    
    # Debug: In ra dữ liệu để kiểm tra
    print(f"DEBUG: reports_data type: {type(reports_data)}")
    print(f"DEBUG: revenue_data type: {type(revenue_data)}")
    print(f"DEBUG: revenue_data content: {revenue_data}")
    
    return render_template('reports.html', 
                         reports=reports_data or [],
                         revenue_data=revenue_data or {})
    
@app.route('/prices')
@login_required
def prices():
    # Lấy danh sách bảng giá từ backend
    prices_data, error = call_backend_api('/api/prices/', 'GET')
    if error:
        flash(f'Lỗi khi tải dữ liệu bảng giá: {error}', 'error')
        prices_list = []
    else:
        # Chuẩn hóa nhiều định dạng: {"success":true,"prices":[...]}, hoặc mảng trực tiếp
        if isinstance(prices_data, dict) and isinstance(prices_data.get('prices'), list):
            prices_list = prices_data.get('prices')
        else:
            prices_list = prices_data or []
    
    # Lấy danh sách sản phẩm (để map tên nếu cần)
    products_data, products_error = call_backend_api('/api/products/', 'GET')
    if products_error:
        products_data = []
    
    return render_template('prices.html', prices=prices_list or [], products=products_data or [])

@app.route('/product-groups')
@login_required
def product_groups():
    # Lấy danh sách nhóm sản phẩm từ backend
    response_data, error = call_backend_api('/api/product-groups/', 'GET')
    if error:
        flash(f'Lỗi khi tải dữ liệu nhóm sản phẩm: {error}', 'error')
        groups_data = []
    else:
        # Xử lý format dữ liệu từ backend: {"success":true,"groups":[...]}
        if isinstance(response_data, dict) and 'groups' in response_data:
            groups_data = response_data['groups']
        else:
            groups_data = response_data or []
    
    # Debug: In ra dữ liệu để kiểm tra
    print(f"DEBUG: response_data type: {type(response_data)}")
    print(f"DEBUG: response_data content: {response_data}")
    print(f"DEBUG: groups_data type: {type(groups_data)}")
    print(f"DEBUG: groups_data content: {groups_data}")
    
    # Tính tổng số lượng - xử lý an toàn
    total_quantity = 0
    if groups_data and isinstance(groups_data, list):
        # Tính tổng số lượng từ field so_luong của mỗi nhóm
        for group in groups_data:
            if isinstance(group, dict) and 'so_luong' in group:
                try:
                    total_quantity += int(group['so_luong'])
                except (ValueError, TypeError):
                    continue
        print(f"DEBUG: Total groups: {len(groups_data)}, Total quantity: {total_quantity}")
    
    return render_template('product_groups.html', 
                         groups=groups_data or [], 
                         total_quantity=total_quantity)


if __name__ == '__main__':
    print(f"🚀 Starting PhanMemKeToan Frontend on port {Config.FRONTEND_PORT}")
    print(f"🌐 Frontend will be available at: http://localhost:{Config.FRONTEND_PORT}")
    print(f"🔗 Backend API should be running at: {Config.BACKEND_URL}")
    print(f"📱 Make sure backend is running before accessing frontend")
    print(f"💡 Use Ctrl+C to stop the server")
    
    app.run(
        host='0.0.0.0',
        port=Config.FRONTEND_PORT,
        debug=Config.DEBUG
    )


