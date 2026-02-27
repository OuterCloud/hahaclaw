@echo off
REM OpenClaw 飞书自动化配置脚本 (Windows)

setlocal enabledelayedexpansion

echo =========================================
echo   OpenClaw 飞书集成配置
echo =========================================
echo.

REM 检查 OpenClaw 是否安装
where openclaw >nul 2>&1
if errorlevel 1 (
    echo 错误: OpenClaw 未安装
    echo 请先运行: openclaw.bat install
    exit /b 1
)

REM 检查配置文件
set "CONFIG_FILE=%USERPROFILE%\.openclaw\openclaw.json"
if not exist "%CONFIG_FILE%" (
    echo 错误: OpenClaw 配置文件不存在
    echo 请先运行: openclaw.bat install
    exit /b 1
)

echo 飞书集成配置向导
echo.
echo 在开始之前，请确保：
echo   1. 已在飞书开放平台创建企业自建应用
echo   2. 已配置应用权限和机器人能力
echo   3. 已获取 App ID 和 App Secret
echo.
echo 如果还未创建应用，请先访问：
echo   - 飞书开放平台: https://open.feishu.cn/
echo   - 详细步骤: docs\FEISHU_SETUP.md
echo   - 快速指南: docs\FEISHU_QUICKSTART.md
echo.

set /p CONTINUE="是否继续配置？(y/n) "
if /i not "%CONTINUE%"=="y" (
    echo 已取消配置
    echo.
    echo 提示: 完成飞书应用创建后，再次运行此脚本
    exit /b 0
)

echo.
echo =========================================
echo   第一步：检查飞书插件
echo =========================================
echo.

REM 检查插件是否已安装
echo 正在检查飞书插件...

REM 检查插件目录是否存在
set "FEISHU_PLUGIN_DIR=%USERPROFILE%\.openclaw\extensions\feishu"

if exist "%FEISHU_PLUGIN_DIR%" (
    echo √ 飞书插件已安装，跳过安装步骤
    goto :plugin_check_done
)

REM 检查插件列表
openclaw plugins list 2>nul | findstr "feishu" >nul
if not errorlevel 1 (
    echo √ 飞书插件已安装，跳过安装步骤
    goto :plugin_check_done
)

REM 插件未安装，开始安装
echo 飞书插件未安装，正在安装...

REM 尝试安装插件
openclaw plugins install @openclaw/feishu >nul 2>&1

REM 等待一下，确保安装完成
timeout /t 1 /nobreak >nul

REM 再次检查是否安装成功
if exist "%FEISHU_PLUGIN_DIR%" (
    echo √ 飞书插件安装成功
    goto :plugin_check_done
)

openclaw plugins list 2>nul | findstr "feishu" >nul
if not errorlevel 1 (
    echo √ 飞书插件安装成功
    goto :plugin_check_done
)

REM 安装失败
echo × 飞书插件安装失败
echo.
echo 可能的原因：
echo   1. 网络连接问题
echo   2. npm 配置问题
echo   3. 权限不足
echo.
echo 请尝试：
echo   - 手动安装: openclaw plugins install @openclaw/feishu
echo   - 查看日志: openclaw logs --follow
echo   - 运行诊断: openclaw doctor
exit /b 1

:plugin_check_done

echo.
echo =========================================
echo   第二步：配置飞书应用信息
echo =========================================
echo.

echo 请访问飞书开放平台获取应用凭证：
echo.
echo   飞书开放平台: https://open.feishu.cn/app
echo.
echo 步骤：
echo   1. 在应用列表中找到你创建的应用
echo   2. 点击进入应用详情
echo   3. 在「凭证与基础信息」页面复制 App ID 和 App Secret
echo.

REM 询问是否打开浏览器
set /p OPEN_BROWSER="是否在浏览器中打开飞书开放平台？(y/n，默认 y) "
if "%OPEN_BROWSER%"=="" set "OPEN_BROWSER=y"

if /i "%OPEN_BROWSER%"=="y" (
    start https://open.feishu.cn/app
    echo √ 已在浏览器中打开
)

echo.

REM 输入 App ID
:input_app_id
set /p APP_ID="请输入飞书 App ID (格式: cli_xxx): "
echo %APP_ID% | findstr /r "^cli_[a-zA-Z0-9]*$" >nul
if errorlevel 1 (
    echo App ID 格式不正确，应该以 cli_ 开头
    goto input_app_id
)

REM 输入 App Secret
echo.
echo 提示: Windows 命令行会显示输入的字符，请确保周围无人查看
:input_app_secret
set /p APP_SECRET="请输入飞书 App Secret（粘贴后按回车）: "
if "%APP_SECRET%"=="" (
    echo App Secret 不能为空
    goto input_app_secret
)

REM 显示确认信息（部分掩码）
set APP_SECRET_LEN=0
set APP_SECRET_TEMP=%APP_SECRET%
:count_loop
if defined APP_SECRET_TEMP (
    set APP_SECRET_TEMP=%APP_SECRET_TEMP:~1%
    set /a APP_SECRET_LEN+=1
    goto count_loop
)

echo √ 已接收 App Secret（长度: %APP_SECRET_LEN% 字符）
set /p CONFIRM_SECRET="确认无误？(y/n，默认 y) "
if "%CONFIRM_SECRET%"=="" set "CONFIRM_SECRET=y"
if /i not "%CONFIRM_SECRET%"=="y" (
    echo 请重新输入...
    goto input_app_secret
)

REM 输入机器人名称
set /p BOT_NAME="请输入机器人名称 (可选，直接回车跳过): "
if "%BOT_NAME%"=="" set "BOT_NAME=AI 助手"

echo.
echo =========================================
echo   第三步：配置访问控制策略
echo =========================================
echo.

echo 私聊访问策略：
echo   1. pairing - 配对模式（推荐，需要管理员批准）
echo   2. open - 开放模式（所有人都可以使用）
echo   3. allowlist - 白名单模式（仅限指定用户）
echo.

:input_dm_policy
set /p DM_POLICY_CHOICE="请选择私聊访问策略 (1-3，默认 1): "
if "%DM_POLICY_CHOICE%"=="" set "DM_POLICY_CHOICE=1"

if "%DM_POLICY_CHOICE%"=="1" (
    set "DM_POLICY=pairing"
    goto dm_policy_done
)
if "%DM_POLICY_CHOICE%"=="2" (
    set "DM_POLICY=open"
    goto dm_policy_done
)
if "%DM_POLICY_CHOICE%"=="3" (
    set "DM_POLICY=allowlist"
    echo 注意: 白名单模式需要手动编辑配置文件添加用户 Open ID
    goto dm_policy_done
)
echo 无效选择，请输入 1-3
goto input_dm_policy

:dm_policy_done

echo.
echo 群聊访问策略：
echo   1. open - 开放模式（需要 @机器人）
echo   2. disabled - 禁用群聊
echo.

:input_group_policy
set /p GROUP_POLICY_CHOICE="请选择群聊访问策略 (1-2，默认 1): "
if "%GROUP_POLICY_CHOICE%"=="" set "GROUP_POLICY_CHOICE=1"

if "%GROUP_POLICY_CHOICE%"=="1" (
    set "GROUP_POLICY=open"
    set "REQUIRE_MENTION=True"
    goto group_policy_done
)
if "%GROUP_POLICY_CHOICE%"=="2" (
    set "GROUP_POLICY=disabled"
    set "REQUIRE_MENTION=False"
    goto group_policy_done
)
echo 无效选择，请输入 1-2
goto input_group_policy

:group_policy_done

echo.
echo =========================================
echo   第四步：生成配置
echo =========================================
echo.

REM 备份原配置
set "BACKUP_FILE=%USERPROFILE%\.openclaw\openclaw.json.backup.%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "BACKUP_FILE=%BACKUP_FILE: =0%"
copy "%CONFIG_FILE%" "%BACKUP_FILE%" >nul
echo √ 已备份原配置到: %BACKUP_FILE%

REM 使用 Python 更新配置
where python >nul 2>&1
if errorlevel 1 (
    echo 错误: 需要 Python 来更新配置文件
    echo 请手动编辑配置文件: %CONFIG_FILE%
    exit /b 1
)

REM 创建临时 Python 脚本
set "TEMP_SCRIPT=%TEMP%\update_feishu_config.py"
(
echo import json
echo import sys
echo.
echo config_file = r"%CONFIG_FILE%"
echo.
echo try:
echo     with open^(config_file, 'r', encoding='utf-8'^) as f:
echo         config = json.load^(f^)
echo except Exception as e:
echo     print^(f"读取配置文件失败: {e}", file=sys.stderr^)
echo     sys.exit^(1^)
echo.
echo # 确保必要的键存在
echo if 'plugins' not in config:
echo     config['plugins'] = {}
echo if 'entries' not in config['plugins']:
echo     config['plugins']['entries'] = {}
echo if 'channels' not in config:
echo     config['channels'] = {}
echo.
echo # 配置插件
echo config['plugins']['entries']['feishu'] = {
echo     'enabled': True
echo }
echo.
echo # 配置频道
echo feishu_config = {
echo     'enabled': True,
echo     'dmPolicy': '%DM_POLICY%',
echo     'groupPolicy': '%GROUP_POLICY%',
echo     'requireMention': %REQUIRE_MENTION%,
echo     'accounts': {
echo         'main': {
echo             'appId': '%APP_ID%',
echo             'appSecret': '%APP_SECRET%',
echo             'botName': '%BOT_NAME%'
echo         }
echo     }
echo }
echo.
echo config['channels']['feishu'] = feishu_config
echo.
echo # 保存配置
echo try:
echo     with open^(config_file, 'w', encoding='utf-8'^) as f:
echo         json.dump^(config, f, indent=2, ensure_ascii=False^)
echo     print^("配置更新成功"^)
echo except Exception as e:
echo     print^(f"保存配置文件失败: {e}", file=sys.stderr^)
echo     sys.exit^(1^)
) > "%TEMP_SCRIPT%"

python "%TEMP_SCRIPT%"
if errorlevel 1 (
    echo × 配置文件更新失败
    echo 正在恢复备份...
    copy "%BACKUP_FILE%" "%CONFIG_FILE%" >nul
    del "%TEMP_SCRIPT%" >nul 2>&1
    exit /b 1
)

del "%TEMP_SCRIPT%" >nul 2>&1
echo √ 配置文件更新成功

echo.
echo =========================================
echo   第五步：重启 Gateway
echo =========================================
echo.

echo 正在重启 OpenClaw Gateway...
openclaw gateway stop >nul 2>&1
timeout /t 2 /nobreak >nul

openclaw gateway start
if errorlevel 1 (
    echo × Gateway 启动失败
    echo 请查看日志: openclaw logs --follow
    exit /b 1
)

echo √ Gateway 重启成功

echo.
echo =========================================
echo   配置完成！
echo =========================================
echo.
echo 下一步操作：
echo.

if "%DM_POLICY%"=="pairing" (
    echo 1. 在飞书中搜索并添加机器人: %BOT_NAME%
    echo 2. 向机器人发送任意消息获取配对码
    echo 3. 运行命令批准配对:
    echo    openclaw pairing approve feishu ^<配对码^>
    echo.
) else if "%DM_POLICY%"=="open" (
    echo 1. 在飞书中搜索并添加机器人: %BOT_NAME%
    echo 2. 直接向机器人发送消息即可使用（无需配对）
    echo.
    echo 提示: 开放模式下所有用户都可以使用机器人
    echo.
)

echo 常用命令：
echo   - 查看状态: openclaw gateway status
echo   - 查看日志: openclaw logs --follow
if "%DM_POLICY%"=="pairing" (
    echo   - 查看配对请求: openclaw pairing list feishu
    echo   - 批准配对: openclaw pairing approve feishu ^<CODE^>
)
echo.
echo 详细文档: docs\FEISHU_SETUP.md
echo.

endlocal
