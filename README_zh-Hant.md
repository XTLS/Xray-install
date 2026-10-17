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

**安裝並升級 Xray-core 和地理數據**

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

## 從本機壓縮檔安裝（備選方式）

下載[安裝腳本](install-release.sh)及對應系統架構的 [Xray-core 壓縮檔](https://github.com/XTLS/Xray-core/releases)，以 root 身分執行。以下以 x86_64 為例：

```sh
bash install-release.sh install --local ./Xray-linux-64.zip
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

**安裝並升級 Xray-core，但不包含地理數據**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --without-geodata
```

**移除 Xray，包括 json 設定檔案和日誌**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
```

## 多實例

安裝時設定 `JSONS_PATH` 以使用設定目錄：

```sh
JSONS_PATH=/usr/local/etc/xray bash install-release.sh install
```

`xray.service` 讀取 `JSONS_PATH`，`xray@a.service` 讀取 `JSONS_PATH/a/`。將各實例的設定放入對應目錄後，使用 `systemctl enable --now xray@a` 啟動。

## 更多用法

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ help
```

## 星標趨勢圖

[![星標趨勢圖](https://starchart.cc/XTLS/Xray-install.svg)](https://starchart.cc/XTLS/Xray-install)
