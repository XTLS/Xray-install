# Xray-install

[English](README.md) | 简体中文 | [繁體中文](README_zh-Hant.md)

用于在支持 systemd 的操作系统（如 CentOS / Debian / OpenSUSE）中安装 Xray 的 Bash 脚本。

**对于 Alpine 及 Gentoo Linux 用户**，请参考 **[OpenRC 专用说明](alpinelinux/README_zh-Hans.md)** 以获取适用于 Alpine/Gentoo Linux 的安装脚本和指南。

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

## 基本用法

**安装或升级 Xray-core**

\* 若 SSH 通过 Xray 连接，升级时务必使用 `--manually-restart-later`，避免断连导致脚本出错。

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
```

**更新 geoip.dat 和 geosite.dat**

\* Xray 自带的是 GeoIP lite 和 GeoSite standard，此命令下载 GeoIP full 和 GeoSite expanded。数据来自 [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat)。

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ update-geodata
```

**移除 Xray，但保留 json 配置文件和日志**

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove
```

**检查 Xray 更新**

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ check
```

## 从本地压缩包安装（备选方式）

下载[安装脚本](install-release.sh)及对应系统架构的 [Xray-core 压缩包](https://github.com/XTLS/Xray-core/releases)。以下以 x86_64 为例：

```bash
bash install-release.sh install --local ./Xray-linux-64.zip
```

还可用 `--geoip` 和 `--geosite` 指定本地 Geodata；两个参数可单独使用，未指定时使用包内数据。

## 高级用法

**通过代理安装或升级 Xray**

```bash
bash -c "$(curl -x http://127.0.0.1:8118 -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --proxy http://127.0.0.1:8118
```

`--proxy` 支持 HTTP 和 SOCKS 代理，也适用于 `update-geodata` 和 `check`。

**安装或升级 Xray 到预发布版本**

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta
```

**安装或升级 Xray，并启用 `logrotate`，`$time` 可以是 12:34:56 格式的时间**

注意：Xray 默认不会将日志记录到 `/var/log/xray/*.log`。请在<a href="https://xtls.github.io/config/log.html" target="_blank">日志配置</a>中指定日志文件路径。

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --logrotate $time
```

```
已安装文件：
- /etc/systemd/system/logrotate@.service
- /etc/systemd/system/logrotate@.timer
- /etc/logrotate.d/xray
```

**安装或升级 Xray，但不包含 Geodata**

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --without-geodata
```

**移除 Xray，包括 json 配置文件和日志**

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
```

## 其他参数

`install` 还支持以下参数：

| 参数                       | 说明                   |
| -------------------------- | ---------------------- |
| `--version <version>`      | 安装指定版本。         |
| `--force`                  | 强制安装。             |
| `--reinstall`              | 重新安装当前版本。     |
| `--no-update-service`      | 保留已有服务文件。     |
| `--without-logfiles`       | 不创建日志目录。       |
| `--manually-restart-later` | 升级时不重新启动服务。 |

## 配置加载模式与多实例

默认使用单文件模式，默认实例读取 `/usr/local/etc/xray/config.json`。使用 `systemctl enable --now xray@a` 启动实例 `a`，读取 `/usr/local/etc/xray/a.json`。

安装或升级时设置 `JSONS_PATH`，可切换为<a href="https://xtls.github.io/config/features/multiple.html" target="_blank">多文件模式</a>：

```bash
JSONS_PATH=/usr/local/etc/xray bash install-release.sh install
```

此时，默认实例读取 `JSONS_PATH/`，实例 `a` 读取 `JSONS_PATH/a/`，均合并加载各自目录下的所有 JSON 配置文件。

各实例配置文件的所有者、组和权限应与 `/usr/local/etc/xray/` 中的配置文件一致；使用多文件模式时，新目录的所有者、组和权限也应与 `/usr/local/etc/xray/` 一致。

## 更多用法

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ help
```

## 证书文件权限

在 Xray 配置中通过文件路径引用证书和私钥时，`xray` 用户或 `xray` 组需要对这些文件有读取权限（`r`），对所在目录及各级父目录（符号链接目标同理）有访问权限（`x`），不应有写入权限。私钥不应向无关用户及组开放读取，自动续期后也应保持上述权限。

以 [acme.sh](https://github.com/acmesh-official/acme.sh) 为例，优先使用独立用户如 `acme` 运行脚本，先 `touch` 创建证书和私钥文件并设置权限，允许 `acme` 写入、`xray` 只读，再用 `--install-cert` 更新，届时权限会自动保留。次选通过 `--reloadcmd` 调用自定义脚本调整权限，脚本及父目录须禁止无关用户写入，避免被篡改。
