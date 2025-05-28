# Xray-install for Alpine Linux

English | [简体中文](README_zh-Hans.md) | [繁體中文](README_zh-Hant.md)

## Install Xray

#### Install cURL

```sh
apk add curl
```

#### Download Installation Script

```sh
curl -O -L https://github.com/XTLS/Xray-install/raw/main/alpinelinux/install-release.sh
```

#### Run Installation Script

```sh
ash install-release.sh
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
