---
title: apache cgi-bin目录 option配置错误，使一台apache服务器变成了扫描肉鸡
tags:
  - cgi-bin
  - XSUCCESS
  - 扫描
  - 配置问题
id: 975
categories:
  - 其它
date: 2015-10-12 18:48:43
---

> 今天连上一台服务器，用ps -efww发现一个奇怪的进程，很快就发现这台机器已经变成了别人的肉鸡了，具体如下

ps -efww 后的进程例表如下图,demon用户是我的apache跑的用户：
[![新建位图图像1012_3](http://www.m690.com/wp-content/uploads/2015/10/新建位图图像1012_3-1024x160.jpg)](http://www.m690.com/wp-content/uploads/2015/10/新建位图图像1012_3.jpg)

查看apache日志，发现日志中的访问如下，其中最后一项本应该记录的是user-agent，但变成了一个可执行的命令（这个命令是去一台国外的机器上下载一个tar包，自解压编译后运行，去扫描其它的机器，然后再把其它有漏洞的机器做成肉鸡，应该是用来提高扫描效率。上面的脚本我保留了，有兴趣的可以单独交流）：

[![新建位图图像1012](http://www.m690.com/wp-content/uploads/2015/10/新建位图图像1012-1024x62.jpg)](http://www.m690.com/wp-content/uploads/2015/10/新建位图图像1012.jpg)

**问题所在：**
是因为我们在配置cgi-bin这个目录权限时，没有使用默认的权限设置，而是做了更改，在 Options   中加了FollowSymLinks，默认应该是None。使用FollowSymLinks后，就可以跳出apache的document root,这样就可以运行你系统上的任何非root权限的命令了。
[![新建位图图像1012_2](http://www.m690.com/wp-content/uploads/2015/10/新建位图图像1012_2-1024x109.jpg)](http://www.m690.com/wp-content/uploads/2015/10/新建位图图像1012_2.jpg)
**另外**
在网络层阻止所有公网IP的服务器对外主动的访问，不失是一种大幅度提高系统安全性的好方法。这样虽然会有一点不方便，但安全和方便总是一对矛盾体。如果的确有对外访问的需求，可以统一用一台安全性比较高的服务器对外提供http代理访问服务，所有的服务器都从这台服务器代理出去。而在代理服务器上设置可以对外访问的域名（七层）。