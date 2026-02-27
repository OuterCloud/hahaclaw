@echo off
REM OpenClaw 启动脚本 (Windows)

setlocal enabledelayedexpansion

echo =========================================
echo   启动 OpenClaw Gateway
echo =========================================
echo.

REM 检查 OpenClaw 是否已安装
where openclaw >nul 2>&1
if errorlevel 1 (
    echo 错误: OpenClaw 未安装或不在 PATH 中
    echo 请先运行: openclaw.bat install
    exit /b 1
)

REM 检查配置文件是否存在
if not exist "%USERPROFILE%\.openclaw\openclaw.json" (
    echo 错误: OpenClaw 配置文件不存在
    echo 请先运行安装脚本完成配置
    exit /b 1
)

REM 检查是否已经在运行
openclaw gateway status >nul 2>&1
if not errorlevel 1 (
    echo OpenClaw Gateway 已在运行中
    echo 使用 'openclaw.bat status' 查看详细状态
    exit /b 0
)

echo 正在启动 OpenClaw Gateway...
echo.

REM 启动 gateway
openclaw gateway start
if errorlevel 1 (
    echo.
    echo × OpenClaw Gateway 启动失败
    echo.
    echo 可能的原因:
    echo   1. 配置文件有误
    echo   2. 端口已被占用
    echo   3. 权限不足
    echo.
    echo 请运行以下命令诊断问题:
    echo   openclaw doctor
    exit /b 1
)

echo.
echo √ OpenClaw Gateway 启动成功！
echo.
echo 后续操作:
echo   - 查看状态: openclaw.bat status
echo   - 打开仪表板: openclaw dashboard
echo   - 停止服务: openclaw.bat stop
echo.

endlocal
