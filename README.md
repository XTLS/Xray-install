# Xray-install

English | [简体中文](README_zh-Hans.md) | [繁體中文](README_zh-Hant.md)

Bash script for installing Xray in operating systems such as CentOS / Debian / OpenSUSE that support systemd.

**For Alpine or Gentoo Linux users**, please refer to **[OpenRC-specific instructions](alpinelinux/README.md)** for installation scripts and guides for Alpine/Gentoo Linux.

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
>    **Directory and file permissions from older installations are not automatically migrated. Adjust them manually according to the table above. Alternatively, back up your configuration and data, completely uninstall the older version and delete all related directories and files, then reinstall.**
>
>    **Custom configurations (if any)**: Your custom configuration directories and new configuration files should also follow the permission rules for "Configuration directory" and "Configuration files" in the table above.
>
>    **Certificates (if any)**: For certificate and private key permissions, see [Certificate file permissions](#certificate-file-permissions) below.
>
>    </details>

---

#### [Filesystem Hierarchy Standard (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)

```
Installed files:
- /etc/systemd/system/xray.service
- /etc/systemd/system/xray@.service

- /usr/local/bin/xray

- /usr/local/etc/xray/*.json

- /usr/local/share/xray/geoip.dat
- /usr/local/share/xray/geosite.dat

- /var/log/xray/
```

## Basic Usage

**Install or upgrade Xray-core**

\* If SSH goes through Xray, you must use `--manually-restart-later` when upgrading to prevent a disconnection from causing script errors.

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
```

**Update geoip.dat and geosite.dat**

\* Xray bundles GeoIP lite and GeoSite standard; this command downloads GeoIP full and GeoSite expanded. Data comes from [XTLS/Xray-rules-dat](https://github.com/XTLS/Xray-rules-dat).

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ update-geodata
```

**Remove Xray, but keep json configuration files and logs**

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove
```

**Check for Xray updates**

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ check
```

## Install from a local archive (alternative)

Download the [installation script](install-release.sh) and the [Xray-core zip](https://github.com/XTLS/Xray-core/releases) for your architecture (x86_64 example):

```bash
bash install-release.sh install --local ./Xray-linux-64.zip
```

You can also use `--geoip` and `--geosite` independently to supply local Geodata; omitted options use the bundled data.

## Advanced Usage

**Install or upgrade Xray through a proxy**

```bash
bash -c "$(curl -x http://127.0.0.1:8118 -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --proxy http://127.0.0.1:8118
```

`--proxy` supports HTTP and SOCKS proxies and also applies to `update-geodata` and `check`.

**Install or upgrade Xray to a pre-release version**

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta
```

**Install or upgrade Xray and enable `logrotate`; `$time` can be a time in the format 12:34:56**

Notice: Xray will NOT log to `/var/log/xray/*.log` by default. Specify log file paths in the <a href="https://xtls.github.io/en/config/log.html" target="_blank">log configuration</a>.

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --logrotate $time
```

```
Installed files:
- /etc/systemd/system/logrotate@.service
- /etc/systemd/system/logrotate@.timer
- /etc/logrotate.d/xray
```

**Install or upgrade Xray without Geodata**

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --without-geodata
```

**Remove Xray, including json configuration files and logs**

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
```

## Other options

`install` also accepts:

| Option                     | Description                             |
| -------------------------- | --------------------------------------- |
| `--version <version>`      | Install a specified version.            |
| `--force`                  | Force installation.                     |
| `--reinstall`              | Reinstall the current version.          |
| `--no-update-service`      | Keep existing service files.            |
| `--without-logfiles`       | Skip creating the log directory.        |
| `--manually-restart-later` | Do not restart service during upgrades. |

## Configuration loading modes and multiple instances

Single-file mode is the default: the default instance reads `/usr/local/etc/xray/config.json`. Start instance `a` with `systemctl enable --now xray@a` to read `/usr/local/etc/xray/a.json`.

Set `JSONS_PATH` when installing or upgrading to switch to <a href="https://xtls.github.io/en/config/features/multiple.html" target="_blank">multi-file mode</a>:

```bash
JSONS_PATH=/usr/local/etc/xray bash install-release.sh install
```

The default instance then reads `JSONS_PATH/`, while instance `a` reads `JSONS_PATH/a/`. Each instance merges all JSON configuration files in its own directory.

Each instance's configuration files should have the same owner, group, and permissions as the configuration files in `/usr/local/etc/xray/`; in multi-file mode, new configuration directories should have the same owner, group, and permissions as `/usr/local/etc/xray/`.

## More Usage

```bash
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ help
```

## Certificate file permissions

When referencing certificates and private keys by file path in the Xray configuration, the `xray` user or `xray` group needs read permission (`r`) on these files, and traversal permission (`x`) on their directory and every parent directory (symlink targets included), with no write permission. Unrelated users and groups should not have read access to the private key. These permissions must remain in place after automatic renewal.

For example, with [acme.sh](https://github.com/acmesh-official/acme.sh), prefer running the script as a dedicated user such as `acme`: pre-create the certificate and private key files with `touch` and set their permissions to allow `acme` to write and `xray` only to read, then update them with `--install-cert`; permissions will automatically be preserved at that point. The second choice is to use `--reloadcmd` to run a custom script that adjusts permissions; prevent unrelated users from writing to the script or its parent directories to protect against tampering.
