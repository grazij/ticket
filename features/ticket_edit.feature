Feature: Ticket Edit
  As a user
  I want to edit tickets in my editor
  So that I can make complex changes easily

  Background:
    Given a clean tickets directory
    And a ticket exists with ID "edit-0001" and title "Editable ticket"

  Scenario: Edit in non-TTY mode shows file path
    When I run "ticket edit edit-0001" in non-TTY mode
    Then the command should succeed
    And the output should contain "Edit ticket file:"
    And the output should contain ".tickets/edit-0001.md"

  Scenario: Edit non-existent ticket
    When I run "ticket edit nonexistent"
    Then the command should fail
    And the output should contain "Error: ticket 'nonexistent' not found"

  Scenario: Edit with partial ID
    When I run "ticket edit 0001" in non-TTY mode
    Then the command should succeed
    And the output should contain "edit-0001.md"

  Scenario: Edit with an EDITOR that carries flags
    Given a fake editor named "fake-editor" that records its arguments
    When I run "ticket edit edit-0001" on a terminal with EDITOR set to "fake-editor --wait"
    Then the command should succeed
    And the editor should have received "--wait"
    And the editor should have received "edit-0001.md"

  Scenario: Edit with an EDITOR whose path contains spaces
    Given a fake editor named "my editor" that records its arguments
    When I run "ticket edit edit-0001" on a terminal with EDITOR set to "'my editor' --wait"
    Then the command should succeed
    And the editor should have received "--wait"
    And the editor should have received "edit-0001.md"

  Scenario: Path traversal in ID is rejected by edit
    Given a file "outside.md" exists outside the tickets directory containing "TOP SECRET"
    When I run "ticket edit ../outside" in non-TTY mode
    Then the command should fail
    And the output should contain "Error: invalid ticket ID '../outside'"
    And the file "outside.md" outside the tickets directory should be unchanged

  Scenario: Edit with partial ID resolves through a symlinked tickets directory
    Given a symlinked tickets directory
    And a ticket exists with ID "sym-9001" and title "Symlink edit test"
    When I run "ticket edit 9001" in non-TTY mode
    Then the command should succeed
    And the output should contain "sym-9001.md"

  Scenario: Edit reports not-found cleanly for a no-match partial ID
    When I run "ticket edit zzzz" in non-TTY mode
    Then the command should fail
    And the output should contain "Error: ticket 'zzzz' not found"
    And the output should not contain "syntax error"

  Scenario: Ambiguous partial ID is still reported for edit
    Given a ticket exists with ID "edit-0002" and title "Another editable ticket"
    When I run "ticket edit edit-000" in non-TTY mode
    Then the command should fail
    And the output should contain "Error: ambiguous ID 'edit-000' matches multiple tickets"
