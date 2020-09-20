---
title: mysql 状态及配置抓取命令小计
id: 317
categories:
  - mysql
date: 2011-11-17 11:45:46
tags:
---

进程状态
show processlist;
 show full processlist;
binlog状态
show binary logs;
日志
show variables like "%log%";
线程
show variables like "%thread%";
连接数（如果前台是php短连接，建议连接数过设置多一点，设置成1000）
show variables like '%conn%';
inndb 状态
show engine innodb status;