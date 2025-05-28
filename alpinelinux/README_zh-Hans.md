# Xray-install for Alpine Linux

[English](README.md) | 简体中文 | [繁體中文](README_zh-Hant.md)

## 安装 Xray

#### 安装 cURL

```sh
apk add curl
```

#### 下载安装脚本

```sh
curl -O -L https://github.com/XTLS/Xray-install/raw/main/alpinelinux/install-release.sh
```

#### 运行安装脚本

```sh
ash install-release.sh
```

## 管理命令

#### 启用 Xray 服务 (开机自启)

```sh
rc-update add xray
```

#### 禁用 Xray 服务 (取消自启)

```sh
rc-update del xray
```

#### 运行 Xray

```sh
rc-service xray start
```

#### 停止 Xray

```sh
rc-service xray stop
```

#### 重启 Xray

```sh
rc-service xray restart
```

## 重大更改 at 2025-04-09

#### 路径变更：原路径 `/usr/local/lib/xray/` 变更为 新路径 `/usr/local/share/xray/`

- 此目录存放了 `geosite.dat` 和 `geoip.dat`
- 如果你编写了一些脚本来自动更新这些文件，需要留意此项改动
- 普通用户无需关注此改动

#### 看门狗：若 Xray 进程 `panic` 将无限自动重启，间隔 5 秒，除非 10 分钟内崩溃 3 次

- 对于高级用户，你无需再手动调整 `/etc/init.d/xray` 或自己编写 daemon 脚本了
- 普通用户无需关注此改动

#### 无需 `root`：已为 Xray 授予特权，即便以 `nobody` 身份运行也支持 `tproxy` 和 `sockopt`

- 对于高级用户，你无需、也**不应该**再让 Xray 以 `root` 身份运行，现在它们已具备所有网络特权
- 如果你的 Xray 作为**节点**而不是客户端运行，或*可考虑*执行下面的命令撤销部分网络特权。理论上可以降低攻击面，实际上无关痛痒
- 普通用户无需关注此改动

```sh
sed -i 's/^capabilities="^cap_net_bind_service,^cap_net_admin,^cap_net_raw"$/capabilities="^cap_net_bind_service"/g' /etc/init.d/xray
```
