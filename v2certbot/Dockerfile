FROM certbot/certbot
LABEL maintainer "yxh <xianhe_yan@sina.com>"
WORKDIR /etc/letsencrypt/www
ADD ./letsencrypt.sh /letsencrypt.sh
RUN chmod a+x /letsencrypt.sh
