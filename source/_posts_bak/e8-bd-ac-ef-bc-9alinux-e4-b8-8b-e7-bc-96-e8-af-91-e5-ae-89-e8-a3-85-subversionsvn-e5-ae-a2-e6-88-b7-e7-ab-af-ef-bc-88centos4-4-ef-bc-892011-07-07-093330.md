---
title: '转：linux 下编译安装 subversion(svn) 客户端 （Centos4.4）(2011-07-07 09:33:30)'
tags:
  - svn
  - 安装
  - 编译
id: 162
categories:
  - svn
date: 2011-07-26 14:56:20
---

    我看到的本文原出处：[http://hi.baidu.com/zxm_xdl/blog/item/7b21adec44419b3663d09f07.html
](http://hi.baidu.com/zxm_xdl/blog/item/7b21adec44419b3663d09f07.html) 

> 最近想通过SVN实现程序发布后自动更新到线上服务器（因为公司不景气，招不到人，没办法哈），减少自己平时的工作量。实现方式是：通过svn update定时把QA发布的更新包下下来，通过更新程序把更新内容同步到线上服务器。

### 公司内到线上的跳板机还是centos4.0的系统，没有yum源，所以决定在上面编译安装svn了，下面是我的参考文章。

svn server 为只支持http://协议的windows;
test web server 为as4,现需安装svn客户端方便同步代码

网上找了下都是讲如何安装svn server的，我只需要一个支持http协议的客户端哈，不想装apache。

安装所需软件
apr, apr-util, sqlite, neon, subversion

1.下载软件
<pre class="brush: php">
wget http://mirror.bjtu.edu.cn/apache//apr/apr-1.4.2.tar.bz2 
wget http://mirror.bjtu.edu.cn/apache//apr/apr-util-1.3.10.tar.bz2 
 wget http://www.sqlite.org/sqlite-amalgamation-3.6.16.tar.gz 
wget http://www.webdav.org/neon/neon-0.28.4.tar.gz 
wget http://subversion.tigris.org/downloads/subversion-1.6.15.tar.bz2 
wget http://mirror.centos.org/centos/4/os/i386/CentOS/RPMS/expat-devel-1.95.7-4.i386.rpm 
wget http://xmlsoft.org/sources/old/libxml2-devel-2.6.16-1.i386.rpm 
</pre>
2.安装apr
<pre class="brush: php">
tar zxvf apr-1.3.7.tar.gz 
cd apr-1.3.7 
./configure -prefix=/usr/local/apr 
make 
make install 
cat /etc/ld.so.conf 
echo /usr/local/apr/lib >> /etc/ld.so.conf
</pre>

3.安装apr-util
<pre class="brush: php">
tar zxvf apr-util-1.3.8.tar.gz 
cd apr-util-.1.3.8 
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/ 
make 
make install 
echo /usr/local/apr-util/lib >> /etc/ld.so.conf 
ldconfig -v 
</pre>

4.安装sqlite
<pre class="brush: php">
tar zxvf sqlite-amalgamation-3.6.16.tar.gz 
cd sqlite-3.6.16/ 
configure --prefix=/usr/local/sqlite 
make 
make install 
</pre>
5.安装neon
不需要支持http协议可以略掉安装
<pre class="brush: php">
tar zxvf neon-0.28.4.tar.gz 
cd neon-0.28.4 
./configure --prefix=/usr/local/neon --enable-shared 
make 
make install 
</pre>
6.安装两个rpm包 (懒得手动去编译了）
<pre class="brush: php">
  rpm -ivh  expat-devel-1.95.7-4.i386.rpm
  rpm -ivh  libxml2-devel-2.6.16-1.i386.rpm
</pre>
方式二:解压后重命名为neon,移动至subversion编译目录
但subversion编译时好像找不到neon
报错如下
<pre class="brush: php">
configure: checking neon library 

An appropriate version of neon could not be found, so libsvn_ra_neon 
will not be built.  If you want to build libsvn_ra_neon, please either 
install neon 0.28.4 on this system 

or 

get neon 0.28.4 from: 
    http://www.webdav.org/neon/neon-0.28.4.tar.gz 
unpack the archive using tar/gunzip and rename the resulting 
directory from ./neon-0.28.4/ to ./neon/ 

no suitable neon found 
</pre>
6.安装subversion
<pre class="brush: php">
tar -jxvf subversion-1.6.3.tar.bz2 
cd subversion-1.6.3 
./configure --prefix=/usr/local/svn --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --with-sqlite=/usr/local/sqlite --with-neon=/usr/local/neon 
make 
make install 
</pre>
7.检查测试
安装后应该有三个模块
<pre class="brush: php">
/usr/local/svn/bin/svn --version 
svn，版本 1.6.3 (r38063) 
编译于 Jul 30 2009，14:31:41 

版权所有 (C) 2000-2009 CollabNet。 
Subversion 是开放源代码软件，请参阅 http://subversion.tigris.org/ 站点。 
此产品包含由 CollabNet(http://www.Collab.Net/) 开发的软件。 

可使用以下的版本库访问模块: 

* ra_neon : 通过 WebDAV 协议使用 neon 访问版本库的模块。 
  - 处理“http”方案 
* ra_svn : 使用 svn 网络协议访问版本库的模块。  - 使用 Cyrus SASL 认证 
  - 处理“svn”方案 
* ra_local : 访问本地磁盘的版本库模块。 
  - 处理“file”方案 
</pre>
导出项目
<pre class="brush: php">
cd /opt/srv/ 
/usr/local/svn/bin/svn export --username c1g --password 123456 http://192.168.1.9/pub37 
</pre>

习惯性的把svn放在bin下
<pre class="brush: php">
ln -s /usr/local/svn/bin/svn /usr/bin/svn
</pre>