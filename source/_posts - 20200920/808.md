---
title: 在IIS6上实现php代码运行小计
tags:
  - fastcgi
  - IIs6
  - php
  - 跑php
id: 808
categories:
  - 技术
date: 2014-08-14 11:49:43
---

> 一台windows2003的服务器上，已经有asp.net站点在上面跑了，现在因为开发人员问题，新加的一个站点要运行php程序。线上系统维护人员从本质上来说，应该要满足开发的需求的，所以决定使用IIS+fastCGI+php来实现这个站点的架设。

1\. php+fastcgi的安装配置可以参考下面的几个链接：
[这个是微软的](http://www.iis.net/learn/application-frameworks/install-and-configure-php-applications-on-iis/using-fastcgi-to-host-php-applications-on-iis-60)
[这个是php的](http://php.net/manual/en/install.windows.iis6.php)
[这个我觉得是最好的](http://www.web-site-scripts.com/knowledge-base/article/AA-00491/0/PHP-installation-on-IIS6.html)
[英文不好的，可以看看这个](http://www.cnblogs.com/zengxiangzhan/archive/2010/03/05/1679286.html)

2、php.ini 配置文件:
<pre>
[PHP]
engine = On
short_open_tag = On
asp_tags = Off
precision = 14
y2k_compliance = On
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
unserialize_callback_func =
serialize_precision = 17
allow_call_time_pass_reference = Off
safe_mode = Off
safe_mode_gid = Off
safe_mode_include_dir =
safe_mode_exec_dir =
safe_mode_allowed_env_vars = PHP_
safe_mode_protected_env_vars = LD_LIBRARY_PATH
open_basedir ="D:\web\www.xxxx.cn\htdocs"
disable_functions =
disable_classes =
zend.enable_gc = On
expose_php = On
max_execution_time = 30
max_input_time = 60
memory_limit = 512M
error_reporting = E_ALL & ~E_DEPRECATED
display_errors = Off
display_startup_errors = Off
log_errors = On
log_errors_max_len = 1024
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
track_errors = Off
html_errors = Off
error_log = "D:\web\www.xxxx.cn\logs\W3SVC2\php_errors.log"
variables_order = "GPCS"
request_order = "GP"
register_globals = Off
register_long_arrays = Off
register_argc_argv = Off
auto_globals_jit = On
post_max_size = 8M
magic_quotes_gpc = On
magic_quotes_runtime = Off
magic_quotes_sybase = Off
auto_prepend_file =
auto_append_file =
default_mimetype = "text/html"
doc_root =
user_dir =
extension_dir = "c:\php\ext"
enable_dl = Off
cgi.force_redirect = 0
cgi.fix_pathinfo=1
fastcgi.impersonate = 1
fastcgi.logging = 1
file_uploads = On
upload_tmp_dir = "C:\PHP\upload"
upload_max_filesize = 2M
max_file_uploads = 20
allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60
extension=php_curl.dll
extension=php_fileinfo.dll
extension=php_gd2.dll
extension=php_mbstring.dll
extension=php_mysqli.dll
[Date]
date.timezone = "Asia/Shanghai"
[Pdo]
[Pdo_mysql]
pdo_mysql.cache_size = 2000
pdo_mysql.default_socket=
[Syslog]
define_syslog_variables  = Off
[mail function]
SMTP = localhost
smtp_port = 25
mail.add_x_header = On
[SQL]
sql.safe_mode = Off
[ODBC]
odbc.allow_persistent = On
odbc.check_persistent = On
odbc.max_persistent = -1
odbc.max_links = -1
odbc.defaultlrl = 4096
odbc.defaultbinmode = 1
[Interbase]
ibase.allow_persistent = 1
ibase.max_persistent = -1
ibase.max_links = -1
ibase.timestampformat = "%Y-%m-%d %H:%M:%S"
ibase.dateformat = "%Y-%m-%d"
ibase.timeformat = "%H:%M:%S"
[MySQL]
mysql.allow_local_infile = On
mysql.allow_persistent = On
mysql.cache_size = 2000
mysql.max_persistent = -1
mysql.max_links = -1
mysql.default_port =
mysql.default_socket =
mysql.default_host =
mysql.default_user =
mysql.default_password =
mysql.connect_timeout = 60
mysql.trace_mode = Off
[MySQLi]
mysqli.max_persistent = -1
mysqli.allow_persistent = On
mysqli.max_links = -1
mysqli.cache_size = 2000
mysqli.default_port = 3306
mysqli.default_socket =
mysqli.default_host =
mysqli.default_user =
mysqli.default_pw =
mysqli.reconnect = Off
[mysqlnd]
mysqlnd.collect_statistics = On
mysqlnd.collect_memory_statistics = Off
[bcmath]
bcmath.scale = 0
[Session]
session.save_handler = files
session.save_path = "C:\PHP\session"
session.use_cookies = 1
session.use_only_cookies = 1
session.name = PHPSESSID
session.auto_start = 0
session.cookie_lifetime = 0
session.cookie_path = /
session.cookie_domain =
session.cookie_httponly =
session.serialize_handler = php
session.gc_probability = 1
session.gc_divisor = 1000
session.gc_maxlifetime = 1440
session.bug_compat_42 = Off
session.bug_compat_warn = Off
session.referer_check =
session.entropy_length = 0
session.cache_limiter = nocache
session.cache_expire = 180
session.use_trans_sid = 0
session.hash_function = 0
session.hash_bits_per_character = 5
url_rewriter.tags = "a=href,area=href,frame=src,input=src,form=fakeentry"
</pre>

3.IIS6上注册fastcgi的方法：
<pre>
;注：记得使用-site:siteid ,siteid是你php站点的ID号，这样，php站点的asp.net站点可以相互不影响
cscript fcgiconfig.js -add -section:"PHP3" -extension:php -path:"C:\PHP
\php-cgi.exe" -site:3
</pre>