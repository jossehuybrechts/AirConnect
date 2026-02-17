#!/bin/bash

# AirConnect Proxmox VE Helper Script
# This script is intended to be run on the Proxmox Host (PVE Node).
# It creates or configures an LXC container and installs AirConnect via Docker Compose.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}AirConnect Proxmox LXC Installer${NC}"
echo "------------------------------------------"

# Check if running on Proxmox
if [ ! -f /etc/pve/.version ]; then
    echo -e "${RED}This script must be run on a Proxmox VE Host.${NC}"
    exit 1
fi

# Ask for VMID
NEXTID=$(pvesh get /cluster/nextid)
read -p "Enter VMID for the new container [default: $NEXTID]: " VMID
VMID=${VMID:-$NEXTID}

# Check if VMID exists
if pct status $VMID &>/dev/null; then
    echo -e "${YELLOW}Container $VMID already exists.${NC}"
    read -p "Do you want to configure this existing container for AirConnect? (y/n) " CONF_EXIST
    if [[ ! $CONF_EXIST =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    # Create new container
    read -p "Enter hostname [default: airconnect]: " HOSTNAME
    HOSTNAME=${HOSTNAME:-airconnect}

    echo -e "${YELLOW}Selecting template...${NC}"
    # Try to find a Debian 12 template
    TEMPLATE=$(pveam list local | grep "debian-12" | head -n 1 | awk '{print $1}')

    if [ -z "$TEMPLATE" ]; then
        echo -e "${YELLOW}Debian 12 template not found locally. Downloading...${NC}"
        pveam update
        TEMPLATE_NAME=$(pveam available | grep "debian-12-standard" | head -n 1 | awk '{print $2}')
        pveam download local "$TEMPLATE_NAME"
        TEMPLATE="local:vztmpl/$TEMPLATE_NAME"
    fi

    echo -e "${YELLOW}Creating container $VMID ($HOSTNAME) using $TEMPLATE...${NC}"

    # Try to detect storage
    STORAGE=$(pvesm status -content rootdir | grep "active" | awk '{print $1}' | head -n 1)
    STORAGE=${STORAGE:-local-lvm}

    pct create $VMID "$TEMPLATE" --hostname "$HOSTNAME" --net0 name=eth0,bridge=vmbr0,ip=dhcp --storage "$STORAGE" --password airconnect --unprivileged 1
    echo -e "${GREEN}Container created successfully on storage: $STORAGE${NC}"
fi

# Configure features for Docker
echo -e "${YELLOW}Configuring container features (nesting=1, keyctl=1)...${NC}"
pct set $VMID -features nesting=1,keyctl=1

# Start container
echo -e "${YELLOW}Starting container...${NC}"
pct start $VMID || true
sleep 5

# Install AirConnect inside LXC
echo -e "${YELLOW}Running AirConnect installer inside container...${NC}"
pct exec $VMID -- bash -c "$(curl -sSL https://raw.githubusercontent.com/jossehuybrechts/AirConnect/master/scripts/install-proxmox.sh)"

echo "------------------------------------------"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "AirConnect is now running in LXC $VMID."
echo -e "You can access the container console with: ${NC}pct console $VMID${NC}"
