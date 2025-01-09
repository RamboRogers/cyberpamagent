#!/bin/sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing CyberPAM Agent...${NC}"

# Function to check if we have root privileges
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
            echo -e "${BLUE}Requesting sudo privileges...${NC}"
            return 1
        elif command -v doas >/dev/null 2>&1; then
            echo -e "${BLUE}Requesting doas privileges...${NC}"
            return 2
        else
            echo -e "${RED}This script must be run as root${NC}"
            exit 1
        fi
    fi
    return 0
}

# Function to handle privileged commands
elevate_cmd() {
    if check_root; then
        "$@"
    else
        if command -v sudo >/dev/null 2>&1; then
            sudo "$@"
        else
            doas "$@"
        fi
    fi
}

# Ensure /usr/local/bin exists
ensure_install_dir() {
    if [ ! -d "/usr/local/bin" ]; then
        echo -e "${BLUE}Creating /usr/local/bin directory...${NC}"
        elevate_cmd mkdir -p /usr/local/bin
    fi
}

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
cd "${TMP_DIR}" || exit 1

# Download binary with error checking
if command -v curl >/dev/null 2>&1; then
    HTTP_RESPONSE=$(curl -L -w "%{http_code}" -o cyberpamagent "${DOWNLOAD_URL}" 2>/dev/null)
elif command -v wget >/dev/null 2>&1; then
    wget -q -O cyberpamagent "${DOWNLOAD_URL}"
    HTTP_RESPONSE=$?
else
    echo -e "${RED}Neither curl nor wget found. Please install one of them.${NC}"
    rm -rf "${TMP_DIR}"
    exit 1
fi

# Verify download success
if [ ! -s cyberpamagent ]; then
    echo -e "${RED}Failed to download CyberPAM Agent${NC}"
    echo -e "${RED}URL: ${DOWNLOAD_URL}${NC}"
    rm -rf "${TMP_DIR}"
    exit 1
fi

# Make binary executable
chmod +x cyberpamagent

# Ensure install directory exists
ensure_install_dir

# Move binary to /usr/local/bin
echo -e "${BLUE}Installing CyberPAM Agent to /usr/local/bin...${NC}"
if ! elevate_cmd mv cyberpamagent /usr/local/bin/cyberpamagent; then
    echo -e "${RED}Failed to install CyberPAM Agent${NC}"
    rm -rf "${TMP_DIR}"
    exit 1
fi

# Clean up
rm -rf "${TMP_DIR}"

echo -e "${GREEN}CyberPAM Agent installed successfully!${NC}"
echo -e "${BLUE}Starting interactive setup...${NC}"

# Run the program in interactive mode
if check_root; then
    /usr/local/bin/cyberpamagent < /dev/tty
else
    if command -v sudo >/dev/null 2>&1; then
        sudo /usr/local/bin/cyberpamagent < /dev/tty
    else
        doas /usr/local/bin/cyberpamagent < /dev/tty
    fi
fi
