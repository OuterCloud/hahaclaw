# OpenClaw 自动化部署工具

一个帮助你在本地自动化安装、部署和配置 [OpenClaw](https://openclaw.ai/) 的便捷工具。

## 项目简介

OpenClaw 是一个开源的个人 AI 助手平台，可以连接到 WhatsApp、Telegram、Discord、Slack 等消息平台，让你通过聊天方式与 AI 交互。本项目提供了自动化脚本，简化 OpenClaw 在 macOS 和 Windows 上的部署流程。

## 功能特性

- 🚀 一键自动化安装 OpenClaw (基于官方 npm 包)
- ⚙️ 自动检测和安装 Node.js 22+ 依赖
- 📦 自动配置环境变量和 API 密钥
- 🔧 支持多个 LLM Provider (Claude, GPT, Gemini, Ollama)
- 💬 支持多个消息平台 (Telegram, 飞书, 钉钉, Discord 等)
- 📝 详细的日志记录和错误提示
- 🛡️ 内置速率限制和成本控制
- 🇨🇳 特别优化国内使用体验（百炼、飞书）

## 系统要求

- 操作系统：macOS / Windows (需要 WSL2)
- Node.js 22 或更高版本
  - macOS：安装脚本会自动通过 Homebrew 安装
  - Windows：可选择手动安装或使用 Winget 自动安装
- 至少 2GB RAM
- 至少 5GB 可用磁盘空间
- 稳定的网络连接

**注意：** 如果系统中没有 Node.js，安装脚本会提供安装指引或自动安装选项。

## 快速开始

### 安装

```bash
# 克隆项目
git clone https://github.com/OuterCloud/hahaclaw.git
cd hahaclaw

# macOS 用户
./openclaw.sh install

# Windows 用户 (以管理员身份运行)
openclaw.bat install
```

### 配置

安装完成后，脚本会引导你配置阿里云百炼 API Key（推荐）：

**获取百炼 API Key：**

1. 访问 [阿里云百炼控制台](https://bailian.console.aliyun.com/)
2. 开通百炼服务（新用户有免费额度）
3. 在 [API Key 管理页面](https://bailian.console.aliyun.com/#/api-key) 创建密钥

**配置步骤：**

安装脚本会自动询问并配置百炼 API Key，包括：

- 输入 API Key
- 选择服务地域（华北 2/新加坡/美国）
- 自动生成配置文件 `~/.openclaw/openclaw.json`

如果跳过了配置，也可以稍后手动配置：

```bash
openclaw dashboard
# 在 Web 界面中: Settings -> Raw -> 编辑配置
```

**其他 LLM Provider：**

如果不使用百炼，也可以配置其他 Provider：

- Anthropic Claude
- OpenAI GPT
- Google Gemini
- 本地 Ollama

详见 [配置文档](docs/CONFIGURATION.md)。

### 启动

配置完成后，可以通过以下方式使用 OpenClaw：

**命令行对话：**

```bash
openclaw tui
```

**Web 控制面板：**

```bash
openclaw dashboard
# 浏览器会自动打开 http://127.0.0.1:18789
```

**连接消息平台（可选）：**

如需通过 Telegram、飞书、钉钉等平台使用，请参考：

- [飞书集成配置](docs/FEISHU_SETUP.md) - 支持一键自动化配置
- [其他平台配置](https://openclaw.ai/docs/channels)

**快速配置飞书：**

```bash
# macOS
./openclaw.sh configure-feishu

# Windows
openclaw.bat configure-feishu
```

- [飞书集成指南](docs/FEISHU_SETUP.md)（推荐国内用户）
- [Telegram Bot 配置](https://core.telegram.org/bots#6-botfather)
- [钉钉集成指南](https://help.aliyun.com/zh/model-studio/use-cases/build-an-ai-employee-solution-based-on-clawdbot-in-4-steps)

- [Telegram Bot 配置](https://core.telegram.org/bots#6-botfather)
- [钉钉集成指南](https://help.aliyun.com/zh/model-studio/use-cases/build-an-ai-employee-solution-based-on-clawdbot-in-4-steps)

## 文档

- [使用指南](docs/USAGE.md) - 详细的命令使用说明
- [配置说明](docs/CONFIGURATION.md) - 配置文件详解
- [飞书集成](docs/FEISHU_SETUP.md) - 飞书机器人配置指南
- [故障排查](docs/TROUBLESHOOTING.md) - 常见问题解决方案
- [常见问题](docs/FAQ.md) - 安装、配置、使用的常见问题
- [项目结构](docs/PROJECT_STRUCTURE.md) - 项目目录结构说明

## 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Merge Request

## 开发路线

- [x] macOS 自动化安装脚本
- [x] Windows 自动化安装脚本
- [x] 配置文件管理
- [x] 智能更新功能
- [x] 阿里云百炼集成
- [ ] Docker 部署支持
- [ ] 自动备份功能
- [ ] Web 管理界面
- [ ] 批量部署工具

## 相关链接

- [OpenClaw 官网](https://openclaw.ai/)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [OpenClaw 文档](https://openclaw.ai/docs)
- [技能市场](https://clawhub.com/)
- [阿里云百炼](https://bailian.console.aliyun.com/)
- [百炼 OpenClaw 配置文档](https://help.aliyun.com/zh/model-studio/openclaw)

## 为什么选择阿里云百炼？

- ✅ 性价比高：相比国际 LLM 服务更实惠
- ✅ 新用户福利：免费额度，90 天有效期
- ✅ 多模型支持：千问 Max、千问 Plus、千问 Flash、DeepSeek、Kimi 等
- ✅ 国内访问快：无需代理，低延迟
- ✅ 套餐优惠：Coding Plan 固定月费，AI 通用型节省计划最高 5.3 折

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

OpenClaw 本身也是 MIT 许可证的开源项目。

## 致谢

- 感谢 [Peter Steinberger](https://github.com/steipete) 创建了 OpenClaw
- 感谢所有为本项目做出贡献的开发者！
