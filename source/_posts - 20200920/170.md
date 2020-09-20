---
title: 'HPUX 安装和配置secure shell---sshd(2010-11-02 17:06:42)'
tags:
  - HP-UX
  - ssh
id: 170
categories:
  - HP-UX
date: 2011-07-26 15:04:50
---

光盘安装方法：

1、把第一张软件安装光盘mount上去：

加个mount光盘的目录

mkdir /iso

查看光驱设备名：

# ioscan -fnC disk
Class     I  H/W Path       Driver S/W State   H/W Type     Description
=======================================================================
disk      0  0/0/0/2/0.6.0  sdisk   CLAIMED     DEVICE       HP 300 GST3300655LC
                           /dev/dsk/c0t6d0     /dev/dsk/c0t6d0s3   /dev/rdsk/c0t6d0s2
                           /dev/dsk/c0t6d0s1   /dev/rdsk/c0t6d0    /dev/rdsk/c0t6d0s3
                           /dev/dsk/c0t6d0s2   /dev/rdsk/c0t6d0s1
disk      1  0/0/0/2/1.2.0  sdisk   CLAIMED     DEVICE       Optiarc DVD RW AD-5170A
                           /dev/dsk/c1t2d0   /dev/rdsk/c1t2d0
disk      2  0/0/0/3/0.6.0  sdisk   CLAIMED     DEVICE       HP 300 GST3300655LC
                           /dev/dsk/c2t6d0   /dev/rdsk/c2t6d0

把光驱挂上：

# mount /dev/dsk/c1t2d0 /iso

2、安装secure shell:

# swinstall

在Source Depot Type:选择Local CDROM，选择安装 SecureShell，按空格，按m，选ACTIONS,选Install...

3、配置并启动ssh

配置文件如下：

# cat /opt/ssh/etc/sshd_config
Port 22
Protocol 2,1
ListenAddress 0.0.0.0
#ListenAddress ::
KeyRegenerationInterval 3600
ServerKeyBits 768
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 600
PermitRootLogin yes
PubkeyAuthentication yes
AuthorizedKeysFile      .ssh/authorized_keys
IgnoreRhosts yes
HostbasedAuthentication no
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
MaxStartups 20
Subsystem       sftp    /opt/ssh/libexec/sftp-server

注：上面的sshd配置只开了key认证，请确认你已经把自己的公钥放入了~/.ssh/authorized_keys文件中，不然将无法使用ssh登录。

关掉telnet :

注释掉/etc/inetd.conf中的telnet那行：

# cat /etc/inetd.conf | grep telnet
#telnet       stream tcp6 nowait root /usr/lbin/telnetd  telnetd

重新启动inetd

# /sbin/init.d/inetd stop
Internet Services stopped
# /sbin/init.d/inetd start
Internet Services started

启动方法如下：

# /sbin/init.d/secsh start