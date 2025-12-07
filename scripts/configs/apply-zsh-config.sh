#!/usr/bin/env bash

################################################################################
# Apply Zsh Configuration Script
# Description: Copies .zshrc from artifacts to home directory
################################################################################

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_DIR="${SCRIPT_DIR}/../common"
ARTIFACTS_DIR="${SCRIPT_DIR}/../../artifacts"

# Source common utilities
source "${COMMON_DIR}/logging.sh"
source "${COMMON_DIR}/utils.sh"

# Configuration file paths
readonly SOURCE_FILE="${ARTIFACTS_DIR}/.zshrc"
readonly TARGET_FILE="${HOME}/.zshrc"

main() {
    log_info "Applying Zsh configuration..."
    
    # Check if source file exists
    if [[ ! -f "${SOURCE_FILE}" ]]; then
        log_error "Source file not found: ${SOURCE_FILE}"
        return 1
    fi
    
    # Backup existing file if it exists
    if [[ -f "${TARGET_FILE}" ]]; then
        local backup="${TARGET_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up existing .zshrc to ${backup}"
        cp "${TARGET_FILE}" "${backup}" || log_warn "Failed to create backup"
    fi
    
    # Copy configuration file
    if cp "${SOURCE_FILE}" "${TARGET_FILE}"; then
        log_success ".zshrc applied successfully"
        log_info "Location: ${TARGET_FILE}"
        return 0
    else
        log_error "Failed to copy .zshrc"
        return 1
    fi
}

# Run main function
main "$@"
