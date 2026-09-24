@echo off
title BADELHA Backend Server
echo ========================================================
echo   BADELHA Laravel 13 ^& PostgreSQL API Server
echo ========================================================
echo.
cd /d "%~dp0backend"
echo Starting server on http://0.0.0.0:8000 ...
php artisan serve --host=0.0.0.0 --port=8000
pause
