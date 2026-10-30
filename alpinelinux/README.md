# Xray-install for Alpine Linux / Gentoo

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

## Install Xray

#### Install cURL

**Alpine Linux:**

```sh
apk add curl
```

**Gentoo:**

```sh
emerge net-misc/curl
```

#### Download Installation Script

```sh
curl -O -L https://github.com/XTLS/Xray-install/raw/main/alpinelinux/install-release.sh
```

#### Run Installation Script

```sh
sh install-release.sh
```

**If your current SSH connection goes through Xray, you must use `--manually-restart-later` when updating Xray to prevent a service restart from disconnecting SSH.**

```sh
sh install-release.sh --manually-restart-later
```

This option keeps the current instances running. Restart manually afterward to apply the changes.

## Proxy

```sh
sh install-release.sh --proxy http://127.0.0.1:8118
```

`--proxy` also applies to `update-geodata`.

## Pre-releases

Install or upgrade to the latest available release, including pre-releases:

```sh
sh install-release.sh --beta
```

## Install from a local archive (alternative)

Download the [installation script](install-release.sh) and the [Xray-core zip](https://github.com/XTLS/Xray-core/releases) for your architecture, then run as root (x86_64 example):

```sh
sh install-release.sh --local ./Xray-linux-64.zip
```

Use `--geoip` and `--geosite` independently to supply local data; omitted options use the bundled data.

## Log rotation

Enable daily rotation with seven archives:

```sh
sh install-release.sh --logrotate
```

Alpine enables `crond`; on Gentoo, ensure a cron service is running.

## Download/update geodata

Run as root to download/update geodata only:

```sh
sh install-release.sh update-geodata
```

**Xray bundles GeoIP lite and GeoSite standard; this command downloads GeoIP full and GeoSite expanded.** Data comes from [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat).

## More Help

```sh
sh install-release.sh help
```

## Management Commands

For multiple instances, put the configuration files for `xray.a` in `/usr/local/etc/xray/a/`, then run:

```sh
ln -s xray /etc/init.d/xray.a
rc-update add xray.a
rc-service xray.a start
```

Updates stop and restore only the instances that were running.

#### Enable Xray Service (Auto-start on Boot)

```sh
rc-update add xray
```

#### Disable Xray Service (Remove from Auto-start)

```sh
rc-update del xray
```

#### Start Xray

```sh
rc-service xray start
```

#### Stop Xray

```sh
rc-service xray stop
```

#### Restart Xray

```sh
rc-service xray restart
```
