# 飞书集成快速开始

5 分钟完成 OpenClaw 与飞书的集成配置。

## 第一步：创建飞书应用（5 分钟）

### 1. 登录飞书开放平台

访问 [https://open.feishu.cn/](https://open.feishu.cn/)

### 2. 创建应用

- 点击「创建企业自建应用」
- 填写应用名称：AI 助手
- 上传应用图标
- 点击「创建」

**提示：** 创建后会自动跳转到应用详情页面。

### 3. 配置权限

在「权限管理」页面，点击「批量导入」，粘贴以下 JSON：

<details>
<summary>点击展开权限配置 JSON</summary>

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

</details>

### 4. 启用机器人

- 在「应用能力」中找到「机器人」
- 切换为「已启用」
- 填写机器人名称和描述

### 5. 配置事件订阅

- 在「事件订阅」页面
- 选择「使用长连接接收事件」
- 添加事件：`im.message.receive_v1`

### 6. 发布应用

- 进入「版本管理与发布」
- 创建版本并发布
- 企业自建应用通常自动通过审核

### 7. 获取凭证

在「凭证与基础信息」页面，复制：

- **App ID**（格式：cli_xxx）
- **App Secret**

**快速访问：** [https://open.feishu.cn/app](https://open.feishu.cn/app) → 选择你的应用 → 凭证与基础信息

**位置说明：**

1. 打开飞书开放平台：https://open.feishu.cn/app
2. 在应用列表中点击你创建的应用
3. 左侧菜单找到「凭证与基础信息」
4. 在页面中可以看到：
   - App ID：以 `cli_` 开头的字符串
   - App Secret：点击「查看」按钮显示

**提示：** 妥善保管 App Secret，不要泄露！如果泄露，可以在此页面重置。

## 第二步：运行自动化配置（1 分钟）

```bash
# macOS
./openclaw.sh configure-feishu

# Windows
openclaw.bat configure-feishu
```

按照提示输入：

1. App ID
2. App Secret
3. 机器人名称（可选）
4. 选择访问策略（推荐：配对模式）

脚本会自动：

- ✅ 安装飞书插件
- ✅ 更新配置文件
- ✅ 重启 Gateway

## 第三步：配对机器人（1 分钟）

### 1. 在飞书中找到机器人

- 打开飞书
- 搜索你的机器人名称
- 开始对话

### 2. 获取配对码

向机器人发送任意消息，会收到配对码。

### 3. 批准配对

在终端运行：

```bash
openclaw pairing approve feishu <配对码>
```

### 4. 测试

在飞书中向机器人发送：

```
你好，请介绍一下自己
```

收到 AI 回复即配置成功！

## 常见问题

### Q: 机器人不响应？

**检查清单：**

```bash
# 1. 检查 Gateway 状态
openclaw gateway status

# 2. 查看日志
openclaw logs --follow

# 3. 重启 Gateway
openclaw gateway restart
```

### Q: 群聊中不响应？

确保：

- 已 @机器人
- 群聊策略设置为 `open`
- 用户有权限使用

### Q: 配对失败？

```bash
# 查看待配对列表
openclaw pairing list feishu

# 重新获取配对码（在飞书中发送新消息）
```

## 高级配置

### 修改访问策略

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "channels": {
    "feishu": {
      "dmPolicy": "pairing", // 私聊策略
      "groupPolicy": "open", // 群聊策略
      "requireMention": true // 群聊需要 @
    }
  }
}
```

修改后重启：

```bash
openclaw gateway restart
```

### 查看配对请求

```bash
openclaw pairing list feishu
```

### 批量批准配对

```bash
# 批准所有待配对请求
openclaw pairing approve-all feishu
```

## 相关文档

- [完整配置指南](FEISHU_SETUP.md)
- [使用指南](USAGE.md)
- [故障排查](TROUBLESHOOTING.md)
- [常见问题](FAQ.md)

## 获取帮助

遇到问题？

1. 查看日志：`openclaw logs --follow`
2. 运行诊断：`openclaw doctor`
