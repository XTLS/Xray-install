# Xray-install for Alpine Linux / Gentoo

[English](README.md) | [简体中文](README_zh-Hans.md) | 繁體中文

## 安裝 Xray

#### 安裝 cURL

**Alpine Linux:**

```sh
apk add curl
```

**Gentoo:**

```sh
emerge net-misc/curl
```

#### 下載安裝腳本

```sh
curl -O -L https://github.com/XTLS/Xray-install/raw/main/alpinelinux/install-release.sh
```

#### 執行安裝腳本

```sh
sh install-release.sh
```

## 管理指令

#### 啟用 Xray 服務 (開機自啟)

```sh
rc-update add xray
```

#### 停用 Xray 服務 (取消自啟)

```sh
rc-update del xray
```

#### 啟動 Xray

```sh
rc-service xray start
```

#### 關閉 Xray

```sh
rc-service xray stop
```

#### 重啟 Xray

```sh
rc-service xray restart
```
