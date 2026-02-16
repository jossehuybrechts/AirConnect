#!/bin/bash

# AirConnect Docker Compose Installation Script (optimized for Proxmox LXC)
# This script installs Docker, Docker Compose, and sets up AirConnect.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}AirConnect Docker Compose Installer${NC}"
echo "------------------------------------------"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root (use sudo)${NC}"
  exit 1
fi

# Proxmox LXC Check
if [ -f /proc/1/environ ] && grep -q "container=lxc" /proc/1/environ; then
    echo -e "${YELLOW}LXC container detected.${NC}"
    echo -e "IMPORTANT: Make sure this LXC has 'nesting=1' and 'keyctl=1' enabled in Proxmox."
    echo -e "You can set this in Proxmox Host Shell: ${NC}pct set <CT_ID> -features nesting=1,keyctl=1${NC}"
    echo ""
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS="unknown"
fi

# Install Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker not found. Installing...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    echo -e "${GREEN}Docker installed successfully.${NC}"
else
    echo -e "${GREEN}Docker is already installed.${NC}"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${YELLOW}Docker Compose not found. Installing...${NC}"
    if [ "$OS" = "debian" ] || [ "$OS" = "ubuntu" ]; then
        apt-get update
        apt-get install -y docker-compose-plugin || apt-get install -y docker-compose
    else
        # Fallback for other distros
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
    echo -e "${GREEN}Docker Compose installed successfully.${NC}"
else
    echo -e "${GREEN}Docker Compose is already installed.${NC}"
fi

# Create directory for AirConnect and docker-compose.yml
if [ ! -f docker-compose.yml ]; then
    echo -e "${YELLOW}Creating airconnect directory and docker-compose.yml...${NC}"
    mkdir -p airconnect
    cd airconnect

    cat <<EOF > docker-compose.yml
services:
  airconnect:
    image: 1activegeek/airconnect:latest
    container_name: airconnect
    network_mode: host
    restart: unless-stopped
    # Environment variables to configure the bridges
    environment:
      - AIRUPNP_VAR=-l 1000:2000
      # To disable one of the services, set its variable to 'kill'
      # - AIRUPNP_VAR=kill
      # - AIRCAST_VAR=kill
EOF
fi

# Start AirConnect
echo -e "${YELLOW}Starting AirConnect with Docker Compose...${NC}"
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

echo "------------------------------------------"
echo -e "${GREEN}AirConnect is now running!${NC}"
echo -e "You can check logs with: ${NC}docker compose logs -f${NC}"
echo -e "Or: ${NC}docker-compose logs -f${NC}"
