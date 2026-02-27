#!/bin/bash

# OpenClaw 状态检查脚本 (macOS)

echo "========================================="
echo "  OpenClaw 状态"
echo "========================================="
echo ""

# 检查 OpenClaw 是否已安装
if ! command -v openclaw &> /dev/null; then
    echo "安装状态: ✗ 未安装或不在 PATH 中"
    echo ""
    echo "请先运行: ./openclaw.sh install"
    exit 1
fi

# 获取 OpenClaw 版本
OPENCLAW_VERSION=$(openclaw --version 2>/dev/null | head -n 1)
echo "安装状态: ✓ 已安装"
echo "版本信息: $OPENCLAW_VERSION"

# 检查配置文件
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    echo "配置文件: ✓ 存在 (~/.openclaw/openclaw.json)"
else
    echo "配置文件: ✗ 不存在"
fi
echo ""

# 检查 Gateway 运行状态
echo "Gateway 状态:"
if openclaw gateway status &> /dev/null; then
    echo "  ✓ 运行中"
    echo ""
    
    # 显示详细状态
    openclaw gateway status
else
    echo "  ✗ 未运行"
    echo ""
    echo "启动 Gateway: ./openclaw.sh start"
fi
echo ""

# 显示其他有用信息
echo "常用命令:"
echo "  - 启动服务: ./openclaw.sh start"
echo "  - 停止服务: ./openclaw.sh stop"
echo "  - 打开仪表板: openclaw dashboard"
echo "  - 系统诊断: openclaw doctor"
echo ""
