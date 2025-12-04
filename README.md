# Zsh Setup Script

This script automates the installation and configuration of **Zsh**, **Oh My Zsh**, popular **Zsh plugins**, and the **Agnoster theme** on Linux systems.

It also sets Zsh as your default shell.

---

## Features

- Installs required dependencies: `zsh`, `git`, `curl`, `fzf`, `nodejs`, `npm`.
- Installs **Oh My Zsh** framework.
- Installs useful Zsh plugins:
  - `zsh-autosuggestions`
  - `zsh-syntax-highlighting`
  - `zsh-history-substring-search`
  - `zsh-autopair`
  - `alias-finder`
  - `zsh-nvm`
  - `fzf-tab`
  - `zsh-completions`
- Sets the **Agnoster theme**.
- Sets Zsh as the default shell.
- Backs up existing `.zshrc` file automatically.

---

## Requirements

- Linux (tested on Ubuntu/Debian)
- `sudo` privileges
- `curl` and `git` (script installs them if missing)

---

## Usage

Make the script executable:

```bash
chmod +x zsh-setup.sh
```

Run the script to install Zsh and configure it:

./zsh-setup.sh
