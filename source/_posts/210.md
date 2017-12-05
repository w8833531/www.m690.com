---
title: '使用 EMC solutions Enabler  查看命令对DMX3进行主动监控(2011-04-11 13:36:20)'
tags:
  - dmx3
  - emc
  - solution enabler
  - 主动监控
id: 210
categories:
  - EMC
date: 2011-07-26 16:24:07
---

> 最近，公司的DMX3 要过保了。问了一下EMC原厂的续保价格，高得惊人，已经和抢钱差不多了。后来用EMC solutions Enabler 看了一下设备出错历史日志。从日志看，从2009年10月到2011年4月，公司的EMC DMX3 一共换了4块磁盘，4个SP，其它的都没有出现过问题，相对来说，还是比较稳定的。因为EMC的Symmetrix系统是一个封闭系统，要更换DMX的设备需要从专用的控制台登录（而且这个控制台的登录密码是RSA一次性密码，有时效的，EMC工程师过来都得做申请），用专用的软件进行check和更换。

     考虑到如此高的维保价格，我们也尝试让与EMC有合作关系的第三方来做维保。只要有备件及相应的管理控制台密码，还是可以做的。价格是EMC的一半以下。同时也出现了一个问题，如何对EMC设备故障进行主动监控，以前这个事是EMC帮我们做了（如果设备有问题，系统会自动向外拨号并发送故障信息给EMC，相关维修人员就会主动通知我们进行设备更换了）。

    这两天试了一下EMC solutions Enabler Symmetrix Array Management CLI Version 6.5功能，还是可以做到的。下面说一下监控方法，其实还是很简单。

    用MC solutions Enabler Symmetrix Array Management CLI Version 6.5的 symevent命令就可以实现这个功能。symevent命令主要是用来显示DMX系统日志的，相关设备问题报警都会在里面：

    如果我们要看一下所有的设备报警日志，可以使用下面的命令：

    **./symevent list -warn**

    如果我们要看一下从2011-3-29到2011-4-1号的设备报警，你可以用下面的命令：

    **./symevent list -warn -start 03/29/2011:00:00:00  -end 04/01/2011:00:00:00**
<pre class="blush: php">
Symmetrix ID: xxxxxxxxxxxxx

Time Zone   : EAT

Detection time           Dir    Src  Category     Severity     Error Num
------------------------ ------ ---- ------------ ------------ ----------
Tue Mar 29 04:07:02 2011 DF-2A  SP   Environment  Error        0x0070
    Environmental Error: Supplemental Power Supply low input AC Voltage

Tue Mar 29 15:04:18 2011 DF-2C  SP   Environment  Error        0x0066
    Environmental Error: Power Supply A faulted

Tue Mar 29 15:04:25 2011 DF-15C SP   Environment  Error        0x0066
    Environmental Error: Power Supply A faulted

Tue Mar 29 15:04:25 2011 DF-2D  SP   Environment  Error        0x0066
    Environmental Error: Power Supply A faulted   
</pre>
    可以写个脚本来监控当天的系统报警日志：
<pre class="blush: php">
    #!/usr/local/bin/bash
    MAILLIST="wuying@xxx.xxx.com"
    for i in Warn Error Fatal
    do
      /opt/emc/SYMCLI/V6.5.3/bin/symevent list -warn -start `date +%x:00:00:00` -end `date +%x:23:59:00` > /tmp/symevent.txt
      cat  /tmp/symevent.txt | grep $i && cat /tmp/symevent.txt   | mailx -s "Symmetrix Device $i" ${MAILLIST}
    done
</pre>
    加个计划任务:
<pre class="blush: php">
    #check  Symmetrix device warn everyday 
    59 23 * * * /symevent.sh
</pre>

    完成上面的工作后，我们就可以进行通过这个EMC solutions Enabler  工具，对我们的DMX3设备情况进行主动监控了。

    下面再发几个有用的查看命令（因为DMX的封闭性，本人还没有把握进行DMX系统的配置，现在仅限与查看)：

    1.查看存储的基本信息：

      **./symcfg list -v**

    2.查看连接主机的应用安装情况：

    ** ./symcfg list -applications**

    3.查看连接主机的空间使用情况：

    ** ./symcfg list -connections -capacity**

    4.查看patch情况：

     **./symcfg list  -upatches**

    5.查看主要硬件情况

    **./symcfg list -env_data**

    6.查看每个bay的信息

    **./symcfg  show -env_data SystemBay**

    **./symcfg  show -env_data Bay-1A

    ./symcfg  show -env_data <Bay_Name>**

    7.查看磁盘设备情况：

    **./symdev list

    ./symdev list -service_state normal**

    8.查看问题磁盘设备情况：

    **./symdisk list -failed

    ./symdev list -service_state normal**

    9.查看某个磁盘设备情况：

    **./symdev show <sym_device_num>**

    10.查看磁盘情况：

    **./symdisk list

    ./symdisk show 01A:C0

    ./symdisk list -spare_info -v

    ./symdisk list -v -hotspares

    ./symdisk list -v -failed**

    11.查看ACL情况：

    **./symacl list -v

    ./symacl list -acl**

    12.存储性能统计:

    **./symstat -type request -i 10 -c 3 **

         