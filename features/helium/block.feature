# https://docs.helium.com/api/blockchain/blocks
# https://documenter.getpostman.com/view/8776393/SVmsTzP6#c3f0d476-e692-4f77-9bda-d566b90948ff
Feature: Tests related with block

  Background:
    Given I save "https://api.helium.io/v1" as "HELIUM_V1_API"

  Scenario: Successfully fetch height of block
    As API user,
    I would like to get the current height of the blockchain.

    When I send "GET" request to "{{.HELIUM_V1_API}}/blocks/height" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200
    And the response body should have format "JSON"
    And the "JSON" node "$.data.height" should be "number"
    And the response body should be valid according to schema:
    """
    {
        "title": "block height",
        "type": "object",
        "properties": {
            "data": {
                "type": "object",
                "properties": {
                    "height": {
                        "type": "integer"
                    }
                }
            }
        }
    }
    """

    And I wait "1s"

  Scenario: Successfully fetch block stats
    As API user,
    I would like to get statistics on block production times.

    When I send "GET" request to "{{.HELIUM_V1_API}}/blocks/stats" with body and headers:
    """
    {
        "body": {},
        "headers": {"User-Agent": "godog-http-api/2.1.0"}
    }
    """
    Then the response status code should be 200
    And the response body should have format "JSON"
    And the response body should be valid according to schema:
    """
    {
        "title": "block height",
        "type": "object",
        "properties": {
            "data": {
                "type": "object",
                "properties": {
                    "last_week": {
                        "type": "object"
                    },
                    "last_month": {
                        "type": "object"
                    },
                    "last_hour": {
                        "type": "object"
                    },
                    "last_day": {
                        "type": "object"
                    }
                }
            }
        }
    }
    """
    And the "JSON" node "$.data.last_day.avg" should be "number"
    And the "JSON" node "$.data.last_day.stddev" should be "number"
    And the "JSON" node "$.data.last_hour.avg" should be "number"
    And the "JSON" node "$.data.last_hour.stddev" should be "number"
    And the "JSON" node "$.data.last_month.avg" should be "number"
    And the "JSON" node "$.data.last_month.stddev" should be "number"
    And the "JSON" node "$.data.last_week.avg" should be "number"
    And the "JSON" node "$.data.last_week.stddev" should be "number"

    And I wait "1s"

  Scenario: Fetch blocks height data.
    As API user,
    I would like to get block descriptor for block at height

    When I send "GET" request to "{{.HELIUM_V1_API}}/blocks/height" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200
    And the response body should have format "JSON"
    And the "JSON" node "$.data.height" should be "number"
    And I save from the last response "JSON" node "data.height" as "BLOCK_HEIGHT"

    And I wait "1s"

    When I send "GET" request to "{{.HELIUM_V1_API}}/blocks/{{.BLOCK_HEIGHT | printf `%2.f`}}" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200
    And the response body should have format "JSON"
    And the "JSON" node "data.hash" should not be "number"
    But the "JSON" node "data.hash" should be "string"
    And the "JSON" node "data.height" should be "int" of value "{{.BLOCK_HEIGHT | printf `%2.f`}}"
    And the "JSON" node "data.prev_hash" should not be "number"
    But the "JSON" node "data.prev_hash" should be "string"
    But the "JSON" node "data.time" should be "number"
    But the "JSON" node "data.transaction_count" should be "number"

    And I wait "1s"

  Scenario: Fetch blocks transactions
    As API user,
    I would like to get transactions for a block at a given height.
    The list of returned transactions is paged. A cursor field is present if more results are available.

    When I send "GET" request to "{{.HELIUM_V1_API}}/blocks/height" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response status code should be 200
    And the response body should have format "JSON"
    And the "JSON" node "$.data.height" should be "number"
    And I save from the last response "JSON" node "data.height" as "BLOCK_HEIGHT"

    And I wait "1s"

    When I send "GET" request to "{{.HELIUM_V1_API}}/blocks/{{.BLOCK_HEIGHT | printf `%2.f`}}/transactions" with body and headers:
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
    And the "JSON" node "data" should not be slice of length "0"

    And I wait "1s"