# 配置说明

## 配置文件位置

配置文件位于项目根目录：`config.yml`

## 配置项说明

### 基础配置

#### install_path

- 类型：字符串
- 默认值：`./openclaw`
- 说明：OpenClaw 的安装路径，支持相对路径和绝对路径

#### port

- 类型：整数
- 默认值：`8080`
- 说明：服务监听端口号

#### log_level

- 类型：字符串
- 可选值：`DEBUG`, `INFO`, `WARNING`, `ERROR`
- 默认值：`INFO`
- 说明：日志输出级别

#### openclaw_version

- 类型：字符串
- 默认值：`latest`
- 说明：要安装的 OpenClaw 版本

### 目录配置

#### data_dir

- 类型：字符串
- 默认值：`./data`
- 说明：数据文件存储目录

#### log_dir

- 类型：字符串
- 默认值：`./logs`
- 说明：日志文件存储目录

### 网络配置

#### network.host

- 类型：字符串
- 默认值：`0.0.0.0`
- 说明：服务绑定的主机地址

#### network.timeout

- 类型：整数
- 默认值：`30`
- 说明：网络请求超时时间（秒）

### 数据库配置

#### database.type

- 类型：字符串
- 默认值：`sqlite`
- 说明：数据库类型

#### database.path

- 类型：字符串
- 默认值：`./data/openclaw.db`
- 说明：数据库文件路径（SQLite）

### 自定义配置

#### custom.max_workers

- 类型：整数
- 默认值：`4`
- 说明：最大工作线程数

#### custom.cache_size

- 类型：整数
- 默认值：`1024`
- 说明：缓存大小（MB）

#### auto_update

- 类型：布尔值
- 默认值：`false`
- 说明：是否启用自动更新

## 配置示例

### 开发环境配置

```yaml
install_path: ./openclaw
port: 8080
log_level: DEBUG
openclaw_version: latest
data_dir: ./data
log_dir: ./logs
auto_update: true

network:
  host: 127.0.0.1
  timeout: 30

database:
  type: sqlite
  path: ./data/openclaw.db

custom:
  max_workers: 2
  cache_size: 512
```

### 生产环境配置

```yaml
install_path: /opt/openclaw
port: 80
log_level: WARNING
openclaw_version: v1.0.0
data_dir: /var/lib/openclaw
log_dir: /var/log/openclaw
auto_update: false

network:
  host: 0.0.0.0
  timeout: 60

database:
  type: sqlite
  path: /var/lib/openclaw/openclaw.db

custom:
  max_workers: 8
  cache_size: 2048
```

## 修改配置

修改配置后需要重启服务才能生效：

```bash
# macOS
./openclaw.sh stop
./openclaw.sh start

# Windows
openclaw.bat stop
openclaw.bat start
```

## 注意事项

1. 修改 `install_path` 后需要重新运行安装脚本
2. 修改 `port` 需确保端口未被占用
3. 路径配置支持相对路径（相对于项目根目录）和绝对路径
4. 修改数据库配置可能导致数据丢失，请谨慎操作
