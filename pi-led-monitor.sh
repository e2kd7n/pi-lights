#!/bin/bash
# LED Monitor Daemon
# Continuously monitors SSH sessions and adjusts LED brightness

LED_CONTROLLER="/usr/local/bin/pi-led-controller.sh"
CHECK_INTERVAL=5  # Check every 5 seconds

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

# Made with Bob
