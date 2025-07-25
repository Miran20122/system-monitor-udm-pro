# UDM Pro System Monitor

This is a custom system monitoring script for the Ubiquiti Dream Machine Pro (UDM Pro). It periodically checks CPU, memory, disk usage, and temperature, and sends notifications to all admins via the UniFi Controller's notification system if any metric exceeds critical thresholds.

---

## Features

- Monitors CPU, memory, disk usage, and temperature.
- Sends notifications via UniFi Controller API.
- Runs persistently as a systemd service.
- Easy install and uninstall scripts included.

---

## 📦 Installation

1. SSH into your UDM Pro.
2. Run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/Miran20122/set-fan-speed-udm/main/install.sh | sh
```

---

## 📦 Uninstallation

1. SSH into your UDM Pro.
2. Run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/Miran20122/set-fan-speed-udm/main/uninstall.sh | sh
```

---

## Notes

- The script requires `curl` and `sensors` commands to be available on the UDM Pro.
- Adjust thresholds in `monitor.sh` as needed.

---

## Disclaimer

Use this script at your own risk. It is provided as-is without warranty.
