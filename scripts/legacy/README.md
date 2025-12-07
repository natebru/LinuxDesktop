# Legacy Scripts

This directory contains the original scripts that have been replaced by the new modular system.

## Archived Files

- `install-programs.sh` - Original monolithic script for terminal setup and dev tools
- `install-software.sh` - Original desktop applications installer (incomplete)
- `config-copy.sh` - Original configuration copy script (no backups)

## Why These Were Replaced

The original scripts had several issues:
- No error handling or idempotency checks
- No logging or progress indicators
- Monolithic structure (hard to maintain)
- No backup functionality
- Missing safety checks

## New System

These have been replaced by the modular system in:
- `scripts/terminal/` - Terminal setup scripts
- `scripts/dev-tools/` - Development tools scripts
- `scripts/desktop-apps/` - Desktop applications scripts
- `scripts/fonts/` - Font installation scripts
- `scripts/configs/` - Configuration management with backups
- `scripts/common/` - Shared utilities

Use `setup.sh` at the root to run the new system.

## Keeping These Scripts

These scripts are kept for reference purposes only. They are not maintained and should not be used.
