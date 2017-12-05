---
title: 教训--opennebula 上KVM虚拟机镜像被删除
id: 963
categories:
  - 技术
date: 2015-09-30 17:56:23
tags:
---

> 是教训，马上要记下来，不然很快就会忘记。今天在操作公司的opennebula云平台上的虚拟机时，在网页上做了shutdown hard操作，但却发现虚拟机镜像却已经在KVM主机上删除了。明显这是一个会产生歧义的操作，（应该是opennebula把虚拟机关闭并删除，但不知道为什么用shutdown hard这个名字），但当出现系统上重要文件被误删除时，我们的处理流程却出现了问题，导至这台KVM主机上的数据在删除后，无法恢复。

一、先说说云平台：
现在我们都在用各种云平台，但有几个问题，我们必须面对：
1、使用云平台很容易产生误操作，上面的一些操作的含义，很容易让人产生误解。
<pre>
shutdown <range|vmid_list>
        Shuts down the given VM. The VM life cycle will end.

        With --hard it unplugs the VM.

        States: RUNNING, UNKNOWN (with --hard)
        valid options: schedule, hard
</pre>

2、云平台上的数据安全如何保证？这次就是因为KVM虚拟机的磁盘镜像文件没有进行备份，所以才出现VM上数据丢失的低级错误。备份、备份、备份！！！重要的事情说三遍。

二、再说说在当出现linux系统上的数据被误删除且没有备份时，我们的操作流程应该是怎么样的？
1、应该马上停掉这台机器上的应用，并把数据分区umount下来。可恶的是，我们之前的SA居然把整个系统分在一个/分区上，不关机，根本无法umount被删除数据的分区。
2、在系统分区规划时，一定要把数据分区和系统分区分开来！当出现上面的情况，就可以马上umount掉数据分区，进行数据分区的数据恢复工作了。
3、恢复数据的工具选择，是选择优势在恢复单个文件且不用umount分区的foremost 还是用 只能umount分区后，对整个extx分区数据进行恢复的extundelete工具。很遗憾，我们当时因为无法umount分区，所以选择了foremost ,而更要命的是，因为打错了命令，直接把数据恢复到了原来的/分区下，其实就是把这个分区上的被删除数据给覆盖了。**所以，如果是回复linux 的extx分区上的数据，一定要umount分区后，使用extundelete工具进行整个分区的恢复。更稳妥的方式，应该是挂一个大的NFS目录，把这个磁盘设备如/dev/sdb1整个dd到这个NFS目录上，然后再做恢复操作。如果是只有一个/分区，可以使用pxe boot的方式，把系统的挂到 pxe boot上，然后再scp extundelete工具，进行恢复操作。**

三、最后说说，我们的具体恢复数据的过程，虽然失败了 ：
1、在没有umount分区且没有dd一个磁盘备份的情况下，大胆的使用了这个致命 foremost工具，还把恢复数据写在要恢复的分区上。
<pre>
wget http://foremost.sourceforge.net/pkg/foremost-1.5.7.tar.gz
tar -zxvf foremost-1.5.7.tar.gz 
cd foremost-1.5.7
make
#要恢复的分区为/dev/sdb1
fsdisk /dev/sda
mkfs.ext4 /dev/sda3
mount /dev/sda3 /backup
#居然下面的命令直接把恢复文件写到了/backup_xxxx_xxxx目录下面也，也就是直接定到了/dev/sdb1上，如果umount分区，就不会有这种问题了：（
foremost -v -T  -i /dev/sdb1 -o /backup
</pre>
2、发现问题后，赶紧用pxe boot把这台机器挂到rescue模式下面,再scp extundelete 工具进行恢复操作，具体如下：
<pre>
#安装extundelete
wget http://sourceforge.net/projects/extundelete/files/latest/download?source=typ_redirect 
tar -jxvf extundelete-0.2.4.tar.bz2 
cd extundelete-0.2.4
yum install -y e2fsprogs-devel.x86_64 e2fsprogs-libs.x86_64
./configure && make &&　makeinstall
#设置tftpboot ，进rescue模式，具体tftp/dhcp安装配置就不说了
[root@dir01 pxelinux.cfg]# cat ../pxelinux.cfg/default
label install_centos65_64_rescue
kernel install_centos65_64
MENU LABEL Install Centos65_64_rescue
append  ksdevice=bootif ip=dhcp nomount rescue lang=en_US keymap=us root=/dev/initrd initrd=install_centos65_64.img method=http://dir/os/centos/6.5/os/x86_64
ipappend 2
#scp extundelete 工具
scp 10.x.x.2:/tools/extundelete /tools/
#在进入pxe boot rescue模式后，把用来保存恢复数据的盘给挂上
mkdir /mnt/sda3
mount /dev/sda3 /mnt/sda3
cp /tools/extundelete  /mnt/sda3/
cd /mnt/sda3
./extundelete /dev/sdb1 --restore-all
</pre>

四、虽然因上面的原因数据恢复不成功，但失败是成功之母。
五、最后说一下，因为我们的合作伙伴在应用层面进行了数据备份，后面进行了应用层数据恢复。所以数据并没有丢失，影响了5小时的用户访问。所以，提醒大家即使使用公有云上的虚拟机，备份自己的应用数据也是很重要的事情 ：）。

  