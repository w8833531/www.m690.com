---
title: apn-proxy 穿墙服务器端架设指南
tags:
  - apn-proxy
  - 安装
  - 指南
  - 穿墙
  - 配置
id: 742
categories:
  - 技术
date: 2014-07-23 02:07:31
---

> 使用apn-proxy可以很好的实现穿墙。我为什么要说“穿”呢？不是“翻”吗。从技术上来说，应该是“穿”，在墙内和墙外打一个加密通道，实现穿墙。apn-proxy 最大的好处是iphone上设置简单，手机使用非常方便，而且可以通过配置实现墙内的站点直接访问，墙外的站点穿墙访问。
下面给个图，看看apn-proxy是如何实现穿墙的。
[![apn-proxy实现穿墙](http://www.m690.com/wp-content/uploads/2014/07/apn-proxy实现穿墙.jpg)](http://www.m690.com/wp-content/uploads/2014/07/apn-proxy实现穿墙.jpg)
从图中我们看到，要实现一个比较“聪明的”穿墙代理，需要有两台代理服务器，一台在墙内（国内），一台在墙外（国外或香港）。用户先连接墙内的代理服务器，如果check到访问的站点域名不在墙外站点列表里，就通知用户端直接访问墙内站点，不走proxy；如果check到访问站点域名在墙外站点列表里，就通过SSL连接到墙外代理服务器，访问墙外站点。这样做的好处是，在客户端设置代理后，访问墙内站点的速度是基本上不受设置代理的影响的。也就是说，这个代理可以一直设置在你的客户端上，不用经常更改。

服务器环境：
两台vps,一台国内，一台在香港，操作系统是CentOS6.4_64。墙外机器配置不高，1CPU，512内存，15G磁盘，150G流量每月，10M峰值带宽，基本已经够用了。

下面讲一下如何安装和配置apn-proxy代理：
1、安装方法：
1）安装jdk java 运行环境，建议使用jdk7：
到[http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)下载jdk7.
安装和配置jdk
<pre>###解压jdk7，解压目录/opt/jdk1.7.0_65
tar -zxvf jdk-7u65-linux-x64.tar.gz 
###增加环境变量到/etc/profile文件最后
export JAVA_HOME=/opt/jdk1.7.0_65
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=$JAVA_HOME/lib:$CLASSPATH
export JAVA_OPTS="-Xms32M -Xmx64M -XX:PermSize=16M -XX:MaxPermSize=32M -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/data/dump/dump.dat -DlogPath=/data/logs/"
###设置对应的日志和dump目录 
mkdir /data/dump/
mkdir /data/logs/
</pre>

2）安装apn-proxy
<pre>###下载apn-proxy
wget https://github.com/apn-proxy/apn-proxy/releases/download/2.0.5/apn-proxy-2.0.5.zip
###解压下载包到/opt
tar -zxvf apn-proxy-2.0.5.zip
</pre>

3)配置墙内apn-proxy服务器
a)config.xml主配置文件的配置
<pre>
[root@web01 conf]# cat config.xml 
<?xml version="1.0" encoding="UTF-8" ?>
<apn-proxy>

    <!-- By default, config apn-proxy listen in plain mode act as a normal http proxy server -->
    <listen-type>plain</listen-type> <!--墙内就直接使用明文方式,这样客户端配置起来比较通用-->
    <port>8700</port>  <!--端口-->
    <thread-count>
        <boss>1</boss>
        <worker>50</worker>
    </thread-count>

    <trust-store>
        <path>conf/truststore.ks</path> <!--证书文件,用keytool命令生成-->
        <password>qwexxxxx</password> <!--证书文件密码-->
    </trust-store>
    <pac-host>180.xx.x.11</pac-host> <!-- 设置本机监听ip地址 -->
    <use-ipv6>false</use-ipv6>
</apn-proxy>
[root@web01 conf]# 
</pre>
b) remote-rules.xml转发规则文件的配置，用于设置把墙内的请求用SSL 转发到墙外的apn-proxy服务器
<pre>
<?xml version="1.0" encoding="UTF-8" ?>
<!-- remote rules for proxy chain -->
<remote-rules>
    <rule>
        <remote-listen-type>ssl</remote-listen-type>    <!--设置向远程apn-proxy发启连接的方式，使用ssl-->
        <remote-host>example.com</remote-host>             <!--设置远程服务器IP或域名-->
        <remote-port>8700</remote-port>                 <!--设置远程服务器端口-->
        <apply-list>                                    <!--设置用于转发的域名-->
                <original-host>google.com</original-host>
                <original-host>facebook.com</original-host>
                <original-host>twitter.com</original-host>
                <original-host>mingpaovan.com</original-host>
                <original-host>wikinews.org</original-host>
                <original-host>joachims.org</original-host>
                <original-host>maiio.net</original-host>
                <original-host>idv.tw</original-host>
                <original-host>mail-archive.com</original-host>
       </apply-list>
    </rule>
</remote-rules>
</pre>
4)配置墙外apn-proxy服务器
a)config.xml主配置文件的配置
<pre>
<?xml version="1.0" encoding="UTF-8" ?>
<apn-proxy>
    <!-- By default, config apn-proxy listen in plain mode act as a normal http proxy server -->
    <!-- <listen-type>plain</listen-type> -->
    <!-- Let apn-proxy listen in ssl mode -->
    <listen-type>ssl</listen-type>                     <!--打开ssl 监听-->
    <!-- ssl mode must config server key store -->
    <key-store>
        <path>conf/keystore.ks</path>                  <!--ssl 私钥，使用keytool命令生成-->
        <password>qwexxxxx</password>                  <!--ssl 私钥密码-->
    </key-store>
    <port>8700</port>                                  <!--监听端口-->
    <thread-count>
        <boss>1</boss>
        <worker>50</worker>
    </thread-count>
    <pac-host>xxxx.com</pac-host>                      <!--监听IP或域名-->
    <use-ipv6>false</use-ipv6>
</apn-proxy>
</pre>
b) remote-rules.xml转发规则文件的配置,因为已经是墙外服务器，不用再转发，这个文件可以为空。
<pre>
<?xml version="1.0" encoding="UTF-8" ?>
<remote-rules>
</remote-rules>
</pre>
c)用keytool命令生成keystore.ks（私钥）和truststore.ks（证书），用于给ssl进行加解密操作。
<pre>
###生成一个RSA的私钥，有效期36500天，秘钥的长度为4096,文件名keystore.ks，给墙外服务器用，放conf目录下面
keytool -genkey -alias xxxx.com -keyalg RSA -keysize 4096 -validity 36500 -keystore keystore.ks
###生成RSA证书请求
keytool -export -alias xxxx.com -keystore keystore.ks -rfc -file cert.pem
###生成证书文件，文件名truststore.ks，给墙内服务器用，放conf目录下面
keytool -import -file cert.pem -keystore truststore.ks -alias xxxx.com
</pre>
5）在两台代理服务器上，分别启动apn-proxy代理，具体方法如下：
<pre>
[root@eagles apn-hg]# cd /opt/apn-hg/
[root@eagles apn-hg]# bash start.sh 
17157
[root@eagles ~]# netstat -antp | grep 8700
tcp        0      0 :::8700                     :::*                        LISTEN      18949/java          
[root@eagles ~]# 
</pre>
6)用户端设置apn-proxy代理的方法
a)在电脑IE 浏览器上设置apn-proxy代理的方法，如下图：
[![client](http://www.m690.com/wp-content/uploads/2014/07/client.jpg)](http://www.m690.com/wp-content/uploads/2014/07/client.jpg)
b)在iphone手机wifi上设置apn-proxy代理的方法，如下图：
[![TM截图未命名](http://www.m690.com/wp-content/uploads/2014/07/TM截图未命名.png)](http://www.m690.com/wp-content/uploads/2014/07/TM截图未命名.png)
访问twitter.com,OK哈，如下图：
[![IMG_2626[1]](http://www.m690.com/wp-content/uploads/2014/07/IMG_26261-576x1024.png)](http://www.m690.com/wp-content/uploads/2014/07/IMG_26261.png)
c)android手机上wifi上设置apn-proxy代理的方法:“WLAN”--“热点名”--“显示高级选项”--“代理设置（选手动）”--"代理主机名（180.xx.x.11）"--"代理服务器端口（8700）",就不给图了哈。
祝大家好运，有问题可以联系我。

官方文档：[apn-proxy](https://github.com/apn-proxy/apn-proxy/wiki/%E4%BD%BF%E7%94%A8%E6%8C%87%E5%8D%97)