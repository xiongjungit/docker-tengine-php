# 简介

Tengine是由淘宝网发起的Web服务器项目。它在Nginx的基础上，针对大访问量网站的需求，添加了很多高级功能和特性。Tengine的性能和稳定性已经在大型的网站如淘宝网，天猫商城等得到了很好的检验。它的最终目标是打造一个高效、稳定、安全、易用的Web平台。

从2011年12月开始，Tengine成为一个开源项目，Tengine团队在积极地开发和维护着它。Tengine团队的核心成员来自于淘宝、搜狗等互联网企业。Tengine是社区合作的成果，我们欢迎大家参与其中，贡献自己的力量。

# Tengine - PHP-fpm 

这是一个Tenginenx和php-fpm的docker镜像。

![](https://dn-daoweb-resource.qbox.me/image-icon/nginx.svg)

![](https://dn-daoweb-resource.qbox.me/image-icon/php.svg)

## 组件

* Tengine

* php

* openssh-server

## 特点:
* 所有配置文件都从`/configs`做软链接, 从而测试/优化可以挂载文件夹而不是重建图像

* 不包含mysql数据库,需要链接额外的数据库镜像。

## 使用:

建议在使用之前检查所有的配置文件


构建

```
docker build -t xman/docker-tengine-php .
```

开发
```    
docker run -i -t \
-v /Volumes/sitename/www/:/var/www \
-v /root/.ssh/authorized_keys:/root/.ssh/authorized_keys \
-v `pwd`/configs/:/configs/ \
-link mariadb:db \
-p 80:80 -p 2222:22 -p 443:443 \
xman/docker-tengine-php bash
```

正常启动

```
docker run -d \
-v /Volumes/sitename/www/:/var/www \
-v /root/.ssh/authorized_keys:/root/.ssh/authorized_keys \
-link mariadb:db \
-p 80:80 -p 2222:22 \
xman/docker-tengine-php bash
```

## 实例

* db: 

```
docker run -d -p 3306:3306 -v /data/wordpress/db:/var/lib/mysql --name mysql xman/docker-mysql
```

```
========================================================================
You can now connect to this MySQL Server using:

    mysql -uadmin -pWxfLmXP2FFwa -h<host> -P<port>

Please remember to change the above password as soon as possible!
MySQL user 'root' has no password but only allows local connections
========================================================================
```

* web:

```
docker run -d -p 80:80 -v /data/wordpress/web/wordpress/:/var/www/ --link mysql:db --name wordpress xman/docker-tengie-php
```

## 代码创建和维护

* QQ: 479608797

* 邮件: fenyunxx@163.com

* [github](https://github.com/xiongjungit/docker-tengine)

* [dockerhub](https://hub.docker.com/r/dockerxman/)





