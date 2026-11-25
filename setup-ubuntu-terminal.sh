#!/usr/bin/env bash
set -euo pipefail

# Portable Ubuntu terminal setup for Kapil's scripts repository.
# Tested design target: Ubuntu 24.04+; optional packages are handled gracefully.

REPO_RAW="https://raw.githubusercontent.com/Kapil-K-Kathiriya/scripts/main"
DOTFILES_URL="$REPO_RAW/dotfiles"
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; NC='\033[0m'
info(){ echo -e "${BLUE}[INFO]${NC} $*"; }
success(){ echo -e "${GREEN}[OK]${NC} $*"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $*"; }
fail(){ echo "[ERROR] $*" >&2; exit 1; }

[[ $EUID -ne 0 ]] || fail "Run as your normal user, not root/sudo."
command -v apt >/dev/null || fail "This installer supports Ubuntu/Debian apt-based systems."
command -v curl >/dev/null || fail "curl is required. Install it first with: sudo apt install curl"

BACKUP_DIR="$HOME/.terminal-setup-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
for f in .zshrc .p10k.zsh .tmux.conf; do
  [[ -f "$HOME/$f" ]] && cp -a "$HOME/$f" "$BACKUP_DIR/"
done
if [[ -x "$HOME/.local/bin/tmux-stats" ]]; then cp -a "$HOME/.local/bin/tmux-stats" "$BACKUP_DIR/"; fi
success "Backup created: $BACKUP_DIR"

info "Updating apt package lists..."
sudo apt update

PACKAGES=(zsh tmux git curl wget unzip fzf zoxide wl-clipboard sysstat build-essential fontconfig)
info "Installing required packages..."
if ! sudo apt install -y "${PACKAGES[@]}"; then
  fail "Required package installation failed. Fix apt errors and rerun the script."
fi

# Fastfetch is optional: package may not exist in some Ubuntu mirror configurations.
if apt-cache show fastfetch >/dev/null 2>&1; then
  info "Installing optional fastfetch..."
  sudo apt install -y fastfetch || warn "Fastfetch installation failed; continuing without it."
else
  warn "Fastfetch package is unavailable in enabled repositories; skipping it."
fi

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  success "Oh My Zsh already installed."
fi

CUSTOM_DIR="$HOME/.oh-my-zsh/custom"
mkdir -p "$CUSTOM_DIR/themes" "$CUSTOM_DIR/plugins"

# Powerlevel10k
if [[ ! -d "$CUSTOM_DIR/themes/powerlevel10k" ]]; then
  info "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$CUSTOM_DIR/themes/powerlevel10k"
fi

# Zsh plugins
if [[ ! -d "$CUSTOM_DIR/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM_DIR/plugins/zsh-autosuggestions"
fi
if [[ ! -d "$CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM_DIR/plugins/zsh-syntax-highlighting"
fi

# Fetch dotfiles from the repository's single source of truth.
mkdir -p "$HOME/.local/bin"
fetch_dotfile() {
  local name="$1" destination="$2"
  info "Downloading $name..."
  curl -fL --retry 3 "$DOTFILES_URL/$name" -o "$destination" || fail "Failed to download $name from GitHub. Check that dotfiles/$name exists on main."
}
fetch_dotfile .zshrc "$HOME/.zshrc"
fetch_dotfile .p10k.zsh "$HOME/.p10k.zsh"
fetch_dotfile .tmux.conf "$HOME/.tmux.conf"
fetch_dotfile tmux-stats "$HOME/.local/bin/tmux-stats"
chmod +x "$HOME/.local/bin/tmux-stats"

# TPM (Tmux Plugin Manager), required by the repository tmux config.
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  info "Installing tmux Plugin Manager (TPM)..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# Make Zsh the default login shell.
ZSH_PATH="$(command -v zsh)"
if [[ -n "$ZSH_PATH" && "${SHELL:-}" != "$ZSH_PATH" ]]; then
  info "Setting Zsh as the default shell..."
  chsh -s "$ZSH_PATH" || warn "Could not change shell automatically; run: chsh -s $ZSH_PATH"
fi

# Optional Fastfetch alias only; no startup invocation.
if ! grep -q 'alias sysinfo=' "$HOME/.zshrc"; then
  printf '\n# Optional system information\nalias sysinfo="command -v fastfetch >/dev/null && fastfetch || echo Fastfetch-not-installed"\n' >> "$HOME/.zshrc"
fi

# Validate the downloaded shell config where possible.
bash -n "$HOME/.local/bin/tmux-stats" || fail "tmux-stats has a syntax error."

success "Terminal setup finished."
echo
echo "Next: restart terminal, then run: tmux"
echo "Backup: $BACKUP_DIR"
echo
echo "TMUX PREFIX: Ctrl + Space"
echo "Prefix + | : Split left/right"
echo "Prefix + - : Split top/bottom"
echo "Alt + arrows: Move between panes"
echo "Prefix + H/J/K/L: Resize panes"
echo "Prefix + c: New window | Prefix + ,: Rename window"
echo "Prefix + d: Detach | Prefix + s: Session tree | Prefix + r: Reload config"
echo "Copy mode: Prefix + [ then v to select, y to copy (Wayland clipboard)"
echo "Zsh: Ctrl+R history search, Ctrl+T file search, Alt+C directory search, z <dir> jump"
echo "Optional: run sysinfo (if fastfetch is available)"
