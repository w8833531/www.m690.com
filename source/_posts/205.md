---
title: 'HP-UX nickel 脚本输出信息细细读--硬件及诊断(2011-04-18 09:09:53)'
tags:
  - HP-UX
  - nickel
  - 硬件诊断
id: 205
categories:
  - HP-UX
date: 2011-07-26 16:01:25
---

> 继续上面一篇，我们来看一下硬件及诊断信息。

二、硬件及诊断信息：

1、查看系统硬件 

   使用命令： **ioscan -fn  ;ioscan -fnCdisk ;ioscan -fnCtape  ; ioscan -fnCfc**

   说明：命令显示解释如下：

          Class--设备分类

          I--设备实例号，同类设备这个数字保持相同

          H/W Path--硬件路径

          Drive--硬件对应的驱动名

          S/W state--硬件是否与驱动绑定

          Hardware Type-- 硬件实体标识符

          Description-- 设备描述

   命令输出：
<pre class="brush: php">
Class       I  H/W Path       Driver    S/W State   H/W Type     Description
=============================================================================
root        0                 root      CLAIMED     BUS_NEXUS   
cell        0  0              cell      CLAIMED     BUS_NEXUS   
ioa         0  0/0            sba       CLAIMED     BUS_NEXUS    System Bus Adapter (12eb)
</pre>

   小技巧：使用ioscan来查看硬件问题
<pre class="brush: php">
       ioscan -fn | grep -i NO_HW    #是否有光纤链接断开

       ioscan -fn | grep -i UNCLAIMED #是否有没安装的驱动

       ioscan -fn | grep -i UNKNOWN
</pre>
2、 查看磁盘详细信息：

  使用命令：** diskinfo -v < character special device file>**

3、 查看PCI-X使用情况

  使用命令： **olrad -q**

  说明：可以用这个命令结合ioscan的H/W path来查看系统中的设备在PCI插槽上的位置。

  小技巧： 可以使用**olrad -I ATTN <solt ID> **来让相应的solt警示灯闪烁。

4、 查看FC信息：

  使用命令：** fcdlist ; fcmsutil  <fc设备名> ;fcdutil <fc设备名>; fcddiag**

  说明：**fcdlist **可以列出你的所有以fcd驱动的光纤设备及连接的磁盘情况。   **fcmsutil  及fcdutil** 命令可以查看fcd驱动的HBA卡的详细情况。fcddiag 查看fcd 驱动的所有详细的fc设备的诊断信息。

  小技巧：如果你想看一下，是否有HBA卡与光纤交换机断开了连接，可以使用下面的命令来查看：
<pre class="brush: php">
          fcdlist | grep -i NO_HW
</pre>
          如果有NO_HW状态的HBA卡且这个断开的HBA设备是/dev/fcd0，设备patch路径前4位是1/0/4/1，你可以用下面的命令来查看他在PCI插槽上的位置：
<pre class="brush: php">
          olrad -q | grep 1/0/4/1       #在第6个槽位上
0-0-1-6  1/0/4/1         340   266  133  On   Yes  No   Yes   N/A  PCI-X PCI-X
</pre>

5、用**cstm**诊断工具查看所有硬件信息：

  使用命令:
<pre class="brush: php">
echo "map; selall; information; wait ; infolog " |  cstm
</pre>
  说明：使用cstm来查看所有设备详细的硬件诊断信息。

6、查看Install Capacity (iCAP) 状态

   使用命令： **icapstatus**

   说明：这个命令可以查看你系统里安装了的CPU、MEM量及被受权的数量

7、查看Npar的状态

   使用命令:**parstatus**

   说明：使用这个命令，你可以看到小机的机柜（Cabinet）、 Cell 、及Npar信息

   小技巧： 查看Cabinet上是否有风扇、电源有问题
<pre class="brush: php">
               parstatus -V -b 0 | grep -i fail
</pre>
               查看Cell板上的CPU和内存是否有问题
<pre class="brush: php">
               parstatus -V -c 0  | grep -i deconf  #下面的输出说明我的Cell0上有2个CPU出问题了

               0    Deconfigured
               1    Deconfigured
               Deconf : 2
               DIMM Deconf   : 0
               Memory Deconf : 0.00 GB
</pre>
8、从小机的MP上来查看系统硬件状态
<pre class="brush: php">
     使用命令：登录MP，MP>CM  ; CM>PS
</pre>
     说明：可以查看Cabinet 电源、风扇、Cell上的CPU 内存等的信息

     小技巧：你可以用MP的SL命令来查看MP日志
<pre class="brush: php">
         MP>SL ; MP:VW> SEL;  MP:VWR> L
</pre>

9、从系统日志中查看相关硬件出错信息

     相关日志：

        1.**dmesg**输出：  查看是否有 scsi reset,file system full等信息

        2.系统启动日志： **more /etc/rc.log**

        3.系统运行日志： **more /var/admin/syslog/syslog.log**

        4.系统关机日志： **more /etc/shutdownlog**

        5.文件系统大小： **bdf**

        6.core dump日志： **/var/admin/crash.x**

10、根盘镜像状态

    使用命令：

    **vgdisplay -v vg00 ** #查看系统启动VG

    **setboot  **          #检查是否设置了备用启动路径，且autoboot为ON

       **crashconf -v     **           #检查dump 区配置是否合理