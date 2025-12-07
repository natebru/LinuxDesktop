#!/usr/bin/env bash

################################################################################
# Linux Desktop Setup - Master Orchestration Script
# Description: Automated setup for Linux desktop environment
# Author: Nate
# Version: 1.0.0
################################################################################

set -euo pipefail

# Script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly COMMON_DIR="${SCRIPT_DIR}/scripts/common"
readonly TERMINAL_DIR="${SCRIPT_DIR}/scripts/terminal"
readonly DEV_TOOLS_DIR="${SCRIPT_DIR}/scripts/dev-tools"
readonly DESKTOP_APPS_DIR="${SCRIPT_DIR}/scripts/desktop-apps"
readonly FONTS_DIR="${SCRIPT_DIR}/scripts/fonts"
readonly CONFIGS_DIR="${SCRIPT_DIR}/scripts/configs"

# Source common utilities
source "${COMMON_DIR}/logging.sh"
source "${COMMON_DIR}/utils.sh"
source "${COMMON_DIR}/checks.sh"
source "${COMMON_DIR}/error-handlers.sh"

# Global variables
INSTALL_TERMINAL=true
INSTALL_DEV_TOOLS=true
INSTALL_DESKTOP_APPS=true
INSTALL_FONTS=true
APPLY_CONFIGS=true
SKIP_PROMPTS=false

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-terminal)
                INSTALL_TERMINAL=false
                shift
                ;;
            --skip-dev-tools)
                INSTALL_DEV_TOOLS=false
                shift
                ;;
            --skip-desktop-apps)
                INSTALL_DESKTOP_APPS=false
                shift
                ;;
            --skip-fonts)
                INSTALL_FONTS=false
                shift
                ;;
            --skip-configs)
                APPLY_CONFIGS=false
                shift
                ;;
            -y|--yes)
                SKIP_PROMPTS=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    cat << EOF
Linux Desktop Setup Script

Usage: ./setup.sh [OPTIONS]

Options:
    --skip-terminal       Skip terminal setup (zsh, oh-my-zsh, etc.)
    --skip-dev-tools      Skip development tools (nvm, node, etc.)
    --skip-desktop-apps   Skip desktop applications (browsers, etc.)
    --skip-fonts          Skip font installation
    --skip-configs        Skip configuration file application
    -y, --yes             Skip all confirmation prompts
    -h, --help            Show this help message

Examples:
    ./setup.sh                           # Full installation with prompts
    ./setup.sh -y                        # Full installation without prompts
    ./setup.sh --skip-desktop-apps       # Install everything except desktop apps
    ./setup.sh --skip-terminal -y        # Skip terminal setup, no prompts

EOF
}

# Pre-flight system checks
run_preflight_checks() {
    log_step 1 10 "Running Pre-flight Checks"
    
    # Check if running on Linux
    if ! check_linux_os; then
        exit 1
    fi
    
    # Check if running as root (we don't want that)
    if ! check_not_root; then
        exit 1
    fi
    
    # Check for sudo access
    if ! check_sudo_access; then
        exit 1
    fi
    
    # Check internet connectivity
    if ! check_internet_connectivity; then
        log_error "No internet connection detected. Please connect to the internet and try again."
        exit 1
    fi
    
    # Check available disk space (need at least 2GB)
    if ! check_disk_space "/home" 2048; then
        log_error "Insufficient disk space. At least 2GB required."
        exit 1
    fi
    
    # Update package lists
    update_apt_cache || log_warn "Failed to update package lists"
    
    log_success "Pre-flight checks completed"
}

# Display installation plan
show_installation_plan() {
    log_step 2 10 "Installation Plan"
    
    echo ""
    echo "The following components will be installed:"
    echo ""
    
    if [[ "${INSTALL_TERMINAL}" == true ]]; then
        echo -e "  ${GREEN}✓${NC} Terminal Setup"
        echo "    - Zsh"
        echo "    - Oh-My-Zsh"
        echo "    - Powerlevel10k theme"
        echo "    - Zsh plugins (autosuggestions, syntax-highlighting)"
    else
        echo -e "  ${YELLOW}✗${NC} Terminal Setup (skipped)"
    fi
    
    if [[ "${INSTALL_FONTS}" == true ]]; then
        echo -e "  ${GREEN}✓${NC} Fonts"
        echo "    - Powerline fonts"
        echo "    - MesloLGS NF fonts"
    else
        echo -e "  ${YELLOW}✗${NC} Fonts (skipped)"
    fi
    
    if [[ "${INSTALL_DEV_TOOLS}" == true ]]; then
        echo -e "  ${GREEN}✓${NC} Development Tools"
        echo "    - NVM (Node Version Manager)"
        echo "    - Node.js (LTS + latest)"
    else
        echo -e "  ${YELLOW}✗${NC} Development Tools (skipped)"
    fi
    
    if [[ "${INSTALL_DESKTOP_APPS}" == true ]]; then
        echo -e "  ${GREEN}✓${NC} Desktop Applications"
        echo "    - Brave Browser"
    else
        echo -e "  ${YELLOW}✗${NC} Desktop Applications (skipped)"
    fi
    
    if [[ "${APPLY_CONFIGS}" == true ]]; then
        echo -e "  ${GREEN}✓${NC} Configuration Files"
        echo "    - .zshrc"
        echo "    - .p10k.zsh"
    else
        echo -e "  ${YELLOW}✗${NC} Configuration Files (skipped)"
    fi
    
    echo ""
    
    if [[ "${SKIP_PROMPTS}" != true ]]; then
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled by user"
            exit 0
        fi
    fi
}

# Backup existing configurations
backup_existing_configs() {
    if [[ "${APPLY_CONFIGS}" == true ]]; then
        log_step 3 10 "Backing Up Existing Configurations"
        bash "${CONFIGS_DIR}/backup-configs.sh" || log_warn "Backup failed, continuing..."
        log_success "Configuration backup completed"
    else
        log_step 3 10 "Skipping Configuration Backup"
    fi
}

# Install terminal components
install_terminal_components() {
    if [[ "${INSTALL_TERMINAL}" == true ]]; then
        log_step 4 10 "Installing Terminal Components"
        
        bash "${TERMINAL_DIR}/install-zsh.sh" || {
            log_error "Failed to install Zsh"
            return 1
        }
        
        bash "${TERMINAL_DIR}/install-oh-my-zsh.sh" || {
            log_error "Failed to install Oh-My-Zsh"
            return 1
        }
        
        bash "${TERMINAL_DIR}/install-zsh-plugins.sh" || {
            log_warn "Failed to install some Zsh plugins"
        }
        
        log_success "Terminal components installed"
    else
        log_step 4 10 "Skipping Terminal Installation"
    fi
}

# Install fonts
install_fonts() {
    if [[ "${INSTALL_FONTS}" == true ]]; then
        log_step 5 10 "Installing Fonts"
        
        bash "${FONTS_DIR}/install-powerline-fonts.sh" || log_warn "Powerline fonts installation failed"
        bash "${FONTS_DIR}/install-nerd-fonts.sh" || log_warn "Nerd fonts installation failed"
        
        log_success "Fonts installed"
    else
        log_step 5 10 "Skipping Font Installation"
    fi
}

# Install development tools
install_development_tools() {
    if [[ "${INSTALL_DEV_TOOLS}" == true ]]; then
        log_step 6 10 "Installing Development Tools"
        
        bash "${DEV_TOOLS_DIR}/install-nvm.sh" || {
            log_error "Failed to install NVM"
            return 1
        }
        
        log_success "Development tools installed"
    else
        log_step 6 10 "Skipping Development Tools Installation"
    fi
}

# Install desktop applications
install_desktop_applications() {
    if [[ "${INSTALL_DESKTOP_APPS}" == true ]]; then
        log_step 7 10 "Installing Desktop Applications"
        
        bash "${DESKTOP_APPS_DIR}/install-browsers.sh" || log_warn "Browser installation had issues"
        
        log_success "Desktop applications installed"
    else
        log_step 7 10 "Skipping Desktop Applications Installation"
    fi
}

# Apply configuration files
apply_configurations() {
    if [[ "${APPLY_CONFIGS}" == true ]]; then
        log_step 8 10 "Applying Configuration Files"
        
        bash "${CONFIGS_DIR}/apply-zsh-config.sh" || log_warn "Failed to apply .zshrc"
        bash "${CONFIGS_DIR}/apply-p10k-config.sh" || log_warn "Failed to apply .p10k.zsh"
        
        log_success "Configurations applied"
    else
        log_step 8 10 "Skipping Configuration Application"
    fi
}

# Post-installation steps
post_installation() {
    log_step 9 10 "Post-Installation Steps"
    
    # Set zsh as default shell if installed
    if [[ "${INSTALL_TERMINAL}" == true ]] && command_exists zsh; then
        if [[ "${SHELL}" != "$(which zsh)" ]]; then
            log_info "Setting Zsh as default shell..."
            chsh -s "$(which zsh)" || log_warn "Failed to set Zsh as default shell. You can change it manually later."
        fi
    fi
    
    # Font cache refresh
    if [[ "${INSTALL_FONTS}" == true ]]; then
        log_info "Refreshing font cache..."
        fc-cache -fv >/dev/null 2>&1 || log_warn "Failed to refresh font cache"
    fi
    
    log_success "Post-installation completed"
}

# Display completion summary
show_completion_summary() {
    log_step 10 10 "Installation Complete!"
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  INSTALLATION COMPLETED!                       ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Next Steps:"
    echo ""
    
    if [[ "${INSTALL_TERMINAL}" == true ]]; then
        echo "  1. Restart your terminal or run: exec zsh"
        echo "  2. Configure Powerlevel10k by running: p10k configure"
    fi
    
    if [[ "${INSTALL_DEV_TOOLS}" == true ]]; then
        echo "  3. Verify Node.js installation: node --version"
        echo "  4. Verify npm installation: npm --version"
    fi
    
    echo ""
    echo "Log file: ${LOG_FILE}"
    echo ""
    
    if [[ "${APPLY_CONFIGS}" == true ]]; then
        echo "Your previous configurations have been backed up to:"
        echo "  ${SCRIPT_DIR}/artifacts/backups/"
        echo ""
        echo "To restore previous configs, run:"
        echo "  bash ${CONFIGS_DIR}/restore-configs.sh"
        echo ""
    fi
}

# Main execution flow
main() {
    init_log
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              Linux Desktop Setup Script v1.0.0                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    parse_arguments "$@"
    run_preflight_checks
    show_installation_plan
    backup_existing_configs
    
    # Execute installations
    install_terminal_components
    install_fonts
    install_development_tools
    install_desktop_applications
    apply_configurations
    
    # Finalize
    post_installation
    show_completion_summary
    
    log_success "All operations completed successfully!"
}

# Trap for cleanup on exit
cleanup() {
    local exit_code=$?
    if [[ ${exit_code} -ne 0 ]]; then
        echo ""
        echo "Installation encountered errors. Check the log file for details: ${LOG_FILE}"
        if [[ "${APPLY_CONFIGS}" == true ]]; then
            echo "You can restore your previous configurations by running:"
            echo "  bash ${CONFIGS_DIR}/restore-configs.sh"
        fi
    fi
}

trap cleanup EXIT

# Run main function
main "$@"
