Feature: Exit Codes
  As a caller driving tk from a script or an agent
  I want a failure's exit code to say which kind of failure it was
  So that I can act on it without parsing stderr

  # 1 usage error, 2 no such ticket, 3 store unavailable.

  Scenario: A resolvable ticket exits 0
    Given a clean tickets directory
    And a ticket exists with ID "abc-1234" and title "Test ticket"
    When I run "ticket show abc-1234"
    Then the command should exit with code 0

  Scenario: An unknown ticket ID exits 2
    Given a clean tickets directory
    When I run "ticket show nosuchid"
    Then the command should exit with code 2

  Scenario: An ambiguous partial ID exits 2
    Given a clean tickets directory
    And a ticket exists with ID "abc-1111" and title "First"
    And a ticket exists with ID "abc-2222" and title "Second"
    When I run "ticket show abc"
    Then the command should exit with code 2

  Scenario: A bad ID on a dependency command exits 2
    Given a clean tickets directory
    And a ticket exists with ID "abc-1234" and title "Test ticket"
    When I run "ticket dep nosuchid abc-1234"
    Then the command should exit with code 2

  Scenario: An unknown command exits 1
    Given a clean tickets directory
    When I run "ticket bogusverb"
    Then the command should exit with code 1

  Scenario: A malformed ID is a usage error, not a missing ticket
    Given a clean tickets directory
    When I run "ticket show bad/id"
    Then the command should exit with code 1

  Scenario: An invalid status value exits 1
    Given a clean tickets directory
    And a ticket exists with ID "abc-1234" and title "Test ticket"
    When I run "ticket status abc-1234 bogus"
    Then the command should exit with code 1

  Scenario: A missing tickets directory exits 3
    Given the tickets directory does not exist
    When I run "ticket ready"
    Then the command should exit with code 3
