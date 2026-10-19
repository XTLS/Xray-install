# Xray-install

[English](README.md) | 简体中文 | [繁體中文](README_zh-Hant.md)

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

**安装并升级 Xray-core 和地理数据**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
```

**仅更新 geoip.dat 和 geosite.dat**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install-geodata
```

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

## 高级用法

**通过代理安装或升级**

```sh
bash -c "$(curl -x http://127.0.0.1:8118 -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --proxy http://127.0.0.1:8118
```

`--proxy` 支持 HTTP 和 SOCKS 代理，也适用于 `install-geodata` 和 `check`。

**安装并升级 Xray-core 到预发布版本**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta
```

**安装并升级 Xray-core 和地理数据，并启用 `logrotate`，`$time` 可以是 12:34:56 格式的时间**

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

| 参数                  | 说明               |
| --------------------- | ------------------ |
| `--version <version>` | 安装指定版本。     |
| `--force`             | 强制安装。         |
| `--reinstall`         | 重新安装当前版本。 |
| `--no-update-service` | 保留已有服务文件。 |
| `--without-logfiles`  | 不创建日志目录。   |

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
