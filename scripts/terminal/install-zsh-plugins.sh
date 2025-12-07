#!/usr/bin/env bash

################################################################################
# Zsh Plugins Installation Script
# Description: Installs zsh-autosuggestions and zsh-syntax-highlighting
################################################################################

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_DIR="${SCRIPT_DIR}/../common"

# Source common utilities
source "${COMMON_DIR}/logging.sh"
source "${COMMON_DIR}/utils.sh"
source "${COMMON_DIR}/checks.sh"

# Install zsh-autosuggestions
install_autosuggestions() {
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    
    log_info "Installing zsh-autosuggestions..."
    clone_if_not_exists \
        "https://github.com/zsh-users/zsh-autosuggestions" \
        "${plugin_dir}" || {
        log_error "Failed to install zsh-autosuggestions"
        return 1
    }
    
    log_success "zsh-autosuggestions installed successfully"
    return 0
}

# Install zsh-syntax-highlighting
install_syntax_highlighting() {
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    
    log_info "Installing zsh-syntax-highlighting..."
    clone_if_not_exists \
        "https://github.com/zsh-users/zsh-syntax-highlighting" \
        "${plugin_dir}" || {
        log_error "Failed to install zsh-syntax-highlighting"
        return 1
    }
    
    log_success "zsh-syntax-highlighting installed successfully"
    return 0
}

main() {
    log_info "Starting Zsh plugins installation..."
    
    # Check prerequisites
    if ! is_oh_my_zsh_installed; then
        log_error "Oh-My-Zsh is not installed. Please install Oh-My-Zsh first."
        return 1
    fi
    
    if ! command_exists git; then
        log_error "git is not installed. Please install git first."
        return 1
    fi
    
    # Install plugins
    local failed=0
    
    install_autosuggestions || ((failed++))
    install_syntax_highlighting || ((failed++))
    
    if [[ ${failed} -eq 0 ]]; then
        log_success "All Zsh plugins installed successfully"
        return 0
    else
        log_warn "${failed} plugin(s) failed to install"
        return 1
    fi
}

# Run main function
main "$@"
