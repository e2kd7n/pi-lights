#!/bin/bash
# Raspberry Pi LED Controller for Cluster HAT
# Controls LED brightness based on activity and time

# LED paths for Raspberry Pi 4
PWR_LED="/sys/class/leds/PWR/brightness"
ACT_LED="/sys/class/leds/ACT/brightness"
PWR_TRIGGER="/sys/class/leds/PWR/trigger"
ACT_TRIGGER="/sys/class/leds/ACT/trigger"

# State file to track current mode
STATE_FILE="/var/run/pi-led-state"
LOCK_FILE="/var/run/pi-led-controller.lock"

# LED modes
MODE_SLEEP="sleep"
MODE_ACTIVE="active"

# Function to set LED to sleep mode (dim)
set_sleep_mode() {
    echo "Setting LEDs to sleep mode"

    if [ -f "$PWR_TRIGGER" ]; then
        echo "heartbeat" > "$PWR_TRIGGER"
    fi

    if [ -f "$ACT_TRIGGER" ]; then
        echo "mmc0" > "$ACT_TRIGGER"
    fi

    clusterhat led off 2>/dev/null || true
    clusterhat act off 2>/dev/null || true

    echo "$MODE_SLEEP" > "$STATE_FILE"
}

# Function to set LED to active mode (bright)
set_active_mode() {
    echo "Setting LEDs to active mode"

    if [ -f "$PWR_TRIGGER" ]; then
        echo "default-on" > "$PWR_TRIGGER"
    fi

    if [ -f "$ACT_TRIGGER" ]; then
        echo "mmc0" > "$ACT_TRIGGER"
    fi

    clusterhat led on 2>/dev/null || true
    clusterhat act on 2>/dev/null || true

    echo "$MODE_ACTIVE" > "$STATE_FILE"
}

# Function to get current mode
get_current_mode() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "$MODE_SLEEP"
    fi
}

# Function to check if SSH sessions are active
check_ssh_sessions() {
    # Count active SSH sessions (excluding the current script)
    local ssh_count=$(who | grep -c "pts/")
    echo "$ssh_count"
}

# Serialize concurrent controller invocations
exec 9>"$LOCK_FILE"
if ! flock -w 2 9; then
    echo "Could not acquire lock — another instance is running" >&2
    exit 1
fi

# Main control logic
case "$1" in
    sleep)
        set_sleep_mode
        ;;
    active)
        set_active_mode
        ;;
    auto)
        # Automatic mode based on SSH sessions
        ssh_sessions=$(check_ssh_sessions)
        current_mode=$(get_current_mode)
        
        if [ "$ssh_sessions" -gt 0 ]; then
            if [ "$current_mode" != "$MODE_ACTIVE" ]; then
                set_active_mode
            fi
        else
            if [ "$current_mode" != "$MODE_SLEEP" ]; then
                set_sleep_mode
            fi
        fi
        ;;
    status)
        echo "Current mode: $(get_current_mode)"
        echo "Active SSH sessions: $(check_ssh_sessions)"
        ;;
    *)
        echo "Usage: $0 {sleep|active|auto|status}"
        echo "  sleep  - Set LEDs to dim/sleep mode"
        echo "  active - Set LEDs to bright/active mode"
        echo "  auto   - Automatically switch based on SSH sessions"
        echo "  status - Show current status"
        exit 1
        ;;
esac

exit 0

# Made with Bob
