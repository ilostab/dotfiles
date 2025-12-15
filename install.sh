#!/bin/bash
set -e

# Define directories
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="$HOME/.config"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🛠️  Initializing Dotfiles Setup...${NC}"

# Ask for sudo upfront
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Function to backup and link files
link_file() {
    local src=$1
    local dest=$2

    # Create destination folder if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ]; then
        local current_link
        current_link=$(readlink "$dest")
        if [ "$current_link" == "$src" ]; then
            echo -e "${GREEN}    Skipping $dest (already correctly linked)${NC}"
            return
        fi
    fi

    if [ -e "$dest" ]; then
        echo -e "${YELLOW}    Backing up existing $dest to $BACKUP_DIR${NC}"
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
    fi

    echo -e "${BLUE}    Linking $src -> $dest${NC}"
    ln -sf "$src" "$dest"
}

# --- 1. System Packages ---
echo -e "\n${BLUE}📦 Installing system packages...${NC}"
if command -v apt-get &> /dev/null; then
    sudo apt-get update -y > /dev/null
    # Installed all in one go for speed
    sudo apt-get install -y zsh curl wget git unzip fontconfig build-essential tmux fzf zoxide > /dev/null
    echo -e "${GREEN}    Packages installed.${NC}"
else
    echo -e "${YELLOW}    Not on Debian/Ubuntu. Skipping apt packages.${NC}"
    # Add logic for pacman/dnf here if needed
fi

# --- 2. Shell Setup (Zsh) ---
echo -e "\n${BLUE}🐚 Setting up Zsh...${NC}"
if [[ "$SHELL" != *zsh* ]]; then
    echo -e "${YELLOW}    Changing default shell to Zsh...${NC}"
    chsh -s "$(which zsh)"
else
    echo -e "${GREEN}    Zsh is already default.${NC}"
fi

# Link zshrc
link_file "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"

# --- 3. Oh My Posh (Optimized Install) ---
echo -e "\n${BLUE}🎨 Setting up Oh My Posh...${NC}"
link_file "$DOTFILES_DIR/zen.toml" "$CONFIG_DIR/ohmyposh/zen.toml"

if ! command -v oh-my-posh &> /dev/null; then
    echo -e "${YELLOW}    Installing Oh My Posh (Binary Method)...${NC}"
    sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
    sudo chmod +x /usr/local/bin/oh-my-posh
    echo -e "${GREEN}    Oh My Posh installed.${NC}"
else
    echo -e "${GREEN}    Oh My Posh already installed.${NC}"
fi

# --- 4. Tmux ---
echo -e "\n${BLUE}🔌 Setting up Tmux...${NC}"
link_file "$DOTFILES_DIR/tmux.conf" "$CONFIG_DIR/tmux/tmux.conf"

# TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo -e "${YELLOW}    Installing TPM...${NC}"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo -e "${GREEN}    TPM already installed.${NC}"
fi

# --- 5. Fonts (Nerd Fonts) ---
echo -e "\n${BLUE}🔤 Checking Fonts...${NC}"
FONT_NAME="JetBrainsMono"
if fc-list | grep -q "$FONT_NAME"; then
    echo -e "${GREEN}    $FONT_NAME already installed.${NC}"
else
    echo -e "${YELLOW}    Installing $FONT_NAME...${NC}"
    mkdir -p /tmp/nerdfonts
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip -O /tmp/nerdfonts/font.zip
    unzip -q /tmp/nerdfonts/font.zip -d /tmp/nerdfonts
    mkdir -p "$HOME/.local/share/fonts"
    cp /tmp/nerdfonts/*.ttf "$HOME/.local/share/fonts/"
    fc-cache -fv > /dev/null
    rm -rf /tmp/nerdfonts
    echo -e "${GREEN}    Font installed.${NC}"
fi

# --- 6. Homebrew (Optional/Background) ---
# We no longer block the main install for this, as it's not strictly required for the shell to look good.
if ! command -v brew &> /dev/null; then
    echo -e "\n${YELLOW}🍺 Homebrew is not installed.${NC}"
    read -p "    Do you want to install Homebrew? (Takes ~5-10 mins) [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Configure shell env for immediate usage
        if [ -d "/home/linuxbrew/.linuxbrew" ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi
else
    echo -e "\n${GREEN}🍺 Homebrew is already installed.${NC}"
fi

echo -e "\n${GREEN}✅ Dotfiles setup complete!${NC}"
echo -e "   Restart your terminal or run: ${YELLOW}exec zsh${NC}"
