---
title: 'HP-UX 让/etc/rc.local也可以使用(2011-01-06 10:34:28)'
tags:
  - HP-UX
  - rc.local
id: 197
categories:
  - HP-UX
date: 2011-07-26 15:48:35
---

> 在linux系统上，当我们要在机器启动时运行一下命令时，经常会把这些命令放到/etc/rc.local文件中运行。在HP-UX上，却没有这个文件，即使加了，不会有效果。怎么让/etc/rc.local生效呢？其实操作起来很简单，虽然做起来有点不正规：）

1、在/sbin/rc文件中最后加一行（这个文件是只读的哈）
<pre class="brush: php">
[root@TC /]# tail -n 1 /sbin/rc
/usr/bin/sh /etc/rc.local
</pre>
2、在/etc/rc.local中加入相应的命令就可以了，比如我这边就启了一个zabbix_agentd程序和增加了一个swap分区，把它的优先级设置的比较低一点，在主交换分区空间不足时，可以用这个交换分区。
<pre class="brush: php">
[root@MEMBDB /]# cat /etc/rc.local
PATH=/opt/softbench/bin:/usr/bin:/usr/ccs/bin:/usr/contrib/bin:/usr/contrib/Q4/bin:/opt/perl/bin:/opt/ipf/bin:/opt/hparray/bin:/opt/nettladm/bin:/opt/fcms/bin:/opt/sas/bin:/opt/wbem/bin:/opt/wbem/sbin:/usr/bin/X11:/opt/resmon/bin:/opt/perf/bin:/usr/contrib/kwdb/bin:/opt/graphics/common/bin:/opt/prm/bin:/opt/sfm/bin:/opt/hpsmh/bin:/opt/upgrade/bin:/opt/wlm/bin:/opt/gvsd/bin:/opt/sec_mgmt/bastille/bin:/opt/drd/bin:/opt/dsau/bin:/opt/dsau/sbin:/opt/firefox:/opt/gnome/bin:/opt/mozilla:/opt/perl_32/bin:/opt/perl_64/bin:/opt/sec_mgmt/spc/bin:/opt/ssh/bin:/opt/swa/bin:/opt/thunderbird:/opt/gwlm/bin:/usr/contrib/bin/X11:/opt/aCC/bin:/opt/caliper/bin:/opt/cadvise/bin:/opt/sentinel/bin:/opt/langtools/bin:/usr/sbin:/usr/local/sbin:/sbin://bin:/usr/sbin:/usr/local/bin
export PATH
/opt/zabbix/bin/zabbix_agentd -c /opt/zabbix/conf/zabbix_agentd.conf
swapon -p 9 /dev/vg00/lvswap02  
</pre>

 