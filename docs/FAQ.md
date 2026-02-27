# 常见问题 (FAQ)

## 安装相关

### Q: 系统没有 Node.js 怎么办？

**A:** 安装脚本会自动处理或提供安装指引。

**macOS：**

安装脚本会自动安装：

1. 检测到没有 Homebrew，会自动安装 Homebrew
2. 通过 Homebrew 自动安装 Node.js 22
3. 无需手动操作

**Windows：**

安装脚本会提供三种选项：

1. **手动安装（推荐）**

   - 访问 [https://nodejs.org/](https://nodejs.org/)
   - 下载并安装 Node.js 22 LTS
   - 重新运行安装脚本

2. **使用 Winget 自动安装**

   - 脚本会询问是否自动安装
   - 选择 y 后自动执行：`winget install OpenJS.NodeJS.LTS`
   - 安装完成后重新打开命令行

3. **使用 Chocolatey**
   - 以管理员身份运行：`choco install nodejs-lts`
   - 重新运行安装脚本

**验证安装：**

```bash
node -v
# 应该显示 v22.x.x 或更高版本
```

### Q: 为什么脚本检测不到我已安装的 OpenClaw？

**A:** OpenClaw 可以通过多种方式安装，可能导致检测问题：

1. **官方安装脚本安装** (`curl -fsSL https://openclaw.ai/install.sh | bash`)

   - 这种方式会创建 `~/.openclaw/` 配置目录
   - 但可能没有将 `openclaw` 命令添加到 PATH
   - 解决方案：重新加载 shell 配置或重启终端

2. **npm 全局安装** (`npm install -g openclaw`)

   - 命令会安装到 npm 的全局目录
   - 如果使用 nvm，需要确保激活了正确的 Node.js 版本

3. **PATH 配置问题**
   - 检查 `openclaw` 是否在 PATH 中：`which openclaw`
   - 如果使用 nvm：`nvm use 22` 然后重试
   - 重新加载 shell：`source ~/.zshrc` 或 `source ~/.bashrc`

**我们的安装脚本现在会：**

- 检测多种安装方式
- 提供修复 PATH 配置的选项
- 给出具体的解决建议

### Q: OpenClaw 可以在本地多个目录下安装吗？

**A:** 不建议，但技术上可行：

1. **标准安装（推荐）**

   - 全局安装：`npm install -g openclaw`
   - 配置目录：`~/.openclaw/`
   - 只有一个实例

2. **多实例安装（高级用法）**

   - 使用 `--profile` 参数：`openclaw --profile work`
   - 会创建独立的配置：`~/.openclaw-work/`
   - 适合需要隔离不同环境的场景

3. **开发模式**
   - 使用 `--dev` 参数：`openclaw --dev`
   - 配置目录：`~/.openclaw-dev/`
   - 用于测试，不影响主配置

**建议：**

- 普通用户：使用标准全局安装
- 高级用户：使用 profile 功能管理多个配置
- 开发者：使用 dev 模式进行测试

### Q: 如何检查 OpenClaw 是否正确安装？

**A:** 运行以下命令：

```bash
# 检查命令是否可用
which openclaw

# 查看版本
openclaw --version

# 运行健康检查
openclaw doctor

# 查看配置
ls -la ~/.openclaw/
```

如果 `which openclaw` 没有输出，但 `~/.openclaw/` 目录存在，说明安装了但 PATH 配置有问题。

### Q: 我应该使用官方安装脚本还是本项目的脚本？

**A:** 两种方式各有优势：

**官方安装脚本** (`curl -fsSL https://openclaw.ai/install.sh | bash`)

- ✅ 官方维护，最新最稳定
- ✅ 自动处理所有依赖
- ✅ 适合快速开始
- ❌ 不包含阿里云百炼配置引导

**本项目脚本** (`./openclaw.sh install`)

- ✅ 友好的中文界面
- ✅ 自动配置阿里云百炼
- ✅ 智能检测已安装版本
- ✅ 提供更新和修复功能
- ❌ 需要先克隆本项目

**推荐方案：**

1. 如果是首次安装：使用官方脚本快速安装
2. 如果需要配置百炼：使用本项目脚本
3. 如果已安装需要管理：使用本项目脚本

## 配置相关

### Q: 为什么推荐使用阿里云百炼？

**A:** 阿里云百炼相比国际 LLM 服务有以下优势：

1. **成本优势**

   - 价格更实惠
   - 新用户有 90 天免费额度
   - 套餐优惠最高 5.3 折

2. **访问优势**

   - 国内访问速度快
   - 无需代理
   - 低延迟

3. **模型选择**

   - 千问系列（Max、Plus、Flash、Coder）
   - 第三方模型（DeepSeek、Kimi、GLM 等）
   - 持续更新

4. **合规性**
   - 符合国内法规要求
   - 数据存储在国内

### Q: 如何切换不同的 LLM Provider？

**A:** 有两种方式：

**方式一：Web 控制台**

```bash
openclaw dashboard
# 在界面中: Settings -> Raw -> 编辑 models 配置
```

**方式二：编辑配置文件**

```bash
vim ~/.openclaw/openclaw.json
# 修改 agents.defaults.model.primary
```

### Q: 配置文件在哪里？

**A:** OpenClaw 的配置文件位置：

- **主配置**：`~/.openclaw/openclaw.json`
- **凭证**：`~/.openclaw/credentials/`
- **日志**：`~/.openclaw/logs/`
- **工作区**：`~/.openclaw/workspace/`

本项目的配置文件：

- **部署配置**：`config.yml`（项目根目录）

## 使用相关

### Q: 如何更新 OpenClaw？

**A:** 使用本项目提供的更新命令：

```bash
# macOS
./openclaw.sh update

# Windows
openclaw.bat update
```

更新前会自动备份配置，安全可靠。

### Q: 如何备份配置？

**A:** 配置文件都在 `~/.openclaw/` 目录下：

```bash
# 手动备份
cp -r ~/.openclaw ~/openclaw-backup-$(date +%Y%m%d)

# 使用本项目的更新功能会自动备份
./openclaw.sh update
```

### Q: 如何卸载 OpenClaw？

**A:** 使用卸载命令：

```bash
# 使用本项目脚本（推荐）
./openclaw.sh uninstall  # macOS
openclaw.bat uninstall   # Windows
```

**卸载脚本会：**

1. 停止所有服务
2. 自动备份配置到 `backups/` 目录
3. 卸载 npm 全局包
4. 删除 `~/.openclaw/` 配置目录
5. 删除本地数据目录
6. 可选清理 shell 配置

**手动卸载：**

```bash
# 停止服务
openclaw gateway stop

# 卸载 npm 包
npm uninstall -g openclaw

# 删除配置
rm -rf ~/.openclaw

# 删除本地数据（如果有）
rm -rf ./openclaw ./logs ./data
```

**注意：**

- 卸载前会自动备份配置
- 操作不可逆，请谨慎
- 建议手动备份重要数据

## 故障排查

### Q: 打开终端提示 "no such file or directory: ~/.openclaw/completions/openclaw.zsh"

**A:** 这是因为 OpenClaw 已卸载，但 shell 配置文件中还有引用。

**快速解决：**

```bash
# 使用我们的清理脚本
./openclaw.sh cleanup

# 或手动清理
sed -i.bak '/openclaw/d' ~/.zshrc
source ~/.zshrc
```

**详细步骤：**

1. 备份配置文件：

   ```bash
   cp ~/.zshrc ~/.zshrc.backup
   ```

2. 删除 OpenClaw 相关行：

   ```bash
   sed -i '/openclaw/d' ~/.zshrc
   ```

3. 重新加载配置：

   ```bash
   source ~/.zshrc
   ```

4. 或重新打开终端窗口

**预防措施：**

- 使用我们的卸载脚本会自动清理
- 卸载时选择清理 shell 配置选项

### Q: 提示 "command not found: openclaw"

**A:** 可能的原因和解决方案：

1. **未安装**

   ```bash
   npm install -g openclaw@latest
   ```

2. **PATH 问题**

   ```bash
   # 重新加载 shell
   source ~/.zshrc  # 或 source ~/.bashrc

   # 如果使用 nvm
   nvm use 22
   ```

3. **权限问题**
   ```bash
   # 检查 npm 全局目录权限
   npm config get prefix
   ls -la $(npm config get prefix)/bin
   ```

### Q: 健康检查失败怎么办？

**A:** 运行诊断命令：

```bash
openclaw doctor
```

根据输出的错误信息：

- API Key 无效：检查并更新密钥
- 网络问题：检查防火墙和代理设置
- 配置错误：查看 `~/.openclaw/openclaw.json`

详细的故障排查请参考 [故障排查文档](TROUBLESHOOTING.md)。

### Q: Dashboard 提示 "unauthorized: gateway token mismatch" 怎么办？

**A:** 这是 OpenClaw 的安全机制，需要使用带 token 的 URL 访问。

**解决方案：**

1. **使用命令打开（推荐）**

   ```bash
   openclaw dashboard
   ```

   这会自动生成带 token 的 URL 并在浏览器中打开。

2. **手动获取 token**

   如果需要手动访问，运行：

   ```bash
   openclaw dashboard
   ```

   会显示类似：

   ```
   Dashboard URL: http://127.0.0.1:18789/#token=xxxxxxxx
   ```

   复制完整 URL 到浏览器。

3. **在已打开的页面中配置**

   如果页面已经打开但没有 token：

   - 在 Control UI 的 Settings 中找到 gateway token 设置
   - 粘贴从命令行获取的 token

**注意：**

- Token 是动态生成的，每次启动 gateway 可能不同
- 不要直接访问 `http://127.0.0.1:18789/`，要带上 token 参数
- 使用 `openclaw dashboard` 命令是最简单的方式

## 飞书集成相关

### Q: 飞书机器人不响应怎么办？

**A:** 按以下步骤排查：

**1. 检查 Gateway 服务**

```bash
openclaw gateway status
```

如果服务未运行：

```bash
openclaw gateway install
openclaw gateway start
```

**2. 检查飞书频道状态**

```bash
openclaw status | grep -i feishu
```

应该显示：`Feishu | ON | OK | configured`

**3. 查看实时日志**

```bash
tail -f ~/.openclaw/logs/gateway.log | grep -i "feishu\|message"
```

在飞书中发送消息，观察日志输出。

**4. 检查飞书应用配置**

- 应用已发布且审核通过
- 事件订阅选择 "使用长连接接收事件"
- 已添加事件：`im.message.receive_v1`

**5. 运行诊断**

```bash
openclaw doctor --fix
```

详细排查步骤请参考 [飞书集成配置指南](FEISHU_SETUP.md#故障排查)。

### Q: 群聊中 @机器人 不响应？

**A:** 检查以下几点：

1. **确认已正确 @机器人**

   - 格式：`@机器人名称 你好`
   - 不能只 @不说话

2. **检查群聊策略**

   ```bash
   cat ~/.openclaw/openclaw.json | grep -A 3 '"groupPolicy"'
   ```

   - 不能是 `disabled`
   - 如果是 `allowlist`，检查用户是否在白名单中

3. **确认机器人在群里**

   - 在群设置中查看成员列表
   - 机器人必须是群成员

4. **查看日志**
   ```bash
   tail -f ~/.openclaw/logs/gateway.log | grep -i "group"
   ```

### Q: 配对失败，提示 "No pending pairing request found"？

**A:** 可能的原因：

1. **使用了 open 模式**

   检查配置：

   ```bash
   cat ~/.openclaw/openclaw.json | grep '"dmPolicy"'
   ```

   如果是 `"dmPolicy": "open"`，不需要配对，直接发送消息即可。

2. **配对码已过期**

   在飞书中重新发送消息获取新的配对码。

3. **Gateway 未收到消息**

   检查 Gateway 状态和日志：

   ```bash
   openclaw gateway status
   tail -f ~/.openclaw/logs/gateway.log
   ```

### Q: 重复插件警告 "duplicate plugin id detected" 怎么办？

**A:** 这个警告通常不影响使用。

**原因：**

- 同时存在全局安装和本地安装的飞书插件

**如果想清理（可选）：**

```bash
# 方案 1：卸载全局插件
npm uninstall -g @openclaw/feishu

# 方案 2：删除本地插件
rm -rf ~/.openclaw/extensions/feishu

# 重新安装
openclaw plugins install @openclaw/feishu

# 重启 Gateway
openclaw gateway restart
```

### Q: 如何切换飞书访问策略？

**A:** 编辑配置文件：

```bash
vim ~/.openclaw/openclaw.json
```

修改 `channels.feishu.dmPolicy`：

- `"pairing"` - 配对模式（需要管理员批准）
- `"open"` - 开放模式（所有人都可以使用）
- `"allowlist"` - 白名单模式（仅限指定用户）

修改后重启 Gateway：

```bash
openclaw gateway stop
openclaw gateway start
```

或者重新运行配置脚本：

```bash
./openclaw.sh configure-feishu
```

## 其他问题

### Q: 如何获取帮助？

**A:** 多种途径：

1. **查看文档**

   - [使用指南](USAGE.md)
   - [配置说明](CONFIGURATION.md)
   - [故障排查](TROUBLESHOOTING.md)

2. **官方资源**

   - [OpenClaw 官网](https://openclaw.ai/)
   - [GitHub Issues](https://github.com/openclaw/openclaw/issues)
   - [Discord 社区](https://discord.gg/openclaw)

### Q: 如何贡献代码？

**A:** 欢迎贡献！

1. Fork 本项目
2. 创建特性分支
3. 提交更改
4. 发起 Merge Request

详见 [贡献指南](../README.md#贡献指南)。
