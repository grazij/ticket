Feature: POSIX awk portability
  As a user whose awk is busybox or another POSIX awk
  I want the shipped scripts to avoid GNU-only regex syntax
  So that dependency and tag parsing does not silently produce wrong answers

  Scenario: Bracket expressions in awk regexes are POSIX-portable
    Given the shipped scripts
    Then no bracket expression contains a backslash-escaped bracket
