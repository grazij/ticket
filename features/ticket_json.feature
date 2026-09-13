Feature: JSON Output
  As a script or agent driving tk
  I want machine-readable output from the core commands
  So that I parse structure instead of column-aligned text, and without needing jq

  Background:
    Given a clean tickets directory

  Scenario: ready --json emits a JSON array
    Given a ticket exists with ID "abc-1111" and title "json test"
    When I run "ticket ready --json"
    Then the command should succeed
    And the output should be valid JSON
    And the JSON should be an array of 1 item

  Scenario: blocked --json emits a JSON array
    Given a ticket exists with ID "abc-2222" and title "blocked one"
    And a ticket exists with ID "abc-3333" and title "the blocker"
    And ticket "abc-2222" depends on "abc-3333"
    When I run "ticket blocked --json"
    Then the command should succeed
    And the output should be valid JSON
    And the JSON should be an array of 1 item

  Scenario: closed --json emits a JSON array
    Given a ticket exists with ID "abc-4444" and title "done thing"
    And ticket "abc-4444" has status "closed"
    When I run "ticket closed --json"
    Then the command should succeed
    And the output should be valid JSON
    And the JSON should be an array of 1 item

  Scenario: show --json emits a JSON object with the ticket fields
    Given a ticket exists with ID "abc-5555" and title "json test"
    When I run "ticket show abc-5555 --json"
    Then the command should succeed
    And the output should be valid JSON
    And the JSON field "id" should be "abc-5555"
    And the JSON field "title" should be "json test"

  Scenario: A title containing the text separator survives JSON
    Given a ticket exists with ID "abc-6666" and title "title with ] - inside"
    When I run "ticket ready --json"
    Then the command should succeed
    And the output should be valid JSON
    And the JSON should be an array of 1 item

  Scenario: A field value containing double quotes is escaped
    Given a ticket exists with ID "abc-7777" and title "quote test"
    And ticket "abc-7777" has scalar field "assignee" set to: say "hello" loudly
    When I run "ticket ready --json"
    Then the command should succeed
    And the output should be valid JSON

  Scenario: A field value containing a backslash is escaped
    Given a ticket exists with ID "abc-8888" and title "backslash test"
    And ticket "abc-8888" has scalar field "assignee" set to: back\slash here
    When I run "ticket ready --json"
    Then the command should succeed
    And the output should be valid JSON

  Scenario: A quoted YAML scalar does not keep its quotes in JSON
    Given a ticket exists with ID "abc-9999" and title "quoted scalar"
    And ticket "abc-9999" has scalar field "assignee" set to: "alice"
    When I run "ticket ready --json"
    Then the command should succeed
    And the output should be valid JSON
    And the JSON field "0.assignee" should be "alice"

  Scenario: Text output remains the default
    Given a ticket exists with ID "abc-1010" and title "json test"
    When I run "ticket ready"
    Then the command should succeed
    And the output should contain "abc-1010"
    And the output should not contain "{"
