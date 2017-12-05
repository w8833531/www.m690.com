---
title: 不拉专线也能去美国－－用xl2tp+openswan 建立一个l2tp over ipsec的VPN
id: 856
categories:
  - 技术
date: 2015-07-30 10:59:39
tags:
---

> 公司为了省成本，把到国外的专线给撤了。问题来了，那有业务要访问国外的站点怎么办呢？想了个省钱的办法，在ucloud香港的linux虚拟机上安装一个VPN，公司里要访问国外站点的，走这个香港的VPN出去。看一去很简单的方案，真正实现却搞了一个多星期，不知道是我技术水平退步了，还是实际的需求与技术实现之间还是有很多问题要处理。
一、先说说需求吧：
1、要可以穿透伟大的GFW，不能被GFW给封IP
2、公司NAT内网内的MAC windows7 系统台式机要可用
3、公司NAT内网内的所有IOS andriod 系统的手机要可用
4、配置要方便，最好不要额外安装软件
5、访问是要被加密的（其实同第一点，不加密，就会被封）
6、要可以被多人多种客户端同时使用，并能满足一定的并发

二、方案选择：
1、刚开始选了opnevpn,但不足是client端要安装，还要导入cert证书文件，这对windows7和MAC还可以接受，但对IOS和andriod的手机用户来说，太麻烦了。
2、使用pptp ,但不足是不加密，只要有人访问一下facebook,一会会GFW就把公司的IP对国外的访问给封了。
3、使用l2tp over ipsec,软件是使用linux系统上的xl2tp+openswan,这个方案可行，所有client端都不用安装客户端，只要进行配置就可以了，而且配置也不算复杂，因为是用ipsec加密的，也不会被封IP。

三、说说碰到的坑：
1坑：使用方案3后，发现MAC IOS andriod都没问题，就windows7的系统拨不上去。原因是因为windows7为了安全，默认如果client和server端都在NAT后，不让使用IPSEC。解决方法是更改windows7 client端的注册表，重启机器就可以拨上去了。
解决方案：导入一个注册表文件后重启机器。
解决方案链接：[http://support.microsoft.com/kb/926179](http://support.microsoft.com/kb/926179 "http://support.microsoft.com/kb/926179")
2坑：这个坑更大，发现如果出口IP 相同（公司有多个出口IP），先拨上去的人会被后面的踢下来，也就是说，同一个出口IP，同时只能有一个client端拨在上面。原因是ipsec 在NAT环境下最多只能有一个VPN主机能建立VPN通道，无法实现多台机器同时在NAT环境下进行通信。
解决方案：使用openswan的KLIPS内核模块，打内核的SAref补丁，并编译内核，使内核支持SAref，让同一出口IP（NAT）后的多个client端可以同时使用l2tp over ipsec拨上来。
解决方案链接（虽然是ubuntu系统的，但centos上一样）：[https://github.com/xelerance/Openswan/wiki/Building-and-installing-an-saref-capable-klips-version-for-ubuntu-lucid](https://github.com/xelerance/Openswan/wiki/Building-and-installing-an-saref-capable-klips-version-for-ubuntu-lucid "https://github.com/xelerance/Openswan/wiki/Building-and-installing-an-saref-capable-klips-version-for-ubuntu-lucid")
3坑：使用KLIPS内核模块后，xl2tpd无法正常使用，一连就crash.
解决方案： 在测试多次后，发现老的xl2tpd的1.3.1的版本是可用的，但由于本人水平有限，根本的问题还是没有找到。

四、服务器应用程序介绍：
1、openswan ,是Linux下IPsec的最佳实现方式，其功能强大，最大程度地保证了数据传输中的安全性、完整性问题。OpenSWan支持2.0、2.2、2.4以及2.6内核，可以运行在不同的系统统平台下，包括X86、X86_64、IA64、MIPS以及ARM。更多详情请参见OpenSWan项目主页：[https://www.openswan.org/](https://www.openswan.org/ "https://www.openswan.org/") 而libreswan是openswan的衍生品。
2、xl2tp,是由 Xelerance维护的linux下的L2TP协议实现软件。
五、具体打kernel的补丁，安装openswan、安装xl2tp操作
操作系统为centos6.5
1、打kernel补丁
<pre>
cd /opt/src
#下载kernel
wget https://www.kernel.org/pub/linux/kernel/v2.6/longterm/v2.6.32/linux-2.6.32.59.tar.xz --no-check-certificate
#下载libswan xl2tpd
wget https://download.libreswan.org/libreswan-3.12.tar.gz --no-check-certificate
wget http://pkgs.fedoraproject.org/repo/pkgs/xl2tpd/xl2tpd-1.3.1.tar.gz/cf61576fef5c2d6c68279a408ec1f0d5/xl2tpd-1.3.1.tar.gz
#解压相关软件
tar -zxvf linux-2.6.32.59.tar.xz
tar -zxvf libreswan-3.12.tar.gz 
tar -zxvf xl2tpd-1.3.1.tar.gz
cd /usr/src
ln -s /opt/src/linux-2.6.32.59 linux
#打内核SAREF补丁
cd linux
patch -p1 < /opt/src/libreswan-3.12/patches/kernel/2.6.32/0001-SAREF-add-support-for-SA-selection-through-sendmsg.patch 
patch -p1 < /opt/src/libreswan-3.12/patches/kernel/2.6.32/0002-SAREF-implement-IP_IPSEC_BINDREF.patch 
sed -i '/^obj-$(CONFIG_XFRM).*xfrm\/$/  aobj-$(CONFIG_KLIPS)\t\t+= ipsec\/' net/Makefile
cp /boot/config-2.6.32-431.11.5.el6.ucloud.x86_64 .config
echo y | make oldconfig
#vi .config #打开 CONFIG_INET_IPSEC_SAREF=y
#编译内核
cat << EOF >> make.sh
cd /usr/src/linux
make -j4 bzImage
make -j4 modules
make -j4 modules_install
make -j4 install
EOF
nohup bash make.sh &
#vi /etc/grub.conf  #设置 default=0指向最新的内核
#编译安装 libreswan
cd /opt/src/libreswan-3.12
yum -y install nss-devel nspr-devel pkg-config pam-devel \
                libcap-ng-devel libselinux-devel \
                curl-devel gmp-devel flex bison gcc make \
                fipscheck-devel unbound-devel
make -j4 programs
make -j4 install
#配置libreswan
#vi /etc/ipsec.conf
config setup
        dumpdir=/data/logs/
        nat_traversal=yes
        virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:25.0.0.0/8
        oe=off
        interfaces="%defaultroute"
        protostack=mast
        plutostderrlog=/data/logs/ipsec.log
conn L2TP-PSK-noNAT
        authby=secret
        pfs=no
        mtu=1500
        auto=add
        keyingtries=3
        forceencaps=yes
        rekey=no
        overlapip=yes
        sareftrack=yes
        ikelifetime=8h
        keylife=1h
        type=transport
        left=10.8.4.241
        leftprotoport=17/1701
        right=%any
        rightprotoport=17/%any
vi ipsec.secrets 
%any %any: PSK "password"
#启动ipsec
service ipsec start
chkconfig ipsec on
#编译安装 xl2tpd
cd xl2tpd-1.3.1
make -j4
make install
#配置xl2tpd
#vi  /etc/xl2tpd/xl2tpd.conf
[global]
ipsec saref = yes
saref refinfo = 30
force userspace = yes
debug network = yes
debug avp = yes
debug state = yes
[lns default]
ip range = 192.168.0.2-192.168.0.254
local ip = 192.168.0.1
assign ip = yes
require chap = yes
refuse pap = yes
require authentication = yes
name = 525tVPNserver
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
#vi /etc/ppp/options.xl2tpd
ipcp-accept-local
ipcp-accept-remote
ms-dns  8.8.8.8
noccp
auth
crtscts
idle 1800
mtu 1410
mru 1410
nodefaultroute
debug
lock
proxyarp
connect-delay 5000
#启动xl2tpd
/usr/local/sbin/xl2tpd -c /etc/xl2tpd/xl2tpd.conf -D 
#设置iptables 
iptables -A POSTROUTING -s 192.168.0.0/24 -o eth0 -j MASQUERADE
</pre>