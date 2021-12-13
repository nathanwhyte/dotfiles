# update zsh config directory
export ZDOTDIR="$HOME/.config/zsh/"

# set zsh default shell
export SHELL="/usr/bin/zsh"

# set default programs
export BROWSER="brave"
export EDITOR="nvim"
export TERM="alacritty"
export VISUAL="emacs"

# set up XDG directiories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# clean up $HOME
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export HISTFILE="$ZDOTDIR/.zsh_history"
export GOPATH="$XDG_DATA_HOME/go"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export LESSHISTFILE="-"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export STACK_ROOT="$XDG_DATA_HOME/stack"

# fcitx setup
export QT_IM_MODULE=fcitx
export GTK_IM_MODULE=fcitx
export SDL_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
