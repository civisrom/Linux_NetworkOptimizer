#!/bin/bash

#############################################
# Installer for Linux Network Optimizer (BBR)
# Repository: civisrom/Linux_NetworkOptimizer
#############################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO_URL="https://raw.githubusercontent.com/civisrom/Linux_NetworkOptimizer/main"
INSTALL_DIR="/opt/network-optimizer"
SCRIPT_NAME="bbr.sh"

print_banner() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${CYAN}  Linux Network Optimizer - Installer${NC}"
    echo -e "${BLUE}==========================================${NC}"
    echo ""
}

print_msg()     { echo -e "${GREEN}[INFO]${NC} $1"; }
print_err()     { echo -e "${RED}[ERROR]${NC} $1"; }
print_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_ok()      { echo -e "${GREEN}[OK]${NC} $1"; }

# --- Pre-flight checks ---

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_err "This installer must be run as root."
        echo -e "  Run: ${CYAN}sudo bash install.sh${NC}"
        exit 1
    fi
}

check_deps() {
    local missing=()
    for cmd in wget curl ping sysctl; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        print_warn "Installing missing dependencies: ${missing[*]}"
        apt-get update -qq && apt-get install -y -qq "${missing[@]}" 2>/dev/null \
            || yum install -y -q "${missing[@]}" 2>/dev/null \
            || {
                print_err "Could not install: ${missing[*]}. Please install them manually."
                exit 1
            }
    fi
}

check_kernel_bbr() {
    if ! modprobe tcp_bbr 2>/dev/null; then
        print_warn "Kernel module tcp_bbr could not be loaded."
        print_warn "BBR requires Linux kernel 4.9+. Your kernel: $(uname -r)"
        read -p "Continue anyway? (y/N): " cont
        cont=${cont:-n}
        if [[ ! "$cont" =~ ^[Yy] ]]; then
            print_msg "Installation cancelled."
            exit 0
        fi
    else
        print_ok "BBR kernel module available."
    fi
}

# --- Installation ---

download_script() {
    print_msg "Creating install directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"

    print_msg "Downloading $SCRIPT_NAME ..."
    if command -v wget &>/dev/null; then
        wget -qO "$INSTALL_DIR/$SCRIPT_NAME" "$REPO_URL/$SCRIPT_NAME"
    elif command -v curl &>/dev/null; then
        curl -sSL -o "$INSTALL_DIR/$SCRIPT_NAME" "$REPO_URL/$SCRIPT_NAME"
    else
        print_err "Neither wget nor curl found. Cannot download."
        exit 1
    fi

    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    print_ok "Script downloaded to $INSTALL_DIR/$SCRIPT_NAME"
}

create_symlink() {
    local link="/usr/local/bin/network-optimizer"
    ln -sf "$INSTALL_DIR/$SCRIPT_NAME" "$link"
    print_ok "Symlink created: $link -> $INSTALL_DIR/$SCRIPT_NAME"
}

# --- Uninstall ---

uninstall() {
    print_warn "Uninstalling Linux Network Optimizer..."

    if [ -L /usr/local/bin/network-optimizer ]; then
        rm -f /usr/local/bin/network-optimizer
        print_ok "Symlink removed."
    fi

    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        print_ok "Directory $INSTALL_DIR removed."
    fi

    print_ok "Uninstall complete. System sysctl settings were NOT reverted."
    print_msg "To restore original sysctl, use the backup files: /etc/sysctl.conf~*"
    exit 0
}

# --- Main ---

main() {
    print_banner
    check_root

    # Handle --uninstall flag
    if [[ "${1}" == "--uninstall" || "${1}" == "-u" ]]; then
        uninstall
    fi

    print_msg "Checking prerequisites..."
    check_deps
    check_kernel_bbr

    echo ""
    download_script
    create_symlink

    echo ""
    echo -e "${BLUE}==========================================${NC}"
    print_ok "Installation complete!"
    echo -e "${BLUE}==========================================${NC}"
    echo ""
    print_msg "Usage:"
    echo -e "  ${CYAN}sudo network-optimizer${NC}        — run via symlink"
    echo -e "  ${CYAN}sudo bash $INSTALL_DIR/$SCRIPT_NAME${NC}"
    echo ""

    # Offer to run immediately
    read -p "Launch Network Optimizer now? (Y/n): " launch
    launch=${launch:-y}
    if [[ "$launch" =~ ^[Yy] ]]; then
        echo ""
        bash "$INSTALL_DIR/$SCRIPT_NAME"
    fi
}

main "$@"
