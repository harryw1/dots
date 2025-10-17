# Bash Aliases Configuration
# This file is automatically sourced by .bashrc during installation

# ============================================================================
# Directory Navigation & Listing
# ============================================================================

# ls aliases - colorized, grouped directories first, sorted alphabetically
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -lAh --group-directories-first --color=auto'
alias la='ls -A --group-directories-first --color=auto'
alias l='ls -CF --group-directories-first --color=auto'

# Directory shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# ============================================================================
# File Operations
# ============================================================================

# Safety nets - confirm before overwriting
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Make parent directories as needed
alias mkdir='mkdir -pv'

# ============================================================================
# System & Package Management
# ============================================================================

# Arch Linux package management shortcuts
alias pacup='sudo pacman -Syu'                    # Update system
alias pacin='sudo pacman -S'                      # Install package
alias pacrem='sudo pacman -Rns'                   # Remove package with deps
alias pacsearch='pacman -Ss'                      # Search packages
alias paclist='pacman -Qe'                        # List explicitly installed
alias pacclean='sudo pacman -Sc'                  # Clean package cache

# AUR helpers (if yay or paru is installed)
alias yayup='yay -Syu'
alias yaysearch='yay -Ss'

# System information
alias sysinfo='inxi -Fxz'                         # System info (if inxi installed)

# ============================================================================
# Git Shortcuts
# ============================================================================

alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# ============================================================================
# Utilities
# ============================================================================

# Colorize grep output
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Human-readable disk usage
alias df='df -h'
alias du='du -h'

# Show open ports
alias ports='netstat -tulanp'

# Get external IP
alias myip='curl -s ifconfig.me'

# Quick file search
alias ff='find . -type f -name'

# Process management
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias topcpu='ps aux --sort=-%cpu | head -11'
alias topmem='ps aux --sort=-%mem | head -11'

# ============================================================================
# Hyprland Specific
# ============================================================================

# Reload Hyprland configuration
alias hyprreload='hyprctl reload'

# View Hyprland errors
alias hyprerrors='hyprctl configerrors'

# Restart Waybar
alias waybar-restart='pkill waybar && waybar &'

# ============================================================================
# Convenience
# ============================================================================

# Clear screen
alias c='clear'

# Quick edit common configs
alias editbash='${EDITOR:-nano} ~/.bashrc'
alias editalias='${EDITOR:-nano} ~/.bash_aliases'
alias edithypr='${EDITOR:-nano} ~/.config/hypr/hyprland.conf'

# Reload bash configuration
alias rebash='source ~/.bashrc'

# Quick directory listing with tree (if installed)
alias tree='tree -C'
alias tree1='tree -C -L 1'
alias tree2='tree -C -L 2'

# ============================================================================
# Development
# ============================================================================

# Python
alias py='python'
alias py3='python3'
alias venv='python -m venv'
alias activate='source venv/bin/activate'

# Node.js
alias ni='npm install'
alias nid='npm install --save-dev'
alias ns='npm start'
alias nt='npm test'
alias nb='npm run build'

# Docker (if installed)
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'

# ============================================================================
# Fun
# ============================================================================

# Weather report (requires curl)
alias weather='curl wttr.in'
