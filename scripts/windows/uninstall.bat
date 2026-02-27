@echo off
REM OpenClaw 卸载脚本 (Windows)

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%..\..\"
set "CONFIG_FILE=%PROJECT_ROOT%config.yml"

echo =========================================
echo   OpenClaw 卸载工具
echo =========================================
echo.

REM 检查 OpenClaw 是否安装
set "OPENCLAW_INSTALLED=false"
where openclaw >nul 2>&1
if not errorlevel 1 (
    set "OPENCLAW_INSTALLED=true"
    for /f "tokens=*" %%v in ('openclaw --version 2^>nul') do set "OPENCLAW_VERSION=%%v"
) else if exist "%USERPROFILE%\.openclaw" (
    set "OPENCLAW_INSTALLED=true"
    for /f "tokens=2 delims=:, " %%v in ('findstr "lastTouchedVersion" "%USERPROFILE%\.openclaw\openclaw.json" 2^>nul') do set "OPENCLAW_VERSION=%%v"
)

if "!OPENCLAW_INSTALLED!"=="false" (
    echo [提示] OpenClaw 未安装或已卸载
    exit /b 0
)

echo [信息] 检测到 OpenClaw 版本: !OPENCLAW_VERSION!
echo.

REM 显示将要删除的内容
echo 卸载将执行以下操作:
echo.
echo 1. 停止 OpenClaw 服务

where openclaw >nul 2>&1
if not errorlevel 1 (
    echo 2. 卸载 npm 全局包
)

if exist "%USERPROFILE%\.openclaw" (
    echo 3. 删除配置目录: %USERPROFILE%\.openclaw\
)

if exist "%CONFIG_FILE%" (
    REM 读取本地配置
    for /f "tokens=2 delims=: " %%a in ('findstr "install_path:" "%CONFIG_FILE%" 2^>nul') do set "INSTALL_PATH=%%a"
    for /f "tokens=2 delims=: " %%a in ('findstr "log_dir:" "%CONFIG_FILE%" 2^>nul') do set "LOG_DIR=%%a"
    for /f "tokens=2 delims=: " %%a in ('findstr "data_dir:" "%CONFIG_FILE%" 2^>nul') do set "DATA_DIR=%%a"
    
    if not "!INSTALL_PATH:~0,1!"=="/" if not "!INSTALL_PATH:~1,1!"==":" (
        set "INSTALL_PATH=%PROJECT_ROOT%!INSTALL_PATH!"
    )
    if not "!LOG_DIR:~0,1!"=="/" if not "!LOG_DIR:~1,1!"==":" (
        set "LOG_DIR=%PROJECT_ROOT%!LOG_DIR!"
    )
    if not "!DATA_DIR:~0,1!"=="/" if not "!DATA_DIR:~1,1!"==":" (
        set "DATA_DIR=%PROJECT_ROOT%!DATA_DIR!"
    )
    
    if exist "!INSTALL_PATH!" (
        echo 4. 删除本地安装目录: !INSTALL_PATH!
    )
    if exist "!LOG_DIR!" (
        echo 5. 删除日志目录: !LOG_DIR!
    )
    if exist "!DATA_DIR!" (
        echo 6. 删除数据目录: !DATA_DIR!
    )
)

echo.
echo [警告] 此操作不可逆，所有数据将被永久删除！
echo.
set /p CONFIRM="确认卸载? (y/N): "

if /i not "!CONFIRM!"=="y" (
    echo 取消卸载
    exit /b 0
)

echo.
echo 开始卸载...
echo.

REM 1. 停止服务
echo [1/6] 停止 OpenClaw 服务...
where openclaw >nul 2>&1
if not errorlevel 1 (
    call openclaw daemon stop >nul 2>&1
    call openclaw gateway stop >nul 2>&1
)

if exist "%PROJECT_ROOT%openclaw.pid" (
    set /p PID=<"%PROJECT_ROOT%openclaw.pid"
    taskkill /PID !PID! /F >nul 2>&1
    del "%PROJECT_ROOT%openclaw.pid" >nul 2>&1
)
echo [√] 服务已停止

REM 2. 备份配置
echo.
echo [2/6] 备份配置...
if exist "%USERPROFILE%\.openclaw" (
    set "BACKUP_DIR=%PROJECT_ROOT%backups\uninstall_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
    set "BACKUP_DIR=!BACKUP_DIR: =0!"
    mkdir "!BACKUP_DIR!" 2>nul
    xcopy "%USERPROFILE%\.openclaw" "!BACKUP_DIR!\.openclaw\" /E /I /Q >nul 2>&1
    echo [√] 配置已备份到: !BACKUP_DIR!
) else (
    echo 跳过备份（配置目录不存在）
)

REM 3. 卸载 npm 包
echo.
echo [3/6] 卸载 npm 全局包...
where openclaw >nul 2>&1
if not errorlevel 1 (
    call npm uninstall -g openclaw >nul 2>&1
    if not errorlevel 1 (
        echo [√] npm 包已卸载
    ) else (
        echo [警告] npm 包卸载失败，可能需要手动卸载
    )
) else (
    echo 跳过（未通过 npm 安装）
)

REM 4. 删除配置目录
echo.
echo [4/6] 删除配置目录...
if exist "%USERPROFILE%\.openclaw" (
    rmdir /S /Q "%USERPROFILE%\.openclaw" >nul 2>&1
    echo [√] 配置目录已删除
) else (
    echo 跳过（配置目录不存在）
)

REM 5. 删除本地目录
echo.
echo [5/6] 删除本地目录...
set "DELETED_COUNT=0"

if exist "!INSTALL_PATH!" (
    rmdir /S /Q "!INSTALL_PATH!" >nul 2>&1
    echo   √ 删除: !INSTALL_PATH!
    set /a DELETED_COUNT+=1
)

if exist "!LOG_DIR!" (
    rmdir /S /Q "!LOG_DIR!" >nul 2>&1
    echo   √ 删除: !LOG_DIR!
    set /a DELETED_COUNT+=1
)

if exist "!DATA_DIR!" (
    rmdir /S /Q "!DATA_DIR!" >nul 2>&1
    echo   √ 删除: !DATA_DIR!
    set /a DELETED_COUNT+=1
)

if !DELETED_COUNT! EQU 0 (
    echo 跳过（本地目录不存在）
) else (
    echo [√] 已删除 !DELETED_COUNT! 个目录
)

REM 6. 清理配置文件
echo.
echo [6/6] 清理配置文件...

REM 检查 PowerShell Profile
if exist "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" (
    findstr /C:"openclaw" "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" >nul 2>&1
    if not errorlevel 1 (
        echo 检测到 PowerShell Profile 中有 OpenClaw 配置
        set /p CLEAN_PS="是否清理? (Y/n): "
        if /i not "!CLEAN_PS!"=="n" (
            REM 备份
            copy "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1.backup" >nul 2>&1
            REM 删除包含 openclaw 的行
            findstr /V /C:"openclaw" "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" > "%TEMP%\ps_profile_temp.ps1" 2>nul
            move /Y "%TEMP%\ps_profile_temp.ps1" "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" >nul 2>&1
            echo [√] PowerShell Profile 已清理
        ) else (
            echo 跳过配置清理
            echo.
            echo 如需稍后清理，请运行:
            echo   openclaw.bat cleanup
        )
    ) else (
        echo 未找到 OpenClaw 配置
    )
) else (
    echo 未找到 PowerShell Profile
)

echo.
echo =========================================
echo   OpenClaw 卸载完成！
echo =========================================
echo.
echo 已删除的内容：
echo   - npm 全局包
echo   - 配置目录 (%%USERPROFILE%%\.openclaw\)
echo   - 本地数据目录

REM 检查是否清理了配置
if exist "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" (
    findstr /C:"openclaw" "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" >nul 2>&1
    if not errorlevel 1 (
        echo.
        echo [提示] PowerShell Profile 未清理
        echo 如需清理，请运行: openclaw.bat cleanup
    ) else (
        echo   - PowerShell Profile
        echo.
        echo [提示] 请重启 PowerShell 使配置生效
    )
)

echo.
if exist "!BACKUP_DIR!" (
    echo 配置备份位置: !BACKUP_DIR!
    echo.
)
echo 如需重新安装，请运行: openclaw.bat install
echo.

endlocal
pause
