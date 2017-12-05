---
title: 小计：CentOS6上安装mongodb 连接数无法上去的解决办法
tags:
  - can't create new thread
  - Centos6
  - discuz
  - limit
  - mongodb
  - 连接数
id: 542
categories:
  - mongodb
date: 2012-11-21 18:34:08
---

> 之前discuZ论坛使用mongodb,为提升性能，会在entlib.config文件中配置前台WEB连接mongodb的连接数。我这边6台WEB，每台WEB向mongodb发起512个连接，发现mongodb的连接数只能上到1000个左右。

1、查看mongodb的日志，报下面的错误：
<pre class="blush: php">
Wed Nov 21 15:26:09 [initandlisten] pthread_create failed: errno:11 Resource temporarily unavailable
Wed Nov 21 15:26:09 [initandlisten] can't create new thread, closing connection
</pre>
2、在一台一样的centos5的机器上测试，发现连接2000个连接一点问题都没有。
3、上google查找问题，关键字“mongod.conf can't create new thread, closing connection”
4、找到问题所在，原来centos6与之前centos5不同，多了一个默认的限制用户nproc的配置文件 ：/etc/security/limits.d/90-nproc.conf  ，默认把普通用户的nproc设置成1024，而mongodb正好又是使用mongod这个非root用户跑的，所以连接数一直上不去了。
5、更改/etc/security/limits.d/90-nproc.conf ，把1024改成20480 ,问题解决。
<pre class="blush: php">
[root@vmongodb02 ~]# cat /etc/security/limits.d/90-nproc.conf 
# Default limit for number of user's processes to prevent
# accidental fork bombs.
# See rhbz #432903 for reasoning.

*          soft    nproc     20480
</pre>