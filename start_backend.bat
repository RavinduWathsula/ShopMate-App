@echo off
echo Starting ShopMate Backend API...
echo Listening on all network interfaces (0.0.0.0:8000)

cd backend
call venv\Scripts\activate
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
