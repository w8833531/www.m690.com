---
title: 小计：centos 系统上报文件描述符不足的处理方法
tags:
  - lsof
  - 文件描述符
id: 399
categories:
  - linux
  - 技术
date: 2012-02-24 17:23:04
---

> 今天发现在台服务器的系统日志中报文件描述符不足，记录一下处理方法

１、用ulimit -a查看，文件描述符的数量：
root@SSS script]# ulimit -a
core file size          (blocks, -c) unlimited
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 71680
max locked memory       (kbytes, -l) 512
max memory size         (kbytes, -m) unlimited
**open files                      (-n) 65535**
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 10240
cpu time               (seconds, -t) unlimited
max user processes              (-u) 71680
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
是６５５３５，应该是不会满的。

２、用lsof 查看文件占用情况，是哪个程序占用了这么多文件描述符。
lsof　｜wc -l
lsof | more
３、提交开发查具体程序的问题