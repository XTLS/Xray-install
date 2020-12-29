#!/usr/bin/env bash

set -euxo pipefail

# Identify architecture
case "$(arch -s)" in
    'i386' | 'i686')
        MACHINE='32'
        ;;
    'amd64' | 'x86_64')
        MACHINE='64'
        ;;
    'armv5tel')
        MACHINE='arm32-v5'
        ;;
    'armv6l')
        MACHINE='arm32-v6'
        grep Features /proc/cpuinfo | grep -qw 'vfp' || MACHINE='arm32-v5'
        ;;
    'armv7' | 'armv7l')
        MACHINE='arm32-v7a'
        grep Features /proc/cpuinfo | grep -qw 'vfp' || MACHINE='arm32-v5'
        ;;
    'armv8' | 'aarch64')
        MACHINE='arm64-v8a'
        ;;
    'mips')
        MACHINE='mips32'
        ;;
    'mipsle')
        MACHINE='mips32le'
        ;;
    'mips64')
        MACHINE='mips64'
        ;;
    'mips64le')
        MACHINE='mips64le'
        ;;
    'ppc64')
        MACHINE='ppc64'
        ;;
    'ppc64le')
        MACHINE='ppc64le'
        ;;
    'riscv64')
        MACHINE='riscv64'
        ;;
    's390x')
        MACHINE='s390x'
        ;;
    *)
        echo "error: The architecture is not supported."
        exit 1
        ;;
esac

TMP_DIRECTORY="$(mktemp -d)/"
ZIP_FILE="${TMP_DIRECTORY}v2ray-linux-$MACHINE.zip"
DOWNLOAD_LINK="https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-$MACHINE.zip"

install_software() {
    if [[ -n "$(command -v curl)" ]]; then
        return
    fi
    if [[ -n "$(command -v unzip)" ]]; then
        return
    fi
    if [ "$(command -v apk)" ]; then
        apk add curl unzip
    else
        echo "error: The script does not support the package manager in this operating system."
        exit 1
    fi
}

download_v2ray() {
    curl -L -H 'Cache-Control: no-cache' -o "$ZIP_FILE" "$DOWNLOAD_LINK" -#
    if [ "$?" -ne '0' ]; then
        echo 'error: Download failed! Please check your network or try again.'
        exit 1
    fi
    curl -L -H 'Cache-Control: no-cache' -o "$ZIP_FILE.dgst" "$DOWNLOAD_LINK.dgst" -#
    if [ "$?" -ne '0' ]; then
        echo 'error: Download failed! Please check your network or try again.'
        exit 1
    fi
}

verification_v2ray() {
    for LISTSUM in 'md5' 'sha1' 'sha256' 'sha512'; do
        SUM="$(${LISTSUM}sum $ZIP_FILE | sed 's/ .*//')"
        CHECKSUM="$(grep $(echo $LISTSUM | tr [:lower:] [:upper:]) $ZIP_FILE.dgst | uniq | sed 's/.* //')"
        if [ "$SUM" != "$CHECKSUM" ]; then
            echo 'error: Check failed! Please check your network or try again.'
            exit 1
        fi
    done
}

decompression() {
    unzip -q "$ZIP_FILE" -d "$TMP_DIRECTORY"
}

is_it_running() {
    V2RAY_RUNNING='0'
    if [ -n "$(pgrep v2ray)" ]; then
        rc-service v2ray stop
        V2RAY_RUNNING='1'
    fi
}

install_v2ray() {
    install -m 755 "${TMP_DIRECTORY}v2ray" "/usr/local/bin/v2ray"
    install -m 755 "${TMP_DIRECTORY}v2ctl" "/usr/local/bin/v2ctl"
    install -d /usr/local/lib/v2ray/
    install -m 755 "${TMP_DIRECTORY}geoip.dat" "/usr/local/lib/v2ray/geoip.dat"
    install -m 755 "${TMP_DIRECTORY}geosite.dat" "/usr/local/lib/v2ray/geosite.dat"
}

install_confdir() {
    CONFDIR='0'
    if [ ! -d '/usr/local/etc/v2ray/' ]; then
        install -d /usr/local/etc/v2ray/
        for BASE in 00_log 01_api 02_dns 03_routing 04_policy 05_inbounds 06_outbounds 07_transport 08_stats 09_reverse; do
            echo '{}' > "/usr/local/etc/v2ray/$BASE.json"
        done
        CONFDIR='1'
    fi
}

install_log() {
    LOG='0'
    if [ ! -d '/var/log/v2ray/' ]; then
        install -d -o nobody -g nobody /var/log/v2ray/
        install -m 600 -o nobody -g nobody /dev/null /var/log/v2ray/access.log
        install -m 600 -o nobody -g nobody /dev/null /var/log/v2ray/error.log
        LOG='1'
    fi
}

install_startup_service_file() {
    OPENRC='0'
    if [ ! -f '/etc/init.d/v2ray' ]; then
        mkdir "${TMP_DIRECTORY}init.d/"
        curl -o "${TMP_DIRECTORY}init.d/v2ray" https://raw.githubusercontent.workers.dev/v2fly/alpinelinux-install-v2ray/master/init.d/v2ray -s
        if [ "$?" -ne '0' ]; then
            echo 'error: Failed to start service file download! Please check your network or try again.'
            exit 1
        fi
        install -m 755 "${TMP_DIRECTORY}init.d/v2ray" /etc/init.d/v2ray
        OPENRC='1'
    fi
}

information() {
    echo 'installed: /usr/local/bin/v2ray'
    echo 'installed: /usr/local/bin/v2ctl'
    echo 'installed: /usr/local/lib/v2ray/geoip.dat'
    echo 'installed: /usr/local/lib/v2ray/geosite.dat'
    if [ "$CONFDIR" -eq '1' ]; then
        echo 'installed: /usr/local/etc/v2ray/00_log.json'
        echo 'installed: /usr/local/etc/v2ray/01_api.json'
        echo 'installed: /usr/local/etc/v2ray/02_dns.json'
        echo 'installed: /usr/local/etc/v2ray/03_routing.json'
        echo 'installed: /usr/local/etc/v2ray/04_policy.json'
        echo 'installed: /usr/local/etc/v2ray/05_inbounds.json'
        echo 'installed: /usr/local/etc/v2ray/06_outbounds.json'
        echo 'installed: /usr/local/etc/v2ray/07_transport.json'
        echo 'installed: /usr/local/etc/v2ray/08_stats.json'
        echo 'installed: /usr/local/etc/v2ray/09_reverse.json'
    fi
    if [ "$LOG" -eq '1' ]; then
        echo 'installed: /var/log/v2ray/'
    fi
    if [ "$OPENRC" -eq '1' ]; then
        echo 'installed: /etc/init.d/v2ray'
    fi
    rm -r "$TMP_DIRECTORY"
    echo "removed: $TMP_DIRECTORY"
    echo "You may need to execute a command to remove dependent software: apk del curl unzip"
    if [ "$V2RAY_RUNNING" -eq '1' ]; then
        rc-service v2ray start
    else
        echo 'Please execute the command: rc-update add v2ray; rc-service v2ray start'
    fi
    echo "info: V2Ray is installed."
}

main() {
    install_software
    install_software
    download_v2ray
    verification_v2ray
    decompression
    is_it_running
    install_v2ray
    install_confdir
    install_log
    install_startup_service_file
    information
}

main
