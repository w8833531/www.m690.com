---
title: 公司一次“DDOS”过程
tags:
  - DDOS
  - 分析
id: 837
categories:
  - 游戏运维
date: 2014-11-27 09:28:39
---

> 在公司9年多，碰到过两次貌似的DDOS，但最终发现，都不是真正的DDOS。

第一次，是在2007年，我做的一款40W人在线的游戏，当时因为脱机外挂，在游戏更新后，外挂因为无法正常登录，不停尝试，直接把我们的游戏登录服务器线搞挂了。当时，以为是DDOS,但发现，连接特别多的IP地址就几十个。后来，在登录服务器前面加了一个linux防火墙，限制单个IP的登录次数，问题解决了。

这次，更像是DDOS。因为通过在前台IIS WEB前面加了一台nginx转发服务器，统计出来的访问日志IP，90%都是不同的，而后台的IIS WEB上每个都有5000个以上的ESTABLISH 连接，网站已经无法正常打开。说明一下，这个网站是一个手机APP应用网站。

分析了一下，前台nginx 的中访问日志：
1、发现所有访问链接都是正常的，而且基本没有重复。
2、每秒的访问量大概在120个左右，不是非常高。
3、统计出来的访问日志IP中，重复超过100个的数量占总的访问数量不到10%。
4、甚至，访问过来的client端agent名字也是我们手机APP中定义的名字。
    从上面几点来看，如果真的是DDOS攻击的话，这个攻击者准备是非常充分的，因为使用了各种真实的IP资源及真实的访问来压我们的应用，而且成本是非常之高的。而我的观点是这不是一个DDOS攻击，可能是因为一些原因，使用server端程序无法正常访问，引起手机APP在用户的后台不停的重试。
事实证明的我的猜测，真正的原因是一个应用程序的DB空间满了，引起了登录应用程序无法正常工作，使所有手机后台的APP在不停的重试登录，产生了类似的DDOS情行。扩充磁盘空间后，应用恢复，后台IIS上的连接恢复正常。

下面给一下用于前台拦截分析的nginx的配置：
<pre>
    upstream tests1 {
     server 10.10.23.111:80 weight=1;
     server 10.10.23.112:80 weight=1;
     server 10.10.23.114:80 weight=1;
#     server 127.0.0.1:8102 weight=1;
#     ip_hash;
   }

log_format  default_log_format  '$remote_addr - $remote_user [$time_local] "$request" '
                   '$status $body_bytes_sent "$http_referer" '
                                      '"$http_user_agent" "$http_x_forwarded_for" '
                                                         '"$request_time" "$connection" "$upstream_addr" "$upstream_response_time" ';
        server {
                listen 80;
                server_name api2.example.com;
                access_log /data/logs/nginx/access_log default_log_format;
                error_log /data/logs/nginx/error_log;
                root html;
                location / {
                    proxy_pass http://tests1;
                    proxy_set_header Host api2.example.com;
                }
#                location = /50x.html {
#                   root /data/nginx/html;
#                }
    }
</pre>