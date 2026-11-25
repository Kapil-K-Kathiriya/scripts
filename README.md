# Ubuntu Developer Terminal Setup

A reusable setup script to quickly configure a clean Ubuntu machine with a productivity-focused developer terminal environment.

The setup includes **Zsh, Oh My Zsh, Powerlevel10k, Tmux, useful CLI tools, plugins, and custom configurations**.

The goal is to get a consistent development environment running on a new Ubuntu machine with a single command.

---

## Features

- **Zsh** – Modern shell experience
- **Oh My Zsh** – Zsh framework and plugin management
- **Powerlevel10k** – Fast, customizable terminal prompt
- **Tmux** – Terminal multiplexer with custom shortcuts and status bar
- **Zsh Autosuggestions** – Suggest commands from history
- **Zsh Syntax Highlighting** – Highlight commands as you type
- **FZF** – Fuzzy finder
- **Zoxide** – Smart directory navigation
- **Fastfetch** – Optional system information display
- **Tmux Stats** – Custom system monitoring utility
- Automatic configuration backups before changes
- Custom dotfiles pulled from this repository
- Designed for reuse across multiple Ubuntu machines

---

## Installation

Run the following command on a fresh Ubuntu machine:

```bash
curl -fsSL https://raw.githubusercontent.com/Kapil-K-Kathiriya/scripts/main/setup-ubuntu-terminal.sh -o setup.sh && bash setup.sh
```

The installer will automatically install and configure the available tools and apply the configurations.

> The script runs using Bash explicitly to avoid shell compatibility issues.

---

## Tools Installed

| Tool | Purpose |
|---|---|
| Zsh | Powerful interactive shell |
| Oh My Zsh | Zsh configuration framework |
| Powerlevel10k | Terminal prompt customization |
| Tmux | Terminal multiplexing |
| FZF | Fuzzy search |
| Zoxide | Smart directory navigation |
| Git | Version control |
| Curl | HTTP requests |
| Build Essential | Compilation tools |
| Sysstat | System performance monitoring |
| Tmux Stats | Custom CPU/RAM/system monitoring |

Some packages, such as Fastfetch, are optional and may be skipped if unavailable in the Ubuntu repositories.

---

## Tmux Shortcuts

The custom Tmux configuration uses **Ctrl + Space** as the prefix key.

| Shortcut | Action |
|---|---|
| `Ctrl + Space` | Tmux prefix |
| `Prefix + \|` | Split left/right |
| `Prefix + -` | Split top/bottom |
| `Prefix + Alt + Arrow` | Move between panes |
| `Prefix + H/J/K/L` | Resize panes |
| `Prefix + c` | New window |
| `Prefix + ,` | Rename window |
| `Prefix + d` | Detach session |
| `Prefix + s` | Session tree |
| `Prefix + r` | Reload config |
| `Prefix + v` | Copy mode |
| `Prefix + Space` | Toggle pane zoom |

---

## Zsh Shortcuts

| Shortcut | Action |
|---|---|
| `Ctrl + R` | Search command history |
| `Ctrl + T` | FZF file search |
| `Alt + C` | FZF directory search |
| `z <directory>` | Jump to a directory using Zoxide |

---

## Configuration Structure

The repository contains reusable terminal configuration files (dotfiles) that are applied by the installer.

```text
scripts/
├── setup-ubuntu-terminal.sh
└── dotfiles/
    ├── .zshrc
    ├── .p10k.zsh
    ├── .tmux.conf
    └── tmux-stats
```

---

## Backup & Safety

Before modifying existing configurations, the installer creates a backup directory.

Example:

```text
~/.terminal-setup-backup-YYYYMMDD-HHMMSS/
```

Existing configuration files are backed up before being replaced.

---

## Updating

To update your terminal setup in the future, rerun:

```bash
curl -fsSL https://raw.githubusercontent.com/Kapil-K-Kathiriya/scripts/main/setup-ubuntu-terminal.sh -o setup.sh && bash setup.sh
```

---

## Supported Environment

- Ubuntu 24.04 LTS and compatible releases
- Bash
- Internet connection required
- `sudo` privileges required for package installation

---

## Notes

- Restart your terminal after installation.
- If Zsh is not your current shell, log out and back in or start Zsh manually.
- Fastfetch is optional and will not prevent setup from completing if unavailable.
- Configuration backups are retained in your home directory.

---

## Author

**Kapil Kathiriya**

GitHub: [Kapil-K-Kathiriya](https://github.com/Kapil-K-Kathiriya)

---

*Automate your Ubuntu developer terminal setup and keep your environment consistent across machines.*
