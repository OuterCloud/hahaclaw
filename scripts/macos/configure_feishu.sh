#!/bin/bash

# OpenClaw 飞书自动化配置脚本 (macOS)

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================="
echo "  OpenClaw 飞书集成配置"
echo "========================================="
echo ""

# 检查 OpenClaw 是否安装
if ! command -v openclaw >/dev/null 2>&1; then
    echo -e "${RED}错误: OpenClaw 未安装${NC}"
    echo "请先运行: ./openclaw.sh install"
    exit 1
fi

# 检查配置文件
CONFIG_FILE="$HOME/.openclaw/openclaw.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}错误: OpenClaw 配置文件不存在${NC}"
    echo "请先运行: ./openclaw.sh install"
    exit 1
fi

echo -e "${BLUE}飞书集成配置向导${NC}"
echo ""
echo "在开始之前，请确保："
echo "  1. 已在飞书开放平台创建企业自建应用"
echo "  2. 已配置应用权限和机器人能力"
echo "  3. 已获取 App ID 和 App Secret"
echo ""
echo -e "${YELLOW}如果还未创建应用，请先访问：${NC}"
echo "  - 飞书开放平台: https://open.feishu.cn/"
echo "  - 详细步骤: docs/FEISHU_SETUP.md"
echo "  - 快速指南: docs/FEISHU_QUICKSTART.md"
echo ""

read -p "是否继续配置？(y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消配置"
    echo ""
    echo "提示: 完成飞书应用创建后，再次运行此脚本"
    exit 0
fi

echo ""
echo "========================================="
echo "  第一步：检查飞书插件"
echo "========================================="
echo ""

# 检查插件是否已安装
echo "正在检查飞书插件..."

# 检查插件目录是否存在
FEISHU_PLUGIN_DIR="$HOME/.openclaw/extensions/feishu"
PLUGIN_LIST_OUTPUT=$(openclaw plugins list 2>/dev/null)

if [ -d "$FEISHU_PLUGIN_DIR" ] || echo "$PLUGIN_LIST_OUTPUT" | grep -qi "feishu"; then
    echo -e "${GREEN}✓ 飞书插件已安装，跳过安装步骤${NC}"
    
    # 检查是否有重复插件警告
    if echo "$PLUGIN_LIST_OUTPUT" | grep -q "duplicate plugin id"; then
        echo ""
        echo -e "${YELLOW}提示: 检测到重复的飞书插件（全局和本地），这通常不影响使用${NC}"
        echo "如需清理，可以运行: openclaw plugins uninstall @openclaw/feishu"
        echo "然后重新安装: openclaw plugins install @openclaw/feishu"
    fi
else
    echo "飞书插件未安装，正在安装..."
    
    # 尝试安装插件
    INSTALL_OUTPUT=$(openclaw plugins install @openclaw/feishu 2>&1)
    INSTALL_EXIT_CODE=$?
    
    # 等待一下，确保安装完成
    sleep 1
    
    # 检查是否安装成功
    if [ -d "$FEISHU_PLUGIN_DIR" ] || openclaw plugins list 2>/dev/null | grep -qi "feishu"; then
        echo -e "${GREEN}✓ 飞书插件安装成功${NC}"
    else
        echo -e "${RED}✗ 飞书插件安装失败${NC}"
        echo ""
        echo "错误信息："
        echo "$INSTALL_OUTPUT"
        echo ""
        echo "可能的原因："
        echo "  1. 网络连接问题"
        echo "  2. npm 配置问题"
        echo "  3. 权限不足"
        echo "  4. 插件目录已存在但损坏"
        echo ""
        echo "请尝试："
        echo "  - 手动安装: openclaw plugins install @openclaw/feishu"
        echo "  - 查看日志: openclaw logs --follow"
        echo "  - 运行诊断: openclaw doctor"
        echo "  - 如果插件目录存在，先删除: rm -rf ~/.openclaw/extensions/feishu"
        exit 1
    fi
fi

echo ""
echo "========================================="
echo "  第二步：配置飞书应用信息"
echo "========================================="
echo ""

echo -e "${BLUE}请访问飞书开放平台获取应用凭证：${NC}"
echo ""
echo "  飞书开放平台: https://open.feishu.cn/app"
echo ""
echo "步骤："
echo "  1. 在应用列表中找到你创建的应用"
echo "  2. 点击进入应用详情"
echo "  3. 在「凭证与基础信息」页面复制 App ID 和 App Secret"
echo ""

# 询问是否打开浏览器
read -p "是否在浏览器中打开飞书开放平台？(y/n，默认 y) " -n 1 -r OPEN_BROWSER
echo ""
OPEN_BROWSER=${OPEN_BROWSER:-y}

if [[ $OPEN_BROWSER =~ ^[Yy]$ ]]; then
    if command -v open >/dev/null 2>&1; then
        open "https://open.feishu.cn/app" 2>/dev/null || true
        echo -e "${GREEN}✓ 已在浏览器中打开${NC}"
    fi
fi

echo ""

# 输入 App ID
while true; do
    read -p "请输入飞书 App ID (格式: cli_xxx): " APP_ID
    if [[ $APP_ID =~ ^cli_[a-zA-Z0-9]+$ ]]; then
        break
    else
        echo -e "${RED}App ID 格式不正确，应该以 cli_ 开头${NC}"
    fi
done

# 输入 App Secret
echo ""
echo -e "${YELLOW}提示: 输入 App Secret 时不会显示字符（安全考虑）${NC}"
while true; do
    read -sp "请输入飞书 App Secret（粘贴后按回车）: " APP_SECRET
    echo ""
    if [ -n "$APP_SECRET" ]; then
        # 显示部分字符用于确认
        SECRET_LEN=${#APP_SECRET}
        if [ $SECRET_LEN -gt 8 ]; then
            MASKED_SECRET="${APP_SECRET:0:4}****${APP_SECRET: -4}"
        else
            MASKED_SECRET="****"
        fi
        echo -e "${GREEN}✓ 已接收 App Secret${NC}"
        echo "  长度: $SECRET_LEN 字符"
        echo "  显示: $MASKED_SECRET"
        echo ""
        
        read -p "确认无误？(y/n，默认 y) " -n 1 -r CONFIRM_SECRET
        echo ""
        CONFIRM_SECRET=${CONFIRM_SECRET:-y}
        if [[ $CONFIRM_SECRET =~ ^[Yy]$ ]]; then
            break
        else
            echo "请重新输入..."
        fi
    else
        echo -e "${RED}App Secret 不能为空${NC}"
    fi
done

# 输入机器人名称（可选）
read -p "请输入机器人名称 (可选，直接回车跳过): " BOT_NAME
if [ -z "$BOT_NAME" ]; then
    BOT_NAME="AI 助手"
fi

echo ""
echo "========================================="
echo "  第三步：配置访问控制策略"
echo "========================================="
echo ""

echo "私聊访问策略："
echo "  1. pairing - 配对模式（推荐，需要管理员批准）"
echo "  2. open - 开放模式（所有人都可以使用）"
echo "  3. allowlist - 白名单模式（仅限指定用户）"
echo ""

while true; do
    read -p "请选择私聊访问策略 (1-3，默认 1): " DM_POLICY_CHOICE
    DM_POLICY_CHOICE=${DM_POLICY_CHOICE:-1}
    
    case $DM_POLICY_CHOICE in
        1)
            DM_POLICY="pairing"
            break
            ;;
        2)
            DM_POLICY="open"
            break
            ;;
        3)
            DM_POLICY="allowlist"
            echo -e "${YELLOW}注意: 白名单模式需要手动编辑配置文件添加用户 Open ID${NC}"
            break
            ;;
        *)
            echo -e "${RED}无效选择，请输入 1-3${NC}"
            ;;
    esac
done

echo ""
echo "群聊访问策略："
echo "  1. open - 开放模式（需要 @机器人）"
echo "  2. disabled - 禁用群聊"
echo ""

while true; do
    read -p "请选择群聊访问策略 (1-2，默认 1): " GROUP_POLICY_CHOICE
    GROUP_POLICY_CHOICE=${GROUP_POLICY_CHOICE:-1}
    
    case $GROUP_POLICY_CHOICE in
        1)
            GROUP_POLICY="open"
            REQUIRE_MENTION="True"
            break
            ;;
        2)
            GROUP_POLICY="disabled"
            REQUIRE_MENTION="False"
            break
            ;;
        *)
            echo -e "${RED}无效选择，请输入 1-2${NC}"
            ;;
    esac
done

echo ""
echo "========================================="
echo "  第四步：生成配置"
echo "========================================="
echo ""

# 备份原配置
BACKUP_FILE="$HOME/.openclaw/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo -e "${GREEN}✓ 已备份原配置到: $BACKUP_FILE${NC}"

# 使用 Python 或 jq 更新 JSON 配置
if command -v python3 >/dev/null 2>&1; then
    # 使用 Python 更新配置
    python3 << EOF
import json
import sys

config_file = "$CONFIG_FILE"

try:
    with open(config_file, 'r', encoding='utf-8') as f:
        config = json.load(f)
except Exception as e:
    print(f"读取配置文件失败: {e}", file=sys.stderr)
    sys.exit(1)

# 确保必要的键存在
if 'plugins' not in config:
    config['plugins'] = {}
if 'entries' not in config['plugins']:
    config['plugins']['entries'] = {}
if 'channels' not in config:
    config['channels'] = {}

# 配置插件
config['plugins']['entries']['feishu'] = {
    'enabled': True
}

# 配置频道
feishu_config = {
    'enabled': True,
    'dmPolicy': '$DM_POLICY',
    'groupPolicy': '$GROUP_POLICY',
    'requireMention': $REQUIRE_MENTION,
    'accounts': {
        'main': {
            'appId': '$APP_ID',
            'appSecret': '$APP_SECRET',
            'botName': '$BOT_NAME'
        }
    }
}

config['channels']['feishu'] = feishu_config

# 保存配置
try:
    with open(config_file, 'w', encoding='utf-8') as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    print("配置更新成功")
except Exception as e:
    print(f"保存配置文件失败: {e}", file=sys.stderr)
    sys.exit(1)
EOF

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 配置文件更新成功${NC}"
    else
        echo -e "${RED}✗ 配置文件更新失败${NC}"
        echo "正在恢复备份..."
        cp "$BACKUP_FILE" "$CONFIG_FILE"
        exit 1
    fi
else
    echo -e "${RED}错误: 需要 Python 3 来更新配置文件${NC}"
    echo "请手动编辑配置文件: $CONFIG_FILE"
    exit 1
fi

echo ""
echo "========================================="
echo "  第五步：重启 Gateway"
echo "========================================="
echo ""

echo "正在重启 OpenClaw Gateway..."
if openclaw gateway stop >/dev/null 2>&1; then
    sleep 2
fi

if openclaw gateway start; then
    echo -e "${GREEN}✓ Gateway 重启成功${NC}"
else
    echo -e "${RED}✗ Gateway 启动失败${NC}"
    echo "请查看日志: openclaw logs --follow"
    exit 1
fi

echo ""
echo "========================================="
echo -e "${GREEN}  配置完成！${NC}"
echo "========================================="
echo ""
echo "下一步操作："
echo ""

if [ "$DM_POLICY" = "pairing" ]; then
    echo "1. 在飞书中搜索并添加机器人: $BOT_NAME"
    echo "2. 向机器人发送任意消息获取配对码"
    echo "3. 运行命令批准配对:"
    echo -e "   ${BLUE}openclaw pairing approve feishu <配对码>${NC}"
    echo ""
elif [ "$DM_POLICY" = "open" ]; then
    echo "1. 在飞书中搜索并添加机器人: $BOT_NAME"
    echo "2. 直接向机器人发送消息即可使用（无需配对）"
    echo ""
    echo -e "${YELLOW}提示: 开放模式下所有用户都可以使用机器人${NC}"
    echo ""
fi

echo "常用命令："
echo -e "  - 查看状态: ${BLUE}openclaw gateway status${NC}"
echo -e "  - 查看日志: ${BLUE}openclaw logs --follow${NC}"
if [ "$DM_POLICY" = "pairing" ]; then
    echo -e "  - 查看配对请求: ${BLUE}openclaw pairing list feishu${NC}"
    echo -e "  - 批准配对: ${BLUE}openclaw pairing approve feishu <CODE>${NC}"
fi
echo ""
echo "详细文档: docs/FEISHU_SETUP.md"
echo ""
