#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 显示使用帮助
show_usage() {
    echo -e "${BLUE}用法: $0 <原IP地址> <新IP地址>${NC}"
    echo -e "${BLUE}示例: $0 8.8.8.8 1.1.1.1${NC}"
    echo -e "${BLUE}说明: 将 /var/run/dnsmasq/resolv.conf 文件中的原IP地址替换为新IP地址${NC}"
}

# 验证IP地址格式
validate_ip() {
    local ip=$1
    local regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
    
    if [[ ! $ip =~ $regex ]]; then
        return 1
    fi
    
    # 检查每个数字是否在0-255范围内
    IFS='.' read -ra parts <<< "$ip"
    for part in "${parts[@]}"; do
        if [[ $part -lt 0 ]] || [[ $part -gt 255 ]]; then
            return 1
        fi
        # 检查是否有前导零
        if [[ ${#part} -gt 1 ]] && [[ $part =~ ^0 ]]; then
            return 1
        fi
    done
    
    return 0
}

# 检查参数数量
if [ $# -ne 2 ]; then
    print_message $RED "[错误] 参数数量不正确！"
    show_usage
    exit 1
fi

# 获取参数
old_ip=$1
new_ip=$2

# 验证IP地址格式
if ! validate_ip "$old_ip"; then
    print_message $RED "[错误] 原IP地址格式不正确: $old_ip"
    show_usage
    exit 1
fi

if ! validate_ip "$new_ip"; then
    print_message $RED "[错误] 新IP地址格式不正确: $new_ip"
    show_usage
    exit 1
fi

# 定义目标文件
resolv_file="/var/run/dnsmasq/resolv.conf"

# 检查文件是否存在
if [ ! -f "$resolv_file" ]; then
    print_message $RED "[错误] 文件不存在: $resolv_file"
    exit 1
fi

# 检查文件是否可读
if [ ! -r "$resolv_file" ]; then
    print_message $RED "[错误] 文件无法读取: $resolv_file"
    exit 1
fi

# 检查文件是否可写
if [ ! -w "$resolv_file" ]; then
    print_message $RED "[错误] 文件无法写入: $resolv_file"
    print_message $YELLOW "[提示] 请使用 sudo 运行此脚本"
    exit 1
fi

# 检查原IP是否存在于文件中
if ! grep -q "$old_ip" "$resolv_file"; then
    print_message $YELLOW "[警告] 在文件中未找到原IP地址: $old_ip"
    print_message $BLUE "[信息] 当前文件内容:"
    cat "$resolv_file"
    exit 0
fi

# 创建备份文件
backup_file="${resolv_file}.backup.$(date +%Y%m%d_%H%M%S)"
if ! cp "$resolv_file" "$backup_file"; then
    print_message $RED "[错误] 无法创建备份文件: $backup_file"
    exit 1
fi

print_message $GREEN "[成功] 已创建备份文件: $backup_file"

# 显示替换前的内容
print_message $BLUE "[信息] 替换前的文件内容:"
cat "$resolv_file"

# 执行替换操作
if sed -i "s/$old_ip/$new_ip/g" "$resolv_file"; then
    print_message $GREEN "[成功] IP地址替换完成！"
    print_message $BLUE "[信息] 已将 $old_ip 替换为 $new_ip"
else
    print_message $RED "[错误] IP地址替换失败！"
    # 如果替换失败，尝试恢复备份
    if cp "$backup_file" "$resolv_file"; then
        print_message $GREEN "[成功] 已从备份恢复原文件"
    else
        print_message $RED "[错误] 无法恢复备份文件！"
    fi
    exit 1
fi

# 显示替换后的内容
print_message $BLUE "[信息] 替换后的文件内容:"
cat "$resolv_file"

# 检查dnsmasq服务状态并重启
if systemctl is-active --quiet dnsmasq; then
    print_message $BLUE "[信息] 正在重启 dnsmasq 服务..."
    if systemctl restart dnsmasq; then
        print_message $GREEN "[成功] dnsmasq 服务重启成功"
    else
        print_message $YELLOW "[警告] dnsmasq 服务重启失败，请手动检查"
    fi
else
    print_message $YELLOW "[警告] dnsmasq 服务未运行，跳过重启"
fi

# 记录操作日志
log_file="/tmp/replace_resolv_ip.log"
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$timestamp] 将 $old_ip 替换为 $new_ip，备份文件: $backup_file" >> "$log_file"

print_message $GREEN "[完成] 操作已完成！"
print_message $BLUE "[信息] 操作日志已记录到: $log_file" 