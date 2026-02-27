@echo off
REM OpenClaw Shell 配置清理脚本 (Windows)

setlocal enabledelayedexpansion

echo =========================================
echo   OpenClaw Shell 配置清理工具
echo =========================================
echo.

REM Windows 通常不需要清理 shell 配置
REM 但可以清理环境变量

echo [信息] Windows 系统通常不需要清理 shell 配置
echo.
echo 如果需要清理环境变量，请手动操作:
echo   1. 右键"此电脑" -^> 属性
echo   2. 高级系统设置 -^> 环境变量
echo   3. 删除包含 "openclaw" 的变量
echo.

REM 检查是否有 PowerShell Profile
if exist "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" (
    findstr /C:"openclaw" "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" >nul 2>&1
    if not errorlevel 1 (
        echo [发现] PowerShell Profile 中有 OpenClaw 配置
        echo 文件位置: %USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
        echo.
        set /p CLEAN_PS="是否清理 PowerShell Profile? (y/N): "
        if /i "!CLEAN_PS!"=="y" (
            REM 备份
            copy "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1.backup" >nul
            REM 删除包含 openclaw 的行
            findstr /V /C:"openclaw" "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" > "%TEMP%\ps_profile_temp.ps1"
            move /Y "%TEMP%\ps_profile_temp.ps1" "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" >nul
            echo [√] PowerShell Profile 已清理
        )
    )
)

echo.
echo [√] 清理完成
echo.

endlocal
pause
