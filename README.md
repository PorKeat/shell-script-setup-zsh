# setup_zsh.sh

A one-shot script to set up Zsh + Oh My Zsh + plugins + Agnoster theme on macOS (M1–M4) and Linux.

**Author:** Porkeat

---

## Usage

```bash
# 1. Clone the repo
git clone https://github.com/PorKeat/shell-script-setup-zsh.git

# 2. Enter the directory
cd shell-script-setup-zsh

# 3. Make executable
chmod +x setup_zsh.sh

# 4. Run
./setup_zsh.sh
```

After it finishes, **fully restart your terminal**.

---

## What gets installed

- **Oh My Zsh** with the **Agnoster** theme
- Plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-history-substring-search`, `zsh-autopair`, `zsh-nvm`, `fzf-tab`, `zsh-completions`
- Homebrew (macOS only, if not already installed)
- **MesloLGS Nerd Font** — installed and auto-configured for Terminal.app, iTerm2, and VS Code

---

## Re-running

Safe to run again at any time — updates all plugins and refreshes your config. Your previous `.zshrc` is always backed up first.
