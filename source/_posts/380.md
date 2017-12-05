---
title: redis 主从配置实例、注意事项、及备份方式
tags:
  - redis
  - 主从配置
id: 380
categories:
  - linux
  - 技术
date: 2012-01-28 21:28:42
---

[![](http://www.m690.com/wp-content/uploads/2012/01/redis.jpg "redis")](http://www.m690.com/wp-content/uploads/2012/01/redis.jpg)
> 这两天在配置线上使用的redis服务。总得看起来，redis服务的配置文件还是非常简洁、清楚，配置起来非常顺畅，赞一下作者。

下面是我使用的配置，使用主从模式，在master上关掉所有持久化，在slave上使用AOF持久化：
$cat /opt/redis/etc/redis.conf
<pre class="blush: php">
######Master config
###General 配置
daemonize yes     #使用daemon 方式运行程序，默认为非daemon方式运行
pidfile /tmp/redis.pid  #pid文件位置
port 6379   #使用默认端口
timeout 30   # client 端空闲断开连接的时间
loglevel warning  #**日志记录级别，默认是notice，我这边使用warning,是为了监控日志方便。使用warning后，只有发生告警才会产生日志，这对于通过判断日志文件是否为空来监控报警非常方便。**
logfile /opt/logs/redis/redis.log   #日志产生的位置
databases 16   #默认是0，也就是只用1 个db,我这边设置成16，方便多个应用使用同一个redis server。使用select n 命令可以确认使用的redis db ,这样不同的应用即使使用相同的key也不会有问题。

###下面是SNAPSHOTTING持久化方式的策略。为了保证数据相对安全，在下面的设置中，更改越频繁，SNAPSHOTTING越频繁，也就是说，压力越大，反而花在持久化上的资源会越多。所以我选择了master-slave模式，并在master关掉了SNAPSHOTTING。
#save 900 1     #在900秒之内，redis至少发生1次修改则redis抓快照到磁盘
#save 300 100   #在300秒之内，redis至少发生100次修改则redis抓快照到磁盘
#save 60 10000  #在60秒之内，redis至少发生10000次修改则redis抓快照到磁盘
rdbcompression yes  #使用压缩
dbfilename dump.rdb  #SNAPSHOTTING的文件名
dir /opt/data/redis/ #SNAPSHOTTING文件的路径

###REPLICATION 设置，
#slaveof <masterip> <masterport>  #如果这台机器是台redis slave，可以打开这个设置。如果使用master-slave模式，我就会在master上把SNAPSHOTTING关了，这样可以不用在master上做持久化，而是在slave上做，这样可以大大提高master 内存使用率和系统性能。
#slave-serve-stale-data yes  #如果slave 无法与master 同步，是否还可以读

### SECURITY 设置  
#requirepass aaaaaaaaa   #redis性能太好，用个passwd 意义不大
#rename-command FLUSHALL ""  #**可以用这种方式关掉非常危险的命令，如FLUSHALL这个命令，它清空整个 Redis 服务器的数据，而且不用确认且从不会失败**

###LIMIT 设置
maxclients 0 #无client连接数量限制
maxmemory 14gb #redis最大可使用的内存量，**我的服务器内存是16G，如果使用redis SNAPSHOTTING的copy-on-write的持久会写方式，会额外的使用内存，为了使持久会操作不会使用系统VM，使redis服务器性能下降，建议保留redis最大使用内存的一半8G来留给持久化使用，我个人觉得非常浪费。我没有在master上不做持久化，使用主从方式**
maxmemory-policy volatile-lru  #**使用LRU算法删除设置了过期时间的key,但如果程序写的时间没有写key的过期时间，建议使用allkeys-lru，这样至少保证redis不会不可写入。**

###APPEND ONLY MODE 设置
appendonly no  #不使用AOF，AOF是另一种持久化方式，我没有使用的原因是这种方式并不能在服务器或磁盘损坏的情况下，保证数据可用性。
appendfsync everysec  
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

###SLOW LOG 设置
slowlog-log-slower-than 10000  #**如果操作时间大于0.001秒，记录slow log,这个log是记录在内存中的，可以用redis-cli slowlog get 命令查看**
slowlog-max-len 1024  #slow log 的最大长度

###VIRTUAL MEMORY 设置
vm-enabled no   #不使用虚拟内存，在redis 2.4版本，作者已经非常不建议使用VM。
vm-swap-file /tmp/redis.swap
vm-max-memory 0
vm-page-size 32
vm-pages 134217728
vm-max-threads 4

###ADVANCED CONFIG 设置，下面的设置主要是用来节省内存的，我没有对它们做修改
hash-max-zipmap-entries 512   
hash-max-zipmap-value 64
list-max-ziplist-entries 512
list-max-ziplist-value 64
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
activerehashing yes

###INCLUDES 设置 ，使用下面的配置，可以配置一些个另其它的设置，如slave的配置
#include /path/to/local.conf
#include /path/to/other.conf
#include /opt/redis/etc/slave.conf  **如果是slave server,把这个注释打开**
</pre>

</strong>slave 配置：**
$cat /opt/redis/etc/slave.conf
<pre class="blush: php">
######slave config
###REPLICATION 设置，
slaveof redis01 6397  #如果这台机器是台redis slave，可以打开这个设置。如果使用master-slave模式，我就会在master上把SNAPSHOTTING关了，这样可以不用在master上做持久化，而是在slave上做，这样可以大大提高master 内存使用率和系统性能。
slave-serve-stale-data no  #如果slave 无法与master 同步，设置成slave不可读，方便监控脚本发现问题。
###APPEND ONLY MODE 设置
appendonly yes  #在slave上使用了AOF,以保证数据可用性。
</pre>

<strong>其它后继数据备份工作 **
1、用redis-cli bgsave 命令每天凌晨一次持久化一次master redis上的数据，并CP到其它备份服务器上。
2、用redis-cli bgrewriteaof 命令每半小时持久化一次 slave redis上的数据，并CP到其它备份服务器上。
3、写个脚本 ，定期get master和slave上的key,看两个是否同步，如果没有同步，及时报警。