#!/usr/bin/env bash

################################################################################
# Backup Configuration Script
# Description: Creates timestamped backups of existing configuration files
################################################################################

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_DIR="${SCRIPT_DIR}/../common"
ARTIFACTS_DIR="${SCRIPT_DIR}/../../artifacts"

# Source common utilities
source "${COMMON_DIR}/logging.sh"
source "${COMMON_DIR}/utils.sh"

# Backup directory
readonly BACKUP_DIR="${ARTIFACTS_DIR}/backups/$(date +%Y%m%d_%H%M%S)"

# Files to backup
readonly CONFIG_FILES=(
    "${HOME}/.zshrc"
    "${HOME}/.p10k.zsh"
    "${HOME}/.bashrc"
)

main() {
    log_info "Starting configuration backup..."
    
    # Create backup directory
    if ! ensure_directory "${BACKUP_DIR}"; then
        log_error "Failed to create backup directory"
        return 1
    fi
    
    local backed_up=0
    local skipped=0
    
    # Backup each configuration file
    for config_file in "${CONFIG_FILES[@]}"; do
        if [[ -f "${config_file}" ]]; then
            local filename=$(basename "${config_file}")
            local backup_path="${BACKUP_DIR}/${filename}"
            
            if cp "${config_file}" "${backup_path}"; then
                log_success "Backed up: ${config_file}"
                ((backed_up++))
            else
                log_error "Failed to backup: ${config_file}"
            fi
        else
            log_info "File not found, skipping: ${config_file}"
            ((skipped++))
        fi
    done
    
    # Summary
    echo ""
    log_info "Backup summary:"
    log_info "  Files backed up: ${backed_up}"
    log_info "  Files skipped: ${skipped}"
    log_info "  Backup location: ${BACKUP_DIR}"
    
    if [[ ${backed_up} -gt 0 ]]; then
        log_success "Configuration backup completed"
        return 0
    else
        log_warn "No files were backed up"
        return 0
    fi
}

# Run main function
main "$@"
