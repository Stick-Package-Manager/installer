<div align="center">
  
<a href="https://github.com/Stick-Package-Manager/installer/blob/43abba602c94e92108e37dbfd6ee61475ec64505/branding.png" target="_blank" rel="noopener">
  <img src="https://github.com/Stick-Package-Manager/installer/blob/43abba602c94e92108e37dbfd6ee61475ec64505/branding.png" width="100" height="100" alt="Stick Installer logo">

  
# Stick Universal Installer

The official installation script for Stick Package Manager and related tools. This script provides an interactive, user-friendly way to install Stick, Stick Lite, and Stickfetch on Arch Linux and Arch-based distributions.
</div>


## Features

- **Interactive Menu** - Choose exactly what you want to install
- **Automatic Dependency Detection** - Checks and installs missing dependencies
- **Smart V Compiler Installation** - Automatically installs V if not present
- **Internet Connectivity Check** - Validates network before starting
- **Comprehensive Logging** - All operations logged for troubleshooting
- **Error Recovery** - Automatic cleanup on failure
- **Retry Mechanism** - Downloads retry on failure
- **Root Protection** - Prevents running as root (asks for sudo when needed)
- **Version Detection** - Shows installed V compiler version
- **File Size Reporting** - Displays download and compiled binary sizes
- **Beautiful Output** - Color-coded, easy-to-read interface

## Quick Start

### One-Line Installation

```bash
curl -sSL https://raw.githubusercontent.com/Stick-Package-Manager/installer/main/install.sh | bash
```

Or with wget:

```bash
wget -qO- https://raw.githubusercontent.com/Stick-Package-Manager/installer/main/install.sh | bash
```

### Manual Download and Run

```bash
# Download the script
curl -sSL https://raw.githubusercontent.com/Stick-Package-Manager/installer/main/install.sh -o install.sh

# Make it executable
chmod +x install.sh

# Run it
./install.sh
```

## Installation Options

The installer presents an interactive menu with the following options:

### 1. Stick (Full Version)

Installs the complete Stick package manager with all features:
- Package search
- Install with dependency resolution
- Remove packages
- List installed packages
- Upgrade all packages
- Reinstall packages
- Multi-threaded operations
- Signature verification
- Auto-conflict resolution

**Recommended for:** Most users who want full AUR package management

### 2. Stick Lite (Minimal Version)

Ultra-lightweight version with only essential commands:
- Install packages
- Remove packages
- No dependency tracking
- No configuration files
- Less than 1 KB compiled size

**Recommended for:** Minimal systems, emergency installations, embedded systems

### 3. Stickfetch (System Info Tool)

System information display tool:
- Shows system details (OS, kernel, uptime, shell, DE, WM)
- Lists all Stick-managed packages with versions
- Beautiful neofetch-style ASCII art output
- Color-coded information

**Recommended for:** Users who want visual system information

### 4. All (Complete Package)

Installs all three tools:
- Stick (full version)
- Stick Lite
- Stickfetch

**Recommended for:** Users who want everything

### 5. Recommended (Stick + Stickfetch)

Installs the most commonly used combination:
- Stick (full version)
- Stickfetch

**Recommended for:** Best balance for most users

### 0. Cancel

Exits the installer without making any changes.

## What the Installer Does

### Pre-Installation Checks

1. **Root Check** - Ensures script is not run as root
2. **Internet Check** - Pings 8.8.8.8 and 1.1.1.1 to verify connectivity
3. **System Check** - Verifies it's an Arch-based distribution

### Dependency Installation

The installer automatically checks and installs:

- **curl or wget** - For downloading files
- **V compiler** - Installs from official V repository if missing
- **base-devel** - Required for makepkg
- **git** - Required for some operations

### Download Phase

- Downloads source files from GitHub
- Validates file integrity (checks size and existence)
- Retries up to 3 times on failure
- Reports download size

### Compilation Phase

- Compiles with V's production mode (`-prod` flag)
- Validates binary creation
- Reports compiled binary size
- Checks for compilation errors

### Installation Phase

- Installs to `/usr/local/bin/`
- Sets executable permissions
- Replaces existing installations if found
- Validates each step

### Cleanup

- Removes temporary files
- Cleans up on success or failure
- Preserves log file for troubleshooting

## System Requirements

### Minimum Requirements

- **OS:** Arch Linux or Arch-based distribution (Manjaro, EndeavourOS, etc.)
- **Internet:** Active connection required
- **Disk Space:** ~50 MB for V compiler + tools
- **Privileges:** sudo access for package installation

### Optional Requirements

- **curl** or **wget** (installer will install curl if missing)
- **V compiler** (installer will install if missing)
- **base-devel** (installer will install if missing)
- **git** (installer will install if missing)

## Troubleshooting

### Installation Fails

Check the log file for detailed error information:

```bash
cat /tmp/stick_install_*/install.log
```

### No Internet Connection

```
✗ No internet connection detected.
  Please check your network and try again.
```

**Solution:** Verify your internet connection and try again.

### Permission Errors

```
✗ Failed to install Stick.
```

**Solution:** Ensure you have sudo privileges. The script will ask for password when needed.

### V Compiler Installation Fails

```
✗ Failed to install V compiler.
Please install V manually from: https://vlang.io
```

**Solution:** 
1. Visit https://vlang.io
2. Follow manual installation instructions
3. Run the installer again

### Compilation Errors

```
✗ Compilation failed for Stick.
Check log file: /tmp/stick_install_12345/install.log
```

**Solution:** 
1. Check the log file for specific errors
2. Ensure V compiler is properly installed: `v version`
3. Try updating V: `v up`
4. Run installer again

### File Download Fails

```
✗ Failed to download Stick
```

**Solution:**
- Check your internet connection
- Verify GitHub is accessible
- The installer will retry 3 times automatically

### Already Installed

```
⚠ Stick already installed. Replacing...
```

This is normal behavior. The installer will replace existing installations with the new version.

## Log Files

The installer creates a detailed log file at:

```
/tmp/stick_install_<PID>/install.log
```

The log file contains:
- Timestamp for each operation
- Downloaded file URLs and sizes
- Compilation output
- Installation paths
- Error messages and stack traces

**Viewing the log:**

```bash
# Find the latest log
ls -lt /tmp/stick_install_*/install.log | head -1

# View the log
cat /tmp/stick_install_*/install.log
```

## Uninstallation

To uninstall tools installed by this script:

```bash
# Remove Stick
sudo rm /usr/local/bin/stick

# Remove Stick Lite
sudo rm /usr/local/bin/stick-lite

# Remove Stickfetch
sudo rm /usr/local/bin/stickfetch

# Remove Stick data directory (optional)
rm -rf ~/.stick
```

## Security Considerations

### Script Execution

Running scripts from the internet requires trust. Here's what this script does:

**Safe Operations:**
- Only downloads from official Stick repository
- Only installs to `/usr/local/bin/` (standard location)
- Asks for sudo only when needed
- Doesn't modify system files outside installation directory
- Creates detailed logs for transparency

**What to Check:**
1. Verify the script URL is from official repository
2. Review the script before running (recommended)
3. Check that it's not asking for unnecessary permissions

### Reviewing Before Installation

Download and review the script first:

```bash
curl -sSL https://raw.githubusercontent.com/Stick-Package-Manager/installer/main/install.sh -o install.sh
less install.sh  # Review the script
chmod +x install.sh
./install.sh
```

## Advanced Usage

### Quiet Installation (Non-Interactive)

The installer requires user input for menu selection. For automated installations, you can use:

```bash
# Install option 5 (Recommended) automatically
echo "5" | bash install.sh
```

### Custom Installation Directory

Currently, the installer installs to `/usr/local/bin/`. To install elsewhere:

```bash
# Download and edit the script
curl -sSL https://raw.githubusercontent.com/Stick-Package-Manager/installer/main/install.sh -o install.sh

# Edit INSTALL_PATH in the script
# Then run it
./install.sh
```

### Offline Installation

For systems without internet:

1. Download all required files on a system with internet:
   - install.sh
   - stick.v
   - stick-lite.v
   - stickfetch.v
   - V compiler (from https://vlang.io)

2. Transfer files to target system

3. Modify install.sh to use local files instead of downloading

© 2025 [ihatemustard](https://github.com/ihatemustard) & [Stick Package Manager contributors](https://github.com/Stick-Package-Manager/stick/people)
