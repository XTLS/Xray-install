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
