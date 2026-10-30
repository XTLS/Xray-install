# Xray-install

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

用于在支持 systemd 的操作系统（如 CentOS / Debian / OpenSUSE）中安装 Xray 的 Bash 脚本。

**对于 Alpine 及 Gentoo Linux 用户**，请参考 **[OpenRC 专用说明](alpinelinux/README_zh-Hans.md)** 以获取适用于 Alpine/Gentoo Linux 的安装脚本和指南。

---

#### [文件系统层次结构标准 (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)

```
已安装文件：
- /etc/systemd/system/xray.service
- /etc/systemd/system/xray@.service

- /usr/local/bin/xray
- /usr/local/etc/xray/*.json

- /usr/local/share/xray/geoip.dat
- /usr/local/share/xray/geosite.dat

- /var/log/xray/
```

注意：Xray 默认不会将日志记录到 `/var/log/xray/*.log`。请配置 `"log"` 来指定日志文件。

## 基本用法

**安装并升级 Xray-core**

**如果当前 SSH 连接通过 Xray 建立，更新 Xray 时务必使用 `--manually-restart-later`，避免服务重启导致 SSH 连接中断。**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
```

**仅更新 geoip.dat 和 geosite.dat**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ update-geodata
```

**Xray 自带的是 GeoIP lite 和 GeoSite standard，此命令下载 GeoIP full 和 GeoSite expanded。** 数据来自 [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat)。

**移除 Xray，但保留 json 配置文件和日志**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove
```

**检查更新**

```sh
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ check
```

## 从本地压缩包安装（备选方式）

下载[安装脚本](install-release.sh)及对应系统架构的 [Xray-core 压缩包](https://github.com/XTLS/Xray-core/releases)，以 root 身份运行。以下以 x86_64 为例：

```sh
bash install-release.sh install --local ./Xray-linux-64.zip
```

可用 `--geoip` 和 `--geosite` 指定本地数据；两个参数可单独使用，未指定时使用包内数据。

## 高级用法

**通过代理安装或升级**

```sh
bash -c "$(curl -x http://127.0.0.1:8118 -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --proxy http://127.0.0.1:8118
```

`--proxy` 支持 HTTP 和 SOCKS 代理，也适用于 `update-geodata` 和 `check`。

**安装并升级 Xray-core 到预发布版本**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta
```

**安装并升级 Xray-core，并启用 `logrotate`，`$time` 可以是 12:34:56 格式的时间**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --logrotate $time
```

```
已安装文件：
- /etc/systemd/system/logrotate@.service
- /etc/systemd/system/logrotate@.timer
- /etc/logrotate.d/xray
```

**安装并升级 Xray-core，但不包含地理数据**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --without-geodata
```

**移除 Xray，包括 json 配置文件和日志**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
```

## 其他参数

`install` 还支持以下参数：

| 参数                       | 说明                                 |
| -------------------------- | ------------------------------------ |
| `--version <version>`      | 安装指定版本。                       |
| `--force`                  | 强制安装。                           |
| `--reinstall`              | 重新安装当前版本。                   |
| `--no-update-service`      | 保留已有服务文件。                   |
| `--without-logfiles`       | 不创建日志目录。                     |
| `--manually-restart-later` | 安装时不重新启动服务。（须谨慎使用） |

## 多实例

安装时设置 `JSONS_PATH` 以使用配置目录：

```sh
JSONS_PATH=/usr/local/etc/xray bash install-release.sh install
```

`xray.service` 读取 `JSONS_PATH`，`xray@a.service` 读取 `JSONS_PATH/a/`。将各实例的配置放入对应目录后，使用 `systemctl enable --now xray@a` 启动。

## 更多用法

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ help
```

## 星标趋势图

[![星标趋势图](https://starchart.cc/XTLS/Xray-install.svg)](https://starchart.cc/XTLS/Xray-install)
