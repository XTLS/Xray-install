# Xray-install for Alpine Linux / Gentoo

[English](README.md) | 简体中文 | [繁體中文](README_zh-Hant.md)

> [!WARNING]
>
> **自 2026-10-18 起的不兼容变更**
>
> **全新安装可忽略此内容，从旧版升级必须照做否则可能无法启动 Xray 或降低安全性**
>
> 1. **Geodata**：为了解决一些已知问题，数据来源已从 Loyalsoldier/v2ray-rules-dat 切换至 [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat)，不保证与旧数据完全兼容。若您需要 GeoIP `cn` `ru` `ir` 以外的国家分类，请执行 `update-geodata`（由 `install-geodata` 改名而来）。若您需要 Loyalsoldier 的一些特殊 GeoSite 分类（如 `gfw`、`win-spy`），请手动下载 [Loyalsoldier 版 geosite.dat](https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat)，在资产目录中另存为 `geosite-loyalsoldier.dat`，并在 Xray 配置中通过 `ext:geosite-loyalsoldier.dat:分类名` 使用。
> 2. **日志轮转**：请使用本安装脚本提供的 `--logrotate`，不要再额外配置其他轮转任务，以免发生权限或日志写入问题。
> 3. **文件权限**：鉴于近期其他软件及系统组件的 0day 频发，为降低其对 Xray 服务的潜在影响，现加强服务隔离与文件权限控制：由共用的 `nobody` 用户改为专用的 `xray` 用户，不再支持自定义运行用户，并收紧配置和日志目录权限。您的自定义配置文件、证书及旧安装需要检查访问权限。
>
>    <details>
>    <summary>展开查看文件权限设置要求</summary>
>
>    下表是当前安装脚本自动设置的安全默认权限：程序和配置由 `root` 管理，`xray` 用户只能读取配置；资产和日志允许服务写入。主旨是保护日志和配置文件，这符合最佳安全实践。
>
>    | 用途         | 路径                                | 所有者:组   | 权限   |
>    | ------------ | ----------------------------------- | ----------- | ------ |
>    | Xray 二进制  | `/usr/local/bin/xray`               | `root:root` | `0755` |
>    | 配置目录     | `/usr/local/etc/xray/`              | `root:xray` | `0750` |
>    | 配置文件     | `/usr/local/etc/xray/*.json`        | `root:xray` | `0640` |
>    | 资产目录     | `/usr/local/share/xray/`            | `xray:xray` | `0755` |
>    | GeoIP 数据   | `/usr/local/share/xray/geoip.dat`   | `xray:xray` | `0644` |
>    | GeoSite 数据 | `/usr/local/share/xray/geosite.dat` | `xray:xray` | `0644` |
>    | 日志目录     | `/var/log/xray/`                    | `xray:xray` | `0700` |
>
>    **升级时，会按照上表覆盖权限。**
>
>    **自定义配置（如有）**：您的自定义配置目录和新增配置文件，也应采用上表中“配置目录”和“配置文件”的权限规则。
>
>    **证书（如有）**：证书和私钥的权限请参阅下文[证书文件权限](#证书文件权限)。
>
>    </details>

## 安装或升级 Xray-core

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

#### 运行脚本以安装或升级 Xray

\* 若 SSH 通过 Xray 连接，升级时务必使用 `--manually-restart-later`，避免断连导致脚本出错。

```sh
sh install-release.sh
```

#### 通过代理安装或升级 Xray

```sh
sh install-release.sh --proxy http://127.0.0.1:8118
```

`--proxy` 支持 HTTP 和 SOCKS 代理，也适用于 `update-geodata`。

#### 安装或升级 Xray 到预发布版本

```sh
sh install-release.sh --beta
```

## 从本地压缩包安装（备选方式）

下载[安装脚本](install-release.sh)及对应系统架构的 [Xray-core 压缩包](https://github.com/XTLS/Xray-core/releases)。以下以 x86_64 为例：

```sh
sh install-release.sh --local ./Xray-linux-64.zip
```

还可用 `--geoip` 和 `--geosite` 指定本地 Geodata；两个参数可单独使用，未指定时使用包内数据。

## 日志轮转

安装或升级 Xray，并启用每日轮转，保留 7 份日志

注意：Xray 默认不会将日志记录到 `/var/log/xray/*.log`。请在<a href="https://xtls.github.io/config/log.html" target="_blank">日志配置</a>中指定日志文件路径。

```sh
sh install-release.sh --logrotate
```

Alpine 会启用 crond；Gentoo 需确保 cron 服务正在运行。

## 更新 geoip.dat 和 geosite.dat

\* Xray 自带的是 GeoIP lite 和 GeoSite standard，此命令下载 GeoIP full 和 GeoSite expanded。数据来自 [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat)。

```sh
sh install-release.sh update-geodata
```

## 更多帮助

```sh
sh install-release.sh help
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

## 多实例

如需同时运行多个 Xray 实例，可为每个实例使用独立的配置目录。以 `xray.a` 为例，将配置文件放入 `/usr/local/etc/xray/a/`，然后执行：

```sh
ln -s xray /etc/init.d/xray.a
rc-update add xray.a
rc-service xray.a start
```

各实例配置目录及其中配置文件的所有者、组和权限，应分别与 `/usr/local/etc/xray/` 目录及其配置文件一致。

## 证书文件权限

在 Xray 配置中通过文件路径引用证书和私钥时，`xray` 用户或 `xray` 组需要对这些文件有读取权限（`r`），对所在目录及各级父目录（符号链接目标同理）有访问权限（`x`），不应有写入权限。私钥不应向无关用户及组开放读取，自动续期后也应保持上述权限。

以 [acme.sh](https://github.com/acmesh-official/acme.sh) 为例，优先使用独立用户如 `acme` 运行脚本，先 `touch` 创建证书和私钥文件并设置权限，允许 `acme` 写入、`xray` 只读，再用 `--install-cert` 更新，届时权限会自动保留。次选通过 `--reloadcmd` 调用自定义脚本调整权限，脚本及父目录须禁止无关用户写入，避免被篡改。
