---
title: mwget 多线程的wget
tags:
  - mwget
  - wget
  - 多线程
id: 961
categories:
  - linux
date: 2015-10-12 18:25:28
---

> 一个多线程的wget 工具，mwget把下载速度提升了一个档次。

具体安装如下：
<pre>
wget http://jaist.dl.sourceforge.net/project/kmphpfm/mwget/0.1/mwget_0.1.0.orig.tar.bz2
tar -jxvf mwget_0.1.0.orig.tar.bz2 
yum -y install intltool
cd mwget_0.1.0.orig
./configure && make -j 8 && make install
</pre>
时间就是生命，在线上wget 文件，还是得用mwget
<pre>
mwget -n 16 http://bd.firefall.com.cn/Firefall_Installer_Full_V1887.zip
</pre>