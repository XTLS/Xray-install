# Xray-install

Bash script for installing Xray in operating systems such as CentOS / Debian / OpenSUSE that support systemd.

[Filesystem Hierarchy Standard (FHS)](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)

```
installed: /usr/local/bin/xray
installed: /usr/local/etc/xray/*.json

installed: /usr/local/share/xray/geoip.dat
installed: /usr/local/share/xray/geosite.dat

installed: /var/log/xray/access.log
installed: /var/log/xray/error.log

installed: /etc/systemd/system/xray.service
installed: /etc/systemd/system/xray@.service
```

## Usage

### Install & Upgrade Xray-core and .dat files

```
# bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh)
```

### Update geoip.dat and geosite.dat only

```
# bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-dat-release.sh)
```

### Remove Xray, except json and logs

```
# bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh) --remove
```
