---
title: mysql 5.5.17编译安装配置小计
tags:
  - install
  - mysql
  - mysql5.5
id: 335
categories:
  - mysql
  - 技术
date: 2011-12-08 17:07:01
---

> 最近两天在安装一个线上社区系统，决定用mysql 5.5系统，所以就把编译参数贴出来，和大家一起分享一下。

<ul>
         	<li>增加一个mysql用户</li>
             useradd mysql -c 'mysql server user'
	<li>mysql 在编译前需要安装的软件包，mysql5.5开始改用cmake来做config了。另外建议安装上libaio包，让mysql使用系统自带的aio：</li>
             yum install gcc-c++.x86_64　 gperf.x86_64　 ncurses-devel.x86_64　 readline-devel.x86_64　 libaio-devel.x86_64
             cd cmake-2.8.4; ./configure && make && make install
         	<li>mysql 编译安装参数：</li>
             cd mysql-5.5.17; 
             /usr/local/bin/cmake -DCMAKE_INSTALL_PREFIX=/opt/mysql -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system   -DENABLED_LOCAL_INFILE=1 -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DEXTRA_CHARSETS=all  -DMYSQL_TCP_PORT=3306 -DMYSQL_USER=mysql
             make –j8 && make install
             /opt/mysql/scripts/mysql_install_db --user=mysql --basedir=/opt/mysql --datadir=/data/mysql/data
         	<li>配置一个service启动脚本</li>
             cp ../support-files/mysql.server /etc/init.d/mysqld
             chkconfig mysqld on
         	<li>配置一个/etc/my.cnf文件。配置主要以前5.1上般过来的，老的不能用的参数，我注释掉了，注释下面如果有新的可用参数的话，会使用新的可用参数。</li>
cat /etc/my.cnf
<pre class="blush: php">
#系统为8G内存、8核CPU，6块盘RAID10的专用mysql服务器
[client]
port            = 3306
default-character-set = utf8   #mysql cleint端用了系统自带的mysql5.1的
socket          = /tmp/mysql.sock

[mysqld]

############################### special ###############################
#5.5.3开始建议使用系统自带的innodbbase引擎，下面三行就不用了。
#ignore-builtin-innodb
#plugin-load=innodb=ha_innodb_plugin.so;innodb_trx=ha_innodb_plugin.so;innodb_locks=ha_innodb_plugin.so;innodb_cmp=ha_innodb_plugin.so;innodb_cmp_reset=ha_innodb_plugin.so;innodb_cmpmem=ha_innodb_plugin.so;innodb_cmpmem_reset=ha_innodb_plugin.so
#skip-innodb

#master上要开binlog
server-id = 101
#pid-file = /tmp/mysqldb01.pid
basedir=/opt/mysql
datadir=/data/mysql/data
log-bin=/opt/data/mysql/mysql_log/mysql-bin
binlog_format=mixed
expire_logs_days = 7
max_binlog_size = 1024M
sync-binlog = 0

############################### general ###############################

port            = 3306
socket          = /tmp/mysql.sock
#skip-locking       #语法变动，要用下面的
skip-external-locking

skip-name-resolve

max_sp_recursion_depth=4
#default-character-set = utf8  #语法变动，字符集默认用utf8
character-set-server = utf8
back_log = 100
max_connections = 500
max_connect_errors = 10
table_cache = 2048

key_buffer_size = 512M
max_allowed_packet = 512M
binlog_cache_size = 8M
max_heap_table_size = 512M
sort_buffer_size = 512M
join_buffer_size = 512M
thread_cache_size = 8
thread_concurrency = 16
query_cache_size = 512M
query_cache_limit = 2M
ft_min_word_len = 4
#default_table_type = INNODB  #语法变动
default-storage-engine=innodb
thread_stack = 256K
transaction_isolation = REPEATABLE-READ
tmp_table_size = 256M
bulk_insert_buffer_size=128M
read_buffer_size=128M

datadir=/opt/data/mysql/data/
tmpdir=/opt/data/mysql/temp/

log-error=/opt/data/mysql/mysql_log/err.log
slow_query_log=on
#log_slow_queries=/opt/data/mysql/mysql_log/slow.log
slow-query-log-file=/opt/data/mysql/mysql_log/slow.log
long_query_time = 1
#log_long_format
#log_queries_not_using_indexes
relay-log=/opt/data/mysql/mysql_log/mysql-relay-bin
max_relay_log_size = 1024M
max_prepared_stmt_count = 40000

############################### myisam ###############################

myisam_recover
myisam_repair_threads = 1
#myisam_max_extra_sort_file_size = 100G
#myisam_max_sort_file_size = 100G

############################### innodb ###############################

innodb_data_home_dir = /opt/data/mysql/data/
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = /opt/data/mysql/mysql_log/
innodb_file_per_table
innodb_open_files=30000
innodb_additional_mem_pool_size = 128M
innodb_buffer_pool_size = 6G
#innodb_file_io_threads = 8
innodb_read_io_threads=8
innodb_write_io_threads=8 
#innodb_force_recovery=1
innodb_thread_concurrency = 30
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 8M
innodb_log_file_size = 1024M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 80
innodb_lock_wait_timeout = 30 
innodb_file_format=Barracuda   #使用suoyu格式，要快一点
innodb_file_format_max=Barracuda
innodb_io_capacity=400     #这个与磁盘iops对应，我的机器可以达到400，默认200
innodb_use_native_aio=1    #用系统aio,这是默认设置

[mysqldump]
quick
max_allowed_packet = 512M

[mysql]
default-character-set = utf8

[myisamchk]
key_buffer_size = 512M
sort_buffer_size = 512M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
#interactive-timeout

[mysqld_safe]
open-files-limit = 30000  
</pre> 