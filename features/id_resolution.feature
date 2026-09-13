Feature: Ticket ID Resolution
  As a user
  I want to use partial ticket IDs
  So that I can work faster without typing full IDs

  Background:
    Given a clean tickets directory

  Scenario: Exact ID match
    Given a ticket exists with ID "abc-1234" and title "Test ticket"
    When I run "ticket show abc-1234"
    Then the command should succeed
    And the output should contain "id: abc-1234"

  Scenario: Partial ID match by suffix
    Given a ticket exists with ID "abc-1234" and title "Test ticket"
    When I run "ticket show 1234"
    Then the command should succeed
    And the output should contain "id: abc-1234"

  Scenario: Partial ID match by prefix
    Given a ticket exists with ID "abc-1234" and title "Test ticket"
    When I run "ticket show abc"
    Then the command should succeed
    And the output should contain "id: abc-1234"

  Scenario: Partial ID match by substring
    Given a ticket exists with ID "abc-1234" and title "Test ticket"
    When I run "ticket show c-12"
    Then the command should succeed
    And the output should contain "id: abc-1234"

  Scenario: Ambiguous ID error
    Given a ticket exists with ID "abc-1234" and title "First ticket"
    And a ticket exists with ID "abc-5678" and title "Second ticket"
    When I run "ticket show abc"
    Then the command should fail
    And the output should contain "Error: ambiguous ID 'abc' matches multiple tickets"

  Scenario: Non-existent ID error
    When I run "ticket show nonexistent"
    Then the command should fail
    And the output should contain "Error: ticket 'nonexistent' not found"

  Scenario: Exact match takes precedence
    Given a ticket exists with ID "abc" and title "Short ID ticket"
    And a ticket exists with ID "abc-1234" and title "Long ID ticket"
    When I run "ticket show abc"
    Then the command should succeed
    And the output should contain "id: abc"
    And the output should contain "Short ID ticket"

  Scenario: ID resolution works with status command
    Given a ticket exists with ID "test-9999" and title "Test ticket"
    When I run "ticket status 9999 in_progress"
    Then the command should succeed
    And ticket "test-9999" should have field "status" with value "in_progress"

  Scenario: ID resolution works with dep command
    Given a ticket exists with ID "dep-aaaa" and title "Main"
    And a ticket exists with ID "dep-bbbb" and title "Dependency"
    When I run "ticket dep aaaa bbbb"
    Then the command should succeed
    And ticket "dep-aaaa" should have "bbbb" in deps

  Scenario: ID resolution works with link command
    Given a ticket exists with ID "link-cccc" and title "First"
    And a ticket exists with ID "link-dddd" and title "Second"
    When I run "ticket link cccc dddd"
    Then the command should succeed
    And ticket "link-cccc" should have "link-dddd" in links

  Scenario: Partial ID match works with symlinked tickets directory
    Given a symlinked tickets directory
    And a ticket exists with ID "sym-1234" and title "Symlink test"
    When I run "ticket show 1234"
    Then the command should succeed
    And the output should contain "id: sym-1234"

  Scenario: Path traversal in ID is rejected when appending a note
    Given a file "outside.md" exists outside the tickets directory containing "TOP SECRET"
    And a ticket exists with ID "abc-1234" and title "Test ticket"
    When I run "ticket add-note ../outside \"injected note\""
    Then the command should fail
    And the output should contain "Error: invalid ticket ID '../outside'"
    And the file "outside.md" outside the tickets directory should be unchanged

  Scenario: Path traversal in ID is rejected from a nested tickets directory
    Given a file "outside.md" exists outside the tickets directory containing "TOP SECRET"
    And a separate tickets directory exists at "nested/.tickets" with ticket "nst-1234" titled "Nested ticket"
    When I run "ticket add-note ../../outside \"injected note\"" with TICKETS_DIR set to "nested/.tickets"
    Then the command should fail
    And the output should contain "Error: invalid ticket ID '../../outside'"
    And the file "outside.md" outside the tickets directory should be unchanged

  Scenario: Path traversal in ID is rejected when showing a ticket
    Given a file "outside.md" exists outside the tickets directory containing "TOP SECRET"
    And a ticket exists with ID "abc-1234" and title "Test ticket"
    When I run "ticket show ../outside"
    Then the command should fail
    And the output should contain "Error: invalid ticket ID '../outside'"
    And the output should not contain "TOP SECRET"

  Scenario: Path traversal in ID is rejected when changing status
    Given a file "outside.md" exists outside the tickets directory containing "TOP SECRET"
    And a ticket exists with ID "abc-1234" and title "Test ticket"
    When I run "ticket status ../outside closed"
    Then the command should fail
    And the output should contain "Error: invalid ticket ID '../outside'"
    And the file "outside.md" outside the tickets directory should be unchanged

  Scenario: ID containing dots and underscores still resolves
    Given a ticket exists with ID "v1.2-beta_x" and title "Dotted ID ticket"
    When I run "ticket show v1.2-beta_x"
    Then the command should succeed
    And the output should contain "id: v1.2-beta_x"

  Scenario: Partial match of an ID containing dots still resolves
    Given a ticket exists with ID "v1.2-beta_x" and title "Dotted ID ticket"
    When I run "ticket show 1.2"
    Then the command should succeed
    And the output should contain "id: v1.2-beta_x"
