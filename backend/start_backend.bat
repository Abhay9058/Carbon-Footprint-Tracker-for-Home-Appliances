@echo off
chcp 65001 >nul
echo ============================================
echo   Eco Warrior - Carbon Footprint Tracker
echo   Backend Server Startup
echo ============================================
echo.
echo Server will run on: http://192.168.1.12:8001
echo Database: eco_warrior.db (SQLite)
echo.
echo IMPORTANT:
echo - Keep this window open while using the app
echo - Make sure your phone is on the same WiFi
echo - Press Ctrl+C to stop the server
echo.
echo ============================================
echo.
cd /d "%~dp0"
python -m uvicorn main:app --host 0.0.0.0 --port 8001
