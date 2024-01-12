# 目的
- 在没有固定公网IP，但支持ddns的家用网络环境中，部署Moon节点服务，并使用此服务作为中继。
- 在公网IP发生变动后，无论是服务端还是客户端，都会在尽量短的时间内进行自动调整，保持Moon中继节点的正常连接。

# 说明
- 此实现方式需要ddns环境，并且已配置好ZeroTier对应的ddns域名，可以通过ping来获取域名对应的IP，此域名仅做定位使用，且不能套用CDN。当然也可以用其他方式来获取当前Moon节点的公网IP，适当调整脚本即可。
- 目前仅支持Linux与Windows系统的自动无感，对其他终端并没有进行深入研究。
- 此配置依赖于docker方式部署的ZeroTier Moon服务节点，如果是其他方式部署，可自行修改`Moon_srv-docker_zerotier_moon_renew.sh`文件中的相应命令。
- 此配置的前提是需要先部署并配置好Moon节点，并保证其他终端已经正常连接到Moon节点上。
- IP检测依赖`moon.json`文件，如果想在配置完Moon节点后删除此文件，则需自行按实际情况调整脚本。

# 原理与实现

## 1、服务端原理：
在部署Moon节点服务时，需要在`moon.json`文件中写入可对外提供服务的公网IP，当公网IP变动后需要重新配置并部署Moon节点的配置，然后重启ZeroTier服务。

## 2、服务端实现：
使用定时任务，对比`moon.json`文件中的IP与实时检测到的IP是否一致，当不一致时判定为公网IP已变动，并执行脚本重新对Moon节点进行配置，配置完毕后重启服务即可生效。

## 3、客户端原理：
在公网IP发生变化后，使用`zerotier-cli`命令，先删除Moon节点，再添加Moon节点，只需要两条命令即可快速刷新状态，无须重启服务。同时由于Moon节点断开后并不影响连通性，故可自行配置命令执行的间隔，无须太过频繁。

# 使用说明

## Moon节点服务端（docker方式部署）
按照实际使用场景，调整`Moon_srv-docker_zerotier_moon_renew.sh`脚本中的变量，并添加到计划任务中，定时执行频率推荐设置为15分钟~1小时之间。

## Windows客户端（ZeroTier为默认安装，注意查看可执行文件的路径）
- 将`Win_corn-renew_zerotier.xml`文件中的`a9a8a7a6a5`更改为你当前Moon节点的ID。
- 将修改好的`Win_corn-renew_zerotier.xml`文件导入到Windows的`任务计划程序`中，并将执行的用户调整为当前的管理员用户账号（非Administrator）。
- 按照实际需要，调整触发器设置。默认在开机、解锁等状态时触发命令执行，对一般日常用电脑已经可以保障及时刷新，对24小时开机的电脑，应设置为定时执行。

## Linux客户端
可参考以下命令，对不同的Linux系统版本和安装路径，应按实际情况进行调整：

```
# 将下列命令中的`a9a8a7a6a5`更改为你当前Moon节点的ID。
zerotier-cli deorbit a9a8a7a6a5
zerotier-cli orbit a9a8a7a6a5 a9a8a7a6a5

# 理论上无需重启服务，若遇到更新异常可酌情设置
service zerotier restart
```

## 其它客户端
这里的实现原理其实很简单。
理论上，所有客户端都可以通过“退出Moon-加入Moon”的两步操作来刷新为最新的Moon节点状态，因为我暂时不需要在IOS与Android系统下接入ZeroTier网络，所以就不做测试了，有需要的可自行研究。
