#!/usr/bin/env bash
# state.sh - State management for dotfiles installation
# Part of the modular dotfiles installation system
# Provides JSON-based state tracking and resume capability

# Requires: tui.sh for print functions

# State file location
STATE_DIR="$HOME/.local/state/dots"
STATE_FILE="$STATE_DIR/install-state.json"
MIGRATIONS_DIR="$STATE_DIR/migrations"

# Initialize state system
state_init() {
    # Create state directory if it doesn't exist
    mkdir -p "$STATE_DIR"
    mkdir -p "$MIGRATIONS_DIR"

    # If state file doesn't exist, create it with default structure
    if [ ! -f "$STATE_FILE" ]; then
        cat > "$STATE_FILE" << 'EOF'
{
  "version": "1.0",
  "install_date": "",
  "last_update": "",
  "current_phase": "",
  "status": "not_started",
  "completed_phases": [],
  "failed_phases": [],
  "installed_packages": {
    "core": [],
    "hypr-ecosystem": [],
    "theming": [],
    "development": [],
    "productivity": [],
    "aur": []
  },
  "configs_deployed": [],
  "services_enabled": [],
  "backup_dir": "",
  "migrations_applied": []
}
EOF
        # Set install date
        local install_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        jq ".install_date = \"$install_date\" | .last_update = \"$install_date\"" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi
}

# Load state into memory (returns entire JSON)
state_load() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "{}"
    fi
}

# Save state from JSON string
state_save() {
    local json="$1"
    echo "$json" > "$STATE_FILE"
}

# Update last_update timestamp
state_update_timestamp() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    jq ".last_update = \"$timestamp\"" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
}

# Mark a phase as complete
state_mark_phase_complete() {
    local phase="$1"

    # Check if already in completed_phases
    local already_complete=$(jq -r ".completed_phases[] | select(. == \"$phase\")" "$STATE_FILE")
    if [ -z "$already_complete" ]; then
        jq ".completed_phases += [\"$phase\"]" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi

    # Remove from failed_phases if present
    jq ".failed_phases = [.failed_phases[] | select(. != \"$phase\")]" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

    # Update timestamp and clear current_phase
    jq ".current_phase = \"\" | .status = \"in_progress\"" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    state_update_timestamp
}

# Mark a phase as failed
state_mark_phase_failed() {
    local phase="$1"

    # Add to failed_phases if not already there
    local already_failed=$(jq -r ".failed_phases[] | select(. == \"$phase\")" "$STATE_FILE")
    if [ -z "$already_failed" ]; then
        jq ".failed_phases += [\"$phase\"]" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi

    # Update status and timestamp
    jq ".status = \"failed\" | .current_phase = \"$phase\"" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    state_update_timestamp
}

# Set current phase
state_set_current_phase() {
    local phase="$1"
    jq ".current_phase = \"$phase\" | .status = \"in_progress\"" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    state_update_timestamp
}

# Check if a phase is completed
state_phase_completed() {
    local phase="$1"
    local is_complete=$(jq -r ".completed_phases[] | select(. == \"$phase\")" "$STATE_FILE")
    [ -n "$is_complete" ]
}

# Get current status
state_get_status() {
    jq -r '.status' "$STATE_FILE"
}

# Get current phase
state_get_current_phase() {
    jq -r '.current_phase' "$STATE_FILE"
}

# Check if installation can be resumed
state_can_resume() {
    local status=$(state_get_status)
    [ "$status" = "failed" ] || [ "$status" = "in_progress" ]
}

# Get list of completed phases
state_get_completed_phases() {
    jq -r '.completed_phases[]' "$STATE_FILE"
}

# Get list of failed phases
state_get_failed_phases() {
    jq -r '.failed_phases[]' "$STATE_FILE"
}

# Add installed package to category
state_add_package() {
    local category="$1"
    local package="$2"

    # Add package to category array if not already there
    jq ".installed_packages[\"$category\"] |= (. + [\"$package\"] | unique)" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
}

# Add multiple packages to category
state_add_packages() {
    local category="$1"
    shift
    local packages=("$@")

    for pkg in "${packages[@]}"; do
        state_add_package "$category" "$pkg"
    done
}

# Mark config as deployed
state_mark_config_deployed() {
    local config="$1"

    # Add to configs_deployed if not already there
    local already_deployed=$(jq -r ".configs_deployed[] | select(. == \"$config\")" "$STATE_FILE")
    if [ -z "$already_deployed" ]; then
        jq ".configs_deployed += [\"$config\"]" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi
}

# Mark service as enabled
state_mark_service_enabled() {
    local service="$1"

    # Add to services_enabled if not already there
    local already_enabled=$(jq -r ".services_enabled[] | select(. == \"$service\")" "$STATE_FILE")
    if [ -z "$already_enabled" ]; then
        jq ".services_enabled += [\"$service\"]" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi
}

# Set backup directory
state_set_backup_dir() {
    local backup_dir="$1"
    jq ".backup_dir = \"$backup_dir\"" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
}

# Mark installation as complete
state_mark_complete() {
    jq ".status = \"completed\" | .current_phase = \"\"" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    state_update_timestamp
}

# Reset state (fresh install)
state_reset() {
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
    fi
    state_init
    print_info "State reset - starting fresh installation"
}

# Migration management
state_mark_migration_complete() {
    local migration="$1"

    # Add to migrations_applied if not already there
    local already_applied=$(jq -r ".migrations_applied[] | select(. == \"$migration\")" "$STATE_FILE")
    if [ -z "$already_applied" ]; then
        jq ".migrations_applied += [\"$migration\"]" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi

    # Create marker file in migrations directory
    touch "$MIGRATIONS_DIR/$migration"
}

# Check if migration has been applied
state_migration_applied() {
    local migration="$1"

    # Check in state file
    local applied=$(jq -r ".migrations_applied[] | select(. == \"$migration\")" "$STATE_FILE")
    [ -n "$applied" ] || [ -f "$MIGRATIONS_DIR/$migration" ]
}

# Print state summary
state_print_summary() {
    echo ""
    print_info "Installation State Summary"
    echo ""

    local status=$(state_get_status)
    local current_phase=$(state_get_current_phase)

    echo "  Status: $status"
    if [ -n "$current_phase" ]; then
        echo "  Current Phase: $current_phase"
    fi

    echo ""
    echo "  Completed Phases:"
    local completed=$(jq -r '.completed_phases[]' "$STATE_FILE" 2>/dev/null)
    if [ -n "$completed" ]; then
        echo "$completed" | while read -r phase; do
            echo "    ✓ $phase"
        done
    else
        echo "    (none)"
    fi

    echo ""
    local failed=$(jq -r '.failed_phases[]' "$STATE_FILE" 2>/dev/null)
    if [ -n "$failed" ]; then
        echo "  Failed Phases:"
        echo "$failed" | while read -r phase; do
            echo "    ✗ $phase"
        done
        echo ""
    fi
}
