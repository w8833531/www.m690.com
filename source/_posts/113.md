---
title: linux ext3 文件恢复方法 （转载张宴的博文）
tags:
  - ext3
  - linux
  - 文件恢复
id: 113
categories:
  - linux
date: 2011-07-25 22:59:25
---

[文章作者：张宴 本文版本：v1.0 最后修改：2009.07.06 转载请注明原文链接：[原文链接](http://blog.s135.com/linux_ext3_undelete/)

> 环境：CentOS 5.3 x86_64下，/dev/sdb1为数据分区/data0，EXT3文件系统。> 
> 　　前因：误删了/data0/tcsql/cankao/phpcws-1.5.0/httpcws.cpp文件。由于忘了备份httpcws.cpp文件，重新开发工作量较大，因此只有恢复该文件一条路可走。　　debugfs命令针对EXT2分区还行，但对EXT3分区就帮不上忙了。

偶然发现的一款开源软件，解决了我的大忙。该软件下载网址为：
　　[ext3grep](http://code.google.com/p/ext3grep/)

###  1、先安装ext3grep软件：

<pre class="brush: php">
wget http://ext3grep.googlecode.com/files/ext3grep-0.10.1.tar.gz
tar zxvf ext3grep-0.10.1.tar.gz
cd ext3grep-0.10.1
./configure
make
make install
</pre>

### 2、umount /data0分区：

<pre class="brush: php">
umount /data0
</pre>

　如果提示busy，先kill正在使用这个目录的进程，再umount：

<pre class="brush: php">
fuser -k /data0
umount /data0
</pre>

### 3、查询所有Inode，（执行需要几分钟～十多分钟）：

<pre class="brush: php">
ext3grep /dev/sdb1 --ls --inode 2
</pre>

### 4、逐级查找Inode，看是否能找到httpcws.cpp文件（此步骤也可省略）：

###  5、恢复/data0/tcsql/cankao/phpcws-1.5.0/httpcws.cpp文件：

<pre class="brush: php">
ext3grep /dev/sdb1 --restore-file tcsql/cankao/phpcws-1.5.0/httpcws.cpp
</pre>

如果提示以下信息，则表示恢复成功：

　　Restoring tcsql/cankao/phpcws-1.5.0/httpcws.cpp

这时，执行ext3grep命令的当前目录下将会自动生成一个名为RESTORED_FILES的文件夹，文件夹下的tcsql/cankao/phpcws-1.5.0/httpcws.cpp即为恢复的文件。查看了一下，和被删除前的内容一样，大功告成。

### 6、重新mount /data0分区：

<pre class="brush: php">
mount /dev/sdb1 /data0
</pre>

　　[参考资料链接](http://www.xs4all.nl/~carlo17/howto/undelete_ext3.html) 