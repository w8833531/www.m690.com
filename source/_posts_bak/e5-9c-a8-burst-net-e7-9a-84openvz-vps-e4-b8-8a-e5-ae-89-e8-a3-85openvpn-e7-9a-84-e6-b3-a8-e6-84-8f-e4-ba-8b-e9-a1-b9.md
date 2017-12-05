---
title: 在 burst.net的OpenVZ  VPS上安装openvpn的注意事项
tags:
  - open_vpn
  - vps
  - 安装
id: 150
categories:
  - open_vpn
date: 2011-07-26 14:05:14
---

> 前些天在burst.net上买了个OpenVZ的VPS（512M 20G 1T Centos5.5 64bit $6/Moth)。今天在上面安装openvpn,时发现了几个问题，与大家分享一下。

    1、openvpn安装完成后，无法正常启动，报"Cannot allocate TUN/TAP dev dynamically"错误。

      原因：VPS 的Centos5.5的kernel tun模块没有加载

      解决方法：登录VPS的WEB控制台，把tun/tap选项打开，默认为关闭。会重启VPS。

    2、用iptables 做MASQUERADE时，无法完成，显示如下：
<pre class="brush: php">

       iptables -t nat -A POSTROUTING -s 192.168.3.0/24 -o venet0 -j MASQUERADE

       iptables: Unknown error 18446744073709551615
</pre>
      原因：VPS的iptables不支持MASQUERADE

      解决方法：使用SNAT，命令如下：
<pre class="brush: php">

        iptables -t nat -A POSTROUTING -s 192.168.3.0/255.255.255.0 -j SNAT --to-source 184.82.xxx.xxx
</pre>