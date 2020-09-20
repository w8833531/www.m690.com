---
title: 'HP-UX nickel 脚本命令细细读--系统信息(2011-04-14 14:02:00)'
tags:
  - HP-UX
  - nickel
  - 系统信息
id: 203
categories:
  - HP-UX
date: 2011-07-26 15:59:26
---

    

> 今天HP的工程师来对公司HP rx8640小机进行巡检。系统一直运行稳定，没出过什么问题。但我把nickel脚本生成的信息发过去后，结果有些意外。有一台小机上的一个CPU已经被Deconfigred掉了。而且问题发生时间是2010年2月15号（去年2月15号），已经一年多了。虽然当时我还不负责这个系统，但还是觉得应该多进行一下对HP小机的硬件监控。

    于是静下心来细细读一下这个nickel的脚本 ，看看我们如何来收集系统信息并及时发现问题。

一、系统信息：

    用与收集系统所有软硬件信息：   

    1、系统信息 system information

     使用命令： /usr/contrib/bin/machinfo

     说明：这个是nickel生成的index.html文件首页的内容，包括了CPU、内存、Firmware、Platform、OS、信息

    2、启动时间  uptime

     使用命令： uptime

     说明：机器启动到现在的天数

    3、环境变量

     使用命令： env

    4、文件系统和磁盘信息

       1）显示启动盘上的LIF信息：

         使用命令： lifls -il /dev/rdsk/c0t6d0s2
         命令显示：

         lifls -il /dev/rdsk/c0t6d0s2
volume ISL10 data size 7984 directory size 8 06/10/27 14:23:07
filename   type   start   size     implement  created
===============================================================
ISL        -12800 584     242      0          06/10/27 14:23:07
AUTO       -12289 832     1        0          06/10/27 14:23:07
HPUX       -12928 840     1024     0          06/10/27 14:23:07
PAD        -12290 1864    1468     0          06/10/27 14:23:07
LABEL      BIN    3336    8        0          09/11/05 22:41:22

        HP-UX系统启动过程:

参见：http://fanqiang.chinaunix.net/a1/b6/20011121/0808001581.html

hpux的启动过程概况如下： 
pdc(Processor-dependent-code,在rom中，完成硬件自检 
| 读取stable storge中的信息，如autosearch， 
| primarypath等等，然后调用isl 
isl (Initial system loader,在boot盘的lif区域。lif 
| 区域主要有四个文件，分别是sl,hpux,AUTO,LABEL 
| 在#下，可以使用lifls命令察看，同时可以使用 
| lifcp 察看AUTO的内容。 
| isl的主要任务是执行lif区域的hpux，同时也可 
| 以改变stable storge中的部分信息，如 
| primarypath,autoboot等等 
hpux 引导os,主要是读取/stand/vmunix文件，同时把 
| 控制权交给内核， 
| 
init 从这里开始，就是软件之间的启动了  
        说明：显示LIF卷上的文件信息 ,相关LIF的文章，请看：http://hi.baidu.com/penguinhe2006/blog/item/470c153d3047cae33c6d97b0.html

       2）显示系统lvm信息：

         使用命令：vgdisplay -v  ; strings /etc/lvmtab

       3）显示启动卷信息：

         使用命令：lvlnboot -v

       4）系统mount情况  ：

         使用命令：cat /etc/fstab    ; mount -p

       5）分区可用空间：

         使用命令： bdf -i

       6）NFS mount :

         使用命令： showmount -a

       7）SWAP 信息：

         使用命令： swapinfo -tam

     5、系统软件及补丁安装情况：

         使用命令：swlist -l bundle ; swlist -l product ; swlist -l product | grep PH ; swlist -l fileset -a state -a patch_state

     6、启动盘设备path 信息：

         使用命令：setboot

     7、计划任务情况：

         使用命令： crontab -l

     8、磁盘IO 情况：

         使用命令：iostat -t 5 2

     9、IPC 情况：

         使用命令：ipcs -bcop

    10、内核加载的设备驱动

         使用命令：lsdev

    11、nfs情况

         使用命令：nfsstate

    12、进程情况：

         使用命令：ps -ef

    13、系统负载情况：

         使用命令：sar -A 5 2

    14、系统重启日志：

         使用命令： cat /var/adm/shutdownlog

    15、系统内核参数情况：

         使用命令：cat /stand/system;  kctune ;  kcusage; sysdef

    16、系统日志：

         使用命令：cat /var/adm/syslog/syslog.log  ; cat /var/adm/syslog/OLDsyslog.log

    17、top信息

         使用命令： top -d5

    18、vmstat 信息：

         使用命令：vmstat -dS 5 2

    19、内核具体信息：

         使用命令：what /stand/vmunix