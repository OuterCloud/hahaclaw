@echo off
REM OpenClaw 自动化安装脚本 (Windows)
REM 基于官方安装文档: https://openclaw.ai/

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%..\..\"
set "CONFIG_FILE=%PROJECT_ROOT%config.yml"

echo =========================================
echo   OpenClaw 自动化安装工具 (Windows)
echo =========================================
echo.

REM 检查配置文件
if not exist "%CONFIG_FILE%" (
    echo [错误] 配置文件 config.yml 不存在
    exit /b 1
)

REM 读取配置
for /f "tokens=2 delims=: " %%a in ('findstr "install_path:" "%CONFIG_FILE%"') do set "INSTALL_PATH=%%a"
for /f "tokens=2 delims=: " %%a in ('findstr "log_dir:" "%CONFIG_FILE%"') do set "LOG_DIR=%%a"
for /f "tokens=2 delims=: " %%a in ('findstr "data_dir:" "%CONFIG_FILE%"') do set "DATA_DIR=%%a"
for /f "tokens=2 delims=: " %%a in ('findstr "openclaw_version:" "%CONFIG_FILE%"') do set "OPENCLAW_VERSION=%%a"

REM 转换相对路径
if not "!INSTALL_PATH:~0,1!"=="/" if not "!INSTALL_PATH:~1,1!"==":" (
    set "INSTALL_PATH=%PROJECT_ROOT%!INSTALL_PATH!"
)
if not "!LOG_DIR:~0,1!"=="/" if not "!LOG_DIR:~1,1!"==":" (
    set "LOG_DIR=%PROJECT_ROOT%!LOG_DIR!"
)
if not "!DATA_DIR:~0,1!"=="/" if not "!DATA_DIR:~1,1!"==":" (
    set "DATA_DIR=%PROJECT_ROOT%!DATA_DIR!"
)

echo 安装配置:
echo   安装路径: !INSTALL_PATH!
echo   日志目录: !LOG_DIR!
echo   数据目录: !DATA_DIR!
echo   版本: !OPENCLAW_VERSION!
echo.

REM [1/6] 检查系统要求
echo [1/6] 检查系统要求...

REM 检查 WSL2
wsl --status >nul 2>&1
if errorlevel 1 (
    echo [警告] 未检测到 WSL2
    echo OpenClaw 在 Windows 上需要 WSL2 支持
    echo.
    set /p INSTALL_WSL="是否安装 WSL2? (y/N): "
    if /i "!INSTALL_WSL!"=="y" (
        echo 正在安装 WSL2...
        wsl --install
        echo.
        echo WSL2 安装完成，请重启计算机后重新运行此脚本
        pause
        exit /b 0
    ) else (
        echo 跳过 WSL2 安装，将尝试直接安装...
    )
)

echo [√] 系统检查通过
echo.

REM [2/6] 检查并安装 Node.js
echo [2/6] 检查 Node.js...

where node >nul 2>&1
if errorlevel 1 (
    echo × Node.js 未安装
    echo.
    echo Node.js 是 OpenClaw 的必需依赖（需要 v22 或更高版本）
    echo.
    echo 安装选项：
    echo   1. 手动安装（推荐）
    echo      访问: https://nodejs.org/
    echo      下载并安装 Node.js 22 LTS
    echo.
    echo   2. 使用 Chocolatey 自动安装
    echo      需要以管理员身份运行: choco install nodejs-lts
    echo.
    echo   3. 使用 Winget 自动安装
    echo      运行: winget install OpenJS.NodeJS.LTS
    echo.
    
    set /p AUTO_INSTALL="是否尝试使用 Winget 自动安装？(y/n，默认 n) "
    if /i "%AUTO_INSTALL%"=="y" (
        echo.
        echo 正在使用 Winget 安装 Node.js...
        winget install OpenJS.NodeJS.LTS --silent
        
        if errorlevel 1 (
            echo × 自动安装失败
            echo 请手动安装后重新运行此脚本
            pause
            exit /b 1
        )
        
        echo.
        echo √ Node.js 安装完成
        echo 请关闭并重新打开命令行窗口，然后重新运行此脚本
        pause
        exit /b 0
    ) else (
        echo.
        echo 请安装 Node.js 后重新运行此脚本
        pause
        exit /b 1
    )
) else (
    for /f "tokens=1 delims=." %%a in ('node -v') do set "NODE_MAJOR=%%a"
    set "NODE_MAJOR=!NODE_MAJOR:v=!"
    if !NODE_MAJOR! LSS 22 (
        echo [警告] Node.js 版本过低 (需要 v22+)
        echo 当前版本: 
        node -v
        echo.
        echo 请访问 https://nodejs.org/ 升级 Node.js
        echo 或使用 Winget: winget upgrade OpenJS.NodeJS.LTS
        pause
        exit /b 1
    )
    echo [√] Node.js 已安装
    node -v
)

echo.

REM [3/6] 创建目录结构
echo [3/6] 创建目录结构...
if not exist "!INSTALL_PATH!" mkdir "!INSTALL_PATH!"
if not exist "!LOG_DIR!" mkdir "!LOG_DIR!"
if not exist "!DATA_DIR!" mkdir "!DATA_DIR!"
if not exist "%USERPROFILE%\.openclaw" mkdir "%USERPROFILE%\.openclaw"
echo [√] 目录创建完成
echo.

REM [4/6] 安装 OpenClaw
echo [4/6] 检查 OpenClaw 安装状态...
echo.

where openclaw >nul 2>&1
if not errorlevel 1 (
    echo [√] 检测到已安装的 OpenClaw
    for /f "tokens=*" %%v in ('openclaw --version 2^>nul') do set "CURRENT_VERSION=%%v"
    echo   当前版本: !CURRENT_VERSION!
    
    REM 检查是否有新版本
    if "!OPENCLAW_VERSION!"=="latest" (
        echo   正在检查最新版本...
        for /f "tokens=*" %%v in ('npm view openclaw version 2^>nul') do set "LATEST_VERSION=%%v"
        if not "!LATEST_VERSION!"=="" (
            if not "!CURRENT_VERSION!"=="!LATEST_VERSION!" (
                echo   [提示] 发现新版本: !LATEST_VERSION!
            ) else (
                echo   已是最新版本
            )
        )
    )
    
    echo.
    echo 请选择操作:
    echo   1^) 跳过安装，使用现有版本
    echo   2^) 更新到最新版本
    echo   3^) 重新安装当前版本
    echo   4^) 完全卸载后重新安装
    set /p INSTALL_CHOICE="请选择 [1-4] (默认: 1): "
    
    if "!INSTALL_CHOICE!"=="" set "INSTALL_CHOICE=1"
    echo.
    
    if "!INSTALL_CHOICE!"=="2" (
        echo 正在更新 OpenClaw 到最新版本...
        call npm update -g openclaw
        if not errorlevel 1 (
            for /f "tokens=*" %%v in ('openclaw --version 2^>nul') do set "NEW_VERSION=%%v"
            echo [√] 更新成功！新版本: !NEW_VERSION!
        ) else (
            echo [×] 更新失败
            exit /b 1
        )
    ) else if "!INSTALL_CHOICE!"=="3" (
        echo 正在重新安装 OpenClaw...
        call npm install -g --force openclaw@!CURRENT_VERSION!
        if not errorlevel 1 (
            echo [√] 重新安装成功
        ) else (
            echo [×] 重新安装失败
            exit /b 1
        )
    ) else if "!INSTALL_CHOICE!"=="4" (
        echo 正在完全卸载 OpenClaw...
        call npm uninstall -g openclaw
        echo 正在重新安装 OpenClaw...
        if "!OPENCLAW_VERSION!"=="latest" (
            call npm install -g openclaw@latest
        ) else (
            call npm install -g openclaw@!OPENCLAW_VERSION!
        )
        if not errorlevel 1 (
            echo [√] 重新安装成功
        ) else (
            echo [×] 重新安装失败
            exit /b 1
        )
    ) else (
        echo 跳过安装，使用现有版本
    )
    goto :skip_install
)

echo OpenClaw 未安装，开始安装...
echo.

if "!OPENCLAW_VERSION!"=="latest" (
    call npm install -g openclaw@latest
) else (
    call npm install -g openclaw@!OPENCLAW_VERSION!
)

if errorlevel 1 (
    echo [×] OpenClaw 安装失败
    echo.
    echo 可能的原因：
    echo   1. 网络连接问题
    echo   2. npm 权限问题（尝试以管理员身份运行）
    echo   3. Node.js 版本不兼容
    echo.
    echo 尝试使用 WSL2 安装:
    echo   wsl curl -fsSL https://openclaw.ai/install.sh ^| bash
    pause
    exit /b 1
)

:skip_install

REM 验证安装
echo.
where openclaw >nul 2>&1
if errorlevel 1 (
    echo [×] OpenClaw 验证失败
    exit /b 1
)

for /f "tokens=*" %%v in ('openclaw --version 2^>nul') do set "INSTALLED_VERSION=%%v"
echo [√] OpenClaw !INSTALLED_VERSION! 准备就绪
echo.

REM [5/6] 配置百炼模型
echo [5/6] 配置阿里云百炼模型...
echo.

set "OPENCLAW_CONFIG=%USERPROFILE%\.openclaw\openclaw.json"

echo OpenClaw 需要配置 LLM 模型才能使用。
echo 本脚本默认使用阿里云百炼（推荐，性价比高）
echo.
echo 如需使用百炼，请先：
echo   1. 访问 https://bailian.console.aliyun.com/
echo   2. 开通阿里云百炼服务
echo   3. 获取 API Key: https://bailian.console.aliyun.com/#/api-key
echo.

set /p CONFIGURE_BAILIAN="是否现在配置百炼 API Key? (Y/n): "
if /i "!CONFIGURE_BAILIAN!"=="n" goto :skip_bailian

echo.
set /p BAILIAN_API_KEY="请输入您的百炼 API Key: "

if "!BAILIAN_API_KEY!"=="" (
    echo [警告] 未输入 API Key，跳过配置
    goto :skip_bailian
)

REM 选择地域
echo.
echo 请选择百炼服务地域:
echo   1^) 华北2（北京）- 推荐
echo   2^) 新加坡
echo   3^) 美国（弗吉尼亚）
set /p REGION_CHOICE="请选择 [1-3]: "

if "!REGION_CHOICE!"=="2" (
    set "BASE_URL=https://dashscope-intl.aliyuncs.com/compatible-mode/v1"
    set "REGION_NAME=新加坡"
) else if "!REGION_CHOICE!"=="3" (
    set "BASE_URL=https://dashscope-us.aliyuncs.com/compatible-mode/v1"
    set "REGION_NAME=美国（弗吉尼亚）"
) else (
    set "BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1"
    set "REGION_NAME=华北2（北京）"
)

echo.
echo 正在配置百炼模型...
echo   地域: !REGION_NAME!
echo   Base URL: !BASE_URL!

REM 生成随机 token
set "GATEWAY_TOKEN=%RANDOM%%RANDOM%%RANDOM%%RANDOM%"

REM 创建配置文件
if not exist "%USERPROFILE%\.openclaw" mkdir "%USERPROFILE%\.openclaw"

(
echo {
echo   "meta": {
echo     "lastTouchedVersion": "2026.2.6",
echo     "lastTouchedAt": "%date:~0,4%-%date:~5,2%-%date:~8,2%T%time:~0,2%:%time:~3,2%:%time:~6,2%.000Z"
echo   },
echo   "models": {
echo     "mode": "merge",
echo     "providers": {
echo       "bailian": {
echo         "baseUrl": "!BASE_URL!",
echo         "apiKey": "!BAILIAN_API_KEY!",
echo         "api": "openai-completions",
echo         "models": [
echo           {
echo             "id": "qwen3-max-2026-01-23",
echo             "name": "qwen3-max-thinking",
echo             "reasoning": false,
echo             "input": ["text"],
echo             "cost": {
echo               "input": 0,
echo               "output": 0,
echo               "cacheRead": 0,
echo               "cacheWrite": 0
echo             },
echo             "contextWindow": 262144,
echo             "maxTokens": 65536
echo           },
echo           {
echo             "id": "qwen3-coder-plus",
echo             "name": "qwen3-coder-plus",
echo             "reasoning": false,
echo             "input": ["text"],
echo             "contextWindow": 131072,
echo             "maxTokens": 32768
echo           },
echo           {
echo             "id": "qwen3-flash",
echo             "name": "qwen3-flash",
echo             "reasoning": false,
echo             "input": ["text"],
echo             "contextWindow": 131072,
echo             "maxTokens": 32768
echo           }
echo         ]
echo       }
echo     }
echo   },
echo   "agents": {
echo     "defaults": {
echo       "model": {
echo         "primary": "bailian/qwen3-max-2026-01-23"
echo       },
echo       "models": {
echo         "bailian/qwen3-max-2026-01-23": {
echo           "alias": "qwen3-max-thinking"
echo         }
echo       },
echo       "maxConcurrent": 4,
echo       "subagents": {
echo         "maxConcurrent": 8
echo       }
echo     }
echo   },
echo   "gateway": {
echo     "mode": "local",
echo     "auth": {
echo       "mode": "token",
echo       "token": "!GATEWAY_TOKEN!"
echo     }
echo   }
echo }
) > "!OPENCLAW_CONFIG!"

echo [√] 百炼模型配置完成
echo   配置文件: !OPENCLAW_CONFIG!
echo   默认模型: qwen3-max-2026-01-23
echo.
echo [提示] 请确保您的百炼账户有足够的额度
echo   新用户可领取免费额度: https://bailian.console.aliyun.com/
goto :config_done

:skip_bailian
echo [警告] 跳过百炼配置，您可以稍后手动配置
echo 配置方法: openclaw dashboard -^> Settings -^> Raw

:config_done
echo [√] 环境配置完成
echo.

REM [6/6] 运行健康检查
echo [6/6] 运行健康检查...
echo.

call openclaw doctor
if errorlevel 1 (
    echo [警告] 健康检查未完全通过，请配置 API 密钥后重试
)

echo.
echo =========================================
echo   OpenClaw 安装完成！
echo =========================================
echo.
echo 下一步操作:
echo.

if exist "!OPENCLAW_CONFIG!" (
    findstr /C:"bailian" "!OPENCLAW_CONFIG!" >nul 2>&1
    if not errorlevel 1 (
        echo 1. 测试对话:
        echo    openclaw tui
        echo    ^(按 Ctrl+C 退出^)
        echo.
        echo 2. 打开 Web 控制面板:
        echo    openclaw dashboard
        echo.
        echo 3. 配置消息平台 ^(可选^):
        echo    - Telegram: https://t.me/BotFather
        echo    - 钉钉: https://help.aliyun.com/zh/model-studio/use-cases/build-an-ai-employee-solution-based-on-clawdbot-in-4-steps
        echo.
        echo 4. 查看使用指南:
        echo    type docs\USAGE.md
        goto :show_links
    )
)

echo 1. 配置 LLM 模型:
echo    方式一: openclaw onboard
echo    方式二: openclaw dashboard ^(推荐^)
echo.
echo 2. 推荐使用阿里云百炼:
echo    - 开通地址: https://bailian.console.aliyun.com/
echo    - 获取 API Key: https://bailian.console.aliyun.com/#/api-key
echo    - 配置文档: https://help.aliyun.com/zh/model-studio/openclaw
echo.
echo 3. 测试对话:
echo    openclaw tui

:show_links
echo.
echo 更多信息:
echo   - OpenClaw 官网: https://openclaw.ai/
echo   - 百炼配置文档: https://help.aliyun.com/zh/model-studio/openclaw
echo   - 配置文件: !OPENCLAW_CONFIG!
echo.

endlocal
pause
