#!/usr/bin/env python3
"""
Database Setup Script for Render Deployment
This script initializes the database schema and creates initial data.
"""

import os
import sys
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Add the current directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import Base
from app.models import *  # Import all models
from werkzeug.security import generate_password_hash

def setup_database():
    """Setup database schema and initial data"""
    
    # Get database URL from environment
    DATABASE_URL = os.environ.get("DATABASE_URL")
    
    if not DATABASE_URL:
        print("❌ DATABASE_URL environment variable not found!")
        return False
    
    # Fix for Render PostgreSQL URL format
    if DATABASE_URL.startswith("postgres://"):
        DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)
    
    try:
        # Create engine
        engine = create_engine(DATABASE_URL)
        
        # Create all tables
        print("📋 Creating database tables...")
        Base.metadata.create_all(bind=engine)
        print("✅ Database tables created successfully!")
        
        # Create session
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        db = SessionLocal()
        
        # Check if admin user exists
        admin = db.query(User).filter(User.username == 'admin').first()
        
        if not admin:
            print("👤 Creating admin user...")
            admin = User(
                username='admin',
                password=generate_password_hash('admin123'),
                name='Administrator',
                email='admin@phanmemketoan.com',
                status=True
            )
            db.add(admin)
            db.commit()
            print("✅ Admin user created: admin/admin123")
        else:
            print("ℹ️  Admin user already exists")
        
        # Create sample products if none exist
        products_count = db.query(Product).count()
        if products_count == 0:
            print("📦 Creating sample products...")
            sample_products = [
                Product(
                    ma_sp='SP001',
                    ten_sp='Sản phẩm mẫu 1',
                    mo_ta='Mô tả sản phẩm mẫu 1',
                    gia_ban=100000,
                    so_luong=50,
                    nhom_sp='Máy tính',
                    trang_thai='active'
                ),
                Product(
                    ma_sp='SP002',
                    ten_sp='Sản phẩm mẫu 2',
                    mo_ta='Mô tả sản phẩm mẫu 2',
                    gia_ban=200000,
                    so_luong=30,
                    nhom_sp='Điện thoại',
                    trang_thai='active'
                ),
                Product(
                    ma_sp='SP003',
                    ten_sp='Sản phẩm mẫu 3',
                    mo_ta='Mô tả sản phẩm mẫu 3',
                    gia_ban=150000,
                    so_luong=25,
                    nhom_sp='Phụ kiện',
                    trang_thai='active'
                )
            ]
            
            for product in sample_products:
                db.add(product)
            db.commit()
            print("✅ Sample products created")
        
        # Create sample accounts if none exist
        accounts_count = db.query(Account).count()
        if accounts_count == 0:
            print("👥 Creating sample accounts...")
            sample_accounts = [
                Account(
                    ten_tk='Khách hàng A',
                    so_dt='0123456789',
                    email='khachhangA@email.com',
                    dia_chi='123 Đường ABC, Quận 1, TP.HCM',
                    trang_thai=True
                ),
                Account(
                    ten_tk='Khách hàng B',
                    so_dt='0987654321',
                    email='khachhangB@email.com',
                    dia_chi='456 Đường XYZ, Quận 2, TP.HCM',
                    trang_thai=True
                )
            ]
            
            for account in sample_accounts:
                db.add(account)
            db.commit()
            print("✅ Sample accounts created")
        
        db.close()
        
        print("🎉 Database setup completed successfully!")
        return True
        
    except Exception as e:
        print(f"❌ Database setup failed: {str(e)}")
        return False

def test_database_connection():
    """Test database connection"""
    
    DATABASE_URL = os.environ.get("DATABASE_URL")
    
    if not DATABASE_URL:
        print("❌ DATABASE_URL environment variable not found!")
        return False
    
    if DATABASE_URL.startswith("postgres://"):
        DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)
    
    try:
        engine = create_engine(DATABASE_URL)
        connection = engine.connect()
        connection.close()
        print("✅ Database connection successful!")
        return True
    except Exception as e:
        print(f"❌ Database connection failed: {str(e)}")
        return False

if __name__ == "__main__":
    print("🚀 Starting database setup...")
    
    # Test connection first
    if test_database_connection():
        # Setup database
        setup_database()
    else:
        print("❌ Cannot proceed with database setup due to connection failure")
        sys.exit(1)
