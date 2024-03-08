* https://github.com/certbot/certbot
* 基于原有镜像certbot/certbot:v2.9.0
* [由于 certbot 运行后容器就结束导致无法直接 续订证书](./Dockerfile)

## nginx 证书自动续签【certbot基于容器运行模式】

- [基于Let’s Encrypt 推荐客户端](https://letsencrypt.org/zh-cn/docs/client-options/)

* 前提是网站 80 服务正常可以访问
* 生成证书后再配置 https 配置

### 一 、nginx 直接安装在宿主机（apt/yum/ 等方式） [docker-compose yml ](./docker-compose-v2certbot.yml)

#### 1、v2certbot 服务说明

```
- ./指当前目录 ./certs ./www/html

- 环境变量
    * 如果你的服务不是默认的 HTTP（80）请设置 HTTP_PORT  环境变量
    * 默认http 端口 80 
        HTTP_PORT=80
    * 间隔多久更新一次证书默 24小时 86400s
        UPDATE_INTERVAL=86400 
    * 设置邮箱 必填 [注意**换成自己邮箱]
        LET_MAILBOX=xianhe_yan@sina.com
    * 设置签约域名 必填 [注意**换成自己域名]
        DOMAIN_NAME=yanxianhe.com
- 映射文件目录
    * letsencrypt 配置证书位于./certs/live/${DOMAIN_NAME}/fullchain.pem ./certs/live/${DOMAIN_NAME}/privkey.pem
        ./certs:/etc/letsencrypt
    * 根据自己需求配置到nginx 工作目录
        ./www/html:/var/www/html 


- 启动 v2certbot
    docker-compose -p v2certbot -f ./docker-compose-v2certbot.yml up -d
- 停止 v2certbot
    docker-compose -p v2certbot -f ./docker-compose-v2certbot.yml down
```

#### 2、v2certbot 服务验证

- 查询管理证书信息[certbot certificates]

```
~$ docker exec -it v2certbot certbot certificates
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Found the following certs:
  Certificate Name: yanxianhe.com
    Serial Number: 389689cb95876e51d0a8b917d3f4bf0bd28
    Key Type: RSA
    Domains: yanxianhe.com
    Expiry Date: 2024-05-30 09:06:12+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/yanxianhe.com/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/yanxianhe.com/privkey.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

```

#### 3、nginx 配置证书 ssl

- nginx 证书位置需要配置启动v2certbot具体位置 ./certs/live/${DOMAIN_NAME}
- fullchain.pem 对应 server.crt ; privkey.pem 对应 server.key
- 放开 443 配置证书位置

```
…… 略
    listen       443 ssl;
    ssl_certificate ./certs/live/${DOMAIN_NAME}/fullchain.pem;
    ssl_certificate_key ./certs/live/${DOMAIN_NAME}/privkey.pem;
…… 略
```

#### 4、验证nginx 配置重新加载配置

- 验证配置没有问题后重新加载nginx配置

```
sudo nginx -t # 验证配置 
sudo nginx -s reload # 重新加载配置
```

#### 5、续订证书后重新加载配置文件

* 一、利用certbot certificates 结合 crontab 定时任务[](./restart-nginx.sh)

- 续订后有效时间90天[共涵盖了 89 天和23小时] ，默认提前 10 天续订
- 利用 certbot certificates 查询VALID: 来重新加载sudo nginx -s reload
- 利用 crontab 24h 判断VALID ,新的一轮证书有效大于等于 89 则触发重新加载 nginx

* 二、利用文件sha256sum 结合 crontab 定时任务[](./restart-nginx1.sh)

- 利用 crontab 24h 判断证书sha256sum值，发生变化时则触发重新加载 nginx

### 二 、nginx v2certbot 基于容器启动[docker-compose yml ](./docker-compose-v2certbot1.yml)

#### 1、服务说明

- 使用绝对路径 /opt/

```
.
├── html                                        # web 根目录v2certbot 也需要 /opt/html 目录
│   ├── ……
├── nginx
│   ├── conf.d                                 # nginx 配置目录
│   └── letsencrypt                            # letsencrypt 配置目录
│       ├── ……
│       ├── live
│       │   └── yanxianhe.com                  # ssl 证书目录包含 fullchain privkey[crt key]
│       │   ├── README
│       │   └── yanxianhe.com
│       │       ├── cert.pem -> ../../archive/yanxianhe.com/cert1.pem
│       │       ├── chain.pem -> ../../archive/yanxianhe.com/chain1.pem
│       │       ├── fullchain.pem -> ../../archive/yanxianhe.com/fullchain1.pem
│       │       ├── privkey.pem -> ../../archive/yanxianhe.com/privkey1.pem
│       │       └── README
│       ├── ……




- 启动 nginx v2certbot
    docker-compose -p nginx -f ./docker-compose-v2certbot1.yml up -d
- 停止 nginx v2certbot
    docker-compose -p nginx -f ./docker-compose-v2certbot1.yml down
```

#### 2、v2certbot 服务验证

- 查询管理证书信息[certbot certificates]

```
~$ docker exec -it v2certbot certbot certificates
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Found the following certs:
  Certificate Name: yanxianhe.com
    Serial Number: 389689cb95876e51d0a8b917d3f4bf0bd28
    Key Type: RSA
    Domains: yanxianhe.com
    Expiry Date: 2024-05-30 09:06:12+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/yanxianhe.com/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/yanxianhe.com/privkey.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

```

#### 3、nginx 配置证书 ssl

- nginx 证书位置需要配置启动v2certbot具体位置 ./certs/live/${DOMAIN_NAME}
- fullchain.pem 对应 server.crt ; privkey.pem 对应 server.key
- 放开 443 配置证书位置

```
…… 略
    listen       443 ssl;
    ssl_certificate /etc/ssl/certs/server.crt;
    ssl_certificate_key /etc/ssl/private/server.key;
…… 略
```

#### 4、验证nginx 配置重新加载配置

- 验证配置没有问题后重新加载nginx配置

```
docker exec -it nginx nginx -t # 验证配置 
docker exec -it nginx nginx -s reload # 重新加载配置
```

#### 5、续订证书后重新加载配置文件

* 一、利用certbot certificates 结合 crontab 定时任务[](./restart-nginx.sh)

- 续订后有效时间90天[共涵盖了 89 天和23小时] ，默认提前 10 天续订
- 利用 certbot certificates 查询VALID: 来重新加载[sudo nginx -s reload 换成  docker exec -it nginx nginx -s reload]
- 利用 crontab 24h 判断VALID ,新的一轮证书有效大于等于 89 则触发重新加载 nginx

* 二、利用文件sha256sum 结合 crontab 定时任务[](./restart-nginx1.sh)

- 利用 crontab 24h 判断证书sha256sum值，发生变化时则触发重新加载[ nginx  sudo nginx -s reload 换成  docker exec -it nginx nginx -s reload]

### 三、crontab 根据需要自行设置

- 例：设置每日0点 检查校验 nginx 证书
- chmod a+x /opt/restart-nginx.sh

```
0 0 * * * sh /opt/restart-nginx.sh
```
