# 项目结构说明

```
hahaclaw/
├── openclaw.sh              # macOS 统一驱动脚本
├── openclaw.bat             # Windows 统一驱动脚本
├── config.yml               # 配置文件
├── README.md                # 项目说明文档
├── .gitignore              # Git 忽略文件
│
├── docs/                    # 文档目录
│   ├── PROJECT_STRUCTURE.md # 项目结构说明（本文件）
│   ├── USAGE.md            # 使用指南
│   ├── CONFIGURATION.md    # 配置说明
│   └── TROUBLESHOOTING.md  # 故障排查指南
│
└── scripts/                 # 脚本目录
    ├── macos/              # macOS 脚本
    │   ├── install.sh      # 安装脚本
    │   ├── start.sh        # 启动脚本
    │   ├── stop.sh         # 停止脚本
    │   ├── status.sh       # 状态检查脚本
    │   └── uninstall.sh    # 卸载脚本
    │
    └── windows/            # Windows 脚本
        ├── install.bat     # 安装脚本
        ├── start.bat       # 启动脚本
        ├── stop.bat        # 停止脚本
        ├── status.bat      # 状态检查脚本
        └── uninstall.bat   # 卸载脚本
```

## 运行时生成的目录

安装后会生成以下目录（已在 .gitignore 中忽略）：

```
hahaclaw/
├── openclaw/               # OpenClaw 安装目录
├── logs/                   # 日志文件目录
├── data/                   # 数据文件目录
└── openclaw.pid           # 进程 ID 文件
```

## 脚本说明

### 统一驱动脚本

- `openclaw.sh` (macOS): 调用 macOS 脚本
- `openclaw.bat` (Windows): 调用 Windows 脚本

### 平台特定脚本

所有平台特定的实现都在 `scripts/` 目录下，按操作系统分类：

- `scripts/macos/`: macOS 使用的 Bash 脚本
- `scripts/windows/`: Windows 使用的批处理脚本

## 配置文件

`config.yml` 包含所有可配置项：

- 安装路径
- 服务端口
- 日志级别
- 数据目录
- 网络配置
- 数据库配置
- 其他自定义配置

详细配置说明请参考 [配置文档](CONFIGURATION.md)。

## 文档说明

所有文档统一存放在 `docs/` 目录下：

- `PROJECT_STRUCTURE.md` - 项目结构说明
- `USAGE.md` - 详细的使用指南
- `CONFIGURATION.md` - 配置文件详解
- `TROUBLESHOOTING.md` - 故障排查和常见问题
