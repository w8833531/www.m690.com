---
title: '实战:HP-UX 扩展HP小机rx8640上的swap和dump空间'
tags:
  - dump
  - HP-UX
  - swap
  - 扩展
  - 空间
id: 199
categories:
  - HP-UX
date: 2011-07-26 15:56:28
---

> ### 目标：
> 1、给小机增加一个备用swap分区> 
> 
>       2、给小机增加一个dump分区

### 操作:

1、查看VG00的两块盘的分配情况，现在vg00的两块盘上各有840个PE。我准备在两块盘上各新建一个lv,一个用做swap的备用分区，一个用做dump分区
<pre class="brush: php">
#vgdisplay -v /dev/vg00

   --- Physical volumes ---
   PV Name                     /dev/dsk/c0t6d0s2
   PV Status                   available               
   Total PE                    4455   
   Free PE                     840     
   Autoswitch                  On       
   Proactive Polling           On              

   PV Name                     /dev/dsk/c2t6d0s2
   PV Status                   available               
   Total PE                    4455   
   Free PE                     840     
   Autoswitch                  On       
   Proactive Polling           On    
</pre>
查看DUMP和SWAP的使用情况，现在是swap和dump共用/dev/vg00/lvol2
<pre class="brush: php">
#lvlnboot -v | more

Boot Definitions for Volume Group /dev/vg00:
Physical Volumes belonging in Root Volume Group:
        /dev/dsk/c0t6d0s2 (1/0/0/2/0.6.0) -- Boot Disk
        /dev/dsk/c2t6d0s2 (1/0/0/3/0.6.0) -- Boot Disk
Boot: lvol1     on:     /dev/dsk/c0t6d0s2
                        /dev/dsk/c2t6d0s2
Root: lvol3     on:     /dev/dsk/c0t6d0s2
                        /dev/dsk/c2t6d0s2
Swap: lvol2     on:     /dev/dsk/c0t6d0s2
                        /dev/dsk/c2t6d0s2
Dump: lvol2  on:        /dev/dsk/c0t6d0s2, 0
</pre>
2、我们来新建和设置dump分区，把lvol2从dump中删除，我们会使用新在dump lv
<pre class="brush: php">
#lvrmboot -d /dev/vg00/lvol2 /dev/vg00
</pre>
确认删除情况
<pre class="brush: php">
#lvlnboot -v | more
</pre>
在vg00上创建一个连续分配-C y 且禁用坏块重定位功能 -r n用来做dump空间的卷, lvdump01
<pre class="brush: php">
#lvcreate -C y -r n -n lvdump01 /dev/vg00
</pre>
扩展这个卷的空间，空间大小视情况来定。新建的lvdump01可以使用一块盘上的800个PE。
<pre class="brush: php">
#lvextend -l 800 /dev/vg00/lvdump01 /dev/dsk/c2t6d0s2
</pre>
查看新建lvdump01的情况
<pre class="brush: php">
#vgdisplay -v /dev/vg00
</pre>
把启动时使用这个dump空间设置为/dev/vg00/lvdump01
<pre class="brush: php">
#lvlnboot -d /dev/vg00/lvdump01 /dev/vg00
</pre>
#查看设置情况
<pre class="brush: php">
lvlnboot -v | more
</pre>
#更改dump配置,使其生效
<pre class="brush: php">
crashconf -vr /dev/vg00/lvdump01
</pre>
3、接着我们来新建备用swap空间，在vg00上创建一个连续分配-C y 用来做新增的SWAP空间的卷, lvswap02
<pre class="brush: php">
#lvcreate -C y -r n -n lvswap02 /dev/vg00 
</pre>
扩展这个卷的空间，空间大小视情况来定。新建的lvswap02可以使用另一块盘上的800个PE。
<pre class="brush: php">
#lvextend -l 800 /dev/vg00/lvswap02 /dev/dsk/c0t6d0s2
</pre>
用swapon命令启用这个备用的swap空间，请大家注意，因为lvswap02与lvol2两个逻辑卷会使用同一块盘，所以不建议同时使用这两个swap空间，因为这样会增加磁头的移动。所以我这里把lvswap02的优先级设置成9，这样只有lvol2用完后，才会使用lvswap02。
<pre class="brush: php">
#swapon -p 9 /dev/vg00/lvswap02 
</pre>
确认swap空间的当前情况
<pre class="brush: php">
# swapinfo -t
             Kb      Kb      Kb   PCT  START/      Kb
TYPE      AVAIL    USED    FREE  USED   LIMIT RESERVE  PRI  NAME
dev     8388608      88 8388520    0%       0       -    1  /dev/vg00/lvol2
dev     52428800       0 25165824    0%       0       -    9  /dev/vg00/lvswap02
reserve       - 14090864 -14090864
memory  100463608 82149308 18314300   82%
total   161281016 96240260 37777780   60%       -       0    -
</pre>
4、最后，把swapon命令加入到/etc/rc.local中，使机器重启时自动运行。

在/sbin/rc文件中最后加一行（这个文件是只读的哈）
<pre class="brush: php">
#tail -n 1 /sbin/rc
/usr/bin/sh /etc/rc.local
</pre>
在/etc/rc.local中加入相应的命令就可以了，比如我这边就启了一个zabbix_agentd程序和增加了一个swap分区，把它的优先级设置的比较低一点，在主交换分区空间不足时，可以用这个交换分区。
<pre class="brush: php">
# cat /etc/rc.local
PATH=/opt/softbench/bin:/usr/bin:/usr/ccs/bin:/usr/contrib/bin:/usr/contrib/Q4/bin:/opt/perl/bin:/opt/ipf/bin:/opt/hparray/bin:/opt/nettladm/bin:/opt/fcms/bin:/opt/sas/bin:/opt/wbem/bin:/opt/wbem/sbin:/usr/bin/X11:/opt/resmon/bin:/opt/perf/bin:/usr/contrib/kwdb/bin:/opt/graphics/common/bin:/opt/prm/bin:/opt/sfm/bin:/opt/hpsmh/bin:/opt/upgrade/bin:/opt/wlm/bin:/opt/gvsd/bin:/opt/sec_mgmt/bastille/bin:/opt/drd/bin:/opt/dsau/bin:/opt/dsau/sbin:/opt/firefox:/opt/gnome/bin:/opt/mozilla:/opt/perl_32/bin:/opt/perl_64/bin:/opt/sec_mgmt/spc/bin:/opt/ssh/bin:/opt/swa/bin:/opt/thunderbird:/opt/gwlm/bin:/usr/contrib/bin/X11:/opt/aCC/bin:/opt/caliper/bin:/opt/cadvise/bin:/opt/sentinel/bin:/opt/langtools/bin:/usr/sbin:/usr/local/sbin:/sbin://bin:/usr/sbin:/usr/local/bin
export PATH
swapon -p 9 /dev/vg00/lvswap02 
</pre>