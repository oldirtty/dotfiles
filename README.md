# ian's dotfiles

![Last Commit](https://img.shields.io/github/last-commit/oldirtty/dotfiles)
![Repo Size](https://img.shields.io/github/repo-size/oldirtty/dotfiles)
![MIT License](https://img.shields.io/badge/License-MIT-blue)
![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)
![Git](https://img.shields.io/badge/Git-F05032?logo=git&logoColor=white)
![GNU Stow](https://img.shields.io/badge/Stow-FFFFFF?logo=gnu&logoColor=black)
![Zsh](https://img.shields.io/badge/Zsh-000000?logo=zsh&logoColor=white)
![Ghostty](https://img.shields.io/badge/Ghostty-423F3E?logo=ghostty&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?logo=neovim&logoColor=white)

My personal dotfiles for setting up and maintaining Linux systems. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

| Folder      | Description                             |
| ----------- | --------------------------------------- |
| `fastfetch` | Tool for fetching system info           |
| `ghostty`   | Terminal emulator                       |
| `matugen`   | DankMaterialShell theming tool          |
| `mpv`       | Media player                            |
| `neovim`    | Terminal text editor                    |
| `niri`      | Scrollable-tiling wayland compositor    |
| `ohmyposh`  | Shell prompt engine                     |
| `scripts`   | Personal shell scripts                  |
| `spicetify` | Spotify customization                   |
| `vscodium`  | VSCode with no microslop                |
| `zen`       | Firefox-based browser                   |
| `zsh`       | Shell with plugins                      |

## Requirements

- `git`
- `curl`
- `stow`

## Quick Install

Clone and run the install script it handles everything automatically:

```bash
git clone https://github.com/old/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The script will:

- Detect your package manager (`apt`, `pacman`)
- Install requirements
- Install `zsh`, `zinit`, `fzf`, `oh-my-posh` and more zsh plugins
- Install CLI utils:  `zoxide`, `eza`, `bat` and more
- Install packages: `ghostty`, `mpv`, `neovim` and more
- Install Nerd Fonts to `~/.fonts`
- Rename `~/dotfiles` → `~/.dotfiles` and stow all configs
