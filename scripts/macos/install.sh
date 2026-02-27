#!/bin/bash

# OpenClaw 自动化安装脚本 (macOS)
# 基于官方安装文档: https://openclaw.ai/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config.yml"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "  OpenClaw 自动化安装工具 (macOS)"
echo "========================================="
echo ""

# 检查配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}错误: 配置文件 config.yml 不存在${NC}"
    exit 1
fi

# 读取配置
INSTALL_PATH=$(grep "install_path:" "$CONFIG_FILE" | awk '{print $2}')
LOG_DIR=$(grep "log_dir:" "$CONFIG_FILE" | awk '{print $2}')
DATA_DIR=$(grep "data_dir:" "$CONFIG_FILE" | awk '{print $2}')
OPENCLAW_VERSION=$(grep "openclaw_version:" "$CONFIG_FILE" | awk '{print $2}')

# 转换相对路径为绝对路径
if [[ "$INSTALL_PATH" != /* ]]; then
    INSTALL_PATH="$PROJECT_ROOT/$INSTALL_PATH"
fi
if [[ "$LOG_DIR" != /* ]]; then
    LOG_DIR="$PROJECT_ROOT/$LOG_DIR"
fi
if [[ "$DATA_DIR" != /* ]]; then
    DATA_DIR="$PROJECT_ROOT/$DATA_DIR"
fi

echo "安装配置:"
echo "  安装路径: $INSTALL_PATH"
echo "  日志目录: $LOG_DIR"
echo "  数据目录: $DATA_DIR"
echo "  版本: $OPENCLAW_VERSION"
echo ""

# [1/6] 检查系统要求
echo "[1/6] 检查系统要求..."

# 检查 macOS 版本
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${RED}错误: 此脚本仅支持 macOS${NC}"
    exit 1
fi

# 检查 Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo -e "${YELLOW}警告: 未检测到 Homebrew，正在安装...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo -e "${GREEN}✓ 系统检查通过${NC}"
echo ""

# [2/6] 检查并安装 Node.js
echo "[2/6] 检查 Node.js..."

if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 22 ]; then
        echo -e "${GREEN}✓ Node.js $(node -v) 已安装${NC}"
    else
        echo -e "${YELLOW}当前 Node.js 版本过低，需要 v22+，正在升级...${NC}"
        brew upgrade node
    fi
else
    echo "正在安装 Node.js 22..."
    brew install node@22
    brew link node@22
fi

# 验证 Node.js 安装
if ! command -v node >/dev/null 2>&1; then
    echo -e "${RED}错误: Node.js 安装失败${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Node.js $(node -v) 准备就绪${NC}"
echo ""

# [3/6] 创建目录结构
echo "[3/6] 创建目录结构..."
mkdir -p "$INSTALL_PATH"
mkdir -p "$LOG_DIR"
mkdir -p "$DATA_DIR"
mkdir -p "$PROJECT_ROOT/.openclaw"
echo -e "${GREEN}✓ 目录创建完成${NC}"
echo ""

# [4/6] 安装 OpenClaw
echo "[4/6] 检查 OpenClaw 安装状态..."
echo ""

# 检查多种可能的安装方式
OPENCLAW_INSTALLED=false
OPENCLAW_CONFIG="$HOME/.openclaw/openclaw.json"

# 方式1: 检查命令是否在 PATH 中
if command -v openclaw >/dev/null 2>&1; then
    OPENCLAW_INSTALLED=true
    CURRENT_VERSION=$(openclaw --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    INSTALL_METHOD="PATH"
# 方式2: 检查配置文件是否存在（官方安装脚本会创建）
elif [ -f "$OPENCLAW_CONFIG" ]; then
    OPENCLAW_INSTALLED=true
    CURRENT_VERSION=$(grep -o '"lastTouchedVersion": "[^"]*"' "$OPENCLAW_CONFIG" | cut -d'"' -f4 || echo "unknown")
    INSTALL_METHOD="官方脚本"
    echo -e "${YELLOW}检测到 OpenClaw 配置文件，但命令不在 PATH 中${NC}"
    echo "这可能是因为："
    echo "  1. 使用官方安装脚本安装，但 shell 未重新加载"
    echo "  2. 使用 nvm 管理 Node.js，需要激活正确的版本"
    echo ""
    echo "尝试以下解决方案："
    echo "  1. 重新加载 shell: source ~/.zshrc 或 source ~/.bashrc"
    echo "  2. 检查 nvm: nvm use 22"
    echo "  3. 重新打开终端窗口"
    echo ""
# 方式3: 检查 npm 全局安装
elif npm list -g openclaw 2>/dev/null | grep -q openclaw; then
    OPENCLAW_INSTALLED=true
    CURRENT_VERSION=$(npm list -g openclaw 2>/dev/null | grep openclaw | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    INSTALL_METHOD="npm"
fi

if [ "$OPENCLAW_INSTALLED" = true ]; then
    echo -e "${GREEN}检测到已安装的 OpenClaw${NC}"
    echo "  当前版本: $CURRENT_VERSION"
    echo "  安装方式: $INSTALL_METHOD"
    
    # 检查是否有新版本
    if [ "$OPENCLAW_VERSION" = "latest" ]; then
        echo "  正在检查最新版本..."
        LATEST_VERSION=$(npm view openclaw version 2>/dev/null || echo "unknown")
        if [ "$LATEST_VERSION" != "unknown" ] && [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
            echo -e "${YELLOW}  发现新版本: $LATEST_VERSION${NC}"
        else
            echo "  已是最新版本"
        fi
    fi
    
    echo ""
    echo "请选择操作:"
    echo "  1) 跳过安装，使用现有版本"
    echo "  2) 更新到最新版本"
    echo "  3) 重新安装当前版本"
    echo "  4) 完全卸载后重新安装"
    echo "  5) 修复 PATH 配置"
    read -p "请选择 [1-5] (默认: 1): " -n 1 -r INSTALL_CHOICE
    echo ""
    echo ""
    
    case $INSTALL_CHOICE in
        2)
            echo "正在更新 OpenClaw 到最新版本..."
            npm update -g openclaw
            if [ $? -eq 0 ]; then
                NEW_VERSION=$(openclaw --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
                echo -e "${GREEN}✓ 更新成功！新版本: $NEW_VERSION${NC}"
            else
                echo -e "${RED}✗ 更新失败${NC}"
                exit 1
            fi
            ;;
        3)
            echo "正在重新安装 OpenClaw..."
            npm install -g --force openclaw@$CURRENT_VERSION
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ 重新安装成功${NC}"
            else
                echo -e "${RED}✗ 重新安装失败${NC}"
                exit 1
            fi
            ;;
        4)
            echo "正在完全卸载 OpenClaw..."
            npm uninstall -g openclaw
            echo "正在重新安装 OpenClaw..."
            if [ "$OPENCLAW_VERSION" = "latest" ]; then
                npm install -g openclaw@latest
            else
                npm install -g openclaw@$OPENCLAW_VERSION
            fi
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ 重新安装成功${NC}"
            else
                echo -e "${RED}✗ 重新安装失败${NC}"
                exit 1
            fi
            ;;
        5)
            echo "正在修复 PATH 配置..."
            # 检查使用的 shell
            if [ -n "$ZSH_VERSION" ]; then
                SHELL_RC="$HOME/.zshrc"
            else
                SHELL_RC="$HOME/.bashrc"
            fi
            
            # 添加 nvm 路径（如果使用 nvm）
            if [ -d "$HOME/.nvm" ]; then
                echo "检测到 nvm，确保已加载..."
                if ! grep -q "NVM_DIR" "$SHELL_RC"; then
                    echo "" >> "$SHELL_RC"
                    echo "# NVM Configuration" >> "$SHELL_RC"
                    echo 'export NVM_DIR="$HOME/.nvm"' >> "$SHELL_RC"
                    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$SHELL_RC"
                fi
            fi
            
            echo -e "${GREEN}✓ PATH 配置已更新${NC}"
            echo "请运行以下命令使配置生效:"
            echo "  source $SHELL_RC"
            echo "或重新打开终端窗口"
            ;;
        *)
            echo "跳过安装，使用现有版本"
            ;;
    esac
else
    echo "OpenClaw 未安装，开始安装..."
    echo ""
    if [ "$OPENCLAW_VERSION" = "latest" ]; then
        npm install -g openclaw@latest
    else
        npm install -g openclaw@$OPENCLAW_VERSION
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ OpenClaw 安装失败${NC}"
        echo ""
        echo "可能的原因："
        echo "  1. 网络连接问题"
        echo "  2. npm 权限问题（尝试使用 sudo）"
        echo "  3. Node.js 版本不兼容"
        echo ""
        echo "尝试使用官方安装脚本:"
        echo "  curl -fsSL https://openclaw.ai/install.sh | bash"
        exit 1
    fi
fi

# 验证安装
echo ""
if ! command -v openclaw >/dev/null 2>&1; then
    echo -e "${RED}✗ OpenClaw 验证失败${NC}"
    exit 1
fi

INSTALLED_VERSION=$(openclaw --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
echo -e "${GREEN}✓ OpenClaw $INSTALLED_VERSION 准备就绪${NC}"
echo ""

# [5/6] 配置百炼模型
echo "[5/6] 配置阿里云百炼模型..."
echo ""

# 配置文件路径
OPENCLAW_CONFIG="$HOME/.openclaw/openclaw.json"

# 询问用户是否配置百炼 API Key
echo "OpenClaw 需要配置 LLM 模型才能使用。"
echo "本脚本默认使用阿里云百炼（推荐，性价比高）"
echo ""
echo "如需使用百炼，请先："
echo "  1. 访问 https://bailian.console.aliyun.com/"
echo "  2. 开通阿里云百炼服务"
echo "  3. 获取 API Key: https://bailian.console.aliyun.com/#/api-key"
echo ""

read -p "是否现在配置百炼 API Key? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    # 获取 API Key
    echo ""
    read -p "请输入您的百炼 API Key: " BAILIAN_API_KEY
    
    if [ -z "$BAILIAN_API_KEY" ]; then
        echo -e "${YELLOW}未输入 API Key，跳过配置${NC}"
    else
        # 选择地域
        echo ""
        echo "请选择百炼服务地域:"
        echo "  1) 华北2（北京）- 推荐"
        echo "  2) 新加坡"
        echo "  3) 美国（弗吉尼亚）"
        read -p "请选择 [1-3]: " -n 1 -r REGION_CHOICE
        echo
        
        case $REGION_CHOICE in
            2)
                BASE_URL="https://dashscope-intl.aliyuncs.com/compatible-mode/v1"
                REGION_NAME="新加坡"
                ;;
            3)
                BASE_URL="https://dashscope-us.aliyuncs.com/compatible-mode/v1"
                REGION_NAME="美国（弗吉尼亚）"
                ;;
            *)
                BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"
                REGION_NAME="华北2（北京）"
                ;;
        esac
        
        echo ""
        echo "正在配置百炼模型..."
        echo "  地域: $REGION_NAME"
        echo "  Base URL: $BASE_URL"
        
        # 创建配置文件
        mkdir -p "$HOME/.openclaw"
        cat > "$OPENCLAW_CONFIG" << EOF
{
  "meta": {
    "lastTouchedVersion": "2026.2.6",
    "lastTouchedAt": "$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")"
  },
  "models": {
    "mode": "merge",
    "providers": {
      "bailian": {
        "baseUrl": "$BASE_URL",
        "apiKey": "$BAILIAN_API_KEY",
        "api": "openai-completions",
        "models": [
          {
            "id": "qwen3-max-2026-01-23",
            "name": "qwen3-max-thinking",
            "reasoning": false,
            "input": ["text"],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "contextWindow": 262144,
            "maxTokens": 65536
          },
          {
            "id": "qwen3-coder-plus",
            "name": "qwen3-coder-plus",
            "reasoning": false,
            "input": ["text"],
            "contextWindow": 131072,
            "maxTokens": 32768
          },
          {
            "id": "qwen3-flash",
            "name": "qwen3-flash",
            "reasoning": false,
            "input": ["text"],
            "contextWindow": 131072,
            "maxTokens": 32768
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "bailian/qwen3-max-2026-01-23"
      },
      "models": {
        "bailian/qwen3-max-2026-01-23": {
          "alias": "qwen3-max-thinking"
        }
      },
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      }
    }
  },
  "gateway": {
    "mode": "local",
    "auth": {
      "mode": "token",
      "token": "$(openssl rand -hex 16)"
    }
  }
}
EOF
        
        echo -e "${GREEN}✓ 百炼模型配置完成${NC}"
        echo "  配置文件: $OPENCLAW_CONFIG"
        echo "  默认模型: qwen3-max-2026-01-23"
        echo ""
        echo -e "${YELLOW}注意: 请确保您的百炼账户有足够的额度${NC}"
        echo "  新用户可领取免费额度: https://bailian.console.aliyun.com/"
    fi
else
    echo -e "${YELLOW}跳过百炼配置，您可以稍后手动配置${NC}"
    echo "配置方法: openclaw dashboard -> Settings -> Raw"
fi

echo -e "${GREEN}✓ 环境配置完成${NC}"
echo ""

# [6/6] 运行健康检查
echo "[6/6] 运行健康检查..."
echo ""

openclaw doctor || echo -e "${YELLOW}警告: 健康检查未完全通过，请配置 API 密钥后重试${NC}"

echo ""
echo "========================================="
echo -e "${GREEN}  OpenClaw 安装完成！${NC}"
echo "========================================="
echo ""
echo "下一步操作:"
echo ""

if [ -f "$OPENCLAW_CONFIG" ] && grep -q "bailian" "$OPENCLAW_CONFIG" 2>/dev/null; then
    echo "1. 测试对话:"
    echo "   openclaw tui"
    echo "   (按 Ctrl+C 退出)"
    echo ""
    echo "2. 打开 Web 控制面板:"
    echo "   openclaw dashboard"
    echo ""
    echo "3. 配置消息平台 (可选):"
    echo "   - Telegram: https://t.me/BotFather"
    echo "   - 钉钉: https://help.aliyun.com/zh/model-studio/use-cases/build-an-ai-employee-solution-based-on-clawdbot-in-4-steps"
    echo ""
    echo "4. 查看使用指南:"
    echo "   cat docs/USAGE.md"
else
    echo "1. 配置 LLM 模型:"
    echo "   方式一: openclaw onboard"
    echo "   方式二: openclaw dashboard (推荐)"
    echo ""
    echo "2. 推荐使用阿里云百炼:"
    echo "   - 开通地址: https://bailian.console.aliyun.com/"
    echo "   - 获取 API Key: https://bailian.console.aliyun.com/#/api-key"
    echo "   - 配置文档: https://help.aliyun.com/zh/model-studio/openclaw"
    echo ""
    echo "3. 测试对话:"
    echo "   openclaw tui"
fi

echo ""
echo "更多信息:"
echo "  - OpenClaw 官网: https://openclaw.ai/"
echo "  - 百炼配置文档: https://help.aliyun.com/zh/model-studio/openclaw"
echo "  - 配置文件: $OPENCLAW_CONFIG"
echo ""
