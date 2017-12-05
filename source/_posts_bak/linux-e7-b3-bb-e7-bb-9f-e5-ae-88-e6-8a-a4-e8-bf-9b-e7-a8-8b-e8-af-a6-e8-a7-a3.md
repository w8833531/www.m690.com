---
title: Linux系统守护进程详解
id: 122
categories:
  - linux
date: 2011-07-25 23:16:11
tags:
---

> redhat的，给个[链接](http://www.linux-cn.com/html/linux/Security/20070421/9425.shtml)吧，已经非常详细了:) 另外给一个本人在CentOs 5.2 64位服务器上建议打开的服务

**auditd**--当 auditd 运行的时候，审核信息会被发送到一个用户配置日志文件中（默认的文件是 /var/log/audit/audit.log）。如果 auditd 没有运行，审核信息会被发送到 syslog。这是通过默认的设置来把信息放入 /var/log/messages

**crond**--计划任务

**haldaemon**--监控硬件的改动（服务器这方面的改动很少，所以我一般不开这个服务）

**iptables** -- linux防火墙，一般我开着，不管加不加策略。如果前面有防火墙，或有交换机ACL，就不用开了。

**irqbalance**--在多处理器系统中，启用该服务可以提高系统性能。

**messagebus**--这是 Linux 的 IPC（Interprocess Communication，进程间通讯）服务。确切地说，它与 DBUS 交互，是重要的系统服务

**network**--不开网络不能使用

**nfs,nfslock**--如果要提供NFS服务，开一下。

**portmap**--如果要使用NFS服务，开一下。

**smartd**--SMART Disk Monitoring 服务用于监测并预测磁盘失败或磁盘问题（前提：磁盘必须支持 SMART）。

**sshd**-- 安全shell,开着，除非你不想做远程管理。最好是设置成public key认证方式。

**syslog**-- 记录系统日志，开着。

**当然，服务开得越少，占用系统资源就越少，被攻击的可能性也就越小。最小的话，我可能只开下面几个服务：**

**crond irqbalance network sshd syslog **5个服务，可以了。 

 