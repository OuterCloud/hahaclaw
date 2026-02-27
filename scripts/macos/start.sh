#!/bin/bash

# OpenClaw 启动脚本 (macOS)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config.yml"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "  启动 OpenClaw"
echo "========================================="
echo ""

# 检查 OpenClaw 是否安装
if ! command -v openclaw >/dev/null 2>&1; then
    echo -e "${RED}错误: OpenClaw 未安装或不在 PATH 中${NC}"
    echo ""
    echo "请先运行安装脚本: ./openclaw.sh install"
    echo ""
    echo "如果已安装但命令不可用，尝试："
    echo "  1. 重新加载 shell: source ~/.zshrc"
    echo "  2. 检查 nvm: nvm use 22"
    echo "  3. 运行修复: ./openclaw.sh install (选择选项 5)"
    exit 1
fi

# 检查 OpenClaw 配置
if [ ! -f "$HOME/.openclaw/openclaw.json" ]; then
    echo -e "${YELLOW}警告: OpenClaw 配置文件不存在${NC}"
    echo ""
    echo "请先配置 OpenClaw:"
    echo "  openclaw onboard"
    echo ""
    echo "或使用安装脚本配置百炼:"
    echo "  ./openclaw.sh install"
    exit 1
fi

# 检查 Gateway 是否已运行
GATEWAY_STATUS=$(openclaw gateway status 2>/dev/null || echo "stopped")
if echo "$GATEWAY_STATUS" | grep -q "running"; then
    echo -e "${GREEN}OpenClaw Gateway 已在运行中${NC}"
    echo ""
    openclaw gateway status
    exit 0
fi

# 读取配置
PORT=$(grep "port:" "$CONFIG_FILE" 2>/dev/null | awk '{print $2}')
if [ -z "$PORT" ]; then
    PORT=18789  # 默认端口
fi

echo "启动参数:"
echo "  端口: $PORT"
echo "  配置: ~/.openclaw/openclaw.json"
echo ""

# 启动 Gateway
echo "正在启动 OpenClaw Gateway..."
openclaw gateway start

# 等待启动
sleep 3

# 验证启动
GATEWAY_STATUS=$(openclaw gateway status 2>/dev/null || echo "failed")
if echo "$GATEWAY_STATUS" | grep -q "running"; then
    echo ""
    echo "========================================="
    echo -e "${GREEN}  OpenClaw 启动成功！${NC}"
    echo "========================================="
    echo ""
    openclaw gateway status
    echo ""
    echo "使用方式:"
    echo "  - 命令行对话: openclaw tui"
    echo "  - Web 控制台: openclaw dashboard"
    echo "  - 查看日志: openclaw logs --follow"
    echo "  - 查看状态: ./openclaw.sh status"
    echo ""
else
    echo ""
    echo -e "${RED}✗ OpenClaw 启动失败${NC}"
    echo ""
    echo "请检查："
    echo "  1. 运行健康检查: openclaw doctor"
    echo "  2. 查看日志: openclaw logs --follow"
    echo "  3. 检查配置: cat ~/.openclaw/openclaw.json"
    echo ""
    exit 1
fi

