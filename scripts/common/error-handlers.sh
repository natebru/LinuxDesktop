#!/usr/bin/env bash

################################################################################
# Error Handler Functions
# Description: Error handling and cleanup functions
################################################################################

# Generic error handler for trap
error_handler() {
    local exit_code=$1
    local line_number=$2
    log_error "Error on line ${line_number}: Command exited with status ${exit_code}"
}

# Cleanup function to be called on script exit
cleanup_on_exit() {
    local exit_code=$?
    
    if [[ ${exit_code} -ne 0 ]]; then
        log_error "Script exited with error code: ${exit_code}"
    fi
    
    return ${exit_code}
}

# Run command with error handling
run_command() {
    local cmd="$1"
    local description="${2:-Running command}"
    
    log_info "${description}..."
    
    if eval "${cmd}"; then
        log_success "${description} completed successfully"
        return 0
    else
        log_error "${description} failed"
        return 1
    fi
}

# Run command and continue on failure
run_command_soft() {
    local cmd="$1"
    local description="${2:-Running command}"
    
    log_info "${description}..."
    
    if eval "${cmd}"; then
        log_success "${description} completed successfully"
        return 0
    else
        log_warn "${description} failed, continuing..."
        return 1
    fi
}
