#!/usr/bin/env bash
set -x
# 获取证书到期天数
EXPIRY_DATE=$(docker exec -it v2certbot certbot certificates |  grep "Expiry Date" | awk '{print $6}')
# 判断证书有效期，大于89天不重新加载，否则续订
if [ $EXPIRY_DATE -ge 89 ]; then
    
    sudo nginx -s reload 
    # docker exec -it nginx nginx -s reload 
    echo "Reload with validity period greater than 89 days"
else
    echo "Certificate for ${DOMAIN_NAME} will expire on: ${EXPIRY_DATE}"
fi
