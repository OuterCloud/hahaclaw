#!/bin/bash

# OpenClaw 更新脚本 (macOS)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================="
echo "  OpenClaw 更新工具"
echo "========================================="
echo ""

# 检查是否已安装
if ! command -v openclaw >/dev/null 2>&1; then
    echo -e "${RED}错误: OpenClaw 未安装${NC}"
    echo "请先运行安装脚本: ./openclaw.sh install"
    exit 1
fi

# 获取当前版本
CURRENT_VERSION=$(openclaw --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
echo -e "${BLUE}当前版本: $CURRENT_VERSION${NC}"

# 检查最新版本
echo "正在检查最新版本..."
LATEST_VERSION=$(npm view openclaw version 2>/dev/null || echo "unknown")

if [ "$LATEST_VERSION" = "unknown" ]; then
    echo -e "${YELLOW}警告: 无法获取最新版本信息${NC}"
    echo "请检查网络连接"
    exit 1
fi

echo -e "${BLUE}最新版本: $LATEST_VERSION${NC}"
echo ""

# 比较版本
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo -e "${GREEN}✓ 您已经在使用最新版本${NC}"
    read -p "是否强制重新安装? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# 备份配置
echo "正在备份配置..."
BACKUP_DIR="$PROJECT_ROOT/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -d "$HOME/.openclaw" ]; then
    cp -r "$HOME/.openclaw" "$BACKUP_DIR/"
    echo -e "${GREEN}✓ 配置已备份到: $BACKUP_DIR${NC}"
fi
echo ""

# 更新
echo "正在更新 OpenClaw..."
npm update -g openclaw

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ 更新失败${NC}"
    echo ""
    echo "尝试使用以下命令手动更新:"
    echo "  npm install -g openclaw@latest"
    exit 1
fi

# 验证更新
NEW_VERSION=$(openclaw --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
echo ""
echo "========================================="
echo -e "${GREEN}  更新成功！${NC}"
echo "========================================="
echo ""
echo "版本变化: $CURRENT_VERSION → $NEW_VERSION"
echo ""

# 运行健康检查
echo "运行健康检查..."
openclaw doctor || echo -e "${YELLOW}警告: 健康检查未完全通过${NC}"

echo ""
echo "更新日志: https://github.com/openclaw/openclaw/releases"
echo "配置备份: $BACKUP_DIR"
echo ""
