# UFW防火墙一键配置脚本

一个简洁而强大的UFW防火墙管理脚本，用于快速配置和管理防火墙规则，限制只有特定IP才能访问服务器的53（DNS）、80（HTTP）、443（HTTPS）端口。

## 脚本文件

### `ufw_quick_manage.sh` - 全功能UFW管理脚本
- **核心功能**：
  - 🚀 自动安装UFW（如果未安装）
  - 🛡️ 一键初始化防火墙配置
  - ➕ 快速添加/删除IP访问规则
  - 📊 规则查看和状态监控
  - 💾 规则备份功能
  - 🖥️ 支持命令行和交互式两种模式
  - 🎨 彩色输出和详细日志

## 使用方法

### 首次初始化

```bash
# 一键初始化防火墙配置
sudo ./ufw_quick_manage.sh init
```

或者使用交互式菜单：
```bash
sudo ./ufw_quick_manage.sh
# 然后选择选项 1: 初始化UFW防火墙
```

初始化过程将：
1. 自动安装UFW（如果未安装）
2. 询问是否重置现有规则
3. 输入允许访问的IP地址
4. 配置基础防火墙规则
5. 启用防火墙并显示状态

### 日常管理

#### 命令行模式
```bash
# 初始化防火墙（首次使用）
sudo ./ufw_quick_manage.sh init

# 添加新的IP访问权限
sudo ./ufw_quick_manage.sh add 192.168.1.100

# 移除IP访问权限
sudo ./ufw_quick_manage.sh remove 192.168.1.100

# 查看当前规则
sudo ./ufw_quick_manage.sh list

# 查看详细状态
sudo ./ufw_quick_manage.sh status

# 备份当前规则
sudo ./ufw_quick_manage.sh backup

# 显示帮助信息
sudo ./ufw_quick_manage.sh help
```

#### 交互式模式
```bash
# 启动交互式菜单
sudo ./ufw_quick_manage.sh
```

## 防火墙规则说明

配置完成后，防火墙将应用以下规则：

### 允许的连接
- **SSH端口（22）**：对所有IP开放（防止管理员被锁定）
- **DNS端口（53）**：仅允许指定IP访问
- **HTTP端口（80）**：仅允许指定IP访问
- **HTTPS端口（443）**：仅允许指定IP访问
- **本地回环接口**：允许本地通信

### 默认策略
- **入站连接**：默认拒绝
- **出站连接**：默认允许

## 安全注意事项

### ⚠️ 重要警告
1. **SSH访问**：脚本会保持SSH端口对所有IP开放，防止管理员被锁定
2. **备份配置**：在进行重大更改前，请使用备份功能保存当前规则
3. **IP地址验证**：确保输入的IP地址正确，错误的IP可能导致无法访问服务

### 🔧 故障排除
如果遇到问题，可以使用以下命令：

```bash
# 查看UFW状态
sudo ufw status verbose

# 临时禁用防火墙（紧急情况）
sudo ufw disable

# 重新启用防火墙
sudo ufw enable

# 完全重置规则（谨慎使用）
sudo ufw --force reset
```

## 常用IP格式示例

### 单个IP地址
```
192.168.1.100    # 局域网IP
203.0.113.10     # 公网IP
```

### IP地址段（CIDR格式）
```
192.168.1.0/24   # 192.168.1.1-192.168.1.254
10.0.0.0/8       # 10.0.0.1-10.255.255.254
172.16.0.0/12    # 172.16.0.1-172.31.255.254
```

## 文件说明

使用过程中会生成以下文件：

- `/root/ufw_backup_YYYYMMDD_HHMMSS.txt` - 规则备份文件（按需生成）

## 兼容性

- **支持的系统**：Ubuntu, Debian, CentOS, RHEL等主流Linux发行版
- **包管理器**：自动检测apt-get, yum, dnf
- **shell要求**：bash 4.0+

## 技术支持

如果在使用过程中遇到问题：

1. 检查系统日志：`sudo journalctl -u ufw`
2. 验证UFW服务状态：`sudo systemctl status ufw`
3. 查看详细规则：`sudo ufw status numbered`

---

**注意**：请确保在执行这些脚本前，您对防火墙规则有基本的了解，并已做好相应的访问准备工作。 