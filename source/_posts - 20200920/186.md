---
title: >-
  实战:HP-UX 在 HP Integrity rx8640 服务器上用LVM镜像引导磁盘并做更换已镜像的引导磁盘测试(2010-12-29
  17:22:07)
tags:
  - HP-UX
  - lvm
  - rx8640
  - 实战
  - 扩展分区
  - 更换已镜像磁
  - 镜像引导磁盘
id: 186
categories:
  - HP-UX
date: 2011-07-26 15:25:38
---

> 一、在 HP Integrity rx8640 服务器上镜像引导磁盘  （注：下面的文字引用自HP官方文档逻辑卷管理HP-UX 11iv3 ，经本人测试，没有问题，相关不同，已经用红色标注)

在 Integrity 服务器上镜像根磁盘的过程与在 HP 9000 服务器上执行的相应过程类似。
不同之处在于 Integrity 服务器引导磁盘是分区的，必须设置分区、将实用程序复制到
EFI 分区并在 LVM 命令中使用 HP-UX 分区设备文件。
图 3-1 显示了引导磁盘的磁盘布局。该磁盘包含“主引导记录”(MBR) 和指向每个分区的
EFI 分区表。idisk 命令用于创建分区（请参阅 idisk(1M)）。
图 3-1 HP Integrity 服务器上的 LVM 磁盘布局示例
在本示例中，要添加的磁盘的硬件路径为 0/1/1/0.0x1.0x0，设备专用文件名为 /dev/
disk/disk2 和 /dev/rdisk/disk2。请执行下列步骤：
1\. 使用 idisk 命令和分区描述文件对磁盘进行分区。
a. 创建分区描述文件。例如：
**# vi /tmp/idf**
在本示例中，分区描述文件包含以下信息：
<pre class="brush: php">
3
EFI 500MB
HPUX 100%
HPSP 400MB
</pre>
移动和重新配置磁盘103
本示例中的值表示引导磁盘有三个分区：EFI 分区、HP-UX 分区和 HPSP 分
区。早期 HP Integrity 服务器的引导磁盘的 EFI 分区可能只有 100 MB，并且
可能不包含 HPSP 分区。
b. 使用 idisk 和分区描述文件对磁盘进行分区，如下所示：
**# idisk -f /tmp/idf -w /dev/rdisk/disk2**
c. 要验证分区是否布局正确，请输入以下命令：
**# idisk /dev/rdisk/disk2**
2\. 为所有分区创建设备文件。例如：
**# insf -e -H 0/1/1/0.0x1.0x0  实际操作中，使用 insf -e C disk**
该磁盘现在具有下列设备文件：
<pre class="brush: php">
/dev/[r]disk/disk2（表示整个磁盘）
/dev/[r]disk/disk2_p1（表示 efi 分区）
/dev/[r]disk/disk2_p2（表示 HP-UX 分区）
/dev/[r]disk/disk2_p3（表示服务分区）
</pre>
3\. 使用表示 HP-UX 分区的设备文件创建可引导物理卷。例如：
**# pvcreate -B /dev/rdisk/disk2_p2**
4\. 将物理卷添加到现有的根卷组，如下所示：
**# vgextend vg00 /dev/disk/disk2_p2**
5\. 将引导实用程序放置在引导区域中。将 EFI 实用程序复制到 EFI 分区，并使用整个
磁盘的设备专用文件，如下所示：
**# mkboot -e -l /dev/rdisk/disk2**
6\. 在磁盘引导区域中添加自动引导文件，如下所示：
**# mkboot -a "boot vmunix" /dev/rdisk/disk2**
注释： 如果希望仅当达不到 Quorum 时才从此磁盘引导，则可以使用备用字符
串 boot vmunix –lq 禁用 Quorum 检查。但是，HP 建议使用至少三个物理卷
以及无单点故障来对根卷组进行配置，以便减少 Quorum 的损失，如“规划恢复”
（第 40 页）中所述。
7\. 必须按照在原始引导磁盘上配置的相同顺序对镜像引导磁盘上的逻辑卷进行扩展。
确定根卷组中的逻辑卷的列表及其顺序。例如：
**# pvdisplay -v /dev/disk/disk0_p2 | grep 'current.*0000 $'**
<pre class="brush: php">
00000 current /dev/vg00/lvol1 00000
00010 current /dev/vg00/lvol2 00000
00138 current /dev/vg00/lvol3 00000
00151 current /dev/vg00/lvol4 00000
00158 current /dev/vg00/lvol5 00000
00159 current /dev/vg00/lvol6 00000
00271 current /dev/vg00/lvol7 00000
00408 current /dev/vg00/lvol8 00000
</pre>
8\. 将 vg00（根卷组）中的每个逻辑卷镜像到指定的物理卷。例如：
**# lvextend –m 1 /dev/vg00/lvol1 /dev/disk/disk2_p2**
新分配的镜像正在进行同步，
该操作要执行一段时间。请稍候...
**# lvextend –m 1 /dev/vg00/lvol2 /dev/disk/disk2_p2**
新分配的镜像正在进行同步，
该操作要执行一段时间。请稍候...
**# lvextend –m 1 /dev/vg00/lvol3 /dev/disk/disk2_p2**
新分配的镜像正在进行同步，
该操作要执行一段时间。请稍候...
**# lvextend –m 1 /dev/vg00/lvol4 /dev/disk/disk2_p2**
新分配的镜像正在进行同步，
该操作要执行一段时间。请稍候...
**# lvextend –m 1 /dev/vg00/lvol5 /dev/disk/disk2_p2**
新分配的镜像正在进行同步，
该操作要执行一段时间。请稍候...
**# lvextend –m 1 /dev/vg00/lvol6 /dev/disk/disk2_p2**
新分配的镜像正在进行同步，
该操作要执行一段时间。请稍候...
**# lvextend –m 1 /dev/vg00/lvol7 /dev/disk/disk2_p2**
新分配的镜像正在进行同步，
该操作要执行一段时间。请稍候...
**# lvextend –m 1 /dev/vg00/lvol8 /dev/disk/disk2_p2**
新分配的镜像正在进行同步，
该操作要执行一段时间。请稍候...
注释： 如果 lvextend 失败，同时显示以下消息：
“m”：无效选项
没有安装 HP MirrorDisk/UX。
提示： 要缩短同步镜像副本所需的时间，请使用在 2007 年 9 月发行的 HP-UX
11i v3 中引入的 lvextend 和 lvsync 命令选项。通过这些选项可以并行而非按
顺序重新同步逻辑卷。例如：
**# lvextend -s –m 1 /dev/vg00/lvol1 /dev/disk/disk2_p2
# lvextend -s –m 1 /dev/vg00/lvol2 /dev/disk/disk2_p2
# lvextend -s –m 1 /dev/vg00/lvol3 /dev/disk/disk2_p2
# lvextend -s –m 1 /dev/vg00/lvol4 /dev/disk/disk2_p2
# lvextend -s –m 1 /dev/vg00/lvol5 /dev/disk/disk2_p2
# lvextend -s –m 1 /dev/vg00/lvol6 /dev/disk/disk2_p2
# lvextend -s –m 1 /dev/vg00/lvol7 /dev/disk/disk2_p2
# lvextend -s –m 1 /dev/vg00/lvol8 /dev/disk/disk2_p2
# lvsync -T /dev/vg00/lvol***
9\. 更新根卷组信息，如下所示：
移动和重新配置磁盘105
**# lvlnboot -R /dev/vg00**
10\. 验证镜像的磁盘是否显示为引导磁盘，以及两个磁盘上是否都有引导逻辑卷、根逻
辑卷和交换逻辑卷，如下所示：
**# lvlnboot -v**
11\. 将镜像磁盘指定为非易失性存储器中的备用引导路径，如下所示：
**# setboot –a 0/1/1/0.0x1.0x0**

用setboot命令查看
12\. 使用 vi 或其他文本编辑器在 /stand/bootconf 中为新引导磁盘添加一行，如
下所示：
**# vi /stand/bootconf**
<pre class="brush: php">
l /dev/disk/disk2_p2
</pre>
其中，字母“l”（L 的小写形式）代表 LVM。

> 二、更换已镜像的引导磁盘 （下面文字部分引用自 http://bbs.chinaunix.net/thread-1417904-1-1.html）

1、测试条件及方法：

测试条件：系统上有两块磁盘，/dev/disk/disk3和/dev/disk/disk5,按上面的在完成上面的镜像工作.

测试方法：我们把服务器上两块磁盘中的第一块/dev/disk/disk3拔出来，换一块同样大小（相同型号）的磁盘上去，来模拟有一块磁盘出问题的情况（rx8640磁盘支持热交换）。当我拔掉一块磁盘后，系统运行正常，用vgdisplay -v 命令查看，被拔掉磁盘的pv显示为unvaliable。

2、进行恢复操作

a、用dmesg 命令查看，有如下报错信息：
<pre class="brush: php">
WARNING:  Failed to find optimal pathfor 0x1000000.
Marking the device 0x1000000 offline.
0/0/0/2/0.6.0 sdisk
</pre>
b、运行 ioscan 命令并记录故障磁盘的硬件路径

[root@hpux01 disk]# ioscan -m lun /dev/disk/disk3
<pre class="brush: php">
Class     I  Lun H/W Path  Driver  S/W State   H/W Type     Health  Description
======================================================================
disk      3  64000/0xfa00/0x0   esdisk  CLAIMED     DEVICE       offline  HP 300 GST3300655LC      
             0/0/0/2/0.0x6.0x0
                      /dev/disk/disk3      /dev/disk/disk3_p2   /dev/rdisk/disk3     /dev/rdisk/disk3_p2
                      /dev/disk/disk3_p1   /dev/disk/disk3_p3   /dev/rdisk/disk3_p1  /dev/rdisk/disk3_p3
</pre>
c、暂停 LVM 对磁盘的访问，如果磁盘是可热交换的，请使用 pvchange 命令的 –a 选项断开该设备：
**[root@hpux01 disk]#  pvchange -a N /dev/disk/disk3_p2**

d、更换磁盘。
有关如何更换磁盘的硬件详细信息，请参阅该系统或磁盘阵列的硬件管理员指南。
如果磁盘是可热交换的，请更换它。
如果磁盘不可热交换，请关闭系统和电源，然后更换磁盘。重新引导系统。可能会
出现两个问题：
• 如果更换了通常用于引导的磁盘，则更换磁盘将不包含引导加载程序所需的信
息。这种情况下，请中断引导进程，并从配置为备用引导路径的镜像引导磁盘
进行引导。
• 如果根卷组中只有两个磁盘，系统 Quorum 检查可能会失败，如“卷组激活失
败” 。系统可能会在初始引导过程中出现混乱，并显示如
下消息：
panic: LVM: Configuration failure
在这种情况下，只有忽略 Quorum 才能引导成功。通过中断引导进程并向引
导命令添加 –lq 选项可完成此操作。

e、用scsimgr来更换磁盘。
如果未重新引导系统以更换故障磁盘，则首先运行 scsimgr，然后将该新磁盘用
作旧磁盘的更换磁盘。例如：
**[root@hpux01 disk]#   scsimgr replace_wwid -D /dev/rdisk/disk3**

该命令允许存储子系统使用新磁盘的 LUN 全球唯一标识符 (WWID) 替换旧磁盘的
LUN WWID。存储子系统将为更换磁盘创建一个新 LUN 实例和新设备专用文件。

f、确定更换磁盘的新 LUN 实例编号

**[root@hpux01 disk]# ioscan -m lun   查看，我这边多了一个 /dev/disk/disk6的磁盘文件**

g、仅限 HP Integrity 服务器）使用 idisk 命令和分区描述文件对替换磁盘进行分区。
创建分区描述文件。例如：
**[root@hpux01 disk]# vi /tmp/idf**
<pre class="brush: php">
3
EFI 500MB
HPUX 100%
HPSP 400MB
</pre>   
    h、使用 idisk 和分区描述文件对磁盘进行分区，如下所示：
**[root@hpux01 disk]# idisk -f /tmp/idf -w /dev/rdisk/disk6**

i、生成对应的disk的设置文件

**[root@hpux01 disk]# insf -eC disk**

j、将旧实例编号分配给替换磁盘

**[root@hpux01 disk]# io_redirect_dsf -d /dev/disk/disk3 -n /dev/disk/disk6**

这将向替换磁盘分配 LUN 实例编号 (3)。此外，将重命名新磁盘的设备专用文件，
以与旧 LUN 实例编号一致。用ioscan -m lum 查看，新的/dev/disk/disk6设备文件消失了，老的/dev/disk/disk3的硬件路径变为64000/0xfa00/0x9

k、将 LVM 配置信息恢复到新磁盘

**[root@hpux01 disk]#vgcfgrestore -n /dev/vg00 /dev/rdisk/disk3_p2**

l、恢复 LVM 对磁盘的访问。
**[root@hpux01 disk]#pvchange -a y /dev/disk/disk3_p2**

m、初始化磁盘上的引导信息。
将引导实用程序放置在引导区域中。将 EFI 实用程序复制到 EFI 分区，并使用整个
磁盘的设备专用文件，如下所示：
**[root@hpux01 disk]# mkboot -e -l /dev/rdisk/disk3**

在磁盘引导区域中添加自动引导文件，如下所示：
**[root@hpux01 disk]# mkboot -a "boot vmunix -lq" /dev/rdisk/disk3**

n、确认表盘上数据已经同步完成

**[root@hpux01 disk]#lvsync -T /dev/vg00/lv***

o、查看VG状态，新换上去的disk3已经可用：

**#[root@hpux01 disk]# vgdisplay -v vg00   **       

<pre class="brush: php">
   --- Physical volumes ---
   PV Name                     /dev/disk/disk3_p2
   PV Status                   available               
   Total PE                    4456   
   Free PE                     3359   
   Autoswitch                  On       
   Proactive Polling           On

PV Name                     /dev/disk/disk5_p2
   PV Status                   available               
   Total PE                    4456   
   Free PE                     3423   
   Autoswitch                  On       
   Proactive Polling           On
</pre>
p、最后，我们把没有更换的disk5从服务器中拔出，看一下，系统是否正常？再查看一下VG的状态，第二块盘disk5已经不可用了：

**[root@hpux01 tmp]# vgdisplay -v**
<pre class="brush: php">
   --- Physical volumes ---
   PV Name                     /dev/disk/disk3_p2
   PV Status                   available               
   Total PE                    4456   
   Free PE                     3359   
   Autoswitch                  On       
   Proactive Polling           On              

   PV Name                     /dev/disk/disk5_p2
   PV Status                   unavailable             
   Total PE                    4456   
   Free PE                     3423   
   Autoswitch                  On       
   Proactive Polling           On 
</pre>

小结：从上面的操作来看，做成LVM镜像后，如果有磁盘损坏，可以在不重启机器的情况下更换磁盘，并恢复LVM镜像。在恢复镜像后，如果再有一块磁盘损坏，也不会对系统产生影响。            

over :)