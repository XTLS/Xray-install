# Xray-install for Alpine Linux / Gentoo

[English](README.md) | [简体中文](README_zh-Hans.md) | 繁體中文

> [!WARNING]
>
> **自 2026-10-18 起的不相容變更**
>
> **全新安裝可忽略此內容，從舊版升級必須遵循，否則可能無法啟動 Xray 或降低安全性**
>
> 1. **Geodata**：為了解決一些已知問題，資料來源已從 Loyalsoldier/v2ray-rules-dat 切換至 [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat)，不保證與舊資料完全相容。若您需要 GeoIP `cn`、`ru`、`ir` 以外的國家分類，請執行 `update-geodata`（由 `install-geodata` 更名而來）。若您需要 Loyalsoldier 的一些特殊 GeoSite 分類（如 `gfw`、`win-spy`），請手動下載 [Loyalsoldier 版 geosite.dat](https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat)，在資產目錄中另存為 `geosite-loyalsoldier.dat`，並在 Xray 設定中透過 `ext:geosite-loyalsoldier.dat:分類名稱` 使用。
> 2. **日誌輪替**：請使用本安裝腳本提供的 `--logrotate`，不要再額外設定其他輪替工作，以免發生權限或日誌寫入問題。
> 3. **檔案權限**：鑑於近期其他軟體及系統元件的 0day 頻發，為降低其對 Xray 服務的潛在影響，現加強服務隔離與檔案權限控管：由共用的 `nobody` 使用者改為專用的 `xray` 使用者，不再支援自訂執行使用者，並收緊設定和日誌目錄權限。您的自訂設定檔、憑證及舊安裝需要檢查存取權限。
>
>    <details>
>    <summary>展開查看檔案權限設定要求</summary>
>
>    下表是目前安裝腳本自動設定的安全預設權限：程式和設定由 `root` 管理，`xray` 使用者只能讀取設定；資產和日誌允許服務寫入。主旨是保護日誌和設定檔，這符合最佳安全實務。
>
>    | 用途         | 路徑                                | 擁有者:群組 | 權限   |
>    | ------------ | ----------------------------------- | ----------- | ------ |
>    | Xray 執行檔  | `/usr/local/bin/xray`               | `root:root` | `0755` |
>    | 設定目錄     | `/usr/local/etc/xray/`              | `root:xray` | `0750` |
>    | 設定檔       | `/usr/local/etc/xray/*.json`        | `root:xray` | `0640` |
>    | 資產目錄     | `/usr/local/share/xray/`            | `xray:xray` | `0755` |
>    | GeoIP 資料   | `/usr/local/share/xray/geoip.dat`   | `xray:xray` | `0644` |
>    | GeoSite 資料 | `/usr/local/share/xray/geosite.dat` | `xray:xray` | `0644` |
>    | 日誌目錄     | `/var/log/xray/`                    | `xray:xray` | `0700` |
>
>    **舊安裝的目錄和檔案權限無法自動遷移，您應按上表手動調整。也可先備份設定與資料，完全解除安裝舊版並刪除所有相關目錄和檔案後，重新安裝。**
>
>    **自訂設定（如有）**：您的自訂設定目錄和新增設定檔，也應採用上表中「設定目錄」和「設定檔」的權限規則。
>
>    **憑證（如有）**：憑證和私鑰的權限請參閱下文[憑證檔案權限](#憑證檔案權限)。
>
>    </details>

## 安裝或升級 Xray-core

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

#### 執行腳本以安裝或升級 Xray

\* 若 SSH 透過 Xray 連線，升級時務必使用 `--manually-restart-later`，避免斷線導致腳本出錯。

```sh
sh install-release.sh
```

#### 透過代理安裝或升級 Xray

```sh
sh install-release.sh --proxy http://127.0.0.1:8118
```

`--proxy` 支援 HTTP 和 SOCKS 代理，也適用於 `update-geodata`。

#### 安裝或升級 Xray 到預發布版本

```sh
sh install-release.sh --beta
```

## 從本機壓縮檔安裝（備選方式）

下載[安裝腳本](install-release.sh)及對應系統架構的 [Xray-core 壓縮檔](https://github.com/XTLS/Xray-core/releases)。以下以 x86_64 為例：

```sh
sh install-release.sh --local ./Xray-linux-64.zip
```

還可用 `--geoip` 和 `--geosite` 指定本機 Geodata；兩個參數可單獨使用，未指定時使用套件內附資料。

## 日誌輪替

安裝或升級 Xray，並啟用每日輪替，保留 7 份日誌

注意：Xray 預設不會將日誌記錄到 `/var/log/xray/*.log`。請在<a href="https://xtls.github.io/en/config/log.html" target="_blank">日誌設定</a>中指定日誌檔案路徑。

```sh
sh install-release.sh --logrotate
```

Alpine 會啟用 crond；Gentoo 需確保 cron 服務正在執行。

## 更新 geoip.dat 和 geosite.dat

\* Xray 內附的是 GeoIP lite 和 GeoSite standard，此指令下載 GeoIP full 和 GeoSite expanded。資料來自 [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat)。

```sh
sh install-release.sh update-geodata
```

## 更多幫助

```sh
sh install-release.sh help
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

## 多實例

如需同時執行多個 Xray 實例，可為每個實例使用獨立的設定目錄。以 `xray.a` 為例，將設定檔放入 `/usr/local/etc/xray/a/`，然後執行：

```sh
ln -s xray /etc/init.d/xray.a
rc-update add xray.a
rc-service xray.a start
```

各實例設定目錄及其中設定檔的擁有者、群組和權限，應分別與 `/usr/local/etc/xray/` 目錄及其設定檔一致。

## 憑證檔案權限

在 Xray 設定中透過檔案路徑引用憑證和私鑰時，`xray` 使用者或 `xray` 群組需要對這些檔案有讀取權限（`r`），對所在目錄及各級父目錄（符號連結目標同理）有存取權限（`x`），不應有寫入權限。私鑰不應向無關使用者及群組開放讀取，自動續期後也應保持上述權限。

以 [acme.sh](https://github.com/acmesh-official/acme.sh) 為例，優先使用獨立使用者如 `acme` 執行腳本，先 `touch` 建立憑證和私鑰檔案並設定權限，允許 `acme` 寫入、`xray` 唯讀，再用 `--install-cert` 更新，屆時權限會自動保留。次選透過 `--reloadcmd` 呼叫自訂腳本調整權限，腳本及父目錄須禁止無關使用者寫入，避免遭到竄改。
