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

### Install & Upgrade Xray-core

```
# bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh) install
```

### Install & Upgrade Xray-core with user root

```
# bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh) install -u root
```

### Install & Upgrade Xray-core without .dat files

```
# bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh) install --without-geodata
```

### Install & Update geoip.dat and geosite.dat only

```
# bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh) install-geodata
```

### Remove Xray

```
# bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh) remove --purge
```

### Remove Xray, except json and logs

```
# bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh) remove
```

### More useages

```
# bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh) help
```
