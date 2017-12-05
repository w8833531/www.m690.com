---
title: Wordpress全站HTTPS之--安装阿里云提供免费1年的HTTPS CA证书
tags:
  - CA
  - https
  - wordpress
  - 免费HTTPS证书
  - 免费证书
  - 证书
  - 阿里云
id: 1026
categories:
  - wordpress
date: 2016-12-14 12:14:56
---

> 号外，现在阿里云提供免费1年的HTTPS CA 证书，终于可以不花钱把自己的blog变成全站HTTPS的了
一、先来两张图吧：
1、显示在chrome中的绿色https标志：

![](http://www.m690.com/wp-content/uploads/2016/12/img_5850c2ba8d580.png)

2、证书信息：

![](http://www.m690.com/wp-content/uploads/2016/12/img_5850c32c1c5c7.png)

二、证书申请：
1、阿里云免费证书申请地址：
[https://www.aliyun.com/product/cas](https://www.aliyun.com/product/cas)
2、证书最多只能绑定一个域名：

![](http://www.m690.com/wp-content/uploads/2016/12/img_5850c41894e69.png)

3、具体证书申请操作，请按照阿里云的提示进行。
4、在申请证书之前，我已经有了如下阿里云相关条件：

三、服务器上的nginx配置
wordpress上，把整个站点设置成只要访问http就自动转成https的nginx设置如下：
<pre>
#root@dm690:/etc/nginx/sites-enable# cat 139.224.113.226.conf  | grep -v '^#' | grep -v "^$"
server {
        listen   80; ## listen for ipv4; this line is default and implied
        listen   [::]:80 default ipv6only=on; ## listen for ipv6
        server_name m690.com 139.224.113.226;
        return         301 https://$server_name$request_uri;
}
server {
        listen 443;
        ssl on;
        ssl_certificate /etc/nginx/conf.d/ssl/139.224.113.226.pem;
        ssl_certificate_key /etc/nginx/conf.d/ssl/139.224.113.226.key;
        ssl_session_timeout 5m;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers AESGCM:ALL:!DH:!EXPORT:!RC4:+HIGH:!MEDIUM:!LOW:!aNULL:!eNULL;
        ssl_prefer_server_ciphers on;
        add_header Strict-Transport-Security "max-age=31536000"; 
        access_log  /data/log/nginx/139.224.113.226.log  main;
        error_log  /data/log/nginx/139.224.113.226.error.log;
        root /data/web/139.224.113.226; 
        index index.php index.html index.htm;
        # Make site accessible from http://localhost/
        server_name 139.224.113.226 m690.com;
        # Disable sendfile as per https://docs.vagrantup.com/v2/synced-folders/virtualbox.html
        sendfile off;
        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to index.html
                try_files $uri $uri/ /index.php?q=$uri&$args;
                # Uncomment to enable naxsi on this location
                # include /etc/nginx/naxsi.rules
        }
        location /doc/ {
                alias /usr/share/doc/;
                autoindex on;
                allow 127.0.0.1;
                allow ::1;
                deny all;
        }
        # Only for nginx-naxsi : process denied requests
        #location /RequestDenied {
                # For example, return an error code
                #return 418;
        #}
        #error_page 404 /404.html;
        # redirect server error pages to the static page /50x.html
        #
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
                root /usr/share/nginx/www;
        }
        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ \.php$ {
                try_files $uri =404;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                # NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
                # With php5-cgi alone:
                fastcgi_pass 127.0.0.1:9000;
                # With php5-fpm:
                #fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                include fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
        }
}
</pre>
最后，记得在wordpress中设置URL为https:

![](http://www.m690.com/wp-content/uploads/2016/12/img_5850c6b373ce5.png)