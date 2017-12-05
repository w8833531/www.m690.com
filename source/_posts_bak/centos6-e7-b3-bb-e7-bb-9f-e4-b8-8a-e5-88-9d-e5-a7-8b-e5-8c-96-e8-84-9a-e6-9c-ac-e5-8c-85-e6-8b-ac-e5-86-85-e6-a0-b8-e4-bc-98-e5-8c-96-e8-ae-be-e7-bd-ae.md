---
title: CentOS6系统初始化脚本--包括内核优化设置
tags:
  - Centos
  - init
  - 系统初始化，内核优化
id: 887
categories:
  - linux
  - 技术
date: 2015-02-28 22:50:32
---

> 很久没整理的系统初始化脚本，贴出来，再对ulimit和sysctl 部分再做个review

脚本及说明如下：
<pre>
#!/bin/bash
### Usage: This script use to config linux system  
### Author:Larry wu
### Email: wuying@corp
### First variable setting 设置主机名/root密码/DNS
hostname=eagle3.m690.com
password=your_password
nameserver=10.x.x.x
### service config 设置打开的服务
for i in `chkconfig --list | awk '{print $1}' `; do echo $i; chkconfig $i off; done
for i in auditd cpuspeed irqbalance sysstat sshd rsyslog network crond iptables; do chkconfig $i on; done
### sshd config 设置ssh key认证
echo "Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
KeyRegenerationInterval 3600
ServerKeyBits 768
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 600
PermitRootLogin yes
PubkeyAuthentication yes
AuthorizedKeysFile      .ssh/authorized_keys
IgnoreRhosts yes
HostbasedAuthentication no
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UseDNS no
MaxStartups 20
Subsystem       sftp    /usr/libexec/openssh/sftp-server" > /etc/ssh/sshd_config
mkdir ~/.ssh/
chmod 700 ~/.ssh/
echo "ssh-dss AAAAB3NzaC1kc3MAAACBALMeZWzukfaXvobuJcGIVJZvlHvhfl+3AM6Gj2uLOdgzwtDSHx6BC6ZPOwM/9gj9jBRQ5+3w3HkBQz2+fcX5RyKcRFWxgdmo2noB51Gii7mJOHE6+CtLguD/XJZSne2tt9dl8zfgrjNAD9SHFFS/T1gh/jWz+e0rUVlGLmt1LuGVAAAAFQDibrsqPgwpthzSm4fIH+c0OPU7WQAAAIAeJHVulfEhnDqQ6f8yqWhSPTW+BeutNFwrFCslYaqPy8G5hU+gYakg7OMCA0z3EEBb6kpRjNuwMXCkJMzJOqYsNzeboQmYTqrP0CZMrhApNXl0R7ndmJeUE67ofw0/H78dC6qqlg8zGzE2s0kj0TLK6QHEWMGsYo+RJAjpmJuZ+QAAAIAQPgOfHroBqrSCd+QBxN1NBPV9HgsEaWmYhXOTAKuw+Jzg86QUVzIn67gXIf09WOTx96XydzOCYLBHRhnXyF4AEzB+fDc6+sXJZC2AEHlIKGO6vceY6nS8wdZ8pyWUuNHSlzXodz9+1u8odqjhqlFi/ZbtHNHU+rU6+mJLxKz5Ow== wuying@the9 " > ~/.ssh/authorized_keys
service sshd restart
### set dns server 设置DNS
echo "nameserver $nameserver" > /etc/resolv.conf
###disable selinux 关selinux
perl -pi.bak -e 's/SELINUX=enforcing/SELINUX=disalbed/gi' /etc/selinux/config
### ulimit setting 设置limit,只对root用户有效果，如果要设置其它用户，请更改/etc/security/limits.conf文件
echo "ulimit -HSc unlimited" >> /etc/bashrc       #取消core文件大小限制
echo "ulimit -HSn 65535" >> /etc/bashrc           #设置root用户打开最大文件数为65535
echo "ulimit -HSu 10240" >> /etc/bashrc           #设置root用户最大打开进程数为10240
#### sysctl.conf setting  设置内核参数
cat >> /etc/sysctl.conf << EOF
###设置用户最大使用内存为 SWAP+80%物理内存总量  ，并先用物理内存
vm.swappiness = 0      #先用物理内存
vm.overcommit_memory = 2    #设置用户最大使用内存为 SWAP+vm.overcommit_ratio%*物理内存总量
vm.overcommit_ratio = 80
###设置core文件放的位置
kernel.core_pattern = /opt/core/core_%h_%e_%p_%t
###设置系统最大打开文件数
fs.file-max = 209708
###下面的TCP内核参数的调整都是为了让服务器可以应对大的或突发性的连接数（如上万的ESTALISH连接），这些调整在nginx/squid/varnish/httpd/ftp这样有会产生大量的TCP连接的应用上，是需要的。
##最大的TCP数据接收窗口（字节）
net.core.wmem_max = 873200
##最大的TCP数据发送窗口（字节）
net.core.rmem_max = 873200
##每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的最大数目,默认是300
net.core.netdev_max_backlog = 2048
##定义了系统中每一个端口最大的监听队列的长度，这是个全局的参数。
net.core.somaxconn = 1024
##下面的三个要一起看，第一个net.ipv4.tcp_mem[0][1][2]表示TCP整体内存使用，计算方式是值*内存页大小4K；三个值分别是低于[0]值,表示TCP没有内存压力，在[1]值下,进入内存压力阶段，大于[2]高于此值,TCP拒绝分配连接。net.ipv4.tcp_wmem[0][1][2]分别表示最小发送内存，默认发送内存，最大发送内存；结合上面的net.ipv4.tcp_mem[0][1][2]三个值，当TCP总内存占用小于tcp_mem[0]时，可以分配小于tcp_wmem[2]的内存给一个TCP连接；当TCP内存占用大于tcp_mem[0]时，可以分配tcp_wmem[0]的内存；当TCP总内存占用大于tcp_mem[1]，小于tcp_mem[2]时，可以分配tcp_wmem[0]的内存；当TCP总内存占用大于tcp_mem[2]时，tcp内存分析无法进行。net.ipv4.tcp_rmem的三个值的解释同上。
net.ipv4.tcp_mem = 786432  1048576 1572864  #设置[0][1][2]分别为3G、4G、6G
net.ipv4.tcp_wmem = 8192  436600  873200   #设置TCP发送缓存分别为：最小8K，默认400k,最大800K
net.ipv4.tcp_rmem = 8192  436600  873200   #设置TCP接收缓存分别为：最小8K，默认400k,最大800K
net.ipv4.tcp_retries2 = 5  #TCP失败重传次数,默认值15,意味着重传15次才彻底放弃.可减少到5,以尽早释放内核资源
net.ipv4.tcp_fin_timeout = 30  #表示如果套接字由本端要求关闭，这个参数决定了它保持在FIN-WAIT-2状态的时间
net.ipv4.tcp_keepalive_time = 1200  #表示当keepalive起用的时候，TCP发送keepalive消息的频度。缺省是2小时，改为20分钟
net.ipv4.tcp_syncookies = 1  #开启SYN Cookies。当出现SYN等待队列溢出时，启用cookies来处理，可防范少量SYN攻击
net.ipv4.tcp_tw_reuse = 1  #表示开启重用。允许将TIME-WAIT sockets重新用于新的TCP连接，减少TIME-WAIT 状态
net.ipv4.tcp_tw_recycle = 1  #表示开启TCP连接中TIME-WAIT sockets的快速回收
net.ipv4.ip_local_port_range = 1024    65000  #增大本地端口数，对于发启很多对外的连接时有用
net.ipv4.tcp_max_syn_backlog = 8192 # 进入SYN包的最大请求队列.默认1024.对重负载服务器,增加该值显然有好处
net.ipv4.tcp_max_tw_buckets = 5000  #表示系统同时保持TIME_WAIT套接字的最大数量，如果超过这个数字，TIME_WAIT套接字将立刻被清除并打印警告信息，默认为180000
###这四个是用来设置lvs实体机用的，如果你的机器不使用lvs的DR方式，可以不加这几个参数
net.ipv4.conf.lo.arp_ignore = 1  
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
EOF
###设置eth0上的路由，如果不默认网关在eth0上，就不用设置了
#cat > /etc/sysconfig/network-scripts/route-eth0 << EOF
#10.0.0.0/8 via 10.126.40.254
#EOF
mkdir /opt/core
###更改root用户的密码
echo $password | passwd root --stdin
echo 'NETWORKING=yes' > /etc/sysconfig/network
echo "HOSTNAME=$hostname" >> /etc/sysconfig/network
###reboot
#reboot
</pre>