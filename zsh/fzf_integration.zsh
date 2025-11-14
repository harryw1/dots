#!/usr/bin/env zsh
# fzf_integration.zsh - fzf (fuzzy finder) integration for zsh
# Provides enhanced file search, history search, and command completion
# Requires: fzf package (sudo pacman -S fzf)

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    return 0
fi

# Setup fzf key bindings and completion for zsh
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
    source /usr/share/fzf/key-bindings.zsh
elif [ -f /usr/share/fzf/shell/key-bindings.zsh ]; then
    source /usr/share/fzf/shell/key-bindings.zsh
fi

# Setup fzf completion for zsh
if [ -f /usr/share/fzf/completion.zsh ]; then
    source /usr/share/fzf/completion.zsh
elif [ -f /usr/share/fzf/shell/completion.zsh ]; then
    source /usr/share/fzf/shell/completion.zsh
fi

# Enhanced history search with fzf
# Ctrl+R: Search command history
# Ctrl+T: Search files and insert into command line
# Alt+C:  Change directory with fuzzy search

# Custom fzf functions

# Fuzzy find and cd into directory
fzf-cd() {
    local dir
    dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m) &&
    cd "$dir"
}

# Fuzzy find file and open with default editor
fzf-file() {
    local file
    file=$(fzf +m -q "$1") && ${EDITOR:-nvim} "$file"
}

# Fuzzy find in git files
fzf-git() {
    local file
    file=$(git ls-files | fzf +m) && ${EDITOR:-nvim} "$file"
}

# Fuzzy kill process
fzf-kill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ -n "$pid" ]; then
        echo "$pid" | xargs kill -${1:-9}
    fi
}

# Fuzzy search git branches
fzf-git-branch() {
    local branch
    branch=$(git branch -a | sed 's/^..//' | fzf +m) &&
    git checkout $(echo "$branch" | sed "s#remotes/[^/]*/##")
}

# Fuzzy search git commits
fzf-git-log() {
    git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" | \
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
    --bind "ctrl-m:execute: (grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
    {}
    FZF-EOF"
}

# fzf options with Catppuccin Frappe colors
# Enhanced colors for both default fzf and completion menus
export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --preview 'bat --color=always --style=header,grid --line-range :300 {}'
    --color=bg+:#414559,bg:#303446,spinner:#f4b8e4,hl:#ca9ee6
    --color=fg:#c6d0f5,header:#ca9ee6,info:#8caaee,pointer:#f4b8e4
    --color=marker:#f4b8e4,fg+:#c6d0f5,prompt:#8caaee,hl+:#ca9ee6
    --color=gutter:#303446,border:#737994,query:#c6d0f5,disabled:#737994
    --color=preview-bg:#292c3c,preview-border:#414559
"

# fzf completion options (for Tab completions)
export FZF_COMPLETION_OPTS="
    --height 50%
    --layout=reverse-list
    --border
    --color=bg+:#414559,bg:#303446,spinner:#f4b8e4,hl:#ca9ee6
    --color=fg:#c6d0f5,header:#ca9ee6,info:#8caaee,pointer:#f4b8e4
    --color=marker:#f4b8e4,fg+:#c6d0f5,prompt:#8caaee,hl+:#ca9ee6
    --color=gutter:#303446,border:#737994,query:#c6d0f5,disabled:#737994
"

# Use fd (faster than find) if available
if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Use ripgrep for content search if available
if command -v rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
fi

