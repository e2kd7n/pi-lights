# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Pure Bash LED controller for Raspberry Pi 4 with Cluster HAT. No build system — scripts run directly on the Pi via a systemd service.

## Running and Testing

```bash
# Manual mode testing (run on the Pi as root)
sudo /usr/local/bin/pi-led-controller.sh sleep
sudo /usr/local/bin/pi-led-controller.sh active
sudo /usr/local/bin/pi-led-controller.sh status

# Service management
sudo systemctl status pi-led-controller.service
sudo journalctl -u pi-led-controller.service -f

# Verify LED paths available on this Pi
ls /sys/class/leds/
```

## Architecture

Two scripts with distinct responsibilities:

- **pi-led-monitor.sh** — long-running daemon (started by systemd). Loops every `CHECK_INTERVAL=5` seconds, checks for active SSH sessions via `who | grep -c "pts/"`, then calls the controller with `sleep` or `active`.
- **pi-led-controller.sh** — stateless LED controller. Sets LED trigger modes via sysfs. Guards against redundant writes using `/var/run/pi-led-state`. Modes: `sleep`, `active`, `auto`, `status`.
- **pi-led-controller.service** — systemd unit. Runs the monitor as root, restarts on failure with a 10s delay. Hardcodes `/usr/local/bin/` for both scripts.

## Critical Non-Obvious Details

**LED sysfs paths (Pi 4)**
- Power LED: `/sys/class/leds/PWR/` — not `led0` or `power`
- Activity LED: `/sys/class/leds/ACT/` — not `led1` or `activity`
- Paths differ by Pi model — always verify with `ls /sys/class/leds/` before editing

**LED trigger sequencing**
- Set the trigger file *before* setting `delay_on`/`delay_off`
- `timer` trigger requires both delay files; setting one without the other has no effect
- SD card trigger is `mmc0`, not `mmc` or `disk`

**State file**
- `/var/run/pi-led-state` tracks current mode to skip unnecessary sysfs writes
- Must be in `/var/run/` — `/tmp/` may be cleared on some distros

**Lock file**
- `/var/run/pi-led-controller.lock` uses `flock` to prevent duplicate daemon instances
- Declared in the script but the lock is acquired in the monitor, not the controller

**Installation**
- Scripts must be copied to `/usr/local/bin/` — that path is hardcoded in the service file
- Service file belongs in `/etc/systemd/system/`, not `/lib/systemd/system/`
- All LED sysfs files require root

## Cluster HAT Integration

`clusterhat led on/off` controls the orange indicator LEDs on the HAT board. `clusterhat act on/off` controls the green ACT LEDs on the Pi Zero boards — this requires a ClusterCTRL device (CBRIDGE qualifies). Both commands are called from `set_sleep_mode()` and `set_active_mode()` with `2>/dev/null || true` so failures don't break the Pi 4 LED transitions.

## Customization Points

- `CHECK_INTERVAL` in [pi-led-monitor.sh](pi-led-monitor.sh) — how often SSH sessions are polled
- Sleep mode uses the `heartbeat` kernel trigger on PWR — no delay files needed
- `set_sleep_mode()` and `set_active_mode()` in [pi-led-controller.sh](pi-led-controller.sh) — LED trigger logic
