# CyberPAM Agent

A command-line installer for cloudflared with cross-platform support.

## Features

- Cross-platform support (Linux, macOS, Windows)
- Automatic system detection
- Secure installation with checksum verification
- Service management (install, configure, start, stop, status)

## Requirements

- Internet connection for downloading cloudflared

## Usage

```bash
# Install cloudflared
./cyberpamagent -install

# Configure with your tunnel token
./cyberpamagent -token "your-token-here"

# Check service status
./cyberpamagent -status

# Start the service
./cyberpamagent -start

# Stop the service
./cyberpamagent -stop

# View service logs
./cyberpamagent -logs

# Uninstall cloudflared
./cyberpamagent -uninstall
```

## Building and Distribution

### Building All Platforms

To build binaries for all supported platforms:

```bash
# Make the build script executable
chmod +x build.sh

# Run the build script
./build.sh
```

This will create binaries in the `bins/cyberpamagent/bins` directory:
- `cyberpamagent.exe` (Windows amd64)
- `cyberpamagent-linux-amd64` (Linux amd64)
- `cyberpamagent-linux-arm64` (Linux arm64)
- `cyberpamagent-darwin-amd64` (macOS Intel)
- `cyberpamagent-darwin-arm64` (macOS Apple Silicon)

A `checksums.txt` file will also be generated containing SHA-256 checksums for all binaries.

### Testing

To test the binary for your current platform:

```bash
# Make the test script executable
chmod +x test.sh

# Run the test script with your token
CLOUDFLARE_TOKEN="your-token-here" ./test.sh
```

## Supported Platforms

- Linux (amd64, arm64)
  - Debian/Ubuntu: .deb package
  - RHEL/CentOS: .rpm package
  - Others: direct binary
- macOS (amd64, arm64)
  - Intel and Apple Silicon
  - Uses .pkg installer
- Windows (amd64)
  - Uses Windows Service

## Development

To modify or contribute to the project:

1. Install Go 1.21 or later
2. Clone the repository
3. Install dependencies: `go mod tidy`
4. Make your changes
5. Build and test: `go build && ./cyberpamagent`

## License

MIT License