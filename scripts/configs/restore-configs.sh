#!/usr/bin/env bash

################################################################################
# Restore Configuration Script
# Description: Restores configuration files from most recent backup
################################################################################

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_DIR="${SCRIPT_DIR}/../common"
ARTIFACTS_DIR="${SCRIPT_DIR}/../../artifacts"

# Source common utilities
source "${COMMON_DIR}/logging.sh"
source "${COMMON_DIR}/utils.sh"

# Backup base directory
readonly BACKUP_BASE_DIR="${ARTIFACTS_DIR}/backups"

main() {
    log_info "Starting configuration restore..."
    
    # Find most recent backup directory
    if [[ ! -d "${BACKUP_BASE_DIR}" ]]; then
        log_error "Backup directory not found: ${BACKUP_BASE_DIR}"
        return 1
    fi
    
    local latest_backup=$(find "${BACKUP_BASE_DIR}" -maxdepth 1 -type d -name "????????_??????" | sort -r | head -n 1)
    
    if [[ -z "${latest_backup}" ]]; then
        log_error "No backups found in ${BACKUP_BASE_DIR}"
        return 1
    fi
    
    log_info "Found backup: ${latest_backup}"
    
    # Restore each file found in backup
    local restored=0
    local failed=0
    
    for backup_file in "${latest_backup}"/*; do
        if [[ -f "${backup_file}" ]]; then
            local filename=$(basename "${backup_file}")
            local target_file="${HOME}/${filename}"
            
            log_info "Restoring ${filename}..."
            
            if cp "${backup_file}" "${target_file}"; then
                log_success "Restored: ${target_file}"
                ((restored++))
            else
                log_error "Failed to restore: ${target_file}"
                ((failed++))
            fi
        fi
    done
    
    # Summary
    echo ""
    log_info "Restore summary:"
    log_info "  Files restored: ${restored}"
    log_info "  Files failed: ${failed}"
    
    if [[ ${restored} -gt 0 ]]; then
        log_success "Configuration restore completed"
        return 0
    else
        log_warn "No files were restored"
        return 1
    fi
}

# Run main function
main "$@"
