Feature: Ticket Search
  As an agent about to open a ticket
  I want search to reach tickets at any status
  So that I can tell a duplicate from new work before filing it

  Background:
    Given a clean tickets directory

  Scenario: Search finds an open ticket by title
    Given a ticket exists with ID "abc-1111" and title "quoting bug in query plugin"
    When I run "ticket search quoting"
    Then the command should succeed
    And the output should contain "abc-1111"

  Scenario: Search reaches closed tickets
    Given a ticket exists with ID "abc-2222" and title "quoting bug in migrate-beads"
    And ticket "abc-2222" has status "closed"
    When I run "ticket search quoting"
    Then the command should succeed
    And the output should contain "abc-2222"

  Scenario: Search matches the body, not only the title
    Given a ticket exists with ID "abc-3333" and title "Unrelated title"
    And ticket "abc-3333" has body text "portable bracket expression"
    When I run "ticket search bracket"
    Then the command should succeed
    And the output should contain "abc-3333"

  Scenario: Search is case-insensitive
    Given a ticket exists with ID "abc-4444" and title "Quoting Bug"
    When I run "ticket search QUOTING"
    Then the command should succeed
    And the output should contain "abc-4444"

  Scenario: Multiple terms are one phrase
    Given a ticket exists with ID "abc-5555" and title "quoting bug in query plugin"
    And a ticket exists with ID "abc-6666" and title "quoting is fine, bug elsewhere"
    When I run "ticket search quoting bug"
    Then the command should succeed
    And the output should contain "abc-5555"
    And the output should not contain "abc-6666"

  Scenario: Status filter narrows the result
    Given a ticket exists with ID "abc-7777" and title "quoting open"
    And a ticket exists with ID "abc-8888" and title "quoting done"
    And ticket "abc-8888" has status "closed"
    When I run "ticket search --status=closed quoting"
    Then the command should succeed
    And the output should contain "abc-8888"
    And the output should not contain "abc-7777"

  Scenario: No match is empty and succeeds
    Given a ticket exists with ID "abc-9999" and title "something else"
    When I run "ticket search zzzznope"
    Then the command should succeed
    And the output should be empty

  Scenario: Search with no terms is a usage error
    When I run "ticket search"
    Then the command should exit with code 1

  Scenario: An invalid status filter is a usage error
    When I run "ticket search --status=bogus quoting"
    Then the command should exit with code 1
