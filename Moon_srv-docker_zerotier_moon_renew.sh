#!/bin/bash

# 指定工作路径
work_dir=/mnt/user/appdata/zerotier/zerotier-one
# 指定对外域名
check_domain=moon.example.com

# 获取新的 IP 地址
new_ip=$(ping -c 1 $check_domain | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
# 读取文件中的旧 IP 地址
old_ip=$(cat $work_dir/moon.json| grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)

# 比较新旧 IP 地址是否相同
if [ "$old_ip" != "$new_ip" ]; then
  # 执行替换操作
  sed -i "s/$old_ip/$new_ip/g" $work_dir/moon.json
  /usr/bin/docker exec -i ZeroTier /bin/sh -c 'cd /var/lib/zerotier-one && zerotier-idtool genmoon moon.json'
  mv $work_dir/*.moon $work_dir/moons.d/
  /usr/bin/docker restart ZeroTier
fi