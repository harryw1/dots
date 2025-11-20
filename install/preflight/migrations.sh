#!/usr/bin/env bash
# migrations.sh - Migration system for dotfiles updates
# Part of the modular dotfiles installation system
# Runs migrations for breaking changes and updates

# Directory containing migration scripts
MIGRATIONS_SOURCE_DIR="$DOTFILES_DIR/migrations"

# Run all pending migrations
run_migrations() {
    print_step 6 6 "Checking for migrations"

    # Skip in dry-run mode
    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would check and run migrations"
        log_info "Skipping migrations - dry run mode"
        echo ""
        return 0
    fi

    # Check if migrations directory exists
    if [ ! -d "$MIGRATIONS_SOURCE_DIR" ]; then
        print_info "No migrations directory found - skipping"
        log_info "No migrations to run"
        echo ""
        return 0
    fi

    # Get list of migration files (sorted by timestamp in filename)
    mapfile -t migrations < <(find "$MIGRATIONS_SOURCE_DIR" -name "*.sh" -type f | sort)

    if [ ${#migrations[@]} -eq 0 ]; then
        print_info "No migrations to run"
        log_info "No migration scripts found"
        echo ""
        return 0
    fi

    print_info "Found ${#migrations[@]} migration(s)"
    log_info "Found ${#migrations[@]} migration(s) to check"

    local applied_count=0
    local skipped_count=0

    for migration_file in "${migrations[@]}"; do
        local migration_name
        migration_name=$(basename "$migration_file" .sh)

        # Check if migration has already been applied
        if state_migration_applied "$migration_name"; then
            ((skipped_count++))
            log_info "Skipping already applied migration: $migration_name"
            continue
        fi

        print_info "Running migration: $migration_name"
        log_info "Executing migration: $migration_name"

        # Source and execute the migration
        if source "$migration_file"; then
            state_mark_migration_complete "$migration_name"
            print_success "Migration completed: $migration_name"
            log_success "Migration completed: $migration_name"
            ((applied_count++))
        else
            print_error "Migration failed: $migration_name"
            log_error "Migration failed: $migration_name"
            return 1
        fi
    done

    if [ $applied_count -eq 0 ]; then
        print_success "All migrations already applied ($skipped_count skipped)"
        log_info "All migrations already applied"
    else
        print_success "Applied $applied_count migration(s), skipped $skipped_count"
        log_success "Applied $applied_count migrations"
    fi

    echo ""
    return 0
}
