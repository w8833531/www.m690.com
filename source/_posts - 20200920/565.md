---
title: 系统升级之--Centos6.3 上实现非NFS root方式的无盘系统
tags:
  - centos6.3
  - diskless
  - dracut
  - initrd
  - nfsroot
  - ramdisk
  - 无盘
id: 565
categories:
  - linux
date: 2012-12-25 23:53:11
---

> 这两天在重做无盘系统，想把之前Centos5.2的无盘系统升级到Centos6.3。发现在Centos6.3上实现非NFS root方式的无盘系统与之前在Centos5.2上变动比较大。主要是initrd.img这个用来实现挂载驱动及挂载最终root分区的ramdisk的内部和以前有很大的不同。

为什么要用非NFSroot的无盘系统？好处当然是防止NFS单点故障，并提升无盘系统的性能及稳定性。

下面我来介绍一下非NFS root方式的无盘系统的思路（前面的4步与我之前介绍的[PXE安装centos6.3系统](http://www.m690.com/archives/555)基本相同，不同的是第5步）：
1、网卡pxe 启动－－2、网卡根据自己的MAC地址到DHCP获得指定的IP地址、tftp server的地址、主机名、DNS Server地址－－3、从tftp server下载到gpxelinux.0这个bootloader－－4、通过gpxelinux.0这个bootloader及MAC地址对应的PXE配置获取centos6.3启动用的kernel及一个用dracut定制的initrd.img文件－－5、用dracut工具定制生成一个initrd.img文件，带livenet模块。在initrd.img载入内存后，livenet模块会从网络下载一个定制的Centos6.3系统的root.img文件，把root.img切换成root,实现无盘系统的启动。

*   先介绍一下initrd.img的作用：
initrd.img是一个小的ramdisk，使用cpio+gzip格式（centos5及以上版本）。包括一些驱动模块，如磁盘驱动模块。通常的系统启动的步骤是bootloader(如GRUB）等启动内核，然后内核挂载initrd.img，并执行里面的脚本来进一步挂载各种各样的驱动模块，然后挂载真正的root分区，并执行root分区中的/sbin/init完成系统的启动。

*   再说一下非NFS root方式的无盘系统实现方式
非NFS root方式的无盘系统实现方式是使用dracut工具生成一个带livenet模块的initrd.img文件。这个initrd.img镜像可以从网络上下载一个定制的root.img（一个Centos6.3的ext4根分区镜像）,并把这个root.img文件挂到内存中，切换成root,实现无盘启动。

*   下面介绍一下root分区镜像的生成方法
root分区镜像生成方法其实很简。用dd生成一个image文件，在这个image文件上生成ext4文件系统，然后挂载这个image文件系统，用yum --installroot=/opt/disless/root -y groupinstall base安装一个centos6.3在这个image上，并对安装完成的系统进行配置。这样就生成了一个root分区的镜像了。下面给一个完整的生成root.img（centos6.3 ext4文件系统）的脚本： 
<pre class="blush: php">
#!/bin/bash
###USAGE:This script is used to create centos6.3 root image for diskless. Load&apply system config file to root image. 
###Author: Larry wu
###Email: w8833531@hotmail.com

#define config files dir 
config_dir=`pwd`/conf/WEB63
os=centos
release=6.3
#define root image size (0.5MB)
root_size=2500
#define root passwd
default_passwd=centos63
install_dir=`pwd`/$os$release
#yum install list define.For software install  requirement,It is not small.It's about 750M after install.
yumgrouplist="core"
yumlist="telnet bc bind-utils crontabs ed dbus file logrotate lsof cyrus-sasl-plain man ntsysv pciutils psacct quota setserial tmpwatch traceroute abrt-addon-ccpp abrt-addon-kerneloops abrt-addon-python abrt-cli b43-fwcutter biosdevname bridge-utils bzip2 cpuspeed cryptsetup-luks dmraid eject ethtool irqbalance kexec-tools lvm2 ledmon libaio mlocate ntpdate openssh-clients pam_passwdqc pcmciautils pinfo plymouth readahead rng-tools rsync scl-utils setuptool smartmontools sos strace sysstat systemtap-runtime tcpdump time unzip usbutils vim-enhanced wget which xz zip dos2unix unix2dos rpcbind zlib-devel openssl-devel libxml2-devel.x86_64 libjpeg-devel.x86_64 libcurl-devel.x86_64 libpng-devel.x86_64 freetype-devel.x86_64 libevent-devel.x86_64 nfs-utils.x86_64" 
x86_64_exclude="*i686*"

###define a write message process wm
wm(){
message=$1
info="\033[0;32m\t[Info]:"
end="\033[0m"
echo -e "$info $1 $end"
}

wm  "===make a root image"
mkdir -p ${install_dir}
cd ${install_dir}
mkdir root
wm "==create  root.img file use dd ,It need some time..."
dd if=/dev/zero of=root.img bs=512 count=${root_size}k
wm "==create ext4 fs on root.img ,It need some time..."
echo y | mkfs.ext4 root.img
wm "==mount root.img on $config_dir/root dir"
umount ${install_dir}/root
mount -o loop root.img ${install_dir}/root
wm "===root.img is created and mounted"
sleep 3

wm  "===install centos6.3 on root image"
mkdir -p root/var/lib/random-seed
wm "==yum install started ,It need some time..."
yum --installroot=${install_dir}/root -y groupinstall $yumgrouplist --exclude=${x86_64_exclude}
wm "==cp yum repo config"
rm -rf root/etc/yum.repos.d/*.repo
cp $config_dir/base.repo root/etc/yum.repos.d/
yum --installroot=${install_dir}/root -y install $yumlist --exclude=${x86_64_exclude}
wm "==add urandom and loop0 dev for yum and mount"
chroot root mknod -m 666  /dev/urandom c 1 9
chroot root mknod -m 660 /dev/loop0 b 7 0
wm "==yum install finished"
sleep 3

wm  "===cp config file to root.img"
wm  "==config font"
cp -rf $config_dir/i18n root/etc/sysconfig/
wm  "==config bash"
cp -rf $config_dir/bashrc root/etc/
cp -rf $config_dir/.bashrc root/root/
cp -rf $config_dir/.bash_profile root/root/
wm  "==config network"
cp -rf $config_dir/network root/etc/sysconfig/
cp -rf $config_dir/ifcfg-eth0 root/etc/sysconfig/network-scripts/ifcfg-eth0
cp -rf $config_dir/ifcfg-eth1 root/etc/sysconfig/network-scripts/ifcfg-eth1
cp -rf $config_dir/ifcfg-eth2 root/etc/sysconfig/network-scripts/ifcfg-eth2
cp -rf $config_dir/ifcfg-eth3 root/etc/sysconfig/network-scripts/ifcfg-eth3
cp -rf $config_dir/route-eth0 root/etc/sysconfig/network-scripts/route-eth0
wm  "==config localtime"
cp -rf root/usr/share/zoneinfo/Asia/Shanghai root/etc/localtime
wm  "==create resolv.conf"
touch root/etc/resolv.conf
wm  "==create rc.local"
cp -rf  $config_dir/rc.local root/etc/rc.local
if [ ! -e $config_dir/rc.local ];then
        cat >> root/etc/rc.local << EOF
touch /var/lock/subsys/local
#time check
/usr/sbin/ntpdate source;hwclock --systohc 
#wget a application initial script from source on base of hostname form dhcp.
hs=`hostname`
cd /root
wget http://source/scripts/$hs.sh
/bin/bash $hs.sh
EOF
fi
wm "==create crontab"
cp -rf  $config_dir/crontab root/var/spool/cron/root
chmod 600 root/var/spool/cron/root
wm "==create a sshd config"
cp -rf $config_dir/sshd_config root/etc/ssh/sshd_config
cp -rf $config_dir/ssh_config root/etc/ssh/ssh_config
wm "==create root initial ssh authorized_keys"
mkdir -p root/root/.ssh/
chmod 700 root/root/.ssh/
cp -rf $config_dir/authorized_keys root/root/.ssh/authorized_keys
wm "==create sysctl.conf"
cp -rf $config_dir/sysctl.conf root/etc/sysctl.conf
wm "==create limits.conf"
cp -rf $config_dir/limits.conf root/etc/security/limits.conf
rm -rf root/etc/security/limits.d/90-nproc.conf
wm "==create a /etc/fstab"
cp -fr $config_dir/fstab root/etc/fstab
wm "==cp /etc/vimrc"
cp -fr $config_dir/vimrc root/etc/vimrc
wm "==Initial root passwd"
chroot root pwconv
cat >> root/tmp/passwd << END
root:$default_passwd
END
chroot root chpasswd < root/tmp/passwd
#rm root/tmp/passwd
wm "==create users"
chroot root useradd -s /sbin/nologin appl
chroot root useradd -s /sbin/nologin zabbix
wm "==disable all service unused"
cp $config_dir/chkconfig.sh root/tmp/chkconfig.sh
chmod 755 root/tmp/chkconfig.sh
cp $config_dir/chkconfig.list root/tmp/chkconfig.list
chroot root /tmp/chkconfig.sh
wm "==config rsyslog.conf"
cp -fr  $config_dir/rsyslog.conf root/etc/rsyslog.conf
wm "==cp selinux config"
cp $config_dir/selinux.config root/etc/selinux/config
wm "===cp config file to root.img finished"
sleep 3

wm "===umount root.img"
umount root

wm "===It is done. do not forget cp root.img to you httpd server for initrd with livenet."
</pre>

*   下面介绍一下dracut的安装及使用方法
dracut 是一个生成initrd.img的工具。Centos6.3自带的dracut比较老，无法使用livenet模块。需要下载比较新版本的dracut工具来编译安装。我使用了dracut-019.tar.bz2这个版本。
下载地址如下：[http://www.kernel.org/pub/linux/utils/boot/dracut/](http://www.kernel.org/pub/linux/utils/boot/dracut/)
具体编译安装方法如下：
<pre class="blush: php">
tar -jxvf dracut-019.tar.bz2 
cd dracut-019
make 
make install prefix=/opt/dracut-019
###用dracut生成 initramfs-2.6.32-279.el6.x86_64一个带livenet功能模块的initrd文件 
/opt/dracut-019/bin/dracut --force **--add "livenet"** initramfs-2.6.32-279.el6.x86_64 `uname -r`
</pre>

*   配置pxe实现无盘启动
接下来配置/tftpboot/pxelinux.cfg/下的配置文件，实现pxe的非NFSroot的无盘启动。
<pre class="blush: php">
[root@pxe01 ~]# cd  /tftpboot/pxelinux.cfg/
###生成WEB63 PXE配置文件的内容，与之前的配置文件不同的是增加了这个选项，###root=live:http://10.127.x.xxx/image/centos63_64/root.img 
###来通过网络下载无盘的root.img这个根镜像文件
[root@pxe01 pxelinux.cfg]# cat WEB63 
default web 
label web
        kernel http://10.127.x.xxx/image/centos63_64/vmlinuz6.3_64  
#        append initrd=http://10.127.x.xxx/image/centos63_64/centos63_64_new.cpio.gz selinux=0 root=/dev/loop0 ramdisk_size=524288 load_ramdisk=1  console=ttyS0 console=tty0 debug
# root=live: 指定了root.img根镜像文件存放的位置
        append initrd=http://10.127.x.xxx/image/centos63_64/initramfs-2.6.32-279.el6.x86_64 root=live:http://10.127.x.xxx/image/centos63_64/root.img ramdisk_size=524288 load_ramdisk=1  console=ttyS0 console=tty0 debug
###把WEB63通过软链接的方式指向需要无盘启动的服务器的MAC地址
[root@pxe01 pxelinux.cfg]# ll | grep WEB63
lrwxrwxrwx 1 root root   5 Dec 17 13:40 01-00-00-6c-1e-00-5a -&gt; WEB63</pre>