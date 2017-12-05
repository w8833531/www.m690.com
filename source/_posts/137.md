---
title: 原创：rhel6上配置openvpn穿越公司防火墙
tags:
  - GWF
  - open_vpn
  - rhel6
  - vps
  - 防火墙
id: 137
categories:
  - open_vpn
date: 2011-07-26 11:22:06
---

一、先说说目的

> 我想大家都会有这样的遭遇：在公司里，想上一下淘宝网或是开心网，却发现这些网址都已经被公司网管给封掉了，真是郁闷啊。今天，我们就来说说，如何利用openvpn来跳过这些限制。要实现这个功能，最重要的一点是你在公司外有一台没有限制对外发起连接的机器，不管是你家里开着已经连上网的台式机，还是在国外购买的托管的服务器。有了这一点，再加上一个openvpn的软件，就搞定了。现在开始我们的解锁之旅。当然，公司的限制可以搞定，如果你在国外有台VPS的话，那GWF的限制你也可以搞定了，自己举一反三吧，我这里就不多说了，哈哈。

二、再说说硬件环境及软件环境及实现所需要的知识水平：

    1、自己家里安装了rhel 6的一台可以连上网的linux台式机（当然 ，在国外有台VPS那就更好了）

    2、在rhel6上安装最新有openvpn软件

    3、对个人要求熟悉linux的基本命令、网络配置及在linux上编译安装软件

三、说说具体的实现方式

1、先让自家的这台linux连上网，操作上很简单：

   1）安装pppd 和 rp-pppoe 软件包
<pre class="brush: php">
      rpm -ivh rp-pppoe-3.10-8.el6.x86_64.rpm
      rpm -ivh ppp-2.4.5-5.el6.x86_64.rpm
</pre>

   2）使用pppoe-setup 命令进行ppp配置，设置成开机自动拨号

   3）使用pppoe-start 命令拨号上网

   上面的内容不是本文的重点，如果大家对这些不熟悉，可以看一下下面的[链接](http://www.mocentr.com/molife/home-space-uid-1-do-blog-id-177.html ) （我只是随便google了一把，呵呵）

2、申请一个free的动态域名

   申请这上是为了让你在公司里也可以知道你家里机器拨号后的IP地址。你可以到 http://www.3322.org 上申请一个动态域名，很快的，而且是free的。我是常州人，"希网“这个公司也在常州，我给自家的公司打个广告了，呵呵。

   举例，如果你已经申请好了aaatest.3322.org这个动态域名，密码是123456，那么你只要在 /etc/rc.local下面加这机两行就可以了(如果没有安装lynx,请安装一下）：
<pre class="brush: php">

sleep 60
/usr/bin/lynx -mime_header -auth=aaatest:123456 "http://www.3322.org/dyndns/update?system=dyndns&hostname=aaatest.3322.org"
</pre>

这样你在公司就可以用aaatest.3322.org这个域名直接ssh到你有电脑上了，当然你的电脑是要开着。什么？公司把对外的22口给封了？那你就只能把sshd监听在80口上了，哈哈。

3、安装openvpn
   1.使用yum安装必要的软件 (openssl & gcc)
<pre class="brush: php">
        yum install openssl
        yum install gcc
        yum install openssl-devel
</pre>
        如果不熟悉yum安装，可以google一下，关键字：rhel yum 安装 本地源
   2.获取并编译安装最新版本的压缩库lzo
<pre class="brush: php">
        wget wget http://www.oberhumer.com/opensource/lzo/download/lzo-2.04.tar.gz
        tar -zxvf lzo-2.04.tar.gz
        cd lzo-2.04
        ./configure && make && make check && make install
</pre>

   3.获取并编译安装最新版本的openvpn
<pre class="brush: php">
        wget http://openvpn.net/release/openvpn-2.1.3.tar.gz
        cd openvpn-2.1.3
        ./configure && make && make install
</pre>  
4.配置 server端的openvpn
   1\. 生成相关的key文件
<pre class="brush: php">
         cd easy-rsa/
         source ./vars
         ./clean-all
         ./build-ca       #生成根证书
         ./build-key-server server   #生成server证书
         ./build-key wuying     #生成用户client端证书
         ./build-dh
         cd keys ; openvpn --genkey --secret ta.key ;
</pre>
   2\. CP这些证书到对应的目录中
<pre class="brush: php">
        mkdir -p /etc/openvpn/server/keys/   #server端证书目录
        cp ca.* /etc/openvpn/server/keys/
        cp server.* /etc/openvpn/server/keys/
        cp dh1024.pem /etc/openvpn/server/keys/
        cp ta.key  /etc/openvpn/server/keys/
        mkdir -p /etc/openvpn/client/keys/    #client端证书目录
        cp wuying.* /etc/openvpn/client/keys/
        cp ca.crt /etc/openvpn/client/keys/
        cp ta.key /etc/openvpn/client/keys/
</pre>
   3\. 配置openvpn server端配置文件
<pre class="brush: php">
        vi /etc/openvpn/server.conf
        port 443        #openvpn监听端口
        proto tcp       #使用协议
        dev tap         #使用设备
        ca /etc/openvpn/server/keys/ca.crt
        cert /etc/openvpn/server/keys/server.crt
        dh /etc/openvpn/server/keys/dh1024.pem
        server 192.168.3.0 255.255.255.0         #使用的VPN网段
        ifconfig-pool-persist /etc/openvpn/server/log/ipp.txt
        push "redirect-gateway def1 bypass-dhcp"  #重要：使client端拨上来后，使用这台机器做为网关 
        push "dhcp-option DNS 116.228.111.18"     #PUSH一个DNS
        client-to-client    # VPN client端可以互连
        keepalive 10 120
        comp-lzo
        max-clients 10
        user nobody
        group nobody
        persist-key
        persist-tun
        status /etc/openvpn/server/log/openvpn-status.log
        log-append         /data/log/openvpn.log   #详细日志存放目录
        #crl-verify /etc/openvpn/server/keys/crl.pem
        verb 5
</pre>
 在完成配置后，做下面的操作启动openvpn服务
<pre class="brush: php">
        mkdir /data/log  #生成日志目录
        cp openvpn-2.1.3/sample-scripts/openvpn.init /etc/init.d/openvpn   #CP启动脚本
        chkconfig openvpn on     #开机启动
        server openvpn on        #启动VPN
</pre>
    4\. 测试openvpn是否已经启动正常
 在公司内的windows机器上telnet,如果可以成功，则证明openvpn已经工作正常。

<pre class="brush: php">
        telnet aaatest.3322.org 443  
</pre>
    5\. 设置系统参数及iptables，使连上来的client端可以通过openvpn访问外网
 设置IP转发：
<pre class="brush: php">
        sysctl net.ipv4.ip_forward=1 ; echo "sysctl net.ipv4.ip_forward = 1" >> /etc/rc.local
 设置iptables的nat转发:
        iptables -F ; iptables -F -t nat ; iptables -t nat -A POSTROUTING -s 192.168.3.0/24 -j MASQUERADE
        service iptables save
        chkconfig iptables on
</pre>
5、 在公司机windows机器上安装和设置client端的openvpn
   1.到下面的链接下载最新的[openvpn  for windows](http://www.openvpn.net/index.php/open-source/downloads.html) 版本
   2.在公司中的windows台式机中安装这个程序，一路next就可以了。
   3.把你的rhel linux server端的/etc/openvpn/client/keys/ 目录中的文件CP到"C:\Program Files\OpenVPN\config"目录下面
   4.在"C:\Program Files\OpenVPN\config"目录下生成用户端配置文件 wuying.ovpn ,内容如下：
<pre class="brush: php">
        client
        dev tap    #与server端配置对应
        proto tcp   #与server端配置对应
        remote aaatest.3322.org 443     #server端主机名及端口
        resolv-retry infinite
        nobind
        persist-key
        persist-tun
        ca "C:\\Program Files\\OpenVPN\\config\\ca.crt"
        cert "C:\\Program Files\\OpenVPN\\config\\test2.crt"
        key "C:\\Program Files\\OpenVPN\\config\\test2.key"
        tls-auth "C:\\Program Files\\OpenVPN\\config\\ta.key" 1
        ns-cert-type server
        comp-lzo
        verb 4
</pre>
    5.点击桌面openvpn图标，进行连接，如果连接成功：
    你在cmd窗口运行 ipconfig 命令中会看到如下显示：
<pre class="brush: php">
        Ethernet adapter 本地连接 4:

        Connection-specific DNS Suffix  . :
        IP Address. . . . . . . . . . . . : 192.168.3.2              #vpn client端获得的IP
        Subnet Mask . . . . . . . . . . . : 255.255.255.0       
        Default Gateway . . . . . . . . . : 192.168.3.1       #vpn server端IP，现在是默认网关
</pre>
    你在cmd窗口运行 nslookup 命令中会看到如下显示： 
<pre class="brush: php">
        C:\Documents and Settings\larry>nslookup
        Default Server:  ns-cx1.online.sh.cn
        Address:  116.228.111.18       #DNS指向了VPN Server中PUSH的IP
</pre>  
    你再打开IE试一下，看是否已经可以访问淘宝网站了？OK，我们的目的达到了。

6、最后，我给个server端的脚本，用来生成client端的证书，并打成一个"用户名.tgz"的文件，如果公司里有其它同事想用你的VPN Server，你把运行脚本后生成的这个包给他们，让他们把包中的文件解开后CP到"C:\Program Files\OpenVPN\config"目录下就可以了。
<pre class="brush: php">
 [root@eagle ~]# cat /data/script/openvpn_client.sh
  #!/bin/bash
  #This script use to create openvpn client account
  user_name=$1
  rsa_script_dir=/data/src/openvpn/openvpn-2.1.3/easy-rsa/2.0
  client_key_dir=/etc/openvpn/client/keys
  server_key_dir=/etc/openvpn/server/keys
  if [ "${user_name}" == "" ];then
          echo "USAGE: $0 <account_name>"
          exit 1
  fi
  cd ${rsa_script_dir}
  source ./vars
  ./build-key ${user_name}
  mkdir ${client_key_dir}/${user_name}/
  cp keys/${user_name}.* ${client_key_dir}/${user_name}/
  cp ${client_key_dir}/ca.crt ${client_key_dir}/${user_name}/
  cp ${client_key_dir}/ta.key ${client_key_dir}/${user_name}/
  perl -pi.bak -e "s/username/${user_name}/gi" ${client_key_dir}/client.ovpn
  mv ${client_key_dir}/client.ovpn ${client_key_dir}/${user_name}/${user_name}.ovpn
  mv ${client_key_dir}/client.ovpn.bak ${client_key_dir}/client.ovpn
  cd ${client_key_dir}
  tar -zcvf ${user_name}.tgz ${user_name}
</pre> 
 需要一个client端的模板文件，内容如下：
<pre class="brush: php"> 
[root@eagle ~]# cat /etc/openvpn/client/keys/client.ovpn
  client
  dev tap
  proto tcp
  remote aaatest.3322.org 443
  resolv-retry infinite
  nobind
  persist-key
  persist-tun
  ca "C:\\Program Files\\OpenVPN\\config\\ca.crt"
  cert "C:\\Program Files\\OpenVPN\\config\\username.crt"
  key "C:\\Program Files\\OpenVPN\\config\\username.key"
  tls-auth "C:\\Program Files\\OpenVPN\\config\\ta.key" 1
  ns-cert-type server
  comp-lzo
  verb 4 
</pre>
 如果你不想某个公司同事来访问你的VPN，你可以直接在server端用下面的命令吊销他的证书就可以了
<pre class="brush: php">
  cd /data/src/openvpn/openvpn-2.1.3/easy-rsa/2.0
  ./revoke-full 用户名
</pre>
  （注意：如果你吊销证书，请cp crl.pem文件到/etc/openvpn/server/keys/目录，并把openvpn服务器端的/etc/openvpn/server.conf文件中下面的这行注释打开
<pre class="brush: php">
   #crl-verify /etc/openvpn/server/keys/crl.pem ）
</pre>