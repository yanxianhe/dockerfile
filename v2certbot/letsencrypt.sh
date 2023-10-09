#!/bin/bash
set -x
if [ -z ${UPDATE_INTERVAL} ] ;then
    UPDATE_INTERVAL=86400
fi
FLG_UPDATE=true
while :
do
    while true; do
        if [ -z ${LET_MAILBOX} ]||[ -z ${DOMAIN_NAME} ];then
            echo "Please set the environment variable LET_ MAILBOX DOMAIN_ NAME LET_ MAILBOX Your email, DOMAIN_ NAME Your domain name"
            sleep 5
            break
        else
            if [ ${FLG_UPDATE} == true ];then
                certbot certonly --webroot --webroot-path=/etc/letsencrypt/www --email ${LET_MAILBOX} --agree-tos --no-eff-email --force-renewal -d ${DOMAIN_NAME}
                echo "certonly --webroot ok"
                FLG_UPDATE=false
		break
            else
                while :
                do
                    certbot renew --webroot --webroot-path=/etc/letsencrypt/www
                    echo "certbot renew --webroot ok"
                    sleep ${UPDATE_INTERVAL}
                done
            fi
        fi
    done
done
