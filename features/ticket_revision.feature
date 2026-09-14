Feature: Optimistic concurrency
  As an agent sharing a ticket store with other agents
  I want a write pinned to the revision I read to be refused if the ticket moved
  So that two writers cannot lose each other's edits without either one noticing

  Background:
    Given a clean tickets directory

  Scenario: show --json carries a revision
    Given a ticket exists with ID "rev-0001" and title "contended"
    When I run "ticket show rev-0001 --json"
    Then the command should succeed
    And the output should be valid JSON
    And the JSON field "revision" should not be empty

  Scenario: the revision changes when the ticket changes
    Given a ticket exists with ID "rev-0002" and title "contended"
    When I remember the revision of ticket "rev-0002"
    And I run "ticket status rev-0002 in_progress"
    Then the command should succeed
    And the revision of ticket "rev-0002" should differ from the remembered revision

  Scenario: a write pinned to the current revision is applied
    Given a ticket exists with ID "rev-0003" and title "contended"
    When I remember the revision of ticket "rev-0003"
    And I run "ticket status rev-0003 closed --if-revision REV" with the remembered revision
    Then the command should succeed
    And ticket "rev-0003" should have field "status" with value "closed"

  Scenario: a write pinned to a stale revision exits 4
    Given a ticket exists with ID "rev-0004" and title "contended"
    When I remember the revision of ticket "rev-0004"
    And I run "ticket status rev-0004 in_progress"
    And I run "ticket status rev-0004 closed --if-revision REV" with the remembered revision
    Then the command should exit with code 4
    And the output should contain "changed since it was read"

  Scenario: a refused write changes nothing
    Given a ticket exists with ID "rev-0005" and title "contended"
    When I remember the revision of ticket "rev-0005"
    And I run "ticket status rev-0005 in_progress"
    And I run "ticket status rev-0005 closed --if-revision REV" with the remembered revision
    Then the command should exit with code 4
    And ticket "rev-0005" should have field "status" with value "in_progress"

  Scenario: a write with no pin is applied as before
    Given a ticket exists with ID "rev-0006" and title "contended"
    When I run "ticket status rev-0006 in_progress"
    And I run "ticket status rev-0006 closed"
    Then the command should succeed
    And ticket "rev-0006" should have field "status" with value "closed"

  Scenario: reject honours a stale pin
    Given a ticket exists with ID "rev-0007" and title "contended"
    When I remember the revision of ticket "rev-0007"
    And I run "ticket status rev-0007 in_progress"
    And I run "ticket reject rev-0007 --if-revision REV" with the remembered revision
    Then the command should exit with code 4
    And ticket "rev-0007" should have field "status" with value "in_progress"

  Scenario: dep honours a stale pin
    Given a ticket exists with ID "rev-0008" and title "contended"
    And a ticket exists with ID "rev-0009" and title "the blocker"
    When I remember the revision of ticket "rev-0008"
    And I run "ticket status rev-0008 in_progress"
    And I run "ticket dep rev-0008 rev-0009 --if-revision REV" with the remembered revision
    Then the command should exit with code 4
    And ticket "rev-0008" should have field "deps" with value "[]"

  Scenario: an unparseable revision is a usage error, not a conflict
    Given a ticket exists with ID "rev-0010" and title "contended"
    When I run "ticket status rev-0010 closed --if-revision"
    Then the command should exit with code 1
    And the output should contain "--if-revision requires"

  Scenario: undep honours a stale pin
    Given a ticket exists with ID "rev-0011" and title "contended"
    And a ticket exists with ID "rev-0012" and title "the blocker"
    And ticket "rev-0011" depends on "rev-0012"
    When I remember the revision of ticket "rev-0011"
    And I run "ticket status rev-0011 in_progress"
    And I run "ticket undep rev-0011 rev-0012 --if-revision REV" with the remembered revision
    Then the command should exit with code 4
    And ticket "rev-0011" should have field "deps" with value "[rev-0012]"

  Scenario: start forwards a pin rather than dropping it
    Given a ticket exists with ID "rev-0013" and title "contended"
    When I remember the revision of ticket "rev-0013"
    And I run "ticket status rev-0013 closed"
    And I run "ticket start rev-0013 --if-revision REV" with the remembered revision
    Then the command should exit with code 4
    And ticket "rev-0013" should have field "status" with value "closed"

  Scenario: reopen forwards a pin rather than dropping it
    Given a ticket exists with ID "rev-0014" and title "contended"
    When I remember the revision of ticket "rev-0014"
    And I run "ticket status rev-0014 closed"
    And I run "ticket reopen rev-0014 --if-revision REV" with the remembered revision
    Then the command should exit with code 4
    And ticket "rev-0014" should have field "status" with value "closed"
