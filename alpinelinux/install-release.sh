#!/usr/bin/env ash
# shellcheck shell=dash

set -euo pipefail

LOCAL_FILE=''
HELP='0'
LOGROTATE='0'
BETA='0'

judgment_parameters() {
    local action=''
    while [ "$#" -gt 0 ]; do
        case "$1" in
        install | help)
            if [ -n "$action" ] && [ "$action" != "$1" ]; then
                echo 'error: You can only choose one action.'
                return 1
            fi
            action="$1"
            ;;
        -l | --local)
            case "${2:-}" in
            '' | -*)
                echo 'error: Please specify a local Xray zip file after --local.'
                return 1
                ;;
            esac
            LOCAL_FILE="$2"
            shift
            ;;
        --logrotate)
            LOGROTATE='1'
            ;;
        --beta)
            BETA='1'
            ;;
        *)
            echo "error: Unknown option: $1"
            return 1
            ;;
        esac
        shift
    done
    if [ "$action" = help ]; then
        if [ -n "$LOCAL_FILE" ]; then
            echo 'error: --local can only be used with install.'
            return 1
        fi
        if [ "$LOGROTATE" -eq '1' ]; then
            echo 'error: --logrotate can only be used with install.'
            return 1
        fi
        if [ "$BETA" -eq '1' ]; then
            echo 'error: --beta can only be used with install.'
            return 1
        fi
        HELP='1'
    fi
    if [ -n "$LOCAL_FILE" ] && [ "$BETA" -eq '1' ]; then
        echo 'error: --beta and --local cannot be used together.'
        return 1
    fi
}

show_help() {
    echo "usage: $0 [install | help] [OPTION]..."
    echo 'With no action, install/update Xray from GitHub.'
    echo '  -l, --local <zip>  Install a local Xray zip without accessing GitHub'
    echo '                     Relative paths use the current working directory; quote paths containing spaces'
    echo '                     Verify <zip>.dgst if present; warn and continue if absent'
    echo '                     Missing tools may be installed from system package repositories'
    echo '                     The archive must contain xray, geoip.dat and geosite.dat'
    echo '      --logrotate    Enable daily log rotation, keeping seven archives'
    echo '      --beta         Install the latest available release, including pre-releases'
}

verify_local_archive() {
    local digest_file="${LOCAL_FILE}.dgst" checksum local_sum
    if [ ! -f "$LOCAL_FILE" ] || [ ! -r "$LOCAL_FILE" ]; then
        echo "error: Local Xray archive is not a readable file: $LOCAL_FILE"
        return 1
    fi
    if [ ! -e "$digest_file" ] && [ ! -L "$digest_file" ]; then
        echo "warning: No local verification file found: $digest_file; continuing without SHA256 verification."
        return 0
    fi
    if [ ! -f "$digest_file" ] || [ ! -r "$digest_file" ]; then
        echo "error: Local verification file is not readable: $digest_file"
        return 1
    fi
    checksum="$(awk -F '=' '/^[[:space:]]*SHA(2-)?256[[:space:]]*=/ {
        if (NF != 2) { print "invalid"; next }
        value = $2
        sub(/^[[:space:]]*/, "", value)
        sub(/[[:space:]]*$/, "", value)
        print tolower(value)
    }' "$digest_file")"
    case "$checksum" in
    '' | *[!0-9a-f]*)
        echo "error: Missing or invalid SHA256 digest in $digest_file"
        return 1
        ;;
    esac
    if [ "${#checksum}" -ne 64 ]; then
        echo "error: Missing or invalid SHA256 digest in $digest_file"
        return 1
    fi
    if ! local_sum="$(sha256sum "$LOCAL_FILE")"; then
        echo "error: Could not calculate SHA256 for $LOCAL_FILE"
        return 1
    fi
    local_sum="${local_sum%% *}"
    if [ "$checksum" != "$local_sum" ]; then
        echo "error: SHA256 check failed for $LOCAL_FILE"
        return 1
    fi
    echo 'info: Local Xray archive passed SHA256 verification.'
}

check_local_xray_version() {
    if ! chmod u+x "$TMP_DIRECTORY/xray" || ! "$TMP_DIRECTORY/xray" -version >/dev/null 2>&1; then
        echo 'error: Local xray binary cannot run. Please check its architecture and format.'
        return 1
    fi
}

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

get_prerelease() {
    local releases_file="${TMP_DIRECTORY}releases.json"
    if ! curl -f -sSL -H 'Accept: application/vnd.github+json' -o "$releases_file" \
        'https://api.github.com/repos/XTLS/Xray-core/releases'; then
        echo 'error: Failed to get release list, please check your network.'
        return 1
    fi
    DOWNLOAD_LINK="$(awk -F '"' -v RS=',' -v archive="/Xray-linux-$MACHINE.zip" '
        !found {
            for (i = 1; i + 2 <= NF; i++) {
                url = $(i + 2)
                if ($i == "browser_download_url" &&
                    index(url, "https://github.com/XTLS/Xray-core/releases/download/") == 1 &&
                    substr(url, length(url) - length(archive) + 1) == archive) {
                    print url
                    found = 1
                    break
                }
            }
        }
    ' "$releases_file")"
    if [ -z "$DOWNLOAD_LINK" ]; then
        echo "error: No release archive found for Xray-linux-$MACHINE.zip."
        return 1
    fi
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
    local service
    XRAY_RUNNING="$(
        for service in /etc/init.d/xray /etc/init.d/xray.*; do
            [ -f "$service" ] || continue
            service="${service##*/}"
            if rc-service "$service" status >/dev/null 2>&1; then
                printf '%s\n' "$service"
            fi
        done
    )"
    if [ -n "$XRAY_RUNNING" ]; then
        manage_xray_services stop
    fi
}

manage_xray_services() {
    local action="$1" service
    printf '%s\n' "$XRAY_RUNNING" | while IFS= read -r service; do
        rc-service "$service" "$action"
    done
}

create_xray_user() {
    if ! grep -q '^xray:' /etc/group; then
        if [ -f /etc/gentoo-release ]; then
            groupadd -r xray
        else
            addgroup -S xray
        fi
    fi
    if ! id -u xray >/dev/null 2>&1; then
        if [ -f /etc/gentoo-release ]; then
            useradd -r -M -d /var/empty -s /bin/false -g xray xray
        else
            adduser -S -D -H -h /var/empty -s /bin/false -G xray xray
        fi
    fi
}

install_xray() {
    install -m 755 -o 0 -g 0 "${TMP_DIRECTORY}xray" "/usr/local/bin/xray"
    install -d -m 755 -o xray -g xray /usr/local/share/xray/
    install -m 644 -o xray -g xray "${TMP_DIRECTORY}geoip.dat" "/usr/local/share/xray/geoip.dat"
    install -m 644 -o xray -g xray "${TMP_DIRECTORY}geosite.dat" "/usr/local/share/xray/geosite.dat"
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
        install -d -m 700 -o xray -g xray /var/log/xray/
        install -m 600 -o xray -g xray /dev/null /var/log/xray/access.log
        install -m 600 -o xray -g xray /dev/null /var/log/xray/error.log
        LOG='1'
    else
        chown -hR xray:xray /var/log/xray/
        chmod 700 /var/log/xray/
    fi
}

install_with_logrotate() {
    install_dependencies logrotate
    install -d -m 755 /etc/logrotate.d
    cat >/etc/logrotate.d/xray <<'EOF'
/var/log/xray/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    copytruncate
}
EOF
    if [ -f /etc/alpine-release ]; then
        rc-update add crond default
        rc-service crond status >/dev/null 2>&1 || rc-service crond start
    fi
}

install_startup_service_file() {
    OPENRC='0'
    if [ ! -f '/etc/init.d/xray' ]; then
        mkdir "${TMP_DIRECTORY}init.d/"
        cat >"${TMP_DIRECTORY}init.d/xray" <<'EOF'
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
case "$RC_SVCNAME" in
xray.*)
	confdir=${confdir:-"/usr/local/etc/xray/${RC_SVCNAME#xray.}/"}
	;;
*)
	confdir=${confdir:-"/usr/local/etc/xray/"}
	;;
esac
command="/usr/local/bin/xray"
command_user="xray:xray"
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
        install -m 755 "${TMP_DIRECTORY}init.d/xray" /etc/init.d/xray
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
    if [ "$LOGROTATE" -eq '1' ]; then
        echo 'installed: /etc/logrotate.d/xray'
    fi
    rm -r "$TMP_DIRECTORY"
    echo "removed: $TMP_DIRECTORY"
    echo "You may need to execute a command to remove dependent software: $(pkg_manager del) curl unzip"
    if [ -n "$XRAY_RUNNING" ]; then
        manage_xray_services start
    else
        echo 'Please execute the command: rc-update add xray; rc-service xray start'
    fi
    echo "info: Xray is installed."
}

main() {
    judgment_parameters "$@"
    if [ "$HELP" -eq 1 ]; then
        show_help
        return 0
    fi
    check_distro
    check_if_running_as_root
    identify_architecture
    if [ -n "$LOCAL_FILE" ]; then
        verify_local_archive
        install_dependencies unzip
    else
        install_dependencies curl unzip
    fi
    if [ "$LOGROTATE" -eq '1' ]; then
        install_with_logrotate
    fi

    TMP_DIRECTORY="$(mktemp -d)"
    trap '"rm" -rf -- "$TMP_DIRECTORY" || :' EXIT
    TMP_DIRECTORY="${TMP_DIRECTORY}/"
    ZIP_FILE="${TMP_DIRECTORY}Xray-linux-$MACHINE.zip"
    DOWNLOAD_LINK="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$MACHINE.zip"

    if [ -n "$LOCAL_FILE" ]; then
        ZIP_FILE="$LOCAL_FILE"
    else
        if [ "$BETA" -eq '1' ]; then
            get_prerelease
        fi
        download_xray
        verification_xray
    fi
    decompression
    if [ -n "$LOCAL_FILE" ]; then
        check_local_xray_version
    fi
    create_xray_user
    is_it_running
    install_xray
    install_confdir
    install_log
    install_startup_service_file
    information
}

main "$@"
