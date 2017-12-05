---
title: 使用fio工具在Centos6.3上对华为ES2000M-640 SSD卡测试结果
tags:
  - fio
  - iodeps
  - libaio
  - ssd
  - 性能
  - 测试
id: 603
categories:
  - linux
  - 技术
date: 2013-02-28 11:50:12
---

测试结果如下：
服务器：IBM x3650 m3 
系统：Centos6.3 x86_64
测试工具: fio  
测试工具相关网站：[使用fio 进行性能测试](http://blog.csdn.net/wyzxg/article/details/7454072)
                [fio 官网](http://freecode.com/projects/fio)
                [有关iodepth](http://os.51cto.com/art/201205/334274.htm)

测试命令及测试结果：
1、同步随机读写：fio -filename=/ssd/ccc  -direct=1 -rw=randrw -bs=8k -size 30G -numjobs=8 -runtime=300 -group_reporting -name=file        （注：卡挂在/ssd目录下面，8进程并发，8KB随机读写，ioengine=sync同步，读写比是5:5）
                读性能：read : io=39805MB, bw=135868KB/s, iops=16983 , runt=300001msec
写性能：write: io=39787MB, bw=135804KB/s, iops=16975 , runt=300001msec

2、同步顺序写：fio -filename=/ssd/ccc  -direct=1 -rw=write -bs=8k -size 30G -numjobs=8 -runtime=120 -group_reporting -name=file
       顺序写性能：write: io=25622MB, bw=218641KB/s, iops=27330 , runt=120002msec

3、同步顺序读：fio -filename=/ssd/ccc  -direct=1 -rw=read -bs=8k -size 30G -numjobs=8 -runtime=120 -group_reporting -name=file
       性能： io=33432MB, bw=285286KB/s, iops=35660 , runt=120001msec

4、异步随机读写：fio -filename=/ssd/ccc  -direct=1 -rw=randrw -bs=8k -size 30G -numjobs=8 -runtime=120 -group_reporting -name=file -ioengine=libaio -iodepth=16 -iodepth_batch=8 -iodepth_low=8 -rwmixwrite=20  （注：使用linux下的ioengine=libaio进行异步读写，并增加 iodepth值到16,读写比是8:2）
      读性能：read : io=96913MB, bw=826971KB/s, iops=103371 , runt=120003msec
               写性能：write: io=24225MB, bw=206711KB/s, iops=25838 , runt=120003msec

5、异步顺序写：fio -filename=/ssd/ccc  -direct=1 -rw=write -bs=8k -size 30G -numjobs=8 -runtime=120 -group_reporting -name=file -ioengine=libaio -iodepth=16 -iodepth_batch=8 -iodepth_low=8
      性能：write: io=78999MB, bw=674115KB/s, iops=84264 , runt=120002msec

6、异步顺序读：fio -filename=/ssd/ccc  -direct=1 -rw=read -bs=8k -size 30G -numjobs=8 -runtime=120 -group_reporting -name=file -ioengine=libaio -iodepth=16 -iodepth_batch=8 -iodepth_low=8
     性能：read : io=130105MB, bw=1084.2MB/s, iops=138776 , runt=120002msec

7、异步随机写：fio -filename=/ssd/ccc  -direct=1 -rw=randwrite -bs=8k -size 30G -numjobs=8 -runtime=120 -group_reporting -name=file -ioengine=libaio -iodepth=16 -iodepth_batch=8 -iodepth_low=8
    性能：write: io=69427MB, bw=592432KB/s, iops=74054 , runt=120003msec

8、异步随机读：fio -filename=/ssd/ccc  -direct=1 -rw=randread -bs=8k -size 30G -numjobs=8 -runtime=120 -group_reporting -name=file -ioengine=libaio -iodepth=16 -iodepth_batch=8 -iodepth_low=8
   性能：read : io=134899MB, bw=1124.2MB/s, iops=143890 , runt=120002msec
测试结果疑问：
在同步读写的情况下，读写带宽只用280MB/s,IOPS也远没有达到下面的性能指标。
在异步读写的情况下，带宽及IOPS接近下面 性能指标，读IOPS在144K左右，与250K也有一定距离。

同步与异步读写性能为什么会有这么大的差异？

性能指标：
	SAS硬盘 	SATA SSD 	华为SSD 	相对SSD硬盘提升 
容量 	600G 	200G 	640GB 	2.2倍↑ 
写带宽(MB/s) 	60 	275 	700 	1.5倍↑ 
读带宽(MB/s) 	120 	285 	1200 	3.2倍↑ 
4K随机IOPS 	180 	read: 50k 
write: 15k 	read: 250k 
write: 80k~170k 	4.3倍↑ 