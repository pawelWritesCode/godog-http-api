Feature: Ping publicly accessible website

  Scenario: I want to ping randomfox.ca to check whether I have internet connection

    When I send "GET" request to "https://randomfox.ca/floof/" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response body should have type "JSON"
    And the response status code should be 200
    And the JSON response should have nodes "image, link"

  Scenario: I want to ping https://animechan.vercel.app/api/random to check whether I have internet connection

    When I send "GET" request to "https://animechan.vercel.app/api/random" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response body should have type "JSON"
    And the response status code should be 200
    And the JSON response should have nodes "anime, character, quote"

  Scenario: I want to ping https://animechan.vercel.app/api/quotes to check whether I have internet connection

    When I send "GET" request to "https://animechan.vercel.app/api/quotes" with body and headers:
    """
    {
        "body": {},
        "headers": {}
    }
    """
    Then the response body should have type "JSON"
    And the response status code should be 200
    And the JSON node "root" should be "slice"
    And the JSON node "root" should be slice of length "10"
