---
title: 小计：mongodb 简明安装测试
tags:
  - centos6.3
  - mongodb
  - 安装
  - 配置
id: 538
categories:
  - mongodb
date: 2012-11-20 18:03:42
---

> 因为公司使用的discuz论坛使用了性能比较好的mongodb,所以今天进行了一下mongodb的安装和配置,记录一下安装过程。

1.  官方在CENTOS上的yum安装方法：

<pre class="blush: php">
#配置yum源：
[root@dev61 source]# cat  /etc/yum.repos.d/10gen.repo   
[10gen]
name=10gen Repository
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64
gpgcheck=0
enabled=1

#使用yum安装
yum install mongo-10gen mongo-10gen-server numactl

#配置mongod.conf 注：没有做更多的配置，只是改了一下数据及日志路径
[root@dev61 source]# cat /etc/mongod.conf | grep -v '^#' | grep -v '^$'
logpath=/opt/mongo/log/mongod.log
logappend=true
fork = true
dbpath=/opt/mongo/data
pidfilepath = /var/run/mongodb/mongod.pid

#增加相应配置的目录及权限
 1018  mkdir -p /opt/mongo/log
 1019  mkdir -p /opt/mongo/data
 1022  chown -R mongod:mongod /opt/mongo/
 1024  mkdir /var/run/mongodb/
 1025  chown -R mongod:mongod /var/run/mongodb/
 1031  service mongod start
 1032  chkconfig mongod on

#测试是否正常启动
 1037  netstat -anp | grep mongod
 1038  telnet dev61 27017
</pre>2.  手动编译安装：CENTOS6.3系统