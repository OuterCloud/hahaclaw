@echo off
REM OpenClaw 状态检查脚本 (Windows)

setlocal enabledelayedexpansion

echo =========================================
echo   OpenClaw 状态
echo =========================================
echo.

REM 检查 OpenClaw 是否已安装
where openclaw >nul 2>&1
if errorlevel 1 (
    echo 安装状态: × 未安装或不在 PATH 中
    echo.
    echo 请先运行: openclaw.bat install
    exit /b 1
)

REM 获取 OpenClaw 版本
for /f "delims=" %%a in ('openclaw --version 2^>nul') do (
    set "OPENCLAW_VERSION=%%a"
    goto :version_found
)
:version_found

echo 安装状态: √ 已安装
echo 版本信息: !OPENCLAW_VERSION!

REM 检查配置文件
if exist "%USERPROFILE%\.openclaw\openclaw.json" (
    echo 配置文件: √ 存在 (~/.openclaw/openclaw.json^)
) else (
    echo 配置文件: × 不存在
)
echo.

REM 检查 Gateway 运行状态
echo Gateway 状态:
openclaw gateway status >nul 2>&1
if not errorlevel 1 (
    echo   √ 运行中
    echo.
    
    REM 显示详细状态
    openclaw gateway status
) else (
    echo   × 未运行
    echo.
    echo 启动 Gateway: openclaw.bat start
)
echo.

REM 显示其他有用信息
echo 常用命令:
echo   - 启动服务: openclaw.bat start
echo   - 停止服务: openclaw.bat stop
echo   - 打开仪表板: openclaw dashboard
echo   - 系统诊断: openclaw doctor
echo.

endlocal
