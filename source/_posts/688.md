---
title: 通过rsyslog进行nginx的日志集中管理使用第三方git syslog模块时的问题解决
tags:
  - git
  - nginx
  - nginx_syslog_patch
  - syslog
  - yaoweibin
id: 688
categories:
  - nginx
  - 技术
date: 2014-01-21 17:31:17
---

> 我的想法是把所有nginx服务器上的日志通过rsyslog抛到远程的一台rsyslog服务器集中管理。在apache中，可以使用| pipe来把日志通过logger抛rsyslog服务器，但新的nginx出了一个plus版本，很悲催，居然是收费的。当然，有免费的版本，但是日志不支持syslog功能。怎么把nginx 的日志抛给rsyslog呢，这是这篇文章要解决的问题。
幸运的是，我在git上找到了支持syslog的nginx第三方模块。
下载地址是： https://github.com/yaoweibin/nginx_syslog_patch
下载方法是： git clone https://github.com/yaoweibin/nginx_syslog_patch
**具体安装/配置方法可以直接看下载地址中的README，写得很详细，我就不再重复了。如果发现configure nginx_syslog_patch时报错，可以使用如下的方法尝试一下：**
<pre class="blush: php">[root@web03 20140121]# sed -n '1,$l' nginx_syslog_patch/config 
\r$
ngx_feature="nginx_syslog_patch"\r$
ngx_feature_name="nginx_syslog_patch"\r$
ngx_feature_run=no\r$
have=NGX_ENABLE_SYSLOG . auto/have\r$
###看到\r$了吗？把换行回车改成换行$就可以编译通过了。
[root@web03 20140121]# perl -pi.bak -e 's/\r//gi' nginx_syslog_patch/config    
[root@web03 20140121]# sed -n '1,$l' nginx_syslog_patch/config 
$
ngx_feature="nginx_syslog_patch"$
ngx_feature_name="nginx_syslog_patch"$
ngx_feature_run=no$
have=NGX_ENABLE_SYSLOG . auto/have$
###然后重新configure ,搞定收功。</pre>