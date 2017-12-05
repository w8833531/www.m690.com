---
title: 在google 被GF时，worldpress站点打开很慢问题的解决方法
tags:
  - fonts
  - fonts.googleapi.com
  - google
  - worldpress
  - 站点访问慢
id: 721
categories:
  - wordpress
  - 技术
date: 2014-06-03 05:39:33
---

> 这两天发现自己的worldpress blog 打开很慢，大于20秒。查了一下自己在香港的VPS，发现ping 时延很小，也没有丢包。用firefox 打开firebug 查看一下自己的站点，发现是卡在了访问 http://front.google.com上。 因为当前google 又被伟大的ZG firewall了。
解决方法也很简单，在worldpress中，安装Disable Google Fonts插件，问题马上解决。在哥哥被关的情况下，就临时用一下杜娘对应的服务吧。有时，我们不也是没办法嘛。但我想，总有一天，这个情况会变的，我想我们都可以亲眼看到。