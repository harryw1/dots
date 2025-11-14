#!/usr/bin/env zsh
# zsh_completion.zsh - Enhanced zsh completion configuration
# Enables menu selection (scrollable completion lists) and context-aware completions
# This provides the interactive scrolling experience you wanted!

# Load completion system
autoload -Uz compinit
compinit

# Load menu selection module (enables scrollable lists with arrow keys)
zmodload zsh/complist

# Enable menu selection - THIS IS THE KEY FEATURE!
# Shows a scrollable list of completions that you can navigate with arrow keys
zstyle ':completion:*' menu select

# Show descriptions for completions
zstyle ':completion:*' format '%B%d%b'

# Group completions by type
zstyle ':completion:*' group-name ''

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Complete in the middle of words (not just at the end)
setopt COMPLETE_IN_WORD

# When completing from the middle of a word, move cursor to end
setopt ALWAYS_TO_END

# Show completion list immediately
setopt AUTO_LIST

# Automatically use menu completion after second tab press
setopt AUTO_MENU

# Show completion list on ambiguous completions
setopt LIST_AMBIGUOUS

# Don't beep on ambiguous completions
setopt NO_LIST_BEEP

# Completion colors (uses terminal's Catppuccin Frappe theme)
# Colors are set via LS_COLORS in zsh_colors.zsh
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Completion cache (speeds up repeated completions)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh

# Completion matching
# Try exact match first, then case-insensitive, then partial word
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Completion ordering
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Process completion
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

# Directory completion
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'

# History completion
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# SSH/SCP completion
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr

# Git completion (if git is installed)
if command -v git &> /dev/null; then
    zstyle ':completion:*:*:git:*' user-commands \
        'add:add file contents to the staging area' \
        'branch:list, create, or delete branches' \
        'checkout:switch branches or restore working tree files' \
        'clone:clone a repository into a new directory' \
        'commit:record changes to the repository' \
        'diff:show changes between commits, commit and working tree, etc' \
        'fetch:download objects and refs from another repository' \
        'merge:join two or more development histories together' \
        'pull:fetch from and integrate with another repository or a local branch' \
        'push:update remote refs along with associated objects' \
        'status:show the working tree status'
fi

# Pacman completion (if pacman is installed)
if command -v pacman &> /dev/null; then
    zstyle ':completion:*:pacman:*' force-list always
    zstyle ':completion:*:*:pacman:*' menu yes select
fi

# Key bindings for menu selection
# Arrow keys navigate the completion menu
bindkey -M menuselect '^[[Z' reverse-menu-complete  # Shift+Tab goes backward
bindkey -M menuselect '^[' send-break               # Escape cancels
bindkey -M menuselect '^M' accept-line              # Enter accepts

# Load zsh colors for Catppuccin Frappe completion highlighting
if [ -f ~/.config/zsh/zsh_colors.zsh ]; then
    . ~/.config/zsh/zsh_colors.zsh
fi

# Load fzf integration if available (provides fuzzy search for files, history, etc.)
if [ -f ~/.config/zsh/fzf_integration.zsh ]; then
    . ~/.config/zsh/fzf_integration.zsh
fi

