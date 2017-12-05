---
title: Perl 使用perl命令批量替换文件内容
tags:
  - perl
  - 批量替换文件内容
id: 128
categories:
  - perl
date: 2011-07-26 09:29:44
---

> 对linux系统下面多个文本文件内容做处理，是SA经常需要完成的工作。如何高效的完成这个工作，perl应该是一个不错的语言工具。你甚至不需要编写perl脚本，用命令就可以完成上面的工作。

perl 命令可以批量替换文件中的一些内容，操作起来非常高效。下面举几个例子:
<pre class="brush: php">
perl -pi -e "s/aaa/bbb/gi" test.txt
</pre>

上面的命令把test.txt文件中的字符aaa替换成bbb
<pre class="brush: php">
perl -pi.bak -e "s/aaa/bbb/gi" test.txt
</pre>

上面的命令把test.txt文件中的字符aaa替换成bbb,并生成一个test.txt.bak的备份文件
<pre class="brush: php">
find ./ -name "*.txt" | xargs perl -pi.bak -e "s/aaa/bbb/gi"
</pre>
上面的命令把当前目录下所有的.txt文件中的字符aaa替换成bbb,并生成相应的.bak的备份文件