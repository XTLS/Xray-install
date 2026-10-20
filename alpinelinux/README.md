# Xray-install for Alpine Linux / Gentoo

English | [简体中文](README_zh-Hans.md) | [繁體中文](README_zh-Hant.md)

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

For multiple instances, put the configuration files for `xray.a` in `/usr/local/etc/xray/a/` and set `confdir="/usr/local/etc/xray/a/"` in `/etc/conf.d/xray.a`, then run:

```sh
ln -s xray /etc/init.d/xray.a
rc-update add xray.a
rc-service xray.a start
```

Each instance can use a different `confdir`. Updates stop and restore only the instances that were running.

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
