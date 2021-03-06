---
title: 小计：RHEL 6.1 默认启动服务功能说明及调整
tags:
  - rhel6.1
  - 功能说明
  - 调整
  - 默认启动服务
id: 288
categories:
  - linux
date: 2011-09-04 22:12:16
---

<blockquote>今天安装了RHEL6.1，发现系统默认在运行级3上启动了下面的一些服务，有些和RHEL5相比是新的。所以做一些说明。对于服务器来说，默认开启的服务，大多也是不必要的。我加粗的，是我个人认为在服务器上要开的服务。

abrtd  (Automated Bug Reporting Tool) Daemon 用于自动向redhat 发送错误报告，windows好象也有这个功能喔。对于服务器来说，我建议把这个服务给关了。因为我的服务器不能通过外网主动向外发启连接（外网交换机上有ACL）。为了安全，没办法哈。

acpid （ Advanced Configuration and Power Interface）电源管理接口服务，一般笔记本上会用到，服务器就不用了，关了。

atd 这个服务功能和crond 相似，但我一般只用crond,关了吧。

**auditd** 审核守护进程, 审核信息会被发送到一个用户配置日志文件中（默认的文件是 /var/log/audit/audit.log）。如果有审计要求，就开着吧。

**cpuspeed** 该服务可以在运行时动态调节 CPU 的频率来节约能源（省电）。我都不确认我服务器的CPU是否支持这个功能，但我还是愿意响应一下国家节能减排的号召，开一下 ：）。

**crond** 相当于windows里的计划任务，对我来说，是必开的。

haldaemon  硬件监控系统此服务监控硬件改变,一般是用来自动挂载移动硬盘用的.对于线上运行的服务器来说，硬件变更的机会非常的少，也不用自动挂载（而且会有安装问题），所以关了吧。

ip6tables 支持IPV6的iptables 防火墙，我的服务器还没有使用IPV6，所以可以把这个关了。

iptables  支持IPV4的iptables 防火墙，我的服务器在交换机层的ACL已经做的很好了，所以这个我也是关掉了。不过对大多数网络层ACL做得不是很好的用户来说，这个还是开着的好，呵呵。

**irqbalance** 对多个系统处理器环境下的系统中断请求进行负载平衡的守护程序。现在还有单核的服务器吗？对我来说，必开哈。

**kdump**  内核转储服务，kdump会在系统内核崩溃时，启动第二个内核来记录当前内存信息。kdump的dump机制是：预先生成一个crashkernel，在内核crash的时候，激活这个crashkernel，用这个crashkernel载入的小型系统dump处于crash状态的内核。有用，我反正是开着的，这个功能在HP-UX及AIX等小机系统上都有的，对分析系统crash很有用。开着。

lvm2-monitor  LVM2 (Linux volume manager) 监控服务，如果你没有什么LVM2，关了吧。

mdmonitor  software RAID monitoring and management service,如果你没有使用软RAID，关了吧。上面的服务和这个服务是否启动，我个人觉得RHEL应该通过脚本来自动确认，而不应该默认就开着。

messagebus   This service broadcasts notifications of system events and other messages (D-bus).  如果你不用 bluetooth, X Windows 等，就关了吧。

netfs   Network Filesystem Mounter，该服务用于在系统启动时自动挂载网络中的共享文件空间。不用自动挂载，就关了吧。

network  网络服务，这个服务不开，网络就不可用，必开哈。

**postfix**  邮件服务，以前是sendmail,现在改成postfix,用启来更顺手了。默认是监听在127.0.0.1上的，可以开着。

rhnsd  连到RHN进行rhel系统更新。如果你用的是yum,就关了吧。我是关着的，原因你明白的。

rhsmcertd  Red Hat Subscription Manager daemon,**这个服务是RHEL6.1新加的**，用于更好、更方便的使用RHN进行用户的软件升级和管理。上面的不用，下面当然也不用了。

**rsyslog**  系统日志，以前用的是syslogd,现在改成rsyslog了，由原来的UDP传输到现在支持TCP传输了。开着哈。

**sshd**  sshd 服务，如果要进行远程管理和文件传输这是必须的。开着。

**sysstat**  使用sar来进行系统性能统计的服务，很好用，我是开着的。

udev-post  Moves the generated persistent udev rules to /etc/udev/rules.d ,还是那句话，服务器上使用U盘的机会很少，所以这个服务我也关了。

好了，写个脚本来只关掉我不使用的服务：
<pre class="blush: php">

#关掉所有默认开启服务
for i in `chkconfig --list | grep 3:on | awk '{print $1}'`; do echo $i; chkconfig $i off; done
#开启要开启的服务
for i in auditd cpuspeed crond irqbalance kdump network postfix rsyslog sshd sysstat; do echo $i ; chkconfig $i on; done
#check 一下打开的服务
chkconfig --list | grep 3:on
#重启服务器
reboot
</pre>

相关链接：
[http://www.cyberciti.biz/faq/linux-default-services-which-are-enabled-at-boot/](http://www.cyberciti.biz/faq/linux-default-services-which-are-enabled-at-boot/)
[http://www.server-world.info/en/note?os=CentOS_6&p=initial_conf&f=4](http://www.server-world.info/en/note?os=CentOS_6&p=initial_conf&f=4)
[http://www.hao32.com/webserver/335.html](http://www.hao32.com/webserver/335.html)