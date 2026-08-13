export GLFW_IM_MODULE=none
export XMODIFIERS="@im=fcitx"
export GTK_IM_MODULE="fcitx"
export QT_IM_MODULE="fcitx"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=( 
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh


# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r #without fastfetch
#pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
fastfetch -c $HOME/.config/fastfetch/config.jsonc

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias cls='clear'

# Hàm ép con trỏ thanh đứng mọi lúc
_always_beam_cursor() {
    echo -ne '\e[5 q'
}

# Ép khi chuẩn bị nhận lệnh
autoload -Uz add-zsh-hook
add-zsh-hook preexec _always_beam_cursor
add-zsh-hook precmd _always_beam_cursor

# Ép trực tiếp vào trình soạn thảo dòng lệnh của Zsh khi gõ chữ
zle-keymap-select() { _always_beam_cursor }
zle-line-init() { _always_beam_cursor }
zle-line-finish() { _always_beam_cursor }

zle -N zle-keymap-select
zle -N zle-line-init
zle -N zle-line-finish

export PATH="$HOME/.local/bin:$PATH"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


# Added by Antigravity CLI installer
export PATH="/home/togpam/.local/bin:$PATH"
