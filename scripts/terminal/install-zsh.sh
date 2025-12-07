#!/usr/bin/env bash

################################################################################
# Zsh Installation Script
# Description: Installs Zsh shell with idempotency checks
################################################################################

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_DIR="${SCRIPT_DIR}/../common"

# Source common utilities
source "${COMMON_DIR}/logging.sh"
source "${COMMON_DIR}/utils.sh"
source "${COMMON_DIR}/checks.sh"

main() {
    log_info "Starting Zsh installation..."
    
    # Check if zsh is already installed
    if command_exists zsh; then
        local zsh_version=$(zsh --version | awk '{print $2}')
        log_success "Zsh is already installed (version: ${zsh_version})"
        return 0
    fi
    
    # Install zsh
    log_info "Installing Zsh..."
    if install_apt_package zsh; then
        local zsh_version=$(zsh --version | awk '{print $2}')
        log_success "Zsh ${zsh_version} installed successfully"
        return 0
    else
        log_error "Failed to install Zsh"
        return 1
    fi
}

# Run main function
main "$@"
