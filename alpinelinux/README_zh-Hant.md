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

## 代理

```sh
sh install-release.sh --proxy http://127.0.0.1:8118
```

## 預發佈版本

安裝或升級至最新版本（包含預發佈版本）：

```sh
sh install-release.sh --beta
```

## 從本機壓縮檔安裝（備選方式）

下載[安裝腳本](install-release.sh)及對應系統架構的 [Xray-core 壓縮檔](https://github.com/XTLS/Xray-core/releases)，以 root 身分執行。以下以 x86_64 為例：

```sh
sh install-release.sh --local ./Xray-linux-64.zip
```

## 日誌輪替

啟用每日輪替，保留 7 份日誌：

```sh
sh install-release.sh --logrotate
```

Alpine 會啟用 `crond`；Gentoo 需確保 cron 服務正在執行。

## 更多幫助

```sh
sh install-release.sh help
```

## 管理指令

使用多實例時，將 `xray.a` 的設定檔放入 `/usr/local/etc/xray/a/`，然後執行：

```sh
ln -s xray /etc/init.d/xray.a
rc-update add xray.a
rc-service xray.a start
```

升級僅停止並恢復原先執行中的實例。

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
