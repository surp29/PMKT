import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Config:
    """Configuration class for the application"""
    
    # Database configuration
    SQLALCHEMY_DATABASE_URI = os.getenv(
        'DATABASE_URL', 
        'postgresql://postgres:password@localhost:5432/ketoan'
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # JWT configuration
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'change-this-in-production')
    JWT_ACCESS_TOKEN_EXPIRES = False
    
    # Server configuration
    BACKEND_PORT = int(os.getenv('BACKEND_PORT', 5001))
    
    # CORS configuration
    CORS_ORIGINS = os.getenv(
        'CORS_ORIGINS', 
        'http://127.0.0.1:5000,http://localhost:5000'
    ).split(',')
    
    # Environment
    ENV = os.getenv('FLASK_ENV', 'development')
    DEBUG = ENV == 'development'