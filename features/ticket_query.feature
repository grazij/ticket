Feature: Ticket Query
  As a user
  I want to query tickets as JSON
  So that I can process ticket data programmatically

  Background:
    Given a clean tickets directory

  Scenario: Query all tickets as JSONL
    Given a ticket exists with ID "query-001" and title "First ticket"
    And a ticket exists with ID "query-002" and title "Second ticket"
    When I run "ticket query"
    Then the command should succeed
    And the output should be valid JSONL
    And the output should contain "query-001"
    And the output should contain "query-002"

  Scenario: Query with jq filter
    Given a ticket exists with ID "query-001" and title "Open ticket"
    And a ticket exists with ID "query-002" and title "Closed ticket"
    And ticket "query-002" has status "closed"
    When I run "ticket query '.status == \"open\"'"
    Then the command should succeed
    And the output should contain "query-001"
    And the output should not contain "query-002"

  Scenario: Query includes all fields
    Given a ticket exists with ID "query-001" and title "Full ticket"
    When I run "ticket query"
    Then the command should succeed
    And the JSONL output should have field "id"
    And the JSONL output should have field "status"
    And the JSONL output should have field "deps"
    And the JSONL output should have field "links"
    And the JSONL output should have field "type"
    And the JSONL output should have field "priority"

  Scenario: Query with no tickets
    When I run "ticket query"
    Then the output should be empty

  Scenario: Query arrays are JSON arrays
    Given a ticket exists with ID "query-001" and title "Deps ticket"
    And a ticket exists with ID "query-002" and title "Dependency"
    And ticket "query-001" depends on "query-002"
    When I run "ticket query"
    Then the command should succeed
    And the JSONL deps field should be a JSON array

  Scenario: Query preserves already-quoted tags as valid JSON
    Given a ticket exists with ID "query-001" and title "Quoted tags ticket"
    And ticket "query-001" has tags value: ["a", "b"]
    When I run "ticket query"
    Then the command should succeed
    And the output should be valid JSONL
    And the JSONL field "tags" should equal ["a", "b"]

  Scenario: Query keeps unquoted tags as valid JSON
    Given a ticket exists with ID "query-001" and title "Unquoted tags ticket"
    And ticket "query-001" has tags value: [a, b]
    When I run "ticket query"
    Then the command should succeed
    And the output should be valid JSONL
    And the JSONL field "tags" should equal ["a", "b"]

  Scenario: Query converts single-quoted tags to valid JSON
    Given a ticket exists with ID "query-001" and title "Single quoted tags ticket"
    And ticket "query-001" has tags value: ['a', 'b']
    When I run "ticket query"
    Then the command should succeed
    And the output should be valid JSONL
    And the JSONL field "tags" should equal ["a", "b"]

  Scenario: Query escapes a double quote embedded in a single-quoted tag
    Given a ticket exists with ID "query-001" and title "Embedded quote tag ticket"
    And ticket "query-001" has tags value: ['a"b']
    When I run "ticket query"
    Then the command should succeed
    And the output should be valid JSONL
    And the JSONL field "tags" should equal ["a\"b"]

  Scenario: Query keeps an apostrophe inside an unquoted tag
    Given a ticket exists with ID "query-001" and title "Apostrophe tag ticket"
    And ticket "query-001" has tags value: [don't, b]
    When I run "ticket query"
    Then the command should succeed
    And the output should be valid JSONL
    And the JSONL field "tags" should equal ["don't", "b"]

  Scenario: Query keeps an apostrophe inside a double-quoted tag
    Given a ticket exists with ID "query-001" and title "Quoted apostrophe tag ticket"
    And ticket "query-001" has tags value: ["don't", "b"]
    When I run "ticket query"
    Then the command should succeed
    And the output should be valid JSONL
    And the JSONL field "tags" should equal ["don't", "b"]

  Scenario: Query ignores a markdown horizontal rule in the ticket body
    Given a ticket exists with ID "query-001" and title "HR body ticket"
    And ticket "query-001" has a horizontal rule followed by "foo: bar" in the body
    When I run "ticket query"
    Then the command should succeed
    And the JSONL output should not have field "foo"

  Scenario: Query parses a normal body with no horizontal rule
    Given a ticket exists with ID "query-001" and title "Normal body ticket"
    When I run "ticket query"
    Then the command should succeed
    And the JSONL output should have field "id"
    And the JSONL output should not have field "foo"
