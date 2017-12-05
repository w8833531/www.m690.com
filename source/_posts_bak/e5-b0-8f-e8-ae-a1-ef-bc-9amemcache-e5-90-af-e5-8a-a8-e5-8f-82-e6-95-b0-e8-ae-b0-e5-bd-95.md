---
title: 小计：memcache 启动参数更改用于解决内存占用的问题
tags:
  - chunk size
  - memcache
  - 大小
id: 402
categories:
  - linux
  - 技术
date: 2012-02-26 11:39:58
---

[![](http://www.m690.com/wp-content/uploads/2012/01/IMAG0256-612x1024.jpg "小土妞")](http://www.m690.com/wp-content/uploads/2012/01/IMAG0256.jpg)> 我们一般会有这样的需求，设置memcache 中的每个chunk size 的大小的最大值是相同的(为了节约内存，如果每个chunk size 都是相同的可以容纳更多的key），比如我这边每个chunk size 的最大值是304.当我用下面的参数启动memcached的时候，会出现下面的问题：

/opt/memcache-1.4.10/bin/memcached -vv -o hashpower=24 -p 10090 -U 0 -f 1.001 -n 256 -m 3072 -c 2048 -u appl -d

从日志看，当用-f 1.001时，生成的所有slab的chunk size 的大小都是304个字节，除了最后一个slab class 200的chunk size 是1M ,这样会出现一个问题，当有大于256字节的key向memcache中保存时，就会存在slab200中，而每个key占用的大小是1M，如果这样的key比较多，比如有2000个，就会占用2G内存，会一下子把本来就不多的内存给吃光。

。。。。。。
slab class 190: chunk size       304 perslab       3
slab class 191: chunk size       304 perslab       3
slab class 192: chunk size       304 perslab       3
slab class 193: chunk size       304 perslab       3
slab class 194: chunk size       304 perslab       3
slab class 195: chunk size       304 perslab       3
slab class 196: chunk size       304 perslab       3
slab class 197: chunk size       304 perslab       3
slab class 198: chunk size       304 perslab       3
slab class 199: chunk size       304 perslab       3
**slab class 200: chunk size      1M perslab       1**
<36 server listening (auto-negotiate)
<37 server listening (auto-negotiate)
(END) 
解决方法，是增加一个**－I**的参数，限制chunk size 的最大大小为1024（1K字节），修改启动参数如下：
/opt/memcache-1.4.10/bin/memcached -vv -o hashpower=24 -p 10090 -U 0 -I 1024 -f 1.001 -n 256 -m 3072 -c 2048 -u appl -d

slab class 190: chunk size       304 perslab       3
slab class 191: chunk size       304 perslab       3
slab class 192: chunk size       304 perslab       3
slab class 193: chunk size       304 perslab       3
slab class 194: chunk size       304 perslab       3
slab class 195: chunk size       304 perslab       3
slab class 196: chunk size       304 perslab       3
slab class 197: chunk size       304 perslab       3
slab class 198: chunk size       304 perslab       3
slab class 199: chunk size       304 perslab       3
**slab class 200: chunk size      1024 perslab       1**
<36 server listening (auto-negotiate)
<37 server listening (auto-negotiate)
(END) 