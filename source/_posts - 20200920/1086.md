---
title: 实战：把公司的SVN迁移到GitLab CE
tags:
  - git
  - git-svn
  - GitLab
  - GitLabCE
  - svn
  - 转换
  - 迁移
id: 1086
categories:
  - svn
date: 2017-03-24 17:47:58
---

> 把公司的SVN迁移到GitLab CE(GitLab社区版）原因主要有下面几个：> 
> 
> *   年青的新人进来，喜欢用git的越来越多
> *   GitLab CE提供了优美的 web 界面，图形化分支结构，更直观的代码审查，统计、issue 系统、wiki 等功能全面集成
> *   Git 比SVN commit和push更快，Git库就在本地，commit是本地提交，回家照样干活。push的时候是push一个压缩的文件，而不是一个个文件的push.
> *   Git数据库是分布式的，每个用户都有一个本地库，数据更安全。
> *   因为是本地commit,Git即使在公网环境下，也可以顺畅使用，如果要跨地域跨国（分公司在美国）做开发，可以方便国外公司人员快速访问，共用同一个版本管理软件。> 
> 基于以上几点，我们决定把当前正在使用的SVN库迁移到GitLab CE上。
一、服务器系统配置如下：
DELL PowerEdge R630 CPU 20core MEM 400G Disk 300G *8 RAID 10
系统 ：Ubuntu 16.04.1 LTS

二、GitLab CE 的安装方法如下：
安装非常简单，可以直接用官方文档安装并启动。建议把/opt/gitlab（程序配置） /var/log/gitlab（日志） /var/opt（数据） 目录放到独立的大的分区上去，并定时备份。
[GitLab CE 在ubuntu16.04上安装官方文档](https://about.gitlab.com/downloads/#ubuntu1604)
<pre>apt-get update
apt-get install curl openssh-server ca-certificates postfix
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
apt-get install gitlab-ce
gitlab-ctl reconfigure
</pre>
三、迁移SVN库到GitLab CE
1、安装迁移工具git-svn
<pre>apt-get install git-svn
</pre>
2、生成SVN用户文件，格式如下：
可以把SVN库中的用户cp出来，在最后加一列邮件地址
<pre>
root@DEV70:/data/git# cat auth.txt
vr = xxxxx  《guanjianming@xxx.com.cn》 #请自己把《》换成半角 ：）
vr_view = xxxx  《liuchenxin@xxx.com.cn》
vr_01 = xxxxx  《zhangrongwang@xxx.com.cn》
vr_02 = xxxxx  《getaiming@xxx.com.cn》
vr_red = xxxx   《alex@xxx.com&gt》
</pre>
3、使用git svn clone命令把SVN库转换为本地git库
<pre>###在服务器上，把一个远程SVN库转为一个git本地库
git svn clone --username vr -s -A auth.txt  svn://172.18.194.181:9999/vr_new/ vr/
#-s 同 --stdlayout 参数表示你的项目在 SVN 中是常见的 “trunk/branches/tags” 目录结构，如果不是，那你需要使用 --tags, --branches, --trunk 参数
#-A --authors-file auth.txt 上面的SVN用户认证文件
#--username 访问SVN 库的用户名

###查看git 本地库的情况
git branch -a  #下面为命令显示，一个master库，和多个包括branch及tag的分支
* master
  remotes/origin/tags/t1.01
  remotes/origin/tags/v1.0
  remotes/origin/tags/v1.01
  remotes/origin/tags/v1.02
  remotes/origin/tags/v1.03
  remotes/origin/tags/v1.04
  remotes/origin/tags/v2.0
  remotes/origin/tags/v2.01
  remotes/origin/tags/v2.02
  remotes/origin/tags/v2.03
  remotes/origin/tags/v2.04
  remotes/origin/tags/v2.05
  remotes/origin/tags/v2.06
  remotes/origin/tags/v2.07
  remotes/origin/tags/v2.07@459
  remotes/origin/tags/v2.08
  remotes/origin/tags/v2.09
  remotes/origin/tags/v2.10
  remotes/origin/tags/v2.11
  remotes/origin/tags/v2.12
  remotes/origin/trunk
  remotes/origin/v1.0_fix 
</pre>
4、在本地的git库上处理branch和tags
<pre>#先同步数据有条件把SVN的关掉，不要让用户再向SVN做递交
cd /data/git/vr
git svn fetch
#转换所有branchs
for i in `git branch -r | grep -v trunk | grep -v tags | awk -F/ '{print $2}'`; do git checkout -b $i origin/$i; done
#转换所有tags
for i in `git branch -r | grep tags | awk -F/ '{print $3}'`; do git checkout -b $i origin/tags/$i; git checkout master; git tag $i $i; git branch -D $i; done
#再次同步，并把master与remotes/origin/trunk 合并,保证master上是最新的commit
git svn fetch
git checkout master
git svn rebase  #或是git merge remotes/origin/trunk ，其实就是把remotes/origin/trunk分支的SVN最新的commit应用到git 的 master分支上
git log  #查看是否是最新的commit
#clone 一个新的本地库
cd ..
git clone vr vr_new
#再做一次branch的转换
cd vr_new
for i in `git branch -r | grep -v trunk | grep -v tags | awk -F/ '{print $2}'`; do git checkout -b $i origin/$i; done
</pre>
5、在GitLab上新建一个vr_new库（具体操作就不描述了）
6、把刚才转换好的git本地库push到GitLab的vr_new库上
<pre>git remote rm origin
git remote add origin git@gitlab:vr/vr_new.git
git push -u origin --all
git push origin --tags
</pre>
7、来GitLab上查看push上来的库

![](http://www.m690.com/wp-content/uploads/2017/03/img_58d4ea3885b1a.png)

![](http://www.m690.com/wp-content/uploads/2017/03/img_58d4ed87b4133.png)

8、最后给一个找到的非常好的git 中文文档链接：
[https://github.com/geeeeeeeeek/git-recipes/wiki](https://github.com/geeeeeeeeek/git-recipes/wiki)