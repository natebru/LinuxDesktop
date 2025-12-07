#!/usr/bin/env bash

################################################################################
# Browser Installation Script
# Description: Installs Brave browser with idempotency checks
################################################################################

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_DIR="${SCRIPT_DIR}/../common"

# Source common utilities
source "${COMMON_DIR}/logging.sh"
source "${COMMON_DIR}/utils.sh"
source "${COMMON_DIR}/checks.sh"

# Install Brave browser via snap
install_brave_snap() {
    log_info "Installing Brave browser via snap..."
    
    # Ensure snap is installed
    ensure_snap_installed || {
        log_error "Failed to install snapd"
        return 1
    }
    
    # Check if Brave is already installed
    if snap list 2>/dev/null | grep -q "^brave"; then
        log_success "Brave browser is already installed via snap"
        return 0
    fi
    
    # Install Brave
    if sudo snap install brave; then
        log_success "Brave browser installed successfully"
        return 0
    else
        log_error "Failed to install Brave browser via snap"
        return 1
    fi
}

# Install Brave browser via apt (alternative method)
install_brave_apt() {
    log_info "Installing Brave browser via apt..."
    
    # Check if Brave is already installed
    if command_exists brave-browser || command_exists brave; then
        log_success "Brave browser is already installed"
        return 0
    fi
    
    # Install prerequisites
    local prereqs=("apt-transport-https" "curl")
    for pkg in "${prereqs[@]}"; do
        install_apt_package "${pkg}" || {
            log_error "Failed to install prerequisite: ${pkg}"
            return 1
        }
    done
    
    # Add Brave repository key
    log_info "Adding Brave GPG key..."
    if ! sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg; then
        log_error "Failed to download Brave GPG key"
        return 1
    fi
    
    # Add Brave repository
    log_info "Adding Brave repository..."
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
        | sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null
    
    # Update package lists
    sudo apt-get update -qq || {
        log_error "Failed to update package lists"
        return 1
    }
    
    # Install Brave
    if install_apt_package brave-browser; then
        log_success "Brave browser installed successfully"
        return 0
    else
        log_error "Failed to install Brave browser"
        return 1
    fi
}

main() {
    log_info "Starting browser installation..."
    
    # Try snap first (simpler), fall back to apt if it fails
    if check_snap_installed; then
        install_brave_snap && return 0
    fi
    
    # If snap method failed or snap not available, try apt
    log_info "Trying apt installation method..."
    install_brave_apt && return 0
    
    log_error "Failed to install Brave browser using all available methods"
    return 1
}

# Run main function
main "$@"
