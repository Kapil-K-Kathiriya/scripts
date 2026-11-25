
#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Ubuntu Developer Terminal Setup
# Zsh + Oh My Zsh + Powerlevel10k + tmux
# Prefix: Ctrl + Space
# ============================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

if [[ "${EUID}" -eq 0 ]]; then
    echo "Run this script as your normal user, not with sudo."
    exit 1
fi

if ! command -v apt >/dev/null 2>&1; then
    echo "This script is designed for Ubuntu/Debian."
    exit 1
fi

echo
echo "============================================================"
echo "       UBUNTU DEVELOPER TERMINAL SETUP"
echo "============================================================"
echo

# ------------------------------------------------------------
# 1. Backup existing configurations
# ------------------------------------------------------------

BACKUP_DIR="$HOME/.terminal-setup-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

for file in .zshrc .tmux.conf .p10k.zsh; do
    if [[ -f "$HOME/$file" ]]; then
        cp -a "$HOME/$file" "$BACKUP_DIR/"
    fi
done

success "Configuration backups created at: $BACKUP_DIR"

# ------------------------------------------------------------
# 2. Install packages
# ------------------------------------------------------------

info "Updating packages..."

sudo apt update

info "Installing developer tools..."

sudo apt install -y \
    zsh \
    tmux \
    git \
    curl \
    wget \
    unzip \
    fzf \
    zoxide \
    fastfetch \
    wl-clipboard \
    sysstat \
    build-essential \
    fontconfig

success "Packages installed"

# ------------------------------------------------------------
# 3. Install Oh My Zsh
# ------------------------------------------------------------

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Installing Oh My Zsh..."

    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    success "Oh My Zsh already installed"
fi

# ------------------------------------------------------------
# 4. Install Powerlevel10k
# ------------------------------------------------------------

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

if [[ ! -d "$P10K_DIR" ]]; then
    info "Installing Powerlevel10k..."

    git clone --depth=1 \
        https://github.com/romkatv/powerlevel10k.git \
        "$P10K_DIR"
fi

# ------------------------------------------------------------
# 5. Install Zsh plugins
# ------------------------------------------------------------

CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$CUSTOM_DIR/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$CUSTOM_DIR/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$CUSTOM_DIR/plugins/zsh-syntax-highlighting"
fi

success "Zsh plugins installed"

# ------------------------------------------------------------
# 6. Configure Powerlevel10k
# ------------------------------------------------------------

cat > "$HOME/.p10k.zsh" <<'P10K'
# Powerlevel10k configuration

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context
    dir
    vcs
    newline
    prompt_char
)

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT='kapil@kaps'
typeset -g POWERLEVEL9K_CONTEXT_ROOT_CONTENT='root@kaps'
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=39

typeset -g POWERLEVEL9K_DIR_FOREGROUND=33
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=245
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=39

typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT='❯'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VICMD_CONTENT='❮'
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT='❯'
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VICMD_CONTENT='❮'

typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND=76
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND=196

typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VICMD_FOREGROUND=33
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VICMD_FOREGROUND=196

typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PADDING=0
typeset -g POWERLEVEL9K_PROMPT_CHAR_HEIGHT=1
typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=false

typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=245

typeset -g POWERLEVEL9K_NEWLINE_PROMPT_GAP=0
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=''

typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
P10K

# ------------------------------------------------------------
# 7. Configure Zsh
# ------------------------------------------------------------

cat > "$HOME/.zshrc" <<'ZSH'
# ============================================================
# ZSH CONFIGURATION
# ============================================================

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    sudo
    command-not-found
    z
    fzf
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ------------------------------------------------------------
# History
# ------------------------------------------------------------

HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$HOME/.zsh_history"

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt AUTO_CD
setopt CORRECT

# ------------------------------------------------------------
# Zoxide
# ------------------------------------------------------------

eval "$(zoxide init zsh)"

# ------------------------------------------------------------
# FZF
# ------------------------------------------------------------

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/.git/*" 2>/dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ------------------------------------------------------------
# Autosuggestions
# ------------------------------------------------------------

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias update='sudo apt update && sudo apt upgrade'
alias sysinfo='fastfetch'
alias ports='ss -tulpn'
alias myip='curl -s ifconfig.me'
alias c='clear'

# ------------------------------------------------------------
# Developer aliases
# ------------------------------------------------------------

alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# ------------------------------------------------------------
# Clipboard
# ------------------------------------------------------------

alias copy='wl-copy'
alias paste='wl-paste'

# ------------------------------------------------------------
# Powerlevel10k
# ------------------------------------------------------------

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ------------------------------------------------------------
# Welcome information is manual:
# Run "sysinfo" whenever needed.
# ------------------------------------------------------------
ZSH

success "Zsh configured"

# ------------------------------------------------------------
# 8. Create CPU/RAM monitoring script for tmux
# ------------------------------------------------------------

mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/tmux-stats" <<'STATS'
#!/usr/bin/env bash

# CPU usage from /proc/stat
read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
TOTAL1=$((user + nice + system + idle + iowait + irq + softirq + steal))
IDLE1=$((idle + iowait))

sleep 0.3

read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
TOTAL2=$((user + nice + system + idle + iowait + irq + softirq + steal))
IDLE2=$((idle + iowait))

TOTAL=$((TOTAL2 - TOTAL1))
IDLE=$((IDLE2 - IDLE))

if (( TOTAL > 0 )); then
    CPU=$(( (100 * (TOTAL - IDLE)) / TOTAL ))
else
    CPU=0
fi

# RAM using MemAvailable
read RAM_TOTAL RAM_AVAILABLE < <(
    awk '
        /MemTotal:/ {total=$2}
        /MemAvailable:/ {available=$2}
        END {print total, available}
    ' /proc/meminfo
)

RAM_USED=$((RAM_TOTAL - RAM_AVAILABLE))

RAM_USED_GB=$(awk -v v="$RAM_USED" 'BEGIN {printf "%.1f", v/1024/1024}')
RAM_TOTAL_GB=$(awk -v v="$RAM_TOTAL" 'BEGIN {printf "%.1f", v/1024/1024}')
RAM_PERCENT=$((RAM_USED * 100 / RAM_TOTAL))

printf " CPU %s%%  │  RAM %s/%s GB (%s%%) " \
    "$CPU" "$RAM_USED_GB" "$RAM_TOTAL_GB" "$RAM_PERCENT"
STATS

chmod +x "$HOME/.local/bin/tmux-stats"

success "CPU/RAM monitor created"

# ------------------------------------------------------------
# 9. Configure tmux
# ------------------------------------------------------------

cat > "$HOME/.tmux.conf" <<'TMUX'
# ============================================================
# TMUX CONFIGURATION
# Prefix: Ctrl + Space
# ============================================================

# Prefix
unbind C-b
unbind C-a
set-option -g prefix C-Space
bind-key C-Space send-prefix

# Terminal
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Shell
set-option -g default-shell /usr/bin/zsh
set-option -g default-command "zsh"

# General
set -g mouse on
set -g history-limit 50000
set -g renumber-windows on
set -g base-index 1
setw -g pane-base-index 1
set -g escape-time 10
set -g focus-events on

# Clipboard
set -g set-clipboard on

# ------------------------------------------------------------
# Copy mode (Vi)
# ------------------------------------------------------------

setw -g mode-keys vi

bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "wl-copy"

# Enter copy mode
bind [ copy-mode

# ------------------------------------------------------------
# Pane splitting
# ------------------------------------------------------------

bind | split-window -h
bind - split-window -v

# Keep current directory
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# ------------------------------------------------------------
# Pane navigation
# ------------------------------------------------------------

bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# ------------------------------------------------------------
# Pane resize
# ------------------------------------------------------------

bind H resize-pane -L 5
bind J resize-pane -D 5
bind K resize-pane -U 5
bind L resize-pane -R 5

# ------------------------------------------------------------
# Windows
# ------------------------------------------------------------

bind c new-window -c "#{pane_current_path}"
bind , rename-window
bind n next-window
bind p previous-window

# ------------------------------------------------------------
# Sessions
# ------------------------------------------------------------

bind d detach
bind s choose-tree -s
bind S command-prompt -I "#{session_name}" "rename-session '%%'"
bind C command-prompt -p "New session name:" "new-session -s '%%'"

# ------------------------------------------------------------
# Status bar
# ------------------------------------------------------------

set -g status on
set -g status-position top
set -g status-interval 3
set -g status-justify left
set -g status-left-length 40
set -g status-right-length 100

set -g status-style "bg=#1e1e2e,fg=#cdd6f4"

set -g status-left "#[fg=#89b4fa,bold] #S #[fg=#585b70]│ "

set -g window-status-format " #I:#W "
set -g window-status-current-format "#[fg=#1e1e2e,bg=#89b4fa,bold] #I:#W "

set -g status-right "#[fg=#89b4fa,bold] #( ~/.local/bin/tmux-stats )"

# ------------------------------------------------------------
# Pane borders
# ------------------------------------------------------------

set -g pane-border-style "fg=#45475a"
set -g pane-active-border-style "fg=#89b4fa"

# ------------------------------------------------------------
# Reload configuration
# ------------------------------------------------------------

bind r source-file ~/.tmux.conf \; display-message "tmux config reloaded"
TMUX

success "tmux configured"

# ------------------------------------------------------------
# 10. Change default shell to Zsh
# ------------------------------------------------------------

ZSH_PATH="$(command -v zsh)"

if [[ -n "$ZSH_PATH" ]]; then
    if [[ "$SHELL" != "$ZSH_PATH" ]]; then
        info "Changing default shell to Zsh..."
        chsh -s "$ZSH_PATH"
    fi
fi

# ------------------------------------------------------------
# 11. Completion
# ------------------------------------------------------------

mkdir -p "$HOME/.config"

# ------------------------------------------------------------
# 12. Final message
# ------------------------------------------------------------

echo
echo "============================================================"
echo -e "${GREEN}       TERMINAL SETUP COMPLETED SUCCESSFULLY!${NC}"
echo "============================================================"
echo
echo "Installed:"
echo "  • Zsh"
echo "  • Oh My Zsh"
echo "  • Powerlevel10k"
echo "  • Autosuggestions"
echo "  • Syntax highlighting"
echo "  • tmux"
echo "  • fzf"
echo "  • zoxide"
echo "  • fastfetch"
echo "  • CPU/RAM monitor"
echo "  • Wayland clipboard"
echo
echo "------------------------------------------------------------"
echo "TMUX SHORTCUTS"
echo "------------------------------------------------------------"
echo
echo "Prefix = Ctrl + Space"
echo
echo "  Prefix + |       Split vertical (left/right)"
echo "  Prefix + -       Split horizontal (top/bottom)"
echo "  Alt + Arrows    Navigate panes"
echo "  Prefix + H/J/K/L Resize panes"
echo "  Prefix + c       New window"
echo "  Prefix + ,       Rename window"
echo "  Prefix + n       Next window"
echo "  Prefix + p       Previous window"
echo "  Prefix + d       Detach session"
echo "  Prefix + s       Session tree"
echo "  Prefix + S       Rename session"
echo "  Prefix + C       Create named session"
echo "  Prefix + r       Reload tmux config"
echo
echo "COPY MODE"
echo "  Prefix + [       Enter copy mode"
echo "  v               Start selection"
echo "  y               Copy selection to clipboard"
echo
echo "ZSH SHORTCUTS"
echo "  Ctrl + R         Search command history"
echo "  Ctrl + T         Find files (fzf)"
echo "  Alt + C          Fuzzy change directory"
echo "  z <directory>    Jump to directory (zoxide)"
echo "  sysinfo         System information"
echo "  ll              Detailed file listing"
echo
echo "------------------------------------------------------------"
echo "NEXT:"
echo "  1. Restart terminal or log out/in"
echo "  2. Start tmux: tmux"
echo "  3. Run: p10k configure (optional)"
echo "  4. For Nerd Font icons, install a Nerd Font and select it"
echo
echo "Backup: $BACKUP_DIR"
echo
success "Enjoy your new developer terminal!"
