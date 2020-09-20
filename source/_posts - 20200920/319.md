---
title: HP-UX 重建一个VG的LVMTAB的方法
tags:
  - HP-UX
  - VG
  - 导出，重建
id: 319
categories:
  - HP-UX
date: 2011-11-17 11:51:55
---

1、记录vgmap  
   ll /dev/*/group > /tmp/vgmap.txt
2、export一个VG  
   vgexport -s -v -m /tmp/vgpayora /dev/vgpayora
3、重建这个VG的DEV目录 
  mkdir /dev/vgpayora
  mknod /dev/vgpayora/group c 64 0x010000
4、重新导入这个VG  
  vgimport -s -v -m /tmp/vgpayora /dev/vgpayora