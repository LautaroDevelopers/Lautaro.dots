#!/bin/bash

set -e

# Colors
CYAN=$(tput setaf 14)
GREEN=$(tput setaf 10)
YELLOW=$(tput setaf 11)
RED=$(tput setaf 9)
BLUE=$(tput setaf 12)
MAGENTA=$(tput setaf 13)
NC=$(tput sgr0)

logo='
  _                _                       ____        _       
 | |    __ _ _   _| |_ __ _ _ __ ___      |  _ \  ___ | |_ ___ 
 | |   / _` | | | | __/ _` | '__/ _ \     | | | |/ _ \| __/ __|
 | |__| (_| | |_| | || (_| | | | (_) |  _ | |_| | (_) | |_\__ \
 |_____\__,_|\__,_|\__\__,_|_|  \___/  (_)|____/ \___/ \__|___/
'

echo -e "${CYAN}${logo}${NC}"
echo -e "${MAGENTA}Lautaro's Personal Dotfiles Installer${NC}"
echo ""

# Keep sudo alive
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Detect OS
is_arch() { [ -f /etc/arch-release ]; }
is_mac() { [[ "$OSTYPE" == "darwin"* ]]; }

# Helper functions
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

select_option() {
    local prompt="$1"
    shift
    local options=("$@")
    PS3="${CYAN}$prompt ${NC}"
    select opt in "${options[@]}"; do
        if [ -n "$opt" ]; then
            echo "$opt"
            break
        fi
    done
}

# ============================================
# STEP 1: Install base dependencies
# ============================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Step 1: Installing base dependencies${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if is_arch; then
    info "Detected Arch Linux"
    sudo pacman -Syu --noconfirm
    sudo pacman -S --needed --noconfirm base-devel curl file git wget unzip fontconfig
    
    # Install yay if not present
    if ! command -v yay &>/dev/null; then
        info "Installing yay (AUR helper)..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm
        cd - > /dev/null
    fi
elif is_mac; then
    info "Detected macOS"
    if ! xcode-select -p &>/dev/null; then
        xcode-select --install
    fi
else
    info "Detected Debian/Ubuntu based system"
    sudo apt-get update
    sudo apt-get install -y build-essential curl file git unzip fontconfig
fi

# Install Rust if not present
if ! command -v cargo &>/dev/null; then
    info "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# ============================================
# STEP 2: Install Homebrew
# ============================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Step 2: Installing Homebrew${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    if is_mac; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
else
    success "Homebrew already installed"
fi

# ============================================
# STEP 3: Install core tools
# ============================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Step 3: Installing core tools${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Tools installed via Homebrew (cross-platform)
BREW_PACKAGES=(
    # Shell & prompt
    zsh
    starship
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-autocomplete
    
    # Terminal tools
    zellij
    lazygit
    atuin
    zoxide
    carapace
    
    # Dev tools
    neovim
    fzf
    fd
    ripgrep
    bat
    lsd
    tree-sitter
    
    # Languages & runtimes
    node
    go
)

info "Installing Homebrew packages..."
for pkg in "${BREW_PACKAGES[@]}"; do
    if brew list "$pkg" &>/dev/null; then
        success "$pkg already installed"
    else
        info "Installing $pkg..."
        brew install "$pkg"
    fi
done

# Arch-specific packages (via pacman/yay)
if is_arch; then
    info "Installing Arch-specific packages..."
    
    PACMAN_PACKAGES=(
        htop
        openssh
        wezterm
    )
    
    for pkg in "${PACMAN_PACKAGES[@]}"; do
        if pacman -Q "$pkg" &>/dev/null; then
            success "$pkg already installed"
        else
            info "Installing $pkg..."
            sudo pacman -S --noconfirm "$pkg"
        fi
    done
    
    # AUR packages
    AUR_PACKAGES=(
        # Add AUR packages here if needed
    )
    
    for pkg in "${AUR_PACKAGES[@]}"; do
        if yay -Q "$pkg" &>/dev/null; then
            success "$pkg already installed (AUR)"
        else
            info "Installing $pkg from AUR..."
            yay -S --noconfirm "$pkg"
        fi
    done
fi

# ============================================
# STEP 4: Install Bun
# ============================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Step 4: Installing Bun${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if ! command -v bun &>/dev/null; then
    info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
else
    success "Bun already installed"
fi

# ============================================
# STEP 5: Install fnm (Node version manager)
# ============================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Step 5: Installing fnm${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if ! command -v fnm &>/dev/null; then
    info "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash
else
    success "fnm already installed"
fi

# ============================================
# STEP 6: Install OpenCode
# ============================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Step 6: Installing OpenCode${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if ! command -v opencode &>/dev/null; then
    info "Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
else
    success "OpenCode already installed"
fi

# ============================================
# STEP 7: Clone and apply dotfiles
# ============================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Step 7: Applying dotfiles${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

DOTFILES_DIR="$HOME/.dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
    warn "Dotfiles directory exists, pulling latest..."
    cd "$DOTFILES_DIR" && git pull
else
    info "Cloning dotfiles..."
    git clone https://github.com/LautaroDevelopers/Lautaro.dots.git "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

# Create config directories
mkdir -p ~/.config/nvim
mkdir -p ~/.config/zellij
mkdir -p ~/.config/lazygit
mkdir -p ~/.config/opencode
mkdir -p ~/.config/htop
mkdir -p ~/.config/warp-terminal

# Symlink configurations
info "Symlinking configurations..."

# Nvim
rm -rf ~/.config/nvim
ln -sf "$DOTFILES_DIR/nvim" ~/.config/nvim
success "nvim config linked"

# Zellij
rm -rf ~/.config/zellij
ln -sf "$DOTFILES_DIR/zellij" ~/.config/zellij
success "zellij config linked"

# Lazygit
rm -rf ~/.config/lazygit
ln -sf "$DOTFILES_DIR/lazygit" ~/.config/lazygit
success "lazygit config linked"

# Starship
ln -sf "$DOTFILES_DIR/starship.toml" ~/.config/starship.toml
success "starship config linked"

# OpenCode
rm -rf ~/.config/opencode/opencode.json
rm -rf ~/.config/opencode/themes
ln -sf "$DOTFILES_DIR/opencode/opencode.json" ~/.config/opencode/opencode.json
ln -sf "$DOTFILES_DIR/opencode/themes" ~/.config/opencode/themes
success "opencode config linked"

# Htop
rm -rf ~/.config/htop
ln -sf "$DOTFILES_DIR/htop" ~/.config/htop
success "htop config linked"

# Warp terminal
rm -rf ~/.config/warp-terminal
ln -sf "$DOTFILES_DIR/warp-terminal" ~/.config/warp-terminal
success "warp-terminal config linked"

# Shell configs
ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/.bashrc" ~/.bashrc
ln -sf "$DOTFILES_DIR/.gitconfig" ~/.gitconfig
success "shell configs linked"

# Wezterm
if [ -f "$DOTFILES_DIR/.wezterm.lua" ]; then
    ln -sf "$DOTFILES_DIR/.wezterm.lua" ~/.wezterm.lua
    success "wezterm config linked"
fi

# ============================================
# STEP 8: Install Nerd Font
# ============================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Step 8: Installing Nerd Font${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

install_font=$(select_option "Install Iosevka Term Nerd Font? " "Yes" "No")

if [ "$install_font" = "Yes" ]; then
    if is_mac; then
        brew install --cask font-iosevka-term-nerd-font
    else
        mkdir -p ~/.local/share/fonts
        if [ ! -f ~/.local/share/fonts/IosevkaTermNerdFont-Regular.ttf ]; then
            info "Downloading Iosevka Term Nerd Font..."
            wget -q -O /tmp/IosevkaTerm.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/IosevkaTerm.zip
            unzip -o /tmp/IosevkaTerm.zip -d ~/.local/share/fonts/
            fc-cache -fv
            success "Font installed"
        else
            success "Font already installed"
        fi
    fi
fi

# ============================================
# STEP 9: Set ZSH as default shell
# ============================================
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Step 9: Setting ZSH as default shell${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    info "Setting zsh as default shell..."
    sudo sh -c "grep -Fxq '$ZSH_PATH' /etc/shells || echo '$ZSH_PATH' >> /etc/shells"
    chsh -s "$ZSH_PATH"
    success "ZSH set as default shell"
else
    success "ZSH is already the default shell"
fi

# ============================================
# DONE!
# ============================================
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Installation complete! 🎉${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Installed:${NC}"
echo "  • Homebrew + core packages"
echo "  • Neovim (LazyVim config)"
echo "  • Zellij (terminal multiplexer)"
echo "  • Starship prompt"
echo "  • Lazygit"
echo "  • FZF, fd, ripgrep, bat, lsd"
echo "  • Bun, fnm, Node.js, Go"
echo "  • OpenCode"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Restart your terminal or run: exec zsh"
echo "  2. Open nvim to let LazyVim install plugins"
echo "  3. Configure your SSH keys if needed"
echo ""
echo -e "${MAGENTA}Enjoy your new setup! 🚀${NC}"
