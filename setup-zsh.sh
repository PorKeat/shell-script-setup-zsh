#!/bin/bash
# ══════════════════════════════════════════════════════════════
#  Universal Zsh + Oh My Zsh + Plugins + Agnoster Setup Script
# ══════════════════════════════════════════════════════════════
set -e

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────
section() {
    echo ""
    echo "──────────────────────────────────────────"
    echo "  $1"
    echo "──────────────────────────────────────────"
}

# ─────────────────────────────────────────────
# 1. Detect OS / distro
# ─────────────────────────────────────────────
detect_distro() {
    section "Detecting OS"
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    case "$OS" in
        Darwin)
            DISTRO="macos"
            ;;
        Linux)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO="$ID"
            elif [ -f /etc/redhat-release ]; then
                DISTRO="rhel"
            elif [ -f /etc/arch-release ]; then
                DISTRO="arch"
            else
                DISTRO="unknown"
            fi
            ;;
        *)
            DISTRO="unknown"
            ;;
    esac

    echo "  OS: $OS | Arch: $ARCH | Distro: $DISTRO"
}

# ─────────────────────────────────────────────
# 2. Bootstrap Homebrew (macOS only)
# ─────────────────────────────────────────────
setup_homebrew() {
    if [ "$DISTRO" != "macos" ]; then return; fi

    section "Homebrew Setup"

    if ! command -v brew &>/dev/null; then
        echo "  Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    echo "  Homebrew ready: $(brew --prefix)"
}

# ─────────────────────────────────────────────
# 3. Install packages
# ─────────────────────────────────────────────
install_packages() {
    section "Installing Packages"

    case "$DISTRO" in
        macos)
            brew install git curl fzf node 2>/dev/null || true
            echo "  macOS zsh: $(zsh --version)"
            ;;
        ubuntu|debian|linuxmint|pop|elementary|zorin)
            sudo apt-get update -y
            sudo apt-get install -y zsh git curl fzf nodejs npm || true
            ;;
        fedora|rhel|centos|rocky|almalinux)
            sudo dnf install -y zsh git curl fzf nodejs npm 2>/dev/null || \
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
            echo "  Warning: Unknown distro. Install zsh git curl fzf nodejs npm manually."
            ;;
    esac
}

# ─────────────────────────────────────────────
# 4. Install Oh My Zsh
# ─────────────────────────────────────────────
install_oh_my_zsh() {
    section "Oh My Zsh"

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "  Installing Oh My Zsh..."
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
            "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "  Already installed — updating..."
        git -C "$HOME/.oh-my-zsh" pull --quiet || true
    fi
}

# ─────────────────────────────────────────────
# 5. Install / update plugins
# ─────────────────────────────────────────────
install_plugins() {
    section "Zsh Plugins"

    local ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    mkdir -p "$ZSH_CUSTOM/plugins"
    export GIT_TERMINAL_PROMPT=0

    plugin_names=(
        zsh-autosuggestions
        zsh-syntax-highlighting
        zsh-history-substring-search
        zsh-autopair
        zsh-nvm
        fzf-tab
        zsh-completions
    )

    plugin_urls=(
        "https://github.com/zsh-users/zsh-autosuggestions.git"
        "https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "https://github.com/zsh-users/zsh-history-substring-search.git"
        "https://github.com/hlissner/zsh-autopair.git"
        "https://github.com/lukechilds/zsh-nvm.git"
        "https://github.com/Aloxaf/fzf-tab.git"
        "https://github.com/zsh-users/zsh-completions.git"
    )

    local i=0
    while [ $i -lt ${#plugin_names[@]} ]; do
        local plugin="${plugin_names[$i]}"
        local url="${plugin_urls[$i]}"
        local dir="$ZSH_CUSTOM/plugins/$plugin"

        if [ -d "$dir" ]; then
            echo "  Updating $plugin..."
            git -C "$dir" pull --quiet || true
        else
            echo "  Installing $plugin..."
            git clone --depth=1 --quiet "$url" "$dir" || true
        fi

        i=$((i + 1))
    done
}

# ─────────────────────────────────────────────
# 6. Write a clean .zshrc
# ─────────────────────────────────────────────
write_zshrc() {
    section "Writing .zshrc"

    if [ -f "$HOME/.zshrc" ]; then
        local backup="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
        cp "$HOME/.zshrc" "$backup"
        echo "  Backed up existing .zshrc → $backup"
    fi

    local BREW_PREFIX=""
    if [ "$DISTRO" = "macos" ]; then
        if [ -f /opt/homebrew/bin/brew ]; then
            BREW_PREFIX="/opt/homebrew"
        elif [ -f /usr/local/bin/brew ]; then
            BREW_PREFIX="/usr/local"
        fi
    fi

    cat > "$HOME/.zshrc" << 'ZSHRC_HEADER'
# ══════════════════════════════════════════
#  .zshrc — managed by setup_zsh.sh
# ══════════════════════════════════════════

ZSHRC_HEADER

    if [ -n "$BREW_PREFIX" ]; then
        cat >> "$HOME/.zshrc" << BREW_BLOCK
# ── Homebrew ──────────────────────────────
if [ -f "${BREW_PREFIX}/bin/brew" ]; then
  eval "\$(${BREW_PREFIX}/bin/brew shellenv)"
fi

BREW_BLOCK
    fi

    cat >> "$HOME/.zshrc" << 'ZSHRC_BODY'
# ── Oh My Zsh ─────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"

# ── zsh-completions: load via fpath BEFORE compinit/OMZ ──
ZSH_COMPLETIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions/src"
if [ -d "$ZSH_COMPLETIONS_DIR" ]; then
  fpath=("$ZSH_COMPLETIONS_DIR" $fpath)
fi

# ── Plugins ───────────────────────────────
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  zsh-autopair
  zsh-nvm
  fzf-tab
)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "[zshrc] Warning: Oh My Zsh not found at $ZSH — skipping."
fi

# ── Completions ───────────────────────────
autoload -Uz compinit && compinit

# ── History ───────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ── fzf shell integration ─────────────────
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ── Key bindings: history search ──────────
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# ── Aliases ───────────────────────────────
alias ll='ls -lAh'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias gp='git pull'
alias reload='source ~/.zshrc'

ZSHRC_BODY

    echo "  .zshrc written successfully."
}

# ─────────────────────────────────────────────
# 7. fzf shell integration
# ─────────────────────────────────────────────
setup_fzf() {
    if [ "$DISTRO" = "macos" ]; then
        local fzf_install
        fzf_install="$(brew --prefix)/opt/fzf/install"
        if [ -f "$fzf_install" ]; then
            echo "  Setting up fzf shell integration..."
            "$fzf_install" --all --no-update-rc 2>/dev/null || true
        fi
    fi
}

# ─────────────────────────────────────────────
# 8. Set Zsh as default shell
# ─────────────────────────────────────────────
set_default_shell() {
    section "Default Shell"

    local shell_path
    shell_path="$(command -v zsh)"

    if [ -z "$shell_path" ]; then
        echo "  Error: zsh not found in PATH."
        return 1
    fi

    if ! grep -qF "$shell_path" /etc/shells 2>/dev/null; then
        echo "$shell_path" | sudo tee -a /etc/shells > /dev/null
        echo "  Added $shell_path to /etc/shells"
    fi

    if [ "$SHELL" = "$shell_path" ]; then
        echo "  Already using zsh ($shell_path) — no change needed."
        return 0
    fi

    echo "  Changing default shell to $shell_path ..."

    if [ "$DISTRO" = "macos" ]; then
        chsh -s "$shell_path" || echo "  Tip: Run manually → chsh -s $shell_path"
    else
        if sudo -n true 2>/dev/null; then
            sudo usermod --shell "$shell_path" "$USER" 2>/dev/null || \
            sudo chsh -s "$shell_path" "$USER" 2>/dev/null || \
            chsh -s "$shell_path" || true
        else
            chsh -s "$shell_path" || echo "  Tip: Run manually → chsh -s $shell_path"
        fi
    fi
}

# ─────────────────────────────────────────────
# 9. Install Nerd Font + auto-configure terminals
#    macOS only
# ─────────────────────────────────────────────
setup_font() {
    if [ "$DISTRO" != "macos" ]; then return; fi

    section "Nerd Font (MesloLGS NF)"

    # ── Install font via Homebrew ──────────────────────────
    if brew list --cask font-meslo-lg-nerd-font &>/dev/null 2>&1; then
        echo "  MesloLGS NF already installed — skipping."
    else
        echo "  Installing MesloLGS NF..."
        brew tap homebrew/cask-fonts 2>/dev/null || true
        brew install --cask font-meslo-lg-nerd-font 2>/dev/null && \
            echo "  Font installed successfully." || \
            echo "  ⚠ Font install failed — you may need to set it manually."
    fi

    # ── VS Code ───────────────────────────────────────────
    # Settings file can be written directly — fully automatic
    local vscode_settings="$HOME/Library/Application Support/Code/User/settings.json"
    if [ -f "$vscode_settings" ]; then
        echo "  Configuring VS Code integrated terminal font..."
        if ! grep -q "terminal.integrated.fontFamily" "$vscode_settings"; then
            sed -i '' 's/}[[:space:]]*$/,\n    "terminal.integrated.fontFamily": "MesloLGS NF"\n}/' \
                "$vscode_settings" 2>/dev/null || true
        fi
        echo "  VS Code: font set to MesloLGS NF ✔"
    fi

    # ── iTerm2 ────────────────────────────────────────────
    # PlistBuddy can write directly to iTerm2 preferences
    local iterm_plist="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
    if [ -f "$iterm_plist" ]; then
        echo "  Configuring iTerm2 font..."
        /usr/libexec/PlistBuddy \
            -c "Set :'New Bookmarks':0:'Normal Font' 'MesloLGSNF-Regular 13'" \
            "$iterm_plist" 2>/dev/null && \
            echo "  iTerm2: font set to MesloLGS NF 13pt ✔" || \
            echo "  ⚠ iTerm2: set font manually → Preferences → Profiles → Text → Font → MesloLGS NF"
    fi

    # ── Terminal.app ──────────────────────────────────────
    # AppleScript can set the font on the Basic profile
    if osascript -e 'id of app "Terminal"' &>/dev/null 2>&1; then
        echo "  Configuring Terminal.app font..."
        osascript <<'APPLESCRIPT' 2>/dev/null && \
            echo "  Terminal.app: font set to MesloLGS NF 13pt ✔" || \
            echo "  ⚠ Terminal.app: set font manually → Preferences → Profiles → Text → Font → MesloLGS NF"
tell application "Terminal"
    set targetProfile to first settings set whose name is "Basic"
    set font name of targetProfile to "MesloLGSNF-Regular"
    set font size of targetProfile to 13
end tell
APPLESCRIPT
    fi

    echo ""
    echo "  Font setup complete. Restart your terminal to see the changes."
}

# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════╗"
    echo "║   Zsh + Oh My Zsh + Plugins + Agnoster Setup      ║"
    echo "║   macOS Apple Silicon (M1–M4) + Linux             ║"
    echo "╚════════════════════════════════════════════════════╝"

    detect_distro
    setup_homebrew       # macOS only: installs brew + sets PATH
    install_packages     # installs git, fzf, node, etc.
    install_oh_my_zsh    # installs/updates OMZ
    install_plugins      # clones/updates all plugins
    write_zshrc          # writes clean .zshrc
    setup_fzf            # fzf shell integration
    set_default_shell    # chsh to zsh
    setup_font           # install MesloLGS NF + auto-configure terminals

    echo ""
    echo "╔════════════════════════════════════════════════════╗"
    echo "║  All done! 🎉                                      ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo ""
    echo "  → Fully restart your terminal to apply all changes."
    echo ""

    printf "  Launch Zsh now? (y/n) "
    read -r REPLY
    echo
    if echo "$REPLY" | grep -iq "^y"; then
        exec zsh
    fi
}

main