SERVICE_NAME="udm-pro-system-monitor"
MONITOR_DIR="/mnt/data/udm-pro-system-monitor"

systemctl stop $SERVICE_NAME
systemctl disable $SERVICE_NAME

rm -f /etc/systemd/system/$SERVICE_NAME.service

rm -rf "$MONITOR_DIR"

# Reload systemd daemon
systemctl daemon-reload

echo "UDM Pro System Monitor uninstalled."
