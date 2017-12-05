---
title: 小技巧： 如何让bzip2 多核并发执行，把速度加快近 n倍（n为CPU核数）
tags:
  - pbzip2
  - 并发压缩
id: 1068
categories:
  - 小技巧
date: 2017-02-14 10:58:21
---

> 我们知道， bzip2这样的命令非常耗CPU，更可恶的是，这些压缩命令都是只支持单核执行的。也就是说，你的服务器有20core,但在做bzip压缩时，只有一个core在工作。如果你要迁移大批数据从一个IDC到另一个IDC话，下面这个命令会非常有用。
可以使用pbzip2这个小工具来并发多核CPU来进行压缩操作。
安装 ：
<pre>apt-get install pbzip2
</pre>
执行效果如下图，我的机器是20cores(40threads),用pbzip2和bzip2对同一文件进行压缩，速度快了18倍（接近与CPU核数）。这在IDC之间或云供应商之间迁移数T级别的数据还是非常有价值的。

![](http://www.m690.com/wp-content/uploads/2017/02/img_58a2718472ec8.png)

还有一个叫Parallel 的命令，也可以通过管道达到相同的效果，但使用起来没有pbzip2来得方便。