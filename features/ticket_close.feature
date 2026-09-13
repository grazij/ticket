Feature: Closing a Ticket With Verification Output
  As someone reading a closed ticket
  I want closing to require the output of the verification that was run
  So that a closed ticket carries evidence the work was done, not an assertion

  Background:
    Given a clean tickets directory
    And a ticket exists with ID "clo-0001" and title "Gated close"

  Scenario: Close without verification output is refused
    When I run "ticket close clo-0001"
    Then the command should exit with code 1
    And the output should contain "close requires verification output"
    And ticket "clo-0001" should have field "status" with value "open"

  Scenario: Verification output on stdin closes the ticket
    When I run "echo 'all 42 scenarios passed' | ticket close clo-0001 --verify-output -"
    Then the command should succeed
    And the output should be "Updated clo-0001 -> closed"
    And ticket "clo-0001" should have field "status" with value "closed"

  Scenario: Verification output from stdin is recorded on the ticket
    When I run "echo 'all 42 scenarios passed' | ticket close clo-0001 --verify-output -"
    Then the command should succeed
    And ticket "clo-0001" should contain "## Verification"
    And ticket "clo-0001" should contain "all 42 scenarios passed"
    And ticket "clo-0001" should contain a timestamped verification block

  Scenario: Verification output from a file is recorded on the ticket
    Given a file "verify.log" exists outside the tickets directory containing "0 failures"
    When I run "ticket close clo-0001 --verify-output verify.log"
    Then the command should succeed
    And ticket "clo-0001" should have field "status" with value "closed"
    And ticket "clo-0001" should contain "0 failures"

  Scenario: The --verify-output=FILE form is accepted too
    Given a file "verify.log" exists outside the tickets directory containing "0 failures"
    When I run "ticket close clo-0001 --verify-output=verify.log"
    Then the command should succeed
    And ticket "clo-0001" should contain "0 failures"

  Scenario: Empty verification output is refused
    When I run "printf '' | ticket close clo-0001 --verify-output -"
    Then the command should exit with code 1
    And the output should contain "verification output is empty"
    And ticket "clo-0001" should have field "status" with value "open"

  Scenario: A missing verification output file is refused
    When I run "ticket close clo-0001 --verify-output no-such.log"
    Then the command should exit with code 1
    And the output should contain "verification output file 'no-such.log' not found"
    And ticket "clo-0001" should have field "status" with value "open"

  Scenario: --verify-output with no value is refused
    When I run "ticket close clo-0001 --verify-output"
    Then the command should exit with code 1
    And the output should contain "--verify-output requires"
    And ticket "clo-0001" should have field "status" with value "open"

  Scenario: An unknown option is refused
    When I run "ticket close clo-0001 --nonsense"
    Then the command should exit with code 1
    And the output should contain "unknown option '--nonsense'"

  Scenario: A wrong ID is still no-such-ticket, not missing evidence
    When I run "ticket close nonexistent"
    Then the command should exit with code 2
    And the output should contain "Error: ticket 'nonexistent' not found"

  Scenario: A second close appends under the same Verification heading
    Given a file "verify.log" exists outside the tickets directory containing "first run"
    When I run "ticket close clo-0001 --verify-output verify.log"
    And I run "ticket reopen clo-0001"
    And I run "echo 'second run' | ticket close clo-0001 --verify-output -"
    Then the command should succeed
    And ticket "clo-0001" should contain "first run"
    And ticket "clo-0001" should contain "second run"
    And ticket "clo-0001" should contain "## Verification" exactly 1 time

  Scenario: The raw status command is not gated
    When I run "ticket status clo-0001 closed"
    Then the command should succeed
    And ticket "clo-0001" should have field "status" with value "closed"
    And ticket "clo-0001" should not contain "## Verification"
