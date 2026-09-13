Feature: Rejecting a Ticket
  As someone deciding not to do a piece of work
  I want a status that means declined rather than done
  So that the decision survives and is not re-investigated

  Background:
    Given a clean tickets directory

  Scenario: Reject sets the rejected status
    Given a ticket exists with ID "abc-1111" and title "wont do this"
    When I run "ticket reject abc-1111 --reason \"superseded by the plugin split\""
    Then the command should succeed
    And ticket "abc-1111" should have field "status" with value "rejected"

  Scenario: The reason is recorded in the body
    Given a ticket exists with ID "abc-2222" and title "wont do this"
    When I run "ticket reject abc-2222 --reason \"superseded by the plugin split\""
    Then the command should succeed
    And ticket "abc-2222" should contain "Rejected: superseded by the plugin split"

  Scenario: A rejected ticket is not ready
    Given a ticket exists with ID "abc-3333" and title "wont do this"
    When I run "ticket reject abc-3333 --reason \"no longer needed\""
    And I run "ticket ready"
    Then the command should succeed
    And the output should not contain "abc-3333"

  Scenario: A rejected ticket is not blocked
    Given a ticket exists with ID "abc-4444" and title "wont do this"
    And a ticket exists with ID "abc-5555" and title "blocker"
    And ticket "abc-4444" depends on "abc-5555"
    When I run "ticket reject abc-4444 --reason \"no longer needed\""
    And I run "ticket blocked"
    Then the command should succeed
    And the output should not contain "abc-4444"

  Scenario: A rejected ticket is not listed as closed
    Given a ticket exists with ID "abc-6666" and title "wont do this"
    When I run "ticket reject abc-6666 --reason \"no longer needed\""
    And I run "ticket closed"
    Then the command should succeed
    And the output should not contain "abc-6666"

  Scenario: Search still finds a rejected ticket
    Given a ticket exists with ID "abc-7777" and title "quoting bug nobody will fix"
    When I run "ticket reject abc-7777 --reason \"no longer needed\""
    And I run "ticket search quoting"
    Then the command should succeed
    And the output should contain "abc-7777"

  Scenario: Search finds a rejected ticket by its reason
    Given a ticket exists with ID "abc-8888" and title "unrelated title"
    When I run "ticket reject abc-8888 --reason \"superseded by the plugin split\""
    And I run "ticket search \"plugin split\""
    Then the command should succeed
    And the output should contain "abc-8888"

  Scenario: Reject without a reason is allowed
    Given a ticket exists with ID "abc-9999" and title "wont do this"
    When I run "ticket reject abc-9999"
    Then the command should succeed
    And ticket "abc-9999" should have field "status" with value "rejected"

  Scenario: Reopen restores a rejected ticket
    Given a ticket exists with ID "abc-1010" and title "wont do this"
    When I run "ticket reject abc-1010 --reason \"no longer needed\""
    And I run "ticket reopen abc-1010"
    Then the command should succeed
    And ticket "abc-1010" should have field "status" with value "open"

  Scenario: The status verb accepts rejected
    Given a ticket exists with ID "abc-1212" and title "wont do this"
    When I run "ticket status abc-1212 rejected"
    Then the command should succeed
    And ticket "abc-1212" should have field "status" with value "rejected"

  Scenario: Rejecting an unknown ID exits 2
    When I run "ticket reject nosuchid --reason \"x\""
    Then the command should exit with code 2

  Scenario: Reject with no arguments is a usage error
    When I run "ticket reject"
    Then the command should exit with code 1
