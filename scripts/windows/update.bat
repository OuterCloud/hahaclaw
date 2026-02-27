@echo off
REM OpenClaw 更新脚本 (Windows)

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%..\..\"

echo =========================================
echo   OpenClaw 更新工具
echo =========================================
echo.

REM 检查是否已安装
where openclaw >nul 2>&1
if errorlevel 1 (
    echo [错误] OpenClaw 未安装
    echo 请先运行安装脚本: openclaw.bat install
    exit /b 1
)

REM 获取当前版本
for /f "tokens=*" %%v in ('openclaw --version 2^>nul') do set "CURRENT_VERSION=%%v"
echo [信息] 当前版本: !CURRENT_VERSION!

REM 检查最新版本
echo 正在检查最新版本...
for /f "tokens=*" %%v in ('npm view openclaw version 2^>nul') do set "LATEST_VERSION=%%v"

if "!LATEST_VERSION!"=="" (
    echo [警告] 无法获取最新版本信息
    echo 请检查网络连接
    exit /b 1
)

echo [信息] 最新版本: !LATEST_VERSION!
echo.

REM 比较版本
if "!CURRENT_VERSION!"=="!LATEST_VERSION!" (
    echo [√] 您已经在使用最新版本
    set /p FORCE_REINSTALL="是否强制重新安装? (y/N): "
    if /i not "!FORCE_REINSTALL!"=="y" (
        exit /b 0
    )
)

REM 备份配置
echo 正在备份配置...
set "BACKUP_DIR=%PROJECT_ROOT%backups\%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "BACKUP_DIR=!BACKUP_DIR: =0!"
mkdir "!BACKUP_DIR!" 2>nul

if exist "%USERPROFILE%\.openclaw" (
    xcopy "%USERPROFILE%\.openclaw" "!BACKUP_DIR!\.openclaw\" /E /I /Q >nul
    echo [√] 配置已备份到: !BACKUP_DIR!
)
echo.

REM 更新
echo 正在更新 OpenClaw...
call npm update -g openclaw

if errorlevel 1 (
    echo [×] 更新失败
    echo.
    echo 尝试使用以下命令手动更新:
    echo   npm install -g openclaw@latest
    exit /b 1
)

REM 验证更新
for /f "tokens=*" %%v in ('openclaw --version 2^>nul') do set "NEW_VERSION=%%v"
echo.
echo =========================================
echo   更新成功！
echo =========================================
echo.
echo 版本变化: !CURRENT_VERSION! -^> !NEW_VERSION!
echo.

REM 运行健康检查
echo 运行健康检查...
call openclaw doctor
if errorlevel 1 (
    echo [警告] 健康检查未完全通过
)

echo.
echo 更新日志: https://github.com/openclaw/openclaw/releases
echo 配置备份: !BACKUP_DIR!
echo.

endlocal
pause
