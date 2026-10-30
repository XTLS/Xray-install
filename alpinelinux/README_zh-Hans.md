# Xray-install for Alpine Linux / Gentoo

[English](README.md) | 简体中文 | [繁體中文](README_zh-Hant.md)

> [!WARNING]
>
> **自 2026-10-18 起的不兼容变更**
>
> **全新安装可忽略此内容，从旧版升级必须照做否则可能无法启动 xray 或降低安全性**
>
> 1. **Geodata**：为了解决一些已知问题，数据来源已从 Loyalsoldier/v2ray-rules-dat 切换至 [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat)，不保证与旧数据完全兼容。若您需要 GeoIP `cn` `ru` `ir` 以外的国家分类，请执行 `update-geodata`（由 `install-geodata` 改名而来）。若您需要 Loyalsoldier 的一些特殊 GeoSite 分类（如 `gfw`、`win-spy`），请手动下载 [Loyalsoldier 版 geosite.dat](https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat)，在资源目录中另存为 `geosite-loyalsoldier.dat`，并在 xray 配置中通过 `ext:geosite-loyalsoldier.dat:分类名` 使用。
> 2. **日志轮转**：请使用本安装脚本提供的 `--logrotate`，不要再额外配置其他轮转任务，以免发生权限或日志写入问题。
> 3. **文件权限**：鉴于近期其他软件及系统组件的 0day 频发，为降低其对 Xray 服务的潜在影响，现加强服务隔离与文件权限控制：由共用的 `nobody` 账号改为专用的 `xray` 用户，不再支持自定义运行用户，并收紧配置和日志目录权限。您的自定义配置文件、证书及旧安装需要检查访问权限。
>
>    <details>
>    <summary>展开查看默认权限及自定义配置、证书的设置要求</summary>
>
>    下表是当前安装脚本自动设置的安全默认权限：程序和配置由 root 管理，`xray` 账户只能读取配置；geodata 和日志允许服务写入。主旨是保护日志和配置文件，这符合最佳安全实践。
>
>    | 用途         | 路径                                | 所有者:组   | 权限   |
>    | ------------ | ----------------------------------- | ----------- | ------ |
>    | Xray 二进制  | `/usr/local/bin/xray`               | `root:root` | `0755` |
>    | 配置目录     | `/usr/local/etc/xray/`              | `root:xray` | `0750` |
>    | 配置文件     | `/usr/local/etc/xray/*.json`        | `root:xray` | `0640` |
>    | Geodata 目录 | `/usr/local/share/xray/`            | `xray:xray` | `0755` |
>    | GeoIP 数据   | `/usr/local/share/xray/geoip.dat`   | `xray:xray` | `0644` |
>    | GeoSite 数据 | `/usr/local/share/xray/geosite.dat` | `xray:xray` | `0644` |
>    | 日志目录     | `/var/log/xray/`                    | `xray:xray` | `0700` |
>
>    **旧安装的目录和文件权限无法自动迁移，您应按上表手动调整。也可先备份配置与数据，完全卸载旧版并删除所有相关目录和文件后，重新安装。**
>
>    **自定义配置与证书（如有）**：您的自定义配置目录、新增配置文件，以及证书目录、证书和私钥，也应采用上表中“配置目录”和“配置文件”的权限规则。
>
>    </details>

## 安装 Xray

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

#### 运行安装脚本

```sh
sh install-release.sh
```

**如果当前 SSH 连接通过 Xray 建立，更新 Xray 时务必使用 `--manually-restart-later`，避免服务重启导致 SSH 连接中断。**

```sh
sh install-release.sh --manually-restart-later
```

此选项保留当前实例运行，更新后需手动重启以应用更改。

## 代理

```sh
sh install-release.sh --proxy http://127.0.0.1:8118
```

`--proxy` 也适用于 `update-geodata`。

## 预发布版本

安装或升级到最新版本（包含预发布版本）：

```sh
sh install-release.sh --beta
```

## 从本地压缩包安装（备选方式）

下载[安装脚本](install-release.sh)及对应系统架构的 [Xray-core 压缩包](https://github.com/XTLS/Xray-core/releases)，以 root 身份运行。以下以 x86_64 为例：

```sh
sh install-release.sh --local ./Xray-linux-64.zip
```

可用 `--geoip` 和 `--geosite` 指定本地数据；两个参数可单独使用，未指定时使用包内数据。

## 日志轮转

启用每日轮转，保留 7 份日志：

```sh
sh install-release.sh --logrotate
```

Alpine 会启用 `crond`；Gentoo 需确保 cron 服务正在运行。

## 下载／更新 geodata

以 root 身份运行，仅下载／更新 geodata：

```sh
sh install-release.sh update-geodata
```

**Xray 自带的是 GeoIP lite 和 GeoSite standard，此命令下载 GeoIP full 和 GeoSite expanded。** 数据来自 [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat)。

## 更多帮助

```sh
sh install-release.sh help
```

## 管理命令

使用多实例时，将 `xray.a` 的配置文件放入 `/usr/local/etc/xray/a/`，然后执行：

```sh
ln -s xray /etc/init.d/xray.a
rc-update add xray.a
rc-service xray.a start
```

升级仅停止并恢复原先运行的实例。

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
