---
title: FFMPEG-3 -- 在ubuntu16.04 LTS 上用apt-get 快速安装及实现多码流hls转换
tags:
  - ffmepg
  - hls
  - ubuntu16.04
  - 多码流
  - 多码流自适应
id: 1083
categories:
  - 小技巧
date: 2017-03-20 20:34:53
---

> 网站上经常要放视频，直接放mp4太大，用flv手机又不全支持。而hls方式还是不错的，因为IOS手机支持，安卓和网页上也可以通过JS插件来实现顺畅播放。使用HLS还可以很方便的切成多个小文件缓存到CDN上，而且HLS可以支持多码流自适应播放。可以在服务器上安装 ffmpeg3这个转码软件，用它实现把用户上传的mp4格式的文件自动转换成多码流自适应的HLS格式。
1、先看一下ffmpe-3在ubuntu16.04上的apt-get安装：
<pre>apt-get install software-properties-common
add-apt-repository ppa:jonathonf/ffmpeg-3
apt-get update
apt install ffmpeg libav-tools x264 x265
#查看一下，安装是否完成：
root@node15:/data/web/www# ffmpeg -version                
ffmpeg version 3.2.4-1~16.04.york1 Copyright (c) 2000-2017 the FFmpeg developers
built with gcc 5.4.1 (Ubuntu 5.4.1-5ubuntu2~16.04.york1) 20170210
</pre>
2、使用ffmpeg3来把一个audition.mp4文件转换成多码流自适应的hls格式：
<pre>
###使用ffmpeg3生成三个码流（5000kbps 2500kbps 1000kbps)的stream_hi.m3u8 stream_med.m3u8 stream_low.m3u8 三个文件
ffmpeg -i "audition.mp4" -y -threads 10  \
-codec:a aac -b:a 160k -ac 2 -c:v libx264 -b:v 5000k  -vprofile baseline -preset medium -x264opts level=41  -hls_list_size 0 -hls_allow_cache 1  stream_hi.m3u8 \
-codec:a aac -b:a 160k -ac 2 -c:v libx264 -b:v 2500k -vprofile baseline -preset medium -x264opts level=41 -hls_list_size 0 -hls_allow_cache 1 stream_med.m3u8 \
-codec:a aac -b:a 80k -ac 2 -c:v libx264 -b:v 1000k -vprofile baseline -preset medium -x264opts level=41 -hls_list_size 0 -hls_allow_cache 1 stream_low.m3u8
###把上面的三个stream_(hi,med,low).m3u8拼成一个自适应码流的audition.m3u8文件
root@node15:/data/web/www/media/audition_multi# cat audition.m3u8 
#EXTM3U
#EXT-X-VERSION:6
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=5000000
stream_hi.m3u8
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2500000
stream_med.m3u8
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=1000000
stream_low.m3u8
###最后在浏览器中访问这个合并生成的audition.m3u8，在chrome中按F12查看是否会在stream_(hi,med,low).m3u8文件中转换
###附加给一个查看文件视频码流的命令，这样就可能通过最高码流、最低码流、切分码流数、再结合文件本身的码流，用后台crontab来实现自动转码（结果是bps)：
root@node15:/data/web/www/media/audition_multi# ffprobe -v quiet -print_format json -show_format   audition.mp4  | grep bit_rate | awk -F'"' '{print $4}'
19078364
root@node15:/data/web/www/media/audition_multi# 
###有时间，再给一个脚本，可以通过设置最高码流、最低码流、切分码流数、再结合文件本身的码流，自动生成多个自适应码流的m3u8文件。
</pre>