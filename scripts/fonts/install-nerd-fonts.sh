#!/usr/bin/env bash

################################################################################
# Nerd Fonts (MesloLGS NF) Installation Script
# Description: Downloads and installs MesloLGS NF fonts for Powerlevel10k
################################################################################

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_DIR="${SCRIPT_DIR}/../common"

# Source common utilities
source "${COMMON_DIR}/logging.sh"
source "${COMMON_DIR}/utils.sh"

# Font directory
readonly FONT_DIR="/usr/local/share/fonts"

# Font URLs
readonly FONT_BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
readonly FONTS=(
    "MesloLGS%20NF%20Regular.ttf"
    "MesloLGS%20NF%20Bold.ttf"
    "MesloLGS%20NF%20Italic.ttf"
    "MesloLGS%20NF%20Bold%20Italic.ttf"
)

# Download and install a single font
install_font() {
    local font_filename="$1"
    local font_path="${FONT_DIR}/${font_filename}"
    
    # Decode URL-encoded filename
    local decoded_filename=$(echo -e "${font_filename}" | sed 's/%20/ /g')
    local decoded_path="${FONT_DIR}/${decoded_filename}"
    
    # Check if font already exists
    if [[ -f "${decoded_path}" ]]; then
        log_info "Font already exists: ${decoded_filename}"
        return 0
    fi
    
    log_info "Downloading ${decoded_filename}..."
    
    if sudo wget -q -O "${decoded_path}" "${FONT_BASE_URL}/${font_filename}"; then
        log_success "Downloaded ${decoded_filename}"
        return 0
    else
        log_error "Failed to download ${decoded_filename}"
        return 1
    fi
}

main() {
    log_info "Starting MesloLGS NF fonts installation..."
    
    # Check prerequisites
    if ! command_exists wget; then
        log_info "wget not found, installing..."
        install_apt_package wget || {
            log_error "Failed to install wget"
            return 1
        }
    fi
    
    # Ensure font directory exists
    if ! sudo mkdir -p "${FONT_DIR}"; then
        log_error "Failed to create font directory: ${FONT_DIR}"
        return 1
    fi
    
    # Install each font
    local failed=0
    for font in "${FONTS[@]}"; do
        install_font "${font}" || ((failed++))
    done
    
    # Refresh font cache
    if [[ ${failed} -eq 0 ]]; then
        log_info "Refreshing font cache..."
        fc-cache -fv >/dev/null 2>&1 || log_warn "Failed to refresh font cache"
        log_success "All MesloLGS NF fonts installed successfully"
        return 0
    else
        log_warn "${failed} font(s) failed to install"
        # Still refresh cache for successfully installed fonts
        fc-cache -fv >/dev/null 2>&1 || true
        return 1
    fi
}

# Run main function
main "$@"
