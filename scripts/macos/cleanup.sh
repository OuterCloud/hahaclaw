#!/bin/bash

# OpenClaw Shell 配置清理脚本 (macOS)

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "  OpenClaw Shell 配置清理工具"
echo "========================================="
echo ""

# 检测使用的 shell
SHELL_RC=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    echo -e "${RED}错误: 无法检测 shell 类型${NC}"
    exit 1
fi

echo "检测到 shell: $SHELL_NAME"
echo "配置文件: $SHELL_RC"
echo ""

# 检查是否有 OpenClaw 配置
if ! grep -q "openclaw" "$SHELL_RC" 2>/dev/null; then
    echo -e "${GREEN}✓ 配置文件中没有 OpenClaw 相关配置${NC}"
    exit 0
fi

# 显示将要删除的行
echo "找到以下 OpenClaw 相关配置:"
echo ""
grep -n "openclaw" "$SHELL_RC" | while IFS=: read -r line_num line_content; do
    echo "  行 $line_num: $line_content"
done
echo ""

read -p "是否删除这些配置? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "取消清理"
    exit 0
fi

# 备份原文件
BACKUP_FILE="$SHELL_RC.backup.$(date +%Y%m%d_%H%M%S)"
cp "$SHELL_RC" "$BACKUP_FILE"
echo -e "${GREEN}✓ 已备份到: $BACKUP_FILE${NC}"

# 删除 OpenClaw 相关行
sed -i.tmp '/openclaw/d' "$SHELL_RC"
rm -f "$SHELL_RC.tmp"

# 同时删除可能的注释行
sed -i.tmp '/# OpenClaw/d' "$SHELL_RC"
rm -f "$SHELL_RC.tmp"

echo -e "${GREEN}✓ 配置已清理${NC}"
echo ""
echo "请运行以下命令使配置生效:"
echo "  source $SHELL_RC"
echo ""
echo "或重新打开终端窗口"
echo ""
