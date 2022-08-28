# https://docs.helium.com/api/blockchain/accounts
# https://documenter.getpostman.com/view/8776393/SVmsTzP6#5764bb54-e5e1-42ee-a7a7-b8f07a37a2ba
Feature: Tests related with accounts.

  Background:
    Given I save "https://api.helium.io/v1" as "HELIUM_V1_API"

  Scenario: Successfully fetch richest accounts
    As API user,
    I would like to fetch up to 100 of the accounts sorted by highest token balance.

    When I send "GET" request to "{{.HELIUM_V1_API}}/accounts/rich" with body and headers:
    """
    {
        "body": {},
        "headers": {}
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
                        "staked_balance": {
                            "type": "integer"
                        },
                        "sec_nonce": {
                            "type": "integer"
                        },
                        "sec_balance": {
                            "type": "integer"
                        },
                        "nonce": {
                            "type": "integer"
                        },
                        "dc_nonce": {
                            "type": "integer"
                        },
                        "dc_balance": {
                            "type": "integer"
                        },
                        "block": {
                            "type": "integer"
                        },
                        "balance": {
                            "type": "integer"
                        },
                        "address": {
                            "type": "string"
                        }
                    }
                }
            }
        }
    }
    """

    And I wait "1s"

  Scenario: Successfully fetch account list
    As API user,
    I would like to retrieve the current set of known accounts.

    When I send "GET" request to "{{.HELIUM_V1_API}}/accounts" with body and headers:
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
                        "staked_balance": {
                            "type": "integer"
                        },
                        "sec_nonce": {
                            "type": "integer"
                        },
                        "sec_balance": {
                            "type": "integer"
                        },
                        "nonce": {
                            "type": "integer"
                        },
                        "dc_nonce": {
                            "type": "integer"
                        },
                        "dc_balance": {
                            "type": "integer"
                        },
                        "block": {
                            "type": "integer"
                        },
                        "balance": {
                            "type": "integer"
                        },
                        "address": {
                            "type": "string"
                        }
                    }
                }
            }
        }
    }
    """

    And I wait "1s"

  Scenario: Successfully fetch account details
    As API user,
    I would like to retrieve a specific account record.
    The account details for a record include additional speculative nonces that indicate what the expected nonce
    for the account is for a specific balance.

    Given I generate a random "int" in the range from "0" to "99" and save it as "RANDOM_ITEM_INDEX"
    When I send "GET" request to "{{.HELIUM_V1_API}}/accounts" with body and headers:
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
    And I save from the last response "JSON" node "data.{{.RANDOM_ITEM_INDEX}}.address" as "RANDOM_ADDRESS"

    And I wait "1s"

    When I send "GET" request to "{{.HELIUM_V1_API}}/accounts/{{.RANDOM_ADDRESS}}" with body and headers:
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
    And the response body should be valid according to schema:
    """
    {
        "title": "list of richest accounts on helium blockchain",
        "type": "object",
        "properties": {
            "data": {
                "type": "object",
                "properties": {
                    "validator_count": {
                        "type": "number"
                    },
                    "staked_balance": {
                        "type": "number"
                    },
                    "speculative_sec_nonce": {
                        "type": "number"
                    },
                    "speculative_nonce": {
                        "type": "number"
                    },
                    "sec_nonce": {
                        "type": "number"
                    },
                    "sec_balance": {
                        "type": "number"
                    },
                    "nonce": {
                        "type": "number"
                    },
                    "hotspot_count": {
                        "type": "number"
                    },
                    "dc_nonce": {
                        "type": "number"
                    },
                    "dc_balance": {
                        "type": "number"
                    },
                    "block": {
                        "type": "number"
                    },
                    "balance": {
                        "type": "number"
                    },
                    "address": {
                        "type": "string"
                    }
                }
            }
        }
    }
    """

  Scenario: Successfully fetch hotspots for random address
    As API user,
    I would like to fetch hotspots owned by a given account address.

    Given I generate a random "int" in the range from "0" to "99" and save it as "RANDOM_ITEM_INDEX"
    When I send "GET" request to "{{.HELIUM_V1_API}}/accounts" with body and headers:
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
    And I save from the last response "JSON" node "data.{{.RANDOM_ITEM_INDEX}}.address" as "RANDOM_ADDRESS"

    And I wait "1s"

    When I send "GET" request to "{{.HELIUM_V1_API}}/accounts/{{.RANDOM_ADDRESS}}/hotspots" with body and headers:
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

  Scenario: Successfully fetch roles for random account.
    As API user,
    I would like to fetch transactions that indicate an account as a participant.
    This includes any transaction that involves the account, usually as a payer, payee or owner.

    Given I generate a random "int" in the range from "0" to "99" and save it as "RANDOM_ITEM_INDEX"
    When I send "GET" request to "{{.HELIUM_V1_API}}/accounts" with body and headers:
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
    And I save from the last response "JSON" node "data.{{.RANDOM_ITEM_INDEX}}.address" as "RANDOM_ADDRESS"

    And I wait "1s"

    When I send "GET" request to "{{.HELIUM_V1_API}}/accounts/{{.RANDOM_ADDRESS}}/roles" with body and headers:
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