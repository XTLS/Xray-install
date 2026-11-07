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
> 3. **File permissions**: In response to the recent wave of 0day vulnerabilities in other software and system components, this installer strengthens service isolation and file permission controls to limit their potential impact on Xray. Services now run under the dedicated `xray` user instead of the shared `nobody` user. Custom runtime users are no longer supported, and permissions on configuration and log directories have been tightened. Check access permissions for your custom configuration files, certificates, and existing installations.
>
>    <details>
>    <summary>Expand to view file permission requirements</summary>
>
>    The table below shows the secure default permissions automatically set by the current installer. The program and configuration are managed by `root`, and the `xray` user can only read the configuration; the service can write assets and logs. These settings protect logs and configuration files and follow security best practices.
>
>    | Purpose                 | Path                                | Owner:Group | Permissions |
>    | ----------------------- | ----------------------------------- | ----------- | ----------- |
>    | Xray binary             | `/usr/local/bin/xray`               | `root:root` | `0755`      |
>    | Configuration directory | `/usr/local/etc/xray/`              | `root:xray` | `0750`      |
>    | Configuration files     | `/usr/local/etc/xray/*.json`        | `root:xray` | `0640`      |
>    | Asset directory         | `/usr/local/share/xray/`            | `xray:xray` | `0755`      |
>    | GeoIP data              | `/usr/local/share/xray/geoip.dat`   | `xray:xray` | `0644`      |
>    | GeoSite data            | `/usr/local/share/xray/geosite.dat` | `xray:xray` | `0644`      |
>    | Log directory           | `/var/log/xray/`                    | `xray:xray` | `0700`      |
>
>    **Upgrades overwrite permissions as shown above.**
>
>    **Custom configurations (if any)**: Your custom configuration directories and new configuration files should also follow the permission rules for "Configuration directory" and "Configuration files" in the table above.
>
>    **Certificates (if any)**: For certificate and private key permissions, see [Certificate file permissions](#certificate-file-permissions) below.
>
>    </details>

## Install or upgrade Xray-core

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

#### Run the script to install or upgrade Xray

\* If SSH goes through Xray, you must use `--manually-restart-later` when upgrading to prevent a disconnection from causing script errors.

```sh
sh install-release.sh
```

#### Install or Upgrade Xray Through a Proxy

```sh
sh install-release.sh --proxy http://127.0.0.1:8118
```

`--proxy` supports HTTP and SOCKS proxies and also applies to `update-geodata`.

#### Install or upgrade Xray to a pre-release version

```sh
sh install-release.sh --beta
```

## Install from a local archive (alternative)

Download the [installation script](install-release.sh) and the [Xray-core zip](https://github.com/XTLS/Xray-core/releases) for your architecture (x86_64 example):

```sh
sh install-release.sh --local ./Xray-linux-64.zip
```

You can also use `--geoip` and `--geosite` independently to supply local Geodata; omitted options use the bundled data.

## Log rotation

Install or upgrade Xray and enable daily rotation with seven archives

Notice: Xray will NOT log to `/var/log/xray/*.log` by default. Specify log file paths in the <a href="https://xtls.github.io/en/config/log.html" target="_blank">log configuration</a>.

```sh
sh install-release.sh --logrotate
```

Alpine enables crond; on Gentoo, ensure a cron service is running.

## Update geoip.dat and geosite.dat

\* Xray bundles GeoIP lite and GeoSite standard; this command downloads GeoIP full and GeoSite expanded. Data comes from [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat).

```sh
sh install-release.sh update-geodata
```

## More Help

```sh
sh install-release.sh help
```

## Management Commands

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

## Multiple instances

To run multiple Xray instances, use a separate configuration directory for each instance. For example, place the configuration files for `xray.a` in `/usr/local/etc/xray/a/`, then run:

```sh
ln -s xray /etc/init.d/xray.a
rc-update add xray.a
rc-service xray.a start
```

The owner, group, and permissions of each instance's configuration directory and files should match those of `/usr/local/etc/xray/` and its configuration files, respectively.

## Certificate file permissions

When referencing certificates and private keys by file path in the Xray configuration, the `xray` user or `xray` group needs read permission (`r`) on these files, and traversal permission (`x`) on their directory and every parent directory (symlink targets included), with no write permission. Unrelated users and groups should not have read access to the private key. These permissions must remain in place after automatic renewal.

For example, with [acme.sh](https://github.com/acmesh-official/acme.sh), prefer running the script as a dedicated user such as `acme`: pre-create the certificate and private key files with `touch` and set their permissions to allow `acme` to write and `xray` only to read, then update them with `--install-cert`; permissions will automatically be preserved at that point. The second choice is to use `--reloadcmd` to run a custom script that adjusts permissions; prevent unrelated users from writing to the script or its parent directories to protect against tampering.
