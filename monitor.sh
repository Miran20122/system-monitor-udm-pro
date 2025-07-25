UNIFI_CONTROLLER=$(ip route | grep default | awk '{print $3}' | xargs -I{} echo "https://{}")
UNIFI_USER=$(cat /mnt/data/unifi-os/unifi-core/config/unifi-core.env 2>/dev/null | grep '^UNIFI_USERNAME=' | cut -d'=' -f2)
UNIFI_PASS=$(cat /mnt/data/unifi-os/unifi-core/config/unifi-core.env 2>/dev/null | grep '^UNIFI_PASSWORD=' | cut -d'=' -f2)
CHECK_INTERVAL=500
LOGFILE="/var/log/udm-pro-system-monitor.log"

CPU_HIGH=90
CPU_LOW=5
MEM_HIGH=90
MEM_LOW=5
DISK_HIGH=90
DISK_LOW=0
TEMP_HIGH=50
TEMP_LOW=5

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOGFILE"
}

send_notification() {
    local message="$1"
    if [ -z "$UNIFI_USER" ] || [ -z "$UNIFI_PASS" ]; then
        log "UniFi credentials not found"
        return 1
    fi
    COOKIE=$(curl -k -s -c - -d "{\"username\":\"$UNIFI_USER\",\"password\":\"$UNIFI_PASS\"}" -H "Content-Type: application/json" "$UNIFI_CONTROLLER/api/login" | grep -o 'unifises')
    if [ -z "$COOKIE" ]; then
        log "Failed to login to UniFi Controller"
        return 1
    fi

    if [ -z "$SITE" ]; then
        SITE=$(curl -k -s -b "unifises=$COOKIE" "$UNIFI_CONTROLLER/api/self/sites" | grep -oP '(?<="name":")[^"]+')
    fi

    curl -k -s -b "unifises=$COOKIE" -X POST -H "Content-Type: application/json" \
        -d "{\"cmd\":\"send_notification\",\"msg\":\"$message\"}" \
        "$UNIFI_CONTROLLER/api/s/$SITE/cmd/notify" >/dev/null 2>&1

    log "Notification sent: $message"
}

get_cpu_usage() {
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d'.' -f1)
    CPU_USAGE=$((100 - CPU_IDLE))
    echo "$CPU_USAGE"
}

get_mem_usage() {
    MEM_TOTAL=$(free | grep Mem | awk '{print $2}')
    MEM_USED=$(free | grep Mem | awk '{print $3}')
    MEM_USAGE=$((MEM_USED * 100 / MEM_TOTAL))
    echo "$MEM_USAGE"
}

get_disk_usage() {
    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "$DISK_USAGE"
}

get_temp() {
    if command -v sensors >/dev/null 2>&1; then
        TEMP=$(sensors | grep -m1 'temp1' | awk '{print $2}' | tr -d '+°C')
        echo "$TEMP"
    else
        echo "N/A"
    fi
}

while true; do
    CPU=$(get_cpu_usage)
    MEM=$(get_mem_usage)
    DISK=$(get_disk_usage)
    TEMP=$(get_temp)

    log "CPU: $CPU%, MEM: $MEM%, DISK: $DISK%, TEMP: $TEMP"

    ALERTS=""

    if [ "$CPU" -ge "$CPU_HIGH" ]; then
        ALERTS="$ALERTS CPU usage high: $CPU%"
    elif [ "$CPU" -le "$CPU_LOW" ]; then
        ALERTS="$ALERTS CPU usage low: $CPU%"
    fi

    if [ "$MEM" -ge "$MEM_HIGH" ]; then
        ALERTS="$ALERTS Memory usage high: $MEM%"
    elif [ "$MEM" -le "$MEM_LOW" ]; then
        ALERTS="$ALERTS Memory usage low: $MEM%"
    fi

    if [ "$DISK" -ge "$DISK_HIGH" ]; then
        ALERTS="$ALERTS Disk usage high: $DISK%"
    elif [ "$DISK" -le "$DISK_LOW" ]; then
        ALERTS="$ALERTS Disk usage low: $DISK%"
    fi

    if [ "$TEMP" != "N/A" ]; then
        if [ "$TEMP" -ge "$TEMP_HIGH" ]; then
            ALERTS="$ALERTS Temperature high: $TEMP°C"
        elif [ "$TEMP" -le "$TEMP_LOW" ]; then
            ALERTS="$ALERTS Temperature low: $TEMP°C"
        fi
    fi

    if [ ! -z "$ALERTS" ]; then
        send_notification "$ALERTS"
    fi

    sleep "$CHECK_INTERVAL"
done