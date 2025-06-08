#!/bin/bash

# 域名提取脚本
# 从tmp目录中的所有文件提取域名，去重后保存到my-proxy-domains.txt

OUTPUT_FILE="my-proxy-domains.txt"
TMP_FILE="/tmp/all_domains.tmp"

echo "开始提取域名..."

# 清空临时文件
> "$TMP_FILE"

# 处理tmp目录中的所有文件
for file in tmp/*; do
    if [ -f "$file" ]; then
        echo "正在处理文件: $file"
        
        # 从文件中提取域名
        # 使用grep和正则表达式匹配域名格式
        grep -oE '[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)+' "$file" | \
        grep -v '^[0-9]*$' | \
        grep -E '\.[a-zA-Z]{2,}' >> "$TMP_FILE" 2>/dev/null
        
        # 也处理每行作为单独域名的情况（针对nfdns.top.txt这样的文件）
        while IFS= read -r line; do
            # 跳过空行和注释行
            [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
            
            # 检查是否为有效域名格式
            if [[ "$line" =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)+$ ]]; then
                echo "$line" >> "$TMP_FILE"
            fi
        done < "$file"
    fi
done

# 去重、排序并保存到输出文件
sort "$TMP_FILE" | uniq > "$OUTPUT_FILE"

# 清理临时文件
rm -f "$TMP_FILE"

# 统计结果
DOMAIN_COUNT=$(wc -l < "$OUTPUT_FILE")
echo "总共提取了 $DOMAIN_COUNT 个唯一域名"
echo "域名已保存到: $OUTPUT_FILE"

# 显示前10个域名作为示例
echo ""
echo "前10个域名示例:"
head -10 "$OUTPUT_FILE" | nl

echo ""
echo "提取完成！" 