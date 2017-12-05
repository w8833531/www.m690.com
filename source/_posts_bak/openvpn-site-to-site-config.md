---
title: ｏｐｅｎ　ｖｐｎ site to site config
tags:
  - Centos6.5
  - site to site
id: 902
categories:
  - open_vpn
  - 技术
date: 2015-04-07 11:02:21
---

> 今天连夜配合美国那边架设了一个site to site 的ｏｐｅｎ ｖｐｎ。
注：因为ＧＦＷ的原因，请把ｏｐｅｎ　ｖｐｎ改成小写半角，ｙｏｕ　ｔｏｂｅ的链接也的用小写半角手动改一下，谢谢。
**系统版本：CentOS6.5**
**ｏｐｅｎ　ｖｐｎ版本： Open_VPN 2.3.2 x86_64**

**架构图（简化版）**
172.18.0.0/16(公司1内网网段）----172.18.248.125(vpnserver1),10.0.0.2(tun0)--------internet ---------10.0.0.1(tun0),172.19.0.5(vpnserver2)---- 172.19.0.0/16(公司2内网网段）

**安装**
<pre>yum install -y gcc make openssl-devel.x86_64  lzo-devel.x86_64  pam-devel.x86_64
cd ｏｐｅｎｖｐｎ-2.3.2
./configure --prefix /opt/ｏｐｅｎｖｐｎ/
make -j 4 &amp;&amp; make install</pre>
**配置**
**生成并同步key**
<pre>
ｏｐｅｎ　ｖｐｎ --genkey --secret /etc/ｏｐｅｎｖｐｎ/vpn.key
rsync -av /etc/ｏｐｅｎ　ｖｐｎ/vpn.key 172.19.0.5:/etc/ｏｐｅｎ　ｖｐｎ/vpn.key
</pre>

**VPNServer 1配置**
<pre>
[root@ｏｐｅｎ　ｖｐｎ ｏｐｅｎ　ｖｐｎ]# cat /etc/ｏｐｅｎ　ｖｐｎ/server.conf
remote 115.182.x.x
float
proto udp 
port 1140
tun-mtu 1400
dev tun
ifconfig 10.0.0.2 10.0.0.1
persist-tun
persist-local-ip
comp-lzo
ping 15
secret /etc/ｏｐｅｎ　ｖｐｎ/vpn.key
route 172.19.0.0 255.255.0.0
chroot /var/empty
user nobody
group nobody
log /var/log/vpn.log
verb 3</pre>
**VPN server 2 配置**
<pre>
[root@ｏｐｅｎ　ｖｐｎ ｏｐｅｎ　ｖｐｎ]# cat /etc/ｏｐｅｎ　ｖｐｎ/server.conf
remote 211.144.xxx.xx
float
proto udp 
port 1140
dev tun
ifconfig 10.0.0.1 10.0.0.2
persist-tun
persist-local-ip
comp-lzo
ping 15
secret /etc/ｏｐｅｎ　ｖｐｎ/vpn.key
route 172.18.0.0 255.255.0.0
#route 172.18.251.0 255.255.255.0
chroot /var/empty
user nobody
group nobody
log /var/log/vpn.log
verb 1</pre>
**启动**
<pre>/opt/ｏｐｅｎｖｐｎ/sbin/ｏｐｅｎ　ｖｐｎ --config /etc/ｏｐｅｎｖｐｎ/server.conf</pre>
**交换机上增加路由**
1、在公司1内网网段三层交换机上增加路由 去172.19.0.0/16 的走 172.18.248.125
2、在公司2内网网段三层交换机上增加路由 去172.18.0.0/16 的走 172.19.0.5 
**测试**
[![vpn 测试](http://www.m690.com/wp-content/uploads/2015/04/vpn-测试.bmp)测试](http://www.m690.com/wp-content/uploads/2015/04/vpn-测试.bmp)