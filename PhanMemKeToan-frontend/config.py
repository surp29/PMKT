"""
Configuration settings for PhanMemKeToan Frontend
"""
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Config:
    """Configuration class for the frontend application"""
    
    # Flask configuration
    SECRET_KEY = os.getenv('SECRET_KEY', 'change-this-in-production')
    DEBUG = os.getenv('FLASK_DEBUG', 'True').lower() == 'true'
    TEMPLATES_AUTO_RELOAD = True
    
    # Server configuration
    FRONTEND_PORT = int(os.getenv('FRONTEND_PORT', 5000))
    HOST = os.getenv('HOST', '127.0.0.1')
    
    # Backend API configuration
    BACKEND_URL = os.getenv('BACKEND_URL', 'http://localhost:5001')
    API_TIMEOUT = int(os.getenv('API_TIMEOUT', 10))
    
    # Security configuration
    SESSION_COOKIE_SECURE = os.getenv('SESSION_COOKIE_SECURE', 'False').lower() == 'true'
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'
    
    # Logging configuration
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
    
    @classmethod
    def validate(cls):
        """Validate configuration settings"""
        if not cls.SECRET_KEY or cls.SECRET_KEY == 'change-this-in-production':
            print("⚠️  Warning: Using default SECRET_KEY. Change this in production!")
        
        if cls.DEBUG:
            print("🔧 Running in DEBUG mode")
        else:
            print("🚀 Running in PRODUCTION mode")
        
        print(f"🌐 Frontend will run on: http://{cls.HOST}:{cls.FRONTEND_PORT}")
        print(f"🔗 Backend API: {cls.BACKEND_URL}")
