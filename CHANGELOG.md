# Changelog

## [Unreleased]

### Changed
- Extracted `edit`, `ls`, `query`, and `migrate-beads` commands to plugins (ticket-extras)
- An unknown command now prints one line pointing at `help` instead of dumping the
  full help text to stderr (2435 bytes to 69)
- `super <cmd>` now names the plugin when no built-in exists (`tk super ls` said
  `Unknown command: ls`, though `ls` is a documented plugin command). `super` still
  refuses to run the plugin
- Distinct exit codes: 1 usage error, 2 no such ticket, 3 store unavailable. Every
  failure previously exited 1, so a caller could not tell a wrong ID from a missing
  `.tickets` directory without parsing stderr

### Added
- Plugin system: executables named `tk-<cmd>` or `ticket-<cmd>` in PATH are invoked automatically
- `super` command to bypass plugins and run built-in commands directly
- `TICKETS_DIR` and `TK_SCRIPT` environment variables exported for plugins
- `help` command lists installed plugins with descriptions
- Plugin metadata: `# tk-plugin:` comment for scripts, `--tk-describe` flag for binaries
- Multi-package distribution: `ticket-core`, `ticket-extras`, and individual plugin packages
- CI scripts for publishing to Homebrew tap and AUR

### Fixed
- Partial ID matching when `.tickets` is a symlink
- Ticket ID prefix no longer inherits `.` from a dot-prefixed directory
- Multi-word titles for `tk create` (`tk create fix the bug` kept only `bug`)
- `TICKET_PAGER=""` no longer falls back to `PAGER`
- Path traversal via ticket ID: IDs containing `/` or `..` are now rejected, so `tk show ../secret` and `tk add-note ../../secret` can no longer read or modify files outside the tickets directory
- awk bracket expressions are POSIX-portable, so `ready`, `blocked`, `ls`,
  `dep tree`, `show` and `link` work on busybox awk instead of silently
  returning wrong results with exit status 0
- `help` reports the tickets directory actually in use, instead of always
  claiming `.tickets/` when `TICKETS_DIR` is set or the store was found in a
  parent directory
- `scripts/publish-homebrew.sh` and `scripts/publish-aur.sh` now detect a
  plugin alias symlink regardless of how its target is spelled (bare,
  `./`-prefixed, or absolute), so an alias can no longer silently vanish from
  both Homebrew and AUR
- `unlink` no longer silently no-ops (while still printing success) when the
  tickets directory path contains a colon
- A partial ticket ID containing `*`, `?`, or a bracket expression is now
  matched as a literal substring of the ticket filename instead of a shell
  glob pattern, in both the core script and `ticket-edit`; previously such an
  ID could resolve to -- and mutate -- a ticket the caller never named (e.g.
  `tk close '*'` silently closing the only ticket in the store)
- Plugin dispatch now passes an explicit `TICKETS_DIR` through even when it
  does not exist yet, matching the exemption built-in `create` already gets,
  so a plugin responsible for creating its own directory (e.g.
  `migrate-beads`) is no longer blocked before it runs; `ls`, `query`, and
  `edit` now report `Error: tickets directory '<path>' does not exist`
  themselves instead of silently matching nothing (or, for `edit`, failing
  with no message at all)
- `ls`, `query`, and `edit` now report `Error: no .tickets directory found
  (searched parent directories)` -- the same message the core script gives --
  when `TICKETS_DIR` is unset and no `.tickets` exists in any parent
  directory, instead of dying with a bash `unbound variable` diagnostic

### Plugins
- ticket-edit 1.0.0: Open ticket in $EDITOR (extracted from core)
- ticket-edit 1.0.1: Handle `$EDITOR` values that carry flags (`code -w`) or contain spaces
- ticket-edit 1.0.2: Reject ticket IDs containing `/` or `..`, which could open files outside the tickets directory
- ticket-edit 1.0.3: Partial ID matching now follows a symlinked tickets directory (`find -L`), and a no-match partial ID reports "not found" instead of a bash arithmetic syntax error
- ticket-edit 1.0.4: Partial ID matching treats `*`, `?`, and bracket expressions in the ID as literal text, not a glob pattern
- ticket-edit 1.0.5: Reports a missing `TICKETS_DIR` instead of failing with no message
- ticket-edit 1.0.6: Reports `no .tickets directory found` instead of an `unbound variable` error when `TICKETS_DIR` is unset entirely
- ticket-ls 1.0.0: List tickets with optional filters (extracted from core); `ticket-list` symlink for alias
- ticket-ls 1.0.1: POSIX-portable awk bracket expressions for busybox
- ticket-ls 1.0.2: Report a missing `TICKETS_DIR` instead of silently listing nothing
- ticket-ls 1.0.3: Reports `no .tickets directory found` instead of an `unbound variable` error when `TICKETS_DIR` is unset entirely
- ticket-query 1.0.0: Output tickets as JSON, optionally filtered with jq (extracted from core)
- ticket-query 1.0.1: Fixed quoted YAML array tags producing invalid JSON, and body horizontal rules (`---`) being misparsed as frontmatter
- ticket-query 1.0.2: Strip single-quoted YAML array items the same as double-quoted ones, and escape embedded double quotes, so single-quoted tags no longer keep their quotes or break JSON
- ticket-query 1.0.3: Report a missing `TICKETS_DIR` instead of silently outputting nothing
- ticket-query 1.0.4: Scalar (non-array) frontmatter values now strip a matching outer quote pair and escape embedded `\` and `"`, the same as array items already did, so a scalar value like an assignee containing a quote no longer produces JSON `jq` can't parse
- ticket-query 1.0.5: Reports `no .tickets directory found` instead of an `unbound variable` error when `TICKETS_DIR` is unset entirely
- ticket-migrate-beads 1.0.0: Import tickets from .beads/issues.jsonl (extracted from core)

## [0.3.2] - 2026-02-03

### Fixed
- Ticket ID lookup now trims leading/trailing whitespace (fixes issue with AI agents passing extra spaces)

## [0.3.1] - 2026-01-28

### Added
- `list` command alias for `ls`
- `TICKET_PAGER` environment variable for `show` command (only when stdout is a TTY; falls back to `PAGER`)

### Changed
- Walk parent directories to find `.tickets/` directory, enabling commands from any subdirectory
- Ticket ID suffix now uses full alphanumeric (a-z0-9) instead of hex for increased entropy

### Fixed
- `dep` command now resolves partial IDs for the dependency argument
- `undep` command now resolves partial IDs and validates dependency exists
- `unlink` command now resolves partial IDs for both arguments
- `create --parent` now validates and resolves parent ticket ID
- `generate_id` now uses 3-char prefix for single-segment directory names (e.g., "plan" → "pla" instead of "p")

## [0.3.0] - 2026-01-18

### Added
- Support `TICKETS_DIR` environment variable for custom tickets directory location
- `dep cycle` command to detect dependency cycles in open tickets
- `add-note` command for appending timestamped notes to tickets
- `-a, --assignee` filter flag for `ls`, `ready`, `blocked`, and `closed` commands
- `--tags` flag for `create` command to add comma-separated tags
- `-T, --tag` filter flag for `ls`, `ready`, `blocked`, and `closed` commands

## [0.2.0] - 2026-01-04

### Added
- `--parent` flag for `create` command to set parent ticket
- `link`/`unlink` commands for symmetric ticket relationships
- `show` command displays parent title and linked tickets
- `migrate-beads` now imports parent-child and related dependencies

## [0.1.1] - 2026-01-02

### Fixed
- `edit` command no longer hangs when run in non-TTY environments

## [0.1.0] - 2026-01-02

Initial release.
