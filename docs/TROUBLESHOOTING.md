# 故障排查指南

## 常见问题

### 1. 安装相关问题

#### 问题：安装时提示 "git 未找到"

**原因：** 系统未安装 git

**解决方案：**

macOS:

```bash
# 使用 Homebrew 安装
brew install git

# 或安装 Xcode Command Line Tools
xcode-select --install
```

Windows:

- 下载并安装 [Git for Windows](https://git-scm.com/download/win)
- 安装后重启命令行

#### 问题：安装时提示 "python3 未找到"

**原因：** 系统未安装 Python 3

**解决方案：**

macOS:

```bash
# 使用 Homebrew 安装
brew install python3
```

Windows:

- 下载并安装 [Python](https://www.python.org/downloads/)
- 安装时勾选 "Add Python to PATH"

#### 问题：安装失败，提示磁盘空间不足

**原因：** 磁盘剩余空间不足

**解决方案：**

1. 清理磁盘空间，至少保留 5GB
2. 修改 `config.yml` 中的 `install_path`，指向空间充足的磁盘
3. 重新运行安装

#### 问题：依赖安装失败

**原因：** pip 安装依赖时网络问题或权限问题

**解决方案：**

macOS:

```bash
# 使用国内镜像源
pip3 install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 如果提示权限问题
pip3 install --user -r requirements.txt
```

Windows:

```cmd
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### 2. 启动相关问题

#### 问题：Dashboard 提示 "unauthorized: gateway token mismatch"

**原因：** OpenClaw 的安全机制要求使用带 token 的 URL 访问

**解决方案：**

1. **使用命令打开（推荐）**

   ```bash
   openclaw dashboard
   ```

   这会自动生成带 token 的 URL 并在浏览器中打开。

2. **手动获取完整 URL**

   运行命令后会显示：

   ```
   Dashboard URL: http://127.0.0.1:18789/#token=xxxxxxxx
   ```

   复制完整 URL（包括 token 参数）到浏览器。

3. **在已打开的页面中配置**

   如果页面已经打开：

   - 在 Control UI 的 Settings 中找到 gateway token 设置
   - 粘贴从命令行获取的 token

**注意：**

- 不要直接访问 `http://127.0.0.1:18789/`
- Token 是动态生成的，每次可能不同
- 使用 `openclaw dashboard` 是最简单的方式

#### 问题：启动失败，提示 "端口已被占用"

**原因：** 配置的端口已被其他程序使用

**解决方案：**

1. 查找占用端口的进程：

macOS:

```bash
lsof -i :18789
```

Windows:

```cmd
netstat -ano | findstr :18789
```

2. 选择以下方案之一：
   - 停止占用端口的程序
   - 修改 `~/.openclaw/openclaw.json` 中的 gateway port 配置

#### 问题：启动失败，运行 `openclaw doctor` 诊断

**原因：** 配置错误、依赖缺失或网络问题

**解决方案：**

1. 运行系统诊断：

   ```bash
   openclaw doctor
   ```

2. 根据诊断结果修复问题：

   - API Key 无效：检查并更新 `~/.openclaw/openclaw.json`
   - 网络问题：检查防火墙和代理设置
   - 配置错误：查看配置文件格式

3. 查看日志：

   ```bash
   openclaw logs --follow
   ```

#### 问题：启动后立即退出

**原因：** 配置错误或依赖缺失

**解决方案：**

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

4. 如果配置损坏，尝试重新配置：

   ```bash
   # 备份当前配置
   cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup

   # 重新运行安装脚本配置
   ./openclaw.sh install
   ```

#### 问题：启动成功但无法访问

**原因：** Token 验证失败或网络配置问题

**解决方案：**

1. 使用正确的方式打开 Dashboard：

   ```bash
   openclaw dashboard
   ```

2. 检查 Gateway 状态：

   ```bash
   openclaw gateway status
   ```

3. 查看日志：

   ```bash
   openclaw logs --follow
   ```

4. 如果是网络问题，检查防火墙设置

macOS:

```bash
# 查看防火墙状态
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

Windows:

- 打开 Windows Defender 防火墙
- 添加入站规则，允许对应端口

**注意：** OpenClaw Gateway 默认绑定到 loopback (127.0.0.1)，只允许本地访问。

#### 问题：macOS 提示 "无法打开，因为无法验证开发者"

**原因：** macOS 安全策略限制（注：OpenClaw 通过 npm 安装不会遇到此问题）

**解决方案：**

如果遇到此问题，说明可能使用了非官方安装方式。建议：

```bash
# 卸载当前版本
./openclaw.sh uninstall

# 使用官方方式重新安装
npm install -g openclaw@latest

# 或使用本项目脚本
./openclaw.sh install
```

### 3. 运行相关问题

#### 问题：服务运行一段时间后自动停止

**原因：** 内存不足、程序崩溃或系统休眠

**解决方案：**

1. 查看日志确认原因：

   ```bash
   openclaw logs --follow
   ```

2. 运行系统诊断：

   ```bash
   openclaw doctor
   ```

3. 检查系统资源使用情况：

   ```bash
   # macOS
   top

   # Windows
   taskmgr
   ```

4. 如果是内存问题，考虑：
   - 关闭其他占用内存的程序
   - 增加系统内存
   - 重启 Gateway：`./openclaw.sh stop && ./openclaw.sh start`

#### 问题：服务响应缓慢

**原因：** 资源不足、网络延迟或 LLM API 响应慢

**解决方案：**

1. 检查系统资源：

   ```bash
   # macOS
   top

   # Windows
   taskmgr
   ```

2. 检查网络连接：

   ```bash
   # 测试 API 连接
   openclaw doctor
   ```

3. 查看日志分析瓶颈：

   ```bash
   openclaw logs --follow
   ```

4. 如果是 LLM API 响应慢：
   - 考虑切换到更快的模型（如 qwen3-flash）
   - 检查 API 配额是否用尽
   - 尝试切换区域（如从 Beijing 切换到 Singapore）

#### 问题：数据丢失

**原因：** 异常关闭或磁盘问题

**解决方案：**

1. 检查 OpenClaw 工作区：

   ```bash
   ls -la ~/.openclaw/workspace/
   ```

2. 检查磁盘健康状态

3. 从备份恢复数据（如果有）

4. 建立定期备份机制：

   ```bash
   # macOS - 备份整个 OpenClaw 目录
   cp -r ~/.openclaw ~/openclaw-backup-$(date +%Y%m%d)

   # Windows
   xcopy %USERPROFILE%\.openclaw %USERPROFILE%\openclaw-backup-%date% /E /I
   ```

5. 使用本项目的更新功能会自动备份：

   ```bash
   ./openclaw.sh update
   ```

### 4. 停止相关问题

#### 问题：无法停止服务

**原因：** 进程无响应

**解决方案：**

1. 尝试强制停止：

   ```bash
   openclaw gateway stop --force
   ```

2. 如果仍然无法停止，手动结束进程：

macOS:

```bash
# 查找进程
ps aux | grep openclaw

# 强制结束
kill -9 <PID>
```

Windows:

```cmd
# 查找进程
tasklist | findstr openclaw

# 强制结束
taskkill /F /PID <PID>
```

3. 清理残留（如果有）：

   ```bash
   # 删除旧的 PID 文件
   rm -f openclaw.pid
   ```

#### 问题：停止后 Dashboard 仍可访问

**原因：** Gateway 进程未完全终止

**现象：**

- 运行 `./openclaw.sh stop` 显示 "已停止"
- 但 Dashboard 仍然可以访问
- `openclaw gateway status` 显示 "RPC probe: ok"

**解决方案：**

本项目的停止脚本已自动处理此问题：

1. **自动清理残留进程**

   ```bash
   ./openclaw.sh stop
   ```

   脚本会：

   - 停止 LaunchAgent/服务
   - 检测残留的 Gateway 进程
   - 自动清理所有相关进程
   - 验证完全停止

2. **手动清理（如果自动清理失败）**

   macOS:

   ```bash
   # 查找 Gateway 进程
   ps aux | grep "openclaw.*gateway"

   # 强制终止
   pkill -9 -f "openclaw.*gateway"

   # 验证
   openclaw gateway status
   ```

   Windows:

   ```cmd
   # 查找进程
   tasklist | findstr openclaw

   # 强制终止
   taskkill /F /IM node.exe /FI "WINDOWTITLE eq openclaw*"
   ```

3. **验证完全停止**

   ```bash
   # 检查服务状态
   openclaw gateway status

   # 检查进程
   ps aux | grep openclaw  # macOS
   tasklist | findstr openclaw  # Windows

   # 尝试访问 Dashboard（应该无法连接）
   curl http://127.0.0.1:18789
   ```

**注意：** 更新到最新版本的停止脚本可以避免此问题。

#### 问题：停止后端口仍被占用

**原因：** 进程未完全结束或有其他程序占用

**解决方案：**

1. 等待几秒后重试
2. 检查是否有其他 OpenClaw 实例
3. 使用本项目的停止脚本（会自动清理）
4. 重启系统（最后手段）

### 5. 卸载相关问题

#### 问题：卸载后仍有残留文件

**原因：** 某些文件被占用或权限问题

**解决方案：**

1. 使用本项目的卸载脚本（推荐）：

   ```bash
   ./openclaw.sh uninstall
   ```

2. 手动清理残留：

macOS:

```bash
# 删除配置目录
rm -rf ~/.openclaw

# 删除本地文件（如果有）
rm -rf ./openclaw ./logs ./data
rm -f openclaw.pid

# 清理 shell 配置
./openclaw.sh cleanup
```

Windows:

```cmd
# 删除配置目录
rmdir /S /Q %USERPROFILE%\.openclaw

# 删除本地文件
rmdir /S /Q openclaw logs data
del openclaw.pid

# 清理 shell 配置
openclaw.bat cleanup
```

### 6. 配置相关问题

#### 问题：修改配置后不生效

**原因：** 未重启服务

**解决方案：**

```bash
./openclaw.sh stop
./openclaw.sh start
```

#### 问题：配置文件损坏或格式错误

**原因：** JSON 格式不正确或手动编辑出错

**解决方案：**

1. 验证 JSON 格式：

   ```bash
   # macOS
   cat ~/.openclaw/openclaw.json | python3 -m json.tool

   # Windows
   type %USERPROFILE%\.openclaw\openclaw.json | python -m json.tool
   ```

2. 如果格式错误，从备份恢复：

   ```bash
   # 查看备份
   ls -la backups/

   # 恢复配置
   cp backups/update_*/openclaw.json ~/.openclaw/openclaw.json
   ```

3. 或重新运行配置：

   ```bash
   ./openclaw.sh install
   # 选择重新配置选项
   ```

### 7. 权限相关问题

#### 问题：macOS 提示 "Permission denied"

**原因：** 脚本没有执行权限

**解决方案：**

```bash
chmod +x openclaw.sh
chmod +x scripts/macos/*.sh
```

#### 问题：Windows 提示 "拒绝访问"

**原因：** 需要管理员权限

**解决方案：**

- 右键点击 `openclaw.bat`
- 选择 "以管理员身份运行"

## 日志分析

### 查看日志

使用 OpenClaw 内置命令（推荐）：

```bash
# 实时查看日志
openclaw logs --follow

# 查看最近的日志
openclaw logs --tail 100

# 查看特定日志文件
cat ~/.openclaw/logs/gateway.log
```

macOS 直接查看：

```bash
# 查看完整日志
cat ~/.openclaw/logs/gateway.log

# 实时查看
tail -f ~/.openclaw/logs/gateway.log

# 查看最后 100 行
tail -n 100 ~/.openclaw/logs/gateway.log

# 搜索错误
grep ERROR ~/.openclaw/logs/gateway.log
```

Windows 直接查看：

```cmd
# 查看日志
type %USERPROFILE%\.openclaw\logs\gateway.log

# 实时查看
powershell Get-Content %USERPROFILE%\.openclaw\logs\gateway.log -Wait

# 搜索错误
findstr ERROR %USERPROFILE%\.openclaw\logs\gateway.log
```

### 常见错误信息

#### "Connection refused"

- 检查服务是否启动
- 检查端口配置是否正确
- 检查防火墙设置

#### "Address already in use"

- 端口被占用，修改配置或停止占用端口的程序

#### "No such file or directory"

- 检查路径配置是否正确
- 确认文件是否存在
- 检查文件权限

#### "Permission denied"

- 检查文件权限
- 使用管理员权限运行

## 获取帮助

如果以上方法无法解决问题，请：

1. 收集以下信息：

   - 操作系统版本
   - OpenClaw 版本
   - 错误信息和日志
   - 配置文件内容
   - 复现步骤

2. 查看文档：
   - [使用指南](USAGE.md)
   - [配置说明](CONFIGURATION.md)
   - [项目结构](PROJECT_STRUCTURE.md)
   - [飞书集成](FEISHU_SETUP.md)

## 飞书集成故障排查

### 问题：飞书机器人不响应

这是最常见的问题，按以下步骤排查：

**步骤 1：检查 Gateway 服务状态**

```bash
openclaw gateway status
```

如果显示 `Gateway service not loaded` 或 `Runtime: unknown`：

```bash
# 安装并启动 Gateway
openclaw gateway install
openclaw gateway start

# 等待 3-5 秒
sleep 5

# 再次检查状态
openclaw gateway status
```

**步骤 2：检查飞书频道状态**

```bash
openclaw status | grep -i feishu
```

应该显示：`Feishu | ON | OK | configured`

如果显示其他状态，运行诊断：

```bash
openclaw doctor --fix
```

**步骤 3：查看实时日志**

```bash
tail -f ~/.openclaw/logs/gateway.log | grep -i "feishu\|message\|event"
```

在飞书中发送消息，观察日志输出。

**正常日志应该包含：**

- `feishu[main]: WebSocket client started` - WebSocket 连接成功
- `feishu[main]: received message` - 收到消息
- `feishu[main]: sending reply` - 发送回复

**异常情况：**

1. **没有 WebSocket 连接日志**

   - 检查飞书应用的事件订阅配置
   - 必须选择 "使用长连接接收事件"
   - 必须添加事件：`im.message.receive_v1`

2. **收到消息但没有回复**

   - 检查 LLM API 配置是否正确
   - 运行：`openclaw doctor`
   - 查看是否有 API Key 错误

3. **完全没有日志**
   - Gateway 可能没有正常启动
   - 重启：`openclaw gateway stop && openclaw gateway start`

**步骤 4：检查配置文件**

```bash
cat ~/.openclaw/openclaw.json | python3 -m json.tool | grep -A 15 '"feishu"'
```

确认：

- `enabled: true`
- `appId` 和 `appSecret` 正确
- `dmPolicy` 和 `groupPolicy` 符合预期

**步骤 5：检查飞书应用配置**

在飞书开放平台检查：

1. **应用状态**：已发布且审核通过
2. **权限配置**：已添加所有必需权限
3. **机器人能力**：已启用
4. **事件订阅**：
   - 模式：使用长连接接收事件
   - 事件：`im.message.receive_v1`

### 问题：群聊中 @机器人 不响应

**检查清单：**

1. **确认已 @机器人**

   - 必须在消息中 @机器人
   - 格式：`@机器人名称 你好`

2. **检查群聊策略**

   ```bash
   cat ~/.openclaw/openclaw.json | grep -A 3 '"groupPolicy"'
   ```

   - 不能是 `disabled`
   - 如果是 `allowlist`，检查用户是否在白名单中

3. **检查机器人是否在群里**

   - 机器人必须是群成员
   - 在群设置中查看成员列表

4. **查看日志**
   ```bash
   tail -f ~/.openclaw/logs/gateway.log | grep -i "group\|mention"
   ```

### 问题：私聊机器人不响应

**检查访问策略：**

```bash
cat ~/.openclaw/openclaw.json | grep -A 3 '"dmPolicy"'
```

**不同策略的处理：**

1. **`dmPolicy: "open"`**

   - 直接发送消息即可
   - 不需要配对

2. **`dmPolicy: "pairing"`**

   - 需要先配对
   - 发送消息获取配对码
   - 运行：`openclaw pairing approve feishu <配对码>`

3. **`dmPolicy: "allowlist"`**
   - 只有白名单用户可以使用
   - 检查 `allowFrom` 配置

### 问题：重复插件警告

**警告信息：**

```
duplicate plugin id detected; later plugin may be overridden
```

**原因：**

- 同时存在全局安装和本地安装的飞书插件

**影响：**

- 通常不影响使用
- 本地插件会覆盖全局插件

**解决方案（可选）：**

```bash
# 卸载全局插件
npm uninstall -g @openclaw/feishu

# 或者删除本地插件
rm -rf ~/.openclaw/extensions/feishu

# 重新安装
openclaw plugins install @openclaw/feishu

# 重启 Gateway
openclaw gateway restart
```

### 问题：配置更新后不生效

**解决方案：**

```bash
# 重启 Gateway 使配置生效
openclaw gateway stop
openclaw gateway start

# 等待服务完全启动
sleep 5

# 验证配置
openclaw status | grep -i feishu
```

### 常用诊断命令

```bash
# 系统诊断
openclaw doctor

# 自动修复配置问题
openclaw doctor --fix

# 查看 Gateway 状态
openclaw gateway status

# 查看所有频道状态
openclaw status

# 查看实时日志
tail -f ~/.openclaw/logs/gateway.log

# 查看配对请求
openclaw pairing list feishu

# 重启 Gateway
openclaw gateway stop && openclaw gateway start
```

## 获取帮助
