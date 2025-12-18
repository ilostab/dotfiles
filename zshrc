# =============================================================================
# ⚡ SUPER RESPONSIVE ZSHRC ⚡
# =============================================================================

# --- 1. Path & Environment ---
export PATH="$HOME/.local/bin:$HOME/.fzf/bin:/usr/local/bin:$PATH"


# History Config
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

# --- 2. Zinit Installer (Turbo Mode) ---
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname $ZINIT_HOME)" && \
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# --- 3. Prompt (NATIVE - 0ms Latency) ---
autoload -Uz colors && colors
setopt prompt_subst
PROMPT='%B%F{blue}%~%f%b %(?.%F{magenta}.%F{red})| %f '
RPROMPT=''

# --- 4. Plugins & Completion System ---

# Completions (TURBO - '0a')
# Load compinit and set styles
zinit ice wait'0a' lucid atinit"autoload -Uz compinit; compinit; 
    zstyle ':completion:*' use-cache on; 
    zstyle ':completion:*' cache-path \"$XDG_CACHE_HOME/zsh/.zcompcache\";
    zstyle ':completion:*' menu select; 
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}';"
zinit light zsh-users/zsh-completions

# Autosuggestions (TURBO - '0b')
zinit ice wait'0b' lucid
zinit light zsh-users/zsh-autosuggestions

# Syntax Highlighting (TURBO - '0c')
zinit ice wait'0c' lucid
zinit light zsh-users/zsh-syntax-highlighting

# --- 5. Tools (Deferred Init) ---

# Zoxide (Use 'z' to jump, 'cd' is standard)
zinit ice wait'0c' lucid id-as'zoxide' atload'eval "$(zoxide init zsh)"'
zinit snippet /dev/null

# FZF (Must load AFTER compinit)
zinit ice wait'0c' lucid id-as'fzf-config'
zinit snippet /dev/null
zinit ice wait'0c' lucid atload'
    if command -v fzf &> /dev/null; then
        [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
        eval "$(fzf --zsh 2>/dev/null)"
        bindkey "^r" fzf-history-widget
        bindkey -r "^T"
        bindkey -r "^[c"

    fi'
zinit snippet /dev/null

# --- 7. Aliases ---
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -l'
alias la='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo apt update && sudo apt upgrade'

# --- 8. Keybindings ---
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

