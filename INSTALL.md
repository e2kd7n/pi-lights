# Raspberry Pi LED Controller Installation Guide

This solution dims your Raspberry Pi 4 and Cluster HAT LEDs at night while automatically brightening them when SSH sessions are active.

## Features

- **Sleep Mode**: Dim LEDs with subtle heartbeat pattern (50ms on, 2950ms off)
- **Active Mode**: Bright LEDs when SSH sessions are detected
- **Automatic Switching**: Monitors SSH sessions every 5 seconds
- **Systemd Integration**: Runs as a background service

## Installation Steps

### 1. Copy Files to Raspberry Pi

Transfer these files to your Raspberry Pi:
- `pi-led-controller.sh` - Main LED control script
- `pi-led-monitor.sh` - Monitoring daemon
- `pi-led-controller.service` - Systemd service file

### 2. Install Scripts

```bash
# Make scripts executable
chmod +x pi-led-controller.sh pi-led-monitor.sh

# Copy scripts to system location
sudo cp pi-led-controller.sh /usr/local/bin/
sudo cp pi-led-monitor.sh /usr/local/bin/

# Copy service file
sudo cp pi-led-controller.service /etc/systemd/system/
```

### 3. Enable and Start Service

```bash
# Reload systemd to recognize new service
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable pi-led-controller.service

# Start the service now
sudo systemctl start pi-led-controller.service
```

### 4. Verify Installation

```bash
# Check service status
sudo systemctl status pi-led-controller.service

# Check current LED mode
sudo /usr/local/bin/pi-led-controller.sh status
```

## Manual Control

You can manually control the LEDs:

```bash
# Set to sleep mode (dim)
sudo /usr/local/bin/pi-led-controller.sh sleep

# Set to active mode (bright)
sudo /usr/local/bin/pi-led-controller.sh active

# Return to automatic mode
sudo systemctl restart pi-led-controller.service
```

## Customization

### Adjust Brightness Levels

Edit `/usr/local/bin/pi-led-controller.sh` and modify these values in the `set_sleep_mode()` function:

```bash
echo 50 > /sys/class/leds/PWR/delay_on      # LED on time (ms)
echo 2950 > /sys/class/leds/PWR/delay_off   # LED off time (ms)
```

- Lower `delay_on` = dimmer LED
- Higher `delay_off` = less frequent blinking

### Adjust Check Interval

Edit `/usr/local/bin/pi-led-monitor.sh` and change:

```bash
CHECK_INTERVAL=5  # Check every 5 seconds
```

After making changes, restart the service:

```bash
sudo systemctl restart pi-led-controller.service
```

## Troubleshooting

### LEDs Not Changing

1. Check if service is running:
   ```bash
   sudo systemctl status pi-led-controller.service
   ```

2. Check logs:
   ```bash
   sudo journalctl -u pi-led-controller.service -f
   ```

3. Verify LED paths exist:
   ```bash
   ls -l /sys/class/leds/
   ```

### Service Won't Start

1. Check script permissions:
   ```bash
   ls -l /usr/local/bin/pi-led-*.sh
   ```

2. Verify scripts are executable:
   ```bash
   sudo chmod +x /usr/local/bin/pi-led-controller.sh
   sudo chmod +x /usr/local/bin/pi-led-monitor.sh
   ```

### Different LED Names

If your Pi has different LED names, check available LEDs:

```bash
ls /sys/class/leds/
```

Then update the LED paths in `pi-led-controller.sh`:
```bash
PWR_LED="/sys/class/leds/YOUR_LED_NAME/brightness"
```

## Uninstallation

```bash
# Stop and disable service
sudo systemctl stop pi-led-controller.service
sudo systemctl disable pi-led-controller.service

# Remove files
sudo rm /etc/systemd/system/pi-led-controller.service
sudo rm /usr/local/bin/pi-led-controller.sh
sudo rm /usr/local/bin/pi-led-monitor.sh
sudo rm /var/run/pi-led-state

# Reload systemd
sudo systemctl daemon-reload

# Reset LEDs to default
echo "default-on" | sudo tee /sys/class/leds/PWR/trigger
echo "mmc0" | sudo tee /sys/class/leds/ACT/trigger
```

## Notes

- The service runs as root to access LED control files
- LED changes are immediate and don't require a reboot
- The Cluster HAT Pi Zeros may have their own LED controls
- Sleep mode uses a slow heartbeat pattern to indicate the system is alive
- Active mode shows normal disk activity on the ACT LED

## Support

For Raspberry Pi 4 specific LED information:
- Power LED: `/sys/class/leds/PWR/`
- Activity LED: `/sys/class/leds/ACT/`

Common trigger modes:
- `none` - Manual control
- `default-on` - Always on
- `timer` - Blinking pattern
- `heartbeat` - Heartbeat pattern
- `mmc0` - SD card activity