---
title: 系统升级之－－安装eaccelerator php加速模块
tags:
  - eaccelerator
  - php
  - 加速
  - 安装
  - 编译
id: 598
categories:
  - 技术
date: 2013-01-02 22:01:12
---

> 最近在做无盘的系统升级，从centos5.2升级到6.3。系统上面安装的软件也基本上都要升了一下，当然包括php了。手动编译了N个php模块，挑一个记录一下。

模块名：eaccelerator-0.9.6.1
模块作用：Accelerator 是一个免费开源的PHP加速、优化、编译和动态缓存的项目，它可以通过缓存PHP代码编译后的结果来提高PHP脚本的性能。通过使用eAccelerator，可以优化你的PHP代码执行速度，降低服务器负载，可以提高PHP应用的执行速度。
下载链接：[http://sourceforge.net/projects/eaccelerator/files/latest/download?source=files](http://sourceforge.net/projects/eaccelerator/files/latest/download?source=files)
编译安装方法：
<pre class="blush: php">
cd eaccelerator-0.9.6.1
/opt/latop/phpfront3/php/bin/phpize
./configure --enable-eaccelerator --with-php-config=/opt/latop/phpfront3/php/bin/php-config
make -j 4 && make install
cp /opt/latop/phpfront3/php/lib/php/extensions/no-debug-non-zts-20090626/eaccelerator.so /www/modules/
</pre>
配置方法：
<pre class="blush: php">
#生成cache_dir及logdir ,并给相应的权限
mkdir /opt/eaccelerator 
mkdir /opt/log
chown -R daemon:daemon /opt/eaccelerator
chown -R daemon:daemon /opt/log
#编辑php.ini,增加下面的内容
[root@WEB24 ~]# cat /www/conf/php.ini | tail -n 17
[eaccelerator]
extension="eaccelerator.so"
eaccelerator.shm_size="32"
eaccelerator.cache_dir="/opt/eaccelerator"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.log_file = "/opt/log/eaccelerator_log"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="0"
eaccelerator.shm_prune_period="0"
eaccelerator.shm_only="0"
eaccelerator.compress="1"
eaccelerator.compress_level="9"
</pre>