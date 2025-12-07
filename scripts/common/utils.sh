#!/usr/bin/env bash

################################################################################
# Utility Functions
# Description: Common utility functions for all scripts
################################################################################

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if an apt package is installed
is_apt_package_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Clone git repository if it doesn't exist, update if it does
clone_if_not_exists() {
    local repo_url="$1"
    local target_dir="$2"
    
    if [[ -d "${target_dir}/.git" ]]; then
        log_info "Repository already exists at ${target_dir}, updating..."
        git -C "${target_dir}" pull --quiet || log_warn "Failed to update repository"
        return 0
    else
        log_info "Cloning ${repo_url}..."
        git clone --quiet --depth=1 "${repo_url}" "${target_dir}" || {
            log_error "Failed to clone repository"
            return 1
        }
        return 0
    fi
}

# Ensure directory exists
ensure_directory() {
    local dir="$1"
    if [[ ! -d "${dir}" ]]; then
        mkdir -p "${dir}" || {
            log_error "Failed to create directory: ${dir}"
            return 1
        }
    fi
    return 0
}

# Backup a file with timestamp
backup_file() {
    local file="$1"
    local backup_dir="${2:-${HOME}/.config/backups}"
    
    if [[ -f "${file}" ]]; then
        ensure_directory "${backup_dir}"
        local filename=$(basename "${file}")
        local backup="${backup_dir}/${filename}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "${file}" "${backup}" && log_info "Backed up ${file} to ${backup}"
    fi
}

# Check if Oh-My-Zsh is installed
is_oh_my_zsh_installed() {
    [[ -d "${HOME}/.oh-my-zsh" ]]
}

# Check if NVM is installed
is_nvm_installed() {
    [[ -d "${HOME}/.nvm" ]] || [[ -n "${NVM_DIR:-}" ]]
}

# Source NVM if available
source_nvm() {
    export NVM_DIR="${HOME}/.nvm"
    if [[ -s "${NVM_DIR}/nvm.sh" ]]; then
        source "${NVM_DIR}/nvm.sh"
        return 0
    fi
    return 1
}

# Download file with progress
download_file() {
    local url="$1"
    local output="$2"
    
    if command_exists wget; then
        wget -q --show-progress -O "${output}" "${url}"
    elif command_exists curl; then
        curl -fsSL -o "${output}" "${url}"
    else
        log_error "Neither wget nor curl is available"
        return 1
    fi
}

# Install apt package if not already installed
install_apt_package() {
    local package="$1"
    
    if is_apt_package_installed "${package}"; then
        log_info "${package} is already installed"
        return 0
    fi
    
    log_info "Installing ${package}..."
    sudo apt-get install -y -qq "${package}" || {
        log_error "Failed to install ${package}"
        return 1
    }
    log_success "${package} installed successfully"
    return 0
}
