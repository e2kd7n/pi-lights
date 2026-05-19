# Raspberry Pi Cluster LED Controller

A smart LED controller for Raspberry Pi 4 with Cluster HAT that automatically dims LEDs at night and brightens them during SSH sessions.

## Quick Overview

This solution provides:

- 🌙 **Sleep Mode**: Dim LEDs with subtle heartbeat (appears "asleep")
- 💻 **Active Mode**: Bright LEDs when SSH sessions are active
- 🔄 **Auto-Switching**: Detects SSH sessions and adjusts automatically
- ⚙️ **Systemd Service**: Runs automatically on boot

## What It Does

### Sleep Mode (Default)
- Power LED: Very dim heartbeat pattern (50ms on, 2950ms off)
- Activity LED: Only shows disk activity
- Perfect for nighttime - minimal light pollution

### Active Mode (SSH Connected)
- Power LED: Solid on
- Activity LED: Shows all disk activity
- Automatically activates when you SSH into the Pi
- Returns to sleep mode 5 seconds after last SSH session ends

## Files Included

1. **pi-led-controller.sh** - Main control script with sleep/active/auto modes
2. **pi-led-monitor.sh** - Background daemon that monitors SSH sessions
3. **pi-led-controller.service** - Systemd service for automatic startup
4. **INSTALL.md** - Detailed installation and configuration guide

## Quick Start

```bash
# 1. Make scripts executable
chmod +x pi-led-controller.sh pi-led-monitor.sh

# 2. Install to system
sudo cp pi-led-controller.sh /usr/local/bin/
sudo cp pi-led-monitor.sh /usr/local/bin/
sudo cp pi-led-controller.service /etc/systemd/system/

# 3. Enable and start
sudo systemctl daemon-reload
sudo systemctl enable pi-led-controller.service
sudo systemctl start pi-led-controller.service

# 4. Check status
sudo systemctl status pi-led-controller.service
```

## Testing

```bash
# Check current mode
sudo /usr/local/bin/pi-led-controller.sh status

# Manually test sleep mode
sudo /usr/local/bin/pi-led-controller.sh sleep

# Manually test active mode
sudo /usr/local/bin/pi-led-controller.sh active

# SSH into your Pi from another terminal
# LEDs should automatically brighten within 5 seconds

# Exit SSH session
# LEDs should dim again within 5 seconds
```

## Customization

See [INSTALL.md](INSTALL.md) for detailed customization options including:
- Adjusting brightness levels
- Changing check intervals
- Modifying LED patterns
- Troubleshooting tips

## How It Works

1. **Service starts on boot** and runs `pi-led-monitor.sh`
2. **Monitor checks every 5 seconds** for active SSH sessions using `who` command
3. **When SSH detected**: Switches to active mode (bright LEDs)
4. **When no SSH**: Switches to sleep mode (dim LEDs)
5. **State is tracked** in `/var/run/pi-led-state` to avoid unnecessary changes

## Compatibility

- ✅ Raspberry Pi 4 (tested)
- ✅ Raspberry Pi 3 B+ (should work)
- ✅ Cluster HAT compatible
- ⚠️ Pi Zero W LEDs controlled separately (may need additional configuration)

## Notes

- Requires root access to control LEDs
- Changes are immediate (no reboot needed)
- Service automatically restarts if it crashes
- LED paths may vary on different Pi models

## License

Free to use and modify for personal and commercial projects.

## Support

For detailed installation instructions, troubleshooting, and customization options, see [INSTALL.md](INSTALL.md).