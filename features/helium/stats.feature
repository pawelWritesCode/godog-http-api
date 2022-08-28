# https://docs.helium.com/api/blockchain/stats
Feature: Tests related to stats

  Background:
    Given I save "https://api.helium.io/v1" as "HELIUM_V1_API"

  Scenario: Successfully fetch blockchain stats
    As API user,
    I would like to retrieve basic stats for the blockchain such as total token supply,
    and average block and election times over a number of intervals.

    When I send "GET" request to "{{.HELIUM_V1_API}}/stats" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "User-Agent": "godog-http-api/2.1.0"
        }
    }
    """
    Then the response status code should be 200
    And the response body should have format "JSON"
    And the "JSON" response should have nodes "data.block_times, data.challenge_counts, data.counts, data.election_times, data.token_supply"
    And the "JSON" node "data.token_supply" should be "number"
    And the "JSON" node "data.block_times" should be "object"
    And the "JSON" node "data.challenge_counts" should be "object"
    And the "JSON" node "data.counts" should be "object"
    And the "JSON" node "data.election_times" should be "object"

    And I wait "1s"

  Scenario: Successfully fetch token supply
    As API user,
    I would like to fetch circulating token supply in either JSON or raw form.

    When I send "GET" request to "{{.HELIUM_V1_API}}/stats/token_supply" with body and headers:
    """
    {
        "body": {},
        "headers": {
            "User-Agent": "godog-http-api/2.1.0"
        }
    }
    """
    Then the response status code should be 200
    And the response body should have format "JSON"
    And the "JSON" node "data.token_supply" should be "number"

    And I wait "1s"