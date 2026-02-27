# 飞书集成配置指南

本文档详细说明如何将 OpenClaw 连接到飞书（Lark），让你可以在飞书中直接与 AI 助手对话。

## 为什么选择飞书？

- ✅ 国内企业广泛使用的协作平台
- ✅ 无需公网 IP，使用 WebSocket 长连接
- ✅ 支持群聊和私聊
- ✅ 丰富的消息类型（文本、图片、文件等）
- ✅ 完善的权限管理

## 前置要求

1. **OpenClaw 已安装**

   ```bash
   openclaw --version
   ```

2. **飞书企业账号**

   - 需要有创建应用的权限
   - 访问 [飞书开放平台](https://open.feishu.cn/)

3. **已配置 LLM Provider**
   - 推荐使用阿里云百炼
   - 或其他支持的 Provider

## 配置步骤

### 快速开始：自动化配置（推荐）

我们提供了自动化配置脚本，可以快速完成 OpenClaw 与飞书的集成配置。

**使用方法：**

```bash
# macOS
./openclaw.sh configure-feishu

# Windows
openclaw.bat configure-feishu
```

**自动化脚本会：**

1. ✅ 自动安装飞书插件
2. ✅ 引导输入飞书应用信息
3. ✅ 配置访问控制策略
4. ✅ 自动更新配置文件
5. ✅ 重启 Gateway 使配置生效

**前置要求：**

在运行自动化脚本之前，你需要先在飞书开放平台完成以下步骤：

1. 创建企业自建应用
2. 配置应用权限
3. 启用机器人能力
4. 配置事件订阅
5. 发布应用

详细步骤请参考下面的「手动配置步骤」。

---

### 手动配置步骤

如果你希望手动配置或需要了解详细步骤，请按照以下指引操作。

### 第一步：安装飞书插件

```bash
openclaw plugins install @openclaw/feishu
```

验证安装：

```bash
openclaw plugins list
```

### 第二步：创建飞书应用

#### 1. 登录飞书开放平台

访问 [https://open.feishu.cn/](https://open.feishu.cn/)，使用飞书账号登录。

#### 2. 创建企业自建应用

- 点击「创建企业自建应用」
- 填写应用名称（如：AI 助手）
- 填写应用描述
- 选择应用图标
- 点击「创建」

#### 3. 获取凭证信息

在「凭证与基础信息」页面，复制：

- **App ID**（格式：`cli_xxx`）
- **App Secret**

**快速访问链接：** [https://open.feishu.cn/app](https://open.feishu.cn/app)

**操作步骤：**

1. 在应用列表中找到你创建的应用
2. 点击进入应用详情
3. 左侧菜单选择「凭证与基础信息」
4. 复制 App ID（直接显示）
5. 点击 App Secret 旁的「查看」按钮，复制密钥

**重要：** 妥善保管 App Secret，不要泄露！如果不慎泄露，可以在此页面重置密钥。

#### 4. 配置权限

在「权限管理」页面，点击「批量导入」，粘贴以下 JSON：

```json
{
  "scopes": {
    "tenant": [
      "aily:file:read",
      "aily:file:write",
      "application:application.app_message_stats.overview:readonly",
      "application:application:self_manage",
      "application:bot.menu:write",
      "cardkit:card:write",
      "contact:contact.base:readonly",
      "contact:user.employee_id:readonly",
      "corehr:file:download",
      "docs:document.content:read",
      "event:ip_list",
      "im:chat",
      "im:chat.access_event.bot_p2p_chat:read",
      "im:chat.members:bot_access",
      "im:message",
      "im:message.group_at_msg:readonly",
      "im:message.group_msg",
      "im:message.p2p_msg:readonly",
      "im:message:readonly",
      "im:message:send_as_bot",
      "im:resource",
      "sheets:spreadsheet",
      "wiki:wiki:readonly"
    ],
    "user": [
      "aily:file:read",
      "aily:file:write",
      "im:chat.access_event.bot_p2p_chat:read"
    ]
  }
}
```

点击「确定」导入权限。

#### 5. 启用机器人能力

- 在左侧菜单找到「应用能力」
- 找到「机器人」卡片
- 将菜单状态切换为「已启用」
- 填写机器人名称和描述（用户会看到这些信息）

#### 6. 配置事件订阅

在「事件订阅」页面：

- 选择「使用长连接接收事件」（WebSocket 模式）
- 添加事件：`im.message.receive_v1`（接收消息）

#### 7. 发布应用

- 进入「版本管理与发布」
- 创建版本
- 提交审核并发布
- 企业自建应用通常会自动通过审核

### 第三步：配置 OpenClaw

有两种配置方式：

#### 方式一：使用命令行（推荐）

```bash
openclaw configure channels
```

选择 Feishu，然后输入：

- App ID
- App Secret
- Bot Name（可选）

#### 方式二：手动编辑配置文件

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "plugins": {
    "entries": {
      "feishu": {
        "enabled": true
      }
    }
  },
  "channels": {
    "feishu": {
      "enabled": true,
      "dmPolicy": "pairing",
      "accounts": {
        "main": {
          "appId": "cli_xxx",
          "appSecret": "your-app-secret",
          "botName": "AI 助手"
        }
      }
    }
  }
}
```

**配置说明：**

- `dmPolicy: "pairing"` - 私聊需要配对（推荐，更安全）
- `dmPolicy: "open"` - 私聊开放给所有人
- `groupPolicy: "open"` - 群聊开放（默认需要 @机器人）
- `requireMention: true` - 群聊中需要 @机器人才响应

### 第四步：重启 Gateway

```bash
openclaw gateway restart
```

验证配置：

```bash
openclaw gateway status
```

### 第五步：配对机器人

#### 1. 在飞书中找到机器人

- 打开飞书
- 搜索你创建的机器人名称
- 开始对话

#### 2. 获取配对码

向机器人发送任意消息，它会返回一个配对码（如果 `dmPolicy` 设置为 `pairing`）。

#### 3. 完成配对

在终端中运行：

```bash
openclaw pairing approve feishu <配对码>
```

#### 4. 测试连接

配对完成后，在飞书中向机器人发送：

```
你好，请介绍一下自己
```

如果收到 AI 回复，说明配置成功！

## 访问控制

### 私聊访问控制

**配对模式（推荐）：**

```json
"dmPolicy": "pairing"
```

- 未知用户会收到配对码
- 管理员需要批准：`openclaw pairing approve feishu <CODE>`

**开放模式：**

```json
"dmPolicy": "open"
```

- 所有用户都可以直接使用

**白名单模式：**

```json
"dmPolicy": "allowlist",
"allowFrom": ["ou_xxx", "ou_yyy"]
```

- 只允许指定的用户 Open ID

### 群聊访问控制

**开放模式（默认）：**

```json
"groupPolicy": "open",
"requireMention": true
```

- 群内所有人都可以使用
- 需要 @机器人 才会响应

**白名单模式：**

```json
"groupPolicy": "allowlist",
"groupAllowFrom": ["ou_xxx", "ou_yyy"]
```

- 只允许白名单内的用户在群聊中使用

**禁用群聊：**

```json
"groupPolicy": "disabled"
```

## 常用命令

```bash
# 查看 Gateway 状态
openclaw gateway status

# 重启 Gateway
openclaw gateway restart

# 查看实时日志
openclaw logs --follow

# 查看待配对请求
openclaw pairing list feishu

# 批准配对
openclaw pairing approve feishu <CODE>

# 查看已安装插件
openclaw plugins list

# 查看频道状态
openclaw status
```

## 故障排查

### 问题 1：机器人不响应

**可能原因：**

1. 应用未发布或未通过审核
2. 事件订阅未配置
3. WebSocket 连接断开
4. Gateway 服务未运行

**解决方案：**

**步骤 1：检查 Gateway 状态**

```bash
openclaw gateway status
```

如果显示 `Gateway service not loaded`，需要安装并启动：

```bash
openclaw gateway install
openclaw gateway start
```

**步骤 2：检查飞书频道状态**

```bash
openclaw status | grep -i feishu
```

应该显示：`Feishu | ON | OK | configured`

**步骤 3：查看实时日志**

```bash
tail -f ~/.openclaw/logs/gateway.log | grep -i "feishu\|message\|event"
```

然后在飞书中发送消息，观察日志输出。

**步骤 4：检查 WebSocket 连接**

日志中应该看到：

```
feishu[main]: WebSocket client started
```

如果没有，检查飞书应用的事件订阅配置：

- 必须选择 **"使用长连接接收事件"**（WebSocket 模式）
- 必须添加事件：`im.message.receive_v1`

**步骤 5：运行系统诊断**

```bash
openclaw doctor
```

如果有配置问题，运行：

```bash
openclaw doctor --fix
```

**步骤 6：重启 Gateway**

```bash
openclaw gateway stop
openclaw gateway start
```

等待 3-5 秒让服务完全启动，然后再测试。

### 问题 2：群聊中机器人不响应

**可能原因：**

1. 未 @机器人
2. `groupPolicy` 设置为 `disabled`
3. 用户不在白名单中
4. Gateway 服务未正常运行

**解决方案：**

**检查配置：**

```bash
cat ~/.openclaw/openclaw.json | grep -A 10 '"feishu"'
```

确认：

- `groupPolicy` 不是 `disabled`
- `requireMention` 为 `true`（需要 @机器人）

**测试步骤：**

1. 在群聊中 @机器人 发送消息
2. 查看实时日志：
   ```bash
   tail -f ~/.openclaw/logs/gateway.log | grep -i "feishu\|message"
   ```
3. 如果日志中没有收到消息，检查飞书应用的事件订阅配置

**常见问题：**

- **只 @了机器人但没有文字**：需要在 @机器人 后面加上消息内容
- **机器人不在群里**：需要先将机器人添加到群聊
- **权限不足**：检查机器人是否有群聊权限

### 问题 3：配对失败

**可能原因：**

1. 配对码输入错误
2. 配对码已过期
3. 使用了 `open` 模式（不需要配对）

**解决方案：**

**检查访问策略：**

```bash
cat ~/.openclaw/openclaw.json | grep -A 3 '"dmPolicy"'
```

- 如果是 `"dmPolicy": "open"`，不需要配对，直接发送消息即可
- 如果是 `"dmPolicy": "pairing"`，需要配对

**配对流程（仅 pairing 模式）：**

```bash
# 1. 查看待配对列表
openclaw pairing list feishu

# 2. 如果列表为空，在飞书中重新发送消息获取新的配对码

# 3. 批准配对
openclaw pairing approve feishu <配对码>
```

**注意：** 配对码有时效性，如果过期需要重新获取。

### 问题 4：App Secret 泄露

**解决方案：**

1. 在飞书开放平台重置 App Secret
2. 更新 OpenClaw 配置
3. 重启 Gateway

### 问题 5：权限不足

**可能原因：**

- 缺少必要的 API 权限

**解决方案：**

1. 检查「权限管理」页面
2. 确保导入了所有必需权限
3. 重新发布应用

## 高级配置

### 多账号配置

可以配置多个飞书机器人：

```json
"channels": {
  "feishu": {
    "enabled": true,
    "accounts": {
      "main": {
        "appId": "cli_xxx1",
        "appSecret": "secret1",
        "botName": "主助手"
      },
      "dev": {
        "appId": "cli_xxx2",
        "appSecret": "secret2",
        "botName": "测试助手"
      }
    }
  }
}
```

### 自定义响应行为

```json
"channels": {
  "feishu": {
    "enabled": true,
    "dmPolicy": "pairing",
    "groupPolicy": "open",
    "requireMention": true,
    "autoReply": {
      "enabled": true,
      "message": "收到，正在处理..."
    },
    "typing": {
      "enabled": true,
      "duration": 3000
    }
  }
}
```

### 环境变量配置

也可以通过环境变量配置：

```bash
export FEISHU_APP_ID="cli_xxx"
export FEISHU_APP_SECRET="your-secret"
export FEISHU_BOT_NAME="AI 助手"
```

## 最佳实践

1. **安全性**

   - 使用配对模式（`dmPolicy: "pairing"`）
   - 定期轮换 App Secret
   - 限制权限范围

2. **性能优化**

   - 合理设置速率限制
   - 使用缓存减少 API 调用
   - 监控日志及时发现问题

3. **用户体验**

   - 设置清晰的机器人名称和描述
   - 提供使用说明
   - 及时响应用户消息

4. **监控维护**
   - 定期检查 Gateway 状态
   - 查看日志发现异常
   - 及时更新 OpenClaw 版本

## 相关资源

- [飞书开放平台](https://open.feishu.cn/)
- [飞书 API 文档](https://open.feishu.cn/document/)
- [OpenClaw 官方文档](https://openclaw.ai/)
- [飞书插件 GitHub](https://github.com/openclaw/openclaw)

## 获取帮助

如果遇到问题：

1. 查看 [故障排查文档](TROUBLESHOOTING.md)
2. 查看 [常见问题](FAQ.md)
