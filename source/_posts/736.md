---
title: 继续代理--使用squid 反向代理https出去
tags:
  - https
  - proxy
  - secure
  - squid
  - windows
id: 736
categories:
  - linux
  - 技术
date: 2014-07-21 17:08:16
---

> 好吧，我们继续聊代理，今天讲的代理不是用来(传强）用的，今天用的代理于线上环境的：如果你有很多windows 线上服务器，我们知道，线上windows服务器外网可以直接对外访问公网，从安全的角度来说，是有风险的。可以用一台linux反向代理来代理所以这些windows机器对公网的访问。这样的好处是：1 windows机器不能直接访问公网，要统一通过一台linux上squid代理出去。2对外访问的域名是可以在squid的反向代理上配置来控制的。这样，所有windows机器的对外访问，都受一~二台linux的squid反向代理来控制，安全上面要好很多。即使因为系统管理员因不小心上传或运行了木马，中的木马windows机器也无法直接通过外网连出去，因为**<span style="color: #0000ff;">服务器直接访问公网是在防火墙上被禁止的</span>**。如果因业务需要，windows服务器要访问共网的某个域名的http或https端口，就可以通过下面的squid 反向proxy来实现，控制粒度是访问的域名。
为了更好好说明squid反向代理的使用，我们给张图吧：
[![Squid实现https及https的反向代理](http://www.m690.com/wp-content/uploads/2014/07/Squid实现https及https的反向代理.jpg)](http://www.m690.com/wp-content/uploads/2014/07/Squid实现https及https的反向代理.jpg)

下面给一下squid.config的配置，安装的话，直接用yum进行默认安装就可以了,**<span style="color: #0000ff;">我这边使用的squid 2.6,其它版本的Squid配置可能会有一些不同</span>：**
<pre class="blush: php">[root@lvs02 squid]# cat /etc/squid/squid.conf
access_log /var/log/squid/access.log
acl all src 0.0.0.0/0.0.0.0
###inner ipaddress 
acl in src 10.127.24.0/255.255.255.0 10.127.58.0/255.255.255.0

http_port 80 vhost
https_port 443 cert=/etc/squid/server.crt key=/etc/squid/server.key vhost
http_access allow in 
cache deny all

### open.t.qq.com for in port 443 &amp; 80
cache_peer open.t.qq.com parent 443 0 proxy-only no-query originserver weight=1 login=PASS ssl sslflags=DONT_VERIFY_PEER name=open.t.qq.com_443
cache_peer_domain open.t.qq.com_443 open.t.qq.com
cache_peer_access open.t.qq.com_443 allow in

cache_peer open.t.qq.com parent 80 0 proxy-only no-query originserver weight=1 login=PASS name=open.t.qq.com_80
cache_peer_domain open.t.qq.com_80 open.t.qq.com
cache_peer_access open.t.qq.com_80 allow in

### api.weibo.com for in port 443 &amp; 80
cache_peer api.weibo.com parent 443 0 proxy-only no-query originserver weight=1 login=PASS ssl sslflags=DONT_VERIFY_PEER name=api.weibo.com_443
cache_peer_domain api.weibo.com_443 api.weibo.com
cache_peer_access api.weibo.com_443 allow in

cache_peer api.weibo.com parent 80 0 proxy-only no-query originserver weight=1 login=PASS name=api.weibo.com_80
cache_peer_domain api.weibo.com_80 api.weibo.com
cache_peer_access api.weibo.com_80 allow in

### api.weixin.qq.com for in port 443 &amp; 80
cache_peer api.weixin.qq.com parent 443 0 proxy-only no-query originserver weight=1 login=PASS ssl sslflags=DONT_VERIFY_PEER name=api.weixin.qq.com_443
cache_peer_domain api.weixin.qq.com_443 api.weixin.qq.com
cache_peer_access api.weixin.qq.com_443 allow in

cache_peer api.weixin.qq.com parent 80 0 proxy-only no-query originserver weight=1 login=PASS name=api.weixin.qq.com_80
cache_peer_domain api.weixin.qq.com_80 api.weixin.qq.com
cache_peer_access api.weixin.qq.com_80 allow in
[root@lvs02 squid]#</pre>