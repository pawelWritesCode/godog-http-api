# https://docs.helium.com/api/blockchain/cities
Feature: Test related with cities.
  Hotspots are usually clustered in and around cities.
  The routes in this section help list all cities with their hotspot counts, or list all hotspots for a specific city

  Background:
    Given I save "https://api.helium.io/v1" as "HELIUM_V1_API"

  Scenario: List hotspot cities
    As API user,
    I would like to list all known hotspot cities with the total hotspot count for each city.

    When I send "GET" request to "{{.HELIUM_V1_API}}/cities" with body and headers:
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
    And the "JSON" node "data" should be slice of length "100"
    And the response body should be valid according to schema:
    """
    {
        "title": "list of richest accounts on helium blockchain",
        "type": "object",
        "properties": {
            "data": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "short_state": {
                            "type": "string"
                        },
                        "short_country": {
                            "type": "string"
                        },
                        "short_city": {
                            "type": "string"
                        },
                        "online_count": {
                            "type": "integer"
                        },
                        "offline_count": {
                            "type": "integer"
                        },
                        "long_state": {
                            "type": "string"
                        },
                        "long_country": {
                            "type": "string"
                        },
                        "long_city": {
                            "type": "string"
                        },
                        "hotspot_count": {
                            "type": "integer"
                        },
                        "city_id": {
                            "type": "string"
                        }
                    }
                }
            }
        }
    }
    """

    And I wait "1s"

  Scenario: Fetch info about city by it's id
    As API user,
    I would like to fetch a city for a given city id.

    Given I generate a random "int" in the range from "0" to "99" and save it as "RANDOM_ITEM_INDEX"
    When I send "GET" request to "{{.HELIUM_V1_API}}/cities" with body and headers:
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
    And the "JSON" node "data" should be slice of length "100"
    And the "JSON" node "data.{{.RANDOM_ITEM_INDEX}}.city_id" should be "string"
    And I save from the last response "JSON" node "data.{{.RANDOM_ITEM_INDEX}}.city_id" as "RANDOM_CITY_ID"

    And I wait "1s"

    When I send "GET" request to "{{.HELIUM_V1_API}}/cities/{{.RANDOM_CITY_ID}}" with body and headers:
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
    And the "JSON" node "data.city_id" should be "string" of value "{{.RANDOM_CITY_ID}}"
    And the "JSON" node "data.hotspot_count" should be "number"

    And I wait "1s"

  Scenario: List hotspots for a city
    As API user,
    I would like to list all known hotspots for a given city_id.
    The city_id captures the city, state and country and is included in the city list result.

    Given I generate a random "int" in the range from "0" to "99" and save it as "RANDOM_ITEM_INDEX"
    When I send "GET" request to "{{.HELIUM_V1_API}}/cities" with body and headers:
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
    And the "JSON" node "data" should be slice of length "100"
    And the "JSON" node "data.{{.RANDOM_ITEM_INDEX}}.city_id" should be "string"
    And I save from the last response "JSON" node "data.{{.RANDOM_ITEM_INDEX}}.city_id" as "RANDOM_CITY_ID"

    And I wait "1s"

    When I send "GET" request to "{{.HELIUM_V1_API}}/cities/{{.RANDOM_CITY_ID}}/hotspots" with body and headers:
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
    And the "JSON" node "data" should be "array"

    And I wait "1s"