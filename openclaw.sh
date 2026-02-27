#!/bin/bash

# OpenClaw 统一驱动脚本 (macOS)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACOS_SCRIPTS="$SCRIPT_DIR/scripts/macos"

# 检查操作系统
OS="$(uname -s)"
case "$OS" in
    Darwin*)
        SCRIPTS_DIR="$MACOS_SCRIPTS"
        ;;
    *)
        echo "错误: 不支持的操作系统 $OS"
        echo "请在 Windows 上使用 openclaw.bat"
        exit 1
        ;;
esac

# 显示帮助信息
show_help() {
    echo "OpenClaw 自动化部署工具"
    echo ""
    echo "用法: ./openclaw.sh <命令>"
    echo ""
    echo "可用命令:"
    echo "  install         - 安装 OpenClaw"
    echo "  update          - 更新 OpenClaw 到最新版本"
    echo "  start           - 启动服务"
    echo "  stop            - 停止服务"
    echo "  status          - 查看状态"
    echo "  uninstall       - 卸载 OpenClaw"
    echo "  cleanup         - 清理 shell 配置文件"
    echo "  configure-feishu - 配置飞书集成"
    echo "  help            - 显示此帮助信息"
    echo ""
}

# 检查命令参数
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

COMMAND=$1

# 执行对应的脚本
case "$COMMAND" in
    install)
        bash "$SCRIPTS_DIR/install.sh"
        ;;
    update)
        bash "$SCRIPTS_DIR/update.sh"
        ;;
    start)
        bash "$SCRIPTS_DIR/start.sh"
        ;;
    stop)
        bash "$SCRIPTS_DIR/stop.sh"
        ;;
    status)
        bash "$SCRIPTS_DIR/status.sh"
        ;;
    uninstall)
        bash "$SCRIPTS_DIR/uninstall.sh"
        ;;
    cleanup)
        bash "$SCRIPTS_DIR/cleanup.sh"
        ;;
    configure-feishu)
        bash "$SCRIPTS_DIR/configure_feishu.sh"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "错误: 未知命令 '$COMMAND'"
        echo ""
        show_help
        exit 1
        ;;
esac
