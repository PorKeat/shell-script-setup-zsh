# Universal Zsh Setup Script

This script automates the installation and configuration of Zsh, Oh My Zsh, popular plugins, and the Agnoster theme across various Linux distributions.

## Features

-   **Distribution Detection**: Automatically identifies your Linux distribution (Ubuntu, Debian, Fedora, Arch, openSUSE, Gentoo, Void, Alpine, etc.) and uses the correct package manager.
-   **Dependency Installation**: Installs essential packages like `zsh`, `git`, `curl`, `fzf`, `nodejs`, and `npm`.
-   **Oh My Zsh Installation**: Installs Oh My Zsh if it's not already present.
-   **Plugin Management**:
    -   Installs and keeps updated a comprehensive set of Zsh plugins:
        -   `zsh-autosuggestions`
        -   `zsh-syntax-highlighting`
        -   `zsh-history-substring-search`
        -   `zsh-autopair`
        -   `alias-finder`
        -   `zsh-nvm`
        -   `fzf-tab`
        -   `zsh-completions`
    -   Ensures your `.zshrc` is configured to load these plugins.
-   **Agnoster Theme**: Sets the popular Agnoster theme for a visually appealing terminal experience.
-   **Default Shell Configuration**: Prompts to set Zsh as your default shell, handling `sudo` permissions gracefully.
-   **Safe Backup**: Creates a timestamped backup of your existing `.zshrc` file before making any changes.

## Usage

1.  **Download the script:**
    ```bash
    git clone https://github.com/your-username/shell-script-setup-zsh.git
    cd shell-script-setup-zsh
    ```
    (Replace `https://github.com/your-username/shell-script-setup-zsh.git` with the actual repository URL)

2.  **Make the script executable:**
    ```bash
    chmod +x setup-zsh.sh
    ```

3.  **Run the script:**
    ```bash
    ./setup-zsh.sh
    ```

The script will guide you through the process, install necessary components, and prompt you to set Zsh as your default shell.



## Customization

You can customize the plugins and theme directly within the `setup-zsh.sh` script if you wish to add or remove specific components.



## Troubleshooting


Feel free to open an issue or contribute if you have suggestions or encounter problems!