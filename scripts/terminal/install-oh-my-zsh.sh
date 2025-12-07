#!/usr/bin/env bash

################################################################################
# Oh-My-Zsh Installation Script
# Description: Installs Oh-My-Zsh and Powerlevel10k theme with idempotency
################################################################################

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_DIR="${SCRIPT_DIR}/../common"

# Source common utilities
source "${COMMON_DIR}/logging.sh"
source "${COMMON_DIR}/utils.sh"
source "${COMMON_DIR}/checks.sh"

# Install Oh-My-Zsh
install_oh_my_zsh() {
    if is_oh_my_zsh_installed; then
        log_success "Oh-My-Zsh is already installed"
        return 0
    fi
    
    log_info "Installing Oh-My-Zsh..."
    
    # Install without changing shell or running zsh
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
        log_error "Failed to install Oh-My-Zsh"
        return 1
    }
    
    log_success "Oh-My-Zsh installed successfully"
    return 0
}

# Install Powerlevel10k theme
install_powerlevel10k() {
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [[ -d "${p10k_dir}" ]]; then
        log_info "Powerlevel10k already installed, updating..."
        git -C "${p10k_dir}" pull --quiet || log_warn "Failed to update Powerlevel10k"
        log_success "Powerlevel10k is up to date"
        return 0
    fi
    
    log_info "Installing Powerlevel10k theme..."
    
    if git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git "${p10k_dir}"; then
        log_success "Powerlevel10k installed successfully"
        return 0
    else
        log_error "Failed to install Powerlevel10k"
        return 1
    fi
}

main() {
    log_info "Starting Oh-My-Zsh installation..."
    
    # Check prerequisites
    if ! command_exists zsh; then
        log_error "Zsh is not installed. Please install Zsh first."
        return 1
    fi
    
    if ! command_exists curl; then
        log_info "curl not found, installing..."
        install_apt_package curl || {
            log_error "Failed to install curl"
            return 1
        }
    fi
    
    if ! command_exists git; then
        log_info "git not found, installing..."
        install_apt_package git || {
            log_error "Failed to install git"
            return 1
        }
    fi
    
    # Install Oh-My-Zsh
    install_oh_my_zsh || return 1
    
    # Install Powerlevel10k theme
    install_powerlevel10k || return 1
    
    log_success "Oh-My-Zsh setup completed successfully"
    return 0
}

# Run main function
main "$@"
