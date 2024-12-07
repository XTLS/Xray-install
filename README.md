# Xray-install

Bash script for installing Xray in operating systems such as CentOS / Debian / OpenSUSE that support systemd.

[Filesystem Hierarchy Standard (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)

```
installed: /etc/systemd/system/xray.service
installed: /etc/systemd/system/xray@.service

installed: /usr/local/bin/xray
installed: /usr/local/etc/xray/*.json

installed: /usr/local/share/xray/geoip.dat
installed: /usr/local/share/xray/geosite.dat

installed: /var/log/xray/access.log
installed: /var/log/xray/error.log
```

Notice: Xray will NOT log to `/var/log/xray/*.log` by default. Configure `"log"` to specify log files.

## Basic Usage

**Install & Upgrade Xray-core and geodata with `User=nobody`, but will NOT overwrite `User` in existing service files**

```
curl -fL https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s - install
```

**Update geoip.dat and geosite.dat only**

```
curl -fL https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s - install-geodata
```

**Remove Xray, except json and logs**

```
curl -fL https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s - remove
```

## Advance

**Install & Upgrade Xray-core to a pre-release version**

```
curl -fL https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s - install --beta
```

**Install & Upgrade Xray-core and geodata with `logrotate`, `$time` can be in the format of 12:34:56**

```
curl -fL https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s - install --logrotate $time
```
```
installed: /etc/systemd/system/logrotate@.service
installed: /etc/systemd/system/logrotate@.timer

installed: /etc/logrotate.d/xray
```

**Install & Upgrade Xray-core and geodata with `User=root`, which will overwrite `User` in existing service files**

```
curl -fL https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s - install -u root
```

**Install & Upgrade Xray-core without geodata**

```
curl -fL https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s - install --without-geodata
```

**Remove Xray, include json and logs**

```
curl -fL https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s - remove --purge
```

## More Usage

```
curl -fL https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s - help
```

## Stargazers over time

[![Stargazers over time](https://starchart.cc/XTLS/Xray-install.svg)](https://starchart.cc/XTLS/Xray-install)
