#!/bin/bash
# 自动重试推送脚本

MAX_RETRIES=30
RETRY_INTERVAL=60
RETRY_COUNT=0

cd /root/.openclaw/workspace

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "=== 尝试推送 ($((RETRY_COUNT+1))/$MAX_RETRIES) ==="
    echo "时间: $(date)"
    
    # 先测试网络
    if curl -I https://github.com --max-time 5 2>&1 | grep -q "HTTP"; then
        echo "网络正常，开始推送..."
        
        # 使用 gh 认证推送
        git remote set-url origin https://gelin-cloud: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@github.com/gelin-cloud/vios.git
        git push origin main
        
        if [ $? -eq 0 ]; then
            echo "✅ 推送成功！"
            echo "完成时间: $(date)"
            exit 0
        else
            echo "❌ 推送失败，继续重试..."
        fi
    else
        echo "网络不通，等待下次重试..."
    fi
    
    RETRY_COUNT=$((RETRY_COUNT+1))
    echo "等待 ${RETRY_INTERVAL} 秒后重试..."
    sleep $RETRY_INTERVAL
done

echo "❌ 达到最大重试次数，推送失败"
exit 1
