#!/bin/bash
set -e

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    elif [ -f /etc/redhat-release ]; then
        DISTRO="rhel"
    elif [ -f /etc/arch-release ]; then
        DISTRO="arch"
    else
        DISTRO="unknown"
    fi
    echo "Detected distribution: $DISTRO"
}

# Backup .zshrc with timestamp
backup_zshrc() {
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
        echo "Backup of .zshrc created."
    fi
}

# Install required packages based on distro
install_packages() {
    echo "Installing dependencies..."
    
    case "$DISTRO" in
        ubuntu|debian|linuxmint|pop|elementary|zorin)
            sudo apt-get update -y
            sudo apt-get install -y zsh git curl fzf nodejs npm || true
            ;;
        fedora|rhel|centos|rocky|almalinux)
            sudo dnf install -y zsh git curl fzf nodejs npm || \
            sudo yum install -y zsh git curl fzf nodejs npm || true
            ;;
        arch|manjaro|endeavouros|garuda)
            sudo pacman -Sy --noconfirm --needed zsh git curl fzf nodejs npm || true
            ;;
        opensuse*|sles)
            sudo zypper install -y zsh git curl fzf nodejs npm || true
            ;;
        gentoo)
            sudo emerge -av app-shells/zsh dev-vcs/git net-misc/curl app-shells/fzf net-libs/nodejs || true
            ;;
        void)
            sudo xbps-install -Sy zsh git curl fzf nodejs || true
            ;;
        alpine)
            sudo apk add zsh git curl fzf nodejs npm || true
            ;;
        *)
            echo "Warning: Unsupported distribution. Please install zsh, git, curl, fzf, nodejs, and npm manually."
            ;;
    esac
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
}

# Install or update plugins
install_plugins() {
    echo "Installing or updating Zsh plugins..."
    mkdir -p "$ZSH_CUSTOM/plugins"
    export GIT_TERMINAL_PROMPT=0
    
    declare -A plugins
    plugins=(
        [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
        [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
        [zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search.git"
        [zsh-autopair]="https://github.com/hlissner/zsh-autopair.git"
        [alias-finder]="https://github.com/Tarrasch/alias-finder.git"
        [zsh-nvm]="https://github.com/lukechilds/zsh-nvm.git"
        [fzf-tab]="https://github.com/Aloxaf/fzf-tab.git"
        [zsh-completions]="https://github.com/zsh-users/zsh-completions.git"
    )
    
    for plugin in "${!plugins[@]}"; do
        if [ -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
            echo "Updating $plugin..."
            git -C "$ZSH_CUSTOM/plugins/$plugin" pull --quiet || true
        else
            echo "Installing $plugin..."
            git clone --depth=1 --quiet "${plugins[$plugin]}" "$ZSH_CUSTOM/plugins/$plugin" || true
        fi
    done
    
    # Ensure .zshrc has the correct plugins line
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search zsh-autopair alias-finder zsh-nvm fzf-tab zsh-completions)" "$HOME/.zshrc"; then
            sed -i '/^plugins=/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search zsh-autopair alias-finder zsh-nvm fzf-tab zsh-completions)' "$HOME/.zshrc"
        fi
    fi
}

# Set theme to Agnoster
set_theme_agnoster() {
    echo "Setting Zsh theme to Agnoster..."
    if [ -f "$HOME/.zshrc" ]; then
        sed -i '/^ZSH_THEME=/c\ZSH_THEME="agnoster"' "$HOME/.zshrc"
    fi
}

# Set default shell to Zsh
set_default_shell() {
    local shell_path
    shell_path=$(command -v zsh)
    
    if [ -z "$shell_path" ]; then
        echo "Error: Zsh not found in PATH"
        return 1
    fi
    
    if [ "$SHELL" != "$shell_path" ]; then
        echo "Setting Zsh as the default shell..."
        
        # Check if user has sudo access
        if sudo -n true 2>/dev/null; then
            # Add zsh to /etc/shells if not already there
            if ! grep -q "$shell_path" /etc/shells; then
                echo "$shell_path" | sudo tee -a /etc/shells > /dev/null
            fi
            
            # Change shell using usermod (works on most systems)
            sudo usermod --shell "$shell_path" "$USER" 2>/dev/null || \
            sudo chsh -s "$shell_path" "$USER" 2>/dev/null || \
            chsh -s "$shell_path" || true
        else
            echo "No sudo access. Attempting to change shell without sudo..."
            chsh -s "$shell_path" || echo "Please run 'chsh -s $shell_path' manually."
        fi
    fi
}

# Main installation/update function
install_or_update_zsh() {
    echo "=== Universal Zsh + Oh My Zsh + Plugins + Agnoster Theme Setup ==="
    detect_distro
    install_packages
    backup_zshrc
    install_oh_my_zsh
    install_plugins
    set_theme_agnoster
    set_default_shell
    echo ""
    echo "=== Installation/Update complete! ==="
    echo "Please log out and log back in for the shell change to take effect."
    echo "Or run: exec zsh"
    echo ""
    
    # Ask user if they want to launch zsh now
    read -p "Launch Zsh now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        exec zsh
    fi
}

# Run script
install_or_update_zsh