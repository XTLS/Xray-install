#!/usr/bin/env ash
# shellcheck shell=dash

set -euo pipefail

pkg_manager() {
    local OP="$1" PM=apk
    shift
    if [ -f /etc/gentoo-release ]; then
        PM=emerge
        case "$OP" in
        add)
            OP='-v'
            ;;
        del)
            OP='-C'
            ;;
        esac
    fi
    if [ $# -eq 0 ]; then
        echo "$PM $OP"
    else
        $PM "$OP" "$@"
    fi
}

check_distro() {
    if [ -z "$(command -v rc-service)" ]; then
        echo "No OpenRC init-system detected."
        return 1
    fi
    if [ -f /etc/alpine-release ] || [ -f /etc/gentoo-release ]; then
        return 0
    else
        return 1
    fi
}

check_if_running_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        return 0
    else
        echo "error: You must run this script as root!"
        return 1
    fi
}

identify_architecture() {
    if [ "$(uname)" != 'Linux' ]; then
        echo "error: This operating system is not supported."
        return 1
    fi
    case "$(uname -m)" in
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
        lscpu | grep -q "Little Endian" && MACHINE='mips64le'
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
        return 1
        ;;
    esac
    if [ ! -f '/etc/os-release' ]; then
        echo "error: Don't use outdated Linux distributions."
        return 1
    fi
}

install_dependencies() {
    local dependency
    for dependency do
        if command -v "$dependency" >/dev/null 2>&1; then
            continue
        fi
        echo "Installing required dependency: $dependency"
        if ! pkg_manager add "$dependency"; then
            echo "error: Installation of $dependency failed, please check your system package repositories."
            exit 1
        fi
    done
}

download_xray() {
    echo "Downloading Xray files..."
    if ! curl -f -L -H 'Cache-Control: no-cache' -o "$ZIP_FILE" "$DOWNLOAD_LINK" -#; then
        echo 'error: Download failed! Please check your network or try again.'
        exit 1
    fi

    if ! curl -f -L -H 'Cache-Control: no-cache' -o "$ZIP_FILE.dgst" "$DOWNLOAD_LINK.dgst" -#; then
        echo 'error: Download failed! Please check your network or try again.'
        exit 1
    fi
}

verification_xray() {
    CHECKSUM=$(awk -F '= ' '/256=/ {print $2}' "$ZIP_FILE.dgst")
    LOCALSUM=$(sha256sum "$ZIP_FILE" | awk '{printf $1}')
    if [ "$CHECKSUM" != "$LOCALSUM" ]; then
        echo 'error: SHA256 check failed! Please check your network or try again.'
        return 1
    fi
}

decompression() {
    if ! unzip -q "$ZIP_FILE" -d "$TMP_DIRECTORY"; then
        echo 'error: Xray decompression failed.'
        exit 1
    fi
}

is_it_running() {
    XRAY_RUNNING='0'
    if [ -n "$(pgrep xray)" ]; then
        rc-service xray stop
        XRAY_RUNNING='1'
    fi
}

install_xray() {
    install -m 755 "${TMP_DIRECTORY}xray" "/usr/local/bin/xray"
    install -d -m 755 -o nobody -g nobody /usr/local/share/xray/
    install -m 644 -o nobody -g nobody "${TMP_DIRECTORY}geoip.dat" "/usr/local/share/xray/geoip.dat"
    install -m 644 -o nobody -g nobody "${TMP_DIRECTORY}geosite.dat" "/usr/local/share/xray/geosite.dat"
}

install_confdir() {
    CONFDIR='0'
    if [ ! -d '/usr/local/etc/xray/' ]; then
        install -d /usr/local/etc/xray/
        for BASE in 00_log 01_api 02_dns 03_routing 04_policy 05_inbounds 06_outbounds 07_stats 08_fakedns 09_metrics 10_observatory 11_geodata 12_env 99_version; do
            echo '{}' >"/usr/local/etc/xray/$BASE.json"
        done
        CONFDIR='1'
    fi
}

install_log() {
    LOG='0'
    if [ ! -d '/var/log/xray/' ]; then
        install -d -m 755 -o 0 -g 0 /var/log/xray/
        install -m 600 -o nobody -g nobody /dev/null /var/log/xray/access.log
        install -m 600 -o nobody -g nobody /dev/null /var/log/xray/error.log
        LOG='1'
    else
        chown 0:0 /var/log/xray/
        chmod 755 /var/log/xray/
        chown nobody:nobody /var/log/xray/*.log
        chmod 600 /var/log/xray/*.log
    fi
}

install_startup_service_file() {
    OPENRC='0'
    if [ ! -f '/etc/init.d/xray' ]; then
        mkdir "${TMP_DIRECTORY}init.d/" || return 1
        cat >"${TMP_DIRECTORY}init.d/xray" <<'EOF' || return 1
#!/sbin/openrc-run

name="Xray Daemon"
description="A unified platform for anti-censorship"

supervisor=supervise-daemon
respawn_delay=5
respawn_max=2
respawn_period=600

pidfile="/run/${RC_SVCNAME}.pid"
rc_ulimit="-n 1024000 -u 1024000"
capabilities="^cap_net_bind_service,^cap_net_admin,^cap_net_raw"
extra_commands="checkconfig"

env=${env:-"XRAY_LOCATION_ASSET=/usr/local/share/xray/"} # See: https://xtls.github.io/en/config/env.html
confdir=${confdir:-"/usr/local/etc/xray/"}
command="/usr/local/bin/xray"
command_user="nobody:nobody"
command_args="run -confdir $confdir"
required_files="$confdir"

depend() {
	need net
	want dns ntp-client
	after firewall
}

checkconfig() {
	export $env
	$command $command_args -test
	eend $?
}

start_pre() {
	checkconfig || return 1
}
EOF
        install -m 755 "${TMP_DIRECTORY}init.d/xray" /etc/init.d/xray || return 1
        OPENRC='1'
    fi
}

information() {
    echo 'installed: /usr/local/bin/xray'
    echo 'installed: /usr/local/share/xray/geoip.dat'
    echo 'installed: /usr/local/share/xray/geosite.dat'
    if [ "$CONFDIR" -eq '1' ]; then
        echo 'installed: /usr/local/etc/xray/00_log.json'
        echo 'installed: /usr/local/etc/xray/01_api.json'
        echo 'installed: /usr/local/etc/xray/02_dns.json'
        echo 'installed: /usr/local/etc/xray/03_routing.json'
        echo 'installed: /usr/local/etc/xray/04_policy.json'
        echo 'installed: /usr/local/etc/xray/05_inbounds.json'
        echo 'installed: /usr/local/etc/xray/06_outbounds.json'
        echo 'installed: /usr/local/etc/xray/07_stats.json'
        echo 'installed: /usr/local/etc/xray/08_fakedns.json'
        echo 'installed: /usr/local/etc/xray/09_metrics.json'
        echo 'installed: /usr/local/etc/xray/10_observatory.json'
        echo 'installed: /usr/local/etc/xray/11_geodata.json'
        echo 'installed: /usr/local/etc/xray/12_env.json'
        echo 'installed: /usr/local/etc/xray/99_version.json'
    fi
    if [ "$LOG" -eq '1' ]; then
        echo 'installed: /var/log/xray/'
    fi
    if [ "$OPENRC" -eq '1' ]; then
        echo 'installed: /etc/init.d/xray'
    fi
    rm -r "$TMP_DIRECTORY"
    echo "removed: $TMP_DIRECTORY"
    echo "You may need to execute a command to remove dependent software: $(pkg_manager del) curl unzip"
    if [ "$XRAY_RUNNING" -eq '1' ]; then
        rc-service xray start
    else
        echo 'Please execute the command: rc-update add xray; rc-service xray start'
    fi
    echo "info: Xray is installed."
}

main() {
    check_distro || return 1
    check_if_running_as_root || return 1
    identify_architecture || return 1
    install_dependencies curl unzip

    TMP_DIRECTORY="$(mktemp -d)" || return 1
    TMP_DIRECTORY="${TMP_DIRECTORY}/"
    ZIP_FILE="${TMP_DIRECTORY}Xray-linux-$MACHINE.zip"
    DOWNLOAD_LINK="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$MACHINE.zip"

    download_xray
    verification_xray
    decompression
    is_it_running
    install_xray
    install_confdir
    install_log
    install_startup_service_file || return 1
    information
}

main
