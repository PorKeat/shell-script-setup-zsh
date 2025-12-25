#!/bin/bash

set -e

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Backup .zshrc with timestamp
backup_zshrc() {
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
        echo "Backup of .zshrc created."
    fi
}

# Install required packages
install_packages() {
    echo "Installing dependencies..."
    sudo apt-get update -y
    sudo apt-get install -y zsh git curl fzf nodejs npm || true
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
    if ! grep -q "plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search zsh-autopair alias-finder zsh-nvm fzf-tab zsh-completions)" "$HOME/.zshrc"; then
        sed -i '/^plugins=/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search zsh-autopair alias-finder zsh-nvm fzf-tab zsh-completions)' "$HOME/.zshrc"
    fi
}

# Set theme to Agnoster
set_theme_agnoster() {
    echo "Setting Zsh theme to Agnoster..."
    sed -i '/^ZSH_THEME=/c\ZSH_THEME="agnoster"' "$HOME/.zshrc"
}

# Set default shell to Zsh
set_default_shell() {
    local shell_path
    shell_path=$(which zsh)
    if [ "$SHELL" != "$shell_path" ]; then
        echo "Setting Zsh as the default shell..."
        sudo usermod --shell "$shell_path" "$USER"
    fi
}

# Main installation/update function
install_or_update_zsh() {
    echo "=== Installing/Updating Zsh + Oh My Zsh + Plugins + Agnoster Theme ==="
    install_packages
    backup_zshrc
    install_oh_my_zsh
    install_plugins
    set_theme_agnoster
    set_default_shell
    echo "=== Installation/Update complete! Launching Zsh now... ==="
    exec zsh
}

# Run script
install_or_update_zsh
