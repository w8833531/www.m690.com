---
title: '转－－RedHat 7.0 beta release notes总结及个人分析 '
tags:
  - kvm
  - new feature
  - performance
  - RedHat7
id: 694
categories:
  - linux
  - 技术
date: 2014-02-18 21:44:11
---

RedHat 7.0在虚拟化支持方面有多个新特性，很多都是大大提升性能的，值得期待，我用黑色标粗。
源文出处：http://blog.csdn.net/ustc_dylan/article/details/19009347

下面就自己感兴趣的RedHat 7.0 beta的new features整理了下，并简单的发表了下自己的看法。

1\. GRUB 2
 redhat 7.0 beta版将之前使用的Boot Loader从GRUB升级到了GRUB2，主要是基于GRUB2以下四个比较显著的特点：
 （1）GRUB2支持更多的硬件体系结构，比如PowerPC
 （2）GRUB2支持更多的固件类型，比如BIOS，EFI和OpenFirmware
 （3）GRUB2除了支持MBR（Master Boot Record）磁盘分区表，还支持GPT(GUID Partition Tables)
 （4）GRUB2除了支持linux文件系统外，还支持一些非linux文件系统，比如苹果的HFS+和微软的NFS文件系统
2\. Storage
 **（1）LIO Kernel Target Subsystem**

 这里重点强调了RedHat 7.0的iscsi target使用LIO（linux-IO Target）代替了tgtd，与tgtd相比，LIO有以下优点（个人理解）：

    tgtd是个user space的daemon，而LIO是个kernel driver，LIO的性能更优；
    LIO采用了一种统一的方式来对当前的iscisi protocol进行配置和管理，即统一的接口，更强大的配置和管理方式。

  **（2）Fast Block Devices Caching Slower Block Devices**
  linux内核支持的以一种block-level caching solution，即使用高速的存储设备作为低速存储设备的cache。 目前，比较流行的block-level caching solution有dm-caceh, bcache，flashcache和enhanceio等。
  其中dm-cache被merge到linux-3.9内核中，bcache被merge到linux-3.10内核中，后两者是facebook提出的，现在应用也比较广。下面简单介绍下block-level caching（以dm-cache为例）的原理，后续如果有时间会详细分析。

  linux kernel通过增加virtual cache devices设备来作为cache设备的抽象，virtual cache device基于三个physical devices来实现：
origin device: slower physical device，比如Hard Disk Device，数据最后持久化存储的位置
cache device： fast physical device， 比如SSD，数据暂时存储的位置
metadata device：元数据设备，可以用SSD（即cache device和metadata deivce可以是一块SSD的两个分区），用来配置cache placement policy（cache的块替换策略），dirty block flags（记录cache中被修改过的块，即脏块）以及其他内部数据
  简单来讲，当读数据的时候，会查找metadata device看请求块是否在cache device中命令中，如果hit，则直接从cache device获取，如果miss，再从origin device获取，同时将数据读到cache device中。当写数据的时候，根据cache placement policy配置的策略的不同，
 执行对应的写操作，当前支持的policy有：writeback和writethrough，默认为writeback，即先写到cache device中，并在metadata device中记录写过的块为dirty，此时写操作就完成了。每个一段时间cache device中的dirty block会被flush到origin device中。
3\.  File System
 通过图形界面安装的redhat 7.0采用XFS作为默认的文件系统，具体XFS相关的内容可参见XFS的相关介绍。
4\. Kernel
**（1）增加硬件支持的APIC虚拟化**
     APIC相关的操作都是特权操作，当vcpu在接收到APIC interrupt时，就会从Guest Mode切换到Kernel Mode，这极大的降低了系统的性能，通过增加硬件支持的APIC虚拟化，避免了这种切换。
**（2）Full DynTick support**
     这个feature的意思是：当某个cpu上只有一个可运行的进程时，禁用这个cpu的tick（滴答，就是时钟中断），个人认为这是一个非常大的进步。这里先简单介绍下相关背景知识，后续有时间详细分析。
    估计大家都听说过HZ，常见的HZ有：100,250,300,1000， 一般桌面版默认设置为250（server版为1000），即每秒产生250个时钟中断（tick，滴答），主要是用来给scheduler来做调度的时间度量。
   如果cpu的idle的情况下，每秒仍然会有1000个时钟中断，即cpu即使idle也是在做时钟中断处理的，于是后来出现了NO_HZ，即如果cpu处于idle，就禁用时钟中断，通过CONFIG_NO_HZ来配置（至于此时如何计时，在此不作讨论）。
   再后来，如果当钱cpu只有一个任务可运行，那么如果禁用使用中断的话，当前任务仍要被打断250次或1000次，所以也没有必要，就出现了CONFIG_NO_HZ_FULL（就是这里的Full DynTick Support）。
   最后，必须承认采用了tickless必然也会带来一些缺点，在此也不做详细分析。
5\. Virtualization
   **（1）块设备IO性能优化**
      增加virtio-blk-data-plane的支持，用来提供块设备IO的性能，具体原理和性能比较参见文章《KVM IO性能测试数据》
   （2）PCI桥支持
     之前qemu最多可仿真32个pci slot，增加pci bridge之后，每个slot可以接pci bridge，而每个pci bridge又可以接32个pci card
   （3）QEMU Sandboxing
     通过kernel system call filtering机制，使得vm的安全隔离性更好
   **（4）Qemu Virtual CPU Hot Add support**
    从字面上理解应该是从真正做到了cpu hotplug，即从qemu层面hot add physical的cpu设备，os层面能够自动识别到新增加的cpu（个人理解是这个功能，需要验证，因为有可能仅仅是更新了qemu的版本，而在qemu层面支持cpu hotplug，os并不能自动识别）
   **（5）Multiple Queue NICs**
    每个vcpu有自己独立的网络收发队列和独立的中断标志位，众所周知，linux kernel中的网络驱动实现为每块网卡分别一个发送队列和接收队列，那么当host os上有个多个vm时，多个vm将共享收发队列和中断号，这大大降低了网络包处理的速度，而且现在很多
    新的网卡从硬件上就支持多队列，旧的仿真驱动不能很好的利用这个功能。
   **（6）Multiple Queue virtio_scsi**
     类似网卡，每个块设备对应自己的收发队列和中断标志位
   （7）I/O Throttling for QEMU Guests
     官方解释是通过对guest block devices IO进行限速来防止system crash，这里的system是指host os吗，这个feature没太想清楚应用场景
   **（8）Windows 8 and Windows Server 2012 Guest Support**
     貌似是redhat 官方第一次宣布对windows 8和windows server 2012支持，之前都是kvm社区发布的support list。
   （9）Integration of Ballooning and Transparent Huge Pages
     增加了对Huge page的balloning和transparent的支持，之前是对4k page，这个功能应该也是redhat官方第一次宣布，之前kvm社区也早就宣布过。
   **（10）Bridge Zero Copy Transmit**
     字面意思是linux bridge的零拷贝传输网络包，这将会大大提高linux bridge的性能，但是具体之前拷贝发生在哪块后续有时间再去分析。
   （11）Live Migration Support
    redhat 6.5上vm迁移到redhat 7.0上的feature
   （12）Para-Virtualized Ticketlocks
     个人感觉这个是Para-Virtualized Ticket spinlocks，是对linux kernel的spinlock的半虚拟化支持，主要为了解决spinlock给vm带来的性能损失。（有待确认）
   **（13）KVM Clock Get Time Performance**
    通过vsyscall降低了guest os获取host os时钟的开销
   （14）Live Migration Threads
    将迁移的功能放在独立的线程中来做，与qemu主线程解耦，从而做到在执行迁移操作时不影响qemu主线程进行其他处理操作。
  **（15）VPC and VHDX File Formats**
    VPC和VHDX格式镜像的原生支持，不需要再进行格式转化了，主要用来兼容hyper-v。从这里也可以看出redhat可以和hyper-v合作也不会和vmware合作（个人意见）。

总结：由于个人研究方向的关系， 简单介绍了下redhat 7.0 virtualization和kernel相关的feature，其他还有些HA和网络相关的feature，后续有时间再做介绍。
        上述内容，纯属一家之言，如有错误，敬请斧正！