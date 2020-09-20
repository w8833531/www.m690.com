---
title: 神奇的dd--使用dd+ssh 备份KVM虚拟机上的lvm磁盘到远程备份服务器而不要先在本地转换成image格式的文件再传送
tags:
  - backup
  - dd
  - kvm
  - lvm
  - ssh
  - vm
  - 备份
  - 虚拟机
id: 579
categories:
  - KVM
date: 2012-12-28 21:27:45
---

> 我们使用lvm的逻辑卷来做KVM虚拟机的磁盘，使用raw盘的方式把lv挂在虚拟机上。每天使用lvm的clone功能对虚拟机进行备份。如何把lv 考贝到备份服务器成了一个需要解决的问题。之前是把clone的lv先在本地转换成image文件，然后再rsync到备份服务器上。但随着VM的实际占用空间越来越大，本地的磁盘空间已经无法满足lv空间的转换需求了。如何把本地的lv直接转送到备份服务器而不需要在本地转换成image文件呢？下面介绍一个dd+ssh的解决办法

<pre class="blush: php">
###把KVM05上的LV dev/vgvmhost/vir_w23_x86_56_d 直接通过dd + ssh 备份到kvm08的/opt/images目录下面
dd if==/dev/vgvmhost/vir_w23_x86_56_d ｜ ssh kvm08 "dd of=/opt/images/vir_w23_x86_56_d.img "
</pre>