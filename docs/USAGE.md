# 使用指南

## 基本命令

### macOS

```bash
./openclaw.sh install            # 安装
./openclaw.sh update             # 更新到最新版本
./openclaw.sh start              # 启动服务
./openclaw.sh stop               # 停止服务
./openclaw.sh status             # 查看状态
./openclaw.sh cleanup            # 清理 shell 配置
./openclaw.sh configure-feishu   # 配置飞书集成
./openclaw.sh uninstall          # 卸载
./openclaw.sh help               # 显示帮助
```

### Windows

```cmd
openclaw.bat install            # 安装
openclaw.bat update             # 更新到最新版本
openclaw.bat start              # 启动服务
openclaw.bat stop               # 停止服务
openclaw.bat status             # 查看状态
openclaw.bat cleanup            # 清理 shell 配置
openclaw.bat configure-feishu   # 配置飞书集成
openclaw.bat uninstall          # 卸载
openclaw.bat help               # 显示帮助
```

## 详细说明

### 安装 (install)

首次使用时需要运行安装命令，该命令会：

1. 检查系统依赖（git, python3 等）
2. 创建必要的目录结构
3. 下载 OpenClaw 程序
4. 安装依赖包
5. 初始化配置文件

**示例：**

```bash
# macOS
./openclaw.sh install

# Windows
openclaw.bat install
```

**注意事项：**

- 确保有足够的磁盘空间（至少 5GB）
- 首次安装可能需要较长时间
- 如果安装失败，请查看错误信息并解决依赖问题

### 启动服务 (start)

启动 OpenClaw Gateway 服务。

**示例：**

```bash
# macOS
./openclaw.sh start

# Windows
openclaw.bat start
```

**启动后：**

- Gateway 服务将在后台运行
- 可以使用以下方式访问：
  - 命令行对话：`openclaw tui`
  - Web 控制台：`openclaw dashboard`
  - 查看日志：`openclaw logs --follow`

**常见问题：**

- 如果启动失败，运行 `openclaw doctor` 诊断问题
- 检查配置文件：`cat ~/.openclaw/openclaw.json`
- 确保已完成安装和配置步骤

### 停止服务 (stop)

停止正在运行的 OpenClaw Gateway 服务。

**示例：**

```bash
# macOS
./openclaw.sh stop

# Windows
openclaw.bat stop
```

**注意事项：**

- 停止服务会中断所有正在进行的任务
- 数据会自动保存
- 如果进程无响应，可以使用 `openclaw gateway stop --force` 强制停止

### 查看状态 (status)

查看 OpenClaw 的安装和运行状态。

**示例：**

```bash
# macOS
./openclaw.sh status

# Windows
openclaw.bat status
```

**显示信息：**

- 安装状态（已安装/未安装）
- 版本信息
- 配置文件状态
- Gateway 运行状态
- 常用命令提示

**其他有用命令：**

- 系统诊断：`openclaw doctor`
- 查看日志：`openclaw logs --follow`
- 打开仪表板：`openclaw dashboard`

### 卸载 (uninstall)

完全卸载 OpenClaw，删除所有相关文件和配置。

**示例：**

```bash
# macOS
./openclaw.sh uninstall

# Windows
openclaw.bat uninstall
```

**卸载流程：**

1. 停止所有 OpenClaw 服务
2. 自动备份配置文件到 `backups/` 目录
3. 卸载 npm 全局包
4. 删除配置目录 (`~/.openclaw/`)
5. 删除本地数据目录
6. 询问是否清理 shell 配置文件（默认清理）

**清理 shell 配置：**

- 卸载时会自动检测并询问是否清理
- 默认选择 Yes 会清理 `.zshrc` 或 `.bashrc` 中的 OpenClaw 配置
- 如果跳过，可以稍后运行 `./openclaw.sh cleanup`
- 清理后需要重新加载配置：`source ~/.zshrc`

**警告：**

- 此操作不可逆，所有数据将被永久删除
- 卸载前会自动备份配置
- 建议手动备份重要数据

**卸载内容：**

- npm 全局安装的 `openclaw` 包
- 配置目录：`~/.openclaw/`
- 本地安装目录（如果有）
- 日志目录
- 数据目录
- PID 文件

**保留内容：**

- 配置备份（在 `backups/uninstall_*` 目录）
- 本项目的脚本文件

### 清理 shell 配置 (cleanup)

清理 shell 配置文件中的 OpenClaw 相关配置（如自动补全脚本）。

**示例：**

```bash
# macOS
./openclaw.sh cleanup

# Windows
openclaw.bat cleanup
```

**清理内容：**

- `.zshrc` 或 `.bashrc` 中的 OpenClaw 自动补全配置
- OpenClaw 相关的环境变量设置
- 其他 OpenClaw 添加的 shell 配置

**使用场景：**

- 卸载后清理残留配置
- 解决 shell 启动时的 OpenClaw 相关错误
- 重新配置 OpenClaw 前的清理

**注意事项：**

- 会自动备份原始配置文件
- 清理后需要重新加载配置：`source ~/.zshrc`
- 卸载时会自动询问是否清理（默认 Yes）

### 配置飞书集成 (configure-feishu)

自动化配置 OpenClaw 与飞书的集成，无需手动编辑配置文件。

**示例：**

```bash
# macOS
./openclaw.sh configure-feishu

# Windows
openclaw.bat configure-feishu
```

**配置流程：**

1. 自动安装飞书插件（如果未安装）
2. 引导输入飞书应用信息：
   - App ID（格式：cli_xxx）
   - App Secret
   - 机器人名称（可选）
3. 选择访问控制策略：
   - 私聊策略：配对模式/开放模式/白名单模式
   - 群聊策略：开放模式/禁用
4. 自动更新配置文件
5. 重启 Gateway 使配置生效

**前置要求：**

- 已在飞书开放平台创建企业自建应用
- 已配置应用权限和机器人能力
- 已获取 App ID 和 App Secret

**详细步骤：**

参考 [飞书集成配置指南](FEISHU_SETUP.md) 了解如何在飞书开放平台创建应用。

**配置完成后：**

1. 在飞书中搜索并添加机器人
2. 如果使用配对模式，向机器人发送消息获取配对码
3. 运行命令批准配对：`openclaw pairing approve feishu <配对码>`

**常用命令：**

```bash
# 查看配对请求
openclaw pairing list feishu

# 批准配对
openclaw pairing approve feishu <CODE>

# 查看 Gateway 状态
openclaw gateway status

# 查看日志
openclaw logs --follow
```

## 高级用法

### 修改配置

编辑 OpenClaw 配置文件：

```bash
# macOS
vim ~/.openclaw/openclaw.json

# Windows
notepad %USERPROFILE%\.openclaw\openclaw.json
```

详细配置说明请参考 [配置文档](CONFIGURATION.md)。

### 查看日志

实时查看 OpenClaw 日志：

```bash
# 使用 OpenClaw 内置命令（推荐）
openclaw logs --follow

# 或者直接查看日志文件
# macOS
tail -f ~/.openclaw/logs/gateway.log

# Windows
powershell Get-Content $env:USERPROFILE\.openclaw\logs\gateway.log -Wait
```

### OpenClaw 常用命令

```bash
# 启动/停止 Gateway
openclaw gateway start
openclaw gateway stop
openclaw gateway status

# 交互式命令行
openclaw tui

# Web 控制台
openclaw dashboard

# 系统诊断
openclaw doctor

# 查看日志
openclaw logs --follow

# 查看版本
openclaw --version

# 查看帮助
openclaw --help
```

## 故障排查

### 安装失败

1. 检查系统依赖是否安装
2. 确认有足够的磁盘空间
3. 检查网络连接
4. 查看安装日志

### 启动失败

1. 运行系统诊断：

   ```bash
   openclaw doctor
   ```

2. 查看日志文件：

   ```bash
   openclaw logs --follow
   ```

3. 检查配置文件：

   ```bash
   cat ~/.openclaw/openclaw.json
   ```

4. 检查端口是否被占用（如果配置了自定义端口）：

   ```bash
   # macOS
   lsof -i :18789

   # Windows
   netstat -ano | findstr :18789
   ```

### 服务无响应

1. 查看服务状态：

   ```bash
   ./openclaw.sh status
   openclaw gateway status
   ```

2. 运行系统诊断：

   ```bash
   openclaw doctor
   ```

3. 查看日志文件：

   ```bash
   openclaw logs --follow
   ```

4. 尝试重启服务：
   ```bash
   ./openclaw.sh stop
   ./openclaw.sh start
   ```

### 端口冲突

OpenClaw Gateway 默认使用端口 18789。如果需要修改，编辑配置文件：

```bash
# 编辑配置文件
vim ~/.openclaw/openclaw.json

# 修改 gateway 部分的 port 配置
{
  "gateway": {
    "port": 18790  // 改为其他未使用的端口
  }
}
```

然后重启服务：

```bash
./openclaw.sh stop
./openclaw.sh start
```

## 最佳实践

1. **定期备份数据**：定期备份 `data/` 目录
2. **监控日志**：定期检查日志文件，及时发现问题
3. **资源监控**：使用 `status` 命令监控资源使用
4. **版本管理**：记录使用的 OpenClaw 版本
5. **配置管理**：将 `config.yml` 纳入版本控制

## 更多帮助

- [配置说明](CONFIGURATION.md)
- [项目结构](PROJECT_STRUCTURE.md)
- [故障排查](TROUBLESHOOTING.md)
