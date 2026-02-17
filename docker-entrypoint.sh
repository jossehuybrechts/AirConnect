#!/bin/bash

# Default values if not set
AIRUPNP_VAR=${AIRUPNP_VAR:-"-l 1000:2000"}
AIRCAST_VAR=${AIRCAST_VAR:-""}

echo "Starting AirConnect..."

# Function to handle shutdown
cleanup() {
    echo "Stopping AirConnect..."
    pkill airupnp
    pkill aircast
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start airupnp if not killed
if [ "$AIRUPNP_VAR" != "kill" ]; then
    echo "Launching airupnp with options: $AIRUPNP_VAR"
    # Use -Z for non-interactive mode
    /usr/bin/airupnp -Z $AIRUPNP_VAR &
fi

# Start aircast if not killed
if [ "$AIRCAST_VAR" != "kill" ]; then
    echo "Launching aircast with options: $AIRCAST_VAR"
    # Use -Z for non-interactive mode
    /usr/bin/aircast -Z $AIRCAST_VAR &
fi

# Keep container running
wait -n
