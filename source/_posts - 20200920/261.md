---
title: 小计：在HP-UX 3.1上安装md5sum
tags:
  - HP-UX
  - md5sum
id: 261
categories:
  - HP-UX
date: 2011-08-12 15:28:55
---

> 今天下了一个HP-UX的depot的安装包，安装时发现报错了。因为文件比较大，要check 一下这个安装包是否下载完成了。打了md5sum命令，发现没有这个包，只能去 [www.software.hp.com ](http://www.software.hp.com)下载了一个

下载地址 ： [https://h20392.www2.hp.com/ecommerce/efulfillment/getsoftwareaction.do?lc=&orderNumber=422106204](https://h20392.www2.hp.com/ecommerce/efulfillment/getsoftwareaction.do?lc=&orderNumber=422106204)

验证及安装方法：
<pre class="blush: php">
swlist -d @ /iso/MD5Checksum_A.01.01.02_HP-UX_B.11.31_IA+PA.depot
swinstall -s /iso/MD5Checksum_A.01.01.02_HP-UX_B.11.31_IA+PA.depot \*
[root@hpux11 iso]# md5sum NaviCLI-HPUX-32-NA-en_US-7.30.11.0.38-1.dep 
85db9cb6d681a19586cd71b01984382b NaviCLI-HPUX-32-NA-en_US-7.30.11.0.38-1.dep
</pre>