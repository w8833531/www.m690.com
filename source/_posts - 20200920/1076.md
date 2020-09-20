---
title: 小技巧--用阿里云的OSS对象存储备份你在云上的系统数据
tags:
  - ECS
  - OSS
  - 备份
  - 阿里云
id: 1076
categories:
  - 小技巧
  - 技术
date: 2017-02-27 17:32:42
---

> 阿里云最近推出了9块钱 100G 包年的oss（对象存储）服务 ，感觉还是比较值的。9块钱1年100G，可以在云上备份很多东西了。最主要的是，可以通过这100G的OSS 把我在 aliyu上的ECS数据做每日备份，非常方便。
在linux系统ECS 上向阿里云的 oss存储数据非常方便，安装 osscmd 工具，写个脚本放crontab中就可以实现自己的ECS数据每天自动备份。具体实现方式如下：
<pre>
#安装 osscmd
wget "https://docs-aliyun.cn-hangzhou.oss.aliyun-inc.com/internal/oss/0.0.4/assets/sdk/OSS_Python_API_20160419.zip?spm=5176.doc32171.2.2.nnigW2&amp;file=OSS_Python_API_20160419.zip"
unzip OSS*20160419.zip   #解压后，osscmd命令就在你的当前目录下面了，可以直接用python命令调用
#使用osscmd命令来传文件
#配置osscmd
python osscmd config --id=xxxxxxx --key=xxxxxxx --host=oss-cn-shanghai.aliyuncs.com
#id 和 key都可以在控制台上生成
#host是你所在的地区（如华东），如果是从外网上传，可以使用oss-cn-shanghai.aliyuncs.com（华东），如果你的ECS和你的OSS在同一个地区，可以oss-cn-shanghai-internal.aliyuncs.com（华东内网），这样速度是非常快，不受外网带宽的限制 。
#这样，会在你的用户主目录下生成一个.osscredentials 文件，如下图：</pre>

![](http://www.m690.com/wp-content/uploads/2017/02/img_58b3f118df619.png)

然后就可以使用python osscmd命令上传文件了：
<pre>
python osscmd multiupload m690.com.tgz oss://w8833531/m690.com.tgz && rm -f m690.com.tgz
</pre>
最后，给一个使用python osscmd 命令上传备份的脚本：
<pre>
root@m690-aliyun:/data# cat oss_backup.sh 
#!/bin/bash
#USAGE: This script use to backup m690.com docker image and data to aliyu oss .
#AUTHOR: Larry Wu

echo "======At `date` start oss backup ======"
cd /data/ || exit 1
tar -zcvf m690.com.tgz m690.com/ > /dev/null
python osscmd multiupload m690.com.tgz oss://xxxxx/m690.com.tgz && rm -f m690.com.tgz
python osscmd list oss://xxxxx/
echo "=======At `date` end oss backup ======"
</pre>
#xxxxx是bucket 名
###最后，增加一个计划任务，每天3点做备份
root@m690-aliyun:/data# crontab -l | grep -v '#'
3 3 * * *  bash /data/oss_backup.sh >> /data/oss_backup.txt 2>&1
root@m690-aliyun:/data# 