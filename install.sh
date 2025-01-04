#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing CyberPAM Agent...${NC}"

# Get system information
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture names
case ${ARCH} in
    x86_64)
        ARCH="amd64"
        ;;
    arm64|aarch64)
        ARCH="arm64"
        ;;
    *)
        echo -e "${RED}Unsupported architecture: ${ARCH}${NC}"
        exit 1
        ;;
esac

# Set binary name based on OS
BINARY_NAME="cyberpamagent-${OS}-${ARCH}"
if [ "${OS}" = "darwin" ]; then
    BINARY_NAME="cyberpamagent-darwin-${ARCH}"
elif [ "${OS}" = "linux" ]; then
    BINARY_NAME="cyberpamagent-linux-${ARCH}"
fi

# GitHub raw URL
DOWNLOAD_URL="https://raw.githubusercontent.com/RamboRogers/cyberpamagent/master/bins/${BINARY_NAME}"

echo -e "${BLUE}Downloading CyberPAM Agent for ${OS} ${ARCH}...${NC}"
echo -e "${BLUE}Download URL: ${DOWNLOAD_URL}${NC}"

# Create temporary directory
TMP_DIR=$(mktemp -d)
cd ${TMP_DIR}

# Download binary with error checking
HTTP_RESPONSE=$(curl -L -w "%{http_code}" -o cyberpamagent "${DOWNLOAD_URL}" 2>/dev/null)
if [ "${HTTP_RESPONSE}" != "200" ]; then
    echo -e "${RED}Failed to download CyberPAM Agent - HTTP Status: ${HTTP_RESPONSE}${NC}"
    echo -e "${RED}URL: ${DOWNLOAD_URL}${NC}"
    echo -e "${RED}Please check if the binary exists in the repository${NC}"
    rm -rf ${TMP_DIR}
    exit 1
fi

# Verify file was downloaded and has content
if [ ! -s cyberpamagent ]; then
    echo -e "${RED}Downloaded file is empty${NC}"
    rm -rf ${TMP_DIR}
    exit 1
fi

# Make binary executable
chmod +x cyberpamagent

# Move binary to /usr/local/bin
echo -e "${BLUE}Installing CyberPAM Agent to /usr/local/bin...${NC}"
if ! sudo mv cyberpamagent /usr/local/bin/cyberpamagent; then
    echo -e "${RED}Failed to install CyberPAM Agent. Please run with sudo.${NC}"
    rm -rf ${TMP_DIR}
    exit 1
fi

# Clean up
rm -rf ${TMP_DIR}

echo -e "${GREEN}CyberPAM Agent installed successfully!${NC}"
echo -e "${BLUE}Starting interactive setup...${NC}"

# Run the program in interactive mode
/usr/local/bin/cyberpamagent
