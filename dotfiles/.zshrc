# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Disable Powerlevel10k instant prompt to prevent initialization warnings
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Autosuggestions appearance
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
# ============================================================
# ZSH CONFIGURATION
# ============================================================

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    sudo
    history
    command-not-found
    z
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------

alias ll="ls -lah"
alias la="ls -A"
alias l="ls -CF"
alias cls="clear"

alias gs="git status"
alias gp="git pull"
alias gl="git log --oneline --graph --decorate"

alias update="sudo apt update && sudo apt upgrade"
alias reload="source ~/.zshrc"

# ------------------------------------------------------------
# Zoxide - smarter directory navigation
# ------------------------------------------------------------

eval "$(zoxide init zsh)"

# ------------------------------------------------------------
# FZF - fuzzy search
# ------------------------------------------------------------

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ------------------------------------------------------------
# Fastfetch - system information
# ------------------------------------------------------------

#fastfetch

# ------------------------------------------------------------
# Powerlevel10k configuration
# ------------------------------------------------------------

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
