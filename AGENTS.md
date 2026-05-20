# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Project Overview
Bash scripts for Raspberry Pi 4 LED control with Cluster HAT - no build system, runs directly on Pi.

## Critical Non-Obvious Details

### LED Control Paths (Pi 4 Specific)
- Power LED: `/sys/class/leds/PWR/` (not `led0` or `power`)
- Activity LED: `/sys/class/leds/ACT/` (not `led1` or `activity`)
- These paths may differ on Pi 3/Zero - always verify with `ls /sys/class/leds/`

### State Management
- State file: `/var/run/pi-led-state` (not `/tmp/` - must survive temp cleanup)
- Lock file: `/var/run/pi-led-controller.lock` (declared but not used in current implementation)
- State file prevents unnecessary LED trigger changes (reduces sysfs writes)

### SSH Detection Method
- Uses `who | grep -c "pts/"` to count SSH sessions
- Counts pseudo-terminals (pts), not just SSH processes
- This catches SSH sessions but may miss other remote connections

### LED Trigger Modes
- `heartbeat` trigger drives the PWR LED pulse in sleep mode — no delay files needed
- `timer` trigger (not currently used) requires both `delay_on` and `delay_off` files; must set trigger before delay values
- `mmc0` trigger is SD card activity (not `mmc` or `disk`)

### Cluster HAT Integration
- `clusterhat led on/off` controls the orange indicator LEDs on the HAT board
- `clusterhat act on/off` controls the green ACT LEDs on the Pi Zero boards (requires ClusterCTRL device — CBRIDGE qualifies)
- Both commands use `2>/dev/null || true` so failures don't interrupt Pi 4 LED transitions
- These only run on mode transitions, not every poll cycle

### Service Behavior
- Service runs `pi-led-monitor.sh`, NOT `pi-led-controller.sh` directly
- Monitor script calls controller with `auto` mode every 5 seconds
- No graceful shutdown - LEDs stay in last state on service stop

### Installation Gotchas
- Scripts must be in `/usr/local/bin/` (hardcoded path in service file)
- Service file must be in `/etc/systemd/system/` (not `/lib/systemd/system/`)
- Requires root - LED sysfs files are root-only on Raspberry Pi OS

## Testing
```bash
# Manual mode testing (bypasses service)
sudo /usr/local/bin/pi-led-controller.sh sleep
sudo /usr/local/bin/pi-led-controller.sh active
sudo /usr/local/bin/pi-led-controller.sh status

# Service testing
sudo systemctl status pi-led-controller.service
sudo journalctl -u pi-led-controller.service -f
```

## Customization Points
- `CHECK_INTERVAL=5` in pi-led-monitor.sh (SSH check frequency)
- `set_sleep_mode()` and `set_active_mode()` in pi-led-controller.sh (LED trigger logic and Cluster HAT commands)
