import uvicorn
from app.main import app
from app.config import Config

if __name__ == "__main__":
    print(f"🚀 Starting PhanMemKeToan Backend on port {Config.BACKEND_PORT}")
    print(f"📡 API will be available at: http://localhost:{Config.BACKEND_PORT}")
    print(f"🔗 Frontend should connect to: http://localhost:{Config.BACKEND_PORT}")
    
    uvicorn.run(
        "app.main:app", 
        host="0.0.0.0", 
        port=Config.BACKEND_PORT, 
        reload=True,
        log_level="info"
    ) 