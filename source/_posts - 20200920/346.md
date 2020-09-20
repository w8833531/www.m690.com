---
title: redhat centos 加静态路由小计
tags:
  - Centos
  - redhat
  - service
  - 静态路由
id: 346
categories:
  - linux
date: 2011-12-15 16:35:15
---

> 老是在用service network restart 的后，才发现静态路由加在/etc/rc.local里了，没有运行，机器通过内网已经连不上了。今天花了5分钟，查了一下永久加静态路由的方法。

加内网eth0网卡方法如下：
vi /etc/sysconfig/network-scripts/route-eth0
10.0.0.0/8 via 10.126.40.254
192.168.188.0/22 via 10.126.40.254

OK,以后用service 命令重启网卡就不会把路由给丢了。