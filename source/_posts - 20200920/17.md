---
title: 谈谈如何用脚本自动备份wordpress
tags:
  - wordpress
  - 脚本
  - 自动备份
id: 17
categories:
  - wordpress
date: 2011-07-21 11:00:00
---

> 我想当我们在VPS上安装完自己的wordpress，放上第一篇文章后，最先想到的可能是“万一我的VPS上的数据丢了怎么办？”，我要如何来备份我的wordpress数据呢？当然我们可以用现成的工具来完成备份，但对于我来说，还是喜欢自己写个脚本来搞定。写个脚本放到crontab中每周自动做备份，并通过邮件把备份数据发到我的hotmail邮箱里。

下面我们就来谈谈如何来用脚本自动备份我们的wordpress.

1、首先就是要备份wordpress里的Plugin及上传的图片等内容。这些内容都放在了wordpreess目录的wp-content目录下面，如我的wordpress 放在/home/wwwroot/wordpress目录下面，那么/home/wwwroot/wordpress/wp-content目录就是我们要备份的内容。可以用下面的命令来完成备份：

<pre class="brush: php">
wordpress_dir=/home/wwwroot/wordpress/
backup_dir=/home/wordpress_backup/
mkdir -p ${backup_dir}`date +%Y%m%d`/
cd $wordpress_dir
cp wp-config.php ${backup_dir}`date +%Y%m%d`/
tar -zcvf wp-content.`date +%Y%m%d`.tgz wp-content/
mv wp-content.`date +%Y%m%d`.tgz ${backup_dir}`date +%Y%m%d`/
</pre>

2、就是备份wordpress数据库了，直接用mysqldump 命令dump出wordpress DB的 sql语句就可以了。可以用下面的命令完成备份（我们DB NAME是wuying)：
<pre class="brush: php">
/usr/bin/mysqldump -uroot -pmysqlpassword wuying &gt; ${backup_dir}`date +%Y%m%d`/wuying.`date +%Y%m%d`.txt
cd ${backup_dir}
tar -zcvf wordpress_`date +%Y%m%d`.tgz `date +%Y%m%d`/
</pre>

3、接着就是如何来发送上面的备份了，我的想法是用邮件直接把上面的打包文件发送到我的邮箱里。下面给一个perl的发送邮件的脚本，需要安装perl 的mail::sender模块,前面的变量定义（如：收信人、发信人、邮件服务器地址、邮件服务器登录用户名、密码）需求你自己来修改。
<pre class="brush: php">
#!/usr/bin/perl
use strict;
use Mail::Sender;
my $user_send='wuying@hotmail.com';
my $user_from='wuying@m690.com';
my $user_id='wuying@wuying.xxx.com';
my $user_pwd="wuyingpassword";
my $user_cc="";
my $mail_host="service.xxx.com";
my $mail_subject="wordpress";
my $mail_content="wordpress backup mail";
my $send_file=$ARGV[0];
printf "$user_send $send_file $mail_host \n";
open my $DEBUG, "&gt;pmail.txt" or die "Can't open the debug file: $!\n";
my $sender = new Mail::Sender{smtp =&gt; $mail_host,
from =&gt; $user_from,
auth =&gt; 'LOGIN',
authid =&gt; $user_id,
authpwd =&gt; $user_pwd,
debug =&gt; $DEBUG};
$sender-&gt;Body({
encoding =&gt; 'gbk',
charset =&gt; 'gbk',
});
$sender-&gt;MailFile({
to =&gt; $user_send,
# Cc =&gt; '***@126.com',
subject =&gt; $mail_subject,
msg =&gt; $mail_content,
file =&gt; $send_file}) or print $Mail::Sender::Error;
$sender-&gt;Close();
</pre>
可以在shell脚本中，用下面的命令来调用这个perl脚本：
<pre class="brush: php">
attachment=wordpress_`date +%Y%m%d`.tgz
./pmail.pl $attachment
</pre>

4、最后，给一个完整的shell脚本，并把这个脚本加到crontab中运行：
<pre class="brush: php">
[root@eagle wordpress_backup]# cat wordpress_backup.sh
#!/bin/bash
#This script use to backup wordpress on my vps
backup_dir=/home/wordpress_backup/
wordpress_dir=/home/wwwroot/wordpress/
subject="wuying wordpress backup at `date`"
mailowner=w883@hotmail.com
attachment=wordpress_`date +%Y%m%d`.tgz

###start backup
mkdir -p ${backup_dir}`date +%Y%m%d`/
cd $wordpress_dir

### wordpress config &amp; content backup
cp wp-config.php ${backup_dir}`date +%Y%m%d`/
tar -zcvf wp-content.`date +%Y%m%d`.tgz wp-content/
mv wp-content.`date +%Y%m%d`.tgz ${backup_dir}`date +%Y%m%d`/

### wordpress db backup
/usr/bin/mysqldump -uroot -pmysqlpasswd wuying &gt; ${backup_dir}`date +%Y%m%d`/wuying.`date +%Y%m%d`.txt
cp ${backup_dir}$0 ${backup_dir}`date +%Y%m%d`/
cp ${backup_dir}pmail.pl ${backup_dir}`date +%Y%m%d`/
cd ${backup_dir}
tar -zcvf wordpress_`date +%Y%m%d`.tgz `date +%Y%m%d`/
find ./ -name "wordpress*.tgz " -mtime 7 | xargs rm -f
rm -rf `date +%Y%m%d`/

### send mail
cd ${backup_dir}
#### use shell script to send mail ，need to start up sendmail service on you vps
#mail -s "$subject" $mailowner &lt;&lt; END
#This mail is wuying wordpress backup

#`uuencode $attachment wuying_$attachment`

#END
#### use perl script to send mail
./pmail.pl $attachment

 </pre>

加个计划任务，每天自动备份并发邮件到我的邮箱：
<pre class="brush: php">
[root@eagle wordpress_backup]# crontab -l
1 0 * * * bash /home/wordpress_backup/wordpress_backup.sh
</pre>