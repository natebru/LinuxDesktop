#!/usr/bin/env bash

################################################################################
# System Check Functions
# Description: Pre-flight and system validation checks
################################################################################

# Check internet connectivity
check_internet_connectivity() {
    log_info "Checking internet connectivity..."
    
    # Try to ping common DNS servers
    if ping -c 1 8.8.8.8 >/dev/null 2>&1 || ping -c 1 1.1.1.1 >/dev/null 2>&1; then
        log_success "Internet connection detected"
        return 0
    fi
    
    # Try to resolve a domain name
    if host github.com >/dev/null 2>&1; then
        log_success "Internet connection detected"
        return 0
    fi
    
    log_error "No internet connection detected"
    return 1
}

# Check available disk space (in MB)
check_disk_space() {
    local path="${1:-/home}"
    local required_mb="${2:-2048}"
    
    log_info "Checking disk space on ${path}..."
    
    local available_mb=$(df -BM "${path}" | awk 'NR==2 {print $4}' | sed 's/M//')
    
    if [[ ${available_mb} -ge ${required_mb} ]]; then
        log_success "Sufficient disk space available: ${available_mb}MB"
        return 0
    else
        log_error "Insufficient disk space. Required: ${required_mb}MB, Available: ${available_mb}MB"
        return 1
    fi
}

# Check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        return 1
    fi
    return 0
}

# Check if running on Linux
check_linux_os() {
    if [[ "$(uname -s)" != "Linux" ]]; then
        log_error "This script is designed for Linux systems only"
        return 1
    fi
    return 0
}

# Check sudo access
check_sudo_access() {
    log_info "Checking sudo access..."
    
    if sudo -n true 2>/dev/null; then
        log_success "Sudo access confirmed"
        return 0
    fi
    
    log_info "Sudo access required. You may be prompted for your password."
    if sudo -v; then
        log_success "Sudo access granted"
        return 0
    else
        log_error "Failed to obtain sudo access"
        return 1
    fi
}

# Update apt package lists
update_apt_cache() {
    log_info "Updating package lists..."
    
    if sudo apt-get update -qq 2>&1 | grep -q "Err:"; then
        log_warn "Some package repositories had errors during update"
        return 1
    fi
    
    log_success "Package lists updated"
    return 0
}

# Check if snap is installed
check_snap_installed() {
    if command_exists snap; then
        return 0
    fi
    return 1
}

# Install snap if not present
ensure_snap_installed() {
    if check_snap_installed; then
        log_info "Snap is already installed"
        return 0
    fi
    
    log_info "Installing snapd..."
    if sudo apt-get install -y -qq snapd; then
        log_success "Snapd installed successfully"
        return 0
    else
        log_error "Failed to install snapd"
        return 1
    fi
}
