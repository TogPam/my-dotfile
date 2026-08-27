#!/usr/bin/env bash

# ==============================================================================
# Script tự động cài đặt dependencies và thiết lập Dotfiles
# Hỗ trợ tốt nhất: Ubuntu / Debian
# ==============================================================================

set -euo pipefail

# Màu thông báo
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Cập nhật hệ thống & cài các gói apt cơ bản
install_apt_packages() {
    log_info "Đang cập nhật danh sách gói apt..."
    sudo apt update -y

    log_info "Đang cài đặt các gói cơ bản qua apt..."
    sudo apt install -y \
        git curl wget build-essential unzip tar jq \
        zsh fzf bat lsd fastfetch kitty

    log_success "Đã cài đặt xong các gói qua apt."
}

# 2. Cài đặt eza (nếu chưa có)
install_eza() {
    if command -v eza >/dev/null 2>&1; then
        log_success "eza đã được cài đặt."
        return 0
    fi

    log_info "Đang cài đặt eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg --yes
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update -y
    sudo apt install -y eza
    log_success "Đã cài đặt eza thành công."
}

# 3. Cài đặt Oh My Posh & Themes
install_oh_my_posh() {
    if ! command -v oh-my-posh >/dev/null 2>&1; then
        log_info "Đang cài đặt Oh My Posh..."
        sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
        sudo chmod +x /usr/local/bin/oh-my-posh
    else
        log_success "Oh My Posh đã được cài đặt."
    fi

    # Tải các themes cho oh-my-posh
    if [ ! -d "$HOME/.poshthemes" ]; then
        log_info "Đang tải Oh My Posh themes..."
        mkdir -p "$HOME/.poshthemes"
        wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O "$HOME/.poshthemes/themes.zip"
        unzip -o "$HOME/.poshthemes/themes.zip" -d "$HOME/.poshthemes"
        chmod u+rw "$HOME/.poshthemes"/*.json "$HOME/.poshthemes"/*.yaml 2>/dev/null || true
        rm -f "$HOME/.poshthemes/themes.zip"
        log_success "Đã tải xong Oh My Posh themes."
    fi
}

# 4. Cài đặt Oh My Zsh & Plugins
install_zsh_config() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Đang cài đặt Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        log_success "Oh My Zsh đã được cài đặt."
    fi

    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        log_info "Đang cài zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        log_info "Đang cài zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    # zsh-vi-mode
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-vi-mode" ]; then
        log_info "Đang cài zsh-vi-mode..."
        git clone https://github.com/jeffreytse/zsh-vi-mode "$ZSH_CUSTOM/plugins/zsh-vi-mode"
    fi
}

# 5. Cài đặt Yazi (Terminal File Manager)
install_yazi() {
    if command -v yazi >/dev/null 2>&1; then
        log_success "Yazi đã được cài đặt."
        return 0
    fi

    log_info "Đang tải và cài đặt Yazi binary..."
    local TEMP_DIR
    TEMP_DIR=$(mktemp -d)
    curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest \
        | grep "browser_download_url.*x86_64-unknown-linux-musl.zip" \
        | cut -d : -f 2,3 \
        | tr -d \" \
        | wget -qi - -O "$TEMP_DIR/yazi.zip"
    
    if [ -f "$TEMP_DIR/yazi.zip" ]; then
        unzip -q "$TEMP_DIR/yazi.zip" -d "$TEMP_DIR"
        local EXTRACTED_DIR
        EXTRACTED_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "yazi*x86_64*")
        sudo cp "$EXTRACTED_DIR/yazi" /usr/local/bin/
        sudo cp "$EXTRACTED_DIR/ya" /usr/local/bin/ 2>/dev/null || true
        log_success "Đã cài đặt Yazi thành công."
    else
        log_warn "Không thể tải Yazi từ GitHub release, bạn có thể cài thủ công bằng cargo: cargo install yazi-cli yazi-fm"
    fi
    rm -rf "$TEMP_DIR"
}

# 6. Cài đặt FantasqueSansMono Nerd Font
install_fonts() {
    local FONT_DIR="$HOME/.local/share/fonts"
    if fc-list : family | grep -qi "FantasqueSansM"; then
        log_success "Font FantasqueSansMono Nerd Font đã tồn tại."
        return 0
    fi

    log_info "Đang cài đặt FantasqueSansMono Nerd Font..."
    mkdir -p "$FONT_DIR"
    wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FantasqueSansMono.zip -O /tmp/FantasqueSansMono.zip
    unzip -oq /tmp/FantasqueSansMono.zip -d "$FONT_DIR/FantasqueSansMono"
    rm -f /tmp/FantasqueSansMono.zip
    fc-cache -f -v >/dev/null 2>&1
    log_success "Đã cài đặt font thành công."
}

# 7. Tạo Symlink cho Dotfiles (sao lưu nếu file cũ đã tồn tại)
link_dotfiles() {
    log_info "Đang liên kết dotfiles vào thư mục HOME ($HOME)..."

    # Link .bashrc
    if [ -f "$DOTFILES_DIR/.bashrc" ]; then
        [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc.backup.$(date +%s)"
        ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
        log_success "Đã liên kết ~/.bashrc"
    fi

    # Link .zshrc
    if [ -f "$DOTFILES_DIR/.zshrc" ]; then
        [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"
        ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
        log_success "Đã liên kết ~/.zshrc"
    fi

    # Link .config
    mkdir -p "$HOME/.config"
    for item in "$DOTFILES_DIR/.config"/*; do
        local target="$HOME/.config/$(basename "$item")"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            mv "$target" "${target}.backup.$(date +%s)"
        fi
        ln -snf "$item" "$target"
        log_success "Đã liên kết $target"
    done

    # Cấp quyền thực thi cho các script trong eww nếu có
    if [ -d "$HOME/.config/eww" ]; then
        find "$HOME/.config/eww" -type f -name "*.sh" -exec chmod +x {} +
    fi
}

main() {
    echo -e "${GREEN}===============================================${NC}"
    echo -e "${GREEN}      BẮT ĐẦU CÀI ĐẶT DOTFILES & DEPENDENCIES  ${NC}"
    echo -e "${GREEN}===============================================${NC}"

    install_apt_packages
    install_eza
    install_oh_my_posh
    install_zsh_config
    install_yazi
    install_fonts
    link_dotfiles

    echo ""
    echo -e "${GREEN}===============================================${NC}"
    echo -e "${GREEN}           CÀI ĐẶT HOÀN TẤT THÀNH CÔNG!         ${NC}"
    echo -e "${GREEN}===============================================${NC}"
    echo -e "👉 Bạn có thể đổi shell mặc định sang Zsh: ${YELLOW}chsh -s \$(which zsh)${NC}"
    echo -e "👉 Khởi động lại terminal hoặc gõ ${YELLOW}zsh${NC} / ${YELLOW}bash${NC} để tận hưởng giao diện mới."
}

main "$@"
