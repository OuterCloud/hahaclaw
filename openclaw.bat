@echo off
REM OpenClaw 统一驱动脚本 (Windows)

setlocal

set "SCRIPT_DIR=%~dp0"
set "WINDOWS_SCRIPTS=%SCRIPT_DIR%scripts\windows"

REM 显示帮助信息
if "%1"=="" goto :show_help
if "%1"=="help" goto :show_help
if "%1"=="--help" goto :show_help
if "%1"=="-h" goto :show_help

REM 执行对应的脚本
if "%1"=="install" (
    call "%WINDOWS_SCRIPTS%\install.bat"
    goto :end
)
if "%1"=="update" (
    call "%WINDOWS_SCRIPTS%\update.bat"
    goto :end
)
if "%1"=="start" (
    call "%WINDOWS_SCRIPTS%\start.bat"
    goto :end
)
if "%1"=="stop" (
    call "%WINDOWS_SCRIPTS%\stop.bat"
    goto :end
)
if "%1"=="status" (
    call "%WINDOWS_SCRIPTS%\status.bat"
    goto :end
)
if "%1"=="uninstall" (
    call "%WINDOWS_SCRIPTS%\uninstall.bat"
    goto :end
)
if "%1"=="cleanup" (
    call "%WINDOWS_SCRIPTS%\cleanup.bat"
    goto :end
)
if "%1"=="configure-feishu" (
    call "%WINDOWS_SCRIPTS%\configure_feishu.bat"
    goto :end
)

echo 错误: 未知命令 '%1'
echo.
goto :show_help

:show_help
echo OpenClaw 自动化部署工具
echo.
echo 用法: openclaw.bat ^<命令^>
echo.
echo 可用命令:
echo   install         - 安装 OpenClaw
echo   update          - 更新 OpenClaw 到最新版本
echo   start           - 启动服务
echo   stop            - 停止服务
echo   status          - 查看状态
echo   uninstall       - 卸载 OpenClaw
echo   cleanup         - 清理配置文件
echo   configure-feishu - 配置飞书集成
echo   help            - 显示此帮助信息
echo.
goto :end

:end
endlocal
