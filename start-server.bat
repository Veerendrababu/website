@echo off
echo Starting Web Server...
echo.
echo Your website will be available at:
echo Local: http://localhost:8000
echo Network: http://192.168.0.105:8000
echo.
echo Connect your mobile device to the same WiFi network
echo Then open: http://192.168.0.105:8000 in mobile browser
echo.
echo Press Ctrl+C to stop the server
echo.

REM Try Python first
python -m http.server 8000 2>nul
if errorlevel 1 (
    REM If Python fails, try with py command
    py -m http.server 8000 2>nul
    if errorlevel 1 (
        REM If still fails, try Node.js
        npx http-server -p 8000 -a 0.0.0.0 2>nul
        if errorlevel 1 (
            echo Error: Neither Python nor Node.js found
            echo Please install Python or Node.js to run the server
            pause
        )
    )
)