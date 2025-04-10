# alpinelinux-install-xray

English | [中文(中国)](README_zh-cn.md) | [中文(薹灣)](README_zh-tw.md)

## Install dependencies

### Install cURL

```sh
apk add curl
```

## Download

```sh
curl -O https://raw.githubusercontent.com/XTLS/alpinelinux-install-xray/main/install-release.sh
```

## Use

```sh
ash install-release.sh
```

## Commands

### Enable

```sh
rc-update add xray
```

### Disable

```sh
rc-update del xray
```

### Start

```sh
rc-service xray start
```

### Stop

```sh
rc-service xray stop
```

### Restart

```sh
rc-service xray restart
```

## Breaking Changes at 2025-04-09

#### Path Change: Original path `/usr/local/lib/xray/` has been updated to new path `/usr/local/share/xray/`

- This directory contains `geosite.dat` and `geoip.dat`
- If you have scripts to automatically update these files, please adjust them accordingly
- Regular users can ignore this change

#### Watchdog: Xray process will now automatically restart indefinitely (every 5 seconds) upon panic, unless it panic 3 times in 10 minutes

- Advanced users no longer need to manually modify `/etc/init.d/xray` or write custom daemon scripts
- Regular users can ignore this change

#### No `root` Required: Xray now retains privileges (capabilities) to support `tproxy` and `sockopt` even when running as `nobody`

- Advanced users **should not** (and need not) run Xray as `root` anymore — it already has all required network privileges
- If you run Xray as a **server** (not client), you _may_ optionally run the command below to reduce capabilities. This theoretically minimizes attack surface but has negligible practical impact
- Regular users can ignore this change

```sh
sed -i 's/^capabilities="^cap_net_bind_service,^cap_net_admin,^cap_net_raw"$/capabilities="^cap_net_bind_service"/g' /etc/init.d/xray
```
