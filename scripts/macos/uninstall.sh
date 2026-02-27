#!/bin/bash

# OpenClaw 卸载脚本 (macOS)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config.yml"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================="
echo "  OpenClaw 卸载工具"
echo "========================================="
echo ""

# 检查 OpenClaw 是否安装
OPENCLAW_INSTALLED=false
if command -v openclaw >/dev/null 2>&1; then
    OPENCLAW_INSTALLED=true
    OPENCLAW_VERSION=$(openclaw --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
elif [ -d "$HOME/.openclaw" ]; then
    OPENCLAW_INSTALLED=true
    OPENCLAW_VERSION=$(grep -o '"lastTouchedVersion": "[^"]*"' "$HOME/.openclaw/openclaw.json" 2>/dev/null | cut -d'"' -f4 || echo "unknown")
fi

if [ "$OPENCLAW_INSTALLED" = false ]; then
    echo -e "${YELLOW}OpenClaw 未安装或已卸载${NC}"
    exit 0
fi

echo -e "${BLUE}检测到 OpenClaw 版本: $OPENCLAW_VERSION${NC}"
echo ""

# 显示将要删除的内容
echo "卸载将执行以下操作:"
echo ""
echo "1. 停止 OpenClaw 服务"
if command -v openclaw >/dev/null 2>&1; then
    echo "2. 卸载 npm 全局包"
fi
if [ -d "$HOME/.openclaw" ]; then
    echo "3. 删除配置目录: ~/.openclaw/"
fi
if [ -f "$PROJECT_ROOT/config.yml" ]; then
    # 读取本地配置
    INSTALL_PATH=$(grep "install_path:" "$CONFIG_FILE" 2>/dev/null | awk '{print $2}')
    LOG_DIR=$(grep "log_dir:" "$CONFIG_FILE" 2>/dev/null | awk '{print $2}')
    DATA_DIR=$(grep "data_dir:" "$CONFIG_FILE" 2>/dev/null | awk '{print $2}')
    
    if [[ "$INSTALL_PATH" != /* ]]; then
        INSTALL_PATH="$PROJECT_ROOT/$INSTALL_PATH"
    fi
    if [[ "$LOG_DIR" != /* ]]; then
        LOG_DIR="$PROJECT_ROOT/$LOG_DIR"
    fi
    if [[ "$DATA_DIR" != /* ]]; then
        DATA_DIR="$PROJECT_ROOT/$DATA_DIR"
    fi
    
    if [ -d "$INSTALL_PATH" ]; then
        echo "4. 删除本地安装目录: $INSTALL_PATH"
    fi
    if [ -d "$LOG_DIR" ]; then
        echo "5. 删除日志目录: $LOG_DIR"
    fi
    if [ -d "$DATA_DIR" ]; then
        echo "6. 删除数据目录: $DATA_DIR"
    fi
fi

echo ""
echo -e "${RED}警告: 此操作不可逆，所有数据将被永久删除！${NC}"
echo ""
read -p "确认卸载? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "取消卸载"
    exit 0
fi

echo ""
echo "开始卸载..."
echo ""

# 1. 停止服务
echo "[1/6] 停止 OpenClaw 服务..."
if command -v openclaw >/dev/null 2>&1; then
    # 停止 daemon
    openclaw daemon stop 2>/dev/null || true
    # 停止 gateway
    openclaw gateway stop 2>/dev/null || true
fi

# 停止本地进程
if [ -f "$PROJECT_ROOT/openclaw.pid" ]; then
    PID=$(cat "$PROJECT_ROOT/openclaw.pid")
    if ps -p "$PID" > /dev/null 2>&1; then
        kill "$PID" 2>/dev/null || true
        sleep 1
    fi
    rm -f "$PROJECT_ROOT/openclaw.pid"
fi
echo -e "${GREEN}✓ 服务已停止${NC}"

# 2. 备份配置（可选）
echo ""
echo "[2/6] 备份配置..."
if [ -d "$HOME/.openclaw" ]; then
    BACKUP_DIR="$PROJECT_ROOT/backups/uninstall_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r "$HOME/.openclaw" "$BACKUP_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✓ 配置已备份到: $BACKUP_DIR${NC}"
else
    echo "跳过备份（配置目录不存在）"
fi

# 3. 卸载 npm 包
echo ""
echo "[3/6] 卸载 npm 全局包..."
if command -v openclaw >/dev/null 2>&1; then
    npm uninstall -g openclaw 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ npm 包已卸载${NC}"
    else
        echo -e "${YELLOW}警告: npm 包卸载失败，可能需要手动卸载${NC}"
    fi
else
    echo "跳过（未通过 npm 安装）"
fi

# 4. 删除配置目录
echo ""
echo "[4/6] 删除配置目录..."
if [ -d "$HOME/.openclaw" ]; then
    rm -rf "$HOME/.openclaw"
    echo -e "${GREEN}✓ 配置目录已删除${NC}"
else
    echo "跳过（配置目录不存在）"
fi

# 5. 删除本地目录
echo ""
echo "[5/6] 删除本地目录..."
DELETED_COUNT=0

if [ -d "$INSTALL_PATH" ]; then
    rm -rf "$INSTALL_PATH"
    echo "  ✓ 删除: $INSTALL_PATH"
    ((DELETED_COUNT++))
fi

if [ -d "$LOG_DIR" ]; then
    rm -rf "$LOG_DIR"
    echo "  ✓ 删除: $LOG_DIR"
    ((DELETED_COUNT++))
fi

if [ -d "$DATA_DIR" ]; then
    rm -rf "$DATA_DIR"
    echo "  ✓ 删除: $DATA_DIR"
    ((DELETED_COUNT++))
fi

if [ $DELETED_COUNT -eq 0 ]; then
    echo "跳过（本地目录不存在）"
else
    echo -e "${GREEN}✓ 已删除 $DELETED_COUNT 个目录${NC}"
fi

# 6. 清理 shell 配置
echo ""
echo "[6/6] 清理 shell 配置..."

# 检查使用的 shell
SHELL_RC=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ] && [ -f "$SHELL_RC" ]; then
    # 检查是否有 OpenClaw 相关配置
    if grep -q "openclaw" "$SHELL_RC"; then
        echo "检测到 shell 配置文件中有 OpenClaw 相关配置"
        read -p "是否清理? (Y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            # 备份原文件
            cp "$SHELL_RC" "$SHELL_RC.backup.$(date +%Y%m%d_%H%M%S)"
            # 删除 OpenClaw 相关行
            sed -i.tmp '/openclaw/d' "$SHELL_RC"
            sed -i.tmp '/# OpenClaw/d' "$SHELL_RC"
            rm -f "$SHELL_RC.tmp"
            echo -e "${GREEN}✓ Shell 配置已清理${NC}"
            echo ""
            echo "请运行以下命令使配置生效:"
            echo "  source $SHELL_RC"
        else
            echo "跳过 shell 配置清理"
            echo ""
            echo "如需稍后清理，请运行:"
            echo "  ./openclaw.sh cleanup"
        fi
    else
        echo "未找到 OpenClaw 配置"
    fi
else
    echo "未找到 shell 配置文件"
fi

echo ""
echo "========================================="
echo -e "${GREEN}  OpenClaw 卸载完成！${NC}"
echo "========================================="
echo ""
echo "已删除的内容："
echo "  - npm 全局包"
echo "  - 配置目录 (~/.openclaw/)"
echo "  - 本地数据目录"
if grep -q "openclaw" "$SHELL_RC" 2>/dev/null; then
    echo ""
    echo -e "${YELLOW}注意: Shell 配置文件未清理${NC}"
    echo "如需清理，请运行: ./openclaw.sh cleanup"
else
    echo "  - Shell 配置文件"
    echo ""
    echo -e "${YELLOW}请重新加载 shell 配置或重启终端:${NC}"
    echo "  source $SHELL_RC"
fi
echo ""
if [ -d "$BACKUP_DIR" ]; then
    echo "配置备份位置: $BACKUP_DIR"
    echo ""
fi
echo "如需重新安装，请运行: ./openclaw.sh install"
echo ""

