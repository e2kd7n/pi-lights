#!/bin/bash
# LED Monitor Daemon
# Continuously monitors SSH sessions and adjusts LED brightness

LED_CONTROLLER="/usr/local/bin/pi-led-controller.sh"
CHECK_INTERVAL=5  # Check every 5 seconds
MONITOR_LOCK="/var/run/pi-led-monitor.lock"

# Ensure only one monitor daemon runs at a time
exec 9>"$MONITOR_LOCK"
if ! flock -n 9; then
    echo "LED monitor already running ($(cat $MONITOR_LOCK 2>/dev/null)). Exiting."
    exit 1
fi
echo $$ >&9

echo "Starting LED monitor daemon..."

# Initialize to sleep mode
$LED_CONTROLLER sleep

# Main monitoring loop
while true; do
    # Run auto mode to check SSH sessions and adjust LEDs
    $LED_CONTROLLER auto
    
    # Wait before next check
    sleep $CHECK_INTERVAL
done

