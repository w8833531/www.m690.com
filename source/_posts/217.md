---
title: 转载：几种系统下查看FC HBA卡信息的方法
tags:
  - fc
  - hba卡信息
  - 系统平台
id: 217
categories:
  - EMC
date: 2011-07-26 16:40:19
---

原文网址：[http://wf0127.blog.51cto.com/1148999/391801
](http://wf0127.blog.51cto.com/1148999/391801)

> 在配置磁盘阵列或虚拟磁带库时，往往会以FC接口与主机对接，那就涉及FC HBA卡的查看，本文就此问题在各种系统下的查看方法进行总结与整理。

### 一、Windows 系统

在Windows系统中，可以使用FC HBA卡厂家提供的管理软件查看光纤适配器的WWN号码，具体如下：

Qlogic：SANsurfer

Emulex：HBAnyware

### 二、SuSE Linux 9

查看 /proc/scsi/qla2xxxport_name 文件的内容即可看到对应FC HBA卡的WWN信息：
<pre class="blush: php">
# cat /sys/class/fc_host/host*/port_name

0x210000e08b907955

0x210000e08b902856
</pre>

### 三、RedHat Linux AS4

<pre class="blush: php">
# grep scsi /proc/scsi/qla2xxx/3

Number of reqs in pending_q= 0, retry_q= 0, done_q= 0, scsi_retry_q= 0

scsi-qla0-adapter-node=20000018822d7834;

scsi-qla0-adapter-port=21000018822d7834;

scsi-qla0-target-0=202900a0b8423858;

scsi-qla0-port-0=200800a0b8423858:202900a0b8423858:0000e8:1;
</pre>

### 四、RedHat Linux AS5

<pre class="blush: php">
# cat /sys/class/fc_host/hostx/port_name
</pre>

### 五、Solaris 10

提供了fcinfo命令，可以使用 **fcinfo hba-port** 查看FC HBA的WWN信息：
<pre class="blush: php">
# fcinfo hba-port
</pre>
查看光纤卡端口的路径及连接状态:
<pre class="blush: php">
# luxadm -e port
</pre>
查看端口的WWN：
<pre class="blush: php">
# luxadm -e dump_map fibre_channel_HBA_port // 上一命令的输出

# prtconf –vp | grep -i wwn

# prtpicl –v | grep -i wwn (prtpicl - print PICL tree)
</pre>

### 六、HP-UX

<pre class="blush: php">
# ioscan –funC fc // 找到HBA卡，再用fcmsutil查看HBA卡信息

# fcmsutil /dev/fcd0(1)
</pre>