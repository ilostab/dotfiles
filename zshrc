# =============================================================================
# ⚡ HIGH PERFORMANCE ZSHRC V7 (Minimal FZF - Ctrl+R Only) ⚡
# =============================================================================

# --- 1. Zinit Installer ---
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname $ZINIT_HOME)" && \
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# --- 2. Auto-Compile (Speedup) ---
if [[ -z ${ZDOTDIR:-$HOME}/.zshrc.zwc || ${ZDOTDIR:-$HOME}/.zshrc -nt ${ZDOTDIR:-$HOME}/.zshrc.zwc ]]; then
    zcompile ${ZDOTDIR:-$HOME}/.zshrc
fi

# --- 3. Caching Helper ---
_eval_cache() {
    local cmd_name="$1"
    local init_cmd="$2"
    local cache_file="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/${cmd_name}_init.zsh"
    [[ -d "$(dirname "$cache_file")" ]] || mkdir -p "$(dirname "$cache_file")"
    if command -v "$cmd_name" &> /dev/null; then
        if [[ ! -s "$cache_file" ]]; then
            eval "$init_cmd" > "$cache_file"
        fi
        source "$cache_file"
    fi
}

# --- 4. Path Config ---
export PATH="$HOME/.local/bin:$HOME/.fzf/bin:/usr/local/bin:$PATH"
if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# =============================================================================
# 🚀 CORE PLUGINS
# =============================================================================

# 1. Initialize Completion System (Standard Zsh completion)
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# 2. Standard Completions
zinit light zsh-users/zsh-completions

# 3. Autosuggestions
# (History strategy is fastest and causes least lag)
zinit ice wait'0a' lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# 4. Syntax Highlighting
zinit ice wait'0b' lucid atinit'zpcdreplay'
zinit light zsh-users/zsh-syntax-highlighting

# 5. Snippets
zinit ice wait'1' lucid
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# =============================================================================
# 🔍 FZF CONFIGURATION (Ctrl+R ONLY)
# =============================================================================

# Attempt to load FZF using multiple methods (Modern vs Legacy)
if command -v fzf &> /dev/null; then
    # Method 1: Modern (fzf >= 0.48.0)
    if fzf --zsh &> /dev/null; then
        source <(fzf --zsh)
    # Method 2: Legacy (Debian/Ubuntu system package)
    elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    # Method 3: Manual Install (git clone)
    elif [ -f ~/.fzf.zsh ]; then
        source ~/.fzf.zsh
    fi
    
    # --- RESTRICT TO Ctrl+R ONLY ---
    # We unbind the other standard FZF widgets if they were set
    bindkey -r '^T'   # Disable Ctrl+T (File Search)
    bindkey -r '^[c'  # Disable Alt+C  (Directory Search)
fi

# Performance options for Ctrl+R
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"

# Use fast backend (fd/rg) if available, otherwise find
if command -v fdfind &> /dev/null; then
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap"
elif command -v fd &> /dev/null; then
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap"
fi

# =============================================================================
# 🎨 THEME & TOOLS (CACHED LOAD)
# =============================================================================

_eval_cache "oh-my-posh" "oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml"
_eval_cache "zoxide" "zoxide init --cmd cd zsh"

# =============================================================================
# ⚙️ SETTINGS
# =============================================================================

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# Latency Optimizations
DISABLE_MAGIC_FUNCTIONS=true
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1

# Completion Styling (Standard Zsh Grid)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select # Enables arrow-key navigation in tab menu

# Keybindings
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
# Ensure Ctrl+R is bound to FZF history if loaded, otherwise standard
# (FZF sourcing usually handles this, but this is a failsafe)
bindkey '^r' fzf-history-widget

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias c='clear'
alias ll='ls -l'
alias lh='ls -lh'
alias la='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo apt update && sudo apt upgrade'
alias refresh-cache='rm -rf ~/.cache/zsh/*_init.zsh && echo "Cache cleared. Restart shell."'
