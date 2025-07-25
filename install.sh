MONITOR_DIR="/mnt/data/udm-pro-system-monitor"
SERVICE_NAME="udm-pro-system-monitor"

mkdir -p "$MONITOR_DIR"
cp -r ./udm-pro-system-monitor/* "$MONITOR_DIR"

cat <<EOF > /etc/systemd/system/$SERVICE_NAME.service
[Unit]
Description=UDM Pro System Monitor Service
After=network.target

[Service]
ExecStart=$MONITOR_DIR/monitor.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME

echo "UDM Pro System Monitor installed and started."
