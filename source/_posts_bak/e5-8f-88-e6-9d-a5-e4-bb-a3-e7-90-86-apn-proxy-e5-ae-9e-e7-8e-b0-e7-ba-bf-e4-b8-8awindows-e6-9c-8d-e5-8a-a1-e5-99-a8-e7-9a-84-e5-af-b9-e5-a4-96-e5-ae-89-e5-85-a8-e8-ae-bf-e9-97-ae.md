---
title: 又来代理--apn-proxy实现线上windows服务器的对外安全访问
tags:
  - apn-proxy
  - proxy
  - secure
  - windows server
id: 785
categories:
  - linux
  - 技术
date: 2014-07-29 10:38:10
---

> 之前我们讨论过了用squid的反向代理来实现线上windows服务器对外的安全访问，又讨论了使用apn-proxy来实现一个smart的用户代理，今天我们讨论一下，如何使用apn-proxy来实现线上服务器对外的安全访问。

无图无真相，先给个架构图吧，与之前的Squid反向代理相似，只是代理服务器换成了apn-proxy:
[![apn-proxy实现https及https的反向代理](http://www.m690.com/wp-content/uploads/2014/07/apn-proxy实现https及https的反向代理.jpg)](http://www.m690.com/wp-content/uploads/2014/07/apn-proxy实现https及https的反向代理.jpg)

从上图中我们可以看出，使用apn-proxy实现了一个7层上的代理，可以控制windows服务器对外访问的域名，这样大大的减少了线上windows服务器对外访问的风险。
因为是做线上服务器的代理，不是用来穿墙的，所以只要用一组apn-proxy服务器就可以了，不用象之前那样，配置墙内和墙外两个代理。具体的安装方法是相同的，很简单，只要安装一下java环境，并解一下包就可以了。可以参考下面的链接：[http://www.m690.com/archives/742](http://www.m690.com/archives/742)

下面讲一下apn-proxy的配置，具体配置方法:
config.xml配置如下：
<pre>
[root@lvs02 conf]# vi config.xml
<?xml version="1.0" encoding="UTF-8" ?>
<apn-proxy>
    <!--By default, config apn-proxy listen in plain mode act as a normal http proxy server-->
   <listen-type>plain</listen-type>  <!--直接使用明文方式,这样客户端配置起来比较通用-->
    <port>8700</port> <!--端口-->
    <thread-count>
        <boss>1</boss>
        <worker>50</worker>
    </thread-count>
    <pac-host>10.xxx.xxx.100</pac-host>  <!-- 设置本机监听ip地址 -->
    <use-ipv6>false</use-ipv6>
    <!-- config the local ip when access the original host -->
    <local-ip-rules>
        <rule>
            <local-ip></local-ip>
            <apply-list>
                <original-host>api.weixin.qq.com</original-host>   <!--设置可以对外代理的域名-->
                <original-host>api.weibo.com</original-host>
            </apply-list>
        </rule>
    </local-ip-rules>
</apn-proxy>
</pre>
remote-rules.xml文件直接全部注释掉就可以了。

客户端的配置直接在IE--internet选项--连接--局域网设置--设置代理服务器 10.xxx.xxx.100:8700 就可以了。程序对外的访问，可以由程序来指向代理。 