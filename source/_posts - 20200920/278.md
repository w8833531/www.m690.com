---
title: 小计：HP-UX 11.31连接 EMC CX3-40f 的 failover设置
tags:
  - CX3-40f
  - emc
  - failover
  - 设置
id: 278
categories:
  - EMC
date: 2011-08-25 11:02:47
---

> 当一台主机连接到EMC CX3存储时，设置连接主机的failover model 非常重要。如果设置不正确，可能会使主机无法对磁盘进行管理，或failover 软件无法正常工作。所以设置 failover model对于主机连接存储是非常重要的一个环节。

之前，当我在HP-UX 11.31上安装完powerpath后，用ioscan -kfnC disk  扫到的磁盘数与我实现分配的lun数量始终不对。为此，我专门打电话到EMC的技术支持部门询问。在经过多次沟通后，终于找到了问题的所在。就是因为我没有在navisphere中进行failover的设置。

**下面，我介绍一下在navisphere中设置failover：**

1、在navisphere的 选择 tool--failover setup wizard 时行设置。
2、在选择连接的主机，存储后，最重要的是设置 initiator type/failover mode/array commpath/这向个参数。CX3-40f 相关各操作系统的这几个参数的设置，我会在下面给出一个文档。在这里，我用的是HP-UX 11.31,所以使用下面的设置 。
[![](http://www.m690.com/wp-content/uploads/2011/08/MSNLite-catchScreen-2011-08-25-10_12_40.jpeg "EMC CX3-40f for hp-ux 11.31 failover 设置")](http://www.m690.com/wp-content/uploads/2011/08/MSNLite-catchScreen-2011-08-25-10_12_40.jpeg)

**hp-ux 相关参数说明**
For HP-UX, arraycommpath can be 1 (Enabled) or 0 (Disabled); either will establish connectivity with the storage system. However, if diskinfo is to be used, then use “0” for the setting (emc68877) or diskinfo will return zero bytes for the alternate path.
You may use “CLARiiON Open” or "HP No Auto Trespass" if your applications use only Persistent Device Special Files (DSFs), also known as Agile DSFs, which have the format /dev/disk/disk42 and /dev/rdisk/42\. You must use “HP No Auto Trespass” if your applications require Legacy DSFs, which have the format /dev/dsk/c2t1d0 and /dev/rdsk/c2t1d0\. September 2007 HP-UX bundle (0709) is required.
For more information, see the HP-UX 11i v3 Persistent DSF Migration Guide (http://docs.hp.com/en/dsfmigration/persistent_dsf_migration.pdf ).
For HP-UX installations using VERITAS VxVM, set failovermode as follows:
• VERITAS VxVM 4.x or 5.x, with PowerPath: failovermode MUST be set as required by PowerPath
• VERITAS VxVM 4.x or 5.x without PowerPath:
o VxVM 4.x (11i v1 and 11i v2): failovermode must be set to 2
o VxVM 5.x (11i v2):
 non-clustered hosts: failovermode can be set to either 1 or 2
 clustered hosts: failovermode must be set to 1
For PowerPath for HP-UX, failovermode settings are as follows:
• FLARE 24 or earlier: failovermode MUST be set to 1
• FLARE 26 or later:
o PowerPath 5.1 or earlier: failovermode MUST be set to 1
o PowerPath 5.1.1 or later:
 For HP-UX 11i v1 or v2: failovermode MUST be set to 1
 For HP-UX 11iv3: failovermode MUST be set to 4

**更多信息，请查看下面的各系统参数设置表格文档**

[emc cx3-40f failover setting](http://www.m690.com/wp-content/uploads/2011/08/emc-cx3-40f-failover-setting-.pdf)