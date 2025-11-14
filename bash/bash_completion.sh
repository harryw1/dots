#!/usr/bin/env bash
# bash_completion.sh - Enhanced bash completion configuration
# Enables tab completion for commands, file paths, and more
# Note: bash-completion is optional - fzf provides fuzzy search as an alternative

# Enable programmable completion features
if ! shopt -oq posix; then
    # Source system bash completion if available (optional - can be disabled)
    # bash-completion provides context-aware completions (e.g., git branches, package names)
    # fzf provides fuzzy search as an alternative/addition
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi

    # Enable completion for aliases (works with or without bash-completion)
    if [ -f ~/.bash_aliases ]; then
        # Enable alias expansion for completion
        # Only works if bash-completion is installed (provides _complete_alias function)
        if type _complete_alias &> /dev/null; then
            complete -F _complete_alias $(alias | cut -d'=' -f1 | cut -d' ' -f2)
        fi
    fi

    # Enhanced completion options for interactive scrolling
    # Case-insensitive completion (optional - uncomment if desired)
    # bind "set completion-ignore-case on"
    
    # Show all completions immediately if ambiguous (displays the list)
    bind "set show-all-if-ambiguous on"
    
    # Show completions on first tab press
    bind "set show-all-if-unmodified on"
    
    # Enable menu completion for interactive cycling through options
    # This allows you to press Tab to cycle through completions
    bind "set menu-complete-display-prefix on"
    
    # Colored completion stats (colors the completion matches)
    # This uses terminal colors to highlight matches
    bind "set colored-stats on"
    
    # Colored completion prefix (colors the common prefix)
    bind "set colored-completion-prefix on"
    
    # Page completions (use less/more for long lists)
    bind "set page-completions on"
    
    # Menu completion keybindings for interactive scrolling
    # Tab: First press shows all completions, subsequent presses cycle through them
    # This gives you the list first, then allows cycling
    bind '"\t": complete'
    bind '"\e[Z": menu-complete-backward'  # Shift+Tab cycles backward
    
    # After showing completions, Tab cycles through them
    # This is handled automatically by bash when show-all-if-ambiguous is on
    
    # Arrow key navigation (alternative to Tab cycling)
    # Up/Down arrows can also cycle through completions
    # Note: These work in menu-complete mode
    # bind '"\e[A": menu-complete-backward'  # Up arrow (uncomment if desired)
    # bind '"\e[B": menu-complete'           # Down arrow (uncomment if desired)
fi

# Load bash colors for Catppuccin Frappe completion highlighting
if [ -f ~/.config/bash/bash_colors.sh ]; then
    . ~/.config/bash/bash_colors.sh
fi

# Load fzf integration if available (provides fuzzy search for files, history, etc.)
# fzf works independently of bash-completion and provides interactive fuzzy search
if [ -f ~/.config/bash/fzf_integration.sh ]; then
    . ~/.config/bash/fzf_integration.sh
fi

