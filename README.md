# Xray-install

English | [简体中文](README_zh-Hans.md) | [繁體中文](README_zh-Hant.md)

Bash script for installing Xray in operating systems such as CentOS / Debian / OpenSUSE that support systemd.

**For Alpine or Gentoo Linux users**, please refer to **[OpenRC Specific Instructions](alpinelinux/README.md)** for installation scripts and guides tailored for Alpine/Gentoo Linux featured by OpenRC init-system.

---

#### [Filesystem Hierarchy Standard (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)

```
installed: /etc/systemd/system/xray.service
installed: /etc/systemd/system/xray@.service

installed: /usr/local/bin/xray
installed: /usr/local/etc/xray/*.json

installed: /usr/local/share/xray/geoip.dat
installed: /usr/local/share/xray/geosite.dat

installed: /var/log/xray/
```

Notice: Xray will NOT log to `/var/log/xray/*.log` by default. Configure `"log"` to specify log files.

## Basic Usage

**Install & Upgrade Xray-core**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
```

**Update geoip.dat and geosite.dat only**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ update-geodata
```

**Xray bundles GeoIP lite and GeoSite standard; this command downloads GeoIP full and GeoSite expanded.** Data comes from [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat).

**Remove Xray, except json and logs**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove
```

**Check for updates**

```sh
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ check
```

## Install from a local archive (alternative)

Download the [installation script](install-release.sh) and the [Xray-core zip](https://github.com/XTLS/Xray-core/releases) for your architecture, then run as root (x86_64 example):

```sh
bash install-release.sh install --local ./Xray-linux-64.zip
```

Use `--geoip` and `--geosite` independently to supply local data; omitted options use the bundled data.

## Advance

**Install or upgrade through a proxy**

```sh
bash -c "$(curl -x http://127.0.0.1:8118 -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --proxy http://127.0.0.1:8118
```

`--proxy` supports HTTP and SOCKS proxies and also applies to `update-geodata` and `check`.

**Install & Upgrade Xray-core to a pre-release version**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta
```

**Install & Upgrade Xray-core with `logrotate`, `$time` can be in the format of 12:34:56**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --logrotate $time
```

```
installed: /etc/systemd/system/logrotate@.service
installed: /etc/systemd/system/logrotate@.timer

installed: /etc/logrotate.d/xray
```

**Install & Upgrade Xray-core without geodata**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --without-geodata
```

**Remove Xray, include json and logs**

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
```

## Other options

`install` also accepts:

| Option                | Description                      |
| --------------------- | -------------------------------- |
| `--version <version>` | Install a specified version.     |
| `--force`             | Force installation.              |
| `--reinstall`         | Reinstall the current version.   |
| `--no-update-service` | Keep existing service files.     |
| `--without-logfiles`  | Skip creating the log directory. |

## Multiple instances

Set `JSONS_PATH` when installing to use configuration directories:

```sh
JSONS_PATH=/usr/local/etc/xray bash install-release.sh install
```

`xray.service` reads `JSONS_PATH`; `xray@a.service` reads `JSONS_PATH/a/`. Put each instance's configuration files in its directory, then start it with `systemctl enable --now xray@a`.

## More Usage

```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ help
```

## Stargazers over time

[![Stargazers over time](https://starchart.cc/XTLS/Xray-install.svg)](https://starchart.cc/XTLS/Xray-install)
