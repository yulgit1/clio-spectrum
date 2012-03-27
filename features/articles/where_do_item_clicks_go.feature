@summon @articles @360link
Feature: Correct 360link routing
  In order to send users to the right resource
  CLIO should intelligently determine whether to send a user
  to an item-level e-link view, or directly to a resource

  Scenario: Hathitrust search
    When I search "articles" for "theory practice mental hygiene notter"
    And looking at the "1st" result
    Then the title should include "The theory and practice of hygiene"
    And the link should not be local
  
  Scenario: Proquest search
    When I search "articles" for "transference Ojibwe"
    And looking at the "1st" result 
    Then the title should include "Ojibwe into English Contexts"
    And the "Format" field should include "Full Text Available"
    And the link should be local

  Scenario: Citation only
    When I search "articles" for "amazonia petit p"
    And looking at the "1st" result
    Then the title should include "Amazonia"
    And the "Format" field should include "Journal"
    And the "Format" field should include "Citation"
    And the link should not be local

  Scenario: Alexander Street Press Audio Recording
    When I search "articles" for "Herbert Halpert new york city collection"
    And looking at the "1st" result
    Then the "Format" field should include "Audio Recording"
    And the "Format" field should include "Available Online"
    And the link should not be local

  Scenario: Music recordings 
    When I search "articles" for "mahler symphony neeme gothenburg seppo"
    And looking at the "1st" result
    Then the "Format" field should include "Music Recording"
    And the "Format" field should include "Available Online"
    And the link should not be local

  Scenario: Reference
    When I search "articles" for "integer sequences online encyclopedia"
    And looking at the "1st" result
    Then the "Format" field should include "Reference"
    And the "Format" field should include "Available Online"
    And the link should not be local
