#!/bin/bash
###killall hexo first
killall hexo
sleep 1
killall hexo
sleep 1
hexo -i 0.0.0.0 -p 8000  server >> /tmp/hexo_start.log 2>&1 &
#hexo generate --watch >> /tmp/hexo_deploy.log 2>&1 &
