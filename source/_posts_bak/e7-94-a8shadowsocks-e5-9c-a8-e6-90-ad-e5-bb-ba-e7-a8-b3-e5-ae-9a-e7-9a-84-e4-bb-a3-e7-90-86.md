---
title: 用shadowsocks-libev tunnel模式搭建一个稳定的可分用户的可进行流量限制的跨国代理
tags:
  - shadowsocks
  - 代理，tunnel
id: 1000
categories:
  - vpn
date: 2016-06-23 18:09:29
---

> 最近在首都在线申请了两台机器，一台在美国，一台在国内。这两台机器之间免费送5M的GPN全球互联流量。这个很好，可以用这5M免费的流量，最主要这5M的带宽质量很高，200ms延时，但基本上没有丢包。用这个做跨国代理再好不过了

**先上个架构图，方便理解**
[![architecture](http://www.m690.com/wp-content/uploads/2016/06/architecture-1024x539.jpg)shadowsocks tunnel architecture](http://www.m690.com/wp-content/uploads/2016/06/architecture.jpg)

**在两台Centos6.5上安装 shadowsocks-libev**
<pre>
yum install build-essential autoconf libtool openssl-devel gcc -y
yum install git -y
git clone https://github.com/madeye/shadowsocks-libev.git
cd shadowsocks-libev
./configure
make -j 4 && make install
</pre>

**在GATE_CHINA上运行ss-tunnel,注：192.168.10.2 是对端GATE_US的GPN ip地址,211.228.xxx.xxx是GATE_CHINA的外网地址，-l 10010是端口， xxxxxxx10是密码，rc4-md5是加密方式**
<pre>
/usr/local/bin/ss-tunnel -s 192.168.10.2 -p 10010 -l 10010 -k xxxxxxx10 -m rc4-md5 -t 60 -f /tmp/ss-10010.pid -n 3000 -b 221.228.109.xxx -L 192.168.10.2:10010 -u
#-s server side ipaddr
#-p server side port
#-l local port
#-k password
#-m encrypt
#-t timeout
#-f pid file name
#-n max open files
#-b local ipaddr
#-L tunnel forward server side ipadd & port
#-u enable udp forward
</pre>

**在GATE_US上运行ss-server**
<pre>
/usr/local/bin/ss-server -s 192.168.10.2 -p 10010 -k xxxxxxx10 -m rc4-md5 -t 60 -f /tmp/ss-10010.pid -n 3000 -u
</pre>

**在GATE_US上，对10010端口出口流量进行限制**
<pre>
tc_dev=eth1
classid=1001
limit=2048
port=10010
#delete & add tc qdisc root on tc_dev
/sbin/tc qdisc del dev ${tc_dev} root
/sbin/tc qdisc add dev ${tc_dev} root handle 1:0 htb default 10
#clear iptables mangle 
iptables -F -t mangle
#add a htb  $classid & set bandwith limit to $limit
/sbin/tc class add dev ${tc_dev} parent 1:0 classid 1:${classid} htb rate ${limit}kbit burst 10k
#add a iptables mangle point to $port & set mark to $port
/sbin/iptables -A OUTPUT -t mangle -p tcp --sport $port -j MARK --set-mark $port
#set filter handle $port and link to bandwith rate limit tc $classid  
/sbin/tc filter add dev ${tc_dev} parent 1:0 prio 0 protocol ip handle $port fw flowid 1:${classid}"
</pre>

ok,在 [https://shadowsocks.org/en/download/clients.html](https://shadowsocks.org/en/download/clients.html) 安装好windows或IOS 或 android 或linux的客户端后，配置下面的内容，就可以访问google拉。
211.228.xxx.xxx是GATE_CHINA的外网地址，-l 10010是端口， xxxxxxx10是密码，rc4-md5是加密方式。

如果是有多人使用，可以给每个人分配一个端口和密码及不同的流量限制，这样，就可以供公司不同人员使用了。欢迎大家一起讨论。
最后给一个完整的配置脚本：
<pre>
#用户配置文件，包括用户名、端口、密码、流量限制（Kbit)，可以把这些信息给不同的用户，实现不同用户，不同端口密码，不同流量限制。
[root@GATE_WX ~]# cat account.txt 
#username:port:password:bandwith_limit(Kbit)
user1:10001:xxxxxx1:2048
user2:10002:xxxxxx2:2048
user3:10003:xxxxxx3:1024
user4:10004:xxxxxx4:1024
user5:10005:xxxxxx5:1024
user6:10006:xxxxxx6:1024
user7:10007:xxxxxx7:1024
user8:10008:xxxxxx8:1024
user9:10009:xxxxxx9:1024
user10:10010:xxxxxx10:1024
user11:10011:xxxxxx11:1536
#在两台GATE上运行命令的脚本：
[root@GATE_WX ~]# cat ss_restart.sh
#!/bin/bash
#Usage:This script is used to restart shadowsocks-libev service and set tc network trafic control,This script run on GATE_CHINA
#Author:WuYing
#Date:20160615 create script
#Date:20160624 add TC network trafic control

### define config
#config file
account_file=/root/account.txt
#GATE_US GPN ip addr
server_host=192.168.10.2
encrypt_method=rc4-md5
timeout=60
#set connection limit per port
max_open_files=3000
#shadowsocks client connect ip
local_address=221.228.xxx.xxx
#tc network trafic control dev on GATE_US
tc_dev=eth1
#tc class id it could not large than 10000
classid=1001

###echo date
echo "===========at `date` start ss restart ============="

###stop ss-tunnel on local
killall ss-tunnel 
sleep 1
ps -efww | grep -v grep | grep ss-tunnel && killall -9 ss-tunnel  

### stop ss-server & delete addn tc qdisc root & clear iptables -t mangle on remote server
ssh  ${server_host} "killall ss-server; sleep 3; ps -efww | grep -v grep | grep ss-server && killall -9 ss-server;\
            /sbin/tc qdisc del dev ${tc_dev} root;/sbin/tc qdisc add dev ${tc_dev} root handle 1:0 htb default 10;\
            iptables -F -t mangle"

###read port & password & trafic limit from account_file then start ss-tunnel ss-server tc
for i in `cat $account_file | grep -v '#' | grep ':'`
do
  ### read account info
    port=`echo $i | awk -F: '{print $2}'`
    passwd=`echo $i | awk -F: '{print $3}'`
    limit=`echo $i | awk -F: '{print $4}'`
    pid_file=/tmp/ss-$port.pid
    log_file=/var/log/ss-$port.log
  ### start ss-tunnel on local server
    /usr/local/bin/ss-tunnel -s ${server_host} -p $port -l $port -k $passwd -m ${encrypt_method} -t ${timeout}  -f ${pid_file} -n ${max_open_files} -b ${local_address} -L ${server_host}:$port -u > ${log_file} 2>&1 & 
  ### restart ss-server & add tc class & add iptables & add tc filter on remote server
    ssh  ${server_host} "/usr/local/bin/ss-server -s ${server_host} -p $port  -k $passwd -m ${encrypt_method} -t ${timeout}  -f ${pid_file} -n ${max_open_files}   -u > ${log_file} 2>&1 &"
    ssh  ${server_host} "/sbin/tc class add dev ${tc_dev} parent 1:0 classid 1:${classid} htb rate ${limit}kbit burst 10k;\
              /sbin/iptables -A OUTPUT -t mangle -p tcp --sport $port -j MARK --set-mark $port;\
              /sbin/tc filter add dev ${tc_dev} parent 1:0 prio 0 protocol ip handle $port fw flowid 1:${classid}"
    classid=$(($classid+1));
    echo "=========$classid==========";
done 
</pre>