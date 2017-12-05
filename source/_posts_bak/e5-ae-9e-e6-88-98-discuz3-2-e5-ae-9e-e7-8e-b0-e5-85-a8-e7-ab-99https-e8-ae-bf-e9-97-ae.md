---
title: 实战--Discuz3.2实现全站https访问是碰到的问题解决
tags:
  - discuz
  - https
  - 云平台
  - 应用中心
  - 无法打开
id: 1110
categories:
  - 其它
date: 2017-04-24 22:58:37
---

> 最近帮同事迁移一个游戏汉化论坛。论坛安装的是Discuz3.2 。因为备案问题，所以把论坛直接迁移到了aliyun香港。为了防止被GWF给bolck掉，所以申请了一个aliyun https证书，把网站强制改成了https访问。在实现全站强制https访问的时候也碰到了一些问题，所以在些记录一下。

证书申请安装配置，在这里就不再复述了，可以参考我的文章 [http://www.m690.com/archives/1026](http://www.m690.com/archives/1026)

**第一步:手动更改相关文件**

查找文件：source/class/discuz/discuz_application.php 并做下面的更改。注释掉的是原文，下面的一行是更改。因为是强制全站https，所以我更改和官方的一些文章不一样，我做的更简单粗暴。因为我用官方的配置，有些js还是会访问到http。如果用官方的方式不行，可以用我这个简单粗暴的更改 ：）  ：
<pre>
//              $_G['isHTTPS'] = ($_SERVER['HTTPS'] && strtolower($_SERVER['HTTPS']) != 'off') ? true : false;
                $_G['isHTTPS'] = true;
</pre>

查找文件：uc_server/avatar.php，做下面的更改,一样的粗暴喔，因为我用官方的配置，有些js还是会访问到http：
<pre>
//define('UC_API', strtolower(($_SERVER['HTTPS'] == 'on' ? 'https' : 'http').'://'.$_SERVER['HTTP_HOST'].substr($_SERVER[
'PHP_SELF'], 0, strrpos($_SERVER['PHP_SELF'], '/'))));
define('UC_API', strtolower('https'.'://'.$_SERVER['HTTP_HOST'].substr($_SERVER['PHP_SELF'], 0, strrpos($_SERVER['PHP_SEL
F'], '/'))));
</pre>

**第二步：修改后台和uc的配置，保证通信 **
后台 > 全局 > 网站url设置成https
后台 > 站长 > UCenter设置 > UCenter 访问地址，修改为https开头的
UCenter后台 > 应用管理 > 应用的主URL，修改为https开头

**第三步：后台-应用-应用中心（云平台）无法访问到。这主要是在https的环境中，discuz太old的云平台目前不支持https，无法正常在https下正常访问**
在nginx的配置中，把访问 /admin.php的匹配，不做301 https强制重定向，其它的仍旧强制301 https重定向。这样，就可以在访问admin.php管理界面时，使用http,而不是https。这样，使用http访问应用中心是正常的。具体配置如下（如访问 http://www.mysitename.com/admin.php）：
<pre>
        location ~ /admin.php {
                proxy_pass http://127.0.0.1:88;
                include naproxy.conf;
        }
        location ~/ {
                return         301 https://www.mysitename.com$request_uri;
        }
</pre>