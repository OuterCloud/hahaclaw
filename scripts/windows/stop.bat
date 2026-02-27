@echo off
REM OpenClaw 停止脚本 (Windows)

setlocal enabledelayedexpansion

echo =========================================
echo   停止 OpenClaw Gateway
echo =========================================
echo.

REM 检查 OpenClaw 是否已安装
where openclaw >nul 2>&1
if errorlevel 1 (
    echo 错误: OpenClaw 未安装或不在 PATH 中
    exit /b 1
)

REM 检查是否在运行
openclaw gateway status >nul 2>&1
if errorlevel 1 (
    echo OpenClaw Gateway 未运行
    exit /b 0
)

echo 正在停止 OpenClaw Gateway...
echo.

REM 停止 gateway
openclaw gateway stop

REM 等待停止
timeout /t 2 /nobreak >nul

REM 检查是否还有 Gateway 进程在运行
tasklist /FI "IMAGENAME eq node.exe" /FO CSV 2>nul | findstr /I "openclaw" >nul
if not errorlevel 1 (
    echo 检测到残留的 Gateway 进程，正在清理...
    
    REM 强制终止所有相关进程
    for /f "tokens=2 delims=," %%a in ('tasklist /FI "IMAGENAME eq node.exe" /FO CSV ^| findstr /I "openclaw"') do (
        set "PID=%%~a"
        echo 终止进程 PID: !PID!
        taskkill /F /PID !PID! >nul 2>&1
    )
    
    timeout /t 1 /nobreak >nul
)

REM 最终验证
openclaw gateway status >nul 2>&1
if errorlevel 1 (
    echo √ OpenClaw 已完全停止
) else (
    tasklist /FI "IMAGENAME eq node.exe" /FO CSV 2>nul | findstr /I "openclaw" >nul
    if errorlevel 1 (
        echo √ OpenClaw 已完全停止
    ) else (
        echo × OpenClaw 停止失败
        echo 请手动在任务管理器中终止相关进程
        exit /b 1
    )
)
echo.

endlocal
