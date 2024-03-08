#!/bin/sh
set -x
# 设置默认更新间隔为一天的秒数
UPDATE_INTERVAL=${UPDATE_INTERVAL:-86400}
HTTP_PORT=${HTTP_PORT:-80}
while true; do
    # 检查必要的环境变量是否设置
    if [ -z "${LET_MAILBOX}" ] || [ -z "${DOMAIN_NAME}" ]; then
        echo "Please set the environment variables LET_MAILBOX and DOMAIN_NAME."
        sleep 5
        continue
    fi
    # 检查是否存在管理的证书，如果没有则执行首次证书申请操作
    if ! certbot certificates | grep -q "${DOMAIN_NAME}"; then
        # certbot certonly --webroot --webroot-path=/var/www/html --email "${LET_MAILBOX}" --agree-tos --no-eff-email --force-renewal -d "${DOMAIN_NAME}"
        certbot certonly --webroot --webroot-path=/var/www/html --http-01-port="${HTTP_PORT}" --email "${LET_MAILBOX}" --agree-tos --no-eff-email --force-renewal -d "${DOMAIN_NAME}"
        echo "Certbot certonly --webroot operation completed."
    else
        # 获取证书到期天数
        EXPIRY_DATE=$(certbot certificates | grep "Expiry Date" | awk '{print $6}')
        echo "Certificate for ${DOMAIN_NAME} will expire on: ${EXPIRY_DATE}"
        # 判断证书有效期，大于10天不续订，否则续订 
        # certbot renew 命令用于自动续签由 Certbot 管理的证书，而不需要重新指定之前用于创建证书的所有参数，包括验证方法、端口和路径。
        if [ $EXPIRY_DATE -le 10 ]; then
            #certbot renew --webroot --webroot-path=/var/www/html
            certbot renew --webroot --webroot-path=/var/www/html --http-01-port="${HTTP_PORT}"
            echo "Certbot renew --webroot operation completed."
        else
            echo "Certificate is still valid for more than 10 days. No renewal needed."
        fi
    fi
    sleep "${UPDATE_INTERVAL}"
done
