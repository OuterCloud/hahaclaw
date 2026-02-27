#!/bin/bash

# OpenClaw 停止脚本 (macOS)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "  停止 OpenClaw"
echo "========================================="
echo ""

# 检查 OpenClaw 是否安装
if ! command -v openclaw >/dev/null 2>&1; then
    echo -e "${YELLOW}OpenClaw 未安装或不在 PATH 中${NC}"
    exit 0
fi

# 检查是否有 OpenClaw 进程在运行
GATEWAY_PIDS=$(pgrep -f "openclaw" 2>/dev/null || true)

if [ -z "$GATEWAY_PIDS" ]; then
    echo -e "${GREEN}OpenClaw 未运行${NC}"
    exit 0
fi

echo "检测到 OpenClaw 进程："
ps aux | grep -E "openclaw" | grep -v grep | awk '{print "  PID " $2 ": " $11}'
echo ""

echo "正在停止 OpenClaw Gateway..."
openclaw gateway stop 2>/dev/null || true

# 等待停止
sleep 2

# 检查是否还有 OpenClaw 进程在运行
GATEWAY_PIDS=$(pgrep -f "openclaw" 2>/dev/null || true)

if [ -n "$GATEWAY_PIDS" ]; then
    echo -e "${YELLOW}检测到残留进程，正在清理...${NC}"
    
    # 显示残留进程
    ps aux | grep -E "openclaw" | grep -v grep | awk '{print "  PID " $2 ": " $11}'
    echo ""
    
    # 尝试优雅终止
    echo "尝试优雅终止进程..."
    for pid in $GATEWAY_PIDS; do
        kill "$pid" 2>/dev/null || true
    done
    
    sleep 3
    
    # 检查是否还在运行
    GATEWAY_PIDS=$(pgrep -f "openclaw" 2>/dev/null || true)
    if [ -n "$GATEWAY_PIDS" ]; then
        echo -e "${YELLOW}进程未响应，强制终止...${NC}"
        for pid in $GATEWAY_PIDS; do
            kill -9 "$pid" 2>/dev/null || true
        done
        sleep 1
    fi
fi

# 最终验证
GATEWAY_PIDS=$(pgrep -f "openclaw" 2>/dev/null || true)

if [ -z "$GATEWAY_PIDS" ]; then
    echo ""
    echo -e "${GREEN}✓ OpenClaw 已完全停止${NC}"
else
    echo ""
    echo -e "${RED}✗ OpenClaw 停止失败${NC}"
    echo -e "${YELLOW}仍有进程在运行：${NC}"
    ps aux | grep -E "openclaw" | grep -v grep | awk '{print "  PID " $2 ": " $11}'
    echo ""
    echo "请手动终止："
    for pid in $GATEWAY_PIDS; do
        echo "  kill -9 $pid"
    done
    exit 1
fi

