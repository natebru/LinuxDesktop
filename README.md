# Linux Desktop Setup

Automated setup scripts for configuring a Linux desktop environment with terminal customizations, development tools, and applications.

## Features

- **Terminal Setup**: Zsh, Oh-My-Zsh, Powerlevel10k theme, and useful plugins
- **Fonts**: Powerline and MesloLGS NF fonts for beautiful terminal display
- **Development Tools**: NVM, Node.js (LTS + latest), npm
- **Desktop Applications**: Brave browser and more
- **Configuration Management**: Automatic backup and restore of config files
- **Idempotent**: Safe to run multiple times without breaking existing installations
- **Error Handling**: Comprehensive logging and graceful error handling

## Quick Start

### Full Installation

Run the complete setup with prompts:

```bash
./setup.sh
```

Run without prompts (auto-accept all):

```bash
./setup.sh -y
```

### Selective Installation

Skip specific components:

```bash
# Skip desktop applications
./setup.sh --skip-desktop-apps

# Skip terminal setup and fonts
./setup.sh --skip-terminal --skip-fonts

# Install only development tools
./setup.sh --skip-terminal --skip-fonts --skip-desktop-apps --skip-configs -y
```

## Usage

### Command-Line Options

```
./setup.sh [OPTIONS]

Options:
  --skip-terminal       Skip terminal setup (zsh, oh-my-zsh, etc.)
  --skip-dev-tools      Skip development tools (nvm, node, etc.)
  --skip-desktop-apps   Skip desktop applications (browsers, etc.)
  --skip-fonts          Skip font installation
  --skip-configs        Skip configuration file application
  -y, --yes             Skip all confirmation prompts
  -h, --help            Show help message
```

### Examples

```bash
# Full installation with prompts
./setup.sh

# Full installation without prompts
./setup.sh -y

# Install everything except desktop apps
./setup.sh --skip-desktop-apps

# Only install terminal and fonts (no dev tools or apps)
./setup.sh --skip-dev-tools --skip-desktop-apps -y

# Install everything but don't apply custom configs
./setup.sh --skip-configs
```

## What Gets Installed

### Terminal Components
- **Zsh**: Modern, feature-rich shell
- **Oh-My-Zsh**: Framework for managing Zsh configuration
- **Powerlevel10k**: Beautiful and fast Zsh theme
- **Plugins**:
  - zsh-autosuggestions: Command suggestions based on history
  - zsh-syntax-highlighting: Syntax highlighting for commands

### Fonts
- **Powerline Fonts**: Icon fonts for terminal themes
- **MesloLGS NF**: Nerd Font variant recommended for Powerlevel10k
  - Regular, Bold, Italic, Bold Italic variants

### Development Tools
- **NVM**: Node Version Manager for managing Node.js versions
- **Node.js LTS**: Long-term support version
- **Node.js Latest**: Most recent stable version
- **npm**: Node package manager (included with Node.js)

### Desktop Applications
- **Brave Browser**: Privacy-focused web browser

### Configuration Files
The script will apply your custom configurations from the `artifacts/` directory:
- `.zshrc`: Zsh configuration
- `.p10k.zsh`: Powerlevel10k theme configuration

## Project Structure

```
.
├── setup.sh                     # Master orchestration script
├── README.md                    # This file
├── scripts/
│   ├── common/                  # Shared utilities
│   │   ├── logging.sh          # Logging functions
│   │   ├── utils.sh            # Utility functions
│   │   ├── checks.sh           # System checks
│   │   └── error-handlers.sh   # Error handling
│   ├── terminal/               # Terminal setup scripts
│   │   ├── install-zsh.sh
│   │   ├── install-oh-my-zsh.sh
│   │   └── install-zsh-plugins.sh
│   ├── fonts/                  # Font installation scripts
│   │   ├── install-powerline-fonts.sh
│   │   └── install-nerd-fonts.sh
│   ├── dev-tools/              # Development tools
│   │   └── install-nvm.sh
│   ├── desktop-apps/           # Desktop applications
│   │   └── install-browsers.sh
│   ├── configs/                # Configuration management
│   │   ├── backup-configs.sh
│   │   ├── apply-zsh-config.sh
│   │   ├── apply-p10k-config.sh
│   │   └── restore-configs.sh
│   └── legacy/                 # Archived old scripts
└── artifacts/
    ├── .zshrc                  # Your Zsh configuration
    ├── .p10k.zsh               # Your Powerlevel10k config
    └── backups/                # Timestamped config backups
```

## Safety Features

### Automatic Backups
Before applying configurations, the script automatically backs up your existing config files to `artifacts/backups/` with timestamps.

### Restore Previous Configurations
If you need to restore your previous configurations:

```bash
bash scripts/configs/restore-configs.sh
```

### Idempotency
All scripts check if software is already installed before attempting installation, making them safe to run multiple times.

### Logging
All operations are logged to `~/.linux-setup.log` for troubleshooting.

## Post-Installation

### Terminal Configuration

After installation, restart your terminal or run:

```bash
exec zsh
```

Configure Powerlevel10k:

```bash
p10k configure
```

### Verify Installations

Check installed versions:

```bash
# Zsh
zsh --version

# Node.js
node --version

# npm
npm --version

# NVM
nvm --version
```

## Requirements

- **Operating System**: Linux (Debian/Ubuntu-based)
- **Permissions**: Non-root user with sudo access
- **Internet**: Active internet connection
- **Disk Space**: At least 2GB free space
- **Package Manager**: apt-get

## Troubleshooting

### Log File
Check the log file for detailed error messages:
```bash
cat ~/.linux-setup.log
```

### Manual Script Execution
You can run individual scripts manually:
```bash
# Install just Zsh
bash scripts/terminal/install-zsh.sh

# Install just NVM and Node
bash scripts/dev-tools/install-nvm.sh
```

### Restore Backups
If something goes wrong with configurations:
```bash
bash scripts/configs/restore-configs.sh
```

### Zsh Not Default Shell
If Zsh wasn't set as your default shell:
```bash
chsh -s $(which zsh)
```

### NVM Not Available After Installation
Source your shell configuration:
```bash
source ~/.zshrc
```

## Customization

### Adding Your Own Configurations
Place your custom configuration files in the `artifacts/` directory:
- `.zshrc` - Your Zsh configuration
- `.p10k.zsh` - Your Powerlevel10k theme settings

### Extending the Scripts
The modular structure makes it easy to add new components:

1. Create a new script in the appropriate `scripts/` subdirectory
2. Source the common utilities at the top
3. Implement idempotency checks
4. Call your script from `setup.sh`

Example structure for a new script:
```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_DIR="${SCRIPT_DIR}/../common"

source "${COMMON_DIR}/logging.sh"
source "${COMMON_DIR}/utils.sh"

main() {
    log_info "Starting installation..."
    # Your installation logic here
    log_success "Installation complete"
}

main "$@"
```

## License

This project is provided as-is for personal use.

## Contributing

Feel free to submit issues or pull requests for improvements!

