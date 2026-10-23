# Xray-install

English | [简体中文](README_zh-Hans.md) | [繁體中文](README_zh-Hant.md)

> [!WARNING]
>
> **Breaking changes since 2026-10-18**
>
> **Fresh installations can ignore this notice. When upgrading from older versions, follow these instructions to avoid Xray startup failures or reduced security.**
>
> 1. **Geodata**: To address some known issues, the data source has changed from Loyalsoldier/v2ray-rules-dat to [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat). Full compatibility with the previous data is not guaranteed. If you need GeoIP country categories other than `cn`, `ru`, and `ir`, run `update-geodata` (renamed from `install-geodata`). If you need special GeoSite categories provided by Loyalsoldier, such as `gfw` or `win-spy`, manually download [Loyalsoldier's geosite.dat](https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat), save it as `geosite-loyalsoldier.dat` in the asset directory, and use `ext:geosite-loyalsoldier.dat:category` in your Xray configuration.
> 2. **Log rotation**: Use the `--logrotate` option provided by this installer. Do not configure additional rotation tasks, as they may cause permission or log writing issues.
> 3. **File permissions**: In response to the recent wave of 0day vulnerabilities in other software and system components, this installer strengthens service isolation and file permission controls to limit their potential impact on Xray. Services now run under the dedicated `xray` user instead of the shared `nobody` account. Custom runtime users are no longer supported, and permissions on configuration and log directories have been tightened. Check access permissions for your custom configuration files, certificates, and existing installations.
>
>    <details>
>    <summary>Expand to view default permissions and requirements for custom configurations and certificates</summary>
>
>    The table below shows the secure default permissions automatically set by the current installer. The program and configuration are managed by root, and the `xray` account can only read the configuration; the service can write geodata and logs. These settings protect logs and configuration files and follow security best practices.
>
>    | Purpose                 | Path                                | Owner:Group | Permissions |
>    | ----------------------- | ----------------------------------- | ----------- | ----------- |
>    | Xray binary             | `/usr/local/bin/xray`               | `root:root` | `0755`      |
>    | Configuration directory | `/usr/local/etc/xray/`              | `root:xray` | `0750`      |
>    | Configuration files     | `/usr/local/etc/xray/*.json`        | `root:xray` | `0640`      |
>    | Geodata directory       | `/usr/local/share/xray/`            | `xray:xray` | `0755`      |
>    | GeoIP data              | `/usr/local/share/xray/geoip.dat`   | `xray:xray` | `0644`      |
>    | GeoSite data            | `/usr/local/share/xray/geosite.dat` | `xray:xray` | `0644`      |
>    | Log directory           | `/var/log/xray/`                    | `xray:xray` | `0700`      |
>
>    **Directory and file permissions from older installations are not automatically migrated. Adjust them manually according to the table above. Alternatively, back up your configuration and data, completely uninstall the older version and delete all related directories and files, then reinstall.**
>
>    **Custom configurations and certificates (if any)**: Your custom configuration directories, new configuration files, certificate directories, certificates, and private keys should also follow the permission rules for "Configuration directory" and "Configuration files" in the table above.
>
>    </details>

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
