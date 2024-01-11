# 目的
- 在没有固定公网IP，但支持ddns的家用网络环境中，部署Moon节点服务，并使用此服务作为中继。
- 在公网IP发生变动后，无论是服务端还是客户端，都会在尽量短的时间内进行自动调整，保持Moon中继节点的正常连接。

# 说明
- 此实现方式需要ddns环境，并且已配置好ZeroTier对应的ddns域名，可以通过ping来获取域名对应的IP，此域名仅做定位使用，且不能套用CDN。当然也可以用其他方式来获取当前Moon节点的公网IP，适当调整脚本即可。
- 目前仅支持Linux与Windows系统的自动无感，对其他终端并没有进行深入研究。
- 此配置依赖于docker方式部署的ZeroTier Moon服务节点，如果是其他方式部署，可自行修改`Moon_srv-docker_zerotier_moon_renew.sh`文件中的相应命令。
- 此配置的前提是需要先部署并配置好Moon节点，并保证其他终端已经正常连接到Moon节点上。配置方式下面仅会做简要说明，具体请查阅其他资料。
- IP检测依赖`moon.json`文件，如果想在配置完Moon节点后删除此文件，则需自行按实际情况调整脚本。

# 原理与实现

## 1、服务端原理：
在部署Moon节点服务时，需要在`moon.json`文件中写入可对外提供服务的公网IP，当公网IP变动后需要重新配置并部署Moon节点的配置，然后重启ZeroTier服务。

## 2、服务端实现：
使用定时任务，对比`moon.json`文件中的IP与实时检测到的IP是否一致，当不一致时判定为公网IP已变动，并执行脚本重新对Moon节点进行配置，配置完毕后重启服务即可生效。

## 3、客户端原理：
在公网IP发生变化后，使用`zerotier-cli`命令，先删除Moon节点，再添加Moon节点，只需要两条命令即可快速刷新状态，无须重启服务。同时由于Moon节点断开后并不影响连通性，故可自行配置命令执行的间隔，无须太过频繁。
