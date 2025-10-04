#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

STICK_URL="https://raw.githubusercontent.com/Stick-Package-Manager/stick/main/stick.v"
STICK_LITE_URL="https://raw.githubusercontent.com/Stick-Package-Manager/lite/main/stick-lite.v"
STICKFETCH_URL="https://raw.githubusercontent.com/Stick-Package-Manager/stick/main/stickfetch.v"
INSTALL_DIR="/tmp/stick_install_$"
LOG_FILE="${INSTALL_DIR}/install.log"

cleanup() {
    if [ -d "$INSTALL_DIR" ]; then
        cd /tmp
        rm -rf "$INSTALL_DIR"
    fi
}

trap cleanup EXIT INT TERM

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE" 2>&1
}

print_banner() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   ${BOLD}Stick Package Manager - Universal Installer${NC}${CYAN}   ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
}

check_root() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}✗${NC} Do not run this script as root!"
        echo -e "${YELLOW}  The script will ask for sudo when needed.${NC}"
        exit 1
    fi
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}✗${NC} $1 is not installed."
        log "Missing: $1"
        return 1
    else
        echo -e "${GREEN}✓${NC} $1 is installed."
        log "Found: $1"
        return 0
    fi
}

check_internet() {
    echo -e "${BLUE}→${NC} Checking internet connection..."
    if ! ping -c 1 -W 2 8.8.8.8 &> /dev/null && ! ping -c 1 -W 2 1.1.1.1 &> /dev/null; then
        echo -e "${RED}✗${NC} No internet connection detected."
        echo -e "${YELLOW}  Please check your network and try again.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓${NC} Internet connection active."
    log "Internet connection verified"
}

install_dependencies() {
    echo -e "${BLUE}→${NC} Checking system requirements..."
    echo ""
    log "Starting dependency check"
    
    if ! check_command "pacman"; then
        echo -e "${RED}Error: This installer requires Arch Linux or an Arch-based distribution.${NC}"
        log "ERROR: Not an Arch-based system"
        exit 1
    fi
    
    local need_install=()
    
    if ! check_command "curl" && ! check_command "wget"; then
        need_install+=("curl")
    fi
    
    local install_v=0
    if ! check_command "v"; then
        echo -e "${YELLOW}V compiler not found. Will install V...${NC}"
        log "V compiler missing, will install"
        install_v=1
    else
        local v_version
        v_version=$(v version 2>&1 | head -n1)
        echo -e "${GREEN}  V version: ${v_version}${NC}"
        log "V version: ${v_version}"
    fi
    
    if ! check_command "makepkg"; then
        need_install+=("base-devel")
    fi
    
    if ! check_command "git"; then
        need_install+=("git")
    fi
    
    if [ ${#need_install[@]} -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Installing required packages: ${need_install[*]}${NC}"
        log "Installing packages: ${need_install[*]}"
        
        if ! sudo pacman -Sy --noconfirm --needed "${need_install[@]}" 2>&1 | tee -a "$LOG_FILE"; then
            echo -e "${RED}✗${NC} Failed to install dependencies."
            log "ERROR: Dependency installation failed"
            exit 1
        fi
        echo -e "${GREEN}✓${NC} Packages installed."
        log "Dependencies installed successfully"
    fi
    
    if [ $install_v -eq 1 ]; then
        echo ""
        echo -e "${YELLOW}Installing V compiler...${NC}"
        log "Starting V installation"
        
        local v_install_script="/tmp/install_v_$.sh"
        if command -v curl &> /dev/null; then
            curl -sSL https://raw.githubusercontent.com/vlang/v/master/cmd/tools/install_v.sh -o "$v_install_script" 2>&1 | tee -a "$LOG_FILE"
        elif command -v wget &> /dev/null; then
            wget -qO "$v_install_script" https://raw.githubusercontent.com/vlang/v/master/cmd/tools/install_v.sh 2>&1 | tee -a "$LOG_FILE"
        fi
        
        if ! bash "$v_install_script" 2>&1 | tee -a "$LOG_FILE"; then
            echo -e "${RED}✗${NC} Failed to install V compiler."
            echo -e "${YELLOW}Please install V manually from: https://vlang.io${NC}"
            log "ERROR: V installation failed"
            exit 1
        fi
        
        rm -f "$v_install_script"
        export PATH="$HOME/.v:$PATH"
        
        if ! command -v v &> /dev/null; then
            echo -e "${RED}✗${NC} V compiler installation failed."
            log "ERROR: V not in PATH after installation"
            exit 1
        fi
        echo -e "${GREEN}✓${NC} V compiler installed."
        log "V compiler installed successfully"
    fi
    
    echo ""
    echo -e "${GREEN}✓${NC} All dependencies met!"
    log "All dependencies satisfied"
    echo ""
}

show_menu() {
    echo -e "${BOLD}${CYAN}Select what to install:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} Stick ${CYAN}(Full version)${NC}"
    echo -e "     - All features: search, install, remove, upgrade, reinstall"
    echo -e "     - Automatic dependency resolution"
    echo -e "     - Multi-threaded operations"
    echo -e "     - Signature verification"
    echo ""
    echo -e "  ${GREEN}2)${NC} Stick Lite ${CYAN}(Minimal version)${NC}"
    echo -e "     - Only install and remove"
    echo -e "     - Ultra-lightweight (<2 KB)"
    echo -e "     - No dependencies tracking"
    echo ""
    echo -e "  ${GREEN}3)${NC} Stickfetch ${CYAN}(System info tool)${NC}"
    echo -e "     - Display system information"
    echo -e "     - Show Stick packages"
    echo -e "     - Neofetch-style output"
    echo ""
    echo -e "  ${GREEN}4)${NC} All ${CYAN}(Stick + Stick Lite + Stickfetch)${NC}"
    echo -e "     - Complete package: all tools"
    echo ""
    echo -e "  ${GREEN}5)${NC} Recommended ${CYAN}(Stick + Stickfetch)${NC}"
    echo -e "     - Best for most users"
    echo ""
    echo -e "  ${RED}0)${NC} Cancel installation"
    echo ""
    
    while true; do
        echo -n -e "${YELLOW}Enter your choice [0-5]:${NC} "
        read -r choice
        
        case $choice in
            [0-5])
                echo ""
                log "User selected option: $choice"
                return 0
                ;;
            *)
                echo -e "${RED}Invalid input. Please enter a number between 0 and 5.${NC}"
                log "Invalid menu input: $choice"
                ;;
        esac
    done
}

download_file() {
    local url=$1
    local output=$2
    local name=$3
    
    echo -e "${BLUE}→${NC} Downloading ${name}..."
    log "Downloading from: $url"
    
    if command -v curl &> /dev/null; then
        if ! curl -sSL --fail --retry 3 --retry-delay 2 "$url" -o "$output" 2>&1 | tee -a "$LOG_FILE"; then
            echo -e "${RED}✗${NC} Failed to download ${name}"
            log "ERROR: Download failed for $name"
            return 1
        fi
    elif command -v wget &> /dev/null; then
        if ! wget --retry-connrefused --waitretry=2 --read-timeout=20 --timeout=15 --tries=3 -q "$url" -O "$output" 2>&1 | tee -a "$LOG_FILE"; then
            echo -e "${RED}✗${NC} Failed to download ${name}"
            log "ERROR: Download failed for $name"
            return 1
        fi
    else
        echo -e "${RED}✗${NC} Neither curl nor wget available."
        log "ERROR: No download tool available"
        return 1
    fi
    
    if [ ! -f "$output" ] || [ ! -s "$output" ]; then
        echo -e "${RED}✗${NC} Downloaded file is missing or empty."
        log "ERROR: File missing or empty: $output"
        return 1
    fi
    
    local file_size
    file_size=$(wc -c < "$output")
    echo -e "${GREEN}✓${NC} ${name} downloaded (${file_size} bytes)."
    log "Download successful: $name ($file_size bytes)"
    
    return 0
}

compile_and_install() {
    local name=$1
    local source=$2
    local binary=$3
    
    echo -e "${BLUE}→${NC} Compiling ${name}..."
    log "Compiling: $name from $source"
    
    local compile_output
    compile_output=$(v -prod "$source" -o "$binary" 2>&1)
    local compile_status=$?
    echo "$compile_output" >> "$LOG_FILE"
    
    if [ $compile_status -ne 0 ]; then
        echo -e "${RED}✗${NC} Compilation failed for ${name}."
        echo -e "${YELLOW}Check log file: ${LOG_FILE}${NC}"
        log "ERROR: Compilation failed for $name"
        return 1
    fi
    
    if [ ! -f "$binary" ]; then
        echo -e "${RED}✗${NC} Build failed for ${name} - binary not created."
        log "ERROR: Binary not created: $binary"
        return 1
    fi
    
    local binary_size
    binary_size=$(wc -c < "$binary")
    echo -e "${GREEN}✓${NC} ${name} compiled (${binary_size} bytes)."
    log "Compilation successful: $name ($binary_size bytes)"
    
    local install_path="/usr/local/bin/$binary"
    if [ -f "$install_path" ]; then
        echo -e "${YELLOW}⚠${NC}  ${name} already installed. Replacing..."
        log "Replacing existing installation: $install_path"
        if ! sudo rm -f "$install_path"; then
            echo -e "${RED}✗${NC} Failed to remove existing ${name}."
            log "ERROR: Failed to remove existing binary"
            return 1
        fi
    fi
    
    echo -e "${BLUE}→${NC} Installing ${name} to ${install_path}..."
    log "Installing to: $install_path"
    
    if ! sudo mv "$binary" "$install_path"; then
        echo -e "${RED}✗${NC} Failed to install ${name}."
        log "ERROR: Failed to move binary to install path"
        return 1
    fi
    
    if ! sudo chmod +x "$install_path"; then
        echo -e "${RED}✗${NC} Failed to set executable permissions."
        log "ERROR: Failed to set permissions"
        return 1
    fi
    
    echo -e "${GREEN}✓${NC} ${name} installed successfully."
    log "Installation successful: $name"
    echo ""
    
    return 0
}

install_stick() {
    echo -e "${CYAN}${BOLD}Installing Stick (Full Version)${NC}"
    echo ""
    log "Starting Stick installation"
    download_file "$STICK_URL" "stick.v" "Stick" || return 1
    compile_and_install "Stick" "stick.v" "stick" || return 1
}

install_stick_lite() {
    echo -e "${CYAN}${BOLD}Installing Stick Lite (Minimal Version)${NC}"
    echo ""
    log "Starting Stick Lite installation"
    download_file "$STICK_LITE_URL" "stick-lite.v" "Stick Lite" || return 1
    compile_and_install "Stick Lite" "stick-lite.v" "stick-lite" || return 1
}

install_stickfetch() {
    echo -e "${CYAN}${BOLD}Installing Stickfetch${NC}"
    echo ""
    log "Starting Stickfetch installation"
    download_file "$STICKFETCH_URL" "stickfetch.v" "Stickfetch" || return 1
    compile_and_install "Stickfetch" "stickfetch.v" "stickfetch" || return 1
}

show_completion() {
    echo -e "${GREEN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          Installation Complete!               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ "$INSTALLED_STICK" = "1" ]; then
        echo -e "${BLUE}→${NC} ${BOLD}Stick${NC} installed to: ${GREEN}/usr/local/bin/stick${NC}"
        echo -e "   Commands:"
        echo -e "   ${CYAN}stick install <package>${NC}       - Install package(s)"
        echo -e "   ${CYAN}stick remove <package>${NC}        - Remove package(s)"
        echo -e "   ${CYAN}stick search <package>${NC}        - Search for packages"
        echo -e "   ${CYAN}stick list${NC}                    - List installed packages"
        echo -e "   ${CYAN}stick upgrade${NC}                 - Upgrade all packages"
        echo -e "   ${CYAN}stick reinstall <package>${NC}     - Reinstall package"
        echo ""
    fi
    
    if [ "$INSTALLED_LITE" = "1" ]; then
        echo -e "${BLUE}→${NC} ${BOLD}Stick Lite${NC} installed to: ${GREEN}/usr/local/bin/stick-lite${NC}"
        echo -e "   Commands:"
        echo -e "   ${CYAN}stick-lite install <pkg>${NC}      - Install package"
        echo -e "   ${CYAN}stick-lite remove <pkg>${NC}       - Remove package"
        echo ""
    fi
    
    if [ "$INSTALLED_FETCH" = "1" ]; then
        echo -e "${BLUE}→${NC} ${BOLD}Stickfetch${NC} installed to: ${GREEN}/usr/local/bin/stickfetch${NC}"
        echo -e "   Commands:"
        echo -e "   ${CYAN}stickfetch${NC}                    - Display system info"
        echo ""
    fi
    
    echo -e "${YELLOW}Note:${NC} On first use, Stick will add ~/.stick/bin to your PATH."
    echo -e "      You may need to restart your shell or run: ${GREEN}source ~/.bashrc${NC}"
    echo ""
    echo -e "${BLUE}→${NC} Documentation: ${CYAN}https://github.com/Stick-Package-Manager/stick${NC}"
    echo -e "${BLUE}→${NC} Log file saved: ${YELLOW}${LOG_FILE}${NC}"
    echo ""
}

main() {
    print_banner
    check_root
    check_internet
    
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    log "Installation started"
    log "Install directory: $INSTALL_DIR"
    
    install_dependencies
    
    show_menu
    
    INSTALLED_STICK=0
    INSTALLED_LITE=0
    INSTALLED_FETCH=0
    
    case $choice in
        1)
            install_stick && INSTALLED_STICK=1
            ;;
        2)
            install_stick_lite && INSTALLED_LITE=1
            ;;
        3)
            install_stickfetch && INSTALLED_FETCH=1
            ;;
        4)
            install_stick && INSTALLED_STICK=1
            install_stick_lite && INSTALLED_LITE=1
            install_stickfetch && INSTALLED_FETCH=1
            ;;
        5)
            install_stick && INSTALLED_STICK=1
            install_stickfetch && INSTALLED_FETCH=1
            ;;
        0)
            echo -e "${YELLOW}Installation cancelled.${NC}"
            log "Installation cancelled by user"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Installation cancelled.${NC}"
            log "Invalid choice: $choice"
            exit 1
            ;;
    esac
    
    if [ "$INSTALLED_STICK" = "1" ] || [ "$INSTALLED_LITE" = "1" ] || [ "$INSTALLED_FETCH" = "1" ]; then
        log "Installation completed successfully"
        show_completion
    else
        echo -e "${RED}No packages were installed.${NC}"
        log "ERROR: No packages installed"
        exit 1
    fi
}

main
