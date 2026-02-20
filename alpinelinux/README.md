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
