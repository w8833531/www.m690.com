title: 实战--迁移wordpress 到hexo
author: 吴鹰
tags:
  - 'hexo,wordpress,migration'
categories: []
date: 2017-11-27 10:13:00
---
>自已的blog以前一直是在wordpress上，已经有6、7年了。之所以想到把wordpress迁移到hexo上:是因为hexo使用[markdown](https://daringfireball.net/projects/markdown/)来写作，对于我来说，觉得更加方便;hexo是纯静态的，速度更快;也正是因为纯静态的，我可以方便的把它迁移到[coding pages](coding.net)或[github page](https://pages.github.com/)上,随时把自己网站的成本变成0。
#### 安装HEXO
##### 先安装Node.js和git，然后用npm安装 hexo
```bash
#安装node.js
curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
apt-get install nodejs
#安装git
apt-get install git-core
#npm 安装 hexo
npm install -g hexo-cli
```
#### 用hexo命令初始化站点
```bash
#生成一个hexo站点目录
mkdir -p /data/hexo/
cd /data/hexo
hexo init www.m690.com
cd www.m690.com
npm install
```
#### 配置_config.yml
```bash
#一般只要改上面的就可以了，其它的可以不动
# Hexo Configuration
# Site
title: 鹰之家
subtitle:
description: 人们一思考，上帝就微笑
author: 吴鹰
language:
- zh-Hans
- en
timezone: Asia/Shanghai
```
#### 迁移 WordPress 内容到hexo
首先，安装 hexo-migrator-wordpress 插件
```bash
$ npm install hexo-migrator-wordpress --save
```
然后，在 WordPress 仪表盘中导出数据(“Tools” → “Export” → “WordPress”)（详情参考WP支持页面）。

然后，插件安装完成后，执行下列命令来迁移所有文章。wordpress.2017-11-23.xml 是 WordPress 导出的文件名。**有一点要注意的是，如果你的文章的标题title有一些特别的符号的话，如‘&’号，下面的转换命令可能会失败。因为，在转换过程中，hexo会把wordpress的文章title名转换成一个静态的目录。我就碰到了这个问题，耽误了我1个小时**
```bash
hexo migrate wordpress wordpress wordpress.2017-11-23.xml
```
再次，用hexo generate命令在www.m690.com/public目录下生成相应的静态文件
```bash
hexo generate
```
再次，迁移wordpress的上传图片，把wordpress根目录下的wp-content/uploads目录内容同步到www.m690.com/wp-content/uploads目录
```bash
#wordpress网站根目录 /data/web/www.m690.com/
#hexo 静态网站网站根目录 /data/hexo/www.m690.com/public/
cd /data/hexo
mkidr -p wp-content/uploads
rsync -av /data/web/www.m690.com/wp-content/uploads/ /data/hexo/www.m690.com/public/wp-content/uploads/
```
最后，mv原来的wordpres根目录 ，把网站的根目录指向hexo/public目录下。打开网站，如果可以正常访问，迁移就算成功了。
```bash
cd /data/web/
mv www.m690.com www.m690.com_wordpress
ln -s /data/hexo/www.m690.com/public www.m690.com
```
#### 安装使用Next主题
##### 安装Next
```bash
#安装next主题
cd /data/hexo/www.m690.com/
git clone https://github.com/iissnan/hexo-theme-next themes/next
#配置/data/hexo/www.m690.com/_config.yml，主题改用next
theme: next
```
#### Next 主题上使用畅言评论
先注册[畅言]（http://changyan.kuaizhan.com/overview），要求网站是备案过的，不然只能用14天。
然后在[畅言]（http://changyan.kuaizhan.com/overview）控制台内，复制appid和appkey,如下图：

![](/images/image_hexo_next_changyan_key.png)

配置next主题，增加畅言评论功能
```bash
vi /data/hexo/www.m690.com/themes/next/_config.yml
#用你自己的appid和appkey更改下面的changyan选项的内容
# changyan
changyan:
  enable: true
  appid: cytlxxxxx
  appkey: 59f96341b426exxxxxxxxxxxxxxxx
#重新生成静态页面
cd /data/hexo/www.m690.com/
hexo g

```
完成后，就可以在自己网站的页面上观看效果了

![](/images/image_hexo_next_changyan.png)

#### 增加hexo-admin 博客后台管理插件
安装并启动后台管理
```bash
# 安装
npm install --save hexo-admin
# 启动hexo server ,我是线上vps，所以启动在了0.0.0.0:8000端口上，默认127.0.0.1:4000
hexo -i 0.0.0.0 -p 8000  server
#可以用下面的命令，实现后台文章的自动静态化生成，省去每次publish后，都去跑一次hexo g
hexo generate --watch
#可以在/data/hexo/www.m690.com/_config.yml中，配置hexo-admin的管理密码
# hexo-admin config
admin:
  username: username
  password_hash: your_password_hash
  secret: my secret for cookies
```
在浏览器中打开你的管理界面 xxx.xx.xx.xx:8000/admin,登录后，就可以在这个界面写你的博客了。左边是你可编辑的markdown文本，右边就是你的预览，而且是隔个几秒系统就会自动保存一下(因为是静态的文件麻，不用象wordpress,要手动去点），好方便。写好后，点publish发布你的博客。如下图：

![](/images/image_hexo_admin.png)

最后，夸一下它的贴图功能 ，QQ截图后，直接在页面中黏贴，给图片启个不重复名字，就可以完成帖图的上传功能，十分方便，如下图：

![upload successful](/images/image_hexo_admin_paste.png)

#### 


