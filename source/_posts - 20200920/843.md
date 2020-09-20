---
title: 备忘--nginx+php-fpm+mysql apache+php编译参数
tags:
  - mysql
  - nginx
  - php
  - 编译安装
id: 843
categories:
  - linux
  - 技术
date: 2014-12-20 21:28:36
---

> 经常安装这些东东，CentOS5.6上编一次，6.3又编译一次，这次6.5上又要编译一次。每次编译都要去翻一遍编译参数，不行了，这次一定要记录一下。

nginx安装
<pre>
yum install pcre-devel.x86_64 openssl-devel.x86_64
useradd www -s /sbin/nologin
./configure --user=www --group=www --prefix=/opt/nginx --conf-path=/opt/conf/nginx/nginx.conf --with-http_stub_status_module --with-http_ssl_module --with-http_sub_module --with-md5=/usr/lib --with-sha1=/usr/lib --http-fastcgi-temp-path=/opt/nginx/fastcgi-temp --http-proxy-temp-path=/opt/nginx/proxy-temp --http-client-body-temp-path=/opt/nginx/body-temp --with-http_gzip_static_module
</pre>
mysql安装
<pre>
useradd mysql
yum install gcc-c++.x86_64 gperf.x86_64 ncurses-devel.x86_64 readline-devel.x86_64 libaio-devel.x86_64 cmake
/usr/local/bin/cmake -DCMAKE_INSTALL_PREFIX=/opt/mysql -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STO
RAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_FEDERATED_STOR
AGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DENABLED_LOCAL_INFILE=1 -DDEF
AULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DEXTRA_CHARSETS=all -DMYSQL_TCP_PORT=3306 -DMYSQL_USER=mysql
cmake  -DCMAKE_INSTALL_PREFIX=/opt/mysql -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 
-DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -
DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DENABLED_LOCAL_INFILE=1 -DDEFAULT_CHARSET=u
tf8 -DDEFAULT_COLLATION=utf8_general_ci -DEXTRA_CHARSETS=all -DMYSQL_TCP_PORT=3306 -DMYSQL_USER=mysql
</pre>
php 安装：
<pre>
yum install -y libxml2-devel.x86_64 libjpeg-devel.x86_64 libcurl-devel.x86_64 libpng-devel.x86_64 freetype-devel.x86_64  libmcrypt.x86_64 libmcrypt-devel.x86_64 mhash-devel.x86_64
'./configure'  '--prefix=/opt/php' '--with-config-file-path=/opt/conf/php' '--enable-cgi' '--with-pear=/opt/php/pear' '--enable-fpm' '--with-fpm-conf=/opt/conf/php/php-fpm.conf' '--with-fpm-log=/opt/conf/php/php-fpm.log' '--with-fpm-pid=/opt/conf/php/php-fpm.pid' '--enable-gd-native-ttf' '--with-gd' '--with-pdo-mysql=/opt/mysql' '--with-mysql=/opt/mysql' '--with-mysqli=/opt/mysql/bin/mysql_config' '--with-curl' '--with-zlib' '--with-openssl' '--enable-mbstring' '--enable-exif' '--disable-debug' '--disable-rpath' '--without-pdo-sqlite' '--without-sqlite' '--enable-sockets' '--enable-pcntl' '--enable-bcmath' '--enable-zip' '--enable-ftp' '--enable-soap' '--with-mcrypt' '--with-mhash' '--enable-zip'
</pre> 
apache+php 安装：
<pre>
#apache 
yum install -y zlib-devel.x86_64 openssl-devel.x86_64
./configure --prefix=/opt/latop/phpfront3/ --enable-modules=all --enable-mods-shared=all --enable-rewrite --enable-so --enable-http --enable-ssl --with-libdir=lib64
#php
yum install -y libxml2-devel.x86_64 libjpeg-devel.x86_64 libcurl-devel.x86_64 libpng-devel.x86_64 freetype-devel.x86_64  libmcrypt.x86_64 libmcrypt-devel.x86_64 mhash-devel.x86_64
./configure --prefix=/opt/latop/phpfront3/php --with-config-file-path=/opt/latop/phpfront3/conf --disable-debug --with-apxs2=/opt/latop/phpfront3/bin/apxs --enable-cli --enable-soap  --with-gd  --enable-gd-native-ttf  --with-iconv --with-openssl --with-pic --enable-sockets --with-curl  --enable-mbstring --with-zlib --with-pdo-mysql=/opt/mysql --with-mysqli=/opt/mysql/bin/mysql_config --enable-pcntl --enable-bcmath --enable-zip --with-mcrypt --with-mhash --with-libdir=/usr/lib64 