#!/usr/bin/env bash

################################################################################
# Powerline Fonts Installation Script
# Description: Installs Powerline fonts via apt
################################################################################

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_DIR="${SCRIPT_DIR}/../common"

# Source common utilities
source "${COMMON_DIR}/logging.sh"
source "${COMMON_DIR}/utils.sh"

main() {
    log_info "Starting Powerline fonts installation..."
    
    # Install powerline fonts package
    if install_apt_package fonts-powerline; then
        log_success "Powerline fonts installed successfully"
        return 0
    else
        log_error "Failed to install Powerline fonts"
        return 1
    fi
}

# Run main function
main "$@"
