# Xray-install for Alpine Linux

[English](README.md) | [简体中文](README_zh-Hans.md) | 繁體中文

## 安裝 Xray

#### 安裝 cURL

```sh
apk add curl
```

#### 下載安裝腳本

```sh
curl -O -L https://github.com/XTLS/Xray-install/raw/main/alpinelinux/install-release.sh
```

#### 執行安裝腳本

```sh
ash install-release.sh
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

## 重大變更 at 2025-04-09

#### 路徑變更：原始路徑 `/usr/local/lib/xray/` 變更為 新路徑 `/usr/local/share/xray/`

- 此目錄存放了 `geosite.dat` 和 `geoip.dat`
- 如果你編寫了一些腳本來自動更新這些文件，需要留意此項改動
- 普通用戶無需關注此改動

#### 看門狗：若 Xray 進程 `panic` 將無限自動重啟，間隔 5 秒，除非 10 分鐘內崩潰 3 次

- 對於高級用戶，你無需再手動調整 `/etc/init.d/xray` 或自己編寫 daemon 腳本了
- 普通用戶無需關注此改動

#### 無需 `root`：已為 Xray 授予特權，即便以 `nobody` 身分執行也支援 `tproxy` 和 `sockopt`

- 對於高級用戶，你無需、也**不應該**再讓 Xray 以 `root` 身份運行，現在它們已具備所有網絡特權
- 如果你的 Xray 是作為**節點**而不是客戶端運行，或*可考慮*執行下面的命令撤銷部分網路特權。理論上可以降低攻擊面，實際上無關痛癢
- 普通用戶無需關注此改動

```sh
sed -i 's/^capabilities="^cap_net_bind_service,^cap_net_admin,^cap_net_raw"$/capabilities="^cap_net_bind_service"/g' /etc/init.d/xray
```
