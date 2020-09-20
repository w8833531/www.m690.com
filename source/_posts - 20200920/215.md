---
title: 实战：在EMC DMX3+HP RX8640 上更换HBA卡的光纤端口
tags:
  - dmx3
  - emc
  - HP-UX
  - solutions enabler
  - 光纤卡更换
id: 215
categories:
  - EMC
date: 2011-07-26 16:34:35
---

 

> 前几天HP工程师过来做巡检，发现我们的一台HP8640小机上有个光纤链路掉了。我们的SAN结构是 HP8640小机（两个HBA卡，双链路）+ EMC光纤交换机（两台）+ EMC DMX3存储。

    同事到机房看了一下，是因为小机上的HBA卡有个光纤端口出问题了。换一个光纤端口后，在光纤交换机上看，链路已经OK了。本以为这样就搞定了，没想到花了我1天的时间才搞定了这个问题。下面是发现的问题及处理的步骤：

    1、登上出问题的小机，用**ioscan -fnC disk**看这个链路上的磁盘还是**NO_HW**状态。

    2、开始以为是光纤交换机上zone的要更改，登上光纤交换机，发现zone是按交换机的端口来划的，我只是换了HBA卡上的端口，光纤交换机上的端口没有更换，所以在zone的划分上并没有什么问题。

    3、用小机上的EMC powerpath软件查看，命令 **powermt display dev=all**，发现有个光纤链路出问题了，显示如下：
<pre class="blush: php">
Logical device ID=0293
state=alive; policy=SymmOpt; priority=0; queued-IOs=0
==============================================================================
---------------- Host ---------------   - Stor -   -- I/O Path -  -- Stats ---
###  HW Path                I/O Paths    Interf.   Mode    State  Q-IOs Errors
==============================================================================
  10 1/0/6/1/0/4/0.11.11.0.0.1.0 c10t1d0   FA  8cB   active  alive      0      2
   8 1/0/4/1/0/4/0.21.11.0.0.1.0 c8t1d0    FA  9cB   active  dead       0      1
</pre>
    4、用 powermt check 命令进行check,但无法把dead的磁盘给去掉，因为VG还在激活状态，umount掉所有存储上的分区，并把VG状态改成不激活状态，就可以了，使用命令如下：

      ** umount /oraque **   #umount掉存储上的分区

      ** vgchange -a n /dev/vgqueora**  #更改VG的激活状态

      ** powermt check **    #去掉dead的磁盘链路

       **powermt display dev=all**  #查看dead的磁盘链路是否已经去掉

   5、用EMC的 solutions Enabler工具配置mask，让新的HBA卡光纤端口可以访问之前对应的磁盘，具体操作如下：

      **cat /usr/emc/API/symapi/config/symapi_licenses.dat** #确认你的solution Enable工具是否有 Dev Masking  license.

      **./symmaskdb list database  **#找到链路有问题的EMC Director ID是9C，Director port 是1，磁盘设备、老的连接主机HBA卡的WWN号等信息，显示如下：(注：请记录下Port Name和Devices列的内容）：
<pre class="blush: php">
           Director Identification : FA-9C
Director Port           : 1

                               User-generated   
Identifier        Type   Node Name        Port Name         Devices
----------------  -----  ---------------------------------  ---------
500143800118fb4a  Fibre  500143800118fb4a 500143800118fb48  00A9
                                                            0293
                                                            0297

</pre>

      ** ./symmask refresh  **   #把EMC后台MASK DB应用到前台FA

      **./symmask delete -wwn 500143800118fb48 **  #删除老的HBA卡的mask

       .把**./symmaskdb list database ** 命令生成的信息中，Director ID是9C，Director port 是1 的 Device 下的信息放到一个aaa.txt文件中，格式如下(第一列是Devices下的内容，第二个是任意4位数字）：
<pre class="blush: php">
           00A9  0000
           0293  0000
           0297  0000
</pre>
      **./symmask  -wwn 500143800118fb4a -dir 9C -p 1 add -f aaa.txt**   #新建一个mask,WWN号是你新的HBA卡光纤端口的WWN号这里是500143800118fb4a ，-dir 是Director ID, -p 是Director Port,aaa.txt中是磁盘设备号。

       **./symmask refresh  **   #把EMC后台MASK DB应用到前台FA

   6、用powermt工具进行config，看是否链路是否已经可用

      ** powermt config  **   #让power patch进行重新配置

       **powermt display dev=all**  #查看是否链路是否已经可用,显示如下：
<pre class="blush: php">
Logical device ID=0293
state=alive; policy=SymmOpt; priority=0; queued-IOs=0
==============================================================================
---------------- Host ---------------   - Stor -   -- I/O Path -  -- Stats ---
###  HW Path                I/O Paths    Interf.   Mode    State  Q-IOs Errors
==============================================================================
  10 1/0/6/1/0/4/0.11.11.0.0.1.0 c10t1d0   FA  8cB   active  alive      0      0
  14 1/0/4/1/0/4/1.21.11.0.0.1.0 c14t1d0   FA  9cB   active  alive      0      0
</pre>
      ** powermt save  **     #保存配置

  7、做到上面一步，新的路径已经可用了，但还是有一些HP主机层上的工作要做，为这些新的路径生成设备文件，使用命令如下：

     ** insf -e -C disk **   #生成新的路径设备文件

  8、在用vgchange来激活新路径时，你可能会得到报错，因为老的设备文件已经不可用了，你需要备份并删除老的/etc/lvmtab文件，用vgscan从磁盘来重新生成新的/etc/lvmtab的VG配置。

　　** cd /etc; cp lvmtab lvmtab.bak; rm lvmtab **  #备份并删除老的/etc/lvmtab文件

     ** vgscan -a**  #从磁盘来重新获得VG配置

     ** vgchange -a y /dev/vgqueora **  #激活VG

      **vgdisplay -v /dev/vgqueora  **#查看VG状态，从显示看，PV的dsk设备名已经从/dev/dsk/c08xxxx改成了/dev/dsk/c14xxxx了：），显示如下：
<pre class="blush: php">
   PV Name                     /dev/dsk/c14t1d7
   PV Name                     /dev/dsk/c10t1d7 Alternate Link
   PV Status                   available               
   Total PE                    2912   
   Free PE                     101    
   Autoswitch                  On       
   Proactive Polling           On              
</pre>
      ** mount /oraque**    #挂上分区

   终于搞定了，哈哈。没想到在SAN环境中换个HBA卡的光纤端口有这么一大堆工作。相关难点主要是用EMC 的solutions Enabler工具配置mask，更换老的HBA卡端口的WWN号。EMC的DMX3是个全封闭系统，相关配置操作文档比较少。如果你有power link的帐号，你可以通过下面的链接来直接下载solutions Enabler的使用说明：

[http://powerlink.emc.com/km/live1/en_US/Offering_Technical/Technical_Documentation/300-002-940_a08.pdf
](http://powerlink.emc.com/km/live1/en_US/Offering_Technical/Technical_Documentation/300-002-940_a08.pdf)  如果你没有power link 的帐号，我也可以给你一个，呵呵。