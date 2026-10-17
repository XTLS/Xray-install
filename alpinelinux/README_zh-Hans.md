# Xray-install for Alpine Linux / Gentoo

[English](README.md) | 简体中文 | [繁體中文](README_zh-Hant.md)

## 安装 Xray

#### 安装 cURL

**Alpine Linux:**

```sh
apk add curl
```

**Gentoo:**

```sh
emerge net-misc/curl
```

#### 下载安装脚本

```sh
curl -O -L https://github.com/XTLS/Xray-install/raw/main/alpinelinux/install-release.sh
```

#### 运行安装脚本

```sh
sh install-release.sh
```

## 预发布版本

安装或升级到最新版本（包含预发布版本）：

```sh
sh install-release.sh --beta
```

## 从本地压缩包安装（备选方式）

下载[安装脚本](install-release.sh)及对应系统架构的 [Xray-core 压缩包](https://github.com/XTLS/Xray-core/releases)，以 root 身份运行。以下以 x86_64 为例：

```sh
sh install-release.sh --local ./Xray-linux-64.zip
```

## 日志轮转

启用每日轮转，保留 7 份日志：

```sh
sh install-release.sh --logrotate
```

Alpine 会启用 `crond`；Gentoo 需确保 cron 服务正在运行。

## 管理命令

使用多实例时，将 `xray.a` 的配置放入 `/usr/local/etc/xray/a/`，在 `/etc/conf.d/xray.a` 中设置 `confdir="/usr/local/etc/xray/a/"`，然后执行：

```sh
ln -s xray /etc/init.d/xray.a
rc-update add xray.a
rc-service xray.a start
```

各实例可以使用不同的 `confdir`。升级仅停止并恢复原先运行的实例。

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
