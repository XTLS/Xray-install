# Xray-install for Alpine Linux / Gentoo

[English](README.md) | [简体中文](README_zh-Hans.md) | 繁體中文

> [!WARNING]
>
> **自 2026-10-18 起的不相容變更**
>
> **全新安裝可忽略此內容，從舊版升級必須遵循，否則可能無法啟動 Xray 或降低安全性**
>
> 1. **Geodata**：為了解決一些已知問題，資料來源已從 Loyalsoldier/v2ray-rules-dat 切換至 [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat)，不保證與舊資料完全相容。若您需要 GeoIP `cn`、`ru`、`ir` 以外的國家分類，請執行 `update-geodata`（由 `install-geodata` 更名而來）。若您需要 Loyalsoldier 的一些特殊 GeoSite 分類（如 `gfw`、`win-spy`），請手動下載 [Loyalsoldier 版 geosite.dat](https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat)，在資源目錄中另存為 `geosite-loyalsoldier.dat`，並在 Xray 設定中透過 `ext:geosite-loyalsoldier.dat:分類名稱` 使用。
> 2. **日誌輪替**：請使用本安裝腳本提供的 `--logrotate`，不要再額外設定其他輪替工作，以免發生權限或日誌寫入問題。
> 3. **檔案權限**：鑑於近期其他軟體及系統元件的 0day 頻發，為降低其對 Xray 服務的潛在影響，現加強服務隔離與檔案權限控管：由共用的 `nobody` 帳號改為專用的 `xray` 使用者，不再支援自訂執行使用者，並收緊設定和日誌目錄權限。您的自訂設定檔、憑證及舊安裝需要檢查存取權限。
>
>    <details>
>    <summary>展開查看預設權限及自訂設定、憑證的設定要求</summary>
>
>    下表是目前安裝腳本自動設定的安全預設權限：程式和設定由 root 管理，`xray` 帳號只能讀取設定；geodata 和日誌允許服務寫入。主旨是保護日誌和設定檔，這符合最佳安全實務。
>
>    | 用途         | 路徑                                | 擁有者:群組 | 權限   |
>    | ------------ | ----------------------------------- | ----------- | ------ |
>    | Xray 執行檔  | `/usr/local/bin/xray`               | `root:root` | `0755` |
>    | 設定目錄     | `/usr/local/etc/xray/`              | `root:xray` | `0750` |
>    | 設定檔       | `/usr/local/etc/xray/*.json`        | `root:xray` | `0640` |
>    | Geodata 目錄 | `/usr/local/share/xray/`            | `xray:xray` | `0755` |
>    | GeoIP 資料   | `/usr/local/share/xray/geoip.dat`   | `xray:xray` | `0644` |
>    | GeoSite 資料 | `/usr/local/share/xray/geosite.dat` | `xray:xray` | `0644` |
>    | 日誌目錄     | `/var/log/xray/`                    | `xray:xray` | `0700` |
>
>    **舊安裝的目錄和檔案權限無法自動遷移，您應按上表手動調整。也可先備份設定與資料，完全解除安裝舊版並刪除所有相關目錄和檔案後，重新安裝。**
>
>    **自訂設定與憑證（如有）**：您的自訂設定目錄、新增設定檔，以及憑證目錄、憑證和私密金鑰，也應採用上表中「設定目錄」和「設定檔」的權限規則。
>
>    </details>

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

**如果目前的 SSH 連線透過 Xray 建立，更新 Xray 時務必使用 `--manually-restart-later`，避免服務重啟導致 SSH 連線中斷。**

```sh
sh install-release.sh --manually-restart-later
```

此選項保留目前實例執行，更新後需手動重啟以套用變更。

## 代理

```sh
sh install-release.sh --proxy http://127.0.0.1:8118
```

`--proxy` 也適用於 `update-geodata`。

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

可用 `--geoip` 和 `--geosite` 指定本機資料；兩個參數可單獨使用，未指定時使用套件內附資料。

## 日誌輪替

啟用每日輪替，保留 7 份日誌：

```sh
sh install-release.sh --logrotate
```

Alpine 會啟用 `crond`；Gentoo 需確保 cron 服務正在執行。

## 下載／更新 geodata

以 root 身分執行，僅下載／更新 geodata：

```sh
sh install-release.sh update-geodata
```

**Xray 內附的是 GeoIP lite 和 GeoSite standard，此指令下載 GeoIP full 和 GeoSite expanded。** 資料來自 [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat)。

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
