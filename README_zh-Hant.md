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

- /var/log/xray/
```

注意：Xray 預設不會將日誌記錄到 `/var/log/xray/*.log`。請配置 `"log"` 來指定日誌檔案。

## 基本用法

**安裝並升級 Xray-core**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
```

**僅更新 geoip.dat 和 geosite.dat**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ update-geodata
```

**移除 Xray，但保留 json 設定檔案和日誌**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove
```

**檢查更新**

```sh
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ check
```

## 從本機壓縮檔安裝（備選方式）

下載[安裝腳本](install-release.sh)及對應系統架構的 [Xray-core 壓縮檔](https://github.com/XTLS/Xray-core/releases)，以 root 身分執行。以下以 x86_64 為例：

```sh
bash install-release.sh install --local ./Xray-linux-64.zip
```

可用 `--geoip` 和 `--geosite` 指定本機資料；兩個參數可單獨使用，未指定時使用套件內附資料。

## 進階用法

**透過代理安裝或升級**

```sh
bash -c "$(curl -x http://127.0.0.1:8118 -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --proxy http://127.0.0.1:8118
```

`--proxy` 支援 HTTP 和 SOCKS 代理，也適用於 `update-geodata` 和 `check`。

**安裝並升級 Xray-core 到預發布版本**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta
```

**安裝並升級 Xray-core，並啟用 `logrotate`，`$time` 可以是 12:34:56 格式的時間**

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

## 其他參數

`install` 還支援以下參數：

| 參數                  | 說明               |
| --------------------- | ------------------ |
| `--version <version>` | 安裝指定版本。     |
| `--force`             | 強制安裝。         |
| `--reinstall`         | 重新安裝目前版本。 |
| `--no-update-service` | 保留既有服務檔案。 |
| `--without-logfiles`  | 不建立日誌目錄。   |

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
