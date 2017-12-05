---
title: 小计：HP-UX CSTM命令列出内存问题
tags:
  - CSTM
  - HP-UX
  - 内存check
id: 269
categories:
  - HP-UX
date: 2011-08-17 16:08:45
---

> 发现CSTM是一个非常有用的工具，可以查看HP-UX各硬件的信息和状态及硬件故障。可以结合hp小机的mp的sl 命令，先查event日志中是否有报错？如果有，可以在HP-UX系统中用CSTM命令来查看详细的错误。

如我在MP中使用SL--sel--l命令,查看到下面的报错信息：MEM_SBE_IN_RANK错误

以root用户，在终端输入cstm，启动cstm这个工具
<pre class="blush: php">
# cstm
Running Command File (/usr/sbin/stm/ui/config/.stmrc).

-- Information --
Support Tools Manager

Version C.48.05

Product Number B4708AA

(C) Copyright Hewlett Packard Co. 1995-2004
All Rights Reserved

Use of this program is subject to the licensing restrictions described
in "Help-->On Version". HP shall not be liable for any damages resulting
from misuse or unauthorized use of this program.

cstm>
</pre>
输入map，列出主机所有的硬件信息
<pre class="blush: php">

cstm>map
                                      PAYDB

  Dev                                                 Last        Last Op      
  Num  Path                 Product                   Active Tool Status       
  ===  ==================== ========================= =========== =============
*   1  system               system (1016)             Information Successful   
*   2  memory               IPF_MEMORY (1016)         Information Successful   
*   3  0                    Cell (ffffffff)           Information Successful   
*   4  0/0                  Bus Adapter (103c12eb)    Information Successful   
*   5  0/0/0                PCI Bus Adapter (103c122e Information Successful   
*   6  0/0/0/1/0            PCI-X 1000Base-T Interfac Information Successful   
*   7  0/0/0/2/0            MPT SCSI Adapter (MPT SCS Information Successful   
*   8  0/0/0/2/0.6.0        SCSI Disk (HP300)         Information Successful   
*   9  0/0/0/2/1            MPT SCSI Adapter (MPT SCS Information Successful   
*  10  0/0/0/3/0            MPT SCSI Adapter (MPT SCS Information Successful   
*  11  0/0/0/3/0.6.0        SCSI Disk (HP300)         Information Successful   
*  12  0/0/0/3/1            MPT SCSI Adapter (MPT SCS Information Successful   
*  13  0/0/1                PCI Bus Adapter (103c12ee Information Successful   
*  14  0/0/2                PCI Bus Adapter (103c12ee Information Successful   
*  15  0/0/4                PCI Bus Adapter (103c12ee Information Successful   
*  16  0/0/6                PCI Bus Adapter (103c12ee Information Successful   
*  17  0/0/8                PCI Bus Adapter (103c12ee Information Successful   
*  18  0/0/8/1/0            PCI 1000Base-T LAN Adapte Information Successful   
*  19  0/0/8/1/1            PCI 1000Base-T LAN Adapte Information Successful   
*  20  0/0/10               PCI Bus Adapter (103c12ee Information Successful   
*  21  0/0/10/1/0           PCI 1000Base-T LAN Adapte Information Successful   
*  22  0/0/10/1/1           PCI 1000Base-T LAN Adapte Information Successful   
*  23  0/0/12               PCI Bus Adapter (103c12ee Information Successful   
*  24  0/0/12/1/0           FC Interface (HPAB378B_QL Information Successful   
*  25  0/0/12/1/0.11        Fibre Channel Driver (Mas                          
*  26  0/0/12/1/0.11.3.0.0\. EMC Array (EMCSYMMETRIX)                           
*  27  0/0/12/1/0.11.3.0.0\. EMC Array (EMCSYMMETRIX)                           
*  28  0/0/12/1/0.11.3.0.0\. EMC Array (EMCSYMMETRIX)                           
*  29  0/0/12/1/0.11.3.0.0\. EMC Array (EMCSYMMETRIX)                           
*  30  0/0/12/1/0.11.3.0.0\. EMC Array (EMCSYMMETRIX)                           
*  31  0/0/12/1/0.11.3.255\. EMC Array (EMCSYMMETRIX)                           
*  32  0/0/14               PCI Bus Adapter (103c12ee Information Successful   
*  33  0/0/14/1/0           FC Interface (HPAB378B_QL Information Successful   
*  34  0/0/14/1/0.21        Fibre Channel Driver (Mas                          
*  35  0/0/14/1/0.21.3.0.0\. EMC Array (EMCSYMMETRIX)                           
*  36  0/0/14/1/0.21.3.0.0\. EMC Array (EMCSYMMETRIX)                           
*  37  0/0/14/1/0.21.3.0.0\. EMC Array (EMCSYMMETRIX)                           
*  38  0/0/14/1/0.21.3.0.0\. EMC Array (EMCSYMMETRIX)                           
*  39  0/0/14/1/0.21.3.0.0\. EMC Array (EMCSYMMETRIX)                           
*  40  0/0/14/1/0.21.3.255\. EMC Array (EMCSYMMETRIX)                           
*  41  0/120                CPU (1016)                                         
*  42  0/121                CPU (1016)                                         
*  43  0/122                CPU (1016)                                         
*  44  0/123                CPU (1016)                                         
*  45  0/124                CPU (1016)                                         
*  46  0/125                CPU (1016)                                         
*  47  0/126                CPU (1016)                                         
*  48  0/127                CPU (1016)                                         
*  49  0/250                Core I/O Adapter (fffffff                          
*  50  0/250/0              ACPI Device (41435049)    Information Successful   
*  51  0/250/1              IPMI Controller (49504930 Information Successful   
*  52  0/250/2              RS-232 Interface (504e503 Information Successful   
</pre>
选中所需要查看的设备的num 输入命令 以内存为例 输入sel dev 2

然后在提示符下键入info     从系统kernel里面收集设备的信息

在提示符下键入il   列出设备的信息
<pre class="blush: php">

cstm>sel dev 2
cstm>info
-- Updating Map --
Updating Map...
cstm>il
-- Converting multiple raw log files to text. --
Preparing the Information Tool Log for each selected device...

.... PAYDB  :  10.127.8.181 .... 

-- Information Tool Log for system on path system --

Log creation time: Wed Aug 17 16:30:35 2011

Hardware path: system

Product ID                : ia64 hp server rx8640
Current Product Number    : AB297A
Original Product Number   : AB297A
System Firmware Revision  : 9.022
BMC Revision              : v03.01
System Serial Number:     : xxxxxxxxxxxx

System Software ID           : xxxxxxxxxx

      For additional information about the system and the CPUs, please run the
      following command:

                 /usr/contrib/bin/machinfo

Field Replaceable Unit Identification (FRUID):

=-+-=-+-=-+-=-+-=-+-=-+-=-+-=-+-=-+-=-+-=-+-=-+-=-+-=-+-=-+-=-+-=-+-=-+-=-+-=

-- Information Tool Log for IPF_MEMORY on path memory --

Log creation time: Wed Aug 17 16:30:35 2011

Hardware path: memory

Basic Memory Description 

   Module Type: MEMORY
   Page Size: 4096 Bytes
   Total Physical Memory: 65536 MB               #一共64G内存
   Total Configured Memory: 65536 MB
   Total Deconfigured Memory: 0 MB

Memory Board Inventory 

   DIMM Location          Size(MB) State   Serial Num       Part Num
   --------------------   -------- ------- ---------------- ------------------
   Cab 0 Cell 0 DIMM 0A   4096     Config  PRY081636Y       A9849-60301       
   Cab 0 Cell 0 DIMM 0B   4096     Config  PRY090561K       A9849-60301       
   Cab 0 Cell 0 DIMM 1A   4096     Config  PRY0905288       A9849-60301       
   Cab 0 Cell 0 DIMM 1B   4096     Config  PRY08163D7       A9849-60301       
   Cab 0 Cell 0 DIMM 2A   4096     Config  PRY08161EP       A9849-60301       
   Cab 0 Cell 0 DIMM 2B   4096     Config  PRY08166SL       A9849-60301       
   Cab 0 Cell 0 DIMM 3A   4096     Config  PRY0816114       A9849-60301       
   Cab 0 Cell 0 DIMM 3B   4096     Config  PRY0816111       A9849-60301       
   Cab 0 Cell 0 DIMM 4A   4096     Config  PRY08163D3       A9849-60301       
   Cab 0 Cell 0 DIMM 4B   4096     Config  PRY08161ES       A9849-60301       
   Cab 0 Cell 0 DIMM 5A   4096     Config  PRY081619T       A9849-60301       
   Cab 0 Cell 0 DIMM 5B   4096     Config  PRY08163X5       A9849-60301       
   Cab 0 Cell 0 DIMM 6A   4096     Config  PRY081619U       A9849-60301       
   Cab 0 Cell 0 DIMM 6B   4096     Config  PRY081630Z       A9849-60301       
   Cab 0 Cell 0 DIMM 7A   4096     Config  PRY0816183       A9849-60301       
   Cab 0 Cell 0 DIMM 7B   4096     Config  PRY0816371       A9849-60301       

   Cab 0 Cell 0 Total: 65536 (MB)

   ===========================================================================

Memory Error Log Summary       ** #这个是系统内存的运行信息，如果有error信息的话内存就有可能存在问题，我这边是DIMM 6A slot 上的内存在报 Single-Bit  的错误。**

   DIMM Location           Error Address     Error Type  Page           Count
   ----------------------  ----------------  ----------  -------------  -----
   Cab 0 Cell 0 DIMM 6A    0xa34077f80       Single-Bit  0xa34077       1    
   Cab 0 Cell 0 DIMM 6A    0xb4a727f80       Single-Bit  0xb4a727       1    
   Cab 0 Cell 0 DIMM 6A    0xc88f27f80       Single-Bit  0xc88f27       1    
   Cab 0 Cell 0 DIMM 6A    0xa324a7f80       Single-Bit  0xa324a7       1    
   Cab 0 Cell 0 DIMM 6A    0xc112d7f80       Single-Bit  0xc112d7       1    

   ===========================================================================

-- Information Tool Log for each selected device --
View   - To View the file.
Print - To Print the file.
SaveAs - To Save the file.
Enter Done, Help, Print, SaveAs, or View: [Done] 
cstm>
</pre>