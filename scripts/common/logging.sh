#!/usr/bin/env bash

################################################################################
# Logging Functions
# Description: Provides colored logging utilities for all scripts
################################################################################

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Log file
readonly LOG_FILE="${HOME}/.linux-setup.log"

# Initialize log file
init_log() {
    echo "=== Linux Desktop Setup - $(date '+%Y-%m-%d %H:%M:%S') ===" | tee -a "${LOG_FILE}"
}

# Log info message
log_info() {
    local message="$1"
    echo -e "${BLUE}[INFO]${NC} ${message}" | tee -a "${LOG_FILE}"
}

# Log success message
log_success() {
    local message="$1"
    echo -e "${GREEN}[SUCCESS]${NC} ${message}" | tee -a "${LOG_FILE}"
}

# Log warning message
log_warn() {
    local message="$1"
    echo -e "${YELLOW}[WARN]${NC} ${message}" | tee -a "${LOG_FILE}"
}

# Log error message
log_error() {
    local message="$1"
    echo -e "${RED}[ERROR]${NC} ${message}" | tee -a "${LOG_FILE}"
}

# Log step progress
log_step() {
    local step="$1"
    local total="$2"
    local description="$3"
    echo -e "\n${MAGENTA}[${step}/${total}]${NC} ${CYAN}${description}${NC}" | tee -a "${LOG_FILE}"
}

# Show progress indicator
show_progress() {
    local description="$1"
    echo -ne "${CYAN}${description}...${NC}\r"
}

# Clear progress indicator
clear_progress() {
    echo -ne "\033[K\r"
}
