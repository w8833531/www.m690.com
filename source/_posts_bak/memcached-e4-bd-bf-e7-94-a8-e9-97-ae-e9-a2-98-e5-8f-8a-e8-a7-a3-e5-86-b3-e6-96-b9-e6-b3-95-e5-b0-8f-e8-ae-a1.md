---
title: Memcached 使用问题及解决方法小计
tags:
  - hashtable
  - memcached
id: 303
categories:
  - linux
date: 2011-11-16 14:58:57
---

> 前一阵子，公司线上服务器上的memcached服务经常出现死锁的情况，可以telnet 到memcached的端口上，但无法获取任何数据，打stats命令无反应。

我的memcached服务器系统配置及相关编译启动参数如下：
<pre class="blush: php">
系统硬件：IBM HS20 ， 内存8G，无磁盘
操作系统：Centos 5.2 64位 无盘系统，其中4G做为系统内存盘
使用memcached版本：memcached-1.4.10
使用libevent版本：libevent-2.0.15-stable
编译参数：./configure --prefix=/data/update/20111114/memcached --enable-64bit --with-libevent=../libevent-2.0.15
memcached启动参数：/opt/memcache-1.4.10/bin/memcached -vv -o hashpower=24 -p 10091 -U 0 -f 1.001 -n 256 -m 3072 -c 2048 -u appl -d
</pre>

用gdb -p ，发现memcached 除了网络线程工作正常，其它的四个工作线程都处于死锁状态。
用-vv参数，打开memcached的日志，发现memcached当出现上面的情况前，日志结尾部分总是会报：**Hash table expansion starting**，然后就卡在那里了。出错信息如下：
<pre class="blush: php">
Hash table expansion starting
<62 get 1379035377@qq.com_MJSG_protected 
<53 get 1379035377@qq.com_0f3f9cc9c88b91b92f0931e518d99020 
<50 get 479650897@qq.com_basic 
Too many open connections
</pre>
查了一下memcached的hash算法的说明，发现当哈希表中的item数大于表的大小的3/2时，则哈希表进行扩张。而每次做hash表自动扩张操作时，memcached程序就会产生死锁。让写C的同事看了一下，一时也找不出具体卡住的原因。

解决方法是：查看memcached的命令行参数，发现有一个-o 参数，可以设置hashpower，系统默认大小是16,也就是2的16次方，也就是说，如可memcached中item的数量大于65536*3/2＝98304时，就会做hash表的扩张。可以把这个值设置得大一点，也就是设置默认hash表的大小大一点，就不会进行扩张了。

我的设置参数是：
<pre class="blush: php">
 -o hashpower=24，  #hash表可以容纳2400W的item,而不需要进行hash表的自动扩张
</pre>

进上面的的设置后，memcached死锁的问题解决，但具体memcached 为什么会在自动进行hash表扩张时，会产生死锁的原因还是没有找到。可能的原因是
1、使用的无盘系统
2、把memcached的增涨因子 -f 1.001   设置的太小。