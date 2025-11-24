# Xray-install

[English](README.md) | [简体中文](README_zh-Hans.md) | 繁體中文

用於在支持 systemd 的作業系統（如 CentOS / Debian / OpenSUSE）中安裝 Xray 的 Bash 腳本。

**針對 Alpine 及 Gentoo Linux 使用者**，請參閱 **[OpenRC 專用說明](alpinelinux/README_zh-Hant.md)** 以獲取適用於 Alpine/Gentoo Linux 的安裝腳本與指南。

---

#### [檔案系統層次結構標準 (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)

```
已安裝檔案：
- /etc/systemd/system/xray.service
- /etc/systemd/system/xray@.service

- /usr/local/bin/xray
- /usr/local/etc/xray/*.json

- /usr/local/share/xray/geoip.dat
- /usr/local/share/xray/geosite.dat

- /var/log/xray/access.log
- /var/log/xray/error.log
```

注意：Xray 預設不會將日誌記錄到 `/var/log/xray/*.log`。請配置 `"log"` 來指定日誌檔案。

## 基本用法

**安裝並升級 Xray-core 和地理數據，預設使用 `User=nobody`，但不會覆蓋已有服務檔案中的 `User` 設定**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
```

**僅更新 geoip.dat 和 geosite.dat**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install-geodata
```

**移除 Xray，但保留 json 設定檔案和日誌**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove
```

## 進階用法

**安裝並升級 Xray-core 到預發布版本**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta
```

**安裝並升級 Xray-core 和地理數據，並啟用 `logrotate`，`$time` 可以是 12:34:56 格式的時間**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --logrotate $time
```

```
已安裝檔案：
- /etc/systemd/system/logrotate@.service
- /etc/systemd/system/logrotate@.timer
- /etc/logrotate.d/xray
```

**安裝並升級 Xray-core 和地理數據，使用 `User=root`，會覆蓋已有服務檔案中的 `User` 設定**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root
```

**安裝並升級 Xray-core，但不包含地理數據**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --without-geodata
```

**移除 Xray，包括 json 設定檔案和日誌**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
```

## 更多用法

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ help
```

## 星標趨勢圖

[![星標趨勢圖](https://starchart.cc/XTLS/Xray-install.svg)](https://starchart.cc/XTLS/Xray-install)
