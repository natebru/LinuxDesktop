#!/usr/bin/env bash

################################################################################
# NVM and Node.js Installation Script
# Description: Installs NVM, Node.js LTS, and latest Node.js with idempotency
################################################################################

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_DIR="${SCRIPT_DIR}/../common"

# Source common utilities
source "${COMMON_DIR}/logging.sh"
source "${COMMON_DIR}/utils.sh"
source "${COMMON_DIR}/checks.sh"

# NVM version to install
readonly NVM_VERSION="v0.39.7"

# Install NVM
install_nvm() {
    if is_nvm_installed; then
        log_success "NVM is already installed"
        source_nvm
        local nvm_ver=$(nvm --version 2>/dev/null || echo "unknown")
        log_info "NVM version: ${nvm_ver}"
        return 0
    fi
    
    log_info "Installing NVM ${NVM_VERSION}..."
    
    # Check prerequisites
    if ! command_exists curl; then
        log_info "curl not found, installing..."
        install_apt_package curl || {
            log_error "Failed to install curl"
            return 1
        }
    fi
    
    # Download and run NVM install script
    if curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash; then
        log_success "NVM installed successfully"
        
        # Source NVM in current shell
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        return 0
    else
        log_error "Failed to install NVM"
        return 1
    fi
}

# Install Node.js LTS
install_node_lts() {
    log_info "Installing Node.js LTS..."
    
    if ! source_nvm; then
        log_error "NVM not available"
        return 1
    fi
    
    # Check if LTS is already installed
    local lts_version=$(nvm version-remote --lts 2>/dev/null || echo "")
    if [[ -n "${lts_version}" ]]; then
        if nvm ls "${lts_version}" >/dev/null 2>&1; then
            log_success "Node.js LTS ${lts_version} is already installed"
        else
            if nvm install --lts; then
                log_success "Node.js LTS installed successfully"
            else
                log_error "Failed to install Node.js LTS"
                return 1
            fi
        fi
    fi
    
    return 0
}

# Install latest Node.js
install_node_latest() {
    log_info "Installing latest Node.js..."
    
    if ! source_nvm; then
        log_error "NVM not available"
        return 1
    fi
    
    # Check if latest is already installed
    local latest_version=$(nvm version-remote node 2>/dev/null || echo "")
    if [[ -n "${latest_version}" ]]; then
        if nvm ls "${latest_version}" >/dev/null 2>&1; then
            log_success "Node.js latest ${latest_version} is already installed"
        else
            if nvm install node; then
                log_success "Latest Node.js installed successfully"
            else
                log_error "Failed to install latest Node.js"
                return 1
            fi
        fi
    fi
    
    return 0
}

# Set default Node.js version
set_default_node() {
    log_info "Setting default Node.js version to LTS..."
    
    if ! source_nvm; then
        log_error "NVM not available"
        return 1
    fi
    
    if nvm alias default lts/* >/dev/null 2>&1; then
        log_success "Default Node.js version set to LTS"
        return 0
    else
        log_warn "Failed to set default Node.js version"
        return 1
    fi
}

main() {
    log_info "Starting NVM and Node.js installation..."
    
    # Install NVM
    install_nvm || {
        log_error "NVM installation failed"
        return 1
    }
    
    # Install Node.js versions
    install_node_lts || log_warn "Node.js LTS installation had issues"
    install_node_latest || log_warn "Node.js latest installation had issues"
    
    # Set default version
    set_default_node || log_warn "Failed to set default Node.js version"
    
    # Display versions
    if source_nvm; then
        echo ""
        log_info "Installed Node.js versions:"
        nvm list 2>/dev/null || true
        echo ""
        
        local node_ver=$(node --version 2>/dev/null || echo "not available")
        local npm_ver=$(npm --version 2>/dev/null || echo "not available")
        log_info "Active Node.js: ${node_ver}"
        log_info "Active npm: ${npm_ver}"
    fi
    
    log_success "NVM and Node.js setup completed successfully"
    return 0
}

# Run main function
main "$@"
