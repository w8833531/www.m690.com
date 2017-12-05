---
title: mysql 导入导出大的数据库加速方法
tags:
  - mysql
  - 加速
  - 导入，导出
id: 880
categories:
  - mysql
date: 2015-02-27 16:22:31
---

> 之前用mysqldump导出的一个25G大小的库，发现导入导出非常非常慢，导入要花几小时。在导出时合理使用几个参数，可以大大加快导 入的速度。

-e 使用包括几个VALUES列表的多行INSERT语法;
--max_allowed_packet=XXX 客户端/服务器之间通信的缓存区的最大大小;
--net_buffer_length=XXX TCP/IP和套接字通信缓冲区大小,创建长度达net_buffer_length的行。

注意：max_allowed_packet 和 net_buffer_length 不能比目标数据库的设定数值 大，否则可能出错。

首先确定目标数据库的参数值
<pre>
mysql show variables like 'max_allowed_packet';
mysql show variables like 'net_buffer_length';
</pre>
根据参数值书写 mysqldump 命令，如：
<pre>
# mysqldump -uroot -p123 21andy -e --max_allowed_packet=16777216 --net_buffer_length=16384 > aaa.sql
</pre>
OK，现在速度就很快了，主要注意的是导入和导出端的 max_allowed_packet 和 net_buffer_length 这2个参数值设定，弄大点就OK了

其实，最快的方法，是直接COPY数据库目录，不过记得先停止 MySQL 服务。